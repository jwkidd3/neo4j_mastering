// Neo4j Lab 8 - Data Reload Script
// Complete data setup for Lab 8: Performance Optimization
// Run this script if you need to reload the Lab 8 data state
// Includes Labs 1-7 data + Performance Indexes, Query Optimization, Caching

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: ENSURE LAB 7 FOUNDATION EXISTS
// ===================================
// This script builds on Lab 7 - make sure you have the foundation data

// Create constraints and indexes for performance optimization
CREATE CONSTRAINT customer_number_unique IF NOT EXISTS FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;
CREATE CONSTRAINT policy_number_unique IF NOT EXISTS FOR (p:Policy) REQUIRE p.policy_number IS UNIQUE;
CREATE CONSTRAINT agent_id_unique IF NOT EXISTS FOR (a:Agent) REQUIRE a.agent_id IS UNIQUE;
CREATE CONSTRAINT claim_number_unique IF NOT EXISTS FOR (cl:Claim) REQUIRE cl.claim_number IS UNIQUE;

// Performance indexes
CREATE INDEX customer_risk_tier IF NOT EXISTS FOR (c:Customer) ON (c.risk_tier);
CREATE INDEX customer_city_state IF NOT EXISTS FOR (c:Customer) ON (c.city, c.state);
CREATE INDEX customer_lifetime_value IF NOT EXISTS FOR (c:Customer) ON (c.lifetime_value);
CREATE INDEX customer_credit_score IF NOT EXISTS FOR (c:Customer) ON (c.credit_score);
CREATE INDEX policy_status_type IF NOT EXISTS FOR (p:Policy) ON (p.policy_status, p.product_type);
CREATE INDEX policy_premium_range IF NOT EXISTS FOR (p:Policy) ON (p.annual_premium);
CREATE INDEX policy_effective_date IF NOT EXISTS FOR (p:Policy) ON (p.effective_date);
CREATE INDEX claim_status_amount IF NOT EXISTS FOR (cl:Claim) ON (cl.claim_status, cl.claim_amount);
CREATE INDEX agent_territory_performance IF NOT EXISTS FOR (a:Agent) ON (a.territory, a.performance_rating);

// Full-text search indexes
CREATE FULLTEXT INDEX customer_search_idx IF NOT EXISTS
FOR (c:Customer) ON EACH [c.first_name, c.last_name, c.email];

CREATE FULLTEXT INDEX policy_search_idx IF NOT EXISTS
FOR (p:Policy) ON EACH [p.policy_number, p.auto_make, p.auto_model];

// Ensure basic entities exist (abbreviated for performance)
MERGE (customer1:Customer:Individual {customer_number: "CUST-001234"})
ON CREATE SET customer1.id = randomUUID(), customer1.first_name = "Sarah", customer1.last_name = "Johnson", customer1.city = "Austin", customer1.state = "TX", customer1.credit_score = 720, customer1.risk_tier = "Standard", customer1.lifetime_value = 12500.00, customer1.customer_since = date("2020-01-15"), customer1.created_at = datetime()

