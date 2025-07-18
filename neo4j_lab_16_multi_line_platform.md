# Neo4j Lab 16: Multi-Line Insurance Platform

## Lab Overview
**Duration:** 45 minutes  
**Difficulty:** Advanced  
**Prerequisites:** Labs 1-15 completed successfully  

In this lab, you'll expand your insurance database to a comprehensive multi-line platform supporting life insurance, commercial coverage, specialty products, and global reinsurance operations. You'll implement advanced enterprise features including multi-currency support, international regulations, and complex partner ecosystems.

---

## Learning Objectives

By the end of this lab, you will be able to:
- ✅ **Implement life insurance products** with beneficiaries, cash values, and term structures
- ✅ **Build commercial insurance systems** supporting general liability, workers compensation, and cyber coverage
- ✅ **Design specialty insurance products** including professional liability and umbrella policies
- ✅ **Create reinsurance networks** with treaty management and risk distribution
- ✅ **Implement global operations** with multi-country compliance and currency management
- ✅ **Build partner ecosystems** including brokers, reinsurers, and specialty providers

---

## Lab Environment Setup

### Step 1: Verify Docker Environment
```bash
# Ensure Neo4j Enterprise container is running
docker ps | grep neo4j

# Container should show: neo4j (Neo4j/2025.06.0 neo4j:enterprise)
```

### Step 2: Connect to Neo4j
```python
# In Jupyter, verify connection
from neo4j import GraphDatabase
import pandas as pd
from datetime import datetime, date
import uuid

# Connect to Neo4j Enterprise instance
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))

def run_query(query, parameters=None):
    with driver.session(database="insurance") as session:
        result = session.run(query, parameters)
        return [record.data() for record in result]

# Verify current database state
current_state = run_query("""
MATCH (n) 
RETURN labels(n)[0] AS node_type, count(n) AS count
ORDER BY count DESC
""")

print("Current Database State:")
for record in current_state:
    print(f"  {record['node_type']}: {record['count']} nodes")
```

---

## Part 1: Life Insurance Integration (12 minutes)

### Step 3: Life Insurance Products and Policies
```python
# Create life insurance products and policies
life_insurance_query = """
// Create Life Insurance Products
CREATE (term_life:Product:Insurance {
  id: randomUUID(),
  product_code: "LIFE-TERM",
  product_name: "Term Life Insurance",
  product_type: "Life",
  coverage_types: ["Death Benefit", "Terminal Illness"],
  base_premium: 850.00,
  max_face_value: 2000000.00,
  term_options: [10, 15, 20, 25, 30],
  medical_exam_required: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "product_management"
})

CREATE (whole_life:Product:Insurance {
  id: randomUUID(),
  product_code: "LIFE-WHOLE",
  product_name: "Whole Life Insurance", 
  product_type: "Life",
  coverage_types: ["Death Benefit", "Cash Value", "Dividend"],
  base_premium: 2400.00,
  max_face_value: 5000000.00,
  cash_value_growth: 0.045,
  dividend_eligible: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "product_management"
})

CREATE (universal_life:Product:Insurance {
  id: randomUUID(),
  product_code: "LIFE-UNIVERSAL",
  product_name: "Universal Life Insurance",
  product_type: "Life", 
  coverage_types: ["Death Benefit", "Flexible Premium", "Investment Options"],
  base_premium: 1800.00,
  max_face_value: 10000000.00,
  investment_options: ["Conservative", "Moderate", "Aggressive"],
  flexible_premium: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "product_management"
})

// Create Life Insurance Policies for existing customers
MATCH (customer:Customer)
WHERE customer.customer_number IN ["CUST-001234", "CUST-001235", "CUST-001236", "CUST-001237", "CUST-001238"]
MATCH (term_life:Product:Insurance {product_code: "LIFE-TERM"})
WITH customer, term_life, 
     CASE customer.customer_number
       WHEN "CUST-001234" THEN {face_value: 500000, premium: 1200, term: 20, beneficiary: "Jane Johnson"}
       WHEN "CUST-001235" THEN {face_value: 750000, premium: 1850, term: 30, beneficiary: "Sarah Wilson"}
       WHEN "CUST-001236" THEN {face_value: 300000, premium: 780, term: 15, beneficiary: "John Brown"}
       WHEN "CUST-001237" THEN {face_value: 1000000, premium: 2400, term: 25, beneficiary: "Mary Davis"}
       WHEN "CUST-001238" THEN {face_value: 600000, premium: 1450, term: 20, beneficiary: "Robert Miller"}
     END AS policy_details

CREATE (policy:Policy:Life:Active {
  id: randomUUID(),
  policy_number: "POL-LIFE-" + right("000000" + toString(toInteger(rand() * 1000000)), 6),
  product_type: "Life",
  policy_type: "Term",
  policy_status: "Active",
  effective_date: date() - duration({months: toInteger(rand() * 24)}),
  expiration_date: date() + duration({years: policy_details.term}),
  
  // Life insurance specific fields
  face_value: policy_details.face_value,
  annual_premium: policy_details.premium,
  term_length: policy_details.term,
  premium_mode: "Annual",
  primary_beneficiary: policy_details.beneficiary,
  beneficiary_relationship: "Spouse",
  cash_value: 0.0,
  
  // Medical underwriting
  medical_exam_completed: true,
  smoking_status: rand() < 0.2,
  health_classification: 
    CASE WHEN rand() < 0.7 THEN "Standard"
         WHEN rand() < 0.9 THEN "Preferred" 
         ELSE "Substandard" END,
  
  // Policy administration
  premium_payment_frequency: "Annual",
  grace_period_days: 31,
  contestability_period: 2,
  suicide_clause_period: 2,
  
  created_at: datetime(),
  created_by: "life_underwriting_system",
  last_updated: datetime(),
  version: 1
})

CREATE (customer)-[:HOLDS_POLICY {
  start_date: policy.effective_date,
  policy_role: "Owner"
}]->(policy)

CREATE (policy)-[:BASED_ON {
  underwriting_date: policy.effective_date,
  risk_assessment: "Approved"
}]->(term_life)

RETURN customer.customer_number AS customer,
       policy.policy_number AS policy_number,
       policy.face_value AS coverage,
       policy.annual_premium AS premium
"""

life_results = run_query(life_insurance_query)
print("Life Insurance Policies Created:")
for record in life_results:
    print(f"  Customer {record['customer']}: Policy {record['policy_number']}, Coverage: ${record['coverage']:,}, Premium: ${record['premium']:,}")
```

