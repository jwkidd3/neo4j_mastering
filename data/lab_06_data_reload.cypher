// Neo4j Lab 6 - Data Reload Script
// Complete data setup for Lab 6: Advanced Customer Intelligence & Segmentation
// Run this script if you need to reload the Lab 6 data state
// Includes Labs 1-5 data + Customer Profiles, Behavioral Analytics, Segmentation

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: ENSURE LAB 5 FOUNDATION EXISTS
// ===================================
// This script builds on Lab 5 - make sure you have the foundation data

// Create constraints if not exist
CREATE CONSTRAINT customer_number_unique IF NOT EXISTS FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;
CREATE CONSTRAINT policy_number_unique IF NOT EXISTS FOR (p:Policy) REQUIRE p.policy_number IS UNIQUE;
CREATE CONSTRAINT agent_id_unique IF NOT EXISTS FOR (a:Agent) REQUIRE a.agent_id IS UNIQUE;

// Ensure basic customer data exists (abbreviated)
MERGE (customer1:Customer:Individual {customer_number: "CUST-001234"})
ON CREATE SET customer1.id = randomUUID(), customer1.first_name = "Sarah", customer1.last_name = "Johnson", customer1.city = "Austin", customer1.state = "TX", customer1.credit_score = 720, customer1.risk_tier = "Standard", customer1.lifetime_value = 12500.00, customer1.created_at = datetime()

MERGE (customer2:Customer:Individual {customer_number: "CUST-001235"})
ON CREATE SET customer2.id = randomUUID(), customer2.first_name = "Michael", customer2.last_name = "Chen", customer2.city = "Austin", customer2.state = "TX", customer2.credit_score = 680, customer2.risk_tier = "Standard", customer2.lifetime_value = 18750.00, customer2.created_at = datetime()

MERGE (customer3:Customer:Individual {customer_number: "CUST-001236"})
ON CREATE SET customer3.id = randomUUID(), customer3.first_name = "Emma", customer3.last_name = "Rodriguez", customer3.city = "Dallas", customer3.state = "TX", customer3.credit_score = 750, customer3.risk_tier = "Preferred", customer3.lifetime_value = 8900.00, customer3.created_at = datetime();

// Create bulk customers
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

// ===================================
// STEP 3: CREATE CUSTOMER PROFILES
// ===================================

// Create detailed customer profiles for advanced analytics
MATCH (customer:Customer)
WITH customer,
  duration.between(customer.customer_since, date()).years AS tenure_years,
  CASE customer.risk_tier
    WHEN "Preferred" THEN 0.85 + (rand() * 0.10)
    WHEN "Standard" THEN 0.75 + (rand() * 0.15)
    WHEN "Substandard" THEN 0.60 + (rand() * 0.20)
    ELSE 0.70
  END AS profitability_score

CREATE (profile:CustomerProfile {
  id: randomUUID(),
  customer_id: customer.customer_number,
  profile_date: date(),

  // Demographic information
  age_range:
    CASE WHEN toInteger(rand() * 10) < 3 THEN "25-35"
         WHEN toInteger(rand() * 10) < 6 THEN "35-45"
         WHEN toInteger(rand() * 10) < 8 THEN "45-55"
         ELSE "55+" END,
  income_bracket:
    CASE customer.risk_tier
      WHEN "Preferred" THEN
        CASE WHEN toInteger(rand() * 3) = 0 THEN "$75K-$100K" ELSE "$100K+" END
      WHEN "Standard" THEN
        CASE WHEN toInteger(rand() * 3) = 0 THEN "$50K-$75K" ELSE "$75K-$100K" END
      ELSE "$25K-$50K"
    END,
  family_status:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Single"
      WHEN 1 THEN "Married"
      WHEN 2 THEN "Married with Children"
      ELSE "Divorced"
    END,
  education_level:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "High School"
      WHEN 1 THEN "Some College"
      WHEN 2 THEN "Bachelor's Degree"
      ELSE "Graduate Degree"
    END,

  // Behavioral metrics
  tenure_years: tenure_years,
  engagement_score: 60 + toInteger(rand() * 40), // 60-100
  digital_adoption:
    CASE toInteger(rand() * 3)
      WHEN 0 THEN "Low"
      WHEN 1 THEN "Medium"
      ELSE "High"
    END,
  communication_preference:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Email"
      WHEN 1 THEN "Phone"
      WHEN 2 THEN "Mobile App"
      ELSE "Mail"
    END,

  // Financial metrics
  total_annual_premium: 0.0,
  average_policy_value: 0.0,
  payment_consistency: 0.85 + (rand() * 0.15), // 0.85-1.0
  profitability_score: profitability_score,
  current_risk_score: 5.0 + (rand() * 5.0), // 5.0-10.0

  // Claims and service metrics
  total_claims: 0,
  claims_ratio: 0.0,
  service_calls_per_year: toInteger(rand() * 5),
  satisfaction_score: 3.0 + (rand() * 2.0), // 3.0-5.0

  // Segmentation
  primary_segment: "TBD",
  value_segment: "TBD",
  behavior_segment: "TBD",
  risk_segment: "TBD",

  created_at: datetime(),
  created_by: "analytics_system",
  version: 1
})

