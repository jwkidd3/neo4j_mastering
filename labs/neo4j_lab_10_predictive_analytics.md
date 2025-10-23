# Neo4j Lab 10: Predictive Analytics & Machine Learning Integration

## Overview
**Duration:** 45 minutes
**Objective:** Learn how to integrate Neo4j with external machine learning systems by extracting graph-based features, storing ML predictions, and querying prediction results for business operations

Building on Lab 7's compliance systems, you'll now learn the complete ML workflow: using Cypher to extract graph-enhanced features from customer networks, simulating external ML model predictions (Python/scikit-learn), storing those predictions back in Neo4j, and querying prediction results to drive business decisions.

**Key Concept:** Neo4j doesn't perform ML training - it excels at extracting rich graph features for ML models and storing/querying prediction results. The actual ML computation happens in Python frameworks (scikit-learn, TensorFlow, PyTorch).

---

## Part 1: Customer Churn Prediction and Retention (15 minutes)

**Workflow Overview:**
1. Extract graph-based features using Cypher (Step 1)
2. External ML model generates predictions (Step 2 - Python example)
3. Store predictions in Neo4j using Cypher (Step 3)
4. Query and analyze predictions (Step 4)
5. Create retention plans based on predictions (Step 5)

### Step 1: Extract Graph-Based Features for ML Model
First, we extract features from the graph that will be fed into an external ML model:

```cypher
// Extract graph-enhanced features for churn prediction ML model
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policies:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(claims:Claim)
OPTIONAL MATCH (customer)-[:MADE_PAYMENT]->(payments:Payment)
OPTIONAL MATCH (customer)-[:HAS_PROFILE]->(profile:CustomerProfile)

WITH customer,
     collect(policies) AS customer_policies,
     collect(claims) AS customer_claims,
     collect(payments) AS customer_payments,
     profile,
     size(collect(policies)) AS policy_count,
     avg(policies.annual_premium) AS avg_premium,
     count(claims) AS claims_count

WITH customer, customer_policies, customer_claims, customer_payments, profile, policy_count, avg_premium, claims_count,
     [p IN customer_payments WHERE p.payment_method IS NOT NULL |
          CASE p.payment_method
            WHEN "Auto Pay" THEN 5
            WHEN "Online" THEN 4
            WHEN "Phone" THEN 3
            WHEN "Mail" THEN 2
            ELSE 1 END] AS payment_scores

WITH customer, customer_policies, customer_claims, customer_payments, profile, policy_count, avg_premium, claims_count,
     CASE WHEN size(payment_scores) > 0
          THEN reduce(sum = 0.0, score IN payment_scores | sum + score) / size(payment_scores)
          ELSE 2.5 END AS payment_convenience_score

RETURN
  customer.customer_number AS customer_id,

  // Demographic features
  duration.between(customer.date_of_birth, date()).years AS customer_age,
  duration.between(customer.created_date, date()).days AS customer_tenure_days,
  COALESCE(customer.credit_score, 650) AS credit_score,

  // Policy portfolio features
  policy_count AS total_policies,
  COALESCE(reduce(s = 0, p IN customer_policies | s + p.annual_premium), 0) AS total_annual_premium,
  COALESCE(avg_premium, 0) AS avg_policy_premium,
  size(reduce(unique = [], p IN customer_policies |
    CASE WHEN p.policy_type IN unique THEN unique ELSE unique + p.policy_type END
  )) AS policy_diversity,

  // Claims behavior features
  claims_count AS total_claims,
  CASE WHEN duration.between(customer.created_date, date()).days > 0
       THEN (claims_count * 365.0) / duration.between(customer.created_date, date()).days
       ELSE 0 END AS claims_frequency,
  CASE WHEN claims_count > 0
       THEN reduce(s = 0.0, c IN customer_claims | s + c.claim_amount) / size(customer_claims)
       ELSE 0 END AS avg_claim_amount,

  // Payment behavior features
  payment_convenience_score,
  CASE WHEN size(customer_payments) > 0
       THEN 1.0 - (size([p IN customer_payments WHERE p.payment_status = "Late"]) * 1.0 / size(customer_payments))
       ELSE 0.8 END AS payment_consistency,

  // Graph network features (unique to Neo4j!)
  COALESCE(profile.network_centrality, 0.1) AS network_score,
  COALESCE(profile.referral_count, 0) AS referral_activity

// Note: This query returns features that would be used as input to an ML model
// In production, you'd export this data to train/apply your ML model
```

### Step 2: External ML Model (Python Example - Not Executed in Neo4j)
```python
# Example: How an external ML model would use the extracted features
# This code runs in Python, NOT in Neo4j!

from neo4j import GraphDatabase
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import pickle

# Connect and extract features
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))

with driver.session() as session:
    # Run the feature extraction query from Step 1
    result = session.run("""
        // ... feature extraction query from Step 1 ...
    """)
    features_df = pd.DataFrame([dict(record) for record in result])

# Prepare features for ML
X = features_df[[
    'customer_age', 'customer_tenure_days', 'credit_score',
    'total_policies', 'total_annual_premium', 'policy_diversity',
    'total_claims', 'claims_frequency', 'payment_consistency',
    'network_score', 'referral_activity'  # Graph features!
]]

# Load pre-trained model (or train new one)
# model = RandomForestClassifier()  # Training code omitted
model = pickle.load(open('churn_model_v3.2.pkl', 'rb'))

# Generate predictions
predictions = model.predict_proba(X)[:, 1]  # Probability of churn
confidence_scores = model.predict_proba(X).max(axis=1)

# Prepare results for loading back into Neo4j
results_df = pd.DataFrame({
    'customer_id': features_df['customer_id'],
    'churn_probability': predictions,
    'confidence_score': confidence_scores,
    'model_version': '3.2',
    'prediction_date': pd.Timestamp.now().date()
})

# Results would be saved to CSV or directly loaded to Neo4j
# results_df.to_csv('churn_predictions.csv', index=False)
```

### Step 3: Store ML Predictions in Neo4j
Now we load the ML-generated predictions back into Neo4j for operational use:

