# Lab 9: Enterprise Data Modeling Workshop

**Duration:** 70 minutes  
**Objective:** Design enterprise-grade graph data models with temporal versioning, security, and scalability patterns

## Prerequisites

- Completed Labs 1-8 successfully with advanced graph analytics experience
- Understanding of complex graph algorithms and community detection from Lab 8
- Familiarity with business intelligence and performance optimization
- Knowledge of production system requirements and constraints

## Learning Outcomes

By the end of this lab, you will:
- Redesign social network data models using enterprise architectural patterns
- Implement comprehensive temporal data modeling with versioning and audit trails
- Build role-based access control (RBAC) systems within graph structures
- Create scalable data import and ETL processes for large-scale operations
- Design data quality validation frameworks and constraint systems
- Implement multi-tenant architectures for enterprise graph applications
- Build event sourcing patterns for complete audit and replay capabilities
- Design performance-optimized schemas for production workloads

## Part 1: Enterprise Architecture Patterns (20 minutes)

### Step 1: Clear Existing Data and Design Enterprise Schema
```cypher
// Clear previous lab data to start with enterprise patterns
MATCH (n) DETACH DELETE n

// Create enterprise-grade user management system
CREATE CONSTRAINT user_id_unique FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT email_unique FOR (u:User) REQUIRE u.email IS UNIQUE;
CREATE CONSTRAINT tenant_id_unique FOR (t:Tenant) REQUIRE t.tenantId IS UNIQUE;

// Create indexes for performance
CREATE INDEX user_email_index FOR (u:User) ON (u.email);
CREATE INDEX user_tenant_index FOR (u:User) ON (u.tenantId);
CREATE INDEX user_status_index FOR (u:User) ON (u.status);
CREATE INDEX audit_timestamp_index FOR (a:AuditEvent) ON (a.timestamp);
```

### Step 2: Multi-Tenant Enterprise User Model
```cypher
// Create enterprise tenants (organizations)
CREATE (corp:Tenant {
  tenantId: 'corp-001',
  name: 'TechCorp Enterprise',
  domain: 'techcorp.com',
  subscriptionTier: 'Enterprise',
  maxUsers: 10000,
  features: ['advanced_analytics', 'custom_integrations', 'priority_support'],
  createdAt: datetime(),
  status: 'Active',
  dataResidency: 'US-East',
  complianceRequirements: ['SOX', 'GDPR', 'SOC2']
})

CREATE (startup:Tenant {
  tenantId: 'startup-002',
  name: 'InnovateLab',
  domain: 'innovatelab.io',
  subscriptionTier: 'Professional',
  maxUsers: 500,
  features: ['basic_analytics', 'api_access'],
  createdAt: datetime(),
  status: 'Active',
  dataResidency: 'EU-West',
  complianceRequirements: ['GDPR']
})

// Create enterprise roles and permissions
CREATE (sysAdmin:Role {
  roleId: 'system_admin',
  name: 'System Administrator',
  description: 'Full system access across all tenants',
  permissions: ['*'],
  scope: 'GLOBAL',
  createdAt: datetime()
})

CREATE (tenantAdmin:Role {
  roleId: 'tenant_admin',
  name: 'Tenant Administrator',
  description: 'Full access within tenant boundary',
  permissions: ['user.create', 'user.update', 'user.delete', 'data.export', 'analytics.view'],
  scope: 'TENANT',
  createdAt: datetime()
})

CREATE (dataAnalyst:Role {
  roleId: 'data_analyst',
  name: 'Data Analyst',
  description: 'Read-only access to analytics and reporting',
  permissions: ['analytics.view', 'reports.create', 'data.export'],
  scope: 'TENANT',
  createdAt: datetime()
})

CREATE (standardUser:Role {
  roleId: 'standard_user',
  name: 'Standard User',
  description: 'Basic user privileges',
  permissions: ['profile.view', 'profile.update', 'content.create', 'content.view'],
  scope: 'USER',
  createdAt: datetime()
})

RETURN 'Enterprise roles and tenants created' AS status
```