// Connect customer to profile
CREATE (customer)-[:HAS_PROFILE {
  created_date: date(),
  current_profile: true,
  created_at: datetime()
}]->(profile);

// ===================================
// STEP 4: CREATE PREDICTIVE MODELS
// ===================================

// Create predictive models for each customer
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
WITH customer, profile,
  // Calculate churn probability based on multiple factors
  CASE
    WHEN profile.tenure_years >= 5 AND profile.satisfaction_score >= 4.0 THEN 0.05 + (rand() * 0.10)
    WHEN profile.tenure_years >= 3 AND profile.satisfaction_score >= 3.5 THEN 0.15 + (rand() * 0.15)
    WHEN profile.tenure_years >= 1 AND profile.satisfaction_score >= 3.0 THEN 0.25 + (rand() * 0.20)
    ELSE 0.40 + (rand() * 0.30)
  END AS churn_prob,

  // Calculate cross-sell probability
  CASE customer.risk_tier
    WHEN "Preferred" THEN 0.60 + (rand() * 0.25)
    WHEN "Standard" THEN 0.40 + (rand() * 0.30)
    ELSE 0.20 + (rand() * 0.25)
  END AS cross_sell_prob

CREATE (prediction:PredictiveModel {
  id: randomUUID(),
  customer_id: customer.customer_number,
  model_date: date(),
  model_type: "Customer Behavior Prediction",
  model_version: "v3.0",

  // Churn prediction
  churn_probability: round(churn_prob * 1000) / 10, // Percentage to 1 decimal
  churn_risk_category:
    CASE WHEN churn_prob > 0.7 THEN "High Risk"
         WHEN churn_prob > 0.4 THEN "Medium Risk"
         WHEN churn_prob > 0.2 THEN "Low Risk"
         ELSE "Very Low Risk" END,
  churn_factors:
    CASE WHEN profile.satisfaction_score < 3.5 THEN ["Low Satisfaction"]
         WHEN profile.tenure_years < 2 THEN ["Short Tenure"]
         ELSE ["Standard Profile"] END +
    CASE WHEN profile.service_calls_per_year > 3 THEN ["High Service Usage"] ELSE [] END,

  // Cross-sell prediction
  cross_sell_probability: round(cross_sell_prob * 1000) / 10,
  cross_sell_opportunity:
    CASE WHEN cross_sell_prob > 0.7 THEN "High Opportunity"
         WHEN cross_sell_prob > 0.4 THEN "Medium Opportunity"
         ELSE "Low Opportunity" END,
  recommended_products:
    CASE WHEN toInteger(rand() * 3) = 0 THEN ["Property Insurance"]
         WHEN toInteger(rand() * 3) = 1 THEN ["Life Insurance"]
         ELSE ["Property Insurance", "Life Insurance"] END,

  // Lifetime value prediction
  predicted_ltv_change: -10.0 + (rand() * 30.0), // -10% to +20% change
  value_trend:
    CASE WHEN customer.risk_tier = "Preferred" THEN "Increasing"
         WHEN profile.tenure_years > 3 THEN "Stable"
         ELSE "Decreasing" END,

  // Next best action
  recommended_action:
    CASE WHEN churn_prob > 0.6 THEN "Retention Campaign"
         WHEN cross_sell_prob > 0.6 THEN "Cross-sell Outreach"
         WHEN profile.satisfaction_score >= 4.5 THEN "Loyalty Program"
         ELSE "Standard Service" END,

  model_confidence: 0.75 + (rand() * 0.20), // 75-95% confidence
  last_updated: datetime(),
  created_at: datetime(),
  created_by: "ml_engine",
  version: 1
})

