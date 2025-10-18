// Neo4j Lab 12 - Data Reload Script
// Complete data setup for Lab 12: Python Driver & Service Integration
// Run this script if you need to reload the Lab 12 data state
// Includes Labs 1-11 data + Python Integration Infrastructure

// ===================================
// STEP 1: LOAD LAB 11 FOUNDATION
// ===================================
// This builds on Lab 11 - ensure you have the foundation

// Import Lab 11 data first (this is a prerequisite)
// The lab_11_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: PYTHON INTEGRATION ENTITIES
// ===================================

// Create API Endpoints
MERGE (api1:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
ON CREATE SET api1.endpoint_path = "/api/v1/customers",
    api1.http_method = "GET",
    api1.endpoint_name = "List Customers",
    api1.description = "Retrieve paginated list of customers",
    api1.authentication_required = true,
    api1.rate_limit = 100,
    api1.rate_limit_period = "minute",
    api1.response_format = "JSON",
    api1.is_active = true,
    api1.version = "1.0",
    api1.created_at = datetime()

MERGE (api2:APIEndpoint {endpoint_id: "API-CUSTOMER-002"})
ON CREATE SET api2.endpoint_path = "/api/v1/customers/{id}",
    api2.http_method = "GET",
    api2.endpoint_name = "Get Customer Details",
    api2.description = "Retrieve detailed customer information including policies and claims",
    api2.authentication_required = true,
    api2.rate_limit = 200,
    api2.rate_limit_period = "minute",
    api2.response_format = "JSON",
    api2.is_active = true,
    api2.version = "1.0",
    api2.created_at = datetime()

MERGE (api3:APIEndpoint {endpoint_id: "API-CLAIM-001"})
ON CREATE SET api3.endpoint_path = "/api/v1/claims",
    api3.http_method = "POST",
    api3.endpoint_name = "Submit New Claim",
    api3.description = "Submit a new insurance claim",
    api3.authentication_required = true,
    api3.rate_limit = 50,
    api3.rate_limit_period = "minute",
    api3.response_format = "JSON",
    api3.is_active = true,
    api3.version = "1.0",
    api3.created_at = datetime()

MERGE (api4:APIEndpoint {endpoint_id: "API-POLICY-001"})
ON CREATE SET api4.endpoint_path = "/api/v1/policies/{id}/quote",
    api4.http_method = "POST",
    api4.endpoint_name = "Generate Policy Quote",
    api4.description = "Generate insurance quote for policy",
    api4.authentication_required = true,
    api4.rate_limit = 75,
    api4.rate_limit_period = "minute",
    api4.response_format = "JSON",
    api4.is_active = true,
    api4.version = "1.0",
    api4.created_at = datetime();

// Create System Integrations
MERGE (si1:SystemIntegration {integration_id: "INT-CRM-001"})
ON CREATE SET si1.integration_name = "Salesforce CRM Integration",
    si1.integration_type = "CRM",
    si1.system_name = "Salesforce",
    si1.connection_type = "REST API",
    si1.connection_status = "Active",
    si1.sync_frequency = "Real-time",
    si1.last_sync = datetime("2024-03-15T14:30:00"),
    si1.data_flow_direction = "Bidirectional",
    si1.entities_synced = ["Customer", "Policy", "Claim"],
    si1.created_at = datetime()

MERGE (si2:SystemIntegration {integration_id: "INT-PAYMENT-001"})
ON CREATE SET si2.integration_name = "Stripe Payment Gateway",
    si2.integration_type = "Payment",
    si2.system_name = "Stripe",
    si2.connection_type = "REST API",
    si2.connection_status = "Active",
    si2.sync_frequency = "On-demand",
    si2.last_sync = datetime("2024-03-15T16:45:00"),
    si2.data_flow_direction = "Inbound",
    si2.entities_synced = ["Payment", "Transaction"],
    si2.created_at = datetime()

MERGE (si3:SystemIntegration {integration_id: "INT-EMAIL-001"})
ON CREATE SET si3.integration_name = "SendGrid Email Service",
    si3.integration_type = "Email",
    si3.system_name = "SendGrid",
    si3.connection_type = "SMTP/API",
    si3.connection_status = "Active",
    si3.sync_frequency = "Real-time",
    si3.last_sync = datetime("2024-03-15T17:00:00"),
    si3.data_flow_direction = "Outbound",
    si3.entities_synced = ["Notification", "EmailTemplate"],
    si3.created_at = datetime();

// Create Database Connections
MERGE (dbc1:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
ON CREATE SET dbc1.connection_name = "Neo4j Production Database",
    dbc1.database_type = "Neo4j",
    dbc1.host = "neo4j-prod.company.com",
    dbc1.port = 7687,
    dbc1.database_name = "insurance",
    dbc1.connection_pool_size = 50,
    dbc1.connection_timeout = 30,
    dbc1.max_transaction_retry = 3,
    dbc1.ssl_enabled = true,
    dbc1.connection_status = "Active",
    dbc1.created_at = datetime()

MERGE (dbc2:DatabaseConnection {connection_id: "DB-POSTGRES-ANALYTICS"})
ON CREATE SET dbc2.connection_name = "PostgreSQL Analytics Database",
    dbc2.database_type = "PostgreSQL",
    dbc2.host = "postgres-analytics.company.com",
    dbc2.port = 5432,
    dbc2.database_name = "analytics",
    dbc2.connection_pool_size = 20,
    dbc2.connection_timeout = 30,
    dbc2.max_transaction_retry = 3,
    dbc2.ssl_enabled = true,
    dbc2.connection_status = "Active",
    dbc2.created_at = datetime();

// Create Service Components
MERGE (sc1:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
ON CREATE SET sc1.component_name = "Customer Service",
    sc1.component_type = "Microservice",
    sc1.programming_language = "Python",
    sc1.framework = "FastAPI",
    sc1.version = "2.1.0",
    sc1.deployment_status = "Running",
    sc1.instance_count = 3,
    sc1.health_status = "Healthy",
    sc1.last_deployment = datetime("2024-03-01T10:00:00"),
    sc1.repository_url = "https://github.com/company/customer-service",
    sc1.created_at = datetime()

MERGE (sc2:ServiceComponent {component_id: "SVC-CLAIM-001"})
ON CREATE SET sc2.component_name = "Claims Processing Service",
    sc2.component_type = "Microservice",
    sc2.programming_language = "Python",
    sc2.framework = "Flask",
    sc2.version = "1.8.2",
    sc2.deployment_status = "Running",
    sc2.instance_count = 5,
    sc2.health_status = "Healthy",
    sc2.last_deployment = datetime("2024-02-15T14:30:00"),
    sc2.repository_url = "https://github.com/company/claims-service",
    sc2.created_at = datetime()

MERGE (sc3:ServiceComponent {component_id: "SVC-POLICY-001"})
ON CREATE SET sc3.component_name = "Policy Management Service",
    sc3.component_type = "Microservice",
    sc3.programming_language = "Python",
    sc3.framework = "Django REST",
    sc3.version = "3.0.1",
    sc3.deployment_status = "Running",
    sc3.instance_count = 4,
    sc3.health_status = "Healthy",
    sc3.last_deployment = datetime("2024-03-10T09:00:00"),
    sc3.repository_url = "https://github.com/company/policy-service",
    sc3.created_at = datetime();

// Create API Request Logs
MERGE (arl1:APIRequestLog {log_id: "LOG-2024-001"})
ON CREATE SET arl1.endpoint_id = "API-CUSTOMER-001",
    arl1.request_timestamp = datetime("2024-03-15T14:30:45"),
    arl1.http_method = "GET",
    arl1.request_path = "/api/v1/customers?page=1&limit=50",
    arl1.response_status = 200,
    arl1.response_time_ms = 245,
    arl1.request_ip = "192.168.1.100",
    arl1.user_agent = "Mozilla/5.0",
    arl1.authenticated_user = "api_user_001",
    arl1.created_at = datetime()

MERGE (arl2:APIRequestLog {log_id: "LOG-2024-002"})
ON CREATE SET arl2.endpoint_id = "API-CLAIM-001",
    arl2.request_timestamp = datetime("2024-03-15T14:35:12"),
    arl2.http_method = "POST",
    arl2.request_path = "/api/v1/claims",
    arl2.response_status = 201,
    arl2.response_time_ms = 1250,
    arl2.request_ip = "192.168.1.101",
    arl2.user_agent = "Python/3.9 requests/2.28",
    arl2.authenticated_user = "api_user_002",
    arl2.created_at = datetime();

// Create Background Jobs
MERGE (bj1:BackgroundJob {job_id: "JOB-SYNC-001"})
ON CREATE SET bj1.job_name = "Customer Data Sync",
    bj1.job_type = "Data Synchronization",
    bj1.schedule_pattern = "0 */6 * * *",
    bj1.last_run = datetime("2024-03-15T12:00:00"),
    bj1.next_run = datetime("2024-03-15T18:00:00"),
    bj1.status = "Completed",
    bj1.execution_time_seconds = 320,
    bj1.records_processed = 5000,
    bj1.errors_count = 0,
    bj1.created_at = datetime()

MERGE (bj2:BackgroundJob {job_id: "JOB-REPORT-001"})
ON CREATE SET bj2.job_name = "Daily Analytics Report",
    bj2.job_type = "Report Generation",
    bj2.schedule_pattern = "0 2 * * *",
    bj2.last_run = datetime("2024-03-15T02:00:00"),
    bj2.next_run = datetime("2024-03-16T02:00:00"),
    bj2.status = "Completed",
    bj2.execution_time_seconds = 180,
    bj2.records_processed = 25000,
    bj2.errors_count = 0,
    bj2.created_at = datetime();

// ===================================
// STEP 3: PYTHON INTEGRATION RELATIONSHIPS
// ===================================

// Link API Endpoints to Service Components
MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (api)-[r:IMPLEMENTED_BY]->(sc)
ON CREATE SET r.implementation_version = sc.version,
    r.created_at = datetime()

MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-002"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (api)-[r:IMPLEMENTED_BY]->(sc)
ON CREATE SET r.implementation_version = sc.version,
    r.created_at = datetime()

MATCH (api:APIEndpoint {endpoint_id: "API-CLAIM-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (api)-[r:IMPLEMENTED_BY]->(sc)
ON CREATE SET r.implementation_version = sc.version,
    r.created_at = datetime()

MATCH (api:APIEndpoint {endpoint_id: "API-POLICY-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-POLICY-001"})
MERGE (api)-[r:IMPLEMENTED_BY]->(sc)
ON CREATE SET r.implementation_version = sc.version,
    r.created_at = datetime();

// Link Service Components to Database Connections
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
MERGE (sc)-[r:CONNECTS_TO]->(dbc)
ON CREATE SET r.connection_pool_size = 10,
    r.created_at = datetime()

MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
MERGE (sc)-[r:CONNECTS_TO]->(dbc)
ON CREATE SET r.connection_pool_size = 15,
    r.created_at = datetime()

MATCH (sc:ServiceComponent {component_id: "SVC-POLICY-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
MERGE (sc)-[r:CONNECTS_TO]->(dbc)
ON CREATE SET r.connection_pool_size = 12,
    r.created_at = datetime();

// Link Service Components to System Integrations
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MATCH (si:SystemIntegration {integration_id: "INT-CRM-001"})
MERGE (sc)-[r:INTEGRATES_WITH]->(si)
ON CREATE SET r.integration_type = "Bidirectional",
    r.created_at = datetime()

MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MATCH (si:SystemIntegration {integration_id: "INT-PAYMENT-001"})
MERGE (sc)-[r:INTEGRATES_WITH]->(si)
ON CREATE SET r.integration_type = "Inbound",
    r.created_at = datetime()

MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MATCH (si:SystemIntegration {integration_id: "INT-EMAIL-001"})
MERGE (sc)-[r:INTEGRATES_WITH]->(si)
ON CREATE SET r.integration_type = "Outbound",
    r.created_at = datetime();

// Link API Request Logs to API Endpoints
MATCH (arl:APIRequestLog {log_id: "LOG-2024-001"})
MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
MERGE (arl)-[r:LOGGED_REQUEST_TO]->(api)
ON CREATE SET r.request_timestamp = arl.request_timestamp

MATCH (arl:APIRequestLog {log_id: "LOG-2024-002"})
MATCH (api:APIEndpoint {endpoint_id: "API-CLAIM-001"})
MERGE (arl)-[r:LOGGED_REQUEST_TO]->(api)
ON CREATE SET r.request_timestamp = arl.request_timestamp;

// Link Background Jobs to Service Components
MATCH (bj:BackgroundJob {job_id: "JOB-SYNC-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (bj)-[r:EXECUTED_BY]->(sc)
ON CREATE SET r.job_schedule = bj.schedule_pattern

MATCH (bj:BackgroundJob {job_id: "JOB-REPORT-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (bj)-[r:EXECUTED_BY]->(sc)
ON CREATE SET r.job_schedule = bj.schedule_pattern;

// Link Background Jobs to Database Connections
MATCH (bj:BackgroundJob {job_id: "JOB-SYNC-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
MERGE (bj)-[r:READS_FROM]->(dbc)

MATCH (bj:BackgroundJob {job_id: "JOB-REPORT-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-POSTGRES-ANALYTICS"})
MERGE (bj)-[r:WRITES_TO]->(dbc);

// Link API Endpoints to Customers (API usage tracking)
MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:ACCESSED_VIA_API]->(api)
ON CREATE SET r.first_access = datetime("2024-03-15T14:30:45"),
    r.last_access = datetime("2024-03-15T14:30:45"),
    r.access_count = 1;

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~650 nodes, ~800 relationships with Python integration infrastructure