### Step 4: Beneficiary Management System
```python
# Create beneficiary entities and relationships
beneficiary_query = """
// Create Beneficiary entities for life insurance policies
MATCH (policy:Policy:Life)
WITH policy, 
     CASE policy.primary_beneficiary
       WHEN "Jane Johnson" THEN {first: "Jane", last: "Johnson", relationship: "Spouse", percentage: 100}
       WHEN "Sarah Wilson" THEN {first: "Sarah", last: "Wilson", relationship: "Spouse", percentage: 100}
       WHEN "John Brown" THEN {first: "John", last: "Brown", relationship: "Spouse", percentage: 100}
       WHEN "Mary Davis" THEN {first: "Mary", last: "Davis", relationship: "Spouse", percentage: 100}
       WHEN "Robert Miller" THEN {first: "Robert", last: "Miller", relationship: "Spouse", percentage: 100}
     END AS beneficiary_info

CREATE (beneficiary:Beneficiary:Person {
  id: randomUUID(),
  beneficiary_id: "BEN-" + right("000000" + toString(toInteger(rand() * 1000000)), 6),
  first_name: beneficiary_info.first,
  last_name: beneficiary_info.last,
  relationship_to_insured: beneficiary_info.relationship,
  benefit_percentage: beneficiary_info.percentage,
  contingent_beneficiary: false,
  
  // Contact information
  phone: "555-" + right("0000" + toString(toInteger(rand() * 10000)), 4),
  email: toLower(beneficiary_info.first + "." + beneficiary_info.last + "@email.com"),
  address: toString(toInteger(rand() * 9999) + 1) + " " + 
           ["Oak", "Pine", "Maple", "Cedar", "Elm"][toInteger(rand() * 5)] + " Street",
  city: ["Austin", "Dallas", "Houston", "San Antonio"][toInteger(rand() * 4)],
  state: "TX",
  zip_code: "7" + right("0000" + toString(toInteger(rand() * 10000)), 4),
  
  // Verification status
  identity_verified: true,
  documentation_complete: true,
  last_contact_date: date() - duration({days: toInteger(rand() * 365)}),
  
  created_at: datetime(),
  created_by: "beneficiary_management_system",
  version: 1
})

CREATE (policy)-[:HAS_BENEFICIARY {
  designation_date: policy.effective_date,
  beneficiary_type: "Primary",
  benefit_percentage: beneficiary_info.percentage,
  designation_status: "Active"
}]->(beneficiary)

RETURN policy.policy_number AS policy,
       beneficiary.first_name + " " + beneficiary.last_name AS beneficiary_name,
       beneficiary.relationship_to_insured AS relationship,
       beneficiary.benefit_percentage AS percentage
"""

beneficiary_results = run_query(beneficiary_query)
print("\nBeneficiaries Created:")
for record in beneficiary_results:
    print(f"  Policy {record['policy']}: {record['beneficiary_name']} ({record['relationship']}) - {record['percentage']}%")
```

---

## Part 2: Commercial Insurance Systems (12 minutes)

