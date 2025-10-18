// Neo4j Lab 11 - Data Reload Script
// Complete data setup for Lab 11: Predictive Analytics & Machine Learning
// Run this script if you need to reload the Lab 11 data state
// Includes Labs 1-10 data + Predictive Analytics Infrastructure

// ===================================
// STEP 1: LOAD LAB 10 FOUNDATION
// ===================================
// This builds on Lab 10 - ensure you have the foundation

// Import Lab 10 data first (this is a prerequisite)
// The lab_10_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: PREDICTIVE ANALYTICS ENTITIES
// ===================================

// Create ML Models
MERGE (ml1:MLModel {model_id: "ML-CHURN-001"})
ON CREATE SET ml1.model_name = "Customer Churn Prediction Model",
    ml1.model_type = "Classification",
    ml1.algorithm = "Random Forest",
    ml1.training_date = date("2024-01-15"),
    ml1.model_version = "1.2.0",
    ml1.accuracy_score = 0.87,
    ml1.precision_score = 0.84,
    ml1.recall_score = 0.89,
    ml1.f1_score = 0.865,
    ml1.training_samples = 15000,
    ml1.feature_count = 24,
    ml1.model_status = "Production",
    ml1.deployed_date = date("2024-02-01"),
    ml1.created_by = "Data Science Team",
    ml1.created_at = datetime()

MERGE (ml2:MLModel {model_id: "ML-LTV-001"})
ON CREATE SET ml2.model_name = "Customer Lifetime Value Prediction",
    ml2.model_type = "Regression",
    ml2.algorithm = "Gradient Boosting",
    ml2.training_date = date("2024-02-01"),
    ml2.model_version = "2.0.1",
    ml2.accuracy_score = 0.82,
    ml2.r2_score = 0.79,
    ml2.mae = 245.50,
    ml2.rmse = 312.75,
    ml2.training_samples = 12000,
    ml2.feature_count = 18,
    ml2.model_status = "Production",
    ml2.deployed_date = date("2024-02-15"),
    ml2.created_by = "Analytics Team",
    ml2.created_at = datetime()

MERGE (ml3:MLModel {model_id: "ML-FRAUD-001"})
ON CREATE SET ml3.model_name = "Fraud Detection Neural Network",
    ml3.model_type = "Deep Learning",
    ml3.algorithm = "Neural Network (LSTM)",
    ml3.training_date = date("2024-03-01"),
    ml3.model_version = "1.0.0",
    ml3.accuracy_score = 0.94,
    ml3.precision_score = 0.91,
    ml3.recall_score = 0.96,
    ml3.f1_score = 0.935,
    ml3.training_samples = 25000,
    ml3.feature_count = 32,
    ml3.model_status = "Testing",
    ml3.deployed_date = null,
    ml3.created_by = "ML Engineering Team",
    ml3.created_at = datetime();

// Create Predictive Scores
MERGE (ps1:PredictiveScore {score_id: "PS-2024-001"})
ON CREATE SET ps1.customer_id = "CUST-001234",
    ps1.score_type = "Churn Risk",
    ps1.score_value = 0.72,
    ps1.score_category = "High Risk",
    ps1.model_id = "ML-CHURN-001",
    ps1.prediction_date = date("2024-03-15"),
    ps1.confidence_level = 0.85,
    ps1.contributing_factors = ["Low engagement", "Missed payments", "Competitor contact"],
    ps1.recommended_actions = ["Retention offer", "Account review", "Personalized outreach"],
    ps1.created_at = datetime()

MERGE (ps2:PredictiveScore {score_id: "PS-2024-002"})
ON CREATE SET ps2.customer_id = "CUST-001235",
    ps2.score_type = "Lifetime Value",
    ps2.score_value = 45000.00,
    ps2.score_category = "High Value",
    ps2.model_id = "ML-LTV-001",
    ps2.prediction_date = date("2024-03-15"),
    ps2.confidence_level = 0.79,
    ps2.contributing_factors = ["Multiple policies", "Long tenure", "High premium"],
    ps2.recommended_actions = ["VIP program enrollment", "Cross-sell opportunities", "Premium retention"],
    ps2.created_at = datetime()

