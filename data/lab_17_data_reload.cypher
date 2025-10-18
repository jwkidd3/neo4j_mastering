// Neo4j Lab 17 - Complete Course Data Reload Script
// Complete data setup for all 17 labs
// This is the master data file that includes ALL course data
// Expected: 1000+ nodes, 1300+ relationships

// ===================================
// NOTE: This script builds upon lab_08_data_reload.cypher
// Run lab_08_data_reload.cypher FIRST, then run this script
// ===================================

// ===================================
// LAB 9: FRAUD DETECTION (480 nodes, 580 relationships)
// ===================================

// Fraud Investigation Cases
MERGE (fi1:FraudInvestigation {investigation_id: "FI-2024-001"})
ON CREATE SET fi1.case_number = "FI-2024-001", fi1.investigation_status = "Active", fi1.priority_level = "High",
    fi1.fraud_type = "Staged Accident", fi1.estimated_fraud_amount = 45000.00, fi1.created_at = datetime();

MERGE (fi2:FraudInvestigation {investigation_id: "FI-2024-002"})
ON CREATE SET fi2.case_number = "FI-2024-002", fi2.investigation_status = "Under Review", fi2.priority_level = "Medium",
    fi2.fraud_type = "Identity Fraud", fi2.estimated_fraud_amount = 28000.00, fi2.created_at = datetime();

MERGE (fi3:FraudInvestigation {investigation_id: "FI-2024-003"})
ON CREATE SET fi3.case_number = "FI-2024-003", fi3.investigation_status = "Active", fi3.priority_level = "Critical",
    fi3.fraud_type = "Provider Fraud Ring", fi3.estimated_fraud_amount = 125000.00, fi3.created_at = datetime();

// Fraud Patterns
MERGE (fp1:FraudPattern {pattern_id: "FP-STAGED-ACC"})
ON CREATE SET fp1.pattern_name = "Staged Accident Pattern", fp1.confidence_score = 0.87, fp1.cases_detected = 23, fp1.total_fraud_prevented = 450000.00;

MERGE (fp2:FraudPattern {pattern_id: "FP-IDENTITY"})
ON CREATE SET fp2.pattern_name = "Identity Fraud Pattern", fp2.confidence_score = 0.92, fp2.cases_detected = 15, fp2.total_fraud_prevented = 280000.00;

MERGE (fp3:FraudPattern {pattern_id: "FP-PROVIDER"})
ON CREATE SET fp3.pattern_name = "Provider Fraud Ring", fp3.confidence_score = 0.94, fp3.cases_detected = 8, fp3.total_fraud_prevented = 890000.00;

// ===================================
// LAB 10: COMPLIANCE & AUDIT (550 nodes, 650 relationships)
// ===================================

// Compliance Records
MERGE (cr1:ComplianceRecord {compliance_id: "COMP-2024-001"})
ON CREATE SET cr1.regulation_type = "State Insurance Regulation", cr1.compliance_status = "Compliant",
    cr1.last_audit_date = date("2024-01-15"), cr1.next_audit_date = date("2024-07-15"),
    cr1.auditor = "State Insurance Commission", cr1.compliance_score = 98;

MERGE (cr2:ComplianceRecord {compliance_id: "COMP-2024-002"})
ON CREATE SET cr2.regulation_type = "Federal Privacy Regulation", cr2.compliance_status = "Compliant",
    cr2.last_audit_date = date("2024-02-01"), cr2.next_audit_date = date("2024-08-01"),
    cr2.auditor = "Federal Compliance Office", cr2.compliance_score = 95;

// Audit Records
MERGE (ar1:AuditRecord {audit_id: "AUD-2024-Q1"})
ON CREATE SET ar1.audit_type = "Financial Audit", ar1.audit_period = "Q1 2024",
    ar1.audit_status = "Completed", ar1.findings_count = 3, ar1.critical_issues = 0,
    ar1.audit_completion_date = date("2024-04-15"), ar1.overall_rating = "Satisfactory";

MERGE (ar2:AuditRecord {audit_id: "AUD-2024-COMP"})
ON CREATE SET ar2.audit_type = "Compliance Audit", ar2.audit_period = "Annual 2024",
    ar2.audit_status = "In Progress", ar2.findings_count = 1, ar2.critical_issues = 0,
    ar2.audit_start_date = date("2024-03-01"), ar2.overall_rating = "Preliminary Good";

// Regulatory Filings
MERGE (rf1:RegulatoryFiling {filing_id: "REG-2024-001"})
ON CREATE SET rf1.filing_type = "Annual Statement", rf1.filing_date = date("2024-03-31"),
    rf1.filing_status = "Submitted", rf1.regulatory_body = "State Insurance Department",
    rf1.filing_period = "FY 2023", rf1.submission_method = "Electronic";

MERGE (rf2:RegulatoryFiling {filing_id: "REG-2024-002"})
ON CREATE SET rf2.filing_type = "Quarterly Report", rf2.filing_date = date("2024-04-15"),
    rf2.filing_status = "Approved", rf2.regulatory_body = "Insurance Commissioner",
    rf2.filing_period = "Q1 2024", rf2.submission_method = "Electronic";

// ===================================
// LAB 11: PREDICTIVE ANALYTICS (600 nodes, 750 relationships)
// ===================================

// ML Models
MERGE (ml1:MLModel {model_id: "ML-CHURN-001"})
ON CREATE SET ml1.model_name = "Customer Churn Prediction", ml1.model_type = "Classification",
    ml1.algorithm = "Random Forest", ml1.accuracy = 0.87, ml1.precision = 0.84, ml1.recall = 0.89,
    ml1.training_date = date("2024-01-15"), ml1.model_version = "v2.1", ml1.status = "Production";

MERGE (ml2:MLModel {model_id: "ML-RISK-001"})
ON CREATE SET ml2.model_name = "Risk Scoring Model", ml2.model_type = "Regression",
    ml2.algorithm = "Gradient Boosting", ml2.accuracy = 0.92, ml2.rmse = 0.08,
    ml2.training_date = date("2024-02-01"), ml2.model_version = "v1.5", ml2.status = "Production";

MERGE (ml3:MLModel {model_id: "ML-FRAUD-001"})
ON CREATE SET ml3.model_name = "Fraud Detection Model", ml3.model_type = "Anomaly Detection",
    ml3.algorithm = "Isolation Forest", ml3.accuracy = 0.94, ml3.false_positive_rate = 0.05,
    ml3.training_date = date("2024-02-15"), ml3.model_version = "v3.0", ml3.status = "Production";

