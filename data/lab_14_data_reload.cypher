// Neo4j Lab 14 - Data Reload Script
// Complete data setup for Lab 14: Production Infrastructure & Deployment
// Run this script if you need to reload the Lab 14 data state
// Includes Labs 1-13 data + Production Infrastructure

// ===================================
// STEP 1: LOAD LAB 13 FOUNDATION
// ===================================
// This builds on Lab 13 - ensure you have the foundation

// Import Lab 13 data first (this is a prerequisite)
// The lab_13_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: PRODUCTION INFRASTRUCTURE ENTITIES
// ===================================

// Create Deployment Environments
MERGE (de1:DeploymentEnvironment {env_id: "ENV-PROD-001"})
ON CREATE SET de1.environment_name = "Production",
    de1.environment_type = "Production",
    de1.cloud_provider = "AWS",
    de1.region = "us-east-1",
    de1.availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"],
    de1.kubernetes_version = "1.28",
    de1.cluster_name = "insurance-prod-cluster",
    de1.node_count = 12,
    de1.total_cpu_cores = 96,
    de1.total_memory_gb = 384,
    de1.network_type = "VPC",
    de1.created_at = datetime()

MERGE (de2:DeploymentEnvironment {env_id: "ENV-STAGING-001"})
ON CREATE SET de2.environment_name = "Staging",
    de2.environment_type = "Staging",
    de2.cloud_provider = "AWS",
    de2.region = "us-east-1",
    de2.availability_zones = ["us-east-1a", "us-east-1b"],
    de2.kubernetes_version = "1.28",
    de2.cluster_name = "insurance-staging-cluster",
    de2.node_count = 6,
    de2.total_cpu_cores = 48,
    de2.total_memory_gb = 192,
    de2.network_type = "VPC",
    de2.created_at = datetime()

MERGE (de3:DeploymentEnvironment {env_id: "ENV-DEV-001"})
ON CREATE SET de3.environment_name = "Development",
    de3.environment_type = "Development",
    de3.cloud_provider = "AWS",
    de3.region = "us-west-2",
    de3.availability_zones = ["us-west-2a"],
    de3.kubernetes_version = "1.28",
    de3.cluster_name = "insurance-dev-cluster",
    de3.node_count = 3,
    de3.total_cpu_cores = 24,
    de3.total_memory_gb = 96,
    de3.network_type = "VPC",
    de3.created_at = datetime();

// Create Monitoring Alerts
MERGE (ma1:MonitoringAlert {alert_id: "ALERT-2024-001"})
ON CREATE SET ma1.alert_name = "High API Response Time",
    ma1.alert_type = "Performance",
    ma1.alert_severity = "Warning",
    ma1.alert_status = "Triggered",
    ma1.triggered_timestamp = datetime("2024-03-15T14:30:00"),
    ma1.resolved_timestamp = datetime("2024-03-15T14:45:00"),
    ma1.alert_threshold = 1000,
    ma1.alert_value = 1250,
    ma1.alert_metric = "api_response_time_ms",
    ma1.environment_id = "ENV-PROD-001",
    ma1.notification_sent = true,
    ma1.created_at = datetime()

MERGE (ma2:MonitoringAlert {alert_id: "ALERT-2024-002"})
ON CREATE SET ma2.alert_name = "Database Connection Pool Exhausted",
    ma2.alert_type = "Resource",
    ma2.alert_severity = "Critical",
    ma2.alert_status = "Resolved",
    ma2.triggered_timestamp = datetime("2024-03-15T15:00:00"),
    ma2.resolved_timestamp = datetime("2024-03-15T15:15:00"),
    ma2.alert_threshold = 45,
    ma2.alert_value = 50,
    ma2.alert_metric = "db_connection_pool_utilization",
    ma2.environment_id = "ENV-PROD-001",
    ma2.notification_sent = true,
    ma2.created_at = datetime()

MERGE (ma3:MonitoringAlert {alert_id: "ALERT-2024-003"})
ON CREATE SET ma3.alert_name = "High Error Rate",
    ma3.alert_type = "Error",
    ma3.alert_severity = "High",
    ma3.alert_status = "Active",
    ma3.triggered_timestamp = datetime("2024-03-15T16:00:00"),
    ma3.resolved_timestamp = null,
    ma3.alert_threshold = 0.02,
    ma3.alert_value = 0.035,
    ma3.alert_metric = "error_rate_percentage",
    ma3.environment_id = "ENV-PROD-001",
    ma3.notification_sent = true,
    ma3.created_at = datetime();