MERGE (ps3:PredictiveScore {score_id: "PS-2024-003"})
ON CREATE SET ps3.customer_id = "CUST-001236",
    ps3.score_type = "Fraud Risk",
    ps3.score_value = 0.15,
    ps3.score_category = "Low Risk",
    ps3.model_id = "ML-FRAUD-001",
    ps3.prediction_date = date("2024-03-15"),
    ps3.confidence_level = 0.92,
    ps3.contributing_factors = ["Consistent behavior", "Verified identity", "Clean history"],
    ps3.recommended_actions = ["Standard processing"],
    ps3.created_at = datetime();

// Create Behavioral Segments
MERGE (bs1:BehavioralSegment {segment_id: "SEG-DIGITAL-001"})
ON CREATE SET bs1.segment_name = "Digital Natives",
    bs1.segment_type = "Channel Preference",
    bs1.segment_description = "Customers who primarily use digital channels",
    bs1.customer_count = 2500,
    bs1.avg_lifetime_value = 35000.00,
    bs1.avg_engagement_score = 0.78,
    bs1.defining_characteristics = ["Mobile app usage", "Online policy management", "Digital payment"],
    bs1.marketing_preferences = ["Email", "SMS", "App notifications"],
    bs1.created_date = date("2024-01-01"),
    bs1.last_updated = date("2024-03-15"),
    bs1.created_at = datetime()

MERGE (bs2:BehavioralSegment {segment_id: "SEG-TRADITIONAL-001"})
ON CREATE SET bs2.segment_name = "Traditional Customers",
    bs2.segment_type = "Channel Preference",
    bs2.segment_description = "Customers who prefer traditional service channels",
    bs2.customer_count = 1800,
    bs2.avg_lifetime_value = 42000.00,
    bs2.avg_engagement_score = 0.65,
    bs2.defining_characteristics = ["Phone contact", "Branch visits", "Mail correspondence"],
    bs2.marketing_preferences = ["Direct mail", "Phone calls", "In-person meetings"],
    bs2.created_date = date("2024-01-01"),
    bs2.last_updated = date("2024-03-15"),
    bs2.created_at = datetime()

MERGE (bs3:BehavioralSegment {segment_id: "SEG-HIGH-RISK-001"})
ON CREATE SET bs3.segment_name = "High Risk Customers",
    bs3.segment_type = "Risk Profile",
    bs3.segment_description = "Customers with elevated risk profiles",
    bs3.customer_count = 450,
    bs3.avg_lifetime_value = 28000.00,
    bs3.avg_engagement_score = 0.45,
    bs3.defining_characteristics = ["Late payments", "Frequent claims", "Coverage gaps"],
    bs3.marketing_preferences = ["Account management", "Risk counseling"],
    bs3.created_date = date("2024-02-01"),
    bs3.last_updated = date("2024-03-15"),
    bs3.created_at = datetime();

// Create Marketing Campaigns
MERGE (mc1:MarketingCampaign {campaign_id: "CAMP-2024-Q1-RETENTION"})
ON CREATE SET mc1.campaign_name = "Q1 Customer Retention Drive",
    mc1.campaign_type = "Retention",
    mc1.campaign_status = "Active",
    mc1.start_date = date("2024-03-01"),
    mc1.end_date = date("2024-04-30"),
    mc1.target_segment = "High Churn Risk",
    mc1.budget = 50000.00,
    mc1.targeted_customers = 850,
    mc1.reached_customers = 720,
    mc1.converted_customers = 245,
    mc1.conversion_rate = 0.34,
    mc1.roi = 2.4,
    mc1.campaign_channel = ["Email", "Phone", "Direct Mail"],
    mc1.offer_description = "Premium discount for policy renewal",
    mc1.created_at = datetime()

MERGE (mc2:MarketingCampaign {campaign_id: "CAMP-2024-Q1-UPSELL"})
ON CREATE SET mc2.campaign_name = "Premium Policy Upgrade Campaign",
    mc2.campaign_type = "Upsell",
    mc2.campaign_status = "Active",
    mc2.start_date = date("2024-03-15"),
    mc2.end_date = date("2024-05-15"),
    mc2.target_segment = "High Lifetime Value",
    mc2.budget = 35000.00,
    mc2.targeted_customers = 500,
    mc2.reached_customers = 450,
    mc2.converted_customers = 125,
    mc2.conversion_rate = 0.278,
    mc2.roi = 3.2,
    mc2.campaign_channel = ["Email", "Account Manager"],
    mc2.offer_description = "Enhanced coverage package with additional benefits",
    mc2.created_at = datetime()