// Create bulk customers for performance testing
WITH [
  {customer_number: "CUST-001234", first_name: "Sarah", last_name: "Johnson", city: "Austin", state: "TX", credit_score: 720, risk_tier: "Standard", lifetime_value: 12500.00},
  {customer_number: "CUST-001235", first_name: "Michael", last_name: "Chen", city: "Austin", state: "TX", credit_score: 680, risk_tier: "Standard", lifetime_value: 18750.00},
  {customer_number: "CUST-001236", first_name: "Emma", last_name: "Rodriguez", city: "Dallas", state: "TX", credit_score: 750, risk_tier: "Preferred", lifetime_value: 8900.00},
  {customer_number: "CUST-001237", first_name: "James", last_name: "Wilson", city: "Houston", state: "TX", credit_score: 685, risk_tier: "Standard", lifetime_value: 8900.00},
  {customer_number: "CUST-001238", first_name: "Maria", last_name: "Garcia", city: "Dallas", state: "TX", credit_score: 745, risk_tier: "Preferred", lifetime_value: 15600.00},
  {customer_number: "CUST-001239", first_name: "Robert", last_name: "Kim", city: "Austin", state: "TX", credit_score: 720, risk_tier: "Standard", lifetime_value: 12300.00},
  {customer_number: "CUST-001240", first_name: "Jennifer", last_name: "Brown", city: "San Antonio", state: "TX", credit_score: 660, risk_tier: "Standard", lifetime_value: 9800.00},
  {customer_number: "CUST-001241", first_name: "William", last_name: "Davis", city: "Austin", state: "TX", credit_score: 780, risk_tier: "Preferred", lifetime_value: 18900.00},
  {customer_number: "CUST-001242", first_name: "Linda", last_name: "Miller", city: "Houston", state: "TX", credit_score: 635, risk_tier: "Substandard", lifetime_value: 6700.00},
  {customer_number: "CUST-001243", first_name: "Christopher", last_name: "Anderson", city: "Dallas", state: "TX", credit_score: 710, risk_tier: "Standard", lifetime_value: 11400.00},
  {customer_number: "CUST-001244", first_name: "Patricia", last_name: "Taylor", city: "Austin", state: "TX", credit_score: 755, risk_tier: "Preferred", lifetime_value: 16800.00},
  {customer_number: "CUST-001245", first_name: "Matthew", last_name: "Thomas", city: "San Antonio", state: "TX", credit_score: 695, risk_tier: "Standard", lifetime_value: 10200.00},
  {customer_number: "CUST-001246", first_name: "Barbara", last_name: "Jackson", city: "Houston", state: "TX", credit_score: 725, risk_tier: "Standard", lifetime_value: 13700.00}
] AS customerData

UNWIND customerData AS row
MERGE (c:Customer:Individual {customer_number: row.customer_number})
ON CREATE SET
  c.id = randomUUID(), c.first_name = row.first_name, c.last_name = row.last_name,
  c.email = toLower(row.first_name) + "." + toLower(row.last_name) + "@email.com",
  c.city = row.city, c.state = row.state, c.credit_score = row.credit_score,
  c.risk_tier = row.risk_tier, c.lifetime_value = row.lifetime_value,
  c.customer_since = date("2019-01-01") + duration({days: toInteger(rand() * 1500)}),
  c.phone = "555-" + toString(toInteger(rand() * 9000) + 1000),
  c.zip_code = toString(toInteger(rand() * 90000) + 10000),
  c.date_of_birth = date("1960-01-01") + duration({days: toInteger(rand() * 15000)}),
  c.ssn_last_four = toString(toInteger(rand() * 9000) + 1000),
  c.created_at = datetime(), c.version = 1;

// Create agents with performance tracking
WITH [
  {agent_id: "AGT-001", first_name: "David", last_name: "Wilson", territory: "Central Texas", performance_rating: "Excellent"},
  {agent_id: "AGT-002", first_name: "Lisa", last_name: "Thompson", territory: "North Texas", performance_rating: "Very Good"},
  {agent_id: "AGT-003", first_name: "Sarah", last_name: "Williams", territory: "Houston Metro", performance_rating: "Very Good"},
  {agent_id: "AGT-004", first_name: "Michael", last_name: "Jones", territory: "Dallas Metro", performance_rating: "Excellent"},
  {agent_id: "AGT-005", first_name: "Jessica", last_name: "Brown", territory: "San Antonio", performance_rating: "Good"},
  {agent_id: "AGT-006", first_name: "Christopher", last_name: "Davis", territory: "Central Austin", performance_rating: "Very Good"}
] AS agentData