```cypher
// Load ML-generated churn predictions into Neo4j
// In production: LOAD CSV or Python driver to bulk insert predictions
// For this lab, we'll simulate with sample prediction values

MATCH (customer:Customer)
WITH customer, rand() AS random_value

// Simulate ML prediction results (in production, these come from your ML model)
WITH customer,
     // Simulate churn probability based on simplified logic for demo
     CASE
       WHEN customer.credit_score < 600 THEN 0.65 + (random_value * 0.25)
       WHEN customer.credit_score < 700 THEN 0.35 + (random_value * 0.25)
       ELSE 0.10 + (random_value * 0.20)
     END AS churn_probability

// Create prediction node with ML results
CREATE (churn_prediction:ChurnPrediction {
  id: randomUUID(),
  prediction_id: "CHURN-" + customer.customer_number + "-" + toString(date()),
  customer_id: customer.customer_number,
  prediction_date: date(),
  model_version: "3.2",

  // ML model output (would come from Python ML system)
  churn_probability: churn_probability,
  confidence_score: 0.75 + (rand() * 0.15),  // Simulated confidence

  // Risk classification based on probability
  churn_risk_level: CASE
    WHEN churn_probability >= 0.6 THEN "High Risk"
    WHEN churn_probability >= 0.3 THEN "Medium Risk"
    WHEN churn_probability >= 0.15 THEN "Low Risk"
    ELSE "Very Low Risk"
  END,

  // Metadata
  created_at: datetime(),
  created_by: "ml_prediction_system"
})

// Link prediction to customer
CREATE (customer)-[:HAS_CHURN_PREDICTION {
  prediction_date: date(),
  model_version: "3.2",
  created_at: datetime()
}]->(churn_prediction)

RETURN count(churn_prediction) AS churn_predictions_created
```

### Step 4: Query and Analyze Stored Predictions
Now we can query the ML predictions stored in Neo4j:

```cypher
// Analyze churn predictions across customer base
MATCH (customer:Customer)-[:HAS_CHURN_PREDICTION]->(prediction:ChurnPrediction)

RETURN
  prediction.churn_risk_level AS risk_level,
  count(*) AS customer_count,
  round(avg(prediction.churn_probability) * 100, 2) AS avg_churn_probability_pct,
  round(avg(prediction.confidence_score) * 100, 2) AS avg_confidence_pct,
  round(min(prediction.churn_probability) * 100, 2) AS min_churn_prob_pct,
  round(max(prediction.churn_probability) * 100, 2) AS max_churn_prob_pct

ORDER BY
  CASE risk_level
    WHEN "High Risk" THEN 1
    WHEN "Medium Risk" THEN 2
    WHEN "Low Risk" THEN 3
    ELSE 4
  END
```

### Step 5: Create Targeted Retention Plans Based on Stored Predictions
```cypher
// Create personalized retention plans for at-risk customers based on ML predictions
MATCH (customer:Customer)-[:HAS_CHURN_PREDICTION]->(prediction:ChurnPrediction)
WHERE prediction.churn_risk_level IN ["High Risk", "Medium Risk"]

CREATE (retention_plan:RetentionPlan {
  id: randomUUID(),
  plan_id: "RET-" + customer.customer_number + "-" + toString(date()),
  customer_id: customer.customer_number,
  risk_level: prediction.churn_risk_level,
  churn_probability: prediction.churn_probability,
  
  // Retention strategy based on risk level and customer profile
  retention_strategy: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN "Intensive Intervention"
      WHEN "Medium Risk" THEN "Proactive Engagement"
      ELSE "Preventive Monitoring"
    END,
    
  // Specific actions based on customer characteristics
  recommended_actions: 
    CASE 
      WHEN prediction.payment_consistency < 0.7 THEN ["Payment plan assistance", "Auto-pay enrollment", "Payment method counseling"]
      WHEN prediction.claims_frequency > 1.5 THEN ["Claims review consultation", "Risk mitigation advice", "Premium adjustment discussion"]
      WHEN prediction.policy_diversity = 1 THEN ["Cross-sell consultation", "Bundle discount offer", "Comprehensive coverage review"]
      WHEN prediction.churn_risk_level = "High Risk" THEN ["Executive escalation", "Retention specialist assignment"]
      ELSE []
    END,
    
  // Contact strategy
  contact_frequency: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN "Weekly for 4 weeks, then bi-weekly"
      WHEN "Medium Risk" THEN "Bi-weekly for 6 weeks"
      ELSE "Monthly check-in"
    END,
    
  contact_methods: ["Phone", "Email", "In-person if local"],
  
  // Incentives and offers
  retention_offers: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN ["10% premium discount for 6 months", "No-deductible claims review", "Premium payment deferral"]
      WHEN "Medium Risk" THEN ["5% premium discount for 3 months", "Free policy review", "Customer appreciation gift"]
      ELSE ["Loyalty program enrollment", "Annual policy review"]
    END,
    
  // Timeline
  plan_duration: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN 90
      WHEN "Medium Risk" THEN 60
      ELSE 30
    END,
    
  target_completion: date() + duration({days: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN 90
      WHEN "Medium Risk" THEN 60
      ELSE 30
    END}),
    
  // Success metrics
  success_criteria: [
    "Customer satisfaction score > 8/10",
    "Payment consistency improvement",
    "Policy renewal commitment",
    "Reduced contact center complaints"
  ],
  
  estimated_cost: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN 500.00
      WHEN "Medium Risk" THEN 200.00
      ELSE 75.00
    END,
    
  expected_ltv_preservation: 
    CASE prediction.churn_risk_level
      WHEN "High Risk" THEN 8500.00
      WHEN "Medium Risk" THEN 6200.00
      ELSE 4000.00
    END,
    
  plan_status: "Active",
  assigned_agent: null,  // To be assigned
  
  created_at: datetime(),
  created_by: "retention_planning_system",
  version: 1
})

// Connect retention plan to customer and prediction
CREATE (retention_plan)-[:TARGETS_CUSTOMER {
  targeting_date: date(),
  retention_priority: prediction.churn_risk_level,
  created_at: datetime()
}]->(customer)

CREATE (retention_plan)-[:BASED_ON_PREDICTION {
  prediction_date: date(),
  model_version: "3.2",
  created_at: datetime()
}]->(prediction)

RETURN count(retention_plan) AS retention_plans_created
```

---

## Part 2: Claims Prediction and Severity Modeling (12 minutes)

**Workflow Overview:**
1. Register ML model metadata in Neo4j (Step 6)
2. Extract features for claims prediction (Step 7)
3. External ML model generates predictions (Step 8 - Python example)
4. Store claims predictions in Neo4j (Step 9)
5. Query and analyze predictions (Step 10)

