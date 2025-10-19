# Neo4j Lab 5: Advanced Analytics Foundation

## Overview
**Duration:** 45 minutes  
**Objective:** Implement sophisticated business intelligence systems, customer 360-degree views, and risk assessment analytics for comprehensive insurance operations

Building on Lab 4's production-scale database, you'll now create advanced analytics capabilities that provide deep business insights, comprehensive customer views, and sophisticated risk assessment systems that drive strategic decision-making.

---

## Part 1: Risk Assessment and Underwriting Analytics (12 minutes)

### Step 1: Create Risk Assessment Entities
Let's implement sophisticated risk assessment capabilities:

```cypher
// Create risk assessments for existing customers
MATCH (customer:Customer)
WITH customer, 
  // Calculate base risk score from multiple factors
  CASE customer.risk_tier
    WHEN "Preferred" THEN 8.5
    WHEN "Standard" THEN 6.5
    WHEN "Substandard" THEN 4.0
    ELSE 5.0
  END + 
  (customer.credit_score - 650) / 50.0 +
  CASE customer.city
    WHEN "Austin" THEN 0.5
    WHEN "Dallas" THEN 0.0
    WHEN "Houston" THEN -0.3
    WHEN "San Antonio" THEN 0.2
    ELSE 0.0
  END AS calculated_risk_score

CREATE (risk:RiskAssessment {
  id: randomUUID(),
  assessment_id: "RISK-" + customer.customer_number,
  customer_id: customer.customer_number,
  assessment_type: "Comprehensive Underwriting",
  risk_score: calculated_risk_score,
  risk_factors: [
    "Credit Score: " + toString(customer.credit_score),
    "Geographic Location: " + customer.city,
    "Customer Tenure: " + toString(duration.between(customer.customer_since, date()).years) + " years",
    "Risk Tier: " + customer.risk_tier
  ],
  assessment_date: date(),
  valid_until: date() + duration({years: 1}),
  assessor_id: "UND-SYSTEM",
  model_version: "v2.1",
  confidence_level: 0.85 + (rand() * 0.10),
  recommendations: 
    CASE 
      WHEN calculated_risk_score >= 8.0 THEN ["Approve standard terms", "Consider premium discount"]
      WHEN calculated_risk_score >= 6.0 THEN ["Approve standard terms", "Monitor claims frequency"]
      WHEN calculated_risk_score >= 4.0 THEN ["Approve with higher deductible", "Require additional documentation"]
      ELSE ["Decline coverage", "Refer to specialist underwriter"]
    END,
  created_at: datetime(),
  created_by: "risk_assessment_system",
  version: 1
})

// Connect risk assessments to customers
CREATE (customer)-[:HAS_RISK_ASSESSMENT {
  assessment_date: date(),
  assessment_type: "Annual Review",
  created_at: datetime()
}]->(risk)

RETURN count(risk) AS risk_assessments_created
```

### Step 2: Territory Risk Analysis
```cypher
// Create territory-based risk profiles
MATCH (customer:Customer)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)
WITH customer.city AS territory,
     customer.state AS state,
     count(customer) AS customer_count,
     avg(risk.risk_score) AS avg_risk_score,
     avg(customer.credit_score) AS avg_credit_score,
     collect(DISTINCT customer.risk_tier) AS risk_tiers

CREATE (territory_risk:TerritoryRisk {
  id: randomUUID(),
  territory_id: "TERR-" + territory + "-" + state,
  territory_name: territory,
  state: state,
  customer_population: customer_count,
  average_risk_score: avg_risk_score,
  average_credit_score: avg_credit_score,
  risk_tiers_present: risk_tiers,
  risk_concentration: 
    CASE 
      WHEN avg_risk_score >= 7.5 THEN "Low Risk"
      WHEN avg_risk_score >= 6.0 THEN "Moderate Risk"
      WHEN avg_risk_score >= 4.5 THEN "High Risk"
      ELSE "Very High Risk"
    END,
  market_penetration: customer_count / 10000.0,
  growth_potential: 
    CASE 
      WHEN customer_count < 3 THEN "High"
      WHEN customer_count < 6 THEN "Moderate"
      ELSE "Saturated"
    END,
  created_at: datetime(),
  created_by: "territory_analysis_system",
  version: 1
})

RETURN territory_risk.territory_name AS territory,
       territory_risk.customer_population AS customers,
       territory_risk.risk_concentration AS risk_level,
       territory_risk.growth_potential AS growth_potential
ORDER BY territory_risk.average_risk_score DESC
```