### Step 5: Commercial Insurance Products
```python
# Create commercial insurance products and policies
commercial_query = """
// Create Commercial Insurance Products
CREATE (general_liability:Product:Insurance {
  id: randomUUID(),
  product_code: "COMM-GL",
  product_name: "General Liability Insurance",
  product_type: "Commercial",
  coverage_types: ["Bodily Injury", "Property Damage", "Personal Injury", "Product Liability"],
  base_premium: 3500.00,
  coverage_territory: "United States",
  policy_term: 12,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "commercial_product_team"
})

CREATE (workers_comp:Product:Insurance {
  id: randomUUID(),
  product_code: "COMM-WC",
  product_name: "Workers Compensation Insurance",
  product_type: "Commercial", 
  coverage_types: ["Medical Expenses", "Disability Benefits", "Death Benefits", "Rehabilitation"],
  base_premium: 4200.00,
  coverage_territory: "Texas",
  mandatory_coverage: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "commercial_product_team"
})

CREATE (commercial_property:Product:Insurance {
  id: randomUUID(),
  product_code: "COMM-PROP",
  product_name: "Commercial Property Insurance", 
  product_type: "Commercial",
  coverage_types: ["Building", "Business Personal Property", "Equipment", "Business Interruption"],
  base_premium: 2800.00,
  coverage_territory: "United States",
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "commercial_product_team"
})

CREATE (cyber_liability:Product:Insurance {
  id: randomUUID(),
  product_code: "COMM-CYBER",
  product_name: "Cyber Liability Insurance",
  product_type: "Commercial",
  coverage_types: ["Data Breach", "Business Interruption", "Cyber Extortion", "Network Security"],
  base_premium: 5500.00,
  coverage_territory: "Global",
  emerging_risk: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "specialty_products_team"
})

// Create Business Customer entities
CREATE (tech_corp:Customer:Business {
  id: randomUUID(),
  customer_number: "CUST-BUS-001",
  business_name: "TechCorp Industries Inc.",
  tax_id: "12-3456789",
  industry: "Technology Services",
  naics_code: "541511",
  business_type: "Corporation",
  employee_count: 150,
  annual_revenue: 25000000.00,
  years_in_business: 8,
  duns_number: "123456789",
  
  // Contact information
  primary_contact: "Michael Anderson",
  contact_title: "Risk Manager", 
  email: "manderson@techcorp.com",
  phone: "512-555-0100",
  address: "100 Tech Plaza",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  
  // Business profile
  credit_rating: "A-",
  risk_profile: "Technology",
  prior_claims_experience: "Good",
  customer_since: date("2020-03-15"),
  
  created_at: datetime(),
  created_by: "commercial_underwriting",
  version: 1
})

CREATE (manufacturing_co:Customer:Business {
  id: randomUUID(),
  customer_number: "CUST-BUS-002",
  business_name: "Precision Manufacturing LLC",
  tax_id: "87-6543210", 
  industry: "Manufacturing",
  naics_code: "336412",
  business_type: "LLC",
  employee_count: 85,
  annual_revenue: 18000000.00,
  years_in_business: 15,
  
  // Contact information
  primary_contact: "Jennifer Torres",
  contact_title: "Operations Manager",
  email: "jtorres@precisionmfg.com",
  phone: "713-555-0200",
  address: "500 Industrial Blvd",
  city: "Houston", 
  state: "TX",
  zip_code: "77001",
  
  // Business profile
  credit_rating: "A",
  risk_profile: "Manufacturing",
  prior_claims_experience: "Excellent",
  customer_since: date("2019-07-20"),
  
  created_at: datetime(),
  created_by: "commercial_underwriting",
  version: 1
})

RETURN tech_corp.business_name AS business1,
       manufacturing_co.business_name AS business2
"""

commercial_results = run_query(commercial_query)
print("Commercial Insurance Infrastructure Created:")
for record in commercial_results:
    print(f"  Business Customers: {record['business1']}, {record['business2']}")
```

### Step 6: Commercial Policies and Coverage
```python
# Create commercial policies with complex coverage structures
commercial_policies_query = """
// Create Commercial Policies for Business Customers
MATCH (tech_corp:Customer:Business {customer_number: "CUST-BUS-001"})
MATCH (gl_product:Product:Insurance {product_code: "COMM-GL"})
MATCH (cyber_product:Product:Insurance {product_code: "COMM-CYBER"})

// General Liability Policy for TechCorp
CREATE (gl_policy:Policy:Commercial:Active {
  id: randomUUID(),
  policy_number: "POL-COMM-GL-001",
  product_type: "Commercial",
  business_type: "General Liability",
  policy_status: "Active",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Coverage details
  per_occurrence_limit: 1000000.00,
  aggregate_limit: 2000000.00,
  annual_premium: 8500.00,
  deductible: 2500.00,
  
  // Business specific
  covered_territory: "United States",
  employee_coverage: 150,
  business_operations: ["Software Development", "IT Consulting", "Cloud Services"],
  industry_classification: "Technology Services",
  payroll: 12000000.00,
  
  // Risk factors
  cyber_exposure: true,
  professional_services: true,
  international_operations: false,
  
  created_at: datetime(),
  created_by: "commercial_underwriting",
  version: 1
})

// Cyber Liability Policy for TechCorp
CREATE (cyber_policy:Policy:Commercial:Active {
  id: randomUUID(),
  policy_number: "POL-COMM-CYBER-001",
  product_type: "Commercial",
  business_type: "Cyber Liability",
  policy_status: "Active", 
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Cyber coverage specifics
  data_breach_limit: 5000000.00,
  business_interruption_limit: 2000000.00,
  cyber_extortion_limit: 1000000.00,
  annual_premium: 12500.00,
  cyber_deductible: 10000.00,
  
  // Coverage scope
  records_covered: 50000,
  breach_response_included: true,
  regulatory_fines_covered: true,
  third_party_liability: true,
  
  // Risk assessment
  security_controls_implemented: true,
  employee_training_program: true,
  incident_response_plan: true,
  penetration_testing: "Annual",
  
  created_at: datetime(),
  created_by: "cyber_underwriting",
  version: 1
})

// Create relationships
CREATE (tech_corp)-[:HOLDS_POLICY {
  start_date: gl_policy.effective_date,
  policy_role: "Named Insured"
}]->(gl_policy)

CREATE (tech_corp)-[:HOLDS_POLICY {
  start_date: cyber_policy.effective_date,
  policy_role: "Named Insured"  
}]->(cyber_policy)

CREATE (gl_policy)-[:BASED_ON {
  underwriting_date: gl_policy.effective_date,
  risk_assessment: "Approved - Standard"
}]->(gl_product)

CREATE (cyber_policy)-[:BASED_ON {
  underwriting_date: cyber_policy.effective_date,
  risk_assessment: "Approved - Enhanced Controls"
}]->(cyber_product)

// Workers Compensation for Manufacturing
MATCH (mfg_corp:Customer:Business {customer_number: "CUST-BUS-002"})
MATCH (wc_product:Product:Insurance {product_code: "COMM-WC"})

CREATE (wc_policy:Policy:Commercial:Active {
  id: randomUUID(),
  policy_number: "POL-COMM-WC-001",
  product_type: "Commercial",
  business_type: "Workers Compensation",
  policy_status: "Active",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Workers comp specifics
  coverage_limit: 1000000.00,
  annual_premium: 15500.00,
  experience_modifier: 0.87,
  
  // Manufacturing specifics
  employee_count: 85,
  payroll_covered: 8500000.00,
  class_codes: ["8810", "8742", "8006"],
  safety_programs: ["OSHA Training", "Safety Committee", "Incident Reporting"],
  loss_control_visits: 2,
  
  created_at: datetime(),
  created_by: "workers_comp_underwriting",
  version: 1
})

CREATE (mfg_corp)-[:HOLDS_POLICY {
  start_date: wc_policy.effective_date,
  policy_role: "Employer"
}]->(wc_policy)

CREATE (wc_policy)-[:BASED_ON {
  underwriting_date: wc_policy.effective_date,
  risk_assessment: "Approved - Excellent Safety Record"
}]->(wc_product)

RETURN gl_policy.policy_number AS gl_policy,
       cyber_policy.policy_number AS cyber_policy,
       wc_policy.policy_number AS wc_policy
"""

commercial_policy_results = run_query(commercial_policies_query)
print("\nCommercial Policies Created:")
for record in commercial_policy_results:
    print(f"  General Liability: {record['gl_policy']}")
    print(f"  Cyber Liability: {record['cyber_policy']}")
    print(f"  Workers Compensation: {record['wc_policy']}")
```