UNWIND agentData AS row
MERGE (agent:Agent:Employee {agent_id: row.agent_id})
ON CREATE SET
  agent.id = randomUUID(), agent.first_name = row.first_name, agent.last_name = row.last_name,
  agent.email = toLower(row.first_name) + "." + toLower(row.last_name) + "@insurance.com",
  agent.territory = row.territory, agent.performance_rating = row.performance_rating,
  agent.phone = "555-" + toString(toInteger(rand() * 9000) + 1000),
  agent.license_number = "TX-INS-" + toString(100000 + toInteger(rand() * 900000)),
  agent.hire_date = date("2015-01-01") + duration({days: toInteger(rand() * 2500)}),
  agent.commission_rate = 0.08 + (rand() * 0.08), // 8-16%
  agent.ytd_sales = 50000 + toInteger(rand() * 150000),
  agent.customer_count = 8 + toInteger(rand() * 12),
  agent.sales_quota = 120000 + toInteger(rand() * 100000),
  agent.created_at = datetime(), agent.version = 1;

// ===================================
// STEP 3: CREATE PERFORMANCE MONITORING ENTITIES
// ===================================

// Create query performance monitoring
CREATE (perf_monitor:QueryPerformanceMonitor {
  id: randomUUID(),
  monitor_id: "PERF-MON-001",
  monitoring_start_date: datetime(),

  // Performance metrics
  total_queries_per_hour: 900,
  avg_response_time_ms: 78.5,
  cache_hit_ratio: 0.73,
  memory_usage_mb: 512.8,
  cpu_utilization_percent: 45.2,

  // Index usage percentages
  customer_indexes_usage: 85.3,
  policy_indexes_usage: 92.1,
  claim_indexes_usage: 67.8,
  agent_indexes_usage: 78.9,
  fulltext_indexes_usage: 34.5,

  // Recommendations
  recommendations: [
    "Add RANGE index on policy.annual_premium for faster range queries",
    "Implement query result caching for dashboard queries",
    "Optimize relationship traversal patterns in customer analytics",
    "Consider graph projections for frequent centrality calculations"
  ],

  last_updated: datetime(),
  created_at: datetime(),
  created_by: "performance_monitoring_system",
  version: 1
});

// ===================================
// STEP 4: CREATE CACHING OPTIMIZATION ENTITIES
// ===================================

// Create cache optimization tracking
CREATE (cache_opt:CacheOptimization {
  id: randomUUID(),
  cache_id: "CACHE-OPT-001",
  optimization_date: datetime(),

  // Cache configuration
  cache_size_mb: 1024,
  cache_type: "LRU", // Least Recently Used
  eviction_policy: "Time-based with LRU fallback",
  cache_ttl_seconds: 3600, // 1 hour

  // Cache performance metrics
  cache_hit_ratio: 0.73,
  cache_miss_ratio: 0.27,
  cache_evictions_per_hour: 145,
  cache_updates_per_hour: 320,

  // Cached query category names
  cached_query_categories: ["Customer Profiles", "Policy Summaries", "Agent Performance Metrics", "Claims Statistics", "Centrality Scores"],
  total_cache_entries: 3390,

  // Cache optimization strategies
  optimization_strategies: [
    "Preload high-value customer profiles during off-peak hours",
    "Implement predictive caching for trending queries",
    "Use write-through caching for frequently updated data",
    "Implement distributed caching for multi-instance deployment"
  ],

  // Performance improvements
  avg_query_time_reduction_percent: 68.4,
  database_load_reduction_percent: 42.1,
  user_experience_improvement_score: 8.7,
  cost_savings_percent: 23.8,

  // Memory efficiency
  compression_ratio: 0.73,
  memory_fragmentation_percent: 8.2,
  garbage_collection_frequency: "Every 2 hours",

  created_at: datetime(),
  created_by: "cache_optimization_system",
  version: 1
});

// ===================================
// STEP 5: CREATE QUERY OPTIMIZATION RESULTS
// ===================================

