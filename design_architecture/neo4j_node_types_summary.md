# Neo4j Insurance Database - Complete Node Types Summary

## Overview
This document provides a comprehensive summary of all node types developed throughout the 3-day Neo4j course, organized by category and showing their evolution from Lab 1 through Lab 17.

---

## 👥 Customer & Personal Entities

### **Customer (Primary Entity)**
```cypher
(:Customer:Individual) {
  id: randomUUID(),
  customer_number: "CUST-001234",
  first_name: "Sarah",
  last_name: "Johnson",
  date_of_birth: date("1985-03-15"),
  ssn_last_four: "1234",
  email: "sarah.johnson@email.com",
  phone: "555-0123",
  address: "123 Oak Street",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  credit_score: 720,
  customer_since: date("2020-01-15"),
  risk_tier: "Standard|Preferred|Substandard",
  lifetime_value: 12500.00,
  // Enterprise metadata
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
}
```
**Introduced:** Lab 1 | **Enhanced:** Labs 2, 6, 11

### **Business Customer**
```cypher
(:Customer:Business) {
  id: randomUUID(),
  customer_number: "CUST-BUS-001",
  business_name: "TechCorp Industries",
  tax_id: "12-3456789",
  industry: "Technology",
  business_type: "Corporation|LLC|Partnership",
  employee_count: 150,
  annual_revenue: 5000000.00,
  duns_number: "123456789",
  primary_contact: "John Smith",
  // Standard customer fields
  email: "contact@techcorp.com",
  phone: "512-555-0100",
  address: "100 Tech Plaza",
  city: "Austin",
  state: "TX",
  zip_code: "78701"
}
```
**Introduced:** Lab 16 (Multi-line platform)

### **Dependent**
```cypher
(:Dependent:Person) {
  id: randomUUID(),
  dependent_id: "DEP-001234",
  first_name: "Emily",
  last_name: "Johnson",
  date_of_birth: date("2010-05-15"),
  relationship: "Child|Spouse|Parent",
  ssn_last_four: "5678",
  coverage_status: "Active|Inactive"
}
```
**Introduced:** Lab 11 (Enterprise schema)

---

## 📋 Insurance Product & Policy Entities

### **Product (Insurance Products)**
```cypher
(:Product:Insurance) {
  id: randomUUID(),
  product_code: "AUTO-STD",
  product_name: "Standard Auto Insurance",
  product_type: "Auto|Property|Life|Commercial",
  coverage_types: ["Liability", "Collision", "Comprehensive"],
  base_premium: 1200.00,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "product_management"
}
```
**Introduced:** Lab 1 | **Enhanced:** Lab 16

### **Policy (Auto Insurance)**
```cypher
(:Policy:Auto:Active) {
  id: randomUUID(),
  policy_number: "POL-AUTO-001234",
  product_type: "Auto",
  policy_status: "Active|Suspended|Cancelled|Expired",
  effective_date: date("2024-01-01"),
  expiration_date: date() + duration({months: 12}),
  annual_premium: 1320.00,
  deductible: 500,
  coverage_limit: 100000,
  payment_frequency: "Monthly|Quarterly|Semi-Annual|Annual",
  // Auto-specific properties
  auto_make: "Toyota",
  auto_model: "Camry",
  auto_year: 2022,
  vin: "1HGBH41JXMN109186",
  vehicle_value: 25000.00,
  usage_type: "Personal|Business|Commercial"
}
```
**Introduced:** Lab 1 | **Enhanced:** Labs 3, 11

### **Policy (Property Insurance)**
```cypher
(:Policy:Property:Active) {
  id: randomUUID(),
  policy_number: "POL-HOME-001235",
  product_type: "Property",
  // Standard policy fields
  policy_status: "Active",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  annual_premium: 950.00,
  deductible: 1000,
  coverage_limit: 250000,
  // Property-specific fields
  property_value: 320000,
  property_type: "Single Family|Condo|Townhouse|Commercial",
  construction_type: "Frame|Brick|Steel|Mixed",
  roof_type: "Shingle|Tile|Metal|Flat",
  square_footage: 2200,
  lot_size: 0.25,
  year_built: 1995
}
```
**Introduced:** Lab 1 | **Enhanced:** Labs 3, 11

