// Neo4j Lab 5 - Data Reload Script
// Complete data setup for Lab 5: Advanced Analytics Foundation
// Run this script if you need to reload the Lab 5 data state
// Includes Labs 1-4 data + Analytics Foundation, Risk Assessments, KPIs

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: EXECUTE LAB 4 RELOAD FIRST
// ===================================
// This script builds on Lab 4 - run lab_04_data_reload.cypher first
// Then continue with Lab 5 additions below

// Create constraints if not exist
CREATE CONSTRAINT customer_number_unique IF NOT EXISTS FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;
CREATE CONSTRAINT policy_number_unique IF NOT EXISTS FOR (p:Policy) REQUIRE p.policy_number IS UNIQUE;
CREATE CONSTRAINT agent_id_unique IF NOT EXISTS FOR (a:Agent) REQUIRE a.agent_id IS UNIQUE;

// Ensure we have the basic foundation (summarized for performance)
MERGE (customer1:Customer:Individual {customer_number: "CUST-001234"})
ON CREATE SET customer1.id = randomUUID(), customer1.first_name = "Sarah", customer1.last_name = "Johnson", customer1.city = "Austin", customer1.state = "TX", customer1.credit_score = 720, customer1.risk_tier = "Standard", customer1.lifetime_value = 12500.00, customer1.created_at = datetime(), customer1.created_by = "underwriting_system", customer1.version = 1;

MERGE (customer2:Customer:Individual {customer_number: "CUST-001235"})
ON CREATE SET customer2.id = randomUUID(), customer2.first_name = "Michael", customer2.last_name = "Chen", customer2.city = "Austin", customer2.state = "TX", customer2.credit_score = 680, customer2.risk_tier = "Standard", customer2.lifetime_value = 18750.00, customer2.created_at = datetime(), customer2.created_by = "underwriting_system", customer2.version = 1;

MERGE (customer3:Customer:Individual {customer_number: "CUST-001236"})
ON CREATE SET customer3.id = randomUUID(), customer3.first_name = "Emma", customer3.last_name = "Rodriguez", customer3.city = "Dallas", customer3.state = "TX", customer3.credit_score = 750, customer3.risk_tier = "Preferred", customer3.lifetime_value = 8900.00, customer3.created_at = datetime(), customer3.created_by = "underwriting_system", customer3.version = 1;

// Create bulk customers from Lab 4
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
  c.email = toLower(row.first_name) + "." + toLower(row.last_name) + "@email.com",
  c.city = row.city, c.state = row.state, c.credit_score = row.credit_score,
  c.risk_tier = row.risk_tier, c.lifetime_value = row.lifetime_value,
  c.customer_since = date("2020-01-01") + duration({days: toInteger(rand() * 1000)}),
  c.created_at = datetime(), c.created_by = "bulk_import_system", c.version = 1;

// Create essential agents
MERGE (agent1:Agent:Employee {agent_id: "AGT-001"})
ON CREATE SET agent1.id = randomUUID(), agent1.first_name = "David", agent1.last_name = "Wilson", agent1.territory = "Central Texas", agent1.performance_rating = "Excellent", agent1.ytd_sales = 85000, agent1.customer_count = 3, agent1.created_at = datetime(), agent1.created_by = "hr_system";

MERGE (agent2:Agent:Employee {agent_id: "AGT-002"})
ON CREATE SET agent2.id = randomUUID(), agent2.first_name = "Lisa", agent2.last_name = "Thompson", agent2.territory = "North Texas", agent2.performance_rating = "Very Good", agent2.ytd_sales = 72000, agent2.customer_count = 2, agent2.created_at = datetime(), agent2.created_by = "hr_system";