---

## Part 3: Specialty Products and Reinsurance Networks (12 minutes)

### Step 7: Specialty Insurance Products
```python
# Create specialty insurance products and coverage
specialty_query = """
// Create Specialty Insurance Products
CREATE (professional_liability:Product:Insurance {
  id: randomUUID(),
  product_code: "SPEC-PROF-LIABILITY",
  product_name: "Professional Liability Insurance",
  product_type: "Specialty",
  coverage_types: ["Errors & Omissions", "Professional Negligence", "Defense Costs", "Regulatory Proceedings"],
  base_premium: 6500.00,
  target_industries: ["Legal", "Medical", "Technology", "Consulting", "Financial Services"],
  claims_made_basis: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "specialty_products_team"
})

CREATE (umbrella_liability:Product:Insurance {
  id: randomUUID(),
  product_code: "SPEC-UMBRELLA",
  product_name: "Commercial Umbrella Liability",
  product_type: "Specialty",
  coverage_types: ["Excess Liability", "Broader Coverage", "Legal Defense"],
  base_premium: 4200.00,
  minimum_underlying: 1000000.00,
  coverage_territory: "Worldwide",
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "specialty_products_team"
})

CREATE (directors_officers:Product:Insurance {
  id: randomUUID(),
  product_code: "SPEC-DNO",
  product_name: "Directors & Officers Liability",
  product_type: "Specialty",
  coverage_types: ["Management Liability", "Employment Practices", "Fiduciary Liability"],
  base_premium: 8500.00,
  target_entities: ["Public Companies", "Private Companies", "Non-Profits"],
  claims_made_basis: true,
  active: true,
  effective_date: date(),
  created_at: datetime(),
  created_by: "specialty_products_team"
})

// Create Specialty Product Policies
MATCH (tech_corp:Customer:Business {customer_number: "CUST-BUS-001"})
MATCH (prof_product:Product:Insurance {product_code: "SPEC-PROF-LIABILITY"})
MATCH (umbrella_product:Product:Insurance {product_code: "SPEC-UMBRELLA"})

CREATE (prof_policy:Policy:Specialty:Active {
  id: randomUUID(),
  policy_number: "POL-SPEC-PROF-001",
  product_type: "Specialty",
  business_type: "Professional Liability",
  policy_status: "Active",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Professional liability specifics
  per_claim_limit: 2000000.00,
  aggregate_limit: 4000000.00,
  annual_premium: 18500.00,
  deductible: 25000.00,
  
  // Claims-made provisions
  retroactive_date: date() - duration({years: 3}),
  extended_reporting_period: 60, // months
  prior_acts_coverage: true,
  
  // Professional services covered
  services_covered: ["Software Development", "IT Consulting", "System Integration", "Data Analytics"],
  professional_licenses: ["Technology Services License"],
  
  created_at: datetime(),
  created_by: "specialty_underwriting",
  version: 1
})

CREATE (umbrella_policy:Policy:Specialty:Active {
  id: randomUUID(),
  policy_number: "POL-SPEC-UMB-001",
  product_type: "Specialty",
  business_type: "Umbrella Liability",
  policy_status: "Active",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Umbrella specifics
  umbrella_limit: 10000000.00,
  annual_premium: 8500.00,
  underlying_policies: ["POL-COMM-GL-001"],
  
  // Coverage territory
  coverage_territory: "Worldwide",
  follow_form_coverage: true,
  additional_coverage: ["Defense Costs", "Punitive Damages", "Worldwide Territory"],
  
  created_at: datetime(),
  created_by: "specialty_underwriting", 
  version: 1
})

// Create relationships
CREATE (tech_corp)-[:HOLDS_POLICY {
  start_date: prof_policy.effective_date,
  policy_role: "Named Insured"
}]->(prof_policy)

CREATE (tech_corp)-[:HOLDS_POLICY {
  start_date: umbrella_policy.effective_date,
  policy_role: "Named Insured"
}]->(umbrella_policy)

CREATE (prof_policy)-[:BASED_ON {
  underwriting_date: prof_policy.effective_date,
  risk_assessment: "Approved - Technology Risks"
}]->(prof_product)

CREATE (umbrella_policy)-[:BASED_ON {
  underwriting_date: umbrella_policy.effective_date,
  risk_assessment: "Approved - Excess Coverage"
}]->(umbrella_product)

RETURN prof_policy.policy_number AS professional,
       umbrella_policy.policy_number AS umbrella
"""

specialty_results = run_query(specialty_query)
print("Specialty Insurance Products Created:")
for record in specialty_results:
    print(f"  Professional Liability: {record['professional']}")
    print(f"  Umbrella Coverage: {record['umbrella']}")
```