### Step 3: Policy Risk Correlations
```cypher
// Analyze risk patterns across policy types and customer segments
MATCH (customer:Customer)-[:HOLDS_POLICY]->(policy:Policy)
MATCH (customer)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)
WITH policy.product_type AS product_type,
     customer.risk_tier AS risk_tier,
     avg(risk.risk_score) AS avg_risk_score,
     avg(policy.annual_premium) AS avg_premium,
     count(policy) AS policy_count,
     sum(policy.annual_premium) AS total_premium

RETURN product_type,
       risk_tier,
       policy_count,
       round(avg_risk_score * 100) / 100 AS avg_risk_score,
       round(avg_premium * 100) / 100 AS avg_premium,
       round(total_premium * 100) / 100 AS total_premium,
       round((total_premium / policy_count) * 100) / 100 AS premium_per_policy
ORDER BY product_type, avg_risk_score DESC
```

---

## Part 2: Customer 360-Degree Views and Segmentation (15 minutes)

### Step 4: Comprehensive Customer Analytics
```cypher
// Create detailed customer profiles with 360-degree view
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(claim:Claim)
OPTIONAL MATCH (customer)-[:MADE_PAYMENT]->(payment:Payment)
OPTIONAL MATCH (agent:Agent)-[:SERVICES]->(customer)
OPTIONAL MATCH (customer)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)

WITH customer,
     count(DISTINCT policy) AS policy_count,
     sum(policy.annual_premium) AS total_annual_premium,
     count(DISTINCT claim) AS total_claims,
     sum(claim.claim_amount) AS total_claim_amount,
     count(DISTINCT payment) AS total_payments,
     sum(payment.amount) AS total_payments_amount,
     agent.first_name + " " + agent.last_name AS assigned_agent,
     avg(risk.risk_score) AS avg_risk_score

CREATE (profile:CustomerProfile {
  id: randomUUID(),
  customer_id: customer.customer_number,
  profile_date: date(),
  
  // Basic demographics
  customer_name: customer.first_name + " " + customer.last_name,
  age: duration.between(customer.date_of_birth, date()).years,
  customer_since: customer.customer_since,
  tenure_years: duration.between(customer.customer_since, date()).years,
  
  // Financial profile
  credit_score: customer.credit_score,
  risk_tier: customer.risk_tier,
  lifetime_value: customer.lifetime_value,
  
  // Policy portfolio
  policy_count: policy_count,
  total_annual_premium: COALESCE(total_annual_premium, 0.0),
  avg_policy_premium: CASE WHEN policy_count > 0 THEN total_annual_premium / policy_count ELSE 0.0 END,
  
  // Claims history
  total_claims: total_claims,
  total_claim_amount: COALESCE(total_claim_amount, 0.0),
  claims_ratio: CASE WHEN total_annual_premium > 0 THEN total_claim_amount / total_annual_premium ELSE 0.0 END,
  
  // Payment behavior
  total_payments: total_payments,
  total_paid: COALESCE(total_payments_amount, 0.0),
  payment_consistency: CASE WHEN total_payments >= policy_count THEN "Consistent" ELSE "Irregular" END,
  
  // Risk assessment
  current_risk_score: COALESCE(avg_risk_score, 5.0),
  
  // Relationship management
  assigned_agent: COALESCE(assigned_agent, "Unassigned"),
  
  // Segmentation
  customer_segment: 
    CASE 
      WHEN customer.lifetime_value > 15000 AND total_claims = 0 THEN "Premium Low-Risk"
      WHEN customer.lifetime_value > 10000 AND total_claims <= 1 THEN "High-Value Standard"
      WHEN customer.lifetime_value > 5000 THEN "Standard Value"
      WHEN total_claims > 2 THEN "High-Risk"
      ELSE "Basic Coverage"
    END,
    
  profitability_score: 
    CASE 
      WHEN total_annual_premium > 0 THEN 
        (total_annual_premium - COALESCE(total_claim_amount, 0.0)) / total_annual_premium
      ELSE 0.0
    END,
    
  retention_risk: 
    CASE 
      WHEN duration.between(customer.customer_since, date()).years < 1 THEN "New Customer"
      WHEN total_claims > policy_count THEN "High Risk"
      WHEN avg_risk_score < 5.0 THEN "Moderate Risk"
      ELSE "Low Risk"
    END,
    
  created_at: datetime(),
  created_by: "customer_analytics_system",
  version: 1
})

// Connect profiles to customers
CREATE (customer)-[:HAS_PROFILE {
  profile_date: date(),
  profile_type: "360-Degree Analysis",
  created_at: datetime()
}]->(profile)

RETURN count(profile) AS customer_profiles_created
```

