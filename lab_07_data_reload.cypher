// Neo4j Lab 7 - Data Reload Script
// Complete data setup for Lab 7: Graph Algorithms for Insurance
// Run this script if you need to reload the Lab 7 data state
// Includes Labs 1-6 data + Graph Algorithm Projections, Centrality Analysis, Community Detection

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: ENSURE LAB 6 FOUNDATION EXISTS
// ===================================
// This script builds on Lab 6 - make sure you have the foundation data

// Create constraints if not exist
CREATE CONSTRAINT customer_number_unique IF NOT EXISTS FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;

// Ensure basic customer and analytics data exists (abbreviated for performance)
MERGE (customer1:Customer:Individual {customer_number: "CUST-001234"})
ON CREATE SET customer1.id = randomUUID(), customer1.first_name = "Sarah", customer1.last_name = "Johnson", customer1.city = "Austin", customer1.state = "TX", customer1.credit_score = 720, customer1.risk_tier = "Standard", customer1.lifetime_value = 12500.00, customer1.created_at = datetime()

MERGE (customer2:Customer:Individual {customer_number: "CUST-001235"})
ON CREATE SET customer2.id = randomUUID(), customer2.first_name = "Michael", customer2.last_name = "Chen", customer2.city = "Austin", customer2.state = "TX", customer2.credit_score = 680, customer2.risk_tier = "Standard", customer2.lifetime_value = 18750.00, customer2.created_at = datetime()

MERGE (customer3:Customer:Individual {customer_number: "CUST-001236"})
ON CREATE SET customer3.id = randomUUID(), customer3.first_name = "Emma", customer3.last_name = "Rodriguez", customer3.city = "Dallas", customer3.state = "TX", customer3.credit_score = 750, customer3.risk_tier = "Preferred", customer3.lifetime_value = 8900.00, customer3.created_at = datetime();

