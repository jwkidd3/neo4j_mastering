// Neo4j Lab 1 - Data Reload Script
// Complete data setup for Lab 1: Enterprise Setup & Docker Connection
// Run this script if you need to reload the Lab 1 data state

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: CREATE DATABASE STRUCTURE
// ===================================

// Note: Database is specified via -d parameter in cypher-shell

// ===================================
// STEP 3: CREATE INSURANCE CUSTOMERS
// ===================================

CREATE (customer1:Customer:Individual {
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
  risk_tier: "Standard",
  lifetime_value: 12500.00,
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
})

CREATE (customer2:Customer:Individual {
  id: randomUUID(),
  customer_number: "CUST-001235",
  first_name: "Michael",
  last_name: "Chen",
  date_of_birth: date("1978-09-22"),
  ssn_last_four: "5678",
  email: "m.chen@email.com",
  phone: "555-0124",
  address: "456 Pine Avenue",
  city: "Austin",
  state: "TX",
  zip_code: "78702",
  credit_score: 680,
  customer_since: date("2019-06-10"),
  risk_tier: "Standard",
  lifetime_value: 18750.00,
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
})

CREATE (customer3:Customer:Individual {
  id: randomUUID(),
  customer_number: "CUST-001236",
  first_name: "Emma",
  last_name: "Rodriguez",
  date_of_birth: date("1992-12-08"),
  ssn_last_four: "9012",
  email: "emma.rodriguez@email.com",
  phone: "555-0125",
  address: "789 Maple Drive",
  city: "Dallas",
  state: "TX",
  zip_code: "75201",
  credit_score: 750,
  customer_since: date("2021-11-20"),
  risk_tier: "Preferred",
  lifetime_value: 8900.00,
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
});

// ===================================
// STEP 4: CREATE INSURANCE PRODUCTS
// ===================================

CREATE (auto_policy:Product:Insurance {
  id: randomUUID(),
  product_code: "AUTO-STD",
  product_name: "Standard Auto Insurance",
  product_type: "Auto",
  coverage_types: ["Liability", "Collision", "Comprehensive"],
  base_premium: 1200.00,
  active: true,
  created_at: datetime(),
  created_by: "product_management"
})

CREATE (home_policy:Product:Insurance {
  id: randomUUID(),
  product_code: "HOME-STD",
  product_name: "Standard Homeowners Insurance",
  product_type: "Property",
  coverage_types: ["Dwelling", "Personal Property", "Liability"],
  base_premium: 800.00,
  active: true,
  created_at: datetime(),
  created_by: "product_management"
});

// ===================================
// STEP 5: CREATE INSURANCE AGENTS
// ===================================

CREATE (agent1:Agent:Employee {
  id: randomUUID(),
  agent_id: "AGT-001",
  first_name: "David",
  last_name: "Wilson",
  email: "david.wilson@insurance.com",
  phone: "555-0200",
  license_number: "TX-INS-123456",
  territory: "Central Texas",
  commission_rate: 0.12,
  hire_date: date("2018-03-01"),
  performance_rating: "Excellent",
  created_at: datetime(),
  created_by: "hr_system"
})

CREATE (agent2:Agent:Employee {
  id: randomUUID(),
  agent_id: "AGT-002",
  first_name: "Lisa",
  last_name: "Thompson",
  email: "lisa.thompson@insurance.com",
  phone: "555-0201",
  license_number: "TX-INS-789012",
  territory: "North Texas",
  commission_rate: 0.11,
  hire_date: date("2019-07-15"),
  performance_rating: "Very Good",
  created_at: datetime(),
  created_by: "hr_system"
});

// ===================================
// STEP 6: CREATE INSURANCE POLICIES
// ===================================

MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (auto_product:Product {product_code: "AUTO-STD"})
MATCH (home_product:Product {product_code: "HOME-STD"})
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"})

// Sarah's auto policy
CREATE (sarah_auto:Policy:Active {
  id: randomUUID(),
  policy_number: "POL-AUTO-001234",
  product_type: "Auto",
  policy_status: "Active",
  effective_date: date("2024-01-01"),
  expiration_date: date() + duration({months: 2}),
  annual_premium: 1320.00,
  deductible: 500,
  coverage_limit: 100000,
  payment_frequency: "Monthly",
  auto_make: "Toyota",
  auto_model: "Camry",
  auto_year: 2022,
  vin: "1HGBH41JXMN109186",
  created_at: datetime(),
  created_by: "underwriting_system",
  underwriter: "system_auto",
  version: 1
})