### Step 3: Enterprise User Profiles with Versioning
```cypher
// Create enterprise users with comprehensive profiles
MATCH (corp:Tenant {tenantId: 'corp-001'})
MATCH (tenantAdmin:Role {roleId: 'tenant_admin'})
MATCH (dataAnalyst:Role {roleId: 'data_analyst'})
MATCH (standardUser:Role {roleId: 'standard_user'})

CREATE (alice:User {
  userId: 'alice.johnson.001',
  tenantId: 'corp-001',
  email: 'alice.johnson@techcorp.com',
  employeeId: 'EMP-001234',
  firstName: 'Alice',
  lastName: 'Johnson',
  displayName: 'Alice Johnson',
  department: 'Engineering',
  jobTitle: 'Senior Software Engineer',
  managerId: 'mgr-005',
  location: 'San Francisco, CA',
  timeZone: 'America/Los_Angeles',
  startDate: date('2020-03-15'),
  status: 'Active',
  securityClearance: 'Standard',
  preferredLanguage: 'en-US',
  createdAt: datetime(),
  lastLoginAt: datetime(),
  profileVersion: 1,
  dataClassification: 'Internal'
})

CREATE (bob:User {
  userId: 'bob.chen.002',
  tenantId: 'corp-001', 
  email: 'bob.chen@techcorp.com',
  employeeId: 'EMP-001235',
  firstName: 'Bob',
  lastName: 'Chen',
  displayName: 'Bob Chen',
  department: 'Analytics',
  jobTitle: 'Principal Data Scientist',
  managerId: 'mgr-007',
  location: 'New York, NY',
  timeZone: 'America/New_York',
  startDate: date('2019-08-22'),
  status: 'Active',
  securityClearance: 'Confidential',
  preferredLanguage: 'en-US',
  createdAt: datetime(),
  lastLoginAt: datetime(),
  profileVersion: 1,
  dataClassification: 'Confidential'
})

// Create tenant relationships
CREATE (alice)-[:BELONGS_TO {assignedAt: datetime(), status: 'Active'}]->(corp)
CREATE (bob)-[:BELONGS_TO {assignedAt: datetime(), status: 'Active'}]->(corp)

// Create role assignments with temporal validity
CREATE (alice)-[:HAS_ROLE {
  assignedAt: datetime(),
  assignedBy: 'system',
  validFrom: datetime(),
  validTo: datetime() + duration('P1Y'),
  status: 'Active'
}]->(standardUser)

CREATE (bob)-[:HAS_ROLE {
  assignedAt: datetime(),
  assignedBy: 'system', 
  validFrom: datetime(),
  validTo: datetime() + duration('P1Y'),
  status: 'Active'
}]->(dataAnalyst)

RETURN 'Enterprise users created with role assignments' AS status
```

### Step 4: Organizational Hierarchy and Reporting Structure
```cypher
// Create organizational hierarchy
MATCH (corp:Tenant {tenantId: 'corp-001'})

CREATE (engineering:Department {
  departmentId: 'ENG-001',
  tenantId: 'corp-001',
  name: 'Engineering',
  description: 'Software development and technical operations',
  costCenter: 'CC-1001',
  budget: 15000000,
  headCount: 125,
  createdAt: datetime()
})

CREATE (analytics:Department {
  departmentId: 'ANA-002', 
  tenantId: 'corp-001',
  name: 'Data Analytics',
  description: 'Business intelligence and data science',
  costCenter: 'CC-1002',
  budget: 8000000,
  headCount: 45,
  createdAt: datetime()
})

CREATE (product:Department {
  departmentId: 'PRD-003',
  tenantId: 'corp-001', 
  name: 'Product Management',
  description: 'Product strategy and roadmap',
  costCenter: 'CC-1003',
  budget: 5000000,
  headCount: 30,
  createdAt: datetime()
})

// Create management hierarchy
CREATE (cto:User {
  userId: 'sarah.kim.cto',
  tenantId: 'corp-001',
  email: 'sarah.kim@techcorp.com',
  employeeId: 'EMP-C001',
  firstName: 'Sarah',
  lastName: 'Kim',
  jobTitle: 'Chief Technology Officer',
  department: 'Executive',
  level: 'C-Level',
  status: 'Active',
  createdAt: datetime()
})

CREATE (engDir:User {
  userId: 'mike.rodriguez.dir',
  tenantId: 'corp-001',
  email: 'mike.rodriguez@techcorp.com', 
  employeeId: 'EMP-D001',
  firstName: 'Mike',
  lastName: 'Rodriguez',
  jobTitle: 'Director of Engineering',
  department: 'Engineering',
  level: 'Director',
  status: 'Active',
  createdAt: datetime()
})

// Create reporting relationships
MATCH (alice:User {userId: 'alice.johnson.001'})
MATCH (bob:User {userId: 'bob.chen.002'})
MATCH (cto:User {userId: 'sarah.kim.cto'})
MATCH (engDir:User {userId: 'mike.rodriguez.dir'})
MATCH (engineering:Department {departmentId: 'ENG-001'})
MATCH (analytics:Department {departmentId: 'ANA-002'})

CREATE (alice)-[:MEMBER_OF {joinedAt: date('2020-03-15'), status: 'Active'}]->(engineering)
CREATE (bob)-[:MEMBER_OF {joinedAt: date('2019-08-22'), status: 'Active'}]->(analytics)
CREATE (alice)-[:REPORTS_TO {since: date('2020-03-15'), reportingType: 'Direct'}]->(engDir)
CREATE (engDir)-[:REPORTS_TO {since: date('2018-01-15'), reportingType: 'Direct'}]->(cto)

// Create department relationships
CREATE (engineering)-[:REPORTS_TO {establishedAt: datetime()}]->(cto)
CREATE (analytics)-[:REPORTS_TO {establishedAt: datetime()}]->(cto)

RETURN 'Organizational hierarchy created' AS status
```