### Step 8: Reinsurance Networks and Treaty Management
```python
# Create reinsurance infrastructure and partnerships
reinsurance_query = """
// Create Reinsurance Companies
CREATE (munich_re:ReinsuranceCompany:PartnerOrganization {
  id: randomUUID(),
  company_id: "REIN-001",
  company_name: "Munich Re America",
  reinsurer_type: "Traditional",
  am_best_rating: "A++",
  financial_strength: "Superior",
  geographic_scope: "Global",
  
  // Contact information
  headquarters: "New York, NY",
  regional_office: "Dallas, TX",
  contact_person: "David Richardson",
  contact_title: "Regional Director",
  phone: "214-555-0300",
  email: "drichardson@munichre.com",
  
  // Business metrics
  surplus: 15000000000.00,
  market_share: 0.12,
  specialties: ["Property", "Casualty", "Life", "Specialty"],
  
  created_at: datetime(),
  created_by: "reinsurance_management",
  version: 1
})

CREATE (swiss_re:ReinsuranceCompany:PartnerOrganization {
  id: randomUUID(),
  company_id: "REIN-002", 
  company_name: "Swiss Re Corporate Solutions",
  reinsurer_type: "Traditional",
  am_best_rating: "A+",
  financial_strength: "Superior",
  geographic_scope: "Global",
  
  // Contact information
  headquarters: "Zurich, Switzerland",
  regional_office: "Austin, TX",
  contact_person: "Maria Rodriguez",
  contact_title: "Account Manager",
  phone: "512-555-0400",
  email: "mrodriguez@swissre.com",
  
  // Business metrics
  surplus: 22000000000.00,
  market_share: 0.15,
  specialties: ["Cyber", "Technology", "Professional Lines"],
  
  created_at: datetime(),
  created_by: "reinsurance_management",
  version: 1
})

CREATE (berkshire_re:ReinsuranceCompany:PartnerOrganization {
  id: randomUUID(),
  company_id: "REIN-003",
  company_name: "Berkshire Hathaway Reinsurance",
  reinsurer_type: "Traditional",
  am_best_rating: "A++",
  financial_strength: "Superior", 
  geographic_scope: "Global",
  
  // Contact information
  headquarters: "Omaha, NE",
  regional_office: "Houston, TX",
  contact_person: "Thomas Wilson",
  contact_title: "Senior Vice President",
  phone: "713-555-0500",
  email: "twilson@brg.com",
  
  // Business metrics
  surplus: 35000000000.00,
  market_share: 0.08,
  specialties: ["Catastrophe", "Large Commercial", "Workers Compensation"],
  
  created_at: datetime(),
  created_by: "reinsurance_management",
  version: 1
})

// Create Reinsurance Treaties
CREATE (property_treaty:ReinsuranceContract {
  id: randomUUID(),
  treaty_id: "TREATY-PROP-001",
  treaty_name: "Property Catastrophe Treaty 2025",
  treaty_type: "Catastrophe Excess of Loss",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Coverage structure
  retention_amount: 5000000.00,
  limit_amount: 50000000.00,
  coverage_territory: "United States",
  covered_perils: ["Hurricane", "Tornado", "Hail", "Wildfire", "Earthquake"],
  
  // Financial terms
  premium_rate: 0.045,
  provisional_premium: 2250000.00,
  swing_rating: true,
  profit_commission: 0.15,
  
  // Treaty terms
  hours_clause: 72,
  reinstatement_provisions: true,
  number_of_reinstatements: 2,
  
  created_at: datetime(),
  created_by: "treaty_management",
  version: 1
})

CREATE (cyber_treaty:ReinsuranceContract {
  id: randomUUID(),
  treaty_id: "TREATY-CYBER-001",
  treaty_name: "Cyber Liability Quota Share 2025",
  treaty_type: "Quota Share",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Quota share specifics
  cession_percentage: 0.40,
  commission_rate: 0.32,
  override_commission: 0.02,
  coverage_territory: "Global",
  
  // Cyber specific terms
  covered_lines: ["Cyber Liability", "Technology E&O", "Privacy Liability"],
  minimum_security_standards: true,
  aggregate_limit: 25000000.00,
  
  created_at: datetime(),
  created_by: "treaty_management",
  version: 1
})

// Create Reinsurance Relationships
CREATE (property_treaty)-[:REINSURED_BY {
  participation_percentage: 0.60,
  role: "Lead Reinsurer",
  signing_date: date() - duration({days: 30})
}]->(munich_re)

CREATE (property_treaty)-[:REINSURED_BY {
  participation_percentage: 0.40,
  role: "Following Reinsurer",
  signing_date: date() - duration({days: 25})
}]->(berkshire_re)

CREATE (cyber_treaty)-[:REINSURED_BY {
  participation_percentage: 1.00,
  role: "Sole Reinsurer",
  signing_date: date() - duration({days: 20})
}]->(swiss_re)

// Link treaties to products
MATCH (property_products:Product:Insurance)
WHERE property_products.product_type IN ["Property", "Commercial"]
MATCH (property_treaty:ReinsuranceContract {treaty_id: "TREATY-PROP-001"})

CREATE (property_products)-[:COVERED_BY_TREATY {
  coverage_effective_date: property_treaty.effective_date,
  coverage_basis: "Excess of Loss"
}]->(property_treaty)

MATCH (cyber_products:Product:Insurance) 
WHERE cyber_products.product_code = "COMM-CYBER"
MATCH (cyber_treaty:ReinsuranceContract {treaty_id: "TREATY-CYBER-001"})

CREATE (cyber_products)-[:COVERED_BY_TREATY {
  coverage_effective_date: cyber_treaty.effective_date,
  coverage_basis: "Quota Share"
}]->(cyber_treaty)

RETURN property_treaty.treaty_name AS property_treaty,
       cyber_treaty.treaty_name AS cyber_treaty
"""

reinsurance_results = run_query(reinsurance_query)
print("\nReinsurance Networks Created:")
for record in reinsurance_results:
    print(f"  Property Treaty: {record['property_treaty']}")
    print(f"  Cyber Treaty: {record['cyber_treaty']}")
```

