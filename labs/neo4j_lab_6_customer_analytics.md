# Neo4j Lab 6: Advanced Customer Intelligence & Segmentation

## Overview
**Duration:** 45 minutes  
**Objective:** Implement sophisticated customer lifetime value calculations, behavioral segmentation, and churn prediction modeling using graph-based analytics

Starting Session 2, you'll now leverage the analytics foundation from Session 1 to build advanced customer intelligence systems that drive marketing strategies, retention programs, and revenue optimization through sophisticated behavioral analysis and predictive modeling.

---

## Part 1: Customer Lifetime Value Calculations (12 minutes)

### Step 1: Enhanced Lifetime Value Modeling
Let's create sophisticated LTV calculations that consider multiple factors:

```cypher
// Calculate advanced customer lifetime value with behavioral factors
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(claim:Claim)

WITH customer, profile, prediction,
     collect(policy) AS policies,
     collect(claim) AS claims,
     
     // Calculate retention probability (inverse of churn)
     (100.0 - prediction.churn_probability) / 100.0 AS retention_probability,
     
     // Calculate policy diversification bonus
     size(collect(DISTINCT policy.product_type)) AS product_diversity,
     
     // Calculate claims impact
     CASE WHEN size(collect(claim)) = 0 THEN 1.2
          WHEN size(collect(claim)) = 1 THEN 1.0
          WHEN size(collect(claim)) = 2 THEN 0.8
          ELSE 0.6 END AS claims_adjustment,
          
     // Calculate tenure bonus
     CASE WHEN profile.tenure_years >= 5 THEN 1.3
          WHEN profile.tenure_years >= 3 THEN 1.1
          WHEN profile.tenure_years >= 1 THEN 1.0
          ELSE 0.8 END AS tenure_bonus

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
  product_diversity: product_diversity,
  product_diversity_score: product_diversity * 0.15,
  claims_frequency: profile.total_claims,
  claims_adjustment_factor: claims_adjustment,
  tenure_bonus_factor: tenure_bonus,
  
  // Risk and profitability factors
  risk_score: profile.current_risk_score,
  profitability_score: profile.profitability_score,
  payment_consistency: profile.payment_consistency,
  
  // Calculated LTV components
  base_annual_value: profile.total_annual_premium * profitability_score,
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
    (profile.total_annual_premium * profitability_score * claims_adjustment * tenure_bonus * 
     CASE WHEN retention_probability > 0.8 THEN 8.0
          WHEN retention_probability > 0.6 THEN 6.0
          WHEN retention_probability > 0.4 THEN 4.0
          ELSE 2.0 END) * 100) / 100,
          
  // Growth potential
  cross_sell_potential: prediction.cross_sell_probability,
  estimated_growth_value: 
    prediction.cross_sell_probability * 
    CASE WHEN NOT "Property" IN [p IN policies | p.product_type] THEN 800.0
         WHEN NOT "Life" IN [p IN policies | p.product_type] THEN 1200.0
         ELSE 300.0 END,
         
  // LTV confidence score
  model_confidence: 0.80 + (product_diversity * 0.05) + (tenure_bonus - 1.0),
  
  created_at: datetime(),
  created_by: "ltv_modeling_system",
  version: 1
})

// Connect LTV models to customers
CREATE (customer)-[:HAS_LTV_MODEL {
  model_date: date(),
  model_type: "Behavioral LTV v2.0",
  created_at: datetime()
}]->(ltv)

RETURN count(ltv) AS ltv_models_created
```

### Step 2: LTV Segment Analysis
```cypher
// Analyze LTV distribution and create value-based segments
MATCH (customer:Customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[:HAS_PROFILE]->(profile:CustomerProfile)

WITH ltv.calculated_ltv AS calculated_ltv,
     customer.customer_number AS customer_id,
     profile.customer_segment AS current_segment,
     ltv.retention_probability AS retention_prob,
     ltv.cross_sell_potential AS cross_sell_prob,
     
     // Create value tiers
     CASE WHEN ltv.calculated_ltv >= 20000 THEN "Platinum"
          WHEN ltv.calculated_ltv >= 15000 THEN "Gold"
          WHEN ltv.calculated_ltv >= 10000 THEN "Silver"
          WHEN ltv.calculated_ltv >= 5000 THEN "Bronze"
          ELSE "Basic" END AS ltv_tier

RETURN ltv_tier,
       count(*) AS customer_count,
       avg(calculated_ltv) AS avg_ltv,
       min(calculated_ltv) AS min_ltv,
       max(calculated_ltv) AS max_ltv,
       avg(retention_prob) AS avg_retention_probability,
       avg(cross_sell_prob) AS avg_cross_sell_potential,
       collect(DISTINCT current_segment) AS customer_segments_present
ORDER BY avg_ltv DESC
```