## Part 2: Temporal Data Modeling and Versioning (20 minutes)

### Step 5: Implement Comprehensive Versioning System
```cypher
// Create version tracking for user profiles
MATCH (alice:User {userId: 'alice.johnson.001'})

// Create current profile version
CREATE (aliceV1:UserProfile {
  userId: 'alice.johnson.001',
  version: 1,
  firstName: 'Alice',
  lastName: 'Johnson',
  jobTitle: 'Senior Software Engineer',
  department: 'Engineering',
  location: 'San Francisco, CA',
  phone: '+1-555-0123',
  skills: ['Python', 'Java', 'React', 'PostgreSQL', 'Neo4j'],
  certifications: ['AWS Solutions Architect', 'Certified Kubernetes Administrator'],
  validFrom: datetime(),
  validTo: null,  // Current version
  createdAt: datetime(),
  createdBy: 'alice.johnson.001',
  changeReason: 'Initial profile creation'
})

// Link user to current profile version
CREATE (alice)-[:CURRENT_PROFILE]->(aliceV1)
CREATE (alice)-[:PROFILE_HISTORY]->(aliceV1)

// Simulate profile update - job promotion
WITH datetime() + duration('P90D') AS promotionDate
CREATE (aliceV2:UserProfile {
  userId: 'alice.johnson.001',
  version: 2,
  firstName: 'Alice',
  lastName: 'Johnson',
  jobTitle: 'Staff Software Engineer',  // Promoted
  department: 'Engineering',
  location: 'San Francisco, CA',
  phone: '+1-555-0123',
  skills: ['Python', 'Java', 'React', 'PostgreSQL', 'Neo4j', 'Kubernetes', 'Microservices'],
  certifications: ['AWS Solutions Architect', 'Certified Kubernetes Administrator', 'Google Cloud Professional'],
  validFrom: promotionDate,
  validTo: null,  // New current version
  createdAt: promotionDate,
  createdBy: 'hr.system',
  changeReason: 'Promotion to Staff Engineer'
})

// Update version chain
MATCH (alice:User {userId: 'alice.johnson.001'})
MATCH (aliceV1:UserProfile {userId: 'alice.johnson.001', version: 1})
SET aliceV1.validTo = promotionDate

// Update current profile link
MATCH (alice)-[current:CURRENT_PROFILE]->(aliceV1)
DELETE current
CREATE (alice)-[:CURRENT_PROFILE]->(aliceV2)
CREATE (alice)-[:PROFILE_HISTORY]->(aliceV2)
CREATE (aliceV1)-[:SUPERSEDED_BY]->(aliceV2)

RETURN 'Profile versioning system created' AS status
```

### Step 6: Audit Trail and Change Tracking
```cypher
// Create comprehensive audit trail system
CREATE (auditPolicy:AuditPolicy {
  policyId: 'AUDIT-001',
  name: 'User Data Changes',
  description: 'Track all changes to user profile data',
  retentionPeriod: 'P7Y',  // 7 years
  triggers: ['CREATE', 'UPDATE', 'DELETE'],
  dataTypes: ['UserProfile', 'RoleAssignment', 'DepartmentMembership'],
  complianceFramework: ['SOX', 'GDPR'],
  createdAt: datetime(),
  status: 'Active'
})

// Create audit events for Alice's profile changes
CREATE (auditCreate:AuditEvent {
  eventId: 'AUD-001-CREATE',
  tenantId: 'corp-001',
  userId: 'alice.johnson.001',
  entityType: 'UserProfile',
  entityId: 'alice.johnson.001',
  action: 'CREATE',
  timestamp: datetime() - duration('P90D'),
  performedBy: 'alice.johnson.001',
  sourceIP: '192.168.1.100',
  userAgent: 'Mozilla/5.0 (Enterprise Browser)',
  sessionId: 'sess-12345',
  changes: {
    new: {
      firstName: 'Alice',
      lastName: 'Johnson',
      jobTitle: 'Senior Software Engineer'
    }
  },
  complianceFlags: ['DATA_CREATED'],
  riskLevel: 'Low'
})

CREATE (auditUpdate:AuditEvent {
  eventId: 'AUD-001-UPDATE',
  tenantId: 'corp-001',
  userId: 'alice.johnson.001',
  entityType: 'UserProfile', 
  entityId: 'alice.johnson.001',
  action: 'UPDATE',
  timestamp: datetime(),
  performedBy: 'hr.system',
  sourceIP: '10.0.1.50',
  userAgent: 'HRSystem/2.1',
  sessionId: 'sys-67890',
  changes: {
    old: {jobTitle: 'Senior Software Engineer'},
    new: {jobTitle: 'Staff Software Engineer'}
  },
  complianceFlags: ['PROMOTION_EVENT'],
  riskLevel: 'Low'
})

// Link audit events to entities
MATCH (alice:User {userId: 'alice.johnson.001'})
CREATE (alice)-[:AUDIT_TRAIL]->(auditCreate)
CREATE (alice)-[:AUDIT_TRAIL]->(auditUpdate)

RETURN 'Audit trail system implemented' AS status
```