// Create Load Balancers
MERGE (lb1:LoadBalancer {lb_id: "LB-PROD-WEB"})
ON CREATE SET lb1.lb_name = "Production Web Load Balancer",
    lb1.lb_type = "Application",
    lb1.cloud_provider = "AWS",
    lb1.lb_dns = "insurance-web-prod-lb.company.com",
    lb1.environment_id = "ENV-PROD-001",
    lb1.target_port = 443,
    lb1.health_check_path = "/health",
    lb1.health_check_interval_seconds = 30,
    lb1.connection_draining_seconds = 300,
    lb1.ssl_enabled = true,
    lb1.created_at = datetime()

MERGE (lb2:LoadBalancer {lb_id: "LB-PROD-API"})
ON CREATE SET lb2.lb_name = "Production API Load Balancer",
    lb2.lb_type = "Application",
    lb2.cloud_provider = "AWS",
    lb2.lb_dns = "insurance-api-prod-lb.company.com",
    lb2.environment_id = "ENV-PROD-001",
    lb2.target_port = 443,
    lb2.health_check_path = "/api/health",
    lb2.health_check_interval_seconds = 15,
    lb2.connection_draining_seconds = 180,
    lb2.ssl_enabled = true,
    lb2.created_at = datetime();

// Create Container Images
MERGE (ci1:ContainerImage {image_id: "IMG-CUSTOMER-SVC-V2.1.0"})
ON CREATE SET ci1.image_name = "insurance/customer-service",
    ci1.image_tag = "v2.1.0",
    ci1.image_registry = "ecr.aws.amazon.com",
    ci1.image_size_mb = 245,
    ci1.build_timestamp = datetime("2024-03-01T10:00:00"),
    ci1.base_image = "python:3.11-slim",
    ci1.vulnerability_scan_status = "Passed",
    ci1.critical_vulnerabilities = 0,
    ci1.high_vulnerabilities = 0,
    ci1.created_at = datetime()

MERGE (ci2:ContainerImage {image_id: "IMG-CLAIM-SVC-V1.8.2"})
ON CREATE SET ci2.image_name = "insurance/claims-service",
    ci2.image_tag = "v1.8.2",
    ci2.image_registry = "ecr.aws.amazon.com",
    ci2.image_size_mb = 312,
    ci2.build_timestamp = datetime("2024-02-15T14:30:00"),
    ci2.base_image = "python:3.11-slim",
    ci2.vulnerability_scan_status = "Passed",
    ci2.critical_vulnerabilities = 0,
    ci2.high_vulnerabilities = 1,
    ci2.created_at = datetime();

// Create Deployment Records
MERGE (dr1:DeploymentRecord {deployment_id: "DEPLOY-2024-001"})
ON CREATE SET dr1.deployment_name = "Customer Service v2.1.0 Production Release",
    dr1.deployment_timestamp = datetime("2024-03-01T10:30:00"),
    dr1.deployment_status = "Successful",
    dr1.environment_id = "ENV-PROD-001",
    dr1.component_id = "SVC-CUSTOMER-001",
    dr1.image_id = "IMG-CUSTOMER-SVC-V2.1.0",
    dr1.deployment_strategy = "Rolling Update",
    dr1.rollback_available = true,
    dr1.deployed_by = "DevOps Team",
    dr1.deployment_duration_minutes = 15,
    dr1.instances_deployed = 3,
    dr1.created_at = datetime()

MERGE (dr2:DeploymentRecord {deployment_id: "DEPLOY-2024-002"})
ON CREATE SET dr2.deployment_name = "Claims Service v1.8.2 Production Release",
    dr2.deployment_timestamp = datetime("2024-02-15T15:00:00"),
    dr2.deployment_status = "Successful",
    dr2.environment_id = "ENV-PROD-001",
    dr2.component_id = "SVC-CLAIM-001",
    dr2.image_id = "IMG-CLAIM-SVC-V1.8.2",
    dr2.deployment_strategy = "Blue-Green",
    dr2.rollback_available = true,
    dr2.deployed_by = "CI/CD Pipeline",
    dr2.deployment_duration_minutes = 22,
    dr2.instances_deployed = 5,
    dr2.created_at = datetime();

// Create Infrastructure Resources
MERGE (ir1:InfrastructureResource {resource_id: "RES-DB-NEO4J-PROD"})
ON CREATE SET ir1.resource_name = "Production Neo4j Database Cluster",
    ir1.resource_type = "Database",
    ir1.cloud_provider = "AWS",
    ir1.instance_type = "r6g.4xlarge",
    ir1.instance_count = 3,
    ir1.storage_type = "io2",
    ir1.storage_size_gb = 2000,
    ir1.iops = 16000,
    ir1.environment_id = "ENV-PROD-001",
    ir1.high_availability = true,
    ir1.backup_enabled = true,
    ir1.created_at = datetime()