### Step 3: Commission Structure for Agents
```cypher
// Create commission tracking for agent performance based on customer value
MATCH (agent:Agent)-[:SERVICES]->(customer:Customer)
MATCH (customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)

WITH agent,
     count(DISTINCT customer) AS customers_managed,
     sum(ltv.calculated_ltv) AS total_ltv_managed,
     sum(policy.annual_premium) AS total_premium_managed,
     avg(ltv.retention_probability) AS avg_retention_rate,
     collect(DISTINCT customer.customer_number) AS customer_list

CREATE (commission:Commission {
  id: randomUUID(),
  agent_id: agent.agent_id,
  calculation_period: "Q3-2024",
  calculation_date: date(),
  
  // Base commission metrics
  customers_managed: customers_managed,
  total_premium_base: round(total_premium_managed * 100) / 100,
  base_commission_rate: agent.commission_rate,
  base_commission_amount: round(total_premium_managed * agent.commission_rate * 100) / 100,
  
  // LTV-based bonuses
  total_ltv_portfolio: round(total_ltv_managed * 100) / 100,
  avg_customer_ltv: round((total_ltv_managed / customers_managed) * 100) / 100,
  ltv_bonus_rate: 
    CASE WHEN total_ltv_managed > 100000 THEN 0.02
         WHEN total_ltv_managed > 50000 THEN 0.015
         WHEN total_ltv_managed > 25000 THEN 0.01
         ELSE 0.005 END,
  ltv_bonus_amount: round(total_ltv_managed * 
    CASE WHEN total_ltv_managed > 100000 THEN 0.02
         WHEN total_ltv_managed > 50000 THEN 0.015
         WHEN total_ltv_managed > 25000 THEN 0.01
         ELSE 0.005 END * 100) / 100,
         
  // Retention bonus
  portfolio_retention_rate: round(avg_retention_rate * 10) / 10,
  retention_bonus: 
    CASE WHEN avg_retention_rate >= 80 THEN total_premium_managed * 0.005
         WHEN avg_retention_rate >= 70 THEN total_premium_managed * 0.003
         ELSE 0.0 END,
         
  // Total compensation
  total_commission: round(
    (total_premium_managed * agent.commission_rate) +
    (total_ltv_managed * CASE WHEN total_ltv_managed > 100000 THEN 0.02
                             WHEN total_ltv_managed > 50000 THEN 0.015
                             WHEN total_ltv_managed > 25000 THEN 0.01
                             ELSE 0.005 END) +
    (CASE WHEN avg_retention_rate >= 80 THEN total_premium_managed * 0.005
          WHEN avg_retention_rate >= 70 THEN total_premium_managed * 0.003
          ELSE 0.0 END) * 100) / 100,
          
  performance_tier: 
    CASE WHEN total_ltv_managed > 100000 AND avg_retention_rate >= 80 THEN "Top Performer"
         WHEN total_ltv_managed > 50000 AND avg_retention_rate >= 70 THEN "High Performer"
         WHEN total_ltv_managed > 25000 THEN "Standard Performer"
         ELSE "Developing" END,
         
  created_at: datetime(),
  created_by: "commission_system",
  version: 1
})

// Connect commissions to agents
CREATE (agent)-[:EARNED_COMMISSION {
  period: "Q3-2024",
  commission_date: date(),
  created_at: datetime()
}]->(commission)

RETURN count(commission) AS commission_records_created
```

---

## Part 2: Behavioral Segmentation and Churn Prediction (15 minutes)