### Step 6: Register Claims Prediction Model Metadata
Before storing predictions, register the ML model metadata in Neo4j for tracking and governance:

```cypher
// Register ML model metadata for tracking and governance
CREATE (claims_model:ClaimsPredictionModel {
  id: randomUUID(),
  model_id: "CLAIMS-PRED-V2.8",
  model_name: "Claims Frequency and Severity Prediction",
  model_type: "Ensemble Model - Frequency + Severity",

  // Model components (trained externally in Python)
  frequency_model: "Poisson Regression with Graph Features",
  severity_model: "Gamma GLM with Network Effects",
  ensemble_method: "Weighted Average",

  // Model performance metrics (from validation)
  frequency_accuracy: 0.74,
  severity_mae: 1250.50,  // Mean Absolute Error
  combined_accuracy: 0.71,
  validation_r_squared: 0.68,

  // Feature importance (from Python ML model)
  top_frequency_features: [
    "customer_age: 0.18",
    "claims_history: 0.22",
    "policy_type: 0.15",
    "geographic_risk: 0.12",
    "credit_score: 0.14",
    "network_effects: 0.19"
  ],

  top_severity_features: [
    "claim_type: 0.25",
    "vehicle_age: 0.18",
    "repair_network: 0.16",
    "geographic_costs: 0.14",
    "policy_limits: 0.12",
    "vendor_relationships: 0.15"
  ],

  // Training data
  training_period: "2020-01-01 to 2023-12-31",
  training_sample_size: 45000,
  holdout_sample_size: 12000,

  // Model deployment
  deployment_date: date(),
  last_retrained: date() - duration({months: 2}),
  next_retraining: date() + duration({months: 4}),

  model_status: "Production",
  monitoring_frequency: "Weekly",

  created_at: datetime(),
  created_by: "ml_engineering_team",
  version: 1
})

RETURN claims_model
```

### Step 7: Extract Features for Claims Prediction ML Model
Extract graph-based features that will be used by the external ML model:

```cypher
// Extract features for claims frequency and severity prediction
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policies:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(historical_claims:Claim)
OPTIONAL MATCH (customer)-[:LOCATED_IN]->(location:Location)

WITH customer,
     collect(policies) AS customer_policies,
     collect(historical_claims) AS past_claims,
     location,
     count(policies) AS policy_count,
     count(historical_claims) AS historical_claims_count

WITH customer, customer_policies, past_claims, location, policy_count, historical_claims_count,
     [p IN customer_policies | p.deductible] AS deductibles,
     [c IN past_claims | c.claim_amount] AS historical_claim_amounts

WITH customer, customer_policies, past_claims, location, policy_count, historical_claims_count,
     CASE WHEN size(deductibles) > 0
          THEN reduce(sum = 0.0, d IN deductibles | sum + d) / size(deductibles)
          ELSE 500.0 END AS avg_deductible,
     CASE WHEN size(historical_claim_amounts) > 0
          THEN reduce(sum = 0.0, amt IN historical_claim_amounts | sum + amt) / size(historical_claim_amounts)
          ELSE 0.0 END AS avg_historical_claim

RETURN
  customer.customer_number AS customer_id,

  // Demographic features
  duration.between(customer.date_of_birth, date()).years AS customer_age,
  duration.between(customer.created_date, date()).days AS customer_tenure,
  COALESCE(customer.credit_score, 650) AS credit_score,

  // Policy portfolio features
  policy_count AS total_policies,
  avg_deductible AS avg_policy_deductible,
  [p IN customer_policies WHERE p.policy_type IS NOT NULL | p.policy_type] AS policy_types,
  reduce(s = 0, p IN customer_policies | s + COALESCE(p.coverage_limit, 50000)) AS total_coverage_limit,

  // Historical claims features
  historical_claims_count,
  avg_historical_claim AS avg_historical_claim_amount,
  CASE WHEN size(past_claims) > 0
       THEN duration.between(
         reduce(maxDate = past_claims[0].claim_date, c IN past_claims |
           CASE WHEN c.claim_date > maxDate THEN c.claim_date ELSE maxDate END
         ), date()).days
       ELSE 9999 END AS last_claim_days_ago,

  // Geographic risk factors (graph feature!)
  COALESCE(location.risk_score, 0.5) AS location_risk_score,
  COALESCE(location.weather_risk_level, "Medium") AS weather_risk

// Note: This query returns features for ML model input
// In production, export to Python for prediction
```

### Step 8: External ML Model for Claims Prediction (Python Example)
```python
# Example: External ML model for claims frequency and severity prediction
# This runs in Python, NOT in Neo4j!

from neo4j import GraphDatabase
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
import pickle

# Connect and extract features
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))

with driver.session() as session:
    result = session.run("""
        // ... feature extraction query from Step 7 ...
    """)
    features_df = pd.DataFrame([dict(record) for record in result])

# Prepare features
X = features_df[[
    'customer_age', 'customer_tenure', 'credit_score',
    'total_policies', 'avg_policy_deductible', 'total_coverage_limit',
    'historical_claims_count', 'avg_historical_claim_amount',
    'last_claim_days_ago', 'location_risk_score'
]]

# Load pre-trained models
frequency_model = pickle.load(open('claims_frequency_model_v2.8.pkl', 'rb'))
severity_model = pickle.load(open('claims_severity_model_v2.8.pkl', 'rb'))

# Generate predictions
predicted_frequency = frequency_model.predict(X)  # Claims per year
predicted_severity = severity_model.predict(X)    # Average claim amount
predicted_annual_cost = predicted_frequency * predicted_severity

# Prepare results
results_df = pd.DataFrame({
    'customer_id': features_df['customer_id'],
    'predicted_frequency': predicted_frequency,
    'predicted_severity': predicted_severity,
    'predicted_annual_claims_cost': predicted_annual_cost,
    'frequency_confidence': 0.74,  # From model metrics
    'severity_confidence': 0.71,
    'model_version': '2.8',
    'prediction_date': pd.Timestamp.now().date()
})

# Save for loading to Neo4j
# results_df.to_csv('claims_predictions.csv', index=False)
```

### Step 9: Store ML-Generated Claims Predictions in Neo4j
Load the predictions from the external ML model into Neo4j:

```cypher
// Load ML-generated claims predictions into Neo4j
// In production: LOAD CSV or Python driver to bulk load predictions
// For this lab, we'll simulate with sample prediction values

MATCH (customer:Customer)
WITH customer, rand() AS random_value

// Simulate ML prediction results (in production, these come from Python ML models)
WITH customer,
     // Simulated frequency prediction (claims per year)
     CASE
       WHEN customer.credit_score < 600 THEN 0.8 + (random_value * 0.6)
       WHEN customer.credit_score < 700 THEN 0.4 + (random_value * 0.4)
       ELSE 0.15 + (random_value * 0.25)
     END AS predicted_frequency,
     // Simulated severity prediction (average claim amount)
     1500.0 + (random_value * 2500.0) AS predicted_severity

// Create prediction node with ML results
CREATE (claims_prediction:ClaimsPrediction {
  id: randomUUID(),
  prediction_id: "CLAIMS-" + customer.customer_number + "-" + toString(date()),
  customer_id: customer.customer_number,
  prediction_date: date(),
  prediction_horizon: "12 months",
  model_version: "2.8",

  // ML model outputs (would come from Python ML system)
  predicted_frequency: predicted_frequency,
  predicted_severity: predicted_severity,
  predicted_annual_claims_cost: predicted_frequency * predicted_severity,

  // Confidence scores (from ML model)
  frequency_confidence: 0.74 + (rand() * 0.1),
  severity_confidence: 0.71 + (rand() * 0.1),
  cost_prediction_confidence: 0.725 + (rand() * 0.1),

  // Risk categorization based on predicted cost
  cost_risk_category: CASE
    WHEN (predicted_frequency * predicted_severity) >= 4000 THEN "High Cost Risk"
    WHEN (predicted_frequency * predicted_severity) >= 2000 THEN "Medium Cost Risk"
    WHEN (predicted_frequency * predicted_severity) >= 1000 THEN "Low Cost Risk"
    ELSE "Very Low Cost Risk"
  END,

  // Metadata
  created_at: datetime(),
  created_by: "ml_prediction_system"
})

// Link prediction to customer
CREATE (customer)-[:HAS_CLAIMS_PREDICTION {
  prediction_date: date(),
  model_version: "2.8",
  created_at: datetime()
}]->(claims_prediction)

RETURN count(claims_prediction) AS claims_predictions_created
```

### Step 10: Query and Analyze Stored Claims Predictions
Query the ML predictions to analyze claims risk across the customer base:

```cypher
// Analyze claims predictions by risk category
MATCH (customer:Customer)-[:HAS_CLAIMS_PREDICTION]->(prediction:ClaimsPrediction)

RETURN
  prediction.cost_risk_category AS risk_category,
  count(*) AS customer_count,
  round(avg(prediction.predicted_frequency), 2) AS avg_predicted_frequency,
  round(avg(prediction.predicted_severity), 2) AS avg_predicted_severity,
  round(avg(prediction.predicted_annual_claims_cost), 2) AS avg_predicted_annual_cost,
  round(sum(prediction.predicted_annual_claims_cost), 2) AS total_predicted_claims_cost,
  round(avg(prediction.cost_prediction_confidence) * 100, 2) AS avg_confidence_pct

ORDER BY
  CASE risk_category
    WHEN "High Cost Risk" THEN 1
    WHEN "Medium Cost Risk" THEN 2
    WHEN "Low Cost Risk" THEN 3
    ELSE 4
  END
```

---

## Part 3: Dynamic Risk Scoring and Assessment (10 minutes)

**Purpose:** Aggregate stored ML predictions into composite risk scores for operational decision-making.

This section demonstrates how to **use** ML predictions stored in Neo4j (from Parts 1 and 2) to create composite risk assessments. We're not doing ML here - we're combining stored churn and claims predictions with business rules to create actionable risk profiles.

### Step 11: Create Composite Risk Assessment from Stored ML Predictions
Combine stored churn and claims predictions into overall customer risk scores:

```cypher
// Aggregate stored ML predictions into composite risk assessments
// This is NOT ML - it's business logic combining ML results
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HAS_CHURN_PREDICTION]->(churn:ChurnPrediction)
OPTIONAL MATCH (customer)-[:HAS_CLAIMS_PREDICTION]->(claims:ClaimsPrediction)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policies:Policy)
OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(recent_claims:Claim)
WHERE recent_claims.claim_date >= date() - duration({months: 6})

WITH customer, churn, claims,
     collect(policies) AS customer_policies,
     collect(recent_claims) AS recent_claims,

     // Calculate portfolio metrics
     count(policies) AS total_policies,
     count(recent_claims) AS recent_claims_count

WITH customer, churn, claims, customer_policies, recent_claims, total_policies, recent_claims_count,
     [p IN customer_policies | p.annual_premium] AS premiums

WITH customer, churn, claims, customer_policies, recent_claims, total_policies, recent_claims_count,
     CASE WHEN size(premiums) > 0
          THEN reduce(sum = 0.0, p IN premiums | sum + p)
          ELSE 0.0 END AS total_premium

CREATE (risk_assessment:DynamicRiskAssessment {
  id: randomUUID(),
  assessment_id: "RISK-" + customer.customer_number + "-" + toString(date()),
  customer_id: customer.customer_number,
  assessment_date: date(),
  assessment_type: "Comprehensive Risk Profile",
  
  // Source data summary
  churn_probability: COALESCE(churn.churn_probability, 0.2),
  predicted_claims_cost: COALESCE(claims.predicted_annual_claims_cost, 1500),
  portfolio_value: COALESCE(total_premium, 1200),
  recent_activity_score: recent_claims_count,
  
  // Multi-dimensional risk scores (0-100 scale)
  retention_risk_score: null,      // Will be calculated
  financial_risk_score: null,      // Will be calculated  
  operational_risk_score: null,    // Will be calculated
  
  // Composite risk assessment
  overall_risk_score: null,        // Will be calculated
  risk_category: null,             // Will be determined
  
  // Risk factors breakdown
  primary_risk_factors: [],        // Will be populated
  risk_mitigation_recommendations: [],  // Will be populated
  
  // Confidence and data quality
  assessment_confidence: null,     // Will be calculated
  data_completeness_score: null,   // Will be calculated
  
  // Monitoring frequency
  next_assessment_date: null,      // Will be set based on risk level
  monitoring_frequency: null       // Will be determined
})

// Calculate retention risk score (0-100, higher = more risk)
SET risk_assessment.retention_risk_score = 
  ROUND(COALESCE(churn.churn_probability, 0.2) * 100)

// Calculate financial risk score based on claims prediction and portfolio
SET risk_assessment.financial_risk_score = 
  ROUND(
    // Claims cost impact (30% weight)
    (CASE WHEN claims.predicted_annual_claims_cost >= 5000 THEN 90
          WHEN claims.predicted_annual_claims_cost >= 3000 THEN 70
          WHEN claims.predicted_annual_claims_cost >= 2000 THEN 50
          WHEN claims.predicted_annual_claims_cost >= 1000 THEN 30
          ELSE 15 END) * 0.3 +
          
    // Portfolio concentration risk (25% weight)  
    (CASE WHEN total_policies = 1 THEN 75
          WHEN total_policies = 2 THEN 45
          WHEN total_policies >= 3 THEN 20
          ELSE 60 END) * 0.25 +
          
    // Premium level stability (25% weight)
    (CASE WHEN total_premium >= 5000 THEN 15
          WHEN total_premium >= 2500 THEN 25
          WHEN total_premium >= 1500 THEN 35
          WHEN total_premium >= 800 THEN 55
          ELSE 80 END) * 0.25 +
          
    // Credit risk component (20% weight)
    (CASE WHEN customer.credit_score >= 750 THEN 10
          WHEN customer.credit_score >= 650 THEN 25
          WHEN customer.credit_score >= 550 THEN 50
          ELSE 75 END) * 0.2
  )

// Calculate operational risk score  
SET risk_assessment.operational_risk_score = 
  ROUND(
    // Recent claims activity (40% weight)
    (CASE WHEN recent_claims_count >= 3 THEN 85
          WHEN recent_claims_count = 2 THEN 60
          WHEN recent_claims_count = 1 THEN 35
          ELSE 15 END) * 0.4 +
          
    // Customer service complexity (30% weight) 
    (CASE WHEN total_policies >= 4 THEN 65  // More policies = more complexity
          WHEN total_policies = 3 THEN 45
          WHEN total_policies = 2 THEN 25
          ELSE 20 END) * 0.3 +
          
    // Payment behavior (30% weight)
    (CASE WHEN churn.payment_consistency IS NOT NULL AND churn.payment_consistency < 0.8 THEN 70
          WHEN churn.payment_consistency IS NOT NULL AND churn.payment_consistency < 0.9 THEN 40
          WHEN churn.payment_consistency IS NOT NULL THEN 20
          ELSE 35 END) * 0.3
  )

// Calculate overall risk score (weighted average)
SET risk_assessment.overall_risk_score = 
  ROUND(
    risk_assessment.retention_risk_score * 0.35 +      // Retention most critical
    risk_assessment.financial_risk_score * 0.40 +      // Financial impact high priority  
    risk_assessment.operational_risk_score * 0.25      // Operational efficiency important
  )

// Determine risk category
SET risk_assessment.risk_category = 
  CASE WHEN risk_assessment.overall_risk_score >= 75 THEN "Very High Risk"
       WHEN risk_assessment.overall_risk_score >= 60 THEN "High Risk"
       WHEN risk_assessment.overall_risk_score >= 40 THEN "Medium Risk"
       WHEN risk_assessment.overall_risk_score >= 25 THEN "Low Risk"
       ELSE "Very Low Risk" END

// Identify primary risk factors
SET risk_assessment.primary_risk_factors = 
  [factor IN [
    CASE WHEN risk_assessment.retention_risk_score >= 60 THEN "High Churn Probability" ELSE null END,
    CASE WHEN risk_assessment.financial_risk_score >= 65 THEN "Elevated Claims Risk" ELSE null END,
    CASE WHEN risk_assessment.operational_risk_score >= 60 THEN "Complex Service Requirements" ELSE null END,
    CASE WHEN customer.credit_score < 600 THEN "Credit Risk Concerns" ELSE null END,
    CASE WHEN total_policies = 1 THEN "Portfolio Concentration" ELSE null END,
    CASE WHEN recent_claims_count >= 2 THEN "Recent Claims Activity" ELSE null END
  ] WHERE factor IS NOT NULL]

// Generate risk mitigation recommendations
SET risk_assessment.risk_mitigation_recommendations = 
  CASE risk_assessment.risk_category
    WHEN "Very High Risk" THEN [
      "Immediate account manager assignment",
      "Quarterly business reviews", 
      "Proactive claims management",
      "Premium restructuring consultation",
      "Executive relationship management"
    ]
    WHEN "High Risk" THEN [
      "Enhanced monitoring protocols",
      "Bi-annual policy reviews",
      "Payment plan options", 
      "Claims prevention programs",
      "Loyalty incentive programs"
    ]
    WHEN "Medium Risk" THEN [
      "Regular policy optimization reviews",
      "Cross-sell opportunity assessment",
      "Annual satisfaction surveys",
      "Risk management consultations"
    ]
    ELSE [
      "Standard monitoring protocols",
      "Annual policy reviews",
      "Customer appreciation programs"
    ]
  END

// Calculate assessment confidence based on data availability
SET risk_assessment.data_completeness_score = 
  (CASE WHEN churn IS NOT NULL THEN 25 ELSE 0 END +
   CASE WHEN claims IS NOT NULL THEN 25 ELSE 0 END +
   CASE WHEN total_policies > 0 THEN 25 ELSE 0 END +
   CASE WHEN customer.credit_score IS NOT NULL THEN 25 ELSE 0 END)

SET risk_assessment.assessment_confidence = 
  CASE WHEN risk_assessment.data_completeness_score >= 75 THEN 0.88
       WHEN risk_assessment.data_completeness_score >= 50 THEN 0.75
       ELSE 0.62 END

// Set monitoring frequency based on risk level
SET risk_assessment.monitoring_frequency = 
  CASE risk_assessment.risk_category
    WHEN "Very High Risk" THEN "Weekly"
    WHEN "High Risk" THEN "Bi-weekly" 
    WHEN "Medium Risk" THEN "Monthly"
    ELSE "Quarterly" END

SET risk_assessment.next_assessment_date = 
  CASE risk_assessment.monitoring_frequency
    WHEN "Weekly" THEN date() + duration({weeks: 1})
    WHEN "Bi-weekly" THEN date() + duration({weeks: 2})
    WHEN "Monthly" THEN date() + duration({months: 1})
    ELSE date() + duration({months: 3}) END

// Connect risk assessment to customer
CREATE (customer)-[:HAS_RISK_ASSESSMENT {
  assessment_date: date(),
  assessment_type: "Dynamic Risk Profile",
  created_at: datetime()
}]->(risk_assessment)

RETURN count(risk_assessment) AS risk_assessments_created
```

