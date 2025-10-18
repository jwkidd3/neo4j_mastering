// Neo4j Lab 13 - Data Reload Script
// Complete data setup for Lab 13: API Development & Web Application
// Run this script if you need to reload the Lab 13 data state
// Includes Labs 1-12 data + API Development Infrastructure

// ===================================
// STEP 1: LOAD LAB 12 FOUNDATION
// ===================================
// This builds on Lab 12 - ensure you have the foundation

// Import Lab 12 data first (this is a prerequisite)
// The lab_12_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: API DEVELOPMENT ENTITIES
// ===================================

// Create Web Sessions
MERGE (ws1:WebSession {session_id: "SESS-2024-001"})
ON CREATE SET ws1.customer_id = "CUST-001234",
    ws1.session_start = datetime("2024-03-15T14:30:00"),
    ws1.session_end = datetime("2024-03-15T15:15:00"),
    ws1.session_duration_minutes = 45,
    ws1.ip_address = "192.168.1.100",
    ws1.user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
    ws1.device_type = "Desktop",
    ws1.browser = "Chrome",
    ws1.browser_version = "122.0.0",
    ws1.pages_viewed = 12,
    ws1.actions_performed = 5,
    ws1.conversion = true,
    ws1.created_at = datetime()

MERGE (ws2:WebSession {session_id: "SESS-2024-002"})
ON CREATE SET ws2.customer_id = "CUST-001235",
    ws2.session_start = datetime("2024-03-15T15:00:00"),
    ws2.session_end = datetime("2024-03-15T15:25:00"),
    ws2.session_duration_minutes = 25,
    ws2.ip_address = "192.168.1.101",
    ws2.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)",
    ws2.device_type = "Mobile",
    ws2.browser = "Safari",
    ws2.browser_version = "17.0",
    ws2.pages_viewed = 8,
    ws2.actions_performed = 3,
    ws2.conversion = false,
    ws2.created_at = datetime()

MERGE (ws3:WebSession {session_id: "SESS-2024-003"})
ON CREATE SET ws3.customer_id = "CUST-001236",
    ws3.session_start = datetime("2024-03-15T16:00:00"),
    ws3.session_end = null,
    ws3.session_duration_minutes = null,
    ws3.ip_address = "192.168.1.102",
    ws3.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    ws3.device_type = "Desktop",
    ws3.browser = "Edge",
    ws3.browser_version = "122.0.0",
    ws3.pages_viewed = 3,
    ws3.actions_performed = 1,
    ws3.conversion = false,
    ws3.created_at = datetime();

// Create User Activities
MERGE (ua1:UserActivity {activity_id: "ACT-2024-001"})
ON CREATE SET ua1.session_id = "SESS-2024-001",
    ua1.customer_id = "CUST-001234",
    ua1.activity_type = "Policy Quote",
    ua1.activity_timestamp = datetime("2024-03-15T14:35:00"),
    ua1.activity_description = "Generated auto insurance quote",
    ua1.entity_type = "Policy",
    ua1.entity_id = "POL-2024-001",
    ua1.activity_result = "Success",
    ua1.activity_value = 1250.00,
    ua1.created_at = datetime()

MERGE (ua2:UserActivity {activity_id: "ACT-2024-002"})
ON CREATE SET ua2.session_id = "SESS-2024-001",
    ua2.customer_id = "CUST-001234",
    ua2.activity_type = "Claim Status Check",
    ua2.activity_timestamp = datetime("2024-03-15T14:45:00"),
    ua2.activity_description = "Checked status of existing claim",
    ua2.entity_type = "Claim",
    ua2.entity_id = "CLM-2024-001",
    ua2.activity_result = "Success",
    ua2.activity_value = null,
    ua2.created_at = datetime()

MERGE (ua3:UserActivity {activity_id: "ACT-2024-003"})
ON CREATE SET ua3.session_id = "SESS-2024-002",
    ua3.customer_id = "CUST-001235",
    ua3.activity_type = "Payment Made",
    ua3.activity_timestamp = datetime("2024-03-15T15:10:00"),
    ua3.activity_description = "Made premium payment",
    ua3.entity_type = "Payment",
    ua3.entity_id = "PAY-2024-001",
    ua3.activity_result = "Success",
    ua3.activity_value = 1200.00,
    ua3.created_at = datetime();