### Step 4: Advanced Behavioral Segmentation
```cypher
// Create sophisticated behavioral segments based on multiple factors
MATCH (customer:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
MATCH (customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)

WITH customer, profile, ltv, prediction,
     
     // Behavioral scoring
     CASE WHEN profile.payment_consistency = "Consistent" THEN 2
          WHEN profile.payment_consistency = "Irregular" THEN -1
          ELSE 0 END +
     CASE WHEN profile.claims_ratio < 0.2 THEN 2
          WHEN profile.claims_ratio < 0.5 THEN 1
          WHEN profile.claims_ratio < 0.8 THEN 0
          ELSE -2 END +
     CASE WHEN ltv.product_diversity >= 3 THEN 2
          WHEN ltv.product_diversity = 2 THEN 1
          ELSE 0 END +
     CASE WHEN profile.tenure_years >= 5 THEN 2
          WHEN profile.tenure_years >= 3 THEN 1
          WHEN profile.tenure_years >= 1 THEN 0
          ELSE -1 END AS behavioral_score

CREATE (behavior:BehavioralSegment {
  id: randomUUID(),
  customer_id: customer.customer_number,
  segmentation_date: date(),
  
  // Behavioral metrics
  payment_behavior: profile.payment_consistency,
  claims_behavior: 
    CASE WHEN profile.claims_ratio = 0 THEN "Claims-Free"
         WHEN profile.claims_ratio < 0.3 THEN "Low Claims"
         WHEN profile.claims_ratio < 0.7 THEN "Moderate Claims"
         ELSE "High Claims" END,
  product_adoption: 
    CASE WHEN ltv.product_diversity >= 3 THEN "Multi-Product"
         WHEN ltv.product_diversity = 2 THEN "Dual-Product"
         ELSE "Single-Product" END,
  tenure_behavior:
    CASE WHEN profile.tenure_years >= 5 THEN "Long-Term Loyal"
         WHEN profile.tenure_years >= 3 THEN "Established"
         WHEN profile.tenure_years >= 1 THEN "Developing"
         ELSE "New Customer" END,
         
  // Engagement patterns
  digital_engagement: 
    CASE WHEN customer.email IS NOT NULL THEN "Digital Active"
         ELSE "Traditional Preferred" END,
  service_interaction:
    CASE WHEN ltv.retention_probability > 80 THEN "Highly Satisfied"
         WHEN ltv.retention_probability > 60 THEN "Satisfied"
         WHEN ltv.retention_probability > 40 THEN "At Risk"
         ELSE "Dissatisfied" END,
         
  // Composite behavioral score
  behavioral_score: behavioral_score,
  behavioral_tier: 
    CASE WHEN behavioral_score >= 6 THEN "Champion"
         WHEN behavioral_score >= 4 THEN "Advocate"
         WHEN behavioral_score >= 2 THEN "Supporter"
         WHEN behavioral_score >= 0 THEN "Neutral"
         WHEN behavioral_score >= -2 THEN "Detractor"
         ELSE "At Risk" END,
         
  // Churn risk assessment
  churn_probability: prediction.churn_probability,
  churn_risk_factors: 
    CASE WHEN profile.payment_consistency = "Irregular" THEN ["Payment Issues"]
         ELSE [] END +
    CASE WHEN profile.claims_ratio > 0.7 THEN ["High Claims"]
         ELSE [] END +
    CASE WHEN profile.tenure_years < 1 THEN ["New Customer"]
         ELSE [] END +
    CASE WHEN ltv.retention_probability < 50 THEN ["Service Dissatisfaction"]
         ELSE [] END,
         
  retention_strategy: 
    CASE WHEN prediction.churn_probability > 60 THEN "Immediate Intervention"
         WHEN prediction.churn_probability > 40 THEN "Proactive Retention"
         WHEN prediction.churn_probability > 20 THEN "Standard Monitoring"
         ELSE "Loyalty Rewards" END,
         
  created_at: datetime(),
  created_by: "behavioral_analytics_system",
  version: 1
})

// Connect behavioral segments to customers
CREATE (customer)-[:HAS_BEHAVIORAL_SEGMENT {
  segment_date: date(),
  segment_type: "Advanced Behavioral Analysis",
  created_at: datetime()
}]->(behavior)

RETURN count(behavior) AS behavioral_segments_created
```