// Connect customer to prediction
CREATE (customer)-[:HAS_PREDICTION {
  prediction_date: date(),
  current_prediction: true,
  created_at: datetime()
}]->(prediction);

// ===================================
// STEP 5: UPDATE CUSTOMER PROFILES WITH POLICY DATA
// ===================================

// Update profile financial metrics based on policies
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(claim:Claim)

WITH profile, customer,
     collect(policy) AS policies,
     collect(claim) AS claims,
     COALESCE(sum(policy.annual_premium), 0.0) AS total_premium,
     count(policy) AS policy_count,
     count(claim) AS claim_count,
     count(DISTINCT policy.product_type) AS distinct_product_count

SET profile.total_annual_premium = total_premium,
    profile.average_policy_value = CASE WHEN policy_count > 0 THEN total_premium / policy_count ELSE 0.0 END,
    profile.total_policies = policy_count,
    profile.total_claims = claim_count,
    profile.claims_ratio = CASE WHEN policy_count > 0 THEN (claim_count * 1.0) / policy_count ELSE 0.0 END,
    profile.product_mix = [p IN policies | p.product_type],
    profile.policy_diversity_score = distinct_product_count;

// ===================================
// STEP 6: CREATE CUSTOMER SEGMENTATION
// ===================================

// Apply sophisticated customer segmentation
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)

WITH customer, profile, prediction,
  // Value segmentation
  CASE WHEN customer.lifetime_value > 15000 AND profile.profitability_score > 0.8 THEN "High Value"
       WHEN customer.lifetime_value > 10000 AND profile.profitability_score > 0.7 THEN "Medium-High Value"
       WHEN customer.lifetime_value > 5000 THEN "Medium Value"
       ELSE "Standard Value" END AS value_seg,

  // Behavioral segmentation
  CASE WHEN profile.engagement_score > 80 AND profile.digital_adoption = "High" THEN "Digital Champion"
       WHEN profile.engagement_score > 60 AND profile.satisfaction_score > 4.0 THEN "Loyal Advocate"
       WHEN profile.engagement_score < 40 OR profile.satisfaction_score < 3.0 THEN "At Risk"
       WHEN prediction.cross_sell_probability > 60 THEN "Growth Opportunity"
       ELSE "Standard Engagement" END AS behavior_seg,

  // Risk segmentation
  CASE WHEN prediction.churn_probability > 60 THEN "High Churn Risk"
       WHEN prediction.churn_probability > 30 THEN "Medium Churn Risk"
       WHEN profile.claims_ratio > 0.5 THEN "High Claims Risk"
       ELSE "Low Risk" END AS risk_seg,

  // Primary segment (combination)
  CASE WHEN customer.lifetime_value > 15000 AND prediction.churn_probability < 20 THEN "VIP Loyal"
       WHEN customer.lifetime_value > 10000 AND prediction.cross_sell_probability > 60 THEN "High Potential"
       WHEN prediction.churn_probability > 60 THEN "Retention Focus"
       WHEN profile.tenure_years < 1 THEN "New Customer"
       WHEN customer.lifetime_value < 5000 AND profile.claims_ratio > 0.3 THEN "Cost Management"
       ELSE "Standard Customer" END AS primary_seg

SET profile.value_segment = value_seg,
    profile.behavior_segment = behavior_seg,
    profile.risk_segment = risk_seg,
    profile.primary_segment = primary_seg,
    profile.segmentation_date = date();

// ===================================
// STEP 7: CREATE GEOGRAPHIC ANALYTICS
// ===================================

// Create geographic customer clustering
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
WITH customer.city AS city,
     customer.state AS state,
     collect(customer) AS customers,
     collect(profile) AS profiles,
     count(customer) AS customer_count,
     avg(customer.lifetime_value) AS avg_ltv,
     avg(profile.total_annual_premium) AS avg_premium