// Create API Metrics
MERGE (am1:APIMetric {metric_id: "METRIC-2024-Q1"})
ON CREATE SET am1.endpoint_id = "API-CUSTOMER-001",
    am1.metric_period_start = datetime("2024-01-01T00:00:00"),
    am1.metric_period_end = datetime("2024-03-31T23:59:59"),
    am1.total_requests = 45000,
    am1.successful_requests = 44250,
    am1.failed_requests = 750,
    am1.avg_response_time_ms = 285,
    am1.median_response_time_ms = 220,
    am1.p95_response_time_ms = 850,
    am1.p99_response_time_ms = 1500,
    am1.unique_users = 2500,
    am1.error_rate = 0.0167,
    am1.created_at = datetime()

MERGE (am2:APIMetric {metric_id: "METRIC-2024-Q1-CLAIM"})
ON CREATE SET am2.endpoint_id = "API-CLAIM-001",
    am2.metric_period_start = datetime("2024-01-01T00:00:00"),
    am2.metric_period_end = datetime("2024-03-31T23:59:59"),
    am2.total_requests = 8500,
    am2.successful_requests = 8200,
    am2.failed_requests = 300,
    am2.avg_response_time_ms = 1250,
    am2.median_response_time_ms = 980,
    am2.p95_response_time_ms = 2500,
    am2.p99_response_time_ms = 4000,
    am2.unique_users = 1200,
    am2.error_rate = 0.0353,
    am2.created_at = datetime();

// Create Web Pages
MERGE (wp1:WebPage {page_id: "PAGE-DASHBOARD"})
ON CREATE SET wp1.page_path = "/dashboard",
    wp1.page_name = "Customer Dashboard",
    wp1.page_type = "Application",
    wp1.requires_authentication = true,
    wp1.avg_load_time_ms = 850,
    wp1.monthly_page_views = 125000,
    wp1.avg_bounce_rate = 0.15,
    wp1.avg_time_on_page_seconds = 180,
    wp1.created_at = datetime()

MERGE (wp2:WebPage {page_id: "PAGE-QUOTE"})
ON CREATE SET wp2.page_path = "/quote",
    wp2.page_name = "Get Insurance Quote",
    wp2.page_type = "Form",
    wp2.requires_authentication = false,
    wp2.avg_load_time_ms = 650,
    wp2.monthly_page_views = 85000,
    wp2.avg_bounce_rate = 0.35,
    wp2.avg_time_on_page_seconds = 240,
    wp2.created_at = datetime()

MERGE (wp3:WebPage {page_id: "PAGE-CLAIMS"})
ON CREATE SET wp3.page_path = "/claims",
    wp3.page_name = "File a Claim",
    wp3.page_type = "Form",
    wp3.requires_authentication = true,
    wp3.avg_load_time_ms = 920,
    wp3.monthly_page_views = 42000,
    wp3.avg_bounce_rate = 0.22,
    wp3.avg_time_on_page_seconds = 320,
    wp3.created_at = datetime();

// Create Form Submissions
MERGE (fs1:FormSubmission {submission_id: "FORM-2024-001"})
ON CREATE SET fs1.form_name = "Auto Insurance Quote",
    fs1.session_id = "SESS-2024-001",
    fs1.customer_id = "CUST-001234",
    fs1.submission_timestamp = datetime("2024-03-15T14:35:00"),
    fs1.form_data = '{"vehicle_year": 2022, "vehicle_make": "Toyota", "coverage_type": "Full"}',
    fs1.submission_status = "Completed",
    fs1.validation_errors = 0,
    fs1.time_to_complete_seconds = 180,
    fs1.created_at = datetime()

MERGE (fs2:FormSubmission {submission_id: "FORM-2024-002"})
ON CREATE SET fs2.form_name = "Claim Submission",
    fs2.session_id = "SESS-2024-002",
    fs2.customer_id = "CUST-001235",
    fs2.submission_timestamp = datetime("2024-03-15T15:15:00"),
    fs2.form_data = '{"incident_date": "2024-03-10", "incident_type": "Collision", "claim_amount": 5000}',
    fs2.submission_status = "Completed",
    fs2.validation_errors = 0,
    fs2.time_to_complete_seconds = 420,
    fs2.created_at = datetime();