### **Policy (Life Insurance)**
```cypher
(:Policy:Life:Active) {
  id: randomUUID(),
  policy_number: "POL-LIFE-001236",
  product_type: "Life",
  policy_type: "Term|Whole|Universal|Variable",
  face_value: 500000.00,
  cash_value: 15000.00,
  term_length: 20, // years
  premium_mode: "Annual|Semi-Annual|Quarterly|Monthly",
  beneficiaries: ["John Doe", "Jane Doe"],
  medical_exam_required: true,
  smoking_status: false
}
```
**Introduced:** Lab 16 (Multi-line platform)

### **Policy (Commercial Insurance)**
```cypher
(:Policy:Commercial:Active) {
  id: randomUUID(),
  policy_number: "POL-COMM-001237",
  product_type: "Commercial",
  business_type: "General Liability|Property|Workers Comp|Cyber",
  coverage_territory: "Texas|National|International",
  employee_coverage: 150,
  property_locations: ["Austin", "Dallas", "Houston"],
  industry_code: "541511", // NAICS code
  payroll: 12000000.00,
  gross_receipts: 25000000.00
}
```
**Introduced:** Lab 16 (Multi-line platform)

---

## 📄 Claims & Incident Entities

### **Claim**
```cypher
(:Claim) {
  id: randomUUID(),
  claim_number: "CLM-001234",
  policy_number: "POL-AUTO-001234",
  claim_type: "Auto|Property|Liability|Life|Workers Comp",
  claim_status: "Open|Under Investigation|Approved|Denied|Closed",
  incident_date: date(),
  report_date: date(),
  claim_amount: 8500.00,
  settled_amount: 7200.00,
  settlement_date: date(),
  description: "Vehicle collision on Highway 35",
  fault_determination: "Not At Fault|At Fault|Shared|Pending",
  // Location data
  incident_latitude: 30.2672,
  incident_longitude: -97.7431,
  incident_address: "Highway 35, Austin, TX",
  // Processing data
  adjuster_id: "ADJ-001",
  priority: "High|Medium|Low",
  fraud_score: 0.15,
  investigation_required: false,
  estimated_repair_cost: 8500.00
}
```
**Introduced:** Lab 3 | **Enhanced:** Labs 9, 10

### **Incident**
```cypher
(:Incident) {
  id: randomUUID(),
  incident_id: "INC-001234",
  incident_type: "Auto Accident|Property Damage|Theft|Fire|Flood",
  incident_date: datetime(),
  weather_conditions: "Clear|Rainy|Snowy|Foggy",
  police_report_number: "APD-2024-001234",
  witness_count: 2,
  photos_taken: true,
  severity: "Minor|Moderate|Major|Total Loss"
}
```
**Introduced:** Lab 9 (Fraud detection)

---

## 👨‍💼 Employee & Professional Entities

### **Agent**
```cypher
(:Agent:Employee) {
  id: randomUUID(),
  agent_id: "AGT-001",
  employee_id: "EMP-12345",
  first_name: "David",
  last_name: "Wilson",
  email: "david.wilson@insurance.com",
  phone: "555-0200",
  license_number: "TX-INS-123456",
  license_expiration: date("2025-12-31"),
  territory: "Central Texas",
  commission_rate: 0.12,
  hire_date: date("2018-03-01"),
  performance_rating: "Excellent|Very Good|Good|Needs Improvement",
  ytd_sales: 125000.00,
  customer_count: 45,
  sales_quota: 150000.00
}
```
**Introduced:** Lab 1 | **Enhanced:** Labs 6, 8

### **Adjuster**
```cypher
(:Adjuster:Employee) {
  id: randomUUID(),
  adjuster_id: "ADJ-001",
  employee_id: "EMP-54321",
  first_name: "Maria",
  last_name: "Garcia",
  specialization: ["Auto", "Property"],
  license_number: "TX-ADJ-789012",
  caseload_limit: 25,
  current_caseload: 18,
  average_settlement_time: 14.5, // days
  territory: "South Texas",
  certification_level: "Senior|Junior|Trainee"
}
```
**Introduced:** Lab 3 | **Enhanced:** Lab 8