CREATE (geo:GeographicCluster {
  id: randomUUID(),
  cluster_id: "GEO-" + replace(city, " ", "-") + "-" + state,
  city: city,
  state: state,
  region:
    CASE city
      WHEN "Austin" THEN "Central Texas"
      WHEN "Dallas" THEN "North Texas"
      WHEN "Houston" THEN "Southeast Texas"
      WHEN "San Antonio" THEN "South Texas"
      ELSE "Other Texas"
    END,

  // Cluster metrics
  customer_count: customer_count,
  average_lifetime_value: round(avg_ltv * 100) / 100,
  average_annual_premium: round(avg_premium * 100) / 100,
  market_penetration: customer_count * 0.1, // Simulated market share

  // Risk characteristics by city
  geographic_risk_factors:
    CASE city
      WHEN "Houston" THEN ["Hurricane", "Flooding"]
      WHEN "Dallas" THEN ["Tornado", "Hail"]
      WHEN "Austin" THEN ["Wildfire", "Flash Flood"]
      WHEN "San Antonio" THEN ["Flooding", "Drought"]
      ELSE ["Standard Weather"]
    END,

  risk_multiplier:
    CASE city
      WHEN "Houston" THEN 1.3  // Higher hurricane risk
      WHEN "Dallas" THEN 1.2   // Tornado alley
      WHEN "Austin" THEN 1.1   // Moderate risk
      WHEN "San Antonio" THEN 1.15  // Flood risk
      ELSE 1.0
    END,

  growth_potential:
    CASE city
      WHEN "Austin" THEN "High"      // Growing tech hub
      WHEN "Dallas" THEN "Medium"    // Steady growth
      WHEN "Houston" THEN "Medium"   // Energy sector
      WHEN "San Antonio" THEN "Low"  // Slower growth
      ELSE "Low"
    END,

  created_at: datetime(),
  created_by: "geo_analytics_system",
  version: 1
})

// Connect customers to geographic clusters
WITH geo, customers
UNWIND customers AS customer
CREATE (customer)-[:BELONGS_TO_CLUSTER {
  cluster_assignment_date: date(),
  distance_from_center: rand() * 25.0, // Miles from city center
  created_at: datetime()
}]->(geo);

// ===================================
// STEP 8: CREATE LIFETIME VALUE MODELS
// ===================================

// Create sophisticated LTV models
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)

WITH customer, profile, prediction,
  // Calculate retention probability (inverse of churn)
  (100.0 - prediction.churn_probability) / 100.0 AS retention_probability,

  // Calculate tenure bonus
  CASE WHEN profile.tenure_years >= 5 THEN 1.3
       WHEN profile.tenure_years >= 3 THEN 1.1
       WHEN profile.tenure_years >= 1 THEN 1.0
       ELSE 0.8 END AS tenure_bonus,

  // Calculate claims adjustment
  CASE WHEN profile.total_claims = 0 THEN 1.2
       WHEN profile.total_claims = 1 THEN 1.0
       WHEN profile.total_claims = 2 THEN 0.8
       ELSE 0.6 END AS claims_adjustment

CREATE (ltv:LifetimeValueModel {
  id: randomUUID(),
  customer_id: customer.customer_number,
  calculation_date: date(),
  model_version: "v2.0",

  // Base metrics
  current_annual_premium: profile.total_annual_premium,
  historical_ltv: customer.lifetime_value,
  tenure_years: profile.tenure_years,

  // Behavioral factors
  retention_probability: round(retention_probability * 1000) / 10,
  product_diversity: profile.policy_diversity_score,
  product_diversity_score: profile.policy_diversity_score * 0.15,
  claims_frequency: profile.total_claims,
  claims_adjustment_factor: claims_adjustment,
  tenure_bonus_factor: tenure_bonus,

  // Risk and profitability factors
  risk_score: profile.current_risk_score,
  profitability_score: profile.profitability_score,
  payment_consistency: profile.payment_consistency,

  // Calculated LTV components
  base_annual_value: profile.total_annual_premium * profile.profitability_score,
  risk_adjusted_value: profile.total_annual_premium * (profile.current_risk_score / 10.0),
  behavioral_adjusted_value: profile.total_annual_premium * claims_adjustment * tenure_bonus,

  // Final LTV calculation
  predicted_annual_retention: round(retention_probability * 100) / 100,
  predicted_lifetime_years:
    CASE WHEN retention_probability > 0.8 THEN 8.0
         WHEN retention_probability > 0.6 THEN 6.0
         WHEN retention_probability > 0.4 THEN 4.0
         ELSE 2.0 END,

  calculated_ltv: round(
    (profile.total_annual_premium * profile.profitability_score * claims_adjustment * tenure_bonus *
     CASE WHEN retention_probability > 0.8 THEN 8.0
          WHEN retention_probability > 0.6 THEN 6.0
          WHEN retention_probability > 0.4 THEN 4.0
          ELSE 2.0 END) * 100) / 100,

  // Growth potential
  cross_sell_potential: prediction.cross_sell_probability,
  estimated_growth_value:
    prediction.cross_sell_probability *
    CASE WHEN NOT "Property" IN profile.product_mix THEN 800.0
         WHEN NOT "Life" IN profile.product_mix THEN 1200.0
         ELSE 300.0 END,

  // LTV confidence score
  model_confidence: 0.80 + (profile.policy_diversity_score * 0.05) + (tenure_bonus - 1.0),

  created_at: datetime(),
  created_by: "ltv_model_engine",
  version: 1
})