// Create Error Logs
MERGE (el1:ErrorLog {error_id: "ERR-2024-001"})
ON CREATE SET el1.error_timestamp = datetime("2024-03-15T14:32:15"),
    el1.error_type = "ValidationError",
    el1.error_severity = "Warning",
    el1.error_message = "Invalid postal code format",
    el1.endpoint_id = "API-CUSTOMER-001",
    el1.session_id = "SESS-2024-001",
    el1.stack_trace = "ValidationError at validators.py:45",
    el1.resolved = true,
    el1.resolution_timestamp = datetime("2024-03-15T14:32:20"),
    el1.created_at = datetime()

MERGE (el2:ErrorLog {error_id: "ERR-2024-002"})
ON CREATE SET el2.error_timestamp = datetime("2024-03-15T15:22:30"),
    el2.error_type = "DatabaseError",
    el2.error_severity = "Error",
    el2.error_message = "Connection timeout to Neo4j database",
    el2.endpoint_id = "API-CLAIM-001",
    el2.session_id = "SESS-2024-002",
    el2.stack_trace = "neo4j.exceptions.ServiceUnavailable",
    el2.resolved = true,
    el2.resolution_timestamp = datetime("2024-03-15T15:23:00"),
    el2.created_at = datetime();

// Create Performance Metrics
MERGE (pm1:PerformanceMetric {metric_id: "PERF-2024-Q1-OVERALL"})
ON CREATE SET pm1.metric_period_start = datetime("2024-01-01T00:00:00"),
    pm1.metric_period_end = datetime("2024-03-31T23:59:59"),
    pm1.avg_api_response_time_ms = 450,
    pm1.avg_database_query_time_ms = 125,
    pm1.avg_page_load_time_ms = 850,
    pm1.total_api_requests = 250000,
    pm1.total_database_queries = 1250000,
    pm1.cache_hit_rate = 0.75,
    pm1.error_rate = 0.02,
    pm1.uptime_percentage = 99.95,
    pm1.created_at = datetime();

// ===================================
// STEP 3: API DEVELOPMENT RELATIONSHIPS
// ===================================

// Link Web Sessions to Customers
MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:HAD_SESSION]->(ws)
ON CREATE SET r.session_start = ws.session_start,
    r.session_duration = ws.session_duration_minutes

MATCH (ws:WebSession {session_id: "SESS-2024-002"})
MATCH (c:Customer {customer_number: "CUST-001235"})
MERGE (c)-[r:HAD_SESSION]->(ws)
ON CREATE SET r.session_start = ws.session_start,
    r.session_duration = ws.session_duration_minutes;

// Link User Activities to Web Sessions
MATCH (ua:UserActivity {activity_id: "ACT-2024-001"})
MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MERGE (ua)-[r:OCCURRED_IN_SESSION]->(ws)
ON CREATE SET r.activity_timestamp = ua.activity_timestamp

MATCH (ua:UserActivity {activity_id: "ACT-2024-002"})
MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MERGE (ua)-[r:OCCURRED_IN_SESSION]->(ws)
ON CREATE SET r.activity_timestamp = ua.activity_timestamp

MATCH (ua:UserActivity {activity_id: "ACT-2024-003"})
MATCH (ws:WebSession {session_id: "SESS-2024-002"})
MERGE (ua)-[r:OCCURRED_IN_SESSION]->(ws)
ON CREATE SET r.activity_timestamp = ua.activity_timestamp;

// Link User Activities to Entities
MATCH (ua:UserActivity {activity_id: "ACT-2024-001"})
MATCH (p:Policy {policy_number: "POL-2024-001"})
MERGE (ua)-[r:INTERACTED_WITH]->(p)
ON CREATE SET r.interaction_type = ua.activity_type

MATCH (ua:UserActivity {activity_id: "ACT-2024-002"})
MATCH (c:Claim {claim_number: "CLM-2024-001"})
MERGE (ua)-[r:INTERACTED_WITH]->(c)
ON CREATE SET r.interaction_type = ua.activity_type;