MERGE (ir2:InfrastructureResource {resource_id: "RES-CACHE-REDIS-PROD"})
ON CREATE SET ir2.resource_name = "Production Redis Cache",
    ir2.resource_type = "Cache",
    ir2.cloud_provider = "AWS",
    ir2.instance_type = "r6g.xlarge",
    ir2.instance_count = 2,
    ir2.memory_gb = 32,
    ir2.environment_id = "ENV-PROD-001",
    ir2.high_availability = true,
    ir2.backup_enabled = true,
    ir2.created_at = datetime();

// Create Health Check Records
MERGE (hc1:HealthCheck {check_id: "HEALTH-2024-001"})
ON CREATE SET hc1.check_name = "Customer Service Health Check",
    hc1.check_timestamp = datetime("2024-03-15T14:00:00"),
    hc1.check_status = "Healthy",
    hc1.response_time_ms = 45,
    hc1.component_id = "SVC-CUSTOMER-001",
    hc1.environment_id = "ENV-PROD-001",
    hc1.endpoint_url = "/health",
    hc1.status_code = 200,
    hc1.created_at = datetime()

MERGE (hc2:HealthCheck {check_id: "HEALTH-2024-002"})
ON CREATE SET hc2.check_name = "Claims Service Health Check",
    hc2.check_timestamp = datetime("2024-03-15T14:00:00"),
    hc2.check_status = "Degraded",
    hc2.response_time_ms = 1250,
    hc2.component_id = "SVC-CLAIM-001",
    hc2.environment_id = "ENV-PROD-001",
    hc2.endpoint_url = "/health",
    hc2.status_code = 200,
    hc2.created_at = datetime();

// Create Backup Records
MERGE (br1:BackupRecord {backup_id: "BACKUP-2024-001"})
ON CREATE SET br1.backup_name = "Neo4j Production Daily Backup",
    br1.backup_timestamp = datetime("2024-03-15T02:00:00"),
    br1.backup_type = "Full",
    br1.backup_status = "Completed",
    br1.backup_size_gb = 450,
    br1.backup_duration_minutes = 45,
    br1.backup_location = "s3://insurance-backups/neo4j/2024-03-15",
    br1.retention_days = 30,
    br1.verified = true,
    br1.created_at = datetime()

MERGE (br2:BackupRecord {backup_id: "BACKUP-2024-002"})
ON CREATE SET br2.backup_name = "Redis Production Snapshot",
    br2.backup_timestamp = datetime("2024-03-15T03:00:00"),
    br2.backup_type = "Snapshot",
    br2.backup_status = "Completed",
    br2.backup_size_gb = 12,
    br2.backup_duration_minutes = 5,
    br2.backup_location = "s3://insurance-backups/redis/2024-03-15",
    br2.retention_days = 7,
    br2.verified = true,
    br2.created_at = datetime();

// ===================================
// STEP 3: PRODUCTION INFRASTRUCTURE RELATIONSHIPS
// ===================================

// Link Service Components to Deployment Environments
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (sc)-[r:DEPLOYED_TO]->(de)
ON CREATE SET r.deployment_timestamp = datetime("2024-03-01T10:30:00"),
    r.instance_count = 3

MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (sc)-[r:DEPLOYED_TO]->(de)
ON CREATE SET r.deployment_timestamp = datetime("2024-02-15T15:00:00"),
    r.instance_count = 5