// Connect customer to LTV model
CREATE (customer)-[:HAS_LTV_MODEL {
  model_date: date(),
  current_model: true,
  created_at: datetime()
}]->(ltv);

// ===================================
// STEP 9: CREATE BEHAVIORAL ANALYTICS
// ===================================

// Create detailed behavioral analytics
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)

CREATE (behavior:BehaviorAnalytics {
  id: randomUUID(),
  customer_id: customer.customer_number,
  analysis_date: date(),

  // Communication patterns
  preferred_channel: profile.communication_preference,
  digital_engagement_level: profile.digital_adoption,
  response_rate_email: 0.15 + (rand() * 0.30), // 15-45%
  response_rate_phone: 0.25 + (rand() * 0.40), // 25-65%
  response_rate_mobile: 0.35 + (rand() * 0.35), // 35-70%

  // Service patterns
  contact_frequency: profile.service_calls_per_year,
  issue_resolution_rating: profile.satisfaction_score,
  self_service_usage:
    CASE profile.digital_adoption
      WHEN "High" THEN 0.70 + (rand() * 0.25)
      WHEN "Medium" THEN 0.40 + (rand() * 0.30)
      ELSE 0.10 + (rand() * 0.25)
    END,

  // Payment behaviors
  payment_method_preference:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Auto Pay"
      WHEN 1 THEN "Online"
      WHEN 2 THEN "Mobile App"
      ELSE "Mail"
    END,
  early_payment_tendency: profile.payment_consistency > 0.90,
  late_payment_risk: profile.payment_consistency < 0.80,

  // Engagement metrics
  policy_review_frequency:
    CASE WHEN profile.engagement_score > 80 THEN "Quarterly"
         WHEN profile.engagement_score > 60 THEN "Semi-Annual"
         ELSE "Annual" END,
  referral_likelihood: prediction.cross_sell_probability * 0.7, // Correlated with cross-sell
  loyalty_score: (profile.satisfaction_score * 20) + (profile.tenure_years * 5),

  // Risk behaviors
  claims_pattern:
    CASE WHEN profile.total_claims = 0 THEN "No Claims"
         WHEN profile.total_claims = 1 THEN "Single Claim"
         WHEN profile.total_claims <= 3 THEN "Multiple Claims"
         ELSE "High Claims Activity" END,
  risk_averse_behavior: customer.risk_tier = "Preferred",

  created_at: datetime(),
  created_by: "behavior_analytics_engine",
  version: 1
})

// Connect customer to behavior analytics
CREATE (customer)-[:HAS_BEHAVIOR_ANALYSIS {
  analysis_date: date(),
  current_analysis: true,
  created_at: datetime()
}]->(behavior);

// ===================================
// STEP 10: VERIFICATION AND ANALYTICS SUMMARY
// ===================================

// Verify Lab 6 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Customer segmentation summary
MATCH (c:Customer)-[:HAS_PROFILE]->(p:CustomerProfile)
RETURN p.primary_segment AS segment,
       p.value_segment AS value_tier,
       count(c) AS customer_count,
       avg(c.lifetime_value) AS avg_lifetime_value,
       avg(p.total_annual_premium) AS avg_annual_premium
ORDER BY avg_lifetime_value DESC;

// Geographic distribution summary
MATCH (geo:GeographicCluster)
RETURN geo.city AS city,
       geo.customer_count AS customers,
       geo.average_lifetime_value AS avg_ltv,
       geo.growth_potential AS growth_potential,
       geo.geographic_risk_factors AS risk_factors
ORDER BY geo.customer_count DESC;

// Expected result: 280 nodes, 380 relationships with advanced customer intelligence