// Link API Metrics to API Endpoints
MATCH (am:APIMetric {metric_id: "METRIC-2024-Q1"})
MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
MERGE (am)-[r:MEASURES_ENDPOINT]->(api)
ON CREATE SET r.period_start = am.metric_period_start,
    r.period_end = am.metric_period_end

MATCH (am:APIMetric {metric_id: "METRIC-2024-Q1-CLAIM"})
MATCH (api:APIEndpoint {endpoint_id: "API-CLAIM-001"})
MERGE (am)-[r:MEASURES_ENDPOINT]->(api)
ON CREATE SET r.period_start = am.metric_period_start,
    r.period_end = am.metric_period_end;

// Link Form Submissions to Web Sessions
MATCH (fs:FormSubmission {submission_id: "FORM-2024-001"})
MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MERGE (fs)-[r:SUBMITTED_IN_SESSION]->(ws)
ON CREATE SET r.submission_timestamp = fs.submission_timestamp

MATCH (fs:FormSubmission {submission_id: "FORM-2024-002"})
MATCH (ws:WebSession {session_id: "SESS-2024-002"})
MERGE (fs)-[r:SUBMITTED_IN_SESSION]->(ws)
ON CREATE SET r.submission_timestamp = fs.submission_timestamp;

// Link Form Submissions to Customers
MATCH (fs:FormSubmission {submission_id: "FORM-2024-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:SUBMITTED_FORM]->(fs)
ON CREATE SET r.submission_timestamp = fs.submission_timestamp

MATCH (fs:FormSubmission {submission_id: "FORM-2024-002"})
MATCH (c:Customer {customer_number: "CUST-001235"})
MERGE (c)-[r:SUBMITTED_FORM]->(fs)
ON CREATE SET r.submission_timestamp = fs.submission_timestamp;

// Link Error Logs to API Endpoints
MATCH (el:ErrorLog {error_id: "ERR-2024-001"})
MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
MERGE (el)-[r:OCCURRED_AT_ENDPOINT]->(api)
ON CREATE SET r.error_timestamp = el.error_timestamp

MATCH (el:ErrorLog {error_id: "ERR-2024-002"})
MATCH (api:APIEndpoint {endpoint_id: "API-CLAIM-001"})
MERGE (el)-[r:OCCURRED_AT_ENDPOINT]->(api)
ON CREATE SET r.error_timestamp = el.error_timestamp;

// Link Error Logs to Web Sessions
MATCH (el:ErrorLog {error_id: "ERR-2024-001"})
MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MERGE (el)-[r:OCCURRED_IN_SESSION]->(ws)
ON CREATE SET r.error_timestamp = el.error_timestamp

MATCH (el:ErrorLog {error_id: "ERR-2024-002"})
MATCH (ws:WebSession {session_id: "SESS-2024-002"})
MERGE (el)-[r:OCCURRED_IN_SESSION]->(ws)
ON CREATE SET r.error_timestamp = el.error_timestamp;

// Link Web Sessions to Web Pages
MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MATCH (wp:WebPage {page_id: "PAGE-DASHBOARD"})
MERGE (ws)-[r:VISITED_PAGE]->(wp)
ON CREATE SET r.visit_timestamp = ws.session_start,
    r.time_on_page_seconds = 120

MATCH (ws:WebSession {session_id: "SESS-2024-001"})
MATCH (wp:WebPage {page_id: "PAGE-QUOTE"})
MERGE (ws)-[r:VISITED_PAGE]->(wp)
ON CREATE SET r.visit_timestamp = datetime("2024-03-15T14:33:00"),
    r.time_on_page_seconds = 180

MATCH (ws:WebSession {session_id: "SESS-2024-002"})
MATCH (wp:WebPage {page_id: "PAGE-CLAIMS"})
MERGE (ws)-[r:VISITED_PAGE]->(wp)
ON CREATE SET r.visit_timestamp = datetime("2024-03-15T15:05:00"),
    r.time_on_page_seconds = 320;

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~720 nodes, ~900 relationships with API development infrastructure