### Step 5: Marketing Campaign Targeting
```cypher
// Create targeted marketing campaigns based on behavioral segments
WITH [
  {
    campaign_id: "CAMP-RETENTION-001",
    name: "Champion Loyalty Program",
    target_segment: "Champion",
    campaign_type: "Retention",
    budget: 25000.00,
    expected_response: 0.35
  },
  {
    campaign_id: "CAMP-CROSS-SELL-001", 
    name: "Multi-Product Expansion",
    target_segment: "Advocate",
    campaign_type: "Cross-Sell",
    budget: 15000.00,
    expected_response: 0.25
  },
  {
    campaign_id: "CAMP-RETENTION-002",
    name: "At-Risk Customer Recovery",
    target_segment: "At Risk",
    campaign_type: "Retention",
    budget: 20000.00,
    expected_response: 0.15
  },
  {
    campaign_id: "CAMP-ENGAGEMENT-001",
    name: "New Customer Onboarding",
    target_segment: "Neutral",
    campaign_type: "Engagement",
    budget: 12000.00,
    expected_response: 0.20
  }
] AS campaignData

UNWIND campaignData AS campaign

CREATE (marketing:MarketingCampaign {
  id: randomUUID(),
  campaign_id: campaign.campaign_id,
  campaign_name: campaign.name,
  campaign_type: campaign.campaign_type,
  
  // Targeting
  target_behavioral_segment: campaign.target_segment,
  target_audience_size: 0, // Will be calculated
  
  // Campaign details
  start_date: date(),
  end_date: date() + duration({days: 90}),
  budget: campaign.budget,
  expected_response_rate: campaign.expected_response,
  
  // Channels
  marketing_channels: 
    CASE campaign.campaign_type
      WHEN "Retention" THEN ["Email", "Phone", "Direct Mail"]
      WHEN "Cross-Sell" THEN ["Email", "Agent Contact", "Digital Display"]
      WHEN "Engagement" THEN ["Email", "Social Media", "Agent Contact"]
      ELSE ["Email", "Digital Display"]
    END,
    
  // Messaging
  primary_message: 
    CASE campaign.campaign_type
      WHEN "Retention" THEN "We value your loyalty - exclusive benefits await"
      WHEN "Cross-Sell" THEN "Enhance your protection with additional coverage"
      WHEN "Engagement" THEN "Discover all the ways we can protect what matters"
      ELSE "Special offers for valued customers"
    END,
    
  // Success metrics
  target_metrics: [
    "Response Rate: " + toString(round(campaign.expected_response * 100)) + "%",
    "ROI: 300%",
    "Customer Satisfaction: 85%"
  ],
  
  // Campaign status
  campaign_status: "Active",
  created_at: datetime(),
  created_by: "marketing_system",
  version: 1
})

RETURN count(marketing) AS marketing_campaigns_created
```

### Step 6: Campaign Audience Assignment
```cypher
// Assign customers to appropriate marketing campaigns
MATCH (customer:Customer)-[:HAS_BEHAVIORAL_SEGMENT]->(behavior:BehavioralSegment)
MATCH (campaign:MarketingCampaign)
WHERE campaign.target_behavioral_segment = behavior.behavioral_tier

// Create campaign targeting relationships
CREATE (campaign)-[:TARGETS {
  targeting_date: date(),
  targeting_criteria: "Behavioral Segment Match",
  priority: 
    CASE behavior.behavioral_tier
      WHEN "Champion" THEN "High"
      WHEN "At Risk" THEN "Urgent"
      ELSE "Standard"
    END,
  expected_response: campaign.expected_response_rate,
  created_at: datetime()
}]->(customer)

// Update campaign audience sizes
WITH campaign, count(customer) AS audience_size
SET campaign.target_audience_size = audience_size,
    campaign.expected_responses = round(audience_size * campaign.expected_response_rate),
    campaign.cost_per_target = round((campaign.budget / audience_size) * 100) / 100

RETURN campaign.campaign_name AS campaign,
       campaign.target_behavioral_segment AS target_segment,
       campaign.target_audience_size AS audience_size,
       campaign.expected_responses AS expected_responses,
       campaign.cost_per_target AS cost_per_customer
ORDER BY audience_size DESC
```

---

## Part 3: Cross-Sell Analytics and Revenue Optimization (10 minutes)

