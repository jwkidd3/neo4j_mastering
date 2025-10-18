// Neo4j Lab 15 - Data Reload Script
// Complete data setup for Lab 15: Complete Platform Integration
// Run this script if you need to reload the Lab 15 data state
// Includes Labs 1-14 data + Platform Integration Infrastructure

// ===================================
// STEP 1: LOAD LAB 14 FOUNDATION
// ===================================
// This builds on Lab 14 - ensure you have the foundation

// Import Lab 14 data first (this is a prerequisite)
// The lab_14_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: PLATFORM INTEGRATION ENTITIES
// ===================================

// Create Integration Workflows
MERGE (iw1:IntegrationWorkflow {workflow_id: "WF-ONBOARD-001"})
ON CREATE SET iw1.workflow_name = "Customer Onboarding Workflow",
    iw1.workflow_type = "Customer Lifecycle",
    iw1.workflow_status = "Active",
    iw1.trigger_type = "Event-Driven",
    iw1.steps_count = 8,
    iw1.avg_execution_time_minutes = 12,
    iw1.success_rate = 0.96,
    iw1.total_executions = 1250,
    iw1.created_date = date("2024-01-01"),
    iw1.last_updated = datetime("2024-03-15T14:00:00"),
    iw1.created_at = datetime()

MERGE (iw2:IntegrationWorkflow {workflow_id: "WF-CLAIM-PROCESS-001"})
ON CREATE SET iw2.workflow_name = "Claims Processing Workflow",
    iw2.workflow_type = "Claims Management",
    iw2.workflow_status = "Active",
    iw2.trigger_type = "Manual/API",
    iw2.steps_count = 12,
    iw2.avg_execution_time_minutes = 45,
    iw2.success_rate = 0.92,
    iw2.total_executions = 850,
    iw2.created_date = date("2024-01-01"),
    iw2.last_updated = datetime("2024-03-15T14:00:00"),
    iw2.created_at = datetime()

MERGE (iw3:IntegrationWorkflow {workflow_id: "WF-RENEWAL-001"})
ON CREATE SET iw3.workflow_name = "Policy Renewal Workflow",
    iw3.workflow_type = "Policy Lifecycle",
    iw3.workflow_status = "Active",
    iw3.trigger_type = "Scheduled",
    iw3.steps_count = 6,
    iw3.avg_execution_time_minutes = 8,
    iw3.success_rate = 0.98,
    iw3.total_executions = 3200,
    iw3.created_date = date("2024-01-01"),
    iw3.last_updated = datetime("2024-03-15T14:00:00"),
    iw3.created_at = datetime();

// Create Data Pipelines
MERGE (dp1:DataPipeline {pipeline_id: "DP-ETL-001"})
ON CREATE SET dp1.pipeline_name = "Customer Data ETL Pipeline",
    dp1.pipeline_type = "ETL",
    dp1.source_system = "Salesforce CRM",
    dp1.target_system = "Neo4j Insurance DB",
    dp1.schedule = "0 */6 * * *",
    dp1.last_run = datetime("2024-03-15T12:00:00"),
    dp1.next_run = datetime("2024-03-15T18:00:00"),
    dp1.status = "Success",
    dp1.records_processed = 5000,
    dp1.execution_time_minutes = 18,
    dp1.data_quality_score = 0.98,
    dp1.created_at = datetime()

MERGE (dp2:DataPipeline {pipeline_id: "DP-ANALYTICS-001"})
ON CREATE SET dp2.pipeline_name = "Analytics Data Aggregation Pipeline",
    dp2.pipeline_type = "Aggregation",
    dp2.source_system = "Neo4j Insurance DB",
    dp2.target_system = "PostgreSQL Analytics",
    dp2.schedule = "0 2 * * *",
    dp2.last_run = datetime("2024-03-15T02:00:00"),
    dp2.next_run = datetime("2024-03-16T02:00:00"),
    dp2.status = "Success",
    dp2.records_processed = 25000,
    dp2.execution_time_minutes = 45,
    dp2.data_quality_score = 0.99,
    dp2.created_at = datetime()

MERGE (dp3:DataPipeline {pipeline_id: "DP-REALTIME-001"})
ON CREATE SET dp3.pipeline_name = "Real-time Event Streaming Pipeline",
    dp3.pipeline_type = "Stream Processing",
    dp3.source_system = "Kafka Event Stream",
    dp3.target_system = "Neo4j Insurance DB",
    dp3.schedule = "Continuous",
    dp3.last_run = datetime("2024-03-15T16:45:00"),
    dp3.next_run = null,
    dp3.status = "Running",
    dp3.records_processed = 125000,
    dp3.execution_time_minutes = null,
    dp3.data_quality_score = 0.97,
    dp3.created_at = datetime();