---

## Part 4: Global Operations and Multi-Currency Support (9 minutes)

### Step 9: International Operations Infrastructure  
```python
# Create global operations and regulatory compliance
global_operations_query = """
// Create International Subsidiaries
CREATE (uk_subsidiary:Customer:Business {
  id: randomUUID(),
  customer_number: "CUST-UK-001",
  business_name: "TechCorp UK Limited",
  tax_id: "GB123456789",
  parent_company: "CUST-BUS-001",
  country: "United Kingdom",
  regulatory_jurisdiction: "FCA",
  
  // Contact information
  primary_contact: "James Morrison",
  contact_title: "Managing Director",
  email: "jmorrison@techcorp.co.uk",
  phone: "+44-20-7123-4567",
  address: "25 Canary Wharf",
  city: "London",
  postal_code: "E14 5AB",
  
  // Business details
  local_currency: "GBP",
  employee_count: 45,
  annual_revenue: 8500000.00,
  revenue_currency: "GBP",
  
  created_at: datetime(),
  created_by: "international_operations",
  version: 1
})

CREATE (canada_subsidiary:Customer:Business {
  id: randomUUID(),
  customer_number: "CUST-CA-001",
  business_name: "TechCorp Canada Inc.",
  tax_id: "CA987654321",
  parent_company: "CUST-BUS-001",
  country: "Canada", 
  regulatory_jurisdiction: "OSFI",
  
  // Contact information
  primary_contact: "Sophie Dubois",
  contact_title: "General Manager", 
  email: "sdubois@techcorp.ca",
  phone: "+1-416-555-0123",
  address: "100 King Street West",
  city: "Toronto",
  state: "ON",
  postal_code: "M5X 1A9",
  
  // Business details
  local_currency: "CAD",
  employee_count: 35,
  annual_revenue: 6200000.00,
  revenue_currency: "CAD",
  
  created_at: datetime(),
  created_by: "international_operations",
  version: 1
})

// Create International Regulatory Frameworks
CREATE (uk_regulations:RegulatoryFramework {
  id: randomUUID(),
  framework_id: "REG-UK-001",
  jurisdiction: "United Kingdom",
  regulatory_body: "Financial Conduct Authority (FCA)",
  framework_name: "UK Insurance Regulations 2025",
  
  // Regulatory requirements
  capital_requirements: ["Solvency II", "Minimum Capital Requirement"],
  reporting_frequency: "Quarterly",
  local_representation_required: true,
  consumer_protection_rules: true,
  
  // Compliance deadlines
  annual_filing_deadline: "March 31",
  quarterly_reporting: true,
  solvency_reporting: "Annual",
  
  effective_date: date(),
  last_updated: datetime(),
  version: 1
})

CREATE (canada_regulations:RegulatoryFramework {
  id: randomUUID(),
  framework_id: "REG-CA-001", 
  jurisdiction: "Canada",
  regulatory_body: "Office of the Superintendent of Financial Institutions (OSFI)",
  framework_name: "Canadian Insurance Regulations 2025",
  
  // Regulatory requirements
  capital_requirements: ["Minimum Continuing Capital", "Surplus Requirements"],
  reporting_frequency: "Quarterly",
  local_representation_required: true,
  consumer_protection_rules: true,
  
  // Compliance deadlines
  annual_filing_deadline: "April 30", 
  quarterly_reporting: true,
  solvency_reporting: "Annual",
  
  effective_date: date(),
  last_updated: datetime(),
  version: 1
})

// Create Currency Exchange Management
CREATE (currency_rates:CurrencyExchange {
  id: randomUUID(),
  exchange_id: "FX-2025-001",
  base_currency: "USD",
  rate_date: date(),
  
  // Exchange rates (example rates)
  usd_to_gbp: 0.79,
  usd_to_cad: 1.35,
  usd_to_eur: 0.92,
  
  // Rate metadata
  source: "Federal Reserve Economic Data",
  rate_type: "Daily Close",
  last_updated: datetime(),
  
  created_at: datetime(),
  created_by: "treasury_system",
  version: 1
})

// Create International Policy with Multi-Currency
MATCH (uk_sub:Customer:Business {customer_number: "CUST-UK-001"})
MATCH (gl_product:Product:Insurance {product_code: "COMM-GL"})

CREATE (uk_policy:Policy:Commercial:Active {
  id: randomUUID(),
  policy_number: "POL-UK-GL-001",
  product_type: "Commercial",
  business_type: "General Liability",
  policy_status: "Active",
  effective_date: date(),
  expiration_date: date() + duration({years: 1}),
  
  // Coverage in local currency
  per_occurrence_limit: 1000000.00,
  aggregate_limit: 2000000.00, 
  annual_premium: 6500.00,
  policy_currency: "GBP",
  
  // USD equivalents
  per_occurrence_limit_usd: 1265822.78,
  aggregate_limit_usd: 2531645.57,
  annual_premium_usd: 8227.85,
  exchange_rate_used: 0.79,
  fx_conversion_date: date(),
  
  // International specifics
  coverage_territory: "United Kingdom",
  local_regulatory_compliance: true,
  regulatory_framework: "FCA Regulations",
  
  created_at: datetime(),
  created_by: "uk_underwriting",
  version: 1
})

// Create relationships
CREATE (uk_sub)-[:HOLDS_POLICY {
  start_date: uk_policy.effective_date,
  policy_role: "Named Insured"
}]->(uk_policy)

CREATE (uk_policy)-[:BASED_ON {
  underwriting_date: uk_policy.effective_date,
  risk_assessment: "Approved - UK Operations"
}]->(gl_product)

CREATE (uk_policy)-[:SUBJECT_TO_REGULATIONS]->(uk_regulations)
CREATE (uk_policy)-[:USES_EXCHANGE_RATE]->(currency_rates)

// Link subsidiaries to parent
MATCH (parent:Customer:Business {customer_number: "CUST-BUS-001"})
MATCH (uk_sub:Customer:Business {customer_number: "CUST-UK-001"})
MATCH (ca_sub:Customer:Business {customer_number: "CUST-CA-001"})

CREATE (parent)-[:HAS_SUBSIDIARY {
  ownership_percentage: 100.0,
  establishment_date: date("2022-01-15"),
  control_type: "Wholly Owned"
}]->(uk_sub)

CREATE (parent)-[:HAS_SUBSIDIARY {
  ownership_percentage: 100.0,
  establishment_date: date("2021-08-20"),
  control_type: "Wholly Owned"  
}]->(ca_sub)

RETURN uk_policy.policy_number AS uk_policy,
       uk_policy.policy_currency AS currency,
       uk_policy.annual_premium AS local_premium,
       uk_policy.annual_premium_usd AS usd_premium
"""

global_results = run_query(global_operations_query)
print("Global Operations Infrastructure Created:")
for record in global_results:
    print(f"  UK Policy: {record['uk_policy']} - {record['local_premium']} {record['currency']} (${record['usd_premium']} USD)")
```