// Create bulk customers with enhanced network relationships
WITH [
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
  c.city = row.city, c.state = row.state, c.credit_score = row.credit_score,
  c.risk_tier = row.risk_tier, c.lifetime_value = row.lifetime_value,
  c.customer_since = date("2019-01-01") + duration({days: toInteger(rand() * 1500)}),
  c.created_at = datetime(), c.version = 1;

// Create agents for network analysis
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
  agent.territory = row.territory, agent.performance_rating = row.performance_rating,
  agent.ytd_sales = 50000 + toInteger(rand() * 100000),
  agent.customer_count = 3 + toInteger(rand() * 7),
  agent.sales_quota = 120000 + toInteger(rand() * 80000),
  agent.created_at = datetime(), agent.version = 1;

// ===================================
// STEP 3: CREATE ENHANCED NETWORK RELATIONSHIPS
// ===================================

// Create customer referral network for centrality analysis
MATCH (customers:Customer)
WITH collect(customers) AS allCustomers
UNWIND allCustomers AS referrer
WITH referrer, allCustomers,
     // Create referral probability based on customer value and location
     [customer IN allCustomers WHERE
      customer <> referrer AND
      customer.city = referrer.city AND
      customer.risk_tier IN ["Preferred", "Standard"] AND
      rand() < 0.15 // 15% chance of referral relationship
     ] AS potential_referrals

UNWIND potential_referrals AS referred
WITH referrer, referred
WHERE referrer.customer_number < referred.customer_number // Avoid duplicates

CREATE (referrer)-[:REFERRED {
  referral_date: date("2020-01-01") + duration({days: toInteger(rand() * 1200)}),
  referral_bonus: 25.0 + (rand() * 75.0), // $25-$100 bonus
  conversion_status:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Converted"
      WHEN 1 THEN "Quoted"
      WHEN 2 THEN "Contacted"
      ELSE "No Response"
    END,
  referral_channel:
    CASE toInteger(rand() * 3)
      WHEN 0 THEN "Word of Mouth"
      WHEN 1 THEN "Social Media"
      ELSE "Email"
    END,
  strength: 0.3 + (rand() * 0.7), // Relationship strength 0.3-1.0
  created_at: datetime()
}]->(referred);

// Create agent collaboration network
MATCH (agents:Agent)
WITH collect(agents) AS allAgents
UNWIND allAgents AS agent1
WITH agent1, allAgents,
     [agent2 IN allAgents WHERE
      agent2 <> agent1 AND
      (agent1.territory CONTAINS "Texas" AND agent2.territory CONTAINS "Texas") AND
      rand() < 0.4 // 40% chance of collaboration
     ] AS collaborating_agents

UNWIND collaborating_agents AS agent2
WITH agent1, agent2
WHERE agent1.agent_id < agent2.agent_id // Avoid duplicates

CREATE (agent1)-[:COLLABORATES_WITH {
  collaboration_type:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Cross-referral"
      WHEN 1 THEN "Joint accounts"
      WHEN 2 THEN "Knowledge sharing"
      ELSE "Territory coordination"
    END,
  collaboration_frequency:
    CASE toInteger(rand() * 3)
      WHEN 0 THEN "Weekly"
      WHEN 1 THEN "Monthly"
      ELSE "Quarterly"
    END,
  relationship_strength: 0.4 + (rand() * 0.6),
  joint_sales_value: 10000 + (rand() * 50000),
  start_date: date("2020-01-01") + duration({days: toInteger(rand() * 1000)}),
  created_at: datetime()
}]->(agent2);

// Create customer influence network (based on same agent, location, similar profiles)
MATCH (c1:Customer), (c2:Customer)
WHERE c1.customer_number < c2.customer_number
  AND c1.city = c2.city
  AND abs(c1.credit_score - c2.credit_score) < 50
  AND c1.risk_tier = c2.risk_tier
  AND rand() < 0.08 // 8% chance of influence relationship

CREATE (c1)-[:INFLUENCES {
  influence_type:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Social"
      WHEN 1 THEN "Professional"
      WHEN 2 THEN "Family"
      ELSE "Neighborhood"
    END,
  influence_strength: 0.2 + (rand() * 0.6), // 0.2-0.8
  interaction_frequency:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Daily"
      WHEN 1 THEN "Weekly"
      WHEN 2 THEN "Monthly"
      ELSE "Occasionally"
    END,
  relationship_duration_months: 12 + toInteger(rand() * 60), // 1-5 years
  mutual_influence: rand() < 0.6, // 60% chance of mutual influence
  created_at: datetime()
}]->(c2);

// ===================================
// STEP 4: CREATE CENTRALITY SCORES
// ===================================

// Calculate and store centrality scores for customers
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[r_out:REFERRED|INFLUENCES]->()
OPTIONAL MATCH (customer)<-[r_in:REFERRED|INFLUENCES]-()
WITH customer,
     count(r_out) AS outgoing_connections,
     count(r_in) AS incoming_connections,
     count(r_out) + count(r_in) AS total_connections

CREATE (centrality:CentralityAnalysis {
  id: randomUUID(),
  entity_id: customer.customer_number,
  entity_type: "Customer",
  analysis_date: date(),

  // Degree centrality (direct connections)
  degree_centrality: total_connections,
  in_degree: incoming_connections,
  out_degree: outgoing_connections,
  normalized_degree: total_connections / 20.0, // Normalize by approximate max connections

  // Simulated centrality scores (in production, these would be calculated by GDS algorithms)
  betweenness_centrality: rand() * 0.5, // How often node appears on shortest paths
  closeness_centrality: 0.3 + (rand() * 0.4), // How close to all other nodes
  pagerank_score: 0.15 + (rand() * 0.85), // Google PageRank algorithm
  eigenvector_centrality: rand() * 1.0, // Connections to well-connected nodes

  // Insurance-specific influence scores
  referral_influence_score:
    CASE WHEN outgoing_connections > 2 THEN 0.8 + (rand() * 0.2)
         WHEN outgoing_connections > 0 THEN 0.4 + (rand() * 0.4)
         ELSE rand() * 0.3 END,

  network_value_score: // Based on LTV of connected customers
    customer.lifetime_value / 20000.0 + (total_connections * 0.1),

  risk_propagation_score: // How risk might spread through network
    CASE customer.risk_tier
      WHEN "Substandard" THEN 0.7 + (total_connections * 0.1)
      WHEN "Standard" THEN 0.4 + (total_connections * 0.05)
      ELSE 0.1 + (total_connections * 0.02) END,

  // Marketing potential
  viral_coefficient: // Potential for viral marketing
    (outgoing_connections * 0.2) +
    CASE customer.risk_tier WHEN "Preferred" THEN 0.3 ELSE 0.1 END,

  influence_rank:
    CASE WHEN total_connections >= 5 THEN "High Influencer"
         WHEN total_connections >= 3 THEN "Medium Influencer"
         WHEN total_connections >= 1 THEN "Low Influencer"
         ELSE "No Influence" END,

  created_at: datetime(),
  created_by: "centrality_engine",
  version: 1
})

CREATE (customer)-[:HAS_CENTRALITY_ANALYSIS {
  analysis_date: date(),
  current_analysis: true,
  created_at: datetime()
}]->(centrality);

// ===================================
// STEP 5: CREATE AGENT NETWORK ANALYSIS
// ===================================

// Calculate centrality scores for agents
MATCH (agent:Agent)
OPTIONAL MATCH (agent)-[r_out:COLLABORATES_WITH|SERVICES]->()
OPTIONAL MATCH (agent)<-[r_in:COLLABORATES_WITH|SERVICES]-()
WITH agent,
     count(r_out) AS outgoing_connections,
     count(r_in) AS incoming_connections,
     count(r_out) + count(r_in) AS total_connections

CREATE (agent_centrality:CentralityAnalysis {
  id: randomUUID(),
  entity_id: agent.agent_id,
  entity_type: "Agent",
  analysis_date: date(),

  // Network metrics
  degree_centrality: total_connections,
  in_degree: incoming_connections,
  out_degree: outgoing_connections,
  normalized_degree: total_connections / 15.0, // Normalize by max expected connections

  // Simulated advanced centrality scores
  betweenness_centrality: rand() * 0.6,
  closeness_centrality: 0.4 + (rand() * 0.3),
  pagerank_score: 0.10 + (rand() * 0.90),
  eigenvector_centrality: rand() * 1.0,

  // Agent-specific influence scores
  collaboration_influence_score:
    CASE agent.performance_rating
      WHEN "Excellent" THEN 0.8 + (rand() * 0.2)
      WHEN "Very Good" THEN 0.6 + (rand() * 0.3)
      ELSE 0.3 + (rand() * 0.4) END,

  territory_leadership_score: // Leadership within territory
    (agent.customer_count / 10.0) + (total_connections * 0.1),

  knowledge_sharing_potential: // Ability to share best practices
    CASE agent.performance_rating
      WHEN "Excellent" THEN 0.9 + (rand() * 0.1)
      WHEN "Very Good" THEN 0.7 + (rand() * 0.2)
      ELSE 0.4 + (rand() * 0.3) END,

  network_reach: // Potential customer reach through network
    agent.customer_count + (total_connections * 2),

  influence_rank:
    CASE WHEN total_connections >= 4 AND agent.performance_rating = "Excellent" THEN "Key Opinion Leader"
         WHEN total_connections >= 3 THEN "Influencer"
         WHEN total_connections >= 1 THEN "Connector"
         ELSE "Individual Contributor" END,

  created_at: datetime(),
  created_by: "centrality_engine",
  version: 1
})

CREATE (agent)-[:HAS_CENTRALITY_ANALYSIS {
  analysis_date: date(),
  current_analysis: true,
  created_at: datetime()
}]->(agent_centrality);

// ===================================
// STEP 6: CREATE COMMUNITY DETECTION RESULTS
// ===================================

// Create customer communities based on geographic and behavioral clustering
MATCH (customer:Customer)
WITH customer,
  // Assign community based on city and risk tier
  customer.city + "-" + customer.risk_tier AS community_id,
  CASE customer.city
    WHEN "Austin" THEN
      CASE customer.risk_tier
        WHEN "Preferred" THEN "Austin-Preferred"
        WHEN "Standard" THEN "Austin-Standard"
        ELSE "Austin-Substandard" END
    WHEN "Dallas" THEN
      CASE customer.risk_tier
        WHEN "Preferred" THEN "Dallas-Preferred"
        WHEN "Standard" THEN "Dallas-Standard"
        ELSE "Dallas-Substandard" END
    WHEN "Houston" THEN
      CASE customer.risk_tier
        WHEN "Preferred" THEN "Houston-Preferred"
        WHEN "Standard" THEN "Houston-Standard"
        ELSE "Houston-Substandard" END
    WHEN "San Antonio" THEN "San-Antonio-Mixed"
    ELSE "Other-Texas"
  END AS primary_community

// Create community nodes
MERGE (community:CustomerCommunity {community_id: primary_community})
ON CREATE SET
  community.id = randomUUID(),
  community.community_name = primary_community,
  community.formation_date = date(),
  community.geographic_center = customer.city,
  community.risk_profile = customer.risk_tier,
  community.member_count = 0,
  community.avg_lifetime_value = 0.0,
  community.avg_credit_score = 0,
  community.total_premium_volume = 0.0,
  community.community_type = "Geographic-Risk Cluster",
  community.cohesion_score = 0.6 + (rand() * 0.3), // How tightly connected
  community.growth_rate = -0.05 + (rand() * 0.20), // -5% to +15% growth
  community.churn_risk =
    CASE customer.risk_tier
      WHEN "Preferred" THEN 0.05 + (rand() * 0.10)
      WHEN "Standard" THEN 0.15 + (rand() * 0.15)
      ELSE 0.30 + (rand() * 0.20) END,
  community.created_at = datetime(),
  community.created_by = "community_detection_engine",
  community.version = 1

// Connect customers to their communities
CREATE (customer)-[:BELONGS_TO_COMMUNITY {
  membership_date: date("2020-01-01") + duration({days: toInteger(rand() * 1200)}),
  membership_strength: 0.5 + (rand() * 0.5), // How strongly they belong
  community_role:
    CASE WHEN customer.lifetime_value > 15000 THEN "Community Leader"
         WHEN customer.lifetime_value > 10000 THEN "Active Member"
         ELSE "Standard Member" END,
  influence_within_community: rand(),
  created_at: datetime()
}]->(community);

// Update community metrics
MATCH (community:CustomerCommunity)<-[:BELONGS_TO_COMMUNITY]-(customer:Customer)
WITH community,
     collect(customer) AS members,
     count(customer) AS member_count,
     avg(customer.lifetime_value) AS avg_ltv,
     avg(customer.credit_score) AS avg_credit,
     sum(customer.lifetime_value) AS total_value

SET community.member_count = member_count,
    community.avg_lifetime_value = round(avg_ltv * 100) / 100,
    community.avg_credit_score = round(avg_credit),
    community.total_premium_volume = round(total_value * 100) / 100,
    community.last_updated = datetime();

// ===================================
// STEP 7: CREATE GRAPH ALGORITHM INSIGHTS
// ===================================

// Create algorithm results and insights
CREATE (algorithm_run:AlgorithmExecution {
  id: randomUUID(),
  execution_id: "ALG-RUN-" + toString(toInteger(rand() * 100000)),
  execution_date: datetime(),

  // Algorithm details
  algorithms_executed: [
    "PageRank",
    "Betweenness Centrality",
    "Community Detection (Louvain)",
    "Node Similarity",
    "Shortest Path"
  ],

  // Graph statistics
  total_nodes_analyzed: 50, // Approximate count
  total_relationships_analyzed: 150,
  graph_density: 0.12, // 12% of possible connections exist
  average_clustering_coefficient: 0.35,
  graph_diameter: 6, // Longest shortest path

  // Key insights
  most_influential_customers: [
    "CUST-001241", // William Davis - High LTV + Preferred
    "CUST-001244", // Patricia Taylor - High LTV + Austin
    "CUST-001238"  // Maria Garcia - High LTV + Preferred
  ],

  highest_risk_propagation: [
    "CUST-001242", // Linda Miller - Substandard + Houston
    "CUST-001240"  // Jennifer Brown - Standard + San Antonio
  ],

  communities_detected: 7,
  largest_community_size: 6,
  most_cohesive_community: "Austin-Preferred",
  highest_growth_community: "Dallas-Preferred",

  // Business recommendations
  marketing_targets: [
    "Target Austin-Preferred community for premium products",
    "Focus retention efforts on Houston-Standard community",
    "Leverage CUST-001241 for referral campaigns"
  ],

  risk_mitigation_actions: [
    "Monitor CUST-001242 network for churn indicators",
    "Strengthen relationships in San Antonio market",
    "Implement community-based retention programs"
  ],

  cross_sell_opportunities: [
    "Life insurance to Austin-Preferred community",
    "Property insurance expansion in Dallas market",
    "Commercial insurance for high-influence customers"
  ],

  execution_time_seconds: 45.7,
  memory_usage_mb: 128.5,
  algorithm_version: "GDS 2.5.0",
  created_at: datetime(),
  created_by: "graph_algorithm_engine",
  version: 1
});

// ===================================
// STEP 8: CREATE NETWORK INSIGHTS DASHBOARD DATA
// ===================================

// Create network insights for business intelligence
MATCH (customer:Customer)-[:HAS_CENTRALITY_ANALYSIS]->(centrality:CentralityAnalysis)
WITH customer, centrality
ORDER BY centrality.network_value_score DESC
LIMIT 10

CREATE (insight:NetworkInsight {
  id: randomUUID(),
  insight_id: "NETWORK-INSIGHT-" + customer.customer_number,
  customer_id: customer.customer_number,
  insight_type: "High Network Value Customer",
  insight_date: date(),

  // Customer details
  customer_name: customer.first_name + " " + customer.last_name,
  customer_location: customer.city + ", " + customer.state,
  customer_tier: customer.risk_tier,
  lifetime_value: customer.lifetime_value,

  // Network metrics
  network_connections: centrality.degree_centrality,
  influence_score: centrality.referral_influence_score,
  network_value: centrality.network_value_score,
  viral_potential: centrality.viral_coefficient,

  // Business recommendations
  recommended_actions: [
    CASE WHEN centrality.referral_influence_score > 0.7
         THEN "Enroll in VIP referral program"
         ELSE "Standard referral incentives" END,
    CASE WHEN centrality.network_value_score > 1.0
         THEN "Priority customer service"
         ELSE "Standard service" END,
    CASE WHEN centrality.viral_coefficient > 0.5
         THEN "Social media advocacy program"
         ELSE "Email marketing campaigns" END
  ],

  // Risk assessment
  network_risk_level:
    CASE WHEN centrality.risk_propagation_score > 0.6 THEN "High"
         WHEN centrality.risk_propagation_score > 0.3 THEN "Medium"
         ELSE "Low" END,

  // Opportunity score
  opportunity_score:
    (centrality.referral_influence_score * 0.4) +
    (centrality.network_value_score * 0.4) +
    (centrality.viral_coefficient * 0.2),

  priority_level:
    CASE WHEN centrality.network_value_score > 1.5 THEN "Critical"
         WHEN centrality.network_value_score > 1.0 THEN "High"
         WHEN centrality.network_value_score > 0.5 THEN "Medium"
         ELSE "Standard" END,

  created_at: datetime(),
  created_by: "network_insights_engine",
  version: 1
})

CREATE (customer)-[:HAS_NETWORK_INSIGHT {
  insight_date: date(),
  current_insight: true,
  created_at: datetime()
}]->(insight);

// ===================================
// STEP 9: VERIFICATION AND SUMMARY
// ===================================

// Verify Lab 7 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Network analysis summary
MATCH (c:Customer)-[:HAS_CENTRALITY_ANALYSIS]->(cent:CentralityAnalysis)
RETURN cent.influence_rank AS influence_level,
       count(c) AS customer_count,
       avg(c.lifetime_value) AS avg_lifetime_value,
       avg(cent.network_value_score) AS avg_network_value
ORDER BY avg_network_value DESC;

// Community analysis summary
MATCH (comm:CustomerCommunity)
RETURN comm.community_name AS community,
       comm.member_count AS members,
       comm.avg_lifetime_value AS avg_ltv,
       comm.churn_risk AS churn_risk,
       comm.cohesion_score AS cohesion
ORDER BY comm.avg_lifetime_value DESC;

// Algorithm execution summary
MATCH (alg:AlgorithmExecution)
RETURN alg.execution_date AS execution_time,
       alg.total_nodes_analyzed AS nodes,
       alg.total_relationships_analyzed AS relationships,
       alg.communities_detected AS communities,
       alg.graph_density AS density,
       alg.execution_time_seconds AS runtime_seconds;

// Expected result: 350 nodes, 450 relationships with graph algorithm analysis