---

## Part 4: ML Performance Monitoring and Model Operations (8 minutes)

**Purpose:** Monitor ML model performance and track business impact of predictions.

This section shows how to create monitoring infrastructure for ML systems integrated with Neo4j. These queries track model performance, data quality, and business outcomes.

### Step 12: Create ML Performance Dashboard
```cypher
// Create comprehensive ML performance monitoring dashboard
CREATE (ml_dashboard:MLPerformanceDashboard {
  id: randomUUID(),
  dashboard_id: "ML-DASH-" + toString(date()),
  dashboard_name: "Predictive Analytics Performance Monitor",
  reporting_date: date(),
  reporting_period: "Current Quarter",
  
  // Model inventory
  active_models: [
    "Churn Prediction v3.2",
    "Claims Prediction v2.8", 
    "Dynamic Risk Assessment v1.5"
  ],

  // Churn model performance - stored as JSON string for nested data
  churn_model_metrics_json: '{"total_predictions":1250,"high_risk_customers":87,"medium_risk_customers":234,"retention_interventions_triggered":187,"successful_retentions":127,"prevention_success_rate":0.68,"model_accuracy_last_month":0.81,"false_positive_rate":0.12,"business_value_generated":1250000.00}',

  // Flattened churn model properties
  churn_total_predictions: 1250,
  churn_high_risk_customers: 87,
  churn_medium_risk_customers: 234,
  churn_retention_interventions_triggered: 187,
  churn_successful_retentions: 127,
  churn_prevention_success_rate: 0.68,
  churn_model_accuracy_last_month: 0.81,
  churn_false_positive_rate: 0.12,
  churn_business_value_generated: 1250000.00,

  // Claims model performance - stored as JSON string for nested data
  claims_model_metrics_json: '{"total_predictions":1425,"high_cost_risk_customers":156,"average_prediction_accuracy":0.74,"cost_prediction_mae":485.30,"frequency_prediction_accuracy":0.78,"severity_prediction_accuracy":0.71,"early_intervention_savings":890000.00}',

  // Flattened claims model properties
  claims_total_predictions: 1425,
  claims_high_cost_risk_customers: 156,
  claims_average_prediction_accuracy: 0.74,
  claims_cost_prediction_mae: 485.30,
  claims_frequency_prediction_accuracy: 0.78,
  claims_severity_prediction_accuracy: 0.71,
  claims_early_intervention_savings: 890000.00,

  // Risk assessment performance - stored as JSON string for nested data
  risk_model_metrics_json: '{"total_assessments":1350,"very_high_risk_customers":45,"high_risk_customers":123,"assessment_confidence_avg":0.79,"data_completeness_avg":0.81,"manual_review_accuracy":0.85,"risk_mitigation_effectiveness":0.73}',

  // Flattened risk model properties
  risk_total_assessments: 1350,
  risk_very_high_risk_customers: 45,
  risk_high_risk_customers: 123,
  risk_assessment_confidence_avg: 0.79,
  risk_data_completeness_avg: 0.81,
  risk_manual_review_accuracy: 0.85,
  risk_mitigation_effectiveness: 0.73,

  // Overall system performance - stored as JSON string for nested data
  system_performance_json: '{"total_customers_scored":1350,"models_in_production":3,"average_prediction_latency_ms":23,"system_uptime_percentage":99.8,"data_quality_score":94.2,"feature_drift_alerts":2,"model_retraining_needed":1}',

  // Flattened system performance properties
  system_total_customers_scored: 1350,
  system_models_in_production: 3,
  system_average_prediction_latency_ms: 23,
  system_uptime_percentage: 99.8,
  system_data_quality_score: 94.2,
  system_feature_drift_alerts: 2,
  system_model_retraining_needed: 1,
  
  // Business impact metrics - stored as JSON string for nested data
  business_impact_json: '{"estimated_annual_churn_prevention":1250000.00,"claims_cost_optimization":890000.00,"operational_efficiency_gains":675000.00,"customer_satisfaction_improvement":0.15,"total_roi_estimate":2815000.00,"cost_of_ml_operations":485000.00,"net_business_value":2330000.00}',

  // Flattened business impact properties
  estimated_annual_churn_prevention: 1250000.00,
  claims_cost_optimization: 890000.00,
  operational_efficiency_gains: 675000.00,
  customer_satisfaction_improvement: 0.15,
  total_roi_estimate: 2815000.00,
  cost_of_ml_operations: 485000.00,
  net_business_value: 2330000.00,

  // Data quality monitoring - stored as JSON string for nested data
  data_quality_metrics_json: '{"customer_data_completeness":0.92,"policy_data_completeness":0.89,"claims_data_completeness":0.85,"payment_data_completeness":0.91,"missing_critical_features":67,"data_freshness_hours":4.2,"data_validation_errors":12}',

  // Flattened data quality properties
  dq_customer_data_completeness: 0.92,
  dq_policy_data_completeness: 0.89,
  dq_claims_data_completeness: 0.85,
  dq_payment_data_completeness: 0.91,
  dq_missing_critical_features: 67,
  dq_data_freshness_hours: 4.2,
  dq_data_validation_errors: 12,

  // Model drift monitoring - stored as JSON string for nested data
  model_drift_indicators_json: '{"churn_model_drift_score":0.08,"claims_model_drift_score":0.15,"risk_model_drift_score":0.05,"concept_drift_detected":false,"population_drift_detected":true,"feature_importance_changes":["credit_score: +0.03","claims_history: -0.02"]}',

  // Flattened model drift properties
  drift_churn_model_score: 0.08,
  drift_claims_model_score: 0.15,
  drift_risk_model_score: 0.05,
  drift_concept_drift_detected: false,
  drift_population_drift_detected: true,
  drift_feature_importance_changes: ["credit_score: +0.03", "claims_history: -0.02"],
  
  // Recommendations
  operational_recommendations: [
    "Retrain claims prediction model within 30 days",
    "Investigate population drift in customer demographics",
    "Improve payment data collection completeness",
    "Scale churn prevention team based on success metrics",
    "Implement automated model monitoring alerts"
  ],
  
  // Next actions
  next_model_review_date: date() + duration({weeks: 2}),
  scheduled_retraining: ["Claims Prediction Model"],
  performance_review_frequency: "Weekly",
  
  created_at: datetime(),
  created_by: "ml_ops_team",
  version: 1
})

RETURN ml_dashboard
```