### Step 7: Data Lineage and Provenance Tracking
```cypher
// Create data lineage tracking for data quality and compliance
CREATE (dataSource:DataSource {
  sourceId: 'HR-SYSTEM-001',
  name: 'Corporate HR System',
  type: 'INTERNAL_SYSTEM',
  description: 'Primary HR system for employee data',
  owner: 'HR Department',
  dataClassification: 'Confidential',
  lastValidated: datetime(),
  certifications: ['SOC2', 'ISO27001'],
  apiEndpoint: 'https://hr-api.techcorp.com/v2',
  dataRetentionPolicy: 'P7Y'
})

CREATE (ldapSource:DataSource {
  sourceId: 'LDAP-001',
  name: 'Active Directory',
  type: 'IDENTITY_PROVIDER',
  description: 'Corporate identity and authentication system',
  owner: 'IT Security',
  dataClassification: 'Confidential',
  lastValidated: datetime(),
  certifications: ['SOC2', 'ISO27001'],
  syncFrequency: 'PT15M'  // 15 minutes
})

// Create data lineage for user profiles
MATCH (alice:User {userId: 'alice.johnson.001'})
MATCH (aliceV1:UserProfile {userId: 'alice.johnson.001', version: 1})
MATCH (aliceV2:UserProfile {userId: 'alice.johnson.001', version: 2})
MATCH (hrSource:DataSource {sourceId: 'HR-SYSTEM-001'})
MATCH (ldapSource:DataSource {sourceId: 'LDAP-001'})

CREATE (lineage1:DataLineage {
  lineageId: 'LIN-001',
  sourceRecordId: 'HR-EMP-001234',
  transformationDate: datetime() - duration('P90D'),
  extractionMethod: 'API_SYNC',
  transformationRules: ['name_standardization', 'department_mapping'],
  qualityScore: 0.98,
  validator: 'data.validator.v1'
})

CREATE (lineage2:DataLineage {
  lineageId: 'LIN-002', 
  sourceRecordId: 'HR-EMP-001234',
  transformationDate: datetime(),
  extractionMethod: 'API_SYNC',
  transformationRules: ['promotion_workflow', 'skill_update'],
  qualityScore: 0.99,
  validator: 'data.validator.v1'
})

// Link lineage to profiles and sources
CREATE (hrSource)-[:DATA_LINEAGE]->(lineage1)-[:CREATED]->(aliceV1)
CREATE (hrSource)-[:DATA_LINEAGE]->(lineage2)-[:CREATED]->(aliceV2)
CREATE (ldapSource)-[:IDENTITY_SOURCE]->(alice)

RETURN 'Data lineage tracking implemented' AS status
```

## Part 3: Role-Based Access Control Implementation (15 minutes)