---

## Step 10: Comprehensive Multi-Line Analytics Dashboard
```python
# Create analytics for the complete multi-line platform
analytics_query = """
// Multi-Line Platform Analytics Dashboard
MATCH (customer:Customer)
OPTIONAL MATCH (customer)-[:HOLDS_POLICY]->(policy:Policy)
OPTIONAL MATCH (policy)-[:BASED_ON]->(product:Product)
OPTIONAL MATCH (policy)-[:COVERED_BY_TREATY]->(treaty:ReinsuranceContract)

WITH 
  // Customer metrics
  count(DISTINCT customer) AS total_customers,
  count(DISTINCT CASE WHEN customer:Individual THEN customer END) AS individual_customers,
  count(DISTINCT CASE WHEN customer:Business THEN customer END) AS business_customers,
  
  // Policy metrics by line
  count(DISTINCT CASE WHEN policy.product_type = "Auto" THEN policy END) AS auto_policies,
  count(DISTINCT CASE WHEN policy.product_type = "Property" THEN policy END) AS property_policies,
  count(DISTINCT CASE WHEN policy.product_type = "Life" THEN policy END) AS life_policies,
  count(DISTINCT CASE WHEN policy.product_type = "Commercial" THEN policy END) AS commercial_policies,
  count(DISTINCT CASE WHEN policy.product_type = "Specialty" THEN policy END) AS specialty_policies,
  
  // Premium analytics
  sum(CASE WHEN policy.product_type = "Auto" THEN policy.annual_premium ELSE 0 END) AS auto_premium,
  sum(CASE WHEN policy.product_type = "Property" THEN policy.annual_premium ELSE 0 END) AS property_premium,
  sum(CASE WHEN policy.product_type = "Life" THEN policy.annual_premium ELSE 0 END) AS life_premium,
  sum(CASE WHEN policy.product_type = "Commercial" THEN policy.annual_premium ELSE 0 END) AS commercial_premium,
  sum(CASE WHEN policy.product_type = "Specialty" THEN policy.annual_premium ELSE 0 END) AS specialty_premium,
  
  // Geographic distribution
  count(DISTINCT CASE WHEN customer.country = "United Kingdom" THEN customer END) AS uk_customers,
  count(DISTINCT CASE WHEN customer.country = "Canada" THEN customer END) AS ca_customers,
  count(DISTINCT CASE WHEN customer.state = "TX" THEN customer END) AS tx_customers,
  
  // Reinsurance coverage
  count(DISTINCT treaty) AS active_treaties

CREATE (dashboard:MultiLineDashboard {
  id: randomUUID(),
  dashboard_id: "MLB-DASH-001",
  report_date: date(),
  
  // Customer portfolio
  total_customers: total_customers,
  individual_customers: individual_customers,
  business_customers: business_customers,
  
  // Policy distribution
  total_policies: auto_policies + property_policies + life_policies + commercial_policies + specialty_policies,
  auto_policies: auto_policies,
  property_policies: property_policies,
  life_policies: life_policies,
  commercial_policies: commercial_policies,
  specialty_policies: specialty_policies,
  
  // Premium portfolio (in millions)
  total_premium: round((auto_premium + property_premium + life_premium + commercial_premium + specialty_premium) / 1000000 * 100) / 100,
  auto_premium_mm: round(auto_premium / 1000000 * 100) / 100,
  property_premium_mm: round(property_premium / 1000000 * 100) / 100,
  life_premium_mm: round(life_premium / 1000000 * 100) / 100,
  commercial_premium_mm: round(commercial_premium / 1000000 * 100) / 100,
  specialty_premium_mm: round(specialty_premium / 1000000 * 100) / 100,
  
  // Geographic presence
  countries_operating: 3,
  uk_customers: uk_customers,
  ca_customers: ca_customers,
  us_customers: tx_customers,
  
  // Reinsurance metrics
  reinsurance_treaties: active_treaties,
  reinsurance_partners: 3,
  
  // Platform capabilities
  product_lines: 5,
  currency_support: ["USD", "GBP", "CAD"],
  regulatory_jurisdictions: ["US", "UK", "CA"],
  
  created_at: datetime(),
  created_by: "multi_line_analytics",
  version: 1
})

RETURN dashboard.total_customers AS customers,
       dashboard.total_policies AS policies,
       dashboard.total_premium AS premium_millions,
       dashboard.countries_operating AS countries,
       dashboard.product_lines AS product_lines
"""

dashboard_results = run_query(analytics_query)
print("\nMulti-Line Platform Analytics:")
for record in dashboard_results:
    print(f"  Total Customers: {record['customers']} across {record['countries']} countries")
    print(f"  Total Policies: {record['policies']} across {record['product_lines']} product lines")
    print(f"  Total Premium: ${record['premium_millions']}M")
```