// Create Message Queues
MERGE (mq1:MessageQueue {queue_id: "MQ-CLAIMS-001"})
ON CREATE SET mq1.queue_name = "claims-processing-queue",
    mq1.queue_type = "FIFO",
    mq1.message_retention_days = 14,
    mq1.max_message_size_kb = 256,
    mq1.current_message_count = 45,
    mq1.avg_processing_time_seconds = 2.5,
    mq1.dead_letter_queue = "claims-processing-dlq",
    mq1.created_at = datetime()

MERGE (mq2:MessageQueue {queue_id: "MQ-NOTIFICATIONS-001"})
ON CREATE SET mq2.queue_name = "customer-notifications-queue",
    mq2.queue_type = "Standard",
    mq2.message_retention_days = 4,
    mq2.max_message_size_kb = 64,
    mq2.current_message_count = 152,
    mq2.avg_processing_time_seconds = 0.8,
    mq2.dead_letter_queue = "notifications-dlq",
    mq2.created_at = datetime();

// Create Event Bus Topics
MERGE (eb1:EventBusTopic {topic_id: "TOPIC-POLICY-EVENTS"})
ON CREATE SET eb1.topic_name = "insurance.policy.events",
    eb1.topic_type = "Event Bus",
    eb1.event_types = ["PolicyCreated", "PolicyUpdated", "PolicyRenewed", "PolicyCancelled"],
    eb1.subscriber_count = 5,
    eb1.avg_publish_rate_per_minute = 25,
    eb1.retention_hours = 48,
    eb1.created_at = datetime()

MERGE (eb2:EventBusTopic {topic_id: "TOPIC-CLAIM-EVENTS"})
ON CREATE SET eb2.topic_name = "insurance.claim.events",
    eb2.topic_type = "Event Bus",
    eb2.event_types = ["ClaimSubmitted", "ClaimApproved", "ClaimRejected", "ClaimPaid"],
    eb2.subscriber_count = 7,
    eb2.avg_publish_rate_per_minute = 12,
    eb2.retention_hours = 72,
    eb2.created_at = datetime();

// Create Data Transformation Rules
MERGE (dtr1:DataTransformationRule {rule_id: "TRANS-CUSTOMER-001"})
ON CREATE SET dtr1.rule_name = "Customer Address Standardization",
    dtr1.rule_type = "Data Cleansing",
    dtr1.source_field = "customer_address",
    dtr1.target_field = "standardized_address",
    dtr1.transformation_logic = "USPS Address Validation API",
    dtr1.is_active = true,
    dtr1.success_rate = 0.95,
    dtr1.created_at = datetime()

MERGE (dtr2:DataTransformationRule {rule_id: "TRANS-CLAIM-001"})
ON CREATE SET dtr2.rule_name = "Claim Amount Normalization",
    dtr2.rule_type = "Data Normalization",
    dtr2.source_field = "claim_amount",
    dtr2.target_field = "normalized_claim_amount",
    dtr2.transformation_logic = "Currency conversion to USD",
    dtr2.is_active = true,
    dtr2.success_rate = 0.99,
    dtr2.created_at = datetime();

// Create API Gateways
MERGE (apig1:APIGateway {gateway_id: "APIGW-PROD-001"})
ON CREATE SET apig1.gateway_name = "Production API Gateway",
    apig1.gateway_url = "https://api.insurance.company.com",
    apig1.gateway_type = "REST",
    apig1.authentication_methods = ["OAuth2", "API Key"],
    apig1.rate_limit_per_minute = 10000,
    apig1.ssl_enabled = true,
    apig1.cors_enabled = true,
    apig1.request_logging = true,
    apig1.created_at = datetime()

MERGE (apig2:APIGateway {gateway_id: "APIGW-INTERNAL-001"})
ON CREATE SET apig2.gateway_name = "Internal Services Gateway",
    apig2.gateway_url = "https://internal-api.insurance.company.com",
    apig2.gateway_type = "GraphQL",
    apig2.authentication_methods = ["mTLS"],
    apig2.rate_limit_per_minute = 50000,
    apig2.ssl_enabled = true,
    apig2.cors_enabled = false,
    apig2.request_logging = true,
    apig2.created_at = datetime();