// Michael's home policy
CREATE (michael_home:Policy:Active {
  id: randomUUID(),
  policy_number: "POL-HOME-001235",
  product_type: "Property",
  policy_status: "Active",
  effective_date: date("2024-02-15"),
  expiration_date: date() + duration({months: 1}),
  annual_premium: 950.00,
  deductible: 1000,
  coverage_limit: 250000,
  payment_frequency: "Annual",
  property_value: 320000,
  property_type: "Single Family",
  construction_type: "Frame",
  roof_type: "Shingle",
  created_at: datetime(),
  created_by: "underwriting_system",
  underwriter: "system_property",
  version: 1
})

// Emma's auto policy
CREATE (emma_auto:Policy:Active {
  id: randomUUID(),
  policy_number: "POL-AUTO-001236",
  product_type: "Auto",
  policy_status: "Active",
  effective_date: date("2024-03-01"),
  expiration_date: date() + duration({weeks: 6}),
  annual_premium: 980.00,
  deductible: 250,
  coverage_limit: 150000,
  payment_frequency: "Semi-Annual",
  auto_make: "Honda",
  auto_model: "Civic",
  auto_year: 2023,
  vin: "2HGFC2F59MH542789",
  created_at: datetime(),
  created_by: "underwriting_system",
  underwriter: "system_auto",
  version: 1
});

// ===================================
// STEP 7: CREATE RELATIONSHIPS
// ===================================

// Customer-Policy relationships
MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (sarah_auto:Policy {policy_number: "POL-AUTO-001234"})
MATCH (michael_home:Policy {policy_number: "POL-HOME-001235"})
MATCH (emma_auto:Policy {policy_number: "POL-AUTO-001236"})
MATCH (auto_product:Product {product_code: "AUTO-STD"})
MATCH (home_product:Product {product_code: "HOME-STD"})
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"})

CREATE (sarah)-[:HOLDS_POLICY {
  relationship_start: date("2024-01-01"),
  policyholder_type: "Primary",
  created_at: datetime()
}]->(sarah_auto)

CREATE (michael)-[:HOLDS_POLICY {
  relationship_start: date("2024-02-15"),
  policyholder_type: "Primary",
  created_at: datetime()
}]->(michael_home)

CREATE (emma)-[:HOLDS_POLICY {
  relationship_start: date("2024-03-01"),
  policyholder_type: "Primary",
  created_at: datetime()
}]->(emma_auto)

// Policy-Product relationships
CREATE (sarah_auto)-[:BASED_ON {
  underwriting_date: date("2023-12-15"),
  risk_assessment: "Standard",
  created_at: datetime()
}]->(auto_product)

CREATE (michael_home)-[:BASED_ON {
  underwriting_date: date("2024-01-20"),
  risk_assessment: "Standard",
  created_at: datetime()
}]->(home_product)

CREATE (emma_auto)-[:BASED_ON {
  underwriting_date: date("2024-02-10"),
  risk_assessment: "Preferred",
  created_at: datetime()
}]->(auto_product)

// Agent-Customer relationships
CREATE (agent1)-[:SERVICES {
  relationship_start: date("2020-01-15"),
  service_quality: "Excellent",
  last_contact: date("2024-01-05"),
  created_at: datetime()
}]->(sarah)

CREATE (agent1)-[:SERVICES {
  relationship_start: date("2019-06-10"),
  service_quality: "Very Good",
  last_contact: date("2024-02-10"),
  created_at: datetime()
}]->(michael)

CREATE (agent2)-[:SERVICES {
  relationship_start: date("2021-11-20"),
  service_quality: "Excellent",
  last_contact: date("2024-02-25"),
  created_at: datetime()
}]->(emma)

// Customer referral relationships
CREATE (sarah)-[:REFERRED {
  referral_date: date("2021-10-15"),
  referral_bonus: 50.00,
  conversion_status: "Converted",
  created_at: datetime()
}]->(emma);

// ===================================
// STEP 8: VERIFICATION
// ===================================

// Verify Lab 1 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Expected result: 10 nodes, 15 relationships