// Create query optimization tracking for common insurance patterns
CREATE (query_opt:QueryOptimization {
  id: randomUUID(),
  optimization_id: "QUERY-OPT-001",
  optimization_date: datetime(),

  // Query optimization statistics
  optimized_query_categories: ["Customer Risk Analysis", "Policy Portfolio Aggregation", "Claims Fraud Detection", "Agent Performance Dashboard", "Customer 360 Deep Dive"],
  avg_improvement_percent: 78.5,
  total_optimizations: 5,

  // Index optimizations
  implemented_indexes: ["customer_ltv_risk_composite", "policy_premium_date_composite", "claim_amount_status_composite"],
  avg_index_performance_gain: 66.8,

  // Pattern optimization types
  optimized_patterns: ["Fan-out Traversals", "Aggregation Queries", "Full-text Search"],

  // Overall performance improvements
  total_queries_optimized: 47,
  avg_performance_improvement_percent: 74.8,
  total_cost_savings_annual: 125000.00,
  user_satisfaction_improvement: 8.3,
  system_scalability_factor: 3.2,

  created_at: datetime(),
  created_by: "query_optimization_engine",
  version: 1
});

// ===================================
// STEP 6: CREATE PERFORMANCE BENCHMARKS
// ===================================

// Create performance benchmarks for different query types
MATCH (customer:Customer)
WITH collect(customer) AS customers,
     count(customer) AS customer_count

CREATE (benchmark:PerformanceBenchmark {
  id: randomUUID(),
  benchmark_id: "PERF-BENCH-001",
  benchmark_date: datetime(),
  database_size_nodes: customer_count * 8, // Estimated total nodes
  database_size_relationships: customer_count * 12, // Estimated relationships

  // Benchmark categories
  benchmark_categories: ["Simple Lookups", "Range Queries", "Relationship Traversals", "Complex Analytics", "Graph Algorithms"],
  simple_lookups_avg_ms: 3.2,
  range_queries_avg_ms: 15.7,
  traversals_avg_ms: 45.3,
  analytics_avg_ms: 156.8,
  algorithms_avg_ms: 890.4,

  // Scalability
  current_load_capacity: "10,000 concurrent users",
  projected_growth_hardware: "4x CPU, 6x RAM",
  performance_degradation_percent: 25.3,
  bottlenecks: ["Memory-intensive graph algorithms", "Complex relationship traversals", "Real-time aggregation queries"],

  // Optimization roadmap
  high_priority_optimizations: ["Implement query result caching for dashboard queries", "Add composite indexes for multi-property filters"],
  medium_priority_optimizations: ["Optimize graph algorithm execution with projections", "Implement materialized views for complex aggregations"],
  low_priority_optimizations: ["Add read replicas for analytics workloads"],

  created_at: datetime(),
  created_by: "performance_benchmark_system",
  version: 1
});

// ===================================
// STEP 7: CREATE COMMISSION TRACKING SYSTEM
// ===================================

// Create commission tracking entities for agent performance optimization
MATCH (agent:Agent)
MATCH (customer:Customer)
WHERE customer.city =
  CASE agent.territory
    WHEN "Central Texas" THEN "Austin"
    WHEN "North Texas" THEN "Dallas"
    WHEN "Houston Metro" THEN "Houston"
    WHEN "San Antonio" THEN "San Antonio"
    ELSE "Austin"
  END

WITH agent, collect(customer)[0..3] AS assigned_customers
UNWIND assigned_customers AS customer