### Step 5: Advanced Customer Segmentation Analysis
```cypher
// Customer segmentation distribution and characteristics
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
RETURN profile.customer_segment AS segment,
       count(customer) AS customer_count,
       avg(profile.total_annual_premium) AS avg_annual_premium,
       avg(profile.lifetime_value) AS avg_lifetime_value,
       avg(profile.current_risk_score) AS avg_risk_score,
       avg(profile.tenure_years) AS avg_tenure_years,
       avg(profile.claims_ratio) AS avg_claims_ratio,
       collect(DISTINCT customer.risk_tier) AS risk_tiers
ORDER BY avg_lifetime_value DESC
```

### Step 6: Cross-Sell and Retention Analytics
```cypher
// Identify cross-sell opportunities and retention strategies
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)

WITH customer, profile,
     collect(DISTINCT policy.product_type) AS current_products,
     size(collect(DISTINCT policy.product_type)) AS product_diversity

// Create cross-sell recommendations
CREATE (opportunity:CrossSellOpportunity {
  id: randomUUID(),
  customer_id: customer.customer_number,
  opportunity_date: date(),
  current_products: current_products,
  product_diversity: product_diversity,
  
  recommended_products: 
    CASE 
      WHEN NOT "Property" IN current_products AND customer.city IN ["Austin", "Dallas"] THEN ["Property Insurance"]
      WHEN NOT "Life" IN current_products AND profile.age > 30 THEN ["Life Insurance"]
      WHEN size(current_products) = 1 AND profile.total_annual_premium > 1500 THEN ["Umbrella Policy"]
      ELSE ["Enhanced Coverage"]
    END,
    
  opportunity_score: 
    profile.lifetime_value / 1000 + 
    profile.current_risk_score + 
    (10 - product_diversity),
    
  priority: 
    CASE 
      WHEN profile.customer_segment = "Premium Low-Risk" THEN "High"
      WHEN profile.customer_segment = "High-Value Standard" THEN "Medium"
      ELSE "Low"
    END,
    
  estimated_revenue: 
    CASE 
      WHEN NOT "Property" IN current_products THEN 800.0
      WHEN NOT "Life" IN current_products THEN 1200.0
      ELSE 300.0
    END,
    
  contact_method: 
    CASE 
      WHEN profile.customer_segment CONTAINS "Premium" THEN "Personal Agent Call"
      WHEN profile.total_annual_premium > 1000 THEN "Agent Outreach"
      ELSE "Digital Marketing"
    END,
    
  created_at: datetime(),
  created_by: "cross_sell_system",
  version: 1
})

// Connect opportunities to customers
CREATE (customer)-[:HAS_OPPORTUNITY {
  opportunity_date: date(),
  opportunity_type: "Cross-Sell",
  created_at: datetime()
}]->(opportunity)

RETURN count(opportunity) AS opportunities_created
```

---

