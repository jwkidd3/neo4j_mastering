// Neo4j Lab 9 - Data Reload Script
// Complete data setup for Lab 9: Fraud Detection & Investigation
// Run this script if you need to reload the Lab 9 data state
// Includes Labs 1-8 data + Fraud Detection Infrastructure

// ===================================
// STEP 1: LOAD LAB 8 FOUNDATION
// ===================================
// This builds on Lab 8 - ensure you have the foundation

// Import Lab 8 data first (this is a prerequisite)
// The lab_08_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: FRAUD DETECTION ENTITIES
// ===================================

// Create Fraud Investigation Cases
MERGE (fi1:FraudInvestigation {investigation_id: "FI-2024-001"})
ON CREATE SET fi1.case_number = "FI-2024-001",
    fi1.investigation_status = "Active",
    fi1.priority_level = "High",
    fi1.fraud_type = "Staged Accident",
    fi1.estimated_fraud_amount = 45000.00,
    fi1.investigation_start_date = date("2024-01-15"),
    fi1.assigned_investigator = "Det. Sarah Martinez",
    fi1.case_summary = "Suspicious pattern of accidents involving same repair shop",
    fi1.evidence_count = 12,
    fi1.suspects_identified = 4,
    fi1.created_at = datetime()

MERGE (fi2:FraudInvestigation {investigation_id: "FI-2024-002"})
ON CREATE SET fi2.case_number = "FI-2024-002",
    fi2.investigation_status = "Under Review",
    fi2.priority_level = "Medium",
    fi2.fraud_type = "Identity Fraud",
    fi2.estimated_fraud_amount = 28000.00,
    fi2.investigation_start_date = date("2024-01-20"),
    fi2.assigned_investigator = "Det. James Wilson",
    fi2.case_summary = "Multiple policies with same address, different names",
    fi2.evidence_count = 8,
    fi2.suspects_identified = 2,
    fi2.created_at = datetime()

MERGE (fi3:FraudInvestigation {investigation_id: "FI-2024-003"})
ON CREATE SET fi3.case_number = "FI-2024-003",
    fi3.investigation_status = "Active",
    fi3.priority_level = "Critical",
    fi3.fraud_type = "Provider Fraud Ring",
    fi3.estimated_fraud_amount = 125000.00,
    fi3.investigation_start_date = date("2024-02-01"),
    fi3.assigned_investigator = "Det. Maria Rodriguez",
    fi3.case_summary = "Network of medical providers billing for unnecessary treatments",
    fi3.evidence_count = 24,
    fi3.suspects_identified = 8,
    fi3.created_at = datetime();

// Create Fraud Patterns
MERGE (fp1:FraudPattern {pattern_id: "FP-STAGED-ACC"})
ON CREATE SET fp1.pattern_name = "Staged Accident Pattern",
    fp1.pattern_type = "Collision Fraud",
    fp1.confidence_score = 0.87,
    fp1.detection_algorithm = "Network Analysis + Timing Correlation",
    fp1.false_positive_rate = 0.12,
    fp1.cases_detected = 23,
    fp1.total_fraud_prevented = 450000.00,
    fp1.indicators = ["Multiple claims same location", "Same repair shop", "Witnesses related"],
    fp1.created_at = datetime()

MERGE (fp2:FraudPattern {pattern_id: "FP-IDENTITY"})
ON CREATE SET fp2.pattern_name = "Identity Fraud Pattern",
    fp2.pattern_type = "Identity Theft",
    fp2.confidence_score = 0.92,
    fp2.detection_algorithm = "Document Analysis + Address Clustering",
    fp2.false_positive_rate = 0.08,
    fp2.cases_detected = 15,
    fp2.total_fraud_prevented = 280000.00,
    fp2.indicators = ["Duplicate SSN", "Multiple policies same address", "New customer high claims"],
    fp2.created_at = datetime()

MERGE (fp3:FraudPattern {pattern_id: "FP-PROVIDER"})
ON CREATE SET fp3.pattern_name = "Provider Fraud Ring",
    fp3.pattern_type = "Medical Fraud",
    fp3.confidence_score = 0.94,
    fp3.detection_algorithm = "Graph Community Detection",
    fp3.false_positive_rate = 0.05,
    fp3.cases_detected = 8,
    fp3.total_fraud_prevented = 890000.00,
    fp3.indicators = ["Billing clusters", "Unnecessary procedures", "Connected providers"],
    fp3.created_at = datetime();

// Create Fraud Alerts
MERGE (fa1:FraudAlert {alert_id: "FA-2024-0315"})
ON CREATE SET fa1.alert_type = "High Risk Claim",
    fa1.alert_severity = "High",
    fa1.alert_status = "Open",
    fa1.detection_date = datetime("2024-03-15T14:30:00"),
    fa1.fraud_score = 0.89,
    fa1.alert_description = "Claim pattern matches staged accident profile",
    fa1.recommended_action = "Immediate investigation required",
    fa1.auto_generated = true,
    fa1.created_at = datetime()