### **Underwriter**
```cypher
(:Underwriter:Employee) {
  id: randomUUID(),
  underwriter_id: "UND-001",
  employee_id: "EMP-67890",
  first_name: "Robert",
  last_name: "Kim",
  specialization: ["Commercial", "High-Value"],
  approval_limit: 500000.00,
  risk_assessment_score: 8.5,
  years_experience: 12,
  certification: "CPCU|ARM|AU"
}
```
**Introduced:** Lab 11 (Enterprise schema)

### **Manager**
```cypher
(:Manager:Employee) {
  id: randomUUID(),
  manager_id: "MGR-001",
  employee_id: "EMP-11111",
  department: "Claims|Underwriting|Sales|Operations",
  team_size: 15,
  budget_responsibility: 2500000.00,
  management_level: "Team Lead|Department Manager|Director|VP"
}
```
**Introduced:** Lab 11 (Enterprise schema)

---

## 🏢 Organizational Entities

### **Company**
```cypher
(:Company) {
  id: randomUUID(),
  company_name: "Acme Insurance Company",
  company_type: "Insurance Carrier|Reinsurer|MGA|Broker",
  headquarters: "Austin, TX",
  founded: date("1985-01-01"),
  license_states: ["TX", "OK", "LA", "NM"],
  financial_rating: "A+|A|A-|B+|B",
  annual_revenue: 500000000.00,
  employee_count: 2500,
  market_cap: 2000000000.00
}
```
**Introduced:** Lab 1 | **Enhanced:** Lab 16

### **Branch**
```cypher
(:Branch:Location) {
  id: randomUUID(),
  branch_id: "BR-001",
  branch_name: "Austin Downtown",
  branch_type: "Regional|Local|Specialty|Claims Center",
  address: "100 Congress Ave",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  phone: "512-555-0100",
  manager_id: "EMP-54321",
  employee_count: 25,
  customer_count: 1200,
  territory_coverage: ["Travis County", "Williamson County"]
}
```
**Introduced:** Lab 2 | **Enhanced:** Lab 11

### **Department**
```cypher
(:Department) {
  id: randomUUID(),
  department_name: "Claims Processing",
  department_code: "CLAIMS",
  budget: 2000000.00,
  head_count: 45,
  manager_id: "EMP-67890",
  cost_center: "CC-1001",
  department_type: "Operations|Support|Sales|Executive"
}
```
**Introduced:** Lab 11 (Enterprise schema)

---

## 💰 Financial Entities

### **Payment**
```cypher
(:Payment) {
  id: randomUUID(),
  payment_id: "PAY-001234",
  policy_number: "POL-AUTO-001234",
  payment_type: "Premium|Claim Settlement|Refund|Commission",
  amount: 110.00,
  payment_date: date(),
  payment_method: "Auto Pay|Check|Credit Card|Bank Transfer|Cash",
  payment_status: "Processed|Pending|Failed|Reversed",
  transaction_id: "TXN-789012",
  bank_account_last_four: "1234",
  confirmation_number: "CONF-789012"
}
```
**Introduced:** Lab 3 | **Enhanced:** Lab 10

### **Invoice**
```cypher
(:Invoice) {
  id: randomUUID(),
  invoice_number: "INV-001234",
  policy_number: "POL-AUTO-001234",
  billing_period: "2024-01",
  amount_due: 110.00,
  due_date: date(),
  payment_status: "Paid|Outstanding|Overdue|Partial",
  invoice_date: date(),
  late_fee: 0.00,
  discount_applied: 0.00
}
```
**Introduced:** Lab 10 (Compliance)

### **Commission**
```cypher
(:Commission) {
  id: randomUUID(),
  commission_id: "COMM-001234",
  agent_id: "AGT-001",
  policy_number: "POL-AUTO-001234",
  commission_type: "New Business|Renewal|Cross-sell",
  commission_rate: 0.12,
  premium_amount: 1320.00,
  commission_amount: 158.40,
  payment_date: date(),
  payment_status: "Paid|Pending|Held"
}
```
**Introduced:** Lab 8 (Performance optimization)

---

## 🚗 Asset Entities