// Create Webhook Endpoints
MERGE (wh1:WebhookEndpoint {webhook_id: "WEBHOOK-PAYMENT-001"})
ON CREATE SET wh1.webhook_name = "Payment Gateway Webhook",
    wh1.webhook_url = "https://api.insurance.company.com/webhooks/payment",
    wh1.webhook_events = ["payment.success", "payment.failed", "payment.refunded"],
    wh1.secret_key_configured = true,
    wh1.retry_policy = "Exponential Backoff",
    wh1.max_retries = 3,
    wh1.timeout_seconds = 30,
    wh1.is_active = true,
    wh1.created_at = datetime()

MERGE (wh2:WebhookEndpoint {webhook_id: "WEBHOOK-CRM-001"})
ON CREATE SET wh2.webhook_name = "CRM Update Webhook",
    wh2.webhook_url = "https://api.insurance.company.com/webhooks/crm",
    wh2.webhook_events = ["customer.created", "customer.updated", "policy.created"],
    wh2.secret_key_configured = true,
    wh2.retry_policy = "Fixed Interval",
    wh2.max_retries = 5,
    wh2.timeout_seconds = 60,
    wh2.is_active = true,
    wh2.created_at = datetime();

// Create Batch Jobs
MERGE (btj1:BatchJob {batch_id: "BATCH-BILLING-001"})
ON CREATE SET btj1.job_name = "Monthly Premium Billing",
    btj1.job_type = "Billing",
    btj1.schedule = "0 0 1 * *",
    btj1.last_run = datetime("2024-03-01T00:00:00"),
    btj1.next_run = datetime("2024-04-01T00:00:00"),
    btj1.status = "Completed",
    btj1.records_processed = 15000,
    btj1.execution_time_minutes = 120,
    btj1.success_count = 14850,
    btj1.failure_count = 150,
    btj1.created_at = datetime()

MERGE (btj2:BatchJob {batch_id: "BATCH-RENEWAL-001"})
ON CREATE SET btj2.job_name = "Policy Renewal Notices",
    btj2.job_type = "Communication",
    btj2.schedule = "0 6 * * *",
    btj2.last_run = datetime("2024-03-15T06:00:00"),
    btj2.next_run = datetime("2024-03-16T06:00:00"),
    btj2.status = "Completed",
    btj2.records_processed = 450,
    btj2.execution_time_minutes = 15,
    btj2.success_count = 445,
    btj2.failure_count = 5,
    btj2.created_at = datetime();

// ===================================
// STEP 3: PLATFORM INTEGRATION RELATIONSHIPS
// ===================================