## Part 3: Business Intelligence and KPI Development (15 minutes)

### Step 7: Executive Dashboard KPIs
```cypher
// Create comprehensive business intelligence metrics
WITH date() AS report_date

// Customer metrics
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
WITH report_date, 
     count(customer) AS total_customers,
     avg(customer.lifetime_value) AS avg_customer_value,
     collect(DISTINCT customer.risk_tier) AS risk_tiers,
     avg(profile.total_annual_premium) AS avg_annual_premium

// Policy metrics  
MATCH (policy:Policy)
WITH report_date, total_customers, avg_customer_value, avg_annual_premium,
     count(policy) AS total_policies,
     sum(policy.annual_premium) AS total_premium_portfolio,
     avg(policy.annual_premium) AS avg_policy_premium

// Claims metrics
MATCH (claim:Claim)
WITH report_date, total_customers, avg_customer_value, avg_annual_premium,
     total_policies, total_premium_portfolio, avg_policy_premium,
     count(claim) AS total_claims,
     sum(claim.claim_amount) AS total_claim_amount,
     avg(claim.claim_amount) AS avg_claim_amount

// Agent metrics
MATCH (agent:Agent)
WITH report_date, total_customers, avg_customer_value, avg_annual_premium,
     total_policies, total_premium_portfolio, avg_policy_premium,
     total_claims, total_claim_amount, avg_claim_amount,
     count(agent) AS total_agents,
     sum(agent.ytd_sales) AS total_ytd_sales

CREATE (kpi:BusinessKPI {
  id: randomUUID(),
  report_date: report_date,
  report_type: "Executive Dashboard",
  
  // Customer KPIs
  total_customers: total_customers,
  avg_customer_lifetime_value: round(avg_customer_value * 100) / 100,
  avg_annual_premium_per_customer: round(avg_annual_premium * 100) / 100,
  
  // Policy KPIs  
  total_active_policies: total_policies,
  total_premium_portfolio: round(total_premium_portfolio * 100) / 100,
  avg_policy_premium: round(avg_policy_premium * 100) / 100,
  policies_per_customer: round((total_policies * 1.0 / total_customers) * 100) / 100,
  
  // Claims KPIs
  total_claims: total_claims,
  total_claim_amount: round(total_claim_amount * 100) / 100,
  avg_claim_amount: round(avg_claim_amount * 100) / 100,
  loss_ratio: round((total_claim_amount / total_premium_portfolio) * 10000) / 100,
  claims_frequency: round((total_claims * 1.0 / total_policies) * 1000) / 10,
  
  // Agent KPIs
  total_agents: total_agents,
  total_ytd_sales: round(total_ytd_sales * 100) / 100,
  avg_agent_productivity: round((total_ytd_sales / total_agents) * 100) / 100,
  customers_per_agent: round((total_customers * 1.0 / total_agents) * 10) / 10,
  
  created_at: datetime(),
  created_by: "bi_system",
  version: 1
})

RETURN kpi.total_customers AS customers,
       kpi.total_active_policies AS policies,
       kpi.total_premium_portfolio AS premium_portfolio,
       kpi.loss_ratio AS loss_ratio_percent,
       kpi.avg_customer_lifetime_value AS avg_customer_value
```