### Step 13: Create Model Validation and Testing Framework
```cypher
// Create comprehensive model validation system
CREATE (model_validation:ModelValidation {
  id: randomUUID(),
  validation_id: "VAL-" + toString(date()),
  validation_date: date(),
  validation_type: "Quarterly Model Review",
  
  // Models under validation
  models_validated: [
    "Churn Prediction v3.2",
    "Claims Prediction v2.8",
    "Dynamic Risk Assessment v1.5"
  ],
  
  // Validation methodology
  validation_approach: "Hold-out testing with temporal validation",
  test_data_period: "Q1 2024",
  test_sample_size: 15000,
  validation_metrics: [
    "Accuracy", "Precision", "Recall", "F1-Score", 
    "AUC-ROC", "Business Impact", "Fairness Metrics"
  ],

  // Churn model validation results - stored as JSON string for nested data
  churn_validation_results_json: '{"test_accuracy":0.82,"precision":0.79,"recall":0.84,"f1_score":0.81,"auc_roc":0.86,"business_impact_validation":"Successful - 68% retention rate achieved","fairness_score":0.91,"bias_detected":false,"validation_status":"Passed"}',

  // Flattened churn validation properties
  churn_val_test_accuracy: 0.82,
  churn_val_precision: 0.79,
  churn_val_recall: 0.84,
  churn_val_f1_score: 0.81,
  churn_val_auc_roc: 0.86,
  churn_val_business_impact_validation: "Successful - 68% retention rate achieved",
  churn_val_fairness_score: 0.91,
  churn_val_bias_detected: false,
  churn_val_validation_status: "Passed",

  // Claims model validation results - stored as JSON string for nested data
  claims_validation_results_json: '{"frequency_mae":0.28,"severity_mape":0.15,"combined_accuracy":0.74,"business_impact_validation":"Good - Cost predictions within 12% of actual","early_warning_effectiveness":0.71,"validation_status":"Passed with recommendations"}',

  // Flattened claims validation properties
  claims_val_frequency_mae: 0.28,
  claims_val_severity_mape: 0.15,
  claims_val_combined_accuracy: 0.74,
  claims_val_business_impact_validation: "Good - Cost predictions within 12% of actual",
  claims_val_early_warning_effectiveness: 0.71,
  claims_val_validation_status: "Passed with recommendations",

  // Risk model validation results - stored as JSON string for nested data
  risk_validation_results_json: '{"risk_classification_accuracy":0.77,"human_expert_agreement":0.83,"recommendation_effectiveness":0.69,"customer_outcome_correlation":0.74,"validation_status":"Passed"}',

  // Flattened risk validation properties
  risk_val_risk_classification_accuracy: 0.77,
  risk_val_human_expert_agreement: 0.83,
  risk_val_recommendation_effectiveness: 0.69,
  risk_val_customer_outcome_correlation: 0.74,
  risk_val_validation_status: "Passed",
  
  // Overall validation summary
  overall_validation_score: 0.81,
  validation_conclusion: "All models meet production standards",
  critical_issues_found: 0,
  recommendations_count: 8,
  
  // Specific recommendations
  model_recommendations: [
    "Churn Model: Explore additional network features for improved accuracy",
    "Claims Model: Investigate seasonal adjustments for severity predictions", 
    "Risk Model: Enhance real-time data integration for operational scores",
    "All Models: Implement automated bias monitoring and alerts",
    "Infrastructure: Upgrade prediction serving infrastructure for lower latency"
  ],
  
  // Business validation - stored as JSON string for nested data
  business_validation_json: '{"customer_outcome_improvement":true,"cost_reduction_achieved":true,"revenue_impact_positive":true,"operational_efficiency_gained":true,"customer_satisfaction_maintained":true,"regulatory_compliance_status":"Compliant"}',

  // Flattened business validation properties
  customer_outcome_improvement: true,
  cost_reduction_achieved: true,
  revenue_impact_positive: true,
  operational_efficiency_gained: true,
  customer_satisfaction_maintained: true,
  regulatory_compliance_status: "Compliant",

  // Technical validation - stored as JSON string for nested data
  technical_validation_json: '{"model_stability":"Stable","performance_consistency":"Good","data_dependency_health":"Healthy","infrastructure_performance":"Excellent","monitoring_effectiveness":"Good","alert_system_functioning":true}',

  // Flattened technical validation properties
  tech_val_model_stability: "Stable",
  tech_val_performance_consistency: "Good",
  tech_val_data_dependency_health: "Healthy",
  tech_val_infrastructure_performance: "Excellent",
  tech_val_monitoring_effectiveness: "Good",
  tech_val_alert_system_functioning: true,
  
  // Future improvements identified
  improvement_roadmap: [
    "Implement ensemble methods for churn prediction",
    "Add real-time feature engineering pipeline",
    "Develop causal inference models for claims prediction",
    "Explore ensemble methods for churn prediction",
    "Implement automated model monitoring"
  ],
  
  // Next validation schedule
  next_validation_date: date() + duration({months: 3}),
  validation_frequency: "Quarterly",
  
  validated_by: "Model Validation Team",
  approved_by: "Chief Data Officer",
  
  created_at: datetime(),
  created_by: "model_validation_system",
  version: 1
})

RETURN model_validation
```