### **Vehicle**
```cypher
(:Vehicle:Asset) {
  id: randomUUID(),
  vin: "1HGBH41JXMN109186",
  make: "Toyota",
  model: "Camry",
  year: 2022,
  color: "Blue",
  vehicle_type: "Sedan|SUV|Truck|Motorcycle",
  engine_size: "2.5L",
  fuel_type: "Gasoline|Hybrid|Electric|Diesel",
  market_value: 25000.00,
  mileage: 45000,
  safety_rating: 5,
  anti_theft_devices: ["Alarm", "GPS Tracking"]
}
```
**Introduced:** Lab 3 | **Enhanced:** Lab 9

### **Property**
```cypher
(:Property:Asset) {
  id: randomUUID(),
  property_id: "PROP-001234",
  property_type: "Residential|Commercial|Industrial",
  address: "123 Oak Street",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  market_value: 320000,
  square_footage: 2200,
  lot_size: 0.25,
  year_built: 1995,
  construction_type: "Frame|Brick|Steel",
  roof_type: "Shingle|Tile|Metal",
  heating_type: "Central Air|Heat Pump|Radiant",
  foundation_type: "Slab|Crawl Space|Basement"
}
```
**Introduced:** Lab 3 | **Enhanced:** Lab 11

---

## 🔧 Vendor & Service Provider Entities

### **Repair Shop**
```cypher
(:RepairShop:Vendor) {
  id: randomUUID(),
  vendor_id: "VEN-001",
  business_name: "Austin Auto Repair",
  specialization: ["Auto Body", "Mechanical", "Paint"],
  preferred_vendor: true,
  rating: 4.5,
  average_repair_time: 7.2, // days
  location: "Austin, TX",
  license_number: "TX-REP-123456",
  insurance_carrier: "General Liability Coverage",
  hourly_rate: 125.00,
  warranty_period: 90 // days
}
```
**Introduced:** Lab 3 | **Enhanced:** Lab 9

### **Medical Provider**
```cypher
(:MedicalProvider:Vendor) {
  id: randomUUID(),
  vendor_id: "VEN-MED-001",
  provider_name: "Austin Medical Center",
  provider_type: "Hospital|Clinic|Specialist|Physical Therapy",
  network_status: "In-Network|Out-of-Network",
  specialization: ["Emergency", "Orthopedic", "Radiology"],
  npi_number: "1234567890",
  address: "200 Medical Drive",
  city: "Austin",
  state: "TX"
}
```
**Introduced:** Lab 9 (Fraud detection)

### **Legal Firm**
```cypher
(:LegalFirm:Vendor) {
  id: randomUUID(),
  vendor_id: "VEN-LEG-001",
  firm_name: "Smith & Associates",
  specialization: ["Personal Injury", "Insurance Defense"],
  bar_number: "TX-BAR-123456",
  hourly_rate: 350.00,
  retainer_required: 5000.00,
  success_rate: 0.85
}
```
**Introduced:** Lab 10 (Compliance)

---

## 📊 Compliance & Audit Entities

### **Compliance Record**
```cypher
(:ComplianceRecord) {
  id: randomUUID(),
  compliance_id: "COMP-001234",
  policy_number: "POL-LIFE-001234",
  regulatory_requirements: ["State Insurance Code", "Federal Guidelines"],
  compliance_status: "Compliant|Non-Compliant|Under Review",
  last_review_date: date(),
  next_review_date: date(),
  compliance_officer: "OFFICER-001",
  findings: ["No issues found"],
  corrective_actions: []
}
```
**Introduced:** Lab 10 (Compliance)

### **Audit Record**
```cypher
(:AuditRecord) {
  id: randomUUID(),
  audit_id: "AUD-001234",
  audit_type: "Internal|External|Regulatory",
  audit_scope: "Claims Processing|Underwriting|Financial",
  audit_date: date(),
  auditor: "External Firm ABC",
  findings: ["Process improvement recommended"],
  audit_status: "Complete|In Progress|Scheduled",
  risk_level: "High|Medium|Low",
  follow_up_required: true
}
```
**Introduced:** Lab 10 (Compliance)