### Step 8: Geographic Performance Analytics
```cypher
// Geographic business performance analysis
MATCH (customer:Customer)-[:HOLDS_POLICY]->(policy:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(claim:Claim)
OPTIONAL MATCH (agent:Agent)-[:SERVICES]->(customer)
OPTIONAL MATCH (agent)-[:WORKS_AT]->(branch:Branch)

WITH customer.city AS city,
     customer.state AS state,
     count(DISTINCT customer) AS customer_count,
     count(DISTINCT policy) AS policy_count,
     sum(policy.annual_premium) AS total_premium,
     count(DISTINCT claim) AS claim_count,
     sum(claim.claim_amount) AS total_claims,
     count(DISTINCT agent) AS agent_count,
     collect(DISTINCT branch.branch_name)[0] AS primary_branch

CREATE (geo_performance:GeographicPerformance {
  id: randomUUID(),
  analysis_date: date(),
  city: city,
  state: state,
  
  // Market metrics
  customer_base: customer_count,
  market_penetration: customer_count / 100000.0,
  policy_portfolio: policy_count,
  
  // Financial metrics
  total_premium_volume: round(total_premium * 100) / 100,
  avg_premium_per_customer: round((total_premium / customer_count) * 100) / 100,
  premium_density: round((total_premium / customer_count) * 100) / 100,
  
  // Risk metrics
  total_claims: claim_count,
  total_claim_amount: round(COALESCE(total_claims, 0.0) * 100) / 100,
  loss_ratio: 
    CASE WHEN total_premium > 0 
    THEN round((COALESCE(total_claims, 0.0) / total_premium) * 10000) / 100
    ELSE 0.0 END,
  claims_frequency: 
    CASE WHEN policy_count > 0
    THEN round((claim_count * 1.0 / policy_count) * 1000) / 10
    ELSE 0.0 END,
    
  // Operational metrics
  agent_coverage: agent_count,
  customers_per_agent: 
    CASE WHEN agent_count > 0
    THEN round((customer_count * 1.0 / agent_count) * 10) / 10
    ELSE 0.0 END,
  primary_branch: COALESCE(primary_branch, "Unassigned"),
  
  // Performance rating
  performance_rating: 
    CASE 
      WHEN total_premium > 15000 AND COALESCE(total_claims, 0.0) / total_premium < 0.3 THEN "Excellent"
      WHEN total_premium > 10000 AND COALESCE(total_claims, 0.0) / total_premium < 0.5 THEN "Good"
      WHEN total_premium > 5000 THEN "Average"
      ELSE "Developing"
    END,
    
  created_at: datetime(),
  created_by: "geographic_analytics_system",
  version: 1
})

RETURN geo_performance.city AS city,
       geo_performance.customer_base AS customers,
       geo_performance.total_premium_volume AS premium_volume,
       geo_performance.loss_ratio AS loss_ratio_percent,
       geo_performance.performance_rating AS rating
ORDER BY geo_performance.total_premium_volume DESC
```

### Step 9: Predictive Analytics Foundation
```cypher
// Create predictive models for customer behavior
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)

WITH customer, profile,
     // Calculate churn probability based on multiple factors
     CASE 
       WHEN profile.tenure_years < 1 THEN 0.4
       WHEN profile.claims_ratio > 0.8 THEN 0.6
       WHEN profile.payment_consistency = "Irregular" THEN 0.3
       WHEN profile.current_risk_score < 4.0 THEN 0.5
       ELSE 0.1
     END +
     CASE 
       WHEN profile.total_annual_premium < 500 THEN 0.2
       WHEN profile.assigned_agent = "Unassigned" THEN 0.15
       ELSE 0.0
     END AS churn_probability

CREATE (prediction:PredictiveModel {
  id: randomUUID(),
  customer_id: customer.customer_number,
  model_date: date(),
  model_type: "Customer Behavior Prediction",
  
  // Churn prediction
  churn_probability: round(churn_probability * 1000) / 10,
  churn_risk_level: 
    CASE 
      WHEN churn_probability >= 0.6 THEN "High Risk"
      WHEN churn_probability >= 0.3 THEN "Moderate Risk"
      ELSE "Low Risk"
    END,
    
  // Lifetime value prediction
  predicted_ltv: profile.lifetime_value * (1.0 + (profile.current_risk_score / 10.0)),
  
  // Cross-sell probability
  cross_sell_probability: 
    CASE 
      WHEN profile.customer_segment = "Premium Low-Risk" THEN 0.7
      WHEN profile.customer_segment = "High-Value Standard" THEN 0.5
      WHEN profile.policy_count = 1 AND profile.total_annual_premium > 1000 THEN 0.4
      ELSE 0.2
    END,
    
  // Claims prediction
  predicted_claims_next_year: 
    CASE 
      WHEN profile.total_claims > 2 THEN 1.5
      WHEN profile.total_claims = 1 THEN 0.8
      WHEN profile.current_risk_score < 5.0 THEN 0.6
      ELSE 0.3
    END,
    
  // Recommendations
  retention_actions: 
    CASE 
      WHEN churn_probability >= 0.5 THEN ["Personal agent contact", "Premium review", "Loyalty benefits"]
      WHEN churn_probability >= 0.3 THEN ["Check-in call", "Service satisfaction survey"]
      ELSE ["Maintain regular contact"]
    END,
    
  model_confidence: 0.75 + (rand() * 0.20),
  model_version: "v1.0",
  
  created_at: datetime(),
  created_by: "predictive_analytics_system",
  version: 1
})

// Connect predictions to customers
CREATE (customer)-[:HAS_PREDICTION {
  prediction_date: date(),
  model_type: "Behavioral Analysis",
  created_at: datetime()
}]->(prediction)

RETURN count(prediction) AS predictions_created
```