MATCH (sc:ServiceComponent {component_id: "SVC-POLICY-001"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (sc)-[r:DEPLOYED_TO]->(de)
ON CREATE SET r.deployment_timestamp = datetime("2024-03-10T09:00:00"),
    r.instance_count = 4;

// Link Monitoring Alerts to Deployment Environments
MATCH (ma:MonitoringAlert {alert_id: "ALERT-2024-001"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (ma)-[r:TRIGGERED_IN_ENVIRONMENT]->(de)
ON CREATE SET r.triggered_timestamp = ma.triggered_timestamp

MATCH (ma:MonitoringAlert {alert_id: "ALERT-2024-002"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (ma)-[r:TRIGGERED_IN_ENVIRONMENT]->(de)
ON CREATE SET r.triggered_timestamp = ma.triggered_timestamp

MATCH (ma:MonitoringAlert {alert_id: "ALERT-2024-003"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (ma)-[r:TRIGGERED_IN_ENVIRONMENT]->(de)
ON CREATE SET r.triggered_timestamp = ma.triggered_timestamp;

// Link Monitoring Alerts to Service Components
MATCH (ma:MonitoringAlert {alert_id: "ALERT-2024-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (ma)-[r:RELATES_TO_COMPONENT]->(sc)
ON CREATE SET r.alert_metric = ma.alert_metric

MATCH (ma:MonitoringAlert {alert_id: "ALERT-2024-002"})
MATCH (dbc:DatabaseConnection {connection_id: "DB-NEO4J-PROD"})
MERGE (ma)-[r:RELATES_TO_DATABASE]->(dbc)
ON CREATE SET r.alert_metric = ma.alert_metric;

// Link Load Balancers to Deployment Environments
MATCH (lb:LoadBalancer {lb_id: "LB-PROD-WEB"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (lb)-[r:BALANCES_TRAFFIC_IN]->(de)

MATCH (lb:LoadBalancer {lb_id: "LB-PROD-API"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (lb)-[r:BALANCES_TRAFFIC_IN]->(de);

// Link Load Balancers to Service Components
MATCH (lb:LoadBalancer {lb_id: "LB-PROD-API"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (lb)-[r:ROUTES_TO_SERVICE]->(sc)
ON CREATE SET r.health_check_enabled = true

MATCH (lb:LoadBalancer {lb_id: "LB-PROD-API"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (lb)-[r:ROUTES_TO_SERVICE]->(sc)
ON CREATE SET r.health_check_enabled = true;

// Link Deployment Records to Container Images
MATCH (dr:DeploymentRecord {deployment_id: "DEPLOY-2024-001"})
MATCH (ci:ContainerImage {image_id: "IMG-CUSTOMER-SVC-V2.1.0"})
MERGE (dr)-[r:DEPLOYED_IMAGE]->(ci)
ON CREATE SET r.deployment_timestamp = dr.deployment_timestamp

MATCH (dr:DeploymentRecord {deployment_id: "DEPLOY-2024-002"})
MATCH (ci:ContainerImage {image_id: "IMG-CLAIM-SVC-V1.8.2"})
MERGE (dr)-[r:DEPLOYED_IMAGE]->(ci)
ON CREATE SET r.deployment_timestamp = dr.deployment_timestamp;

// Link Deployment Records to Service Components
MATCH (dr:DeploymentRecord {deployment_id: "DEPLOY-2024-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (dr)-[r:UPDATED_COMPONENT]->(sc)
ON CREATE SET r.previous_version = "2.0.5",
    r.new_version = "2.1.0"

MATCH (dr:DeploymentRecord {deployment_id: "DEPLOY-2024-002"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (dr)-[r:UPDATED_COMPONENT]->(sc)
ON CREATE SET r.previous_version = "1.8.1",
    r.new_version = "1.8.2";

// Link Infrastructure Resources to Deployment Environments
MATCH (ir:InfrastructureResource {resource_id: "RES-DB-NEO4J-PROD"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (ir)-[r:PROVISIONED_IN]->(de)

MATCH (ir:InfrastructureResource {resource_id: "RES-CACHE-REDIS-PROD"})
MATCH (de:DeploymentEnvironment {env_id: "ENV-PROD-001"})
MERGE (ir)-[r:PROVISIONED_IN]->(de);

// Link Health Checks to Service Components
MATCH (hc:HealthCheck {check_id: "HEALTH-2024-001"})
MATCH (sc:ServiceComponent {component_id: "SVC-CUSTOMER-001"})
MERGE (hc)-[r:CHECKS_HEALTH_OF]->(sc)
ON CREATE SET r.check_timestamp = hc.check_timestamp

MATCH (hc:HealthCheck {check_id: "HEALTH-2024-002"})
MATCH (sc:ServiceComponent {component_id: "SVC-CLAIM-001"})
MERGE (hc)-[r:CHECKS_HEALTH_OF]->(sc)
ON CREATE SET r.check_timestamp = hc.check_timestamp;

// Link Backup Records to Infrastructure Resources
MATCH (br:BackupRecord {backup_id: "BACKUP-2024-001"})
MATCH (ir:InfrastructureResource {resource_id: "RES-DB-NEO4J-PROD"})
MERGE (br)-[r:BACKUP_OF]->(ir)
ON CREATE SET r.backup_timestamp = br.backup_timestamp

MATCH (br:BackupRecord {backup_id: "BACKUP-2024-002"})
MATCH (ir:InfrastructureResource {resource_id: "RES-CACHE-REDIS-PROD"})
MERGE (br)-[r:BACKUP_OF]->(ir)
ON CREATE SET r.backup_timestamp = br.backup_timestamp;

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~800 nodes, ~1000 relationships with production infrastructure