CREATE (commission:Commission {
  id: randomUUID(),
  commission_id: "COMM-" + agent.agent_id + "-" + customer.customer_number,
  agent_id: agent.agent_id,
  customer_id: customer.customer_number,
  commission_type:
    CASE toInteger(rand() * 3)
      WHEN 0 THEN "New Business"
      WHEN 1 THEN "Renewal"
      ELSE "Cross-sell"
    END,

  // Commission calculation
  commission_rate: agent.commission_rate,
  base_premium: customer.lifetime_value * 0.1, // Approximate annual premium
  commission_amount: (customer.lifetime_value * 0.1) * agent.commission_rate,

  // Performance metrics
  sale_date: date("2024-01-01") + duration({days: toInteger(rand() * 180)}),
  payment_date: date("2024-01-01") + duration({days: toInteger(rand() * 210)}),
  payment_status:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Paid"
      WHEN 1 THEN "Pending"
      WHEN 2 THEN "Processing"
      ELSE "Held"
    END,

  // Quality metrics
  customer_satisfaction_score: 3.5 + (rand() * 1.5), // 3.5-5.0
  retention_probability: 0.7 + (rand() * 0.25), // 70-95%
  cross_sell_success: rand() < 0.3, // 30% cross-sell success rate

  created_at: datetime(),
  created_by: "commission_system",
  version: 1
})

// Connect commission to agent and customer
CREATE (agent)-[:EARNED_COMMISSION {
  earning_date: commission.sale_date,
  payment_status: commission.payment_status,
  created_at: datetime()
}]->(commission)

CREATE (commission)-[:FOR_CUSTOMER {
  customer_acquisition_date: commission.sale_date,
  commission_type: commission.commission_type,
  created_at: datetime()
}]->(customer);

// ===================================
// STEP 8: PERFORMANCE OPTIMIZATION SUMMARY
// ===================================

// Update agents with performance optimization metrics
MATCH (agent:Agent)-[:EARNED_COMMISSION]->(commission:Commission)
WITH agent,
     count(commission) AS total_commissions,
     sum(commission.commission_amount) AS total_commission_earned,
     avg(commission.customer_satisfaction_score) AS avg_satisfaction,
     avg(commission.retention_probability) AS avg_retention

SET agent.total_commissions = total_commissions,
    agent.total_commission_earned = round(total_commission_earned * 100) / 100,
    agent.avg_customer_satisfaction = round(avg_satisfaction * 10) / 10,
    agent.avg_retention_rate = round(avg_retention * 100) / 100,
    agent.performance_index =
      (avg_satisfaction / 5.0 * 0.4) +
      (avg_retention * 0.4) +
      (CASE WHEN total_commission_earned > agent.sales_quota * 0.8 THEN 0.2 ELSE 0.0 END),
    agent.optimization_tier =
      CASE WHEN agent.performance_index > 0.8 THEN "Tier 1 - Top Performer"
           WHEN agent.performance_index > 0.6 THEN "Tier 2 - Strong Performer"
           WHEN agent.performance_index > 0.4 THEN "Tier 3 - Standard Performer"
           ELSE "Tier 4 - Needs Improvement" END;

// ===================================
// STEP 9: VERIFICATION AND SUMMARY
// ===================================

// Verify Lab 8 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Performance optimization summary
MATCH (perf:QueryPerformanceMonitor)
RETURN perf.total_queries_per_hour AS queries_per_hour,
       perf.avg_response_time_ms AS avg_response_time,
       perf.cache_hit_ratio AS cache_hit_ratio,
       perf.cpu_utilization_percent AS cpu_usage
LIMIT 1;

// Agent performance optimization summary
MATCH (agent:Agent)
RETURN agent.optimization_tier AS performance_tier,
       count(agent) AS agent_count,
       avg(agent.performance_index) AS avg_performance_index,
       avg(agent.total_commission_earned) AS avg_commission_earned
ORDER BY avg_performance_index DESC;

// Commission system summary
MATCH (commission:Commission)
RETURN commission.commission_type AS commission_type,
       commission.payment_status AS status,
       count(commission) AS count,
       sum(commission.commission_amount) AS total_amount,
       avg(commission.customer_satisfaction_score) AS avg_satisfaction
ORDER BY total_amount DESC;

// Expected result: 400 nodes, 500 relationships with performance optimization