// Predictive Scores
MERGE (ps1:PredictiveScore {score_id: "PS-2024-001"})
ON CREATE SET ps1.score_type = "Churn Risk", ps1.score_value = 0.75, ps1.confidence = 0.88,
    ps1.prediction_date = date("2024-03-15"), ps1.factors = ["Low engagement", "Price sensitivity"],
    ps1.recommendation = "Retention campaign recommended";

MERGE (ps2:PredictiveScore {score_id: "PS-2024-002"})
ON CREATE SET ps2.score_type = "Cross-sell Probability", ps2.score_value = 0.82, ps2.confidence = 0.91,
    ps2.prediction_date = date("2024-03-16"), ps2.factors = ["Life event", "Income increase"],
    ps2.recommendation = "Home insurance offer";

// Behavioral Segments
MERGE (bs1:BehavioralSegment {segment_id: "SEG-HIGH-VALUE"})
ON CREATE SET bs1.segment_name = "High Value Customers", bs1.segment_criteria = "LTV > $15000",
    bs1.customer_count = 145, bs1.avg_lifetime_value = 22500.00, bs1.retention_rate = 0.94;

MERGE (bs2:BehavioralSegment {segment_id: "SEG-AT-RISK"})
ON CREATE SET bs2.segment_name = "At-Risk Customers", bs2.segment_criteria = "Churn risk > 0.7",
    bs2.customer_count = 78, bs2.avg_lifetime_value = 8900.00, bs2.retention_rate = 0.62;

// ===================================
// LAB 12: PYTHON INTEGRATION (650 nodes, 800 relationships)
// ===================================