MERGE (mc3:MarketingCampaign {campaign_id: "CAMP-2024-Q2-DIGITAL"})
ON CREATE SET mc3.campaign_name = "Digital Channel Migration",
    mc3.campaign_type = "Engagement",
    mc3.campaign_status = "Planned",
    mc3.start_date = date("2024-04-01"),
    mc3.end_date = date("2024-06-30"),
    mc3.target_segment = "Traditional Customers",
    mc3.budget = 25000.00,
    mc3.targeted_customers = 600,
    mc3.reached_customers = 0,
    mc3.converted_customers = 0,
    mc3.conversion_rate = null,
    mc3.roi = null,
    mc3.campaign_channel = ["Direct Mail", "Email", "SMS"],
    mc3.offer_description = "Incentives for mobile app adoption",
    mc3.created_at = datetime();

// Create Feature Importance Records
MERGE (fi1:FeatureImportance {feature_id: "FEAT-CHURN-001"})
ON CREATE SET fi1.model_id = "ML-CHURN-001",
    fi1.feature_name = "days_since_last_payment",
    fi1.importance_score = 0.24,
    fi1.importance_rank = 1,
    fi1.feature_type = "Numeric",
    fi1.description = "Number of days since customer made last payment",
    fi1.created_at = datetime()

MERGE (fi2:FeatureImportance {feature_id: "FEAT-CHURN-002"})
ON CREATE SET fi2.model_id = "ML-CHURN-001",
    fi2.feature_name = "customer_tenure_years",
    fi2.importance_score = 0.19,
    fi2.importance_rank = 2,
    fi2.feature_type = "Numeric",
    fi2.description = "Number of years customer has been with company",
    fi2.created_at = datetime()

MERGE (fi3:FeatureImportance {feature_id: "FEAT-CHURN-003"})
ON CREATE SET fi3.model_id = "ML-CHURN-001",
    fi3.feature_name = "engagement_score",
    fi3.importance_score = 0.17,
    fi3.importance_rank = 3,
    fi3.feature_type = "Numeric",
    fi3.description = "Overall customer engagement score (0-1)",
    fi3.created_at = datetime();

// ===================================
// STEP 3: PREDICTIVE ANALYTICS RELATIONSHIPS
// ===================================