### Step 7: Advanced Cross-Sell Opportunity Analysis
```cypher
// Enhanced cross-sell analysis with revenue projections
MATCH (customer:Customer)-[:HAS_OPPORTUNITY]->(opportunity:CrossSellOpportunity)
MATCH (customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[:HAS_BEHAVIORAL_SEGMENT]->(behavior:BehavioralSegment)
MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)

WITH customer, opportunity, ltv, behavior,
     collect(DISTINCT policy.product_type) AS current_products,
     
     // Calculate enhanced opportunity scoring
     opportunity.opportunity_score +
     CASE behavior.behavioral_tier
       WHEN "Champion" THEN 3.0
       WHEN "Advocate" THEN 2.0
       WHEN "Supporter" THEN 1.0
       ELSE 0.0
     END +
     CASE WHEN ltv.calculated_ltv > 15000 THEN 2.0
          WHEN ltv.calculated_ltv > 10000 THEN 1.0
          ELSE 0.0
     END AS enhanced_opportunity_score

// Update cross-sell opportunities with enhanced analytics
SET opportunity.enhanced_score = enhanced_opportunity_score,
    opportunity.behavioral_tier = behavior.behavioral_tier,
    opportunity.current_ltv = ltv.calculated_ltv,
    opportunity.probability_adjustment = 
      CASE behavior.behavioral_tier
        WHEN "Champion" THEN 1.5
        WHEN "Advocate" THEN 1.3
        WHEN "Supporter" THEN 1.1
        WHEN "Neutral" THEN 1.0
        WHEN "Detractor" THEN 0.7
        ELSE 0.5
      END,
    opportunity.adjusted_revenue_potential = round(
      opportunity.estimated_revenue * 
      CASE behavior.behavioral_tier
        WHEN "Champion" THEN 1.5
        WHEN "Advocate" THEN 1.3
        WHEN "Supporter" THEN 1.1
        WHEN "Neutral" THEN 1.0
        WHEN "Detractor" THEN 0.7
        ELSE 0.5
      END * 100) / 100,
    opportunity.contact_urgency = 
      CASE WHEN enhanced_opportunity_score > 15 THEN "Immediate"
           WHEN enhanced_opportunity_score > 12 THEN "High"
           WHEN enhanced_opportunity_score > 9 THEN "Medium"
           ELSE "Low"
      END

RETURN customer.customer_number AS customer_id,
       behavior.behavioral_tier AS segment,
       opportunity.recommended_products AS products,
       opportunity.enhanced_score AS opportunity_score,
       opportunity.adjusted_revenue_potential AS revenue_potential,
       opportunity.contact_urgency AS urgency
ORDER BY opportunity.enhanced_score DESC
LIMIT 20
```

### Step 8: Agent Performance with Customer Value Correlation
```cypher
// Comprehensive agent performance analysis with customer value metrics
MATCH (agent:Agent)-[:SERVICES]->(customer:Customer)
MATCH (customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[:HAS_BEHAVIORAL_SEGMENT]->(behavior:BehavioralSegment)
MATCH (agent)-[:EARNED_COMMISSION]->(commission:Commission)
OPTIONAL MATCH (customer)-[:HAS_OPPORTUNITY]->(opportunity:CrossSellOpportunity)

WITH agent, commission,
     count(DISTINCT customer) AS total_customers,
     sum(ltv.calculated_ltv) AS total_ltv_managed,
     avg(ltv.calculated_ltv) AS avg_customer_ltv,
     avg(ltv.retention_probability) AS avg_retention_rate,
     
     // Behavioral segment distribution
     size([b IN collect(behavior) WHERE b.behavioral_tier = "Champion"]) AS champion_customers,
     size([b IN collect(behavior) WHERE b.behavioral_tier = "Advocate"]) AS advocate_customers,
     size([b IN collect(behavior) WHERE b.behavioral_tier = "At Risk"]) AS at_risk_customers,
     
     // Cross-sell performance
     count(DISTINCT opportunity) AS cross_sell_opportunities,
     avg(opportunity.enhanced_score) AS avg_opportunity_score

CREATE (performance:AgentPerformanceAnalytics {
  id: randomUUID(),
  agent_id: agent.agent_id,
  analysis_period: "Q3-2024",
  analysis_date: date(),
  
  // Customer portfolio metrics
  total_customers_managed: total_customers,
  total_ltv_portfolio: round(total_ltv_managed * 100) / 100,
  average_customer_ltv: round(avg_customer_ltv * 100) / 100,
  portfolio_retention_rate: round(avg_retention_rate * 10) / 10,
  
  // Customer quality distribution
  champion_customer_count: champion_customers,
  champion_percentage: round((champion_customers * 100.0 / total_customers) * 10) / 10,
  advocate_customer_count: advocate_customers,
  advocate_percentage: round((advocate_customers * 100.0 / total_customers) * 10) / 10,
  at_risk_customer_count: at_risk_customers,
  at_risk_percentage: round((at_risk_customers * 100.0 / total_customers) * 10) / 10,
  
  // Cross-sell performance
  cross_sell_opportunities_identified: cross_sell_opportunities,
  opportunities_per_customer: round((cross_sell_opportunities * 1.0 / total_customers) * 100) / 100,
  average_opportunity_score: round(COALESCE(avg_opportunity_score, 0.0) * 100) / 100,
  
  // Financial performance
  total_commission_earned: commission.total_commission,
  commission_per_customer: round((commission.total_commission / total_customers) * 100) / 100,
  ltv_to_commission_ratio: round((total_ltv_managed / commission.total_commission) * 100) / 100,
  
  // Performance rating
  overall_performance_score: 
    (champion_customers * 3 + advocate_customers * 2 + (total_customers - at_risk_customers)) / total_customers +
    (avg_retention_rate / 20) +
    (COALESCE(avg_opportunity_score, 0.0) / 5),
    
  performance_rating: 
    CASE WHEN (champion_customers * 3 + advocate_customers * 2 + (total_customers - at_risk_customers)) / total_customers +
              (avg_retention_rate / 20) +
              (COALESCE(avg_opportunity_score, 0.0) / 5) >= 8.0 THEN "Exceptional"
         WHEN (champion_customers * 3 + advocate_customers * 2 + (total_customers - at_risk_customers)) / total_customers +
              (avg_retention_rate / 20) +
              (COALESCE(avg_opportunity_score, 0.0) / 5) >= 6.5 THEN "High Performer"
         WHEN (champion_customers * 3 + advocate_customers * 2 + (total_customers - at_risk_customers)) / total_customers +
              (avg_retention_rate / 20) +
              (COALESCE(avg_opportunity_score, 0.0) / 5) >= 5.0 THEN "Meets Expectations"
         ELSE "Needs Improvement"
    END,
    
  created_at: datetime(),
  created_by: "performance_analytics_system",
  version: 1
})

// Connect performance analytics to agents
CREATE (agent)-[:HAS_PERFORMANCE_ANALYTICS {
  analysis_period: "Q3-2024",
  analysis_date: date(),
  created_at: datetime()
}]->(performance)

RETURN count(performance) AS performance_analytics_created
```