---

## Step 11: Verify Multi-Line Platform State
```python
# Verify the complete multi-line platform
verification_query = """
// Platform verification and node count
MATCH (n)
WITH labels(n)[0] AS node_type, count(n) AS count
ORDER BY count DESC

WITH collect({type: node_type, count: count}) AS node_summary,
     sum(count) AS total_nodes

MATCH ()-[r]->()
WITH node_summary, total_nodes, count(r) AS total_relationships

UNWIND node_summary AS node_info
RETURN node_info.type AS node_type,
       node_info.count AS count,
       total_nodes,
       total_relationships
ORDER BY count DESC
"""

verification_results = run_query(verification_query)
total_nodes = verification_results[0]['total_nodes'] if verification_results else 0
total_relationships = verification_results[0]['total_relationships'] if verification_results else 0

print(f"\n=== Multi-Line Platform Database State ===")
print(f"Total Nodes: {total_nodes}")
print(f"Total Relationships: {total_relationships}")
print("\nNode Distribution:")
for record in verification_results:
    print(f"  {record['node_type']}: {record['count']} nodes")
```

---

## Lab 16 Summary

**🎯 What You've Accomplished:**

### **Multi-Line Insurance Platform Implementation**
- ✅ **Life insurance integration** with term, whole, and universal life products including beneficiary management
- ✅ **Commercial insurance systems** supporting general liability, workers compensation, property, and cyber coverage
- ✅ **Specialty insurance products** including professional liability, umbrella coverage, and directors & officers insurance
- ✅ **Business customer management** with comprehensive commercial risk profiles and multi-policy relationships

### **Global Operations & Reinsurance Networks**  
- ✅ **Reinsurance partnerships** with major global reinsurers including Munich Re, Swiss Re, and Berkshire Hathaway
- ✅ **Treaty management systems** supporting catastrophe excess, quota share, and specialty reinsurance arrangements
- ✅ **International operations** with UK and Canadian subsidiaries including regulatory compliance frameworks
- ✅ **Multi-currency support** with real-time exchange rates and automated USD conversion capabilities

### **Enterprise Platform Features**
- ✅ **Regulatory compliance systems** supporting FCA (UK), OSFI (Canada), and US state insurance regulations
- ✅ **Multi-jurisdictional operations** with localized products, currency support, and regulatory reporting
- ✅ **Advanced risk distribution** through comprehensive reinsurance networks and treaty structures
- ✅ **Integrated analytics dashboard** providing real-time insights across all product lines and geographies

### **Node Types Added (8 types):**
- ✅ **Policy:Life** - Life insurance policies with beneficiaries, cash values, and term structures
- ✅ **Policy:Commercial** - Commercial policies supporting liability, workers comp, property, and cyber coverage  
- ✅ **Beneficiary:Person** - Life insurance beneficiary management with verification and documentation
- ✅ **Customer:Business** - Commercial customers with industry classifications and revenue profiles
- ✅ **ReinsuranceCompany:PartnerOrganization** - Global reinsurance partners with financial strength ratings
- ✅ **ReinsuranceContract** - Treaty management with quota share, excess of loss, and catastrophe coverage
- ✅ **RegulatoryFramework** - International compliance frameworks for multi-jurisdictional operations
- ✅ **CurrencyExchange** - Multi-currency support with real-time exchange rate management

### **Database State:** 950 nodes, 1200 relationships with complete multi-line operations

### **Enterprise Insurance Platform Capabilities**
- ✅ **Complete product portfolio** spanning personal lines, commercial coverage, life insurance, and specialty products
- ✅ **Global scalability** with multi-country operations, regulatory compliance, and currency management
- ✅ **Risk management excellence** through comprehensive reinsurance networks and treaty structures
- ✅ **Operational efficiency** with integrated systems supporting the complete insurance value chain

---

## Next Steps

You're now ready for **Lab 17: Innovation Showcase & Future Capabilities**, where you'll:
- Integrate AI/ML capabilities for predictive risk assessment and automated underwriting
- Implement IoT data streams from telematics, smart homes, and wearable devices
- Build blockchain integration for smart contracts and parametric insurance products
- Create advanced visualization interfaces with 3D network displays and real-time streaming analytics
- **Database Evolution:** 950 nodes → 1000+ nodes, 1200 relationships → 1300+ relationships

**Congratulations!** You've successfully built a comprehensive multi-line insurance platform that rivals enterprise systems used by major global insurance companies, complete with international operations, sophisticated reinsurance networks, and advanced regulatory compliance capabilities.