### **Regulatory Filing**
```cypher
(:RegulatoryFiling) {
  id: randomUUID(),
  filing_id: "REG-2024-001",
  filing_type: "Annual Report|Quarterly|Rate Filing|Form Filing",
  regulatory_body: "Texas Department of Insurance",
  filing_date: date(),
  due_date: date(),
  filing_status: "Submitted|Under Review|Approved|Rejected",
  contact_person: "EMP-99999"
}
```
**Introduced:** Lab 10 (Compliance)

---

## 🔍 Analytics & Intelligence Entities

### **Risk Assessment**
```cypher
(:RiskAssessment) {
  id: randomUUID(),
  assessment_id: "RISK-001234",
  customer_id: "CUST-001234",
  assessment_type: "Underwriting|Renewal|Claims",
  risk_score: 7.5,
  risk_factors: ["Credit Score", "Claims History", "Location"],
  assessment_date: date(),
  valid_until: date(),
  assessor_id: "UND-001",
  model_version: "v2.1"
}
```
**Introduced:** Lab 11 (Enterprise schema)

### **Fraud Investigation**
```cypher
(:FraudInvestigation) {
  id: randomUUID(),
  investigation_id: "FRAUD-001234",
  claim_number: "CLM-001234",
  investigation_status: "Open|Closed|Suspended",
  fraud_type: "Staged Accident|Exaggerated Claim|Identity Fraud",
  investigator_id: "INV-001",
  start_date: date(),
  evidence_collected: ["Photos", "Witness Statements", "Medical Records"],
  investigation_result: "Fraud Confirmed|No Fraud|Inconclusive",
  estimated_savings: 15000.00
}
```
**Introduced:** Lab 9 (Fraud detection)

### **Marketing Campaign**
```cypher
(:MarketingCampaign) {
  id: randomUUID(),
  campaign_id: "CAMP-2024-001",
  campaign_name: "Spring Auto Special",
  campaign_type: "Digital|Direct Mail|TV|Radio",
  start_date: date(),
  end_date: date(),
  budget: 50000.00,
  target_audience: "Young Drivers",
  channel: "Social Media",
  response_rate: 0.035,
  cost_per_lead: 25.00
}
```
**Introduced:** Lab 17 (Innovation showcase)

---

## 📱 Technology & Integration Entities

### **System Integration**
```cypher
(:SystemIntegration) {
  id: randomUUID(),
  integration_id: "INT-001",
  system_name: "Core Policy System",
  integration_type: "Real-time|Batch|Event-driven",
  endpoint_url: "https://api.coreystem.com/v1/",
  authentication_type: "API Key|OAuth2|Certificate",
  last_sync: datetime(),
  sync_status: "Success|Failed|In Progress",
  error_count: 0
}
```
**Introduced:** Lab 15 (Production deployment)

### **API Endpoint**
```cypher
(:APIEndpoint) {
  id: randomUUID(),
  endpoint_id: "API-001",
  endpoint_path: "/api/v1/customers",
  http_method: "GET|POST|PUT|DELETE",
  rate_limit: 1000, // requests per hour
  authentication_required: true,
  response_format: "JSON|XML",
  cache_ttl: 300, // seconds
  monitoring_enabled: true
}
```
**Introduced:** Lab 13 (API development)

---

## Summary Statistics by Introduction

### **Lab 1 (Foundation):** 4 node types
- Customer:Individual, Product:Insurance, Policy:Auto, Policy:Property, Agent:Employee

### **Lab 2-5 (Day 1):** +3 node types  
- Branch:Location, Department, Invoice

### **Lab 6-11 (Day 2):** +8 node types
- Claim, Vehicle:Asset, Property:Asset, RepairShop:Vendor, MedicalProvider:Vendor, ComplianceRecord, AuditRecord, RiskAssessment, FraudInvestigation

### **Lab 12-17 (Day 3):** +8 node types
- Customer:Business, Policy:Life, Policy:Commercial, Dependent:Person, SystemIntegration, APIEndpoint, MarketingCampaign, plus specialized roles (Adjuster, Underwriter, Manager)

### **Total: 25+ distinct node types** representing a complete enterprise insurance ecosystem

This comprehensive node type structure enables sophisticated insurance operations, advanced analytics, fraud detection, regulatory compliance, and enterprise integration capabilities throughout the 3-day course progression.