---

## Part 4: Predictive Customer Journey Analytics (8 minutes)

### Step 9: Customer Journey Prediction
```cypher
// Create predictive customer journey models
MATCH (customer:Customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[:HAS_BEHAVIORAL_SEGMENT]->(behavior:BehavioralSegment)
MATCH (customer)-[:HAS_PREDICTION]->(prediction:PredictiveModel)

WITH customer, ltv, behavior, prediction,
     
     // Predict next 12 months journey
     CASE WHEN prediction.churn_probability > 60 THEN "Retention Focus"
          WHEN ltv.cross_sell_potential > 0.6 THEN "Expansion Opportunity"
          WHEN behavior.behavioral_tier IN ["Champion", "Advocate"] THEN "Loyalty Deepening"
          WHEN behavior.behavioral_tier = "At Risk" THEN "Recovery Program"
          ELSE "Standard Journey" END AS predicted_journey

CREATE (journey:CustomerJourney {
  id: randomUUID(),
  customer_id: customer.customer_number,
  journey_prediction_date: date(),
  prediction_horizon: "12 months",
  
  // Current state
  current_behavioral_tier: behavior.behavioral_tier,
  current_ltv: ltv.calculated_ltv,
  current_retention_probability: ltv.retention_probability,
  
  // Predicted journey
  predicted_journey_type: predicted_journey,
  predicted_journey_stages: 
    CASE predicted_journey
      WHEN "Retention Focus" THEN ["Immediate Contact", "Issue Resolution", "Loyalty Incentive", "Relationship Rebuild"]
      WHEN "Expansion Opportunity" THEN ["Needs Assessment", "Product Recommendation", "Proposal", "Cross-sell Close"]
      WHEN "Loyalty Deepening" THEN ["Appreciation Contact", "Exclusive Benefits", "Referral Program", "VIP Services"]
      WHEN "Recovery Program" THEN ["Risk Assessment", "Service Recovery", "Value Demonstration", "Retention Offer"]
      ELSE ["Regular Contact", "Service Check", "Renewal Planning", "Satisfaction Survey"]
    END,
    
  // Predicted outcomes
  predicted_12_month_retention: 
    CASE WHEN predicted_journey = "Retention Focus" THEN ltv.retention_probability * 0.8
         WHEN predicted_journey = "Recovery Program" THEN ltv.retention_probability * 0.6
         ELSE ltv.retention_probability * 1.1 END,
         
  predicted_ltv_change: 
    CASE WHEN predicted_journey = "Expansion Opportunity" THEN ltv.calculated_ltv * 1.3
         WHEN predicted_journey = "Loyalty Deepening" THEN ltv.calculated_ltv * 1.15
         WHEN predicted_journey = "Retention Focus" THEN ltv.calculated_ltv * 0.9
         WHEN predicted_journey = "Recovery Program" THEN ltv.calculated_ltv * 0.7
         ELSE ltv.calculated_ltv * 1.05 END,
         
  // Touchpoint predictions
  predicted_touchpoints: 
    CASE WHEN behavior.behavioral_tier = "Champion" THEN 8
         WHEN behavior.behavioral_tier = "Advocate" THEN 6
         WHEN behavior.behavioral_tier = "At Risk" THEN 12
         ELSE 4 END,
         
  predicted_channel_preference: 
    CASE WHEN ltv.calculated_ltv > 15000 THEN "Personal Agent"
         WHEN behavior.behavioral_tier = "At Risk" THEN "Phone + Email"
         ELSE "Digital First" END,
         
  // Success probability
  journey_success_probability: 
    CASE predicted_journey
      WHEN "Expansion Opportunity" THEN ltv.cross_sell_potential
      WHEN "Retention Focus" THEN 0.75
      WHEN "Loyalty Deepening" THEN 0.85
      WHEN "Recovery Program" THEN 0.45
      ELSE 0.70 END,
      
  // Resource requirements
  estimated_agent_hours: 
    CASE predicted_journey
      WHEN "Recovery Program" THEN 8.0
      WHEN "Retention Focus" THEN 6.0
      WHEN "Expansion Opportunity" THEN 4.0
      WHEN "Loyalty Deepening" THEN 3.0
      ELSE 2.0 END,
      
  estimated_cost: 
    CASE predicted_journey
      WHEN "Recovery Program" THEN 250.0
      WHEN "Retention Focus" THEN 200.0
      WHEN "Expansion Opportunity" THEN 150.0
      WHEN "Loyalty Deepening" THEN 100.0
      ELSE 75.0 END,
      
  created_at: datetime(),
  created_by: "journey_prediction_system",
  version: 1
})

// Connect journey predictions to customers
CREATE (customer)-[:HAS_PREDICTED_JOURNEY {
  prediction_date: date(),
  journey_type: predicted_journey,
  created_at: datetime()
}]->(journey)

RETURN count(journey) AS customer_journeys_predicted
```

