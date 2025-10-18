// Neo4j Lab 10 - Data Reload Script
// Complete data setup for Lab 10: Compliance & Audit Trail
// Run this script if you need to reload the Lab 10 data state
// Includes Labs 1-9 data + Compliance & Audit Infrastructure

// ===================================
// STEP 1: LOAD LAB 9 FOUNDATION
// ===================================
// This builds on Lab 9 - ensure you have the foundation

// Import Lab 9 data first (this is a prerequisite)
// The lab_09_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: COMPLIANCE ENTITIES
// ===================================

// Create Compliance Records
MERGE (cr1:ComplianceRecord {compliance_id: "COMP-2024-001"})
ON CREATE SET cr1.record_type = "Regulatory Filing",
    cr1.regulation_name = "NAIC Model Law Compliance",
    cr1.filing_date = date("2024-01-15"),
    cr1.compliance_status = "Submitted",
    cr1.regulatory_body = "State Insurance Commission",
    cr1.filing_reference = "NAIC-2024-Q1-001",
    cr1.compliance_officer = "Jane Williams",
    cr1.next_review_date = date("2024-04-15"),
    cr1.documentation_complete = true,
    cr1.created_at = datetime()

MERGE (cr2:ComplianceRecord {compliance_id: "COMP-2024-002"})
ON CREATE SET cr2.record_type = "Privacy Compliance",
    cr2.regulation_name = "GDPR Data Protection",
    cr2.filing_date = date("2024-02-01"),
    cr2.compliance_status = "Active",
    cr2.regulatory_body = "Data Protection Authority",
    cr2.filing_reference = "GDPR-2024-DPA-002",
    cr2.compliance_officer = "Robert Chen",
    cr2.next_review_date = date("2024-05-01"),
    cr2.documentation_complete = true,
    cr2.created_at = datetime()

MERGE (cr3:ComplianceRecord {compliance_id: "COMP-2024-003"})
ON CREATE SET cr3.record_type = "Financial Compliance",
    cr3.regulation_name = "Sarbanes-Oxley Act",
    cr3.filing_date = date("2024-03-01"),
    cr3.compliance_status = "Under Review",
    cr3.regulatory_body = "Securities and Exchange Commission",
    cr3.filing_reference = "SOX-2024-Q1-003",
    cr3.compliance_officer = "Michael Brown",
    cr3.next_review_date = date("2024-06-01"),
    cr3.documentation_complete = false,
    cr3.created_at = datetime();

// Create Audit Records
MERGE (ar1:AuditRecord {audit_id: "AUD-2024-Q1"})
ON CREATE SET ar1.audit_type = "Internal Compliance Audit",
    ar1.audit_period_start = date("2024-01-01"),
    ar1.audit_period_end = date("2024-03-31"),
    ar1.audit_status = "Completed",
    ar1.auditor_name = "Jennifer Martinez",
    ar1.auditor_firm = "Internal Audit Department",
    ar1.findings_count = 3,
    ar1.critical_findings = 0,
    ar1.recommendations = 5,
    ar1.audit_scope = "Claims Processing Compliance",
    ar1.completion_date = date("2024-04-15"),
    ar1.created_at = datetime()

MERGE (ar2:AuditRecord {audit_id: "AUD-2024-Q2"})
ON CREATE SET ar2.audit_type = "External Financial Audit",
    ar2.audit_period_start = date("2024-04-01"),
    ar2.audit_period_end = date("2024-06-30"),
    ar2.audit_status = "In Progress",
    ar2.auditor_name = "David Thompson",
    ar2.auditor_firm = "Thompson & Associates CPA",
    ar2.findings_count = 0,
    ar2.critical_findings = 0,
    ar2.recommendations = 0,
    ar2.audit_scope = "Financial Statements and Controls",
    ar2.completion_date = null,
    ar2.created_at = datetime();

// Create Regulatory Requirements
MERGE (rr1:RegulatoryRequirement {requirement_id: "REG-NAIC-001"})
ON CREATE SET rr1.requirement_name = "Annual Financial Reporting",
    rr1.regulatory_body = "National Association of Insurance Commissioners",
    rr1.requirement_type = "Financial Disclosure",
    rr1.frequency = "Annual",
    rr1.deadline_month = 3,
    rr1.deadline_day = 31,
    rr1.is_mandatory = true,
    rr1.penalty_for_noncompliance = "License Suspension",
    rr1.description = "Submit audited financial statements and statutory filings",
    rr1.created_at = datetime()