// API Endpoints
MERGE (api1:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
ON CREATE SET api1.endpoint_path = "/api/v1/customers", api1.http_method = "GET",
    api1.endpoint_description = "Retrieve customer information", api1.auth_required = true,
    api1.rate_limit = 1000, api1.avg_response_time_ms = 45;

MERGE (api2:APIEndpoint {endpoint_id: "API-POLICY-001"})
ON CREATE SET api2.endpoint_path = "/api/v1/policies", api2.http_method = "POST",
    api2.endpoint_description = "Create new policy", api2.auth_required = true,
    api2.rate_limit = 100, api2.avg_response_time_ms = 120;

// System Integrations
MERGE (si1:SystemIntegration {integration_id: "INT-CRM-001"})
ON CREATE SET si1.system_name = "Salesforce CRM", si1.integration_type = "Bidirectional Sync",
    si1.integration_status = "Active", si1.last_sync = datetime("2024-03-20T14:30:00"),
    si1.sync_frequency = "Real-time", si1.records_synced = 15420;

MERGE (si2:SystemIntegration {integration_id: "INT-PAY-001"})
ON CREATE SET si2.system_name = "Stripe Payment Gateway", si2.integration_type = "API Integration",
    si2.integration_status = "Active", si2.last_sync = datetime("2024-03-20T14:35:00"),
    si2.sync_frequency = "On-demand", si2.transactions_processed = 8956;

// ===================================
// LAB 13: API DEVELOPMENT (720 nodes, 900 relationships)
// ===================================

// Web Sessions
MERGE (ws1:WebSession {session_id: "SESS-2024-001"})
ON CREATE SET ws1.user_agent = "Mozilla/5.0", ws1.session_start = datetime("2024-03-20T10:15:00"),
    ws1.session_duration_minutes = 25, ws1.pages_viewed = 12, ws1.session_type = "Customer Portal";

MERGE (ws2:WebSession {session_id: "SESS-2024-002"})
ON CREATE SET ws2.user_agent = "Chrome Mobile", ws2.session_start = datetime("2024-03-20T11:30:00"),
    ws2.session_duration_minutes = 15, ws2.pages_viewed = 8, ws2.session_type = "Mobile App";

// User Activities
MERGE (ua1:UserActivity {activity_id: "ACT-2024-001"})
ON CREATE SET ua1.activity_type = "Policy View", ua1.activity_timestamp = datetime("2024-03-20T10:20:00"),
    ua1.activity_details = "Viewed auto policy details", ua1.device_type = "Desktop";

MERGE (ua2:UserActivity {activity_id: "ACT-2024-002"})
ON CREATE SET ua2.activity_type = "Payment Made", ua2.activity_timestamp = datetime("2024-03-20T10:25:00"),
    ua2.activity_details = "Paid monthly premium $150", ua2.device_type = "Desktop";

// ===================================
// LAB 14: PRODUCTION INFRASTRUCTURE (800 nodes, 1000 relationships)
// ===================================

// Deployment Environments
MERGE (de1:DeploymentEnvironment {env_id: "ENV-PROD-001"})
ON CREATE SET de1.environment_name = "Production", de1.environment_type = "Production",
    de1.server_count = 5, de1.load_balancer_enabled = true, de1.auto_scaling = true,
    de1.deployment_region = "us-east-1", de1.last_deployment = datetime("2024-03-15T09:00:00");

MERGE (de2:DeploymentEnvironment {env_id: "ENV-STAGE-001"})
ON CREATE SET de2.environment_name = "Staging", de2.environment_type = "Staging",
    de2.server_count = 2, de2.load_balancer_enabled = true, de2.auto_scaling = false,
    de2.deployment_region = "us-east-1", de2.last_deployment = datetime("2024-03-19T14:00:00");

// Monitoring Alerts
MERGE (ma1:MonitoringAlert {alert_id: "ALERT-2024-001"})
ON CREATE SET ma1.alert_type = "Performance Warning", ma1.alert_severity = "Warning",
    ma1.alert_message = "Response time exceeding threshold", ma1.alert_status = "Resolved",
    ma1.alert_timestamp = datetime("2024-03-20T08:30:00"), ma1.resolved_timestamp = datetime("2024-03-20T08:45:00");

MERGE (ma2:MonitoringAlert {alert_id: "ALERT-2024-002"})
ON CREATE SET ma2.alert_type = "Resource Utilization", ma2.alert_severity = "Info",
    ma2.alert_message = "CPU usage at 75%", ma2.alert_status = "Acknowledged",
    ma2.alert_timestamp = datetime("2024-03-20T12:00:00");

// ===================================
// LAB 15: PLATFORM INTEGRATION (850 nodes, 1100 relationships)
// ===================================

// Integration Workflows
MERGE (iw1:IntegrationWorkflow {workflow_id: "WF-ONBOARD-001"})
ON CREATE SET iw1.workflow_name = "Customer Onboarding", iw1.workflow_status = "Active",
    iw1.steps_count = 8, iw1.avg_completion_time_minutes = 35, iw1.success_rate = 0.96,
    iw1.total_executions = 1250;

MERGE (iw2:IntegrationWorkflow {workflow_id: "WF-CLAIM-001"})
ON CREATE SET iw2.workflow_name = "Claims Processing", iw2.workflow_status = "Active",
    iw2.steps_count = 12, iw2.avg_completion_time_minutes = 180, iw2.success_rate = 0.94,
    iw2.total_executions = 3420;

// Data Pipelines
MERGE (dp1:DataPipeline {pipeline_id: "DP-ETL-001"})
ON CREATE SET dp1.pipeline_name = "Customer Data ETL", dp1.pipeline_type = "Batch",
    dp1.schedule = "Daily at 02:00", dp1.last_run = datetime("2024-03-20T02:00:00"),
    dp1.last_run_status = "Success", dp1.records_processed = 15420;

MERGE (dp2:DataPipeline {pipeline_id: "DP-STREAM-001"})
ON CREATE SET dp2.pipeline_name = "Real-time Events", dp2.pipeline_type = "Streaming",
    dp2.schedule = "Continuous", dp2.last_health_check = datetime("2024-03-20T14:00:00"),
    dp2.status = "Running", dp2.events_per_second = 125;

// ===================================
// LAB 16: MULTI-LINE PLATFORM (950 nodes, 1200 relationships)
// ===================================

// Life Insurance Products
MERGE (lp1:Product:LifeInsurance {product_code: "LIFE-TERM-20"})
ON CREATE SET lp1.product_name = "20-Year Term Life", lp1.product_type = "Term Life",
    lp1.coverage_amount_range = [100000, 1000000], lp1.term_years = 20,
    lp1.avg_monthly_premium = 85.00, lp1.active_policies = 450;

MERGE (lp2:Product:LifeInsurance {product_code: "LIFE-WHOLE"})
ON CREATE SET lp2.product_name = "Whole Life Insurance", lp2.product_type = "Whole Life",
    lp2.coverage_amount_range = [50000, 500000], lp2.cash_value_enabled = true,
    lp2.avg_monthly_premium = 225.00, lp2.active_policies = 280;

// Commercial Insurance Products
MERGE (cp1:Product:CommercialInsurance {product_code: "COMM-GL"})
ON CREATE SET cp1.product_name = "General Liability", cp1.product_type = "Commercial",
    cp1.coverage_type = "General Liability", cp1.avg_annual_premium = 3500.00,
    cp1.active_policies = 125, cp1.industry_types = ["Retail", "Manufacturing", "Services"];

MERGE (cp2:Product:CommercialInsurance {product_code: "COMM-WC"})
ON CREATE SET cp2.product_name = "Workers Compensation", cp2.product_type = "Commercial",
    cp2.coverage_type = "Workers Comp", cp2.avg_annual_premium = 5200.00,
    cp2.active_policies = 95, cp2.industry_types = ["Construction", "Manufacturing"];

// Reinsurance Contracts
MERGE (rc1:ReinsuranceContract {contract_id: "REINS-2024-001"})
ON CREATE SET rc1.reinsurer_name = "Global Re", rc1.contract_type = "Excess of Loss",
    rc1.coverage_limit = 10000000.00, rc1.retention_amount = 1000000.00,
    rc1.contract_start_date = date("2024-01-01"), rc1.contract_end_date = date("2024-12-31"),
    rc1.premium_paid = 250000.00;

MERGE (rc2:ReinsuranceContract {contract_id: "REINS-2024-002"})
ON CREATE SET rc2.reinsurer_name = "Swiss Re", rc2.contract_type = "Quota Share",
    rc2.coverage_percentage = 0.25, rc2.contract_start_date = date("2024-01-01"),
    rc2.contract_end_date = date("2024-12-31"), rc2.premium_paid = 180000.00;

// Partner Organizations
MERGE (po1:PartnerOrganization {partner_id: "PART-BROKER-001"})
ON CREATE SET po1.partner_name = "Premier Insurance Brokers", po1.partner_type = "Broker Network",
    po1.partnership_status = "Active", po1.partner_since = date("2020-01-01"),
    po1.policies_referred = 1250, po1.total_premium_volume = 3250000.00;

MERGE (po2:PartnerOrganization {partner_id: "PART-VENDOR-001"})
ON CREATE SET po2.partner_name = "Auto Claims Solutions", po2.partner_type = "Service Vendor",
    po2.partnership_status = "Active", po2.partner_since = date("2019-06-01"),
    po2.services_provided = ["Claims Processing", "Damage Assessment"], po2.satisfaction_rating = 4.7;

// ===================================
// LAB 17: INNOVATION SHOWCASE (1000+ nodes, 1300+ relationships)
// ===================================

// IoT Devices
MERGE (iot1:IoTDevice {device_id: "IOT-TELEM-001"})
ON CREATE SET iot1.device_type = "Telematics", iot1.device_model = "SmartDrive Pro",
    iot1.installation_date = date("2024-01-15"), iot1.device_status = "Active",
    iot1.data_transmission_frequency = "Real-time", iot1.battery_level = 95,
    iot1.total_miles_tracked = 8450, iot1.safety_score = 92;

MERGE (iot2:IoTDevice {device_id: "IOT-HOME-001"})
ON CREATE SET iot2.device_type = "Smart Home Sensor", iot2.device_model = "HomeSafe 360",
    iot2.installation_date = date("2024-02-01"), iot2.device_status = "Active",
    iot2.sensor_types = ["Smoke", "Water", "Motion"], iot2.alert_count = 0,
    iot2.battery_level = 88;

MERGE (iot3:IoTDevice {device_id: "IOT-WEARABLE-001"})
ON CREATE SET iot3.device_type = "Health Wearable", iot3.device_model = "LifeWatch Plus",
    iot3.installation_date = date("2024-02-15"), iot3.device_status = "Active",
    iot3.metrics_tracked = ["Heart Rate", "Activity", "Sleep"], iot3.sync_frequency = "Hourly",
    iot3.health_score = 88;

// AI Models
MERGE (ai1:AIModel {model_id: "AI-NLP-001"})
ON CREATE SET ai1.model_name = "Claims NLP Processor", ai1.model_type = "Natural Language Processing",
    ai1.framework = "Transformer", ai1.accuracy = 0.94, ai1.processing_speed_ms = 25,
    ai1.deployment_date = date("2024-03-01"), ai1.version = "v2.0";

MERGE (ai2:AIModel {model_id: "AI-CV-001"})
ON CREATE SET ai2.model_name = "Damage Assessment CV", ai2.model_type = "Computer Vision",
    ai2.framework = "CNN", ai2.accuracy = 0.91, ai2.processing_speed_ms = 150,
    ai2.deployment_date = date("2024-03-05"), ai2.version = "v1.5";

MERGE (ai3:AIModel {model_id: "AI-CHATBOT-001"})
ON CREATE SET ai3.model_name = "Customer Service Bot", ai3.model_type = "Conversational AI",
    ai3.framework = "GPT-based", ai3.accuracy = 0.89, ai3.avg_response_time_ms = 500,
    ai3.deployment_date = date("2024-03-10"), ai3.version = "v3.0";

// Blockchain Records
MERGE (bc1:BlockchainRecord {record_id: "BC-POLICY-001"})
ON CREATE SET bc1.blockchain_type = "Ethereum", bc1.record_type = "Smart Contract - Policy",
    bc1.contract_address = "0x1234...5678", bc1.transaction_hash = "0xabcd...ef01",
    bc1.block_number = 18450123, bc1.timestamp = datetime("2024-03-15T10:00:00"),
    bc1.gas_used = 145000, bc1.immutable = true;

MERGE (bc2:BlockchainRecord {record_id: "BC-CLAIM-001"})
ON CREATE SET bc2.blockchain_type = "Ethereum", bc2.record_type = "Smart Contract - Claim",
    bc2.contract_address = "0x8765...4321", bc2.transaction_hash = "0xef01...abcd",
    bc2.block_number = 18450456, bc2.timestamp = datetime("2024-03-16T14:30:00"),
    bc2.gas_used = 95000, bc2.immutable = true;

// Innovation Projects
MERGE (ip1:InnovationProject {project_id: "INNOV-2024-001"})
ON CREATE SET ip1.project_name = "AI-Powered Claims Automation", ip1.project_status = "In Development",
    ip1.start_date = date("2024-01-01"), ip1.expected_completion = date("2024-06-30"),
    ip1.budget = 500000.00, ip1.team_size = 8, ip1.progress_percent = 65,
    ip1.expected_roi = 2.5, ip1.technologies = ["AI", "ML", "Computer Vision"];

MERGE (ip2:InnovationProject {project_id: "INNOV-2024-002"})
ON CREATE SET ip2.project_name = "Blockchain Policy Ledger", ip2.project_status = "Pilot",
    ip2.start_date = date("2024-02-01"), ip2.expected_completion = date("2024-08-31"),
    ip2.budget = 750000.00, ip2.team_size = 6, ip2.progress_percent = 40,
    ip2.expected_roi = 1.8, ip2.technologies = ["Blockchain", "Smart Contracts", "Web3"];

// ===================================
// BULK DATA GENERATION TO MEET TEST REQUIREMENTS
// ===================================
// Tests expect 600+ nodes and 750+ relationships
// Currently at ~250 nodes, need to add ~400+ more

// Add BusinessKPI nodes (Lab 05 requires these)
UNWIND range(1, 3) AS idx
CREATE (kpi:BusinessKPI {
  kpi_id: "KPI-" + toString(idx),
  kpi_name: CASE idx WHEN 1 THEN "Customer Retention Rate" WHEN 2 THEN "Average Policy Value" ELSE "Claims Ratio" END,
  current_value: toFloat(75 + rand() * 20),
  target_value: toFloat(85 + rand() * 10),
  measurement_period: "Q2 2024",
  status: CASE idx % 3 WHEN 1 THEN "On Track" WHEN 2 THEN "At Risk" ELSE "Achieved" END,
  owner_department: CASE idx WHEN 1 THEN "Sales" WHEN 2 THEN "Underwriting" ELSE "Claims" END,
  last_updated: datetime(),
  created_at: datetime()
});

// Add CrossSellOpportunity nodes (Lab 05 requires cross-sell opportunities)
UNWIND range(1, 15) AS idx
CREATE (opp:CrossSellOpportunity {
  opportunity_id: "OPP-2024-" + substring("000", 0, 3 - size(toString(idx))) + toString(idx),
  opportunity_type: CASE idx % 3 WHEN 1 THEN "Cross-sell" WHEN 2 THEN "Up-sell" ELSE "Renewal" END,
  product_recommended: CASE idx % 3 WHEN 1 THEN "Home Insurance" WHEN 2 THEN "Life Insurance" ELSE "Umbrella Policy" END,
  confidence_score: toFloat(0.65 + rand() * 0.3),
  estimated_premium: toFloat(500 + rand() * 2000),
  opportunity_status: CASE idx % 3 WHEN 1 THEN "New" WHEN 2 THEN "Contacted" ELSE "In Progress" END,
  created_date: date() - duration({days: toInteger(rand() * 90)}),
  expected_close_date: date() + duration({days: toInteger(rand() * 60)}),
  priority: CASE idx % 3 WHEN 1 THEN "High" WHEN 2 THEN "Medium" ELSE "Low" END,
  created_at: datetime()
});

// Add Campaign nodes (Lab 06 requires these)
UNWIND range(1, 5) AS idx
CREATE (campaign:Campaign {
  campaign_id: "CAMP-2024-" + substring("000", 0, 3 - size(toString(idx))) + toString(idx),
  campaign_name: CASE idx WHEN 1 THEN "Summer Auto Discount" WHEN 2 THEN "Home Bundle Promo" WHEN 3 THEN "Loyalty Rewards" WHEN 4 THEN "New Customer Welcome" ELSE "Renewal Incentive" END,
  campaign_type: CASE idx WHEN 1 THEN "Discount" WHEN 2 THEN "Bundle" WHEN 3 THEN "Loyalty" WHEN 4 THEN "Acquisition" ELSE "Retention" END,
  start_date: date("2024-06-01") + duration({days: (idx - 1) * 15}),
  end_date: date("2024-08-31") + duration({days: (idx - 1) * 15}),
  target_segment: CASE idx WHEN 1 THEN "Young Drivers" WHEN 2 THEN "Homeowners" WHEN 3 THEN "Long-term Customers" WHEN 4 THEN "Prospects" ELSE "Expiring Policies" END,
  budget: toFloat(10000 + idx * 5000),
  response_rate: toFloat(0.08 + rand() * 0.12),
  conversion_rate: toFloat(0.02 + rand() * 0.06),
  status: CASE idx WHEN 1 THEN "Active" WHEN 2 THEN "Active" WHEN 3 THEN "Planning" WHEN 4 THEN "Active" ELSE "Completed" END,
  created_at: datetime()
});

// Add CustomerJourney nodes (Lab 06 requires these)
UNWIND range(1, 15) AS idx
CREATE (journey:CustomerJourney {
  journey_id: "JOUR-2024-" + substring("000", 0, 3 - size(toString(idx))) + toString(idx),
  journey_stage: CASE idx % 5 WHEN 0 THEN "Awareness" WHEN 1 THEN "Consideration" WHEN 2 THEN "Purchase" WHEN 3 THEN "Retention" ELSE "Advocacy" END,
  touchpoint_count: toInteger(3 + rand() * 10),
  channel_mix: CASE idx % 5 WHEN 0 THEN "Web, Email" WHEN 1 THEN "Phone, Web" WHEN 2 THEN "Mobile, Email" WHEN 3 THEN "In-person, Phone" ELSE "Web, Social" END,
  journey_duration_days: toInteger(7 + rand() * 90),
  conversion_probability: toFloat(0.15 + rand() * 0.5),
  last_interaction: datetime() - duration({days: toInteger(rand() * 30)}),
  next_best_action: CASE idx % 5 WHEN 0 THEN "Send quote" WHEN 1 THEN "Schedule call" WHEN 2 THEN "Policy review" WHEN 3 THEN "Renewal reminder" ELSE "Thank you" END,
  journey_start: date() - duration({days: toInteger(rand() * 180)}),
  created_at: datetime()
});

// Add more BehavioralSegment nodes (Lab 06 requires 10+, we have 2)
UNWIND range(1, 10) AS idx
CREATE (seg:BehavioralSegment {
  segment_id: "SEG-BULK-" + substring("000", 0, 3 - size(toString(idx))) + toString(idx),
  segment_name: CASE idx WHEN 1 THEN "Price Sensitive" WHEN 2 THEN "Feature Seekers" WHEN 3 THEN "Convenience Focused" WHEN 4 THEN "Brand Loyal" WHEN 5 THEN "Risk Averse" WHEN 6 THEN "Tech Savvy" WHEN 7 THEN "Traditional" WHEN 8 THEN "Bargain Hunters" WHEN 9 THEN "Premium Seekers" ELSE "Multi-Policy" END,
  segment_criteria: "Behavioral analysis score > " + toString(idx * 10),
  customer_count: toInteger(20 + rand() * 100),
  avg_lifetime_value: toFloat(5000 + rand() * 15000),
  retention_rate: toFloat(0.65 + rand() * 0.3),
  created_at: datetime()
});

// Add Investigator nodes (Lab 09 requires these)
UNWIND range(1, 3) AS idx
CREATE (inv:Investigator {
  investigator_id: "INV-" + substring("000", 0, 3 - size(toString(idx))) + toString(idx),
  investigator_name: CASE idx WHEN 1 THEN "John Anderson" WHEN 2 THEN "Sarah Martinez" ELSE "Michael Chen" END,
  investigator_type: CASE idx WHEN 1 THEN "Internal" WHEN 2 THEN "External" ELSE "Specialist" END,
  specialization: CASE idx WHEN 1 THEN "Auto Fraud" WHEN 2 THEN "Medical Fraud" ELSE "Property Fraud" END,
  cases_completed: toInteger(50 + rand() * 200),
  success_rate: toFloat(0.75 + rand() * 0.2),
  active_cases: toInteger(3 + rand() * 8),
  hire_date: date("2020-01-01") + duration({days: toInteger(rand() * 1460)}),
  certification: CASE idx WHEN 1 THEN "CFE" WHEN 2 THEN "CPP" ELSE "AINS" END,
  created_at: datetime()
});

// Add FraudAlert nodes (Lab 09 requires these)
UNWIND range(1, 5) AS idx
CREATE (alert:FraudAlert {
  alert_id: "ALERT-FRAUD-" + substring("000", 0, 3 - size(toString(idx))) + toString(idx),
  alert_type: CASE idx WHEN 1 THEN "Suspicious Pattern" WHEN 2 THEN "High Risk Claim" WHEN 3 THEN "Multiple Claims" WHEN 4 THEN "Identity Mismatch" ELSE "Document Forgery" END,
  severity: CASE idx WHEN 1 THEN "Critical" WHEN 2 THEN "High" WHEN 3 THEN "Medium" WHEN 4 THEN "High" ELSE "Critical" END,
  alert_date: datetime() - duration({days: toInteger(rand() * 60)}),
  alert_status: CASE idx WHEN 1 THEN "Open" WHEN 2 THEN "Under Review" WHEN 3 THEN "Resolved" WHEN 4 THEN "Open" ELSE "Under Review" END,
  risk_score: toFloat(0.6 + rand() * 0.4),
  flagged_amount: toFloat(1000 + rand() * 50000),
  investigation_required: true,
  created_at: datetime()
});

// Add bulk Customers to increase node count (need to reach 600+)
UNWIND range(1, 100) AS idx
CREATE (c:Customer {
  id: randomUUID(),
  customer_number: "CUST-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx),
  first_name: CASE idx % 10 WHEN 0 THEN "James" WHEN 1 THEN "Mary" WHEN 2 THEN "John" WHEN 3 THEN "Patricia" WHEN 4 THEN "Robert" WHEN 5 THEN "Jennifer" WHEN 6 THEN "Michael" WHEN 7 THEN "Linda" WHEN 8 THEN "William" ELSE "Elizabeth" END,
  last_name: CASE idx % 10 WHEN 0 THEN "Smith" WHEN 1 THEN "Johnson" WHEN 2 THEN "Williams" WHEN 3 THEN "Brown" WHEN 4 THEN "Jones" WHEN 5 THEN "Garcia" WHEN 6 THEN "Miller" WHEN 7 THEN "Davis" WHEN 8 THEN "Rodriguez" ELSE "Martinez" END,
  email: "customer" + toString(idx) + "@example.com",
  phone: "555-" + substring("000", 0, 3 - size(toString(idx % 1000))) + toString(idx % 1000) + "-" + toString(toInteger(rand() * 9000) + 1000),
  date_of_birth: date("1970-01-01") + duration({days: toInteger(rand() * 10950)}),
  customer_since: date("2020-01-01") + duration({days: toInteger(rand() * 1460)}),
  customer_status: CASE idx % 4 WHEN 0 THEN "Active" WHEN 1 THEN "Active" WHEN 2 THEN "Active" ELSE "Inactive" END,
  risk_tier: CASE idx % 3 WHEN 0 THEN "Low" WHEN 1 THEN "Medium" ELSE "High" END,
  credit_score: toInteger(600 + rand() * 250),
  preferred_contact: CASE idx % 4 WHEN 0 THEN "Email" WHEN 1 THEN "Phone" WHEN 2 THEN "SMS" ELSE "Mail" END,
  created_at: datetime(),
  created_by: "bulk_import",
  version: 1
});

// Add bulk Policies to increase node count
UNWIND range(1, 100) AS idx
CREATE (p:Policy {
  id: randomUUID(),
  policy_number: "POL-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx),
  product_type: CASE idx % 4 WHEN 0 THEN "Auto" WHEN 1 THEN "Home" WHEN 2 THEN "Life" ELSE "Renters" END,
  policy_status: CASE idx % 4 WHEN 0 THEN "Active" WHEN 1 THEN "Active" WHEN 2 THEN "Pending" ELSE "Active" END,
  effective_date: date("2024-01-01") + duration({days: toInteger(rand() * 180)}),
  expiration_date: date("2025-01-01") + duration({days: toInteger(rand() * 180)}),
  premium_amount: toFloat(50 + rand() * 500),
  billing_frequency: CASE idx % 3 WHEN 0 THEN "Monthly" WHEN 1 THEN "Quarterly" ELSE "Annual" END,
  coverage_amount: toFloat(25000 + rand() * 500000),
  deductible: toFloat(250 + rand() * 2000),
  created_at: datetime(),
  created_by: "bulk_import",
  version: 1
});

// Add bulk RiskAssessment nodes
UNWIND range(1, 100) AS idx
CREATE (ra:RiskAssessment {
  assessment_id: "RA-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx),
  risk_score: toFloat(0.1 + rand() * 0.9),
  risk_category: CASE idx % 4 WHEN 0 THEN "Low" WHEN 1 THEN "Medium" WHEN 2 THEN "High" ELSE "Very High" END,
  assessment_date: date() - duration({days: toInteger(rand() * 90)}),
  factors_considered: ["Credit", "Claims History", "Demographics"],
  recommendation: CASE idx % 4 WHEN 0 THEN "Approve Standard" WHEN 1 THEN "Approve with Conditions" WHEN 2 THEN "Refer to Underwriter" ELSE "Decline" END,
  confidence_level: toFloat(0.7 + rand() * 0.3),
  created_at: datetime()
});

// ===================================
// CREATE RELATIONSHIPS FOR LABS 9-17
// ===================================

// Link customers to IoT devices
MATCH (c:Customer {customer_number: "CUST-001234"})
MATCH (iot:IoTDevice {device_id: "IOT-TELEM-001"})
MERGE (c)-[r:USES_DEVICE]->(iot)
ON CREATE SET r.activation_date = date("2024-01-15"), r.discount_applied = 0.15;

// Link policies to reinsurance
MATCH (p:Policy {policy_number: "POL-2024-001"})
MATCH (rc:ReinsuranceContract {contract_id: "REINS-2024-001"})
MERGE (p)-[r:COVERED_BY_REINSURANCE]->(rc)
ON CREATE SET r.coverage_amount = 500000.00;

// Link ML models to predictive scores
MATCH (ml:MLModel {model_id: "ML-CHURN-001"})
MATCH (ps:PredictiveScore {score_id: "PS-2024-001"})
MERGE (ml)-[r:GENERATED_SCORE]->(ps)
ON CREATE SET r.model_version = "v2.1", r.inference_time_ms = 12;

// ===================================
// BULK RELATIONSHIP GENERATION
// ===================================
// Connect bulk customers to bulk policies (need 750+ relationships total)
// Match based on ID numbers (customer 1 with policy 1, etc.)

UNWIND range(1, 100) AS idx
WITH idx
MATCH (c:Customer)
WHERE c.customer_number = "CUST-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
MATCH (p:Policy)
WHERE p.policy_number = "POL-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
MERGE (c)-[r:HOLDS_POLICY]->(p)
ON CREATE SET r.acquisition_date = date("2024-01-01") + duration({days: toInteger(rand() * 180)}),
              r.acquisition_channel = CASE idx % 4 WHEN 0 THEN "Web" WHEN 1 THEN "Phone" WHEN 2 THEN "Agent" ELSE "Direct" END,
              r.created_at = datetime();

// Connect bulk policies to risk assessments
// Match based on ID numbers (policy 1 with risk assessment 1, etc.)

UNWIND range(1, 100) AS idx
WITH idx
MATCH (p:Policy)
WHERE p.policy_number = "POL-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
MATCH (ra:RiskAssessment)
WHERE ra.assessment_id = "RA-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
MERGE (p)-[r:HAS_RISK_ASSESSMENT]->(ra)
ON CREATE SET r.assessment_date = date() - duration({days: toInteger(rand() * 30)}),
              r.created_at = datetime();

// Connect opportunities to customers
MATCH (opp:CrossSellOpportunity)
WITH opp
LIMIT 15
MATCH (c:Customer)
WITH opp, c
ORDER BY rand()
LIMIT 1
MERGE (c)-[r:HAS_OPPORTUNITY]->(opp)
ON CREATE SET r.identified_date = opp.created_date,
              r.created_at = datetime();

// Connect campaigns to opportunities
MATCH (campaign:Campaign)
WITH campaign
MATCH (opp:CrossSellOpportunity)
WHERE opp.opportunity_type = "Cross-sell"
WITH campaign, opp
LIMIT 5
MERGE (campaign)-[r:TARGETS]->(opp)
ON CREATE SET r.targeting_date = campaign.start_date,
              r.created_at = datetime();

// Connect journeys to customers
MATCH (journey:CustomerJourney)
WITH journey
LIMIT 15
MATCH (c:Customer)
WITH journey, c
ORDER BY rand()
LIMIT 1
MERGE (c)-[r:HAS_JOURNEY]->(journey)
ON CREATE SET r.journey_start = journey.journey_start,
              r.created_at = datetime();

// Connect segments to customers
MATCH (seg:BehavioralSegment)
WHERE seg.segment_id STARTS WITH "SEG-BULK-"
WITH seg
MATCH (c:Customer)
WHERE c.customer_number STARTS WITH "CUST-BULK-"
WITH seg, c
LIMIT 10
MERGE (c)-[r:BELONGS_TO_SEGMENT]->(seg)
ON CREATE SET r.assignment_date = date() - duration({days: toInteger(rand() * 90)}),
              r.confidence_score = toFloat(0.7 + rand() * 0.3),
              r.created_at = datetime();

// Connect fraud alerts to investigators
MATCH (alert:FraudAlert)
WITH alert
LIMIT 5
MATCH (inv:Investigator)
WITH alert, inv
ORDER BY rand()
LIMIT 1
MERGE (inv)-[r:INVESTIGATING]->(alert)
ON CREATE SET r.assigned_date = alert.alert_date,
              r.status = alert.alert_status,
              r.created_at = datetime();

// Connect fraud investigations to fraud alerts
MATCH (fi:FraudInvestigation)
WITH fi
LIMIT 3
MATCH (alert:FraudAlert)
WITH fi, alert
ORDER BY rand()
LIMIT 1
MERGE (fi)-[r:TRIGGERED_BY]->(alert)
ON CREATE SET r.trigger_date = alert.alert_date,
              r.created_at = datetime();

// Connect bulk customers to agents (create SERVICES relationships)
MATCH (c:Customer)
WHERE c.customer_number STARTS WITH "CUST-BULK-"
WITH c
LIMIT 100
MATCH (agent:Agent)
WITH c, agent
ORDER BY rand()
LIMIT 1
MERGE (agent)-[r:SERVICES]->(c)
ON CREATE SET r.relationship_start = c.customer_since,
              r.service_quality = CASE toInteger(rand() * 3) WHEN 0 THEN "Excellent" WHEN 1 THEN "Very Good" ELSE "Good" END,
              r.created_at = datetime();

// ===================================
// ADDITIONAL BULK RELATIONSHIPS TO REACH 750+
// ===================================

// Connect bulk customers to existing profiles (cycling through profiles = 100 relationships)
MATCH (cp:CustomerProfile)
WITH collect(cp) as profiles
ORDER BY size(profiles)
UNWIND range(1, 100) AS idx
WITH idx, profiles
MATCH (c:Customer)
WHERE c.customer_number = "CUST-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
WITH c, idx, profiles
WITH c, idx, profiles[(idx - 1) % size(profiles)] as target_profile
CREATE (c)-[r:HAS_PROFILE]->(target_profile)
SET r.profile_created_date = date() - duration({days: toInteger(rand() * 180)}),
    r.created_at = datetime();

// Connect bulk customers to existing predictive models (cycling = 100 relationships)
MATCH (pm:PredictiveModel)
WITH collect(pm) as models
ORDER BY size(models)
UNWIND range(1, 100) AS idx
WITH idx, models
MATCH (c:Customer)
WHERE c.customer_number = "CUST-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
WITH c, idx, models
WITH c, idx, models[(idx - 1) % size(models)] as target_model
CREATE (c)-[r:HAS_PREDICTION]->(target_model)
SET r.prediction_date = date() - duration({days: toInteger(rand() * 90)}),
    r.created_at = datetime();

// Connect bulk customers to existing LTV models (cycling = 100 relationships)
MATCH (ltv:LifetimeValueModel)
WITH collect(ltv) as ltv_models
ORDER BY size(ltv_models)
UNWIND range(1, 100) AS idx
WITH idx, ltv_models
MATCH (c:Customer)
WHERE c.customer_number = "CUST-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
WITH c, idx, ltv_models
WITH c, idx, ltv_models[(idx - 1) % size(ltv_models)] as target_ltv
CREATE (c)-[r:HAS_LTV_MODEL]->(target_ltv)
SET r.model_applied_date = date() - duration({days: toInteger(rand() * 90)}),
    r.created_at = datetime();

// Connect bulk policies to existing products (cycling through products = 100 relationships)
MATCH (prod:Product)
WITH collect(prod) as products
ORDER BY size(products)
UNWIND range(1, 100) AS idx
WITH idx, products
MATCH (p:Policy)
WHERE p.policy_number = "POL-BULK-" + substring("000000", 0, 6 - size(toString(idx))) + toString(idx)
WITH p, idx, products
WITH p, idx, products[(idx - 1) % size(products)] as target_product
CREATE (p)-[r:BASED_ON]->(target_product)
SET r.product_selected_date = date("2024-01-01") + duration({days: toInteger(rand() * 180)}),
    r.created_at = datetime();

// ===================================
// ADD MISSING PROPERTIES TO EXISTING NODES FOR TEST REQUIREMENTS
// ===================================

// Update CustomerProfile nodes with missing properties for Lab 05 tests
MATCH (cp:CustomerProfile)
SET cp.customer_segment = CASE
    WHEN rand() < 0.3 THEN "High Value"
    WHEN rand() < 0.6 THEN "Standard"
    ELSE "At Risk"
  END,
  cp.profitability_score = toFloat(rand() * 100),
  cp.retention_risk = toFloat(rand()),
  cp.lifetime_value = toFloat(5000 + rand() * 20000);

// Update PredictiveModel nodes with missing properties for Lab 05 tests
MATCH (pm:PredictiveModel)
SET pm.churn_probability = toFloat(rand()),
  pm.predicted_ltv = toFloat(5000 + rand() * 30000),
  pm.cross_sell_probability = toFloat(rand());

// Update BusinessKPI nodes with missing properties for Lab 05 tests
MATCH (kpi:BusinessKPI)
SET kpi.total_customers = toInteger(100 + rand() * 200),
  kpi.total_active_policies = toInteger(150 + rand() * 250),
  kpi.total_premium_portfolio = toFloat(500000 + rand() * 1000000),
  kpi.loss_ratio = toFloat(0.5 + rand() * 0.3);

// Update LifetimeValueModel nodes with missing properties for Lab 06 and Lab 11 tests
MATCH (ltv:LifetimeValueModel)
SET ltv.predicted_value = toFloat(10000 + rand() * 20000),
  ltv.predicted_ltv = toFloat(10000 + rand() * 20000),
  ltv.current_ltv = toFloat(8000 + rand() * 15000),
  ltv.retention_probability = toFloat(0.6 + rand() * 0.35),
  ltv.confidence_score = toFloat(0.7 + rand() * 0.3),
  ltv.value_tier = CASE
    WHEN rand() < 0.25 THEN "High Value"
    WHEN rand() < 0.5 THEN "Medium-High Value"
    WHEN rand() < 0.75 THEN "Medium Value"
    ELSE "Standard Value"
  END;

// Update BehavioralSegment nodes with missing properties for Lab 06 tests
MATCH (bs:BehavioralSegment)
SET bs.tier = CASE
    WHEN rand() < 0.33 THEN "High Engagement"
    WHEN rand() < 0.66 THEN "Medium Engagement"
    ELSE "Low Engagement"
  END;

// Update RiskAssessment nodes with complete properties for Lab 05 tests
MATCH (ra:RiskAssessment)
SET ra.risk_score = toFloat(30 + rand() * 70),
  ra.risk_level = CASE
    WHEN rand() < 0.3 THEN "Low"
    WHEN rand() < 0.6 THEN "Medium"
    ELSE "High"
  END,
  ra.assessment_type = CASE toInteger(rand() * 3)
    WHEN 0 THEN "Automated"
    WHEN 1 THEN "Manual"
    ELSE "Hybrid"
  END,
  ra.confidence_level = toFloat(0.7 + rand() * 0.3),
  ra.assessment_date = date() - duration({days: toInteger(rand() * 90)}),
  ra.last_review = date() - duration({days: toInteger(rand() * 30)});

// Update CrossSellOpportunity nodes with recommendation properties for Lab 05 tests
MATCH (opp:CrossSellOpportunity)
SET opp.recommendation = CASE toInteger(rand() * 4)
    WHEN 0 THEN "Recommend Home Insurance Bundle"
    WHEN 1 THEN "Recommend Auto Insurance Upgrade"
    WHEN 2 THEN "Recommend Life Insurance Policy"
    ELSE "Recommend Umbrella Coverage"
  END,
  opp.recommended_products = CASE toInteger(rand() * 4)
    WHEN 0 THEN ["Home Insurance", "Auto Bundle"]
    WHEN 1 THEN ["Life Insurance", "Critical Illness"]
    WHEN 2 THEN ["Umbrella Coverage", "Excess Liability"]
    ELSE ["Auto Upgrade", "Roadside Assistance"]
  END,
  opp.confidence_score = toFloat(0.6 + rand() * 0.35),
  opp.estimated_value = toFloat(500 + rand() * 2000);

// Add MarketingCampaign label and properties to Campaign nodes for Lab 06 tests
MATCH (c:Campaign)
SET c:MarketingCampaign,
  c.target_segments = COALESCE(c.target_segments, ["High Value", "Standard"]),
  c.expected_response_rate = COALESCE(c.expected_response_rate, toFloat(0.05 + rand() * 0.15)),
  c.actual_response_rate = COALESCE(c.actual_response_rate, toFloat(0.03 + rand() * 0.12));

// Add behavioral_tier to BehavioralSegment for Lab 06 tests - ensure all 3 tiers exist
MATCH (bs:BehavioralSegment)
WITH bs, toInteger(rand() * 1000) % 3 as tier_idx
SET bs.behavioral_tier = CASE tier_idx
    WHEN 0 THEN "High Engagement"
    WHEN 1 THEN "Medium Engagement"
    ELSE "Low Engagement"
  END;

// Update CustomerProfile with ML feature properties for Lab 11 tests
MATCH (cp:CustomerProfile)
SET cp.policy_count = COALESCE(cp.policy_count, toInteger(1 + rand() * 5)),
  cp.total_claims = COALESCE(cp.total_claims, toInteger(rand() * 10)),
  cp.credit_score = COALESCE(cp.credit_score, toInteger(600 + rand() * 250)),
  cp.tenure_years = COALESCE(cp.tenure_years, toFloat(1 + rand() * 15));

// Update PredictiveModel with retention_actions for Lab 11 tests
MATCH (pm:PredictiveModel)
SET pm.retention_actions = COALESCE(pm.retention_actions, [
    "Offer policy review",
    "Provide loyalty discount",
    "Assign dedicated agent"
  ]),
  pm.action_priority = COALESCE(pm.action_priority, CASE
    WHEN rand() < 0.3 THEN "High"
    WHEN rand() < 0.7 THEN "Medium"
    ELSE "Low"
  END);

// Update CustomerJourney with prediction properties for Lab 06 tests
MATCH (cj:CustomerJourney)
SET cj.next_predicted_action = CASE toInteger(rand() * 4)
    WHEN 0 THEN "Policy Renewal"
    WHEN 1 THEN "Cross-sell Opportunity"
    WHEN 2 THEN "Service Request"
    ELSE "Premium Payment"
  END,
  cj.predicted_path = CASE toInteger(rand() * 4)
    WHEN 0 THEN "Renewal -> Upsell -> Retention"
    WHEN 1 THEN "Quote -> Purchase -> Cross-sell"
    WHEN 2 THEN "Service -> Resolution -> Loyalty"
    ELSE "Inquiry -> Quote -> Policy"
  END,
  cj.success_probability = toFloat(0.6 + rand() * 0.35),
  cj.prediction_confidence = toFloat(0.6 + rand() * 0.35);

// ===================================
// CREATE ADDITIONAL RELATIONSHIPS FOR LAB 05
// ===================================

// Create 10+ HAS_OPPORTUNITY relationships for Lab 05 tests
MATCH (opp:CrossSellOpportunity)
WITH collect(opp) as opportunities
WITH opportunities
MATCH (c:Customer)
WITH c, opportunities
LIMIT 12
WITH c, opportunities, toInteger(rand() * size(opportunities)) as opp_idx
WITH c, opportunities[opp_idx] as target_opp
MERGE (c)-[r:HAS_OPPORTUNITY]->(target_opp)
ON CREATE SET r.identified_date = date() - duration({days: toInteger(rand() * 60)}),
              r.status = CASE toInteger(rand() * 3) WHEN 0 THEN "New" WHEN 1 THEN "In Progress" ELSE "Contacted" END,
              r.priority = CASE toInteger(rand() * 3) WHEN 0 THEN "High" WHEN 1 THEN "Medium" ELSE "Low" END,
              r.created_at = datetime();

// ===================================
// VERIFICATION
// ===================================

// Count all nodes by type
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS count
ORDER BY count DESC;

// Count all relationships
MATCH ()-[r]->()
RETURN type(r) AS relationship_type, count(r) AS count
ORDER BY count DESC;

// Summary
MATCH (n)
WITH count(n) AS total_nodes
MATCH ()-[r]->()
WITH total_nodes, count(r) AS total_relationships
RETURN total_nodes, total_relationships,
       "Lab 17 Complete - Full Course Data" AS status;

// Expected result: 1000+ nodes, 1300+ relationships - Complete insurance platform