### Step 10: Comprehensive Analytics Dashboard Query
```cypher
// Executive analytics dashboard with all customer intelligence metrics
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
OPTIONAL MATCH (customer)-[:HAS_BEHAVIORAL_SEGMENT]->(behavior:BehavioralSegment)
OPTIONAL MATCH (customer)-[:HAS_PREDICTED_JOURNEY]->(journey:CustomerJourney)
OPTIONAL MATCH (campaign:MarketingCampaign)-[:TARGETS]->(customer)

WITH 
  // Customer segmentation metrics
  count(DISTINCT customer) AS total_customers,
  count(DISTINCT CASE WHEN behavior.behavioral_tier = "Champion" THEN customer END) AS champion_customers,
  count(DISTINCT CASE WHEN behavior.behavioral_tier = "Advocate" THEN customer END) AS advocate_customers,
  count(DISTINCT CASE WHEN behavior.behavioral_tier = "At Risk" THEN customer END) AS at_risk_customers,
  
  // LTV metrics
  avg(ltv.calculated_ltv) AS avg_customer_ltv,
  sum(ltv.calculated_ltv) AS total_portfolio_ltv,
  avg(ltv.retention_probability) AS avg_retention_rate,
  
  // Journey predictions
  count(DISTINCT CASE WHEN journey.predicted_journey_type = "Expansion Opportunity" THEN customer END) AS expansion_opportunities,
  count(DISTINCT CASE WHEN journey.predicted_journey_type = "Retention Focus" THEN customer END) AS retention_focus_needed,
  
  // Campaign targeting
  count(DISTINCT campaign) AS active_campaigns,
  count(DISTINCT CASE WHEN campaign IS NOT NULL THEN customer END) AS customers_in_campaigns

RETURN 
  "Customer Intelligence Dashboard" AS dashboard_title,
  total_customers AS total_customers,
  round((champion_customers * 100.0 / total_customers) * 10) / 10 AS champion_percentage,
  round((advocate_customers * 100.0 / total_customers) * 10) / 10 AS advocate_percentage,
  round((at_risk_customers * 100.0 / total_customers) * 10) / 10 AS at_risk_percentage,
  round(avg_customer_ltv * 100) / 100 AS avg_customer_ltv,
  round(total_portfolio_ltv * 100) / 100 AS total_portfolio_ltv,
  round(avg_retention_rate * 10) / 10 AS avg_retention_rate_percent,
  expansion_opportunities AS customers_ready_for_expansion,
  retention_focus_needed AS customers_needing_retention_focus,
  active_campaigns AS marketing_campaigns_active,
  round((customers_in_campaigns * 100.0 / total_customers) * 10) / 10 AS campaign_coverage_percentage
```