MERGE (rr2:RegulatoryRequirement {requirement_id: "REG-GDPR-001"})
ON CREATE SET rr2.requirement_name = "Data Protection Impact Assessment",
    rr2.regulatory_body = "EU Data Protection Board",
    rr2.requirement_type = "Privacy Protection",
    rr2.frequency = "As Needed",
    rr2.deadline_month = null,
    rr2.deadline_day = null,
    rr2.is_mandatory = true,
    rr2.penalty_for_noncompliance = "Fines up to 4% of annual revenue",
    rr2.description = "Assess privacy risks for new processing activities",
    rr2.created_at = datetime()

MERGE (rr3:RegulatoryRequirement {requirement_id: "REG-SOX-001"})
ON CREATE SET rr3.requirement_name = "Internal Control Assessment",
    rr3.regulatory_body = "SEC and PCAOB",
    rr3.requirement_type = "Financial Controls",
    rr3.frequency = "Quarterly",
    rr3.deadline_month = null,
    rr3.deadline_day = 45,
    rr3.is_mandatory = true,
    rr3.penalty_for_noncompliance = "Criminal and civil penalties",
    rr3.description = "Evaluate effectiveness of internal controls over financial reporting",
    rr3.created_at = datetime();

// Create Audit Trail Entries
MERGE (ate1:AuditTrailEntry {entry_id: "TRAIL-2024-001"})
ON CREATE SET ate1.action_type = "Policy Update",
    ate1.action_timestamp = datetime("2024-03-15T14:30:00"),
    ate1.user_id = "USR-001",
    ate1.user_name = "Sarah Johnson",
    ate1.entity_type = "Policy",
    ate1.entity_id = "POL-2024-001",
    ate1.action_description = "Updated premium amount from $1200 to $1250",
    ate1.old_values = "{premium: 1200}",
    ate1.new_values = "{premium: 1250}",
    ate1.ip_address = "192.168.1.100",
    ate1.session_id = "SESS-2024-001",
    ate1.created_at = datetime()

MERGE (ate2:AuditTrailEntry {entry_id: "TRAIL-2024-002"})
ON CREATE SET ate2.action_type = "Claim Approval",
    ate2.action_timestamp = datetime("2024-03-16T09:15:00"),
    ate2.user_id = "USR-002",
    ate2.user_name = "Michael Brown",
    ate2.entity_type = "Claim",
    ate2.entity_id = "CLM-2024-001",
    ate2.action_description = "Approved claim for payment",
    ate2.old_values = "{status: Pending}",
    ate2.new_values = "{status: Approved, amount: 5000}",
    ate2.ip_address = "192.168.1.101",
    ate2.session_id = "SESS-2024-002",
    ate2.created_at = datetime()

MERGE (ate3:AuditTrailEntry {entry_id: "TRAIL-2024-003"})
ON CREATE SET ate3.action_type = "Customer Data Access",
    ate3.action_timestamp = datetime("2024-03-17T11:45:00"),
    ate3.user_id = "USR-003",
    ate3.user_name = "Jennifer Martinez",
    ate3.entity_type = "Customer",
    ate3.entity_id = "CUST-001234",
    ate3.action_description = "Viewed customer personal information",
    ate3.old_values = null,
    ate3.new_values = null,
    ate3.ip_address = "192.168.1.102",
    ate3.session_id = "SESS-2024-003",
    ate3.created_at = datetime();

// Create Policy Versions (for audit trail)
MERGE (pv1:PolicyVersion {version_id: "POL-2024-001-V1"})
ON CREATE SET pv1.policy_id = "POL-2024-001",
    pv1.version_number = 1,
    pv1.effective_date = date("2024-01-01"),
    pv1.expiration_date = date("2024-03-14"),
    pv1.premium_amount = 1200.00,
    pv1.coverage_amount = 100000.00,
    pv1.change_reason = "Initial Policy Creation",
    pv1.modified_by = "SYSTEM",
    pv1.created_at = datetime("2024-01-01T00:00:00")

MERGE (pv2:PolicyVersion {version_id: "POL-2024-001-V2"})
ON CREATE SET pv2.policy_id = "POL-2024-001",
    pv2.version_number = 2,
    pv2.effective_date = date("2024-03-15"),
    pv2.expiration_date = null,
    pv2.premium_amount = 1250.00,
    pv2.coverage_amount = 100000.00,
    pv2.change_reason = "Premium Adjustment - Risk Reassessment",
    pv2.modified_by = "USR-001",
    pv2.created_at = datetime("2024-03-15T14:30:00");

// ===================================
// STEP 3: COMPLIANCE RELATIONSHIPS
// ===================================