MERGE (fa2:FraudAlert {alert_id: "FA-2024-0316"})
ON CREATE SET fa2.alert_type = "Identity Verification Required",
    fa2.alert_severity = "Medium",
    fa2.alert_status = "In Review",
    fa2.detection_date = datetime("2024-03-16T09:15:00"),
    fa2.fraud_score = 0.75,
    fa2.alert_description = "Multiple policies with same identifying information",
    fa2.recommended_action = "Document verification needed",
    fa2.auto_generated = true,
    fa2.created_at = datetime();

// Create Suspicious Activity Reports
MERGE (sar1:SuspiciousActivityReport {sar_id: "SAR-2024-001"})
ON CREATE SET sar1.report_type = "Fraud Suspicion",
    sar1.filing_date = date("2024-03-10"),
    sar1.reported_by = "Claims Adjuster - David Kim",
    sar1.activity_description = "Customer filed 3 claims in 2 months, all different vehicles",
    sar1.estimated_loss = 35000.00,
    sar1.report_status = "Submitted to Fraud Department",
    sar1.follow_up_required = true,
    sar1.created_at = datetime()

MERGE (sar2:SuspiciousActivityReport {sar_id: "SAR-2024-002"})
ON CREATE SET sar2.report_type = "Provider Billing Anomaly",
    sar2.filing_date = date("2024-03-12"),
    sar2.reported_by = "Medical Claims Reviewer - Lisa Chen",
    sar2.activity_description = "Provider billing for procedures not medically necessary",
    sar2.estimated_loss = 62000.00,
    sar2.report_status = "Under Investigation",
    sar2.follow_up_required = true,
    sar2.created_at = datetime();

// ===================================
// STEP 3: FRAUD DETECTION RELATIONSHIPS
// ===================================

// Link Claims to Fraud Investigations
MATCH (c:Claim {claim_number: "CLM-2024-001"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-001"})
MERGE (c)-[r:UNDER_INVESTIGATION]->(fi)
ON CREATE SET r.flagged_date = date("2024-01-15"),
    r.flag_reason = "Suspicious timing and location patterns",
    r.investigator_notes = "Multiple red flags identified"

MATCH (c:Claim {claim_number: "CLM-2024-002"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-001"})
MERGE (c)-[r:UNDER_INVESTIGATION]->(fi)
ON CREATE SET r.flagged_date = date("2024-01-16"),
    r.flag_reason = "Connected to same repair shop pattern",
    r.investigator_notes = "Part of suspected fraud ring";

// Link Customers to Fraud Investigations
MATCH (c:Customer {customer_number: "CUST-001234"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-002"})
MERGE (c)-[r:SUBJECT_OF_INVESTIGATION]->(fi)
ON CREATE SET r.suspect_level = "Person of Interest",
    r.investigation_start = date("2024-01-20"),
    r.evidence_collected = 5

MATCH (c:Customer {customer_number: "CUST-001235"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-002"})
MERGE (c)-[r:SUBJECT_OF_INVESTIGATION]->(fi)
ON CREATE SET r.suspect_level = "Primary Suspect",
    r.investigation_start = date("2024-01-22"),
    r.evidence_collected = 8;

// Link Fraud Patterns to Investigations
MATCH (fp:FraudPattern {pattern_id: "FP-STAGED-ACC"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-001"})
MERGE (fi)-[r:MATCHES_PATTERN]->(fp)
ON CREATE SET r.match_confidence = 0.87,
    r.pattern_indicators_found = ["Same repair shop", "Timing correlation", "Witness relationships"]

MATCH (fp:FraudPattern {pattern_id: "FP-IDENTITY"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-002"})
MERGE (fi)-[r:MATCHES_PATTERN]->(fp)
ON CREATE SET r.match_confidence = 0.92,
    r.pattern_indicators_found = ["Duplicate addresses", "Multiple policies"];

// Link Fraud Alerts to Claims
MATCH (fa:FraudAlert {alert_id: "FA-2024-0315"})
MATCH (c:Claim {claim_number: "CLM-2024-001"})
MERGE (fa)-[r:TRIGGERED_BY]->(c)
ON CREATE SET r.trigger_factors = ["High claim amount", "Suspicious timing", "Repair shop flagged"],
    r.created_at = datetime();

// Link SARs to Investigations
MATCH (sar:SuspiciousActivityReport {sar_id: "SAR-2024-001"})
MATCH (fi:FraudInvestigation {investigation_id: "FI-2024-001"})
MERGE (sar)-[r:INITIATED_INVESTIGATION]->(fi)
ON CREATE SET r.report_reviewed_date = date("2024-03-11"),
    r.investigation_priority = "High";

// Create fraud network connections (suspected fraud ring members)
MATCH (c1:Customer {customer_number: "CUST-001234"})
MATCH (c2:Customer {customer_number: "CUST-001235"})
MERGE (c1)-[r:SUSPECTED_COLLUSION]->(c2)
ON CREATE SET r.connection_type = "Same address",
    r.confidence_score = 0.78,
    r.evidence = ["Shared mailing address", "Similar claim patterns"],
    r.identified_date = date("2024-01-20");

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~480 nodes, ~580 relationships with fraud detection infrastructure