### Step 8: Advanced Permission and Security Model
```cypher
// Create granular permissions system
CREATE (readUser:Permission {
  permissionId: 'user.read',
  name: 'Read User Profiles',
  description: 'View user profile information',
  resourceType: 'User',
  action: 'READ',
  scope: 'TENANT',
  riskLevel: 'Low',
  dataClassification: 'Internal'
})

CREATE (updateUser:Permission {
  permissionId: 'user.update',
  name: 'Update User Profiles',
  description: 'Modify user profile information',
  resourceType: 'User',
  action: 'UPDATE', 
  scope: 'TENANT',
  riskLevel: 'Medium',
  dataClassification: 'Confidential',
  requiresApproval: true
})

CREATE (viewAnalytics:Permission {
  permissionId: 'analytics.view',
  name: 'View Analytics Data',
  description: 'Access to analytics dashboards and reports',
  resourceType: 'Analytics',
  action: 'READ',
  scope: 'TENANT',
  riskLevel: 'Medium',
  dataClassification: 'Confidential'
})

CREATE (exportData:Permission {
  permissionId: 'data.export',
  name: 'Export Data',
  description: 'Export data outside the system',
  resourceType: 'Data',
  action: 'EXPORT',
  scope: 'TENANT', 
  riskLevel: 'High',
  dataClassification: 'Confidential',
  requiresApproval: true,
  auditRequired: true
})

// Link roles to permissions
MATCH (dataAnalyst:Role {roleId: 'data_analyst'})
MATCH (tenantAdmin:Role {roleId: 'tenant_admin'})
MATCH (standardUser:Role {roleId: 'standard_user'})

CREATE (dataAnalyst)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(readUser)
CREATE (dataAnalyst)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(viewAnalytics)
CREATE (tenantAdmin)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(readUser)
CREATE (tenantAdmin)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(updateUser)
CREATE (tenantAdmin)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(viewAnalytics)
CREATE (tenantAdmin)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(exportData)
CREATE (standardUser)-[:HAS_PERMISSION {grantedAt: datetime(), grantedBy: 'system'}]->(readUser)

RETURN 'Permission system implemented' AS status
```

### Step 9: Data Classification and Access Policies
```cypher
// Create data classification system
CREATE (publicClass:DataClassification {
  classificationId: 'PUBLIC',
  name: 'Public',
  description: 'Information that can be freely shared',
  retentionPeriod: null,
  encryptionRequired: false,
  accessControls: ['NONE'],
  handlingInstructions: 'No special handling required'
})

CREATE (internalClass:DataClassification {
  classificationId: 'INTERNAL',
  name: 'Internal',
  description: 'Information for internal use only',
  retentionPeriod: 'P3Y',
  encryptionRequired: false,
  accessControls: ['AUTHENTICATION_REQUIRED'],
  handlingInstructions: 'Restrict to authorized personnel'
})

CREATE (confidentialClass:DataClassification {
  classificationId: 'CONFIDENTIAL',
  name: 'Confidential',
  description: 'Sensitive business information',
  retentionPeriod: 'P7Y',
  encryptionRequired: true,
  accessControls: ['AUTHENTICATION_REQUIRED', 'AUTHORIZATION_REQUIRED', 'AUDIT_LOGGING'],
  handlingInstructions: 'Handle with strict access controls'
})

CREATE (restrictedClass:DataClassification {
  classificationId: 'RESTRICTED',
  name: 'Restricted',
  description: 'Highly sensitive information',
  retentionPeriod: 'P10Y',
  encryptionRequired: true,
  accessControls: ['MFA_REQUIRED', 'SEGREGATION_OF_DUTIES', 'EXECUTIVE_APPROVAL'],
  handlingInstructions: 'Highest level of protection required'
})

// Create access policies based on data classification
CREATE (confidentialPolicy:AccessPolicy {
  policyId: 'POL-CONFIDENTIAL-001',
  name: 'Confidential Data Access Policy',
  description: 'Access controls for confidential data',
  applicableClassifications: ['CONFIDENTIAL'],
  requiredClearanceLevel: 'Confidential',
  minimumRole: 'data_analyst',
  accessConditions: [
    'VALID_BUSINESS_JUSTIFICATION',
    'MANAGER_APPROVAL',
    'TIME_BOUNDED_ACCESS'
  ],
  auditingLevel: 'DETAILED',
  createdAt: datetime(),
  effectiveDate: datetime(),
  reviewDate: datetime() + duration('P1Y')
})

// Apply data classifications to users
MATCH (alice:User {userId: 'alice.johnson.001'})
MATCH (bob:User {userId: 'bob.chen.002'})
MATCH (internalClass:DataClassification {classificationId: 'INTERNAL'})
MATCH (confidentialClass:DataClassification {classificationId: 'CONFIDENTIAL'})

CREATE (alice)-[:HAS_CLASSIFICATION {appliedAt: datetime(), appliedBy: 'hr.system'}]->(internalClass)
CREATE (bob)-[:HAS_CLASSIFICATION {appliedAt: datetime(), appliedBy: 'hr.system'}]->(confidentialClass)

RETURN 'Data classification and access policies implemented' AS status
```