// Create additional agents
WITH [
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
  agent.ytd_sales = 50000 + toInteger(rand() * 100000), agent.customer_count = 2 + toInteger(rand() * 4),
  agent.sales_quota = 120000 + toInteger(rand() * 80000),
  agent.created_at = datetime(), agent.created_by = "hr_system", agent.version = 1;

// ===================================
// STEP 3: LAB 5 ADDITIONS - RISK ASSESSMENTS
// ===================================

// Create Risk Assessment entities for customers
MATCH (c:Customer)
WITH c,
  CASE c.risk_tier
    WHEN "Preferred" THEN 8.5 + (rand() * 1.5)
    WHEN "Standard" THEN 6.0 + (rand() * 2.0)
    WHEN "Substandard" THEN 3.0 + (rand() * 2.0)
    ELSE 5.0
  END AS calculated_risk_score

CREATE (ra:RiskAssessment {
  id: randomUUID(),
  assessment_id: "RISK-" + c.customer_number,
  customer_id: c.customer_number,
  assessment_type: "Customer Underwriting",
  risk_score: calculated_risk_score,
  risk_factors:
    CASE c.risk_tier
      WHEN "Preferred" THEN ["High Credit Score", "Long Tenure", "Low Claims History"]
      WHEN "Standard" THEN ["Average Credit Score", "Standard Profile"]
      WHEN "Substandard" THEN ["Low Credit Score", "High Risk Profile"]
      ELSE ["Standard Assessment"]
    END,
  assessment_date: date() - duration({days: toInteger(rand() * 90)}),
  valid_until: date() + duration({months: 6}),
  assessor_id: "SYSTEM-AUTO",
  model_version: "v2.1",
  created_at: datetime(),
  created_by: "risk_engine",
  version: 1
})

// Connect risk assessments to customers
CREATE (c)-[:HAS_RISK_ASSESSMENT {
  assessment_date: ra.assessment_date,
  current_assessment: true,
  created_at: datetime()
}]->(ra);

// ===================================
// STEP 4: CREATE CUSTOMER 360 DEGREE VIEWS
// ===================================

// Create comprehensive customer profiles with analytics
MATCH (c:Customer)
SET c.total_policies = 0,
    c.total_premium = 0.0,
    c.avg_premium = 0.0,
    c.policy_tenure_months = 0,
    c.last_policy_date = date("2020-01-01"),
    c.customer_segment =
      CASE
        WHEN c.lifetime_value > 15000 THEN "High Value"
        WHEN c.lifetime_value > 10000 THEN "Medium Value"
        ELSE "Standard Value"
      END,
    c.geographic_risk =
      CASE c.city
        WHEN "Houston" THEN "High" // Hurricane risk
        WHEN "Dallas" THEN "Medium" // Tornado risk
        WHEN "Austin" THEN "Low" // Moderate risk
        WHEN "San Antonio" THEN "Medium" // Flood risk
        ELSE "Medium"
      END;

// Update customer analytics with policy data
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
WITH c,
     count(p) AS policy_count,
     sum(p.annual_premium) AS total_premium_sum,
     avg(p.annual_premium) AS avg_premium_calc,
     max(p.effective_date) AS latest_policy_date
SET c.total_policies = policy_count,
    c.total_premium = total_premium_sum,
    c.avg_premium = avg_premium_calc,
    c.last_policy_date = latest_policy_date,
    c.policy_tenure_months = duration.between(c.customer_since, date()).months;

// ===================================
// STEP 5: CREATE BUSINESS INTELLIGENCE METRICS
// ===================================

// Create KPI tracking entities
CREATE (kpi_portfolio:KPI {
  id: randomUUID(),
  kpi_id: "KPI-PORTFOLIO-001",
  kpi_name: "Portfolio Premium Volume",
  kpi_category: "Financial",
  measurement_period: "Monthly",
  target_value: 2500000.00,
  current_value: 0.0,
  last_calculated: datetime(),
  calculation_method: "Sum of all active policy premiums",
  business_unit: "Personal Lines",
  owner: "Portfolio Manager",
  created_at: datetime(),
  created_by: "analytics_system",
  version: 1
})

CREATE (kpi_retention:KPI {
  id: randomUUID(),
  kpi_id: "KPI-RETENTION-001",
  kpi_name: "Customer Retention Rate",
  kpi_category: "Customer",
  measurement_period: "Quarterly",
  target_value: 92.0,
  current_value: 0.0,
  last_calculated: datetime(),
  calculation_method: "Percentage of customers retained year-over-year",
  business_unit: "Customer Experience",
  owner: "Customer Success Manager",
  created_at: datetime(),
  created_by: "analytics_system",
  version: 1
})

CREATE (kpi_acquisition:KPI {
  id: randomUUID(),
  kpi_id: "KPI-ACQUISITION-001",
  kpi_name: "New Customer Acquisition Cost",
  kpi_category: "Marketing",
  measurement_period: "Monthly",
  target_value: 150.00,
  current_value: 0.0,
  last_calculated: datetime(),
  calculation_method: "Marketing spend divided by new customers acquired",
  business_unit: "Marketing",
  owner: "Marketing Director",
  created_at: datetime(),
  created_by: "analytics_system",
  version: 1
});

// ===================================
// STEP 6: CALCULATE AND UPDATE KPI VALUES
// ===================================

// Calculate portfolio premium volume
MATCH (p:Policy {policy_status: "Active"})
WITH sum(p.annual_premium) AS total_portfolio_premium
MATCH (kpi:KPI {kpi_id: "KPI-PORTFOLIO-001"})
SET kpi.current_value = total_portfolio_premium,
    kpi.last_calculated = datetime(),
    kpi.variance_from_target = ((total_portfolio_premium - kpi.target_value) / kpi.target_value) * 100,
    kpi.status = CASE
      WHEN total_portfolio_premium >= kpi.target_value THEN "On Target"
      WHEN total_portfolio_premium >= (kpi.target_value * 0.9) THEN "Close to Target"
      ELSE "Below Target"
    END;

// Calculate customer retention metrics
MATCH (c:Customer)
WHERE c.customer_since < date() - duration({years: 1})
WITH count(c) AS retained_customers
MATCH (c2:Customer)
WITH retained_customers, count(c2) AS total_customers
WITH (retained_customers * 100.0 / total_customers) AS retention_rate
MATCH (kpi:KPI {kpi_id: "KPI-RETENTION-001"})
SET kpi.current_value = retention_rate,
    kpi.last_calculated = datetime(),
    kpi.variance_from_target = retention_rate - kpi.target_value,
    kpi.status = CASE
      WHEN retention_rate >= kpi.target_value THEN "On Target"
      WHEN retention_rate >= (kpi.target_value - 3.0) THEN "Close to Target"
      ELSE "Below Target"
    END;

// ===================================
// STEP 7: CREATE ADVANCED ANALYTICS VIEWS
// ===================================

// Create customer analytics view with geographic and risk segmentation
MATCH (c:Customer)
OPTIONAL MATCH (c)-[:HAS_RISK_ASSESSMENT]->(ra:RiskAssessment)
OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
WITH c, ra, collect(p) AS policies,
     CASE c.city
       WHEN "Austin" THEN "Central Texas"
       WHEN "Dallas" THEN "North Texas"
       WHEN "Houston" THEN "Southeast Texas"
       WHEN "San Antonio" THEN "South Texas"
       ELSE "Other Texas"
     END AS region

SET c.analytics_region = region,
    c.risk_score = COALESCE(ra.risk_score, 5.0),
    c.policy_diversity = size([p IN policies WHERE p.product_type = "Auto"]) + size([p IN policies WHERE p.product_type = "Property"]),
    c.premium_per_policy = CASE WHEN c.total_policies > 0 THEN c.total_premium / c.total_policies ELSE 0.0 END,
    c.customer_value_tier =
      CASE
        WHEN c.lifetime_value > 15000 AND c.risk_score > 7.0 THEN "Premium"
        WHEN c.lifetime_value > 10000 AND c.risk_score > 6.0 THEN "Preferred"
        WHEN c.lifetime_value > 5000 THEN "Standard"
        ELSE "Basic"
      END;

// ===================================
// STEP 8: CREATE AGENT PERFORMANCE ANALYTICS
// ===================================

// Update agent performance with detailed analytics
MATCH (a:Agent)
OPTIONAL MATCH (a)-[:SERVICES]->(c:Customer)-[:HOLDS_POLICY]->(p:Policy)
WITH a, collect(DISTINCT c) AS customers, collect(p) AS policies
SET a.active_customers = size(customers),
    a.total_portfolio_premium = COALESCE(reduce(total = 0.0, p IN policies | total + p.annual_premium), 0.0),
    a.avg_customer_value = CASE WHEN size(customers) > 0 THEN reduce(total = 0.0, c IN customers | total + c.lifetime_value) / size(customers) ELSE 0.0 END,
    a.performance_score =
      CASE a.performance_rating
        WHEN "Excellent" THEN 9.0 + (rand() * 1.0)
        WHEN "Very Good" THEN 7.5 + (rand() * 1.5)
        WHEN "Good" THEN 6.0 + (rand() * 1.5)
        ELSE 5.0 + (rand() * 1.0)
      END,
    a.quota_achievement = CASE WHEN a.sales_quota > 0 THEN (a.ytd_sales * 100.0 / a.sales_quota) ELSE 0.0 END;

// ===================================
// STEP 9: CREATE PREDICTIVE ANALYTICS FOUNDATION
// ===================================

// Create churn risk scores for customers
MATCH (c:Customer)
WITH c,
  CASE
    WHEN c.risk_score < 4.0 THEN 0.8 + (rand() * 0.15)  // High churn risk
    WHEN c.risk_score < 6.0 THEN 0.4 + (rand() * 0.3)   // Medium churn risk
    WHEN c.risk_score < 8.0 THEN 0.1 + (rand() * 0.25)  // Low churn risk
    ELSE 0.05 + (rand() * 0.1)                          // Very low churn risk
  END AS churn_probability

SET c.churn_risk_score = churn_probability,
    c.churn_risk_category =
      CASE
        WHEN churn_probability > 0.7 THEN "High Risk"
        WHEN churn_probability > 0.4 THEN "Medium Risk"
        WHEN churn_probability > 0.2 THEN "Low Risk"
        ELSE "Very Low Risk"
      END,
    c.retention_priority =
      CASE
        WHEN churn_probability > 0.7 AND c.lifetime_value > 15000 THEN "Critical"
        WHEN churn_probability > 0.4 AND c.lifetime_value > 10000 THEN "High"
        WHEN churn_probability > 0.2 THEN "Medium"
        ELSE "Low"
      END;

// ===================================
// STEP 10: CREATE REGULATORY COMPLIANCE FOUNDATION
// ===================================

// Create compliance tracking for high-value customers
MATCH (c:Customer)
WHERE c.lifetime_value > 10000 OR c.customer_value_tier IN ["Premium", "Preferred"]

CREATE (comp:ComplianceRecord {
  id: randomUUID(),
  compliance_id: "COMP-" + c.customer_number,
  customer_id: c.customer_number,
  regulatory_requirements: ["Customer Data Protection", "Financial Privacy", "Insurance Regulations"],
  compliance_status: "Compliant",
  last_review_date: date() - duration({days: toInteger(rand() * 90)}),
  next_review_date: date() + duration({months: 6}),
  compliance_officer: "OFFICER-001",
  findings: ["No issues identified"],
  corrective_actions: [],
  risk_level:
    CASE c.customer_value_tier
      WHEN "Premium" THEN "High"
      WHEN "Preferred" THEN "Medium"
      ELSE "Standard"
    END,
  created_at: datetime(),
  created_by: "compliance_system",
  version: 1
})

CREATE (c)-[:SUBJECT_TO_COMPLIANCE {
  compliance_start: comp.last_review_date,
  compliance_level: comp.risk_level,
  review_frequency: "Semi-Annual",
  created_at: datetime()
}]->(comp);

// ===================================
// STEP 11: VERIFICATION AND ANALYTICS SUMMARY
// ===================================

// Verify Lab 5 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Analytics summary
MATCH (c:Customer)
RETURN c.customer_value_tier AS value_tier,
       c.churn_risk_category AS churn_risk,
       count(c) AS customer_count,
       avg(c.lifetime_value) AS avg_lifetime_value,
       avg(c.total_premium) AS avg_total_premium
ORDER BY avg_lifetime_value DESC;

// Expected result: 200 nodes, 300 relationships with advanced analytics