---

## Part 4: Advanced Analytics Queries and Insights (8 minutes)

### Step 10: Customer Lifetime Value Analysis
```cypher
// Comprehensive customer lifetime value analysis with risk factors
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)
OPTIONAL MATCH (customer)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)

RETURN customer.risk_tier AS risk_tier,
       count(customer) AS customer_count,
       avg(profile.lifetime_value) AS avg_current_ltv,
       avg(prediction.predicted_ltv) AS avg_predicted_ltv,
       avg(profile.current_risk_score) AS avg_risk_score,
       avg(prediction.churn_probability) AS avg_churn_probability,
       sum(profile.total_annual_premium) AS total_premium_base,
       avg(profile.tenure_years) AS avg_tenure_years
ORDER BY avg_predicted_ltv DESC
```

### Step 11: Risk and Profitability Correlation
```cypher
// Analyze correlation between risk scores and profitability
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)

WITH CASE 
       WHEN risk.risk_score >= 8.0 THEN "Very Low Risk"
       WHEN risk.risk_score >= 6.5 THEN "Low Risk"
       WHEN risk.risk_score >= 5.0 THEN "Moderate Risk"
       WHEN risk.risk_score >= 3.5 THEN "High Risk"
       ELSE "Very High Risk"
     END AS risk_category,
     profile.profitability_score AS profitability,
     profile.claims_ratio AS claims_ratio,
     profile.total_annual_premium AS annual_premium,
     customer.customer_number AS customer_id

RETURN risk_category,
       count(*) AS customer_count,
       avg(profitability) AS avg_profitability,
       avg(claims_ratio) AS avg_claims_ratio,
       avg(annual_premium) AS avg_annual_premium,
       min(profitability) AS min_profitability,
       max(profitability) AS max_profitability
ORDER BY avg_profitability DESC
```

### Step 12: Agent Performance with Customer Analytics
```cypher
// Agent performance correlation with customer portfolio quality
MATCH (agent:Agent)-[:SERVICES]->(customer:Customer)
MATCH (customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
OPTIONAL MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)

WITH agent,
     count(customer) AS customer_count,
     avg(profile.lifetime_value) AS avg_customer_value,
     avg(profile.current_risk_score) AS avg_risk_score,
     avg(prediction.churn_probability) AS avg_churn_risk,
     sum(profile.total_annual_premium) AS total_managed_premium,
     avg(profile.profitability_score) AS avg_profitability

RETURN agent.agent_id AS agent_id,
       agent.first_name + " " + agent.last_name AS agent_name,
       agent.territory AS territory,
       customer_count,
       round(avg_customer_value * 100) / 100 AS avg_customer_value,
       round(avg_risk_score * 100) / 100 AS avg_risk_score,
       round(avg_churn_risk * 10) / 10 AS avg_churn_risk_percent,
       round(total_managed_premium * 100) / 100 AS total_premium_managed,
       round(avg_profitability * 100) / 100 AS avg_profitability
ORDER BY total_premium_managed DESC
```