### Step 10: Dynamic Access Control Evaluation
```cypher
// Create dynamic access control rules
CREATE (locationRule:AccessRule {
  ruleId: 'LOC-001',
  name: 'Geographic Access Restriction',
  description: 'Restrict access based on geographic location',
  ruleType: 'LOCATION_BASED',
  conditions: {
    allowedCountries: ['US', 'CA', 'GB'],
    allowedRegions: ['us-east-1', 'us-west-2', 'eu-west-1'],
    blockVPN: true,
    blockTor: true
  },
  actions: ['BLOCK_ACCESS', 'REQUIRE_ADDITIONAL_AUTH'],
  riskScore: 0.7,
  enabled: true
})

CREATE (timeRule:AccessRule {
  ruleId: 'TIME-001',
  name: 'Business Hours Access',
  description: 'Restrict access to business hours',
  ruleType: 'TEMPORAL',
  conditions: {
    allowedHours: 'MON-FRI 06:00-22:00',
    timezone: 'USER_LOCAL',
    emergencyAccess: true,
    emergencyApprover: 'DUTY_MANAGER'
  },
  actions: ['REQUIRE_JUSTIFICATION', 'NOTIFY_SECURITY'],
  riskScore: 0.4,
  enabled: true
})

CREATE (deviceRule:AccessRule {
  ruleId: 'DEV-001',
  name: 'Managed Device Requirement',
  description: 'Require access from managed corporate devices',
  ruleType: 'DEVICE_BASED',
  conditions: {
    requireManagedDevice: true,
    requireEncryption: true,
    maxDeviceAge: 'P3Y',
    requiredCompliance: ['PATCH_LEVEL', 'ANTIVIRUS', 'FIREWALL']
  },
  actions: ['BLOCK_UNMANAGED', 'REQUIRE_DEVICE_REGISTRATION'],
  riskScore: 0.8,
  enabled: true
})

// Create access control evaluation context
CREATE (accessContext:AccessContext {
  contextId: 'CTX-001',
  userId: 'alice.johnson.001',
  resourceType: 'UserProfile',
  requestedAction: 'READ',
  timestamp: datetime(),
  sourceIP: '192.168.1.100',
  location: 'San Francisco, CA, US',
  deviceId: 'DEV-CORP-12345',
  userAgent: 'Mozilla/5.0 (Corporate Browser)',
  sessionId: 'sess-active-789'
})

// Link rules to context for evaluation
CREATE (accessContext)-[:SUBJECT_TO]->(locationRule)
CREATE (accessContext)-[:SUBJECT_TO]->(timeRule)
CREATE (accessContext)-[:SUBJECT_TO]->(deviceRule)

RETURN 'Dynamic access control system implemented' AS status
```

## Part 4: Scalable Data Import and ETL Processes (15 minutes)

### Step 11: Enterprise Data Import Framework
```cypher
// Create data import job configuration
CREATE (importJob:ImportJob {
  jobId: 'IMP-USERS-001',
  name: 'User Profile Bulk Import',
  description: 'Import user profiles from HR system',
  sourceSystem: 'HR-SYSTEM-001',
  targetEntity: 'User',
  scheduleType: 'DAILY',
  scheduleCron: '0 2 * * *',  // Daily at 2 AM
  batchSize: 1000,
  parallelThreads: 4,
  retryAttempts: 3,
  timeoutMinutes: 30,
  validationRules: [
    'REQUIRED_FIELDS',
    'EMAIL_FORMAT',
    'UNIQUE_CONSTRAINTS',
    'DATA_CLASSIFICATION'
  ],
  transformationRules: [
    'NAME_STANDARDIZATION',
    'DEPARTMENT_MAPPING',
    'SKILL_NORMALIZATION'
  ],
  errorHandling: 'CONTINUE_ON_ERROR',
  notificationEmail: 'data-ops@techcorp.com',
  createdAt: datetime(),
  status: 'Active'
})

// Create staging area for data validation
CREATE (stagingArea:StagingArea {
  areaId: 'STAGE-USERS',
  name: 'User Data Staging',
  description: 'Temporary storage for user data validation',
  retentionPeriod: 'P7D',
  encryptionEnabled: true,
  compressionEnabled: true,
  capacity: '10GB',
  currentUsage: '2.3GB'
})

// Create data quality rules
CREATE (emailRule:DataQualityRule {
  ruleId: 'DQ-EMAIL-001',
  name: 'Email Format Validation',
  description: 'Validate email address format and domain',
  ruleType: 'FORMAT_VALIDATION',
  expression: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
  severity: 'ERROR',
  action: 'REJECT_RECORD'
})

CREATE (phoneRule:DataQualityRule {
  ruleId: 'DQ-PHONE-001',
  name: 'Phone Number Standardization',
  description: 'Standardize phone number format',
  ruleType: 'TRANSFORMATION',
  expression: 'NORMALIZE_PHONE_US',
  severity: 'WARNING',
  action: 'TRANSFORM_VALUE'
})

CREATE (departmentRule:DataQualityRule {
  ruleId: 'DQ-DEPT-001',
  name: 'Department Validation',
  description: 'Validate department against approved list',
  ruleType: 'REFERENCE_VALIDATION',
  referenceList: ['Engineering', 'Sales', 'Marketing', 'HR', 'Finance', 'Operations'],
  severity: 'ERROR',
  action: 'REJECT_RECORD'
})

// Link import job to staging and quality rules
CREATE (importJob)-[:USES_STAGING]->(stagingArea)
CREATE (importJob)-[:APPLIES_RULE]->(emailRule)
CREATE (importJob)-[:APPLIES_RULE]->(phoneRule)
CREATE (importJob)-[:APPLIES_RULE]->(departmentRule)

RETURN 'Data import framework created' AS status
```