### Step 11: Customer Intelligence Network Visualization
```cypher
// Comprehensive customer intelligence network visualization
MATCH (customer:Customer)-[r1:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
MATCH (customer)-[r2:HAS_BEHAVIORAL_SEGMENT]->(behavior:BehavioralSegment)
MATCH (customer)-[r3:HAS_PREDICTED_JOURNEY]->(journey:CustomerJourney)
OPTIONAL MATCH (campaign:MarketingCampaign)-[r4:TARGETS]->(customer)
OPTIONAL MATCH (agent:Agent)-[r5:SERVICES]->(customer)
RETURN customer, r1, ltv, r2, behavior, r3, journey, r4, campaign, agent, r5
LIMIT 20
```

---

## Neo4j Lab 6 Summary

**🎯 What You've Accomplished:**

### **Advanced Customer Lifetime Value**
- ✅ **Sophisticated LTV calculations** incorporating behavioral factors, retention probability, and growth potential
- ✅ **Multi-factor LTV modeling** with risk adjustment, tenure bonuses, and claims impact analysis
- ✅ **Value-based segmentation** creating Platinum, Gold, Silver, Bronze, and Basic customer tiers
- ✅ **Commission optimization** linking agent compensation to customer value and retention performance

### **Behavioral Intelligence & Segmentation**
- ✅ **Advanced behavioral scoring** using payment patterns, claims behavior, product adoption, and tenure
- ✅ **Six-tier behavioral segments** from Champion to At Risk with detailed characteristics
- ✅ **Churn risk assessment** with specific risk factors and targeted retention strategies
- ✅ **Marketing campaign targeting** with personalized messaging and channel optimization

### **Predictive Customer Analytics**
- ✅ **Customer journey prediction** forecasting 12-month paths with success probabilities
- ✅ **Cross-sell opportunity enhancement** with behavioral adjustments and revenue projections
- ✅ **Agent performance correlation** connecting customer value metrics to agent effectiveness
- ✅ **Resource optimization** predicting agent hours and costs for customer management

### **Node Types Added (5 types):**
- ✅ **LifetimeValueModel** - Sophisticated LTV calculations with behavioral and risk factors
- ✅ **Commission** - Agent compensation tracking with LTV-based bonuses and performance metrics
- ✅ **BehavioralSegment** - Six-tier behavioral classification with churn risk and retention strategies
- ✅ **MarketingCampaign** - Targeted campaigns with audience sizing and response predictions
- ✅ **CustomerJourney** - Predictive journey modeling with touchpoint and resource planning

### **Database State:** 280 nodes, 380 relationships with advanced customer intelligence

### **Business Impact Capabilities**
- ✅ **Revenue optimization** through value-based customer management and targeted campaigns
- ✅ **Retention improvement** with predictive churn identification and intervention strategies
- ✅ **Cross-sell efficiency** using behavioral insights for personalized product recommendations
- ✅ **Agent performance optimization** through customer value correlation and commission alignment

---

## Next Steps

You're now ready for **Lab 7: Graph Algorithms for Insurance**, where you'll:
- Add Incident and FraudInvestigation entities for pattern detection
- Implement centrality analysis for customer influence scoring and agent network analysis
- Apply community detection algorithms for fraud ring identification and market segmentation
- Master pathfinding algorithms for claims investigation and relationship analysis
- **Database Evolution:** 280 nodes → 350 nodes, 380 relationships → 450 relationships

**Congratulations!** You've built a sophisticated customer intelligence system that provides actionable insights for revenue optimization, retention improvement, and personalized customer management through advanced behavioral analytics and predictive modeling.

## Troubleshooting

### If LTV calculations seem inconsistent:
- Verify all source metrics exist: `MATCH (c:Customer)-[:HAS_PROFILE]->(p) RETURN count(p)`
- Check for NULL values in calculations using COALESCE
- Validate retention probability ranges (0-100): `MATCH (l:LifetimeValueModel) WHERE l.retention_probability > 100 RETURN count(l)`

### If behavioral segments are unbalanced:
- Review scoring algorithm thresholds for appropriate distribution
- Check data quality in source customer profiles
- Consider adjusting segment boundaries based on business requirements

### If campaign targeting returns no results:
- Verify behavioral segments exist: `MATCH (b:BehavioralSegment) RETURN DISTINCT b.behavioral_tier`
- Check campaign target criteria match existing segment values
- Ensure relationship directions are correct in targeting queries