// Link Integration Workflows to Service Components
MATCH (iw:IntegrationWorkflow {workflow_id: "WF-ONBOARD-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (iw)-[r:EXECUTED_BY_SERVICE]->(sc)
ON CREATE SET r.avg_execution_time = iw.avg_execution_time_minutes

MATCH (iw:IntegrationWorkflow {workflow_id: "WF-CLAIM-PROCESS-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (iw)-[r:EXECUTED_BY_SERVICE]->(sc)
ON CREATE SET r.avg_execution_time = iw.avg_execution_time_minutes;

// Link Data Pipelines to System Integrations
MATCH (dp:DataPipeline {pipeline_id: "DP-ETL-001"})
MATCH (si:SystemIntegration {integration_id: "INT-CRM-001"})
MERGE (dp)-[r:EXTRACTS_FROM]->(si)
ON CREATE SET r.extraction_frequency = dp.schedule

MATCH (dp:DataPipeline {pipeline_id: "DP-ANALYTICS-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
MERGE (dp)-[r:READS_FROM]->(dbc)

MATCH (dp:DataPipeline {pipeline_id: "DP-ANALYTICS-001"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-POSTGRES-ANALYTICS"})
MERGE (dp)-[r:WRITES_TO]->(dbc);

// Link Data Pipelines to Data Transformation Rules
MATCH (dp:DataPipeline {pipeline_id: "DP-ETL-001"})
MATCH (dtr:DataTransformationRule {rule_id: "TRANS-CUSTOMER-001"})
MERGE (dp)-[r:APPLIES_RULE]->(dtr)
ON CREATE SET r.rule_priority = 1

MATCH (dp:DataPipeline {pipeline_id: "DP-REALTIME-001"})
MATCH (dtr:DataTransformationRule {rule_id: "TRANS-CLAIM-001"})
MERGE (dp)-[r:APPLIES_RULE]->(dtr)
ON CREATE SET r.rule_priority = 1;

// Link Message Queues to Service Components
MATCH (mq:MessageQueue {queue_id: "MQ-CLAIMS-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (sc)-[r:CONSUMES_FROM_QUEUE]->(mq)
ON CREATE SET r.consumer_group = "claims-processors"

MATCH (mq:MessageQueue {queue_id: "MQ-NOTIFICATIONS-001"})
MATCH (si:SystemIntegration {integration_id: "INT-EMAIL-001"})
MERGE (si)-[r:CONSUMES_FROM_QUEUE]->(mq)
ON CREATE SET r.consumer_group = "notification-senders";

// Link Event Bus Topics to Service Components
MATCH (eb:EventBusTopic {topic_id: "TOPIC-POLICY-EVENTS"})
MATCH (sc:ServiceComponent {component_id: "SVC-POLICY-001"})
MERGE (sc)-[r:PUBLISHES_TO]->(eb)
ON CREATE SET r.event_types = eb.event_types

MATCH (eb:EventBusTopic {topic_id: "TOPIC-CLAIM-EVENTS"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (sc)-[r:PUBLISHES_TO]->(eb)
ON CREATE SET r.event_types = eb.event_types;

// Subscribe Service Components to Event Topics
MATCH (eb:EventBusTopic {topic_id: "TOPIC-POLICY-EVENTS"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (sc)-[r:SUBSCRIBES_TO]->(eb)
ON CREATE SET r.subscription_filter = "PolicyCreated,PolicyUpdated"

MATCH (eb:EventBusTopic {topic_id: "TOPIC-CLAIM-EVENTS"})
MATCH (iw:IntegrationWorkflow {workflow_id: "WF-CLAIM-PROCESS-001"})
MERGE (iw)-[r:TRIGGERED_BY_TOPIC]->(eb)
ON CREATE SET r.trigger_events = ["ClaimSubmitted"];

// Link API Gateways to API Endpoints
MATCH (apig:APIGateway {gateway_id: "APIGW-PROD-001"})
MATCH (api:APIEndpoint {endpoint_id: "API-CUSTOMER-001"})
MERGE (apig)-[r:ROUTES_REQUEST_TO]->(api)
ON CREATE SET r.route_priority = 100

MATCH (apig:APIGateway {gateway_id: "APIGW-PROD-001"})
MATCH (api:APIEndpoint {endpoint_id: "API-CLAIM-001"})
MERGE (apig)-[r:ROUTES_REQUEST_TO]->(api)
ON CREATE SET r.route_priority = 100;

// Link Webhooks to System Integrations
MATCH (wh:WebhookEndpoint {webhook_id: "WEBHOOK-PAYMENT-001"})
MATCH (si:SystemIntegration {integration_id: "INT-PAYMENT-001"})
MERGE (wh)-[r:RECEIVES_FROM]->(si)
ON CREATE SET r.webhook_events = wh.webhook_events

MATCH (wh:WebhookEndpoint {webhook_id: "WEBHOOK-CRM-001"})
MATCH (si:SystemIntegration {integration_id: "INT-CRM-001"})
MERGE (wh)-[r:RECEIVES_FROM]->(si)
ON CREATE SET r.webhook_events = wh.webhook_events;

// Link Batch Jobs to Integration Workflows
MATCH (btj:BatchJob {batch_id: "BATCH-BILLING-001"})
MATCH (iw:IntegrationWorkflow {workflow_id: "WF-RENEWAL-001"})
MERGE (btj)-[r:TRIGGERS_WORKFLOW]->(iw)
ON CREATE SET r.trigger_condition = "Billing cycle complete"

MATCH (btj:BatchJob {batch_id: "BATCH-RENEWAL-001"})
MATCH (iw:IntegrationWorkflow {workflow_id: "WF-RENEWAL-001"})
MERGE (btj)-[r:TRIGGERS_WORKFLOW]->(iw)
ON CREATE SET r.trigger_condition = "Renewal notice scheduled";

// Link Integration Workflows to Customers (workflow executions)
MATCH (iw:IntegrationWorkflow {workflow_id: "WF-ONBOARD-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:PROCESSED_BY_WORKFLOW]->(iw)
ON CREATE SET r.workflow_execution_date = date("2024-01-15"),
    r.execution_status = "Completed",
    r.execution_time_minutes = 10;

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~850 nodes, ~1100 relationships with platform integration infrastructure