### Step 12: Error Handling and Data Reconciliation
```cypher
// Create error tracking and handling system
CREATE (errorLog:ErrorLog {
  errorId: 'ERR-001-20241127',
  jobId: 'IMP-USERS-001',
  timestamp: datetime(),
  errorType: 'VALIDATION_FAILURE',
  severity: 'ERROR',
  message: 'Invalid email format in record ID HR-12345',
  sourceRecord: {
    employeeId: 'EMP-12345',
    email: 'invalid-email-format',
    name: 'John Doe'
  },
  failedRule: 'DQ-EMAIL-001',
  resolutionStatus: 'PENDING',
  assignedTo: 'data-steward@techcorp.com',
  retryCount: 0
})

CREATE (reconciliation:DataReconciliation {
  reconciliationId: 'REC-001-20241127',
  jobId: 'IMP-USERS-001',
  executionDate: date(),
  sourceRecordCount: 1247,
  targetRecordCount: 1245,
  successfulImports: 1245,
  failedImports: 2,
  duplicatesSkipped: 0,
  validationErrors: 2,
  transformationWarnings: 15,
  processingTimeMinutes: 12,
  dataQualityScore: 0.998,
  reconciliationStatus: 'COMPLETED_WITH_ERRORS'
})

// Create data lineage for imported records
CREATE (importLineage:ImportLineage {
  lineageId: 'LIN-IMP-001',
  importJobId: 'IMP-USERS-001',
  sourceFile: 'hr_export_20241127.csv',
  sourceChecksum: 'sha256:abc123def456',
  importTimestamp: datetime(),
  recordsProcessed: 1247,
  transformationVersion: 'v2.1.3',
  validationVersion: 'v1.4.2'
})

// Link to import job
MATCH (importJob:ImportJob {jobId: 'IMP-USERS-001'})
CREATE (importJob)-[:HAS_ERROR_LOG]->(errorLog)
CREATE (importJob)-[:HAS_RECONCILIATION]->(reconciliation)
CREATE (importJob)-[:HAS_LINEAGE]->(importLineage)

RETURN 'Error handling and reconciliation system created' AS status
```

### Step 13: Performance Monitoring and Optimization
```cypher
// Create performance monitoring for data operations
CREATE (perfMonitor:PerformanceMonitor {
  monitorId: 'PERF-IMP-001',
  jobId: 'IMP-USERS-001',
  metricType: 'IMPORT_PERFORMANCE',
  timestamp: datetime(),
  recordsPerSecond: 34.2,
  avgRecordSizeKB: 2.8,
  memoryUsageMB: 512,
  cpuUtilization: 0.45,
  networkThroughputMbps: 15.2,
  diskIOOperations: 1250,
  queryExecutionTimeMs: 25.6,
  indexLookupTimeMs: 2.1,
  commitTimeMs: 145.3,
  alertThresholds: {
    maxRecordsPerSecond: 50,
    maxMemoryMB: 1024,
    maxCpuUtilization: 0.8,
    maxExecutionTimeMs: 100
  }
})

// Create optimization recommendations
CREATE (optimization:OptimizationRecommendation {
  recommendationId: 'OPT-001',
  jobId: 'IMP-USERS-001',
  timestamp: datetime(),
  type: 'BATCH_SIZE_TUNING',
  currentValue: 1000,
  recommendedValue: 750,
  expectedImprovement: '15% faster processing',
  reasoning: 'Reduce memory pressure and improve commit frequency',
  implementationEffort: 'LOW',
  riskLevel: 'LOW',
  status: 'PENDING_APPROVAL'
})

// Create capacity planning data
CREATE (capacity:CapacityPlan {
  planId: 'CAP-USERS-2024',
  entityType: 'User',
  currentCount: 8500,
  projectedGrowthRate: 0.15,  // 15% annual growth
  targetCount: 12000,
  timeframe: 'P1Y',
  resourceRequirements: {
    diskSpaceGB: 50,
    memoryMB: 2048,
    processingTimeHours: 2.5
  },
  scalingTriggers: {
    recordCountThreshold: 10000,
    processingTimeThreshold: 'PT1H',
    errorRateThreshold: 0.05
  }
})

RETURN 'Performance monitoring and optimization implemented' AS status
```