// Link Compliance Records to Regulatory Requirements
MATCH (cr:ComplianceRecord {compliance_id: "COMP-2024-001"})
MATCH (rr:RegulatoryRequirement {requirement_id: "REG-NAIC-001"})
MERGE (cr)-[r:SATISFIES_REQUIREMENT]->(rr)
ON CREATE SET r.compliance_level = "Full Compliance",
    r.verification_date = date("2024-01-20"),
    r.verified_by = "Jane Williams"

MATCH (cr:ComplianceRecord {compliance_id: "COMP-2024-002"})
MATCH (rr:RegulatoryRequirement {requirement_id: "REG-GDPR-001"})
MERGE (cr)-[r:SATISFIES_REQUIREMENT]->(rr)
ON CREATE SET r.compliance_level = "Full Compliance",
    r.verification_date = date("2024-02-05"),
    r.verified_by = "Robert Chen"

MATCH (cr:ComplianceRecord {compliance_id: "COMP-2024-003"})
MATCH (rr:RegulatoryRequirement {requirement_id: "REG-SOX-001"})
MERGE (cr)-[r:SATISFIES_REQUIREMENT]->(rr)
ON CREATE SET r.compliance_level = "Partial Compliance",
    r.verification_date = date("2024-03-10"),
    r.verified_by = "Michael Brown";

// Link Audit Records to Compliance Records
MATCH (ar:AuditRecord {audit_id: "AUD-2024-Q1"})
MATCH (cr:ComplianceRecord {compliance_id: "COMP-2024-001"})
MERGE (ar)-[r:AUDITED_COMPLIANCE]->(cr)
ON CREATE SET r.audit_finding = "Compliant",
    r.finding_severity = "None",
    r.recommendations = ["Maintain current processes"]

MATCH (ar:AuditRecord {audit_id: "AUD-2024-Q1"})
MATCH (cr:ComplianceRecord {compliance_id: "COMP-2024-002"})
MERGE (ar)-[r:AUDITED_COMPLIANCE]->(cr)
ON CREATE SET r.audit_finding = "Minor Issues Found",
    r.finding_severity = "Low",
    r.recommendations = ["Improve documentation", "Update training materials"];

// Link Audit Trail Entries to Entities
MATCH (ate:AuditTrailEntry {entry_id: "TRAIL-2024-001"})
MATCH (p:Policy {policy_number: "POL-2024-001"})
MERGE (ate)-[r:TRACKED_CHANGE]->(p)
ON CREATE SET r.change_type = "Update",
    r.change_timestamp = ate.action_timestamp

MATCH (ate:AuditTrailEntry {entry_id: "TRAIL-2024-002"})
MATCH (c:Claim {claim_number: "CLM-2024-001"})
MERGE (ate)-[r:TRACKED_CHANGE]->(c)
ON CREATE SET r.change_type = "Status Change",
    r.change_timestamp = ate.action_timestamp

MATCH (ate:AuditTrailEntry {entry_id: "TRAIL-2024-003"})
MATCH (cust:Customer {customer_number: "CUST-001234"})
MERGE (ate)-[r:TRACKED_ACCESS]->(cust)
ON CREATE SET r.access_type = "Read",
    r.access_timestamp = ate.action_timestamp;

// Link Policy Versions
MATCH (pv1:PolicyVersion {version_id: "POL-2024-001-V1"})
MATCH (pv2:PolicyVersion {version_id: "POL-2024-001-V2"})
MERGE (pv1)-[r:SUPERSEDED_BY]->(pv2)
ON CREATE SET r.transition_date = pv2.effective_date,
    r.transition_reason = pv2.change_reason;

// Link Audit Trail Entries to Policy Versions
MATCH (ate:AuditTrailEntry {entry_id: "TRAIL-2024-001"})
MATCH (pv:PolicyVersion {version_id: "POL-2024-001-V2"})
MERGE (ate)-[r:CREATED_VERSION]->(pv)
ON CREATE SET r.version_timestamp = ate.action_timestamp;

// Link Customers to Compliance (GDPR subject rights)
MATCH (c:Customer {customer_number: "CUST-001234"})
MATCH (cr:ComplianceRecord {compliance_id: "COMP-2024-002"})
MERGE (c)-[r:PROTECTED_BY]->(cr)
ON CREATE SET r.rights_granted = ["Access", "Rectification", "Erasure", "Portability"],
    r.consent_given = true,
    r.consent_date = date("2024-01-15");

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~550 nodes, ~650 relationships with compliance infrastructure