### Step 14: Create ML Model Performance Summary
```cypher
// Create comprehensive ML performance summary
CREATE (ml_summary:MLPerformanceSummary {
  id: randomUUID(),
  summary_id: "ML-SUM-" + toString(date()),
  summary_date: date(),
  reporting_period: "Current Quarter",
  
  // Model deployment summary
  models_in_production: 3,
  models_in_development: 2,
  models_retired: 1,
  total_predictions_generated: 145000,
  
  // Business value generated
  estimated_annual_value: 3750000.00,
  cost_savings_realized: 2100000.00,
  revenue_optimization: 1250000.00,
  efficiency_improvements: 400000.00,
  
  // Technical performance
  average_model_accuracy: 0.81,
  average_prediction_latency: "23ms",
  system_uptime: 0.998,
  data_processing_efficiency: 0.94,
  
  // Customer impact
  customers_with_churn_predictions: 1250,
  churn_prevention_interventions: 187,
  successful_retentions: 127,
  claims_predictions_generated: 1425,
  risk_scores_updated: 1350,
  
  // Model health indicators
  models_requiring_retraining: 1,
  data_quality_score: 94.2,
  feature_drift_alerts: 2,
  performance_degradation_alerts: 1,
  
  // Future roadmap
  upcoming_model_deployments: [
    "Premium Optimization Model v1.0",
    "Customer Lifetime Value Prediction v2.1",
    "Fraud Detection Enhancement v3.0"
  ],
  
  planned_improvements: [
    "Real-time model updating",
    "Advanced ensemble methods",
    "Automated feature engineering",
    "Causal inference integration"
  ],
  
  // Resource requirements
  current_ml_team_size: 8,
  recommended_team_expansion: 2,
  infrastructure_investment_needed: 250000.00,
  training_budget_required: 75000.00,
  
  summary_prepared_by: "ML Operations Team",
  summary_approved_by: "VP of Analytics",
  
  created_at: datetime(),
  created_by: "ml_summary_system",
  version: 1
})

WITH ml_summary

// Validate the complete predictive analytics infrastructure
MATCH (churn:ChurnPrediction)
MATCH (claims:ClaimsPrediction)
MATCH (risk:DynamicRiskAssessment)
MATCH (dashboard:MLPerformanceDashboard)
MATCH (validation:ModelValidation)

RETURN "Predictive Analytics System Validation" AS status,
       count(DISTINCT churn) AS churn_predictions,
       count(DISTINCT claims) AS claims_predictions,
       count(DISTINCT risk) AS risk_assessments,
       count(DISTINCT dashboard) AS performance_dashboards,
       count(DISTINCT validation) AS validation_reports,
       "Advanced ML Infrastructure Ready" AS system_status
```

---

## Neo4j Lab 10 Summary

**🎯 What You've Accomplished:**

### **Understanding the Neo4j + ML Workflow**
- ✅ **Learned the complete ML integration pattern**: Extract features → Train/predict externally → Store results → Query for decisions
- ✅ **Mastered feature extraction** using Cypher to prepare graph-enhanced features for ML models
- ✅ **Understood the separation of concerns**: Neo4j for data, Python/sklearn for ML, Neo4j for operational queries
- ✅ **Simulated production ML pipelines** showing how real-world systems integrate Neo4j with ML frameworks

### **Churn Prediction Integration (Part 1)**
- ✅ **Extracted graph features** including network centrality, referral activity, and customer behavior
- ✅ **Stored ML predictions** from external churn models in Neo4j for operational use
- ✅ **Created retention plans** based on ML-generated risk scores
- ✅ **Queried prediction results** to analyze churn risk across customer segments

### **Claims Prediction Integration (Part 2)**
- ✅ **Registered ML model metadata** for tracking frequency and severity prediction models
- ✅ **Extracted features** combining historical claims, geography, and policy portfolio data
- ✅ **Stored claims forecasts** generated by external ML models (frequency × severity)
- ✅ **Analyzed cost predictions** by risk category for portfolio management

### **Composite Risk Scoring (Part 3)**
- ✅ **Aggregated stored ML predictions** from churn and claims models
- ✅ **Created composite risk assessments** combining multiple ML outputs with business rules
- ✅ **Generated actionable recommendations** for account management and intervention
- ✅ **Demonstrated Neo4j's role** in integrating multiple ML prediction sources

### **ML Monitoring and Governance (Part 4)**
- ✅ **Built performance dashboards** tracking model accuracy, business impact, and data quality
- ✅ **Created validation frameworks** ensuring ML predictions remain reliable over time
- ✅ **Monitored prediction usage** in operational systems and business processes
- ✅ **Tracked business value** generated by ML-driven decisions

### **Key Technical Skills Acquired**
- ✅ **Feature engineering with Cypher** - extracting graph features for ML models
- ✅ **Prediction storage patterns** - loading ML results efficiently into Neo4j
- ✅ **Operational querying** - using stored predictions for real-time decisions
- ✅ **ML metadata management** - tracking models, versions, and performance in Neo4j

### **Database State:** 600 nodes, 750 relationships with ML prediction nodes

### **Production ML Integration Patterns Learned**
- ✅ **Extract** - Cypher queries export graph features for ML training/prediction
- ✅ **Train/Predict** - Python ML frameworks (sklearn, TensorFlow) generate predictions
- ✅ **Load** - Predictions stored in Neo4j via CSV/driver for operational use
- ✅ **Query** - Cypher analyzes predictions for business decisions and interventions
- ✅ **Monitor** - Track model performance and business impact over time

---

## Next Steps

You're now ready for **Session 3 - Lab 7: Python Integration & Service Architecture**, where you'll:
- Build Python applications with Neo4j driver integration and proper architecture patterns
- Implement service layers with error handling and data mapping for insurance operations
- Create automated testing frameworks for graph operations and business logic
- Design scalable application architectures with dependency injection and clean patterns
- **Database Evolution:** 600 nodes → 650 nodes, 750 relationships → 800 relationships

**Congratulations!** You've successfully learned how to integrate Neo4j with external machine learning systems! You now understand how to extract graph-enhanced features from Neo4j, how external ML models generate predictions using those features, how to store ML results back in Neo4j, and how to query predictions for operational business decisions. This complete workflow reflects real-world production ML systems where Neo4j provides rich graph features and serves as the operational data store for ML predictions.

## Troubleshooting

### If prediction scores seem inconsistent:
- Verify all input features exist: `MATCH (c:Customer)-[:HAS_PROFILE]->(p) RETURN count(p)`
- Check for NULL values affecting calculations: Use COALESCE for all optional fields
- Validate date calculations and tenure computations

### If model performance appears degraded:
- Review feature distributions: `MATCH (c:Customer) RETURN avg(c.credit_score), min(c.credit_score), max(c.credit_score)`
- Check data quality metrics and completeness rates
- Verify business rule logic matches current operational definitions

### If predictions aren't generating expected business value:
- Review threshold calibration for risk classifications
- Validate action recommendations align with business capabilities
- Check intervention success tracking and feedback loops