## Lab Completion Checklist

- [ ] Redesigned social network with enterprise multi-tenant architecture
- [ ] Implemented comprehensive temporal data modeling with versioning
- [ ] Built role-based access control with granular permissions
- [ ] Created organizational hierarchy with reporting structures
- [ ] Designed audit trail and change tracking systems
- [ ] Implemented data lineage and provenance tracking
- [ ] Built data classification and access policy frameworks
- [ ] Created dynamic access control with risk-based evaluation
- [ ] Designed scalable data import and ETL processes
- [ ] Implemented error handling and data reconciliation systems
- [ ] Built performance monitoring and optimization frameworks
- [ ] Created capacity planning and scalability assessments

## Key Concepts Mastered

1. **Enterprise Architecture Patterns:** Multi-tenancy, organizational modeling, scalability design
2. **Temporal Data Management:** Versioning, audit trails, change tracking, data lineage
3. **Security and Compliance:** RBAC, data classification, access policies, audit logging
4. **Data Quality Management:** Validation rules, error handling, reconciliation processes
5. **Performance Optimization:** Monitoring, capacity planning, scalability assessment
6. **Operational Excellence:** ETL processes, error recovery, performance tuning
7. **Governance and Compliance:** Data stewardship, regulatory compliance, risk management
8. **Production Readiness:** Monitoring, alerting, capacity planning, operational procedures

## Enterprise Features Implemented

### 1. **Multi-Tenant Architecture**
- **Tenant isolation** with secure data boundaries
- **Subscription tier management** with feature restrictions
- **Cross-tenant reporting** with proper authorization
- **Data residency** and compliance requirements

### 2. **Comprehensive Security Model**
- **Role-based access control** with granular permissions
- **Data classification** with handling policies
- **Dynamic access evaluation** based on context
- **Audit trails** for compliance and security

### 3. **Data Governance Framework**
- **Data lineage tracking** for compliance
- **Quality validation** and error handling
- **Change management** with approval workflows
- **Retention policies** and lifecycle management

### 4. **Operational Excellence**
- **Performance monitoring** and optimization
- **Capacity planning** and scalability assessment
- **Error recovery** and resilience patterns
- **Automated reconciliation** and validation

## Next Steps

Excellent work! You've built an enterprise-grade data model that includes:
- **Production-ready architecture** with proper security and governance
- **Comprehensive audit and compliance** capabilities
- **Scalable data management** with quality validation
- **Operational monitoring** and optimization frameworks

**In Lab 10**, you'll focus on:
- **Python application development** using the enterprise data model
- **API development** with proper authentication and authorization
- **Integration patterns** for connecting external systems
- **Testing strategies** for enterprise graph applications

## Practice Exercises (Optional)

Extend your enterprise modeling capabilities:

1. **Compliance Framework:** Implement GDPR, SOX, or HIPAA compliance patterns
2. **Advanced Workflows:** Create approval workflows for sensitive operations
3. **Data Anonymization:** Implement privacy protection for non-production environments
4. **Cross-Tenant Analytics:** Build secure reporting across tenant boundaries
5. **Disaster Recovery:** Design backup and recovery procedures for enterprise data

## Quick Reference

**Enterprise Modeling Patterns:**
```cypher
// Multi-tenant pattern
(:User {tenantId: 'tenant-001'})-[:BELONGS_TO]->(:Tenant)

// Versioning pattern
(:Entity)-[:CURRENT_VERSION]->(:EntityVersion {version: 2})
(:EntityVersion {version: 1})-[:SUPERSEDED_BY]->(:EntityVersion {version: 2})

// Audit pattern
(:User)-[:AUDIT_TRAIL]->(:AuditEvent {action: 'UPDATE', timestamp: datetime()})

// Access control pattern
(:Role)-[:HAS_PERMISSION]->(:Permission {action: 'READ', resourceType: 'User'})
(:User)-[:HAS_ROLE {validFrom: datetime(), validTo: datetime()}]->(:Role)
```

---

**🎉 Lab 9 Complete!**

You now possess enterprise-grade data modeling skills that enable you to design production-ready graph databases with proper security, governance, and operational capabilities. These patterns form the foundation for building scalable, compliant, and maintainable graph applications in enterprise environments!