// Link Predictive Scores to Customers
MATCH (ps:PredictiveScore {score_id: "PS-2024-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:HAS_SCORE]->(ps)
ON CREATE SET r.score_date = ps.prediction_date,
    r.is_current = true

MATCH (ps:PredictiveScore {score_id: "PS-2024-002"})
MATCH (c:Customer {customer_number: "CUST-001235"})
MERGE (c)-[r:HAS_SCORE]->(ps)
ON CREATE SET r.score_date = ps.prediction_date,
    r.is_current = true;

// Link Predictive Scores to ML Models
MATCH (ps:PredictiveScore {score_id: "PS-2024-001"})
MATCH (ml:MLModel {model_id: "ML-CHURN-001"})
MERGE (ps)-[r:GENERATED_BY]->(ml)
ON CREATE SET r.model_version = ml.model_version,
    r.prediction_timestamp = ps.created_at

MATCH (ps:PredictiveScore {score_id: "PS-2024-002"})
MATCH (ml:MLModel {model_id: "ML-LTV-001"})
MERGE (ps)-[r:GENERATED_BY]->(ml)
ON CREATE SET r.model_version = ml.model_version,
    r.prediction_timestamp = ps.created_at

MATCH (ps:PredictiveScore {score_id: "PS-2024-003"})
MATCH (ml:MLModel {model_id: "ML-FRAUD-001"})
MERGE (ps)-[r:GENERATED_BY]->(ml)
ON CREATE SET r.model_version = ml.model_version,
    r.prediction_timestamp = ps.created_at;

// Link Customers to Behavioral Segments
MATCH (c:Customer {customer_number: "CUST-001234"})
MATCH (bs:BehavioralSegment {segment_id: "SEG-DIGITAL-001"})
MERGE (c)-[r:BELONGS_TO_SEGMENT]->(bs)
ON CREATE SET r.assignment_date = date("2024-01-15"),
    r.confidence_score = 0.89,
    r.segment_fit = "Strong"

MATCH (c:Customer {customer_number: "CUST-001234"})
MATCH (bs:BehavioralSegment {segment_id: "SEG-HIGH-RISK-001"})
MERGE (c)-[r:BELONGS_TO_SEGMENT]->(bs)
ON CREATE SET r.assignment_date = date("2024-02-01"),
    r.confidence_score = 0.76,
    r.segment_fit = "Moderate"

MATCH (c:Customer {customer_number: "CUST-001235"})
MATCH (bs:BehavioralSegment {segment_id: "SEG-TRADITIONAL-001"})
MERGE (c)-[r:BELONGS_TO_SEGMENT]->(bs)
ON CREATE SET r.assignment_date = date("2024-01-15"),
    r.confidence_score = 0.92,
    r.segment_fit = "Strong";

// Link Marketing Campaigns to Behavioral Segments
MATCH (mc:MarketingCampaign {campaign_id: "CAMP-2024-Q1-RETENTION"})
MATCH (bs:BehavioralSegment {segment_id: "SEG-HIGH-RISK-001"})
MERGE (mc)-[r:TARGETS_SEGMENT]->(bs)
ON CREATE SET r.target_percentage = 0.85,
    r.priority_level = "High"

MATCH (mc:MarketingCampaign {campaign_id: "CAMP-2024-Q1-UPSELL"})
MATCH (bs:BehavioralSegment {segment_id: "SEG-DIGITAL-001"})
MERGE (mc)-[r:TARGETS_SEGMENT]->(bs)
ON CREATE SET r.target_percentage = 0.60,
    r.priority_level = "Medium"

MATCH (mc:MarketingCampaign {campaign_id: "CAMP-2024-Q2-DIGITAL"})
MATCH (bs:BehavioralSegment {segment_id: "SEG-TRADITIONAL-001"})
MERGE (mc)-[r:TARGETS_SEGMENT]->(bs)
ON CREATE SET r.target_percentage = 0.75,
    r.priority_level = "Medium";

// Link Customers to Marketing Campaigns
MATCH (c:Customer {customer_number: "CUST-001234"})
MATCH (mc:MarketingCampaign {campaign_id: "CAMP-2024-Q1-RETENTION"})
MERGE (c)-[r:TARGETED_BY_CAMPAIGN]->(mc)
ON CREATE SET r.contacted_date = date("2024-03-05"),
    r.response_status = "Converted",
    r.response_date = date("2024-03-12"),
    r.channel_used = "Email"

MATCH (c:Customer {customer_number: "CUST-001235"})
MATCH (mc:MarketingCampaign {campaign_id: "CAMP-2024-Q1-UPSELL"})
MERGE (c)-[r:TARGETED_BY_CAMPAIGN]->(mc)
ON CREATE SET r.contacted_date = date("2024-03-18"),
    r.response_status = "Pending",
    r.response_date = null,
    r.channel_used = "Account Manager";

// Link Feature Importance to ML Models
MATCH (fi:FeatureImportance {feature_id: "FEAT-CHURN-001"})
MATCH (ml:MLModel {model_id: "ML-CHURN-001"})
MERGE (fi)-[r:FEATURE_OF]->(ml)
ON CREATE SET r.importance_rank = fi.importance_rank

MATCH (fi:FeatureImportance {feature_id: "FEAT-CHURN-002"})
MATCH (ml:MLModel {model_id: "ML-CHURN-001"})
MERGE (fi)-[r:FEATURE_OF]->(ml)
ON CREATE SET r.importance_rank = fi.importance_rank

MATCH (fi:FeatureImportance {feature_id: "FEAT-CHURN-003"})
MATCH (ml:MLModel {model_id: "ML-CHURN-001"})
MERGE (fi)-[r:FEATURE_OF]->(ml)
ON CREATE SET r.importance_rank = fi.importance_rank;

// Link ML Models to Training Data (using existing Customers as training set)
MATCH (ml:MLModel {model_id: "ML-CHURN-001"})
MATCH (c:Customer)
WHERE c.customer_number IN ["CUST-001234", "CUST-001235"]
MERGE (ml)-[r:TRAINED_ON]->(c)
ON CREATE SET r.training_date = ml.training_date,
    r.sample_weight = 1.0,
    r.included_in_version = ml.model_version;

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~600 nodes, ~750 relationships with predictive analytics infrastructure