### Step 13: Complete Analytics Network Visualization
```cypher
// Comprehensive analytics visualization showing all relationships
MATCH (customer:Customer)-[r1:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[r2:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)
MATCH (customer)-[r3:HAS_PREDICTION]->(prediction:PredictiveModel)
OPTIONAL MATCH (customer)-[r4:HAS_OPPORTUNITY]->(opportunity:CrossSellOpportunity)
OPTIONAL MATCH (agent:Agent)-[r5:SERVICES]->(customer)
RETURN customer, r1, profile, r2, risk, r3, prediction, r4, opportunity, agent, r5
LIMIT 15
```

---

## Neo4j Lab 5 Summary

**🎯 What You've Accomplished:**

### **Advanced Risk Assessment**
- ✅ **Comprehensive risk scoring** with multi-factor analysis including credit, geography, and tenure
- ✅ **Territory risk profiling** analyzing geographic risk concentrations and market opportunities
- ✅ **Policy risk correlations** examining relationships between risk tiers and product performance
- ✅ **Predictive risk modeling** for underwriting and pricing optimization

### **Customer 360-Degree Views**
- ✅ **Complete customer profiles** integrating demographics, financial, policy, claims, and payment data
- ✅ **Advanced segmentation** with profitability scoring and retention risk analysis
- ✅ **Cross-sell opportunity identification** with personalized product recommendations
- ✅ **Predictive customer behavior modeling** for churn prevention and lifetime value optimization

### **Business Intelligence & KPIs**
- ✅ **Executive dashboard metrics** with comprehensive business performance indicators
- ✅ **Geographic performance analytics** showing market penetration and operational efficiency
- ✅ **Predictive analytics foundation** for customer behavior and business forecasting
- ✅ **Advanced correlation analysis** between risk, profitability, and operational metrics

### **Node Types Added (5 types):**
- ✅ **RiskAssessment** - Sophisticated risk scoring with multi-factor analysis
- ✅ **CustomerProfile** - 360-degree customer views with segmentation and profitability metrics
- ✅ **CrossSellOpportunity** - Personalized product recommendations with revenue projections
- ✅ **BusinessKPI** - Executive dashboard metrics and performance indicators
- ✅ **PredictiveModel** - Customer behavior predictions and retention analytics

### **Database State:** 200 nodes, 300 relationships with comprehensive analytics capabilities

### **Enterprise Analytics Readiness**
- ✅ **Data-driven decision making** with sophisticated metrics and predictive models
- ✅ **Customer relationship optimization** through 360-degree views and behavior prediction
- ✅ **Risk management** with comprehensive assessment and territory analysis
- ✅ **Business performance monitoring** with KPIs and geographic analytics

---

## Next Steps

You're now ready for **Session 2 - Lab 6: Customer Analytics & Segmentation**, where you'll:
- Implement advanced customer lifetime value calculations and behavioral segmentation
- Add Commission and MarketingCampaign entities for comprehensive business tracking
- Build sophisticated customer journey analytics and retention modeling
- Apply machine learning concepts for customer behavior prediction
- **Database Evolution:** 200 nodes → 280 nodes, 300 relationships → 380 relationships

**Congratulations!** You've built a comprehensive analytics foundation that provides deep business insights, sophisticated customer understanding, and predictive capabilities that enable data-driven decision making across all aspects of insurance operations.

## Troubleshooting

### If analytics queries run slowly:
- Use PROFILE to identify performance bottlenecks
- Ensure indexes exist on frequently queried properties: `CREATE INDEX customer_segment IF NOT EXISTS FOR (cp:CustomerProfile) ON (cp.customer_segment)`
- Consider query optimization with strategic LIMIT clauses during development

### If calculated metrics seem incorrect:
- Verify source data quality with validation queries
- Check for NULL values that might affect calculations: `COALESCE(value, 0.0)`
- Test calculations on smaller datasets first before applying to full database

### If relationships aren't created properly:
- Ensure all referenced entities exist before creating relationships
- Use MERGE instead of CREATE for entities that might already exist
- Verify relationship direction and property names match exactly