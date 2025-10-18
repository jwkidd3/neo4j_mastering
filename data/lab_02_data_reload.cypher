// Neo4j Lab 2 - Data Reload Script
// Complete data setup for Lab 2: Cypher Query Fundamentals
// Run this script if you need to reload the Lab 2 data state
// Includes Lab 1 data + Organizational Structure

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: LOAD LAB 1 DATA FIRST
// ===================================
// Run the Lab 1 reload script first, then continue with Lab 2 additions

// Create Lab 1 entities (shortened version)
CREATE (customer1:Customer:Individual {
  id: randomUUID(), customer_number: "CUST-001234", first_name: "Sarah", last_name: "Johnson",
  date_of_birth: date("1985-03-15"), ssn_last_four: "1234", email: "sarah.johnson@email.com",
  phone: "555-0123", address: "123 Oak Street", city: "Austin", state: "TX", zip_code: "78701",
  credit_score: 720, customer_since: date("2020-01-15"), risk_tier: "Standard", lifetime_value: 12500.00,
  created_at: datetime(), created_by: "underwriting_system", last_updated: datetime(), version: 1
})

CREATE (customer2:Customer:Individual {
  id: randomUUID(), customer_number: "CUST-001235", first_name: "Michael", last_name: "Chen",
  date_of_birth: date("1978-09-22"), ssn_last_four: "5678", email: "m.chen@email.com",
  phone: "555-0124", address: "456 Pine Avenue", city: "Austin", state: "TX", zip_code: "78702",
  credit_score: 680, customer_since: date("2019-06-10"), risk_tier: "Standard", lifetime_value: 18750.00,
  created_at: datetime(), created_by: "underwriting_system", last_updated: datetime(), version: 1
})

CREATE (customer3:Customer:Individual {
  id: randomUUID(), customer_number: "CUST-001236", first_name: "Emma", last_name: "Rodriguez",
  date_of_birth: date("1992-12-08"), ssn_last_four: "9012", email: "emma.rodriguez@email.com",
  phone: "555-0125", address: "789 Maple Drive", city: "Dallas", state: "TX", zip_code: "75201",
  credit_score: 750, customer_since: date("2021-11-20"), risk_tier: "Preferred", lifetime_value: 8900.00,
  created_at: datetime(), created_by: "underwriting_system", last_updated: datetime(), version: 1
})

CREATE (auto_policy:Product:Insurance {
  id: randomUUID(), product_code: "AUTO-STD", product_name: "Standard Auto Insurance",
  product_type: "Auto", coverage_types: ["Liability", "Collision", "Comprehensive"],
  base_premium: 1200.00, active: true, created_at: datetime(), created_by: "product_management"
})

CREATE (home_policy:Product:Insurance {
  id: randomUUID(), product_code: "HOME-STD", product_name: "Standard Homeowners Insurance",
  product_type: "Property", coverage_types: ["Dwelling", "Personal Property", "Liability"],
  base_premium: 800.00, active: true, created_at: datetime(), created_by: "product_management"
})

CREATE (agent1:Agent:Employee {
  id: randomUUID(), agent_id: "AGT-001", first_name: "David", last_name: "Wilson",
  email: "david.wilson@insurance.com", phone: "555-0200", license_number: "TX-INS-123456",
  territory: "Central Texas", commission_rate: 0.12, hire_date: date("2018-03-01"),
  performance_rating: "Excellent", created_at: datetime(), created_by: "hr_system"
})

CREATE (agent2:Agent:Employee {
  id: randomUUID(), agent_id: "AGT-002", first_name: "Lisa", last_name: "Thompson",
  email: "lisa.thompson@insurance.com", phone: "555-0201", license_number: "TX-INS-789012",
  territory: "North Texas", commission_rate: 0.11, hire_date: date("2019-07-15"),
  performance_rating: "Very Good", created_at: datetime(), created_by: "hr_system"
});

// ===================================
// STEP 3: CREATE BRANCH LOCATIONS
// ===================================

CREATE (branch_austin:Branch:Location {
  id: randomUUID(),
  branch_id: "BR-001",
  branch_name: "Austin Downtown",
  branch_type: "Regional",
  address: "100 Congress Ave",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  phone: "512-555-0100",
  employee_count: 25,
  customer_count: 1200,
  territory_coverage: ["Travis County", "Williamson County"],
  opened_date: date("2010-03-15"),
  created_at: datetime(),
  created_by: "admin_system",
  version: 1
})

CREATE (branch_dallas:Branch:Location {
  id: randomUUID(),
  branch_id: "BR-002",
  branch_name: "Dallas North",
  branch_type: "Regional",
  address: "500 Main Street",
  city: "Dallas",
  state: "TX",
  zip_code: "75201",
  phone: "214-555-0200",
  employee_count: 35,
  customer_count: 1800,
  territory_coverage: ["Dallas County", "Collin County"],
  opened_date: date("2008-09-20"),
  created_at: datetime(),
  created_by: "admin_system",
  version: 1
})

CREATE (branch_houston:Branch:Location {
  id: randomUUID(),
  branch_id: "BR-003",
  branch_name: "Houston Central",
  branch_type: "Regional",
  address: "800 Texas Ave",
  city: "Houston",
  state: "TX",
  zip_code: "77002",
  phone: "713-555-0300",
  employee_count: 40,
  customer_count: 2100,
  territory_coverage: ["Harris County", "Fort Bend County"],
  opened_date: date("2005-01-10"),
  created_at: datetime(),
  created_by: "admin_system",
  version: 1
});

// ===================================
// STEP 4: CREATE DEPARTMENTS
// ===================================

CREATE (dept_sales:Department {
  id: randomUUID(),
  department_name: "Sales",
  department_code: "SALES",
  budget: 3500000.00,
  head_count: 85,
  cost_center: "CC-1001",
  department_type: "Revenue",
  manager_title: "VP of Sales",
  quarterly_target: 15000000.00,
  created_at: datetime(),
  created_by: "hr_system",
  version: 1
})

CREATE (dept_claims:Department {
  id: randomUUID(),
  department_name: "Claims Processing",
  department_code: "CLAIMS",
  budget: 2800000.00,
  head_count: 65,
  cost_center: "CC-2001",
  department_type: "Operations",
  manager_title: "Claims Director",
  avg_settlement_time: 12.5,
  created_at: datetime(),
  created_by: "hr_system",
  version: 1
})

CREATE (dept_underwriting:Department {
  id: randomUUID(),
  department_name: "Underwriting",
  department_code: "UW",
  budget: 2200000.00,
  head_count: 45,
  cost_center: "CC-3001",
  department_type: "Operations",
  manager_title: "Chief Underwriter",
  approval_authority: 1000000.00,
  created_at: datetime(),
  created_by: "hr_system",
  version: 1
});

// ===================================
// STEP 5: CREATE POLICIES
// ===================================

MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (auto_product:Product {product_code: "AUTO-STD"})
MATCH (home_product:Product {product_code: "HOME-STD"})

CREATE (sarah_auto:Policy:Active {
  id: randomUUID(), policy_number: "POL-AUTO-001234", product_type: "Auto",
  policy_status: "Active", effective_date: date("2024-01-01"),
  expiration_date: date() + duration({months: 2}), annual_premium: 1320.00,
  deductible: 500, coverage_limit: 100000, payment_frequency: "Monthly",
  auto_make: "Toyota", auto_model: "Camry", auto_year: 2022,
  vin: "1HGBH41JXMN109186", created_at: datetime(),
  created_by: "underwriting_system", underwriter: "system_auto", version: 1
})

CREATE (michael_home:Policy:Active {
  id: randomUUID(), policy_number: "POL-HOME-001235", product_type: "Property",
  policy_status: "Active", effective_date: date("2024-02-15"),
  expiration_date: date() + duration({months: 1}), annual_premium: 950.00,
  deductible: 1000, coverage_limit: 250000, payment_frequency: "Annual",
  property_value: 320000, property_type: "Single Family",
  construction_type: "Frame", roof_type: "Shingle", created_at: datetime(),
  created_by: "underwriting_system", underwriter: "system_property", version: 1
})

CREATE (emma_auto:Policy:Active {
  id: randomUUID(), policy_number: "POL-AUTO-001236", product_type: "Auto",
  policy_status: "Active", effective_date: date("2024-03-01"),
  expiration_date: date() + duration({weeks: 6}), annual_premium: 980.00,
  deductible: 250, coverage_limit: 150000, payment_frequency: "Semi-Annual",
  auto_make: "Honda", auto_model: "Civic", auto_year: 2023,
  vin: "2HGFC2F59MH542789", created_at: datetime(),
  created_by: "underwriting_system", underwriter: "system_auto", version: 1
});

// ===================================
// STEP 6: CREATE ALL RELATIONSHIPS
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
MATCH (branch_austin:Branch {branch_id: "BR-001"})
MATCH (branch_dallas:Branch {branch_id: "BR-002"})
MATCH (dept_sales:Department {department_code: "SALES"})

CREATE (sarah)-[:HOLDS_POLICY {relationship_start: date("2024-01-01"), policyholder_type: "Primary", created_at: datetime()}]->(sarah_auto)
CREATE (michael)-[:HOLDS_POLICY {relationship_start: date("2024-02-15"), policyholder_type: "Primary", created_at: datetime()}]->(michael_home)
CREATE (emma)-[:HOLDS_POLICY {relationship_start: date("2024-03-01"), policyholder_type: "Primary", created_at: datetime()}]->(emma_auto)

// Policy-Product relationships
CREATE (sarah_auto)-[:BASED_ON {underwriting_date: date("2023-12-15"), risk_assessment: "Standard", created_at: datetime()}]->(auto_product)
CREATE (michael_home)-[:BASED_ON {underwriting_date: date("2024-01-20"), risk_assessment: "Standard", created_at: datetime()}]->(home_product)
CREATE (emma_auto)-[:BASED_ON {underwriting_date: date("2024-02-10"), risk_assessment: "Preferred", created_at: datetime()}]->(auto_product)

// Agent-Customer relationships
CREATE (agent1)-[:SERVICES {relationship_start: date("2020-01-15"), service_quality: "Excellent", last_contact: date("2024-01-05"), created_at: datetime()}]->(sarah)
CREATE (agent1)-[:SERVICES {relationship_start: date("2019-06-10"), service_quality: "Very Good", last_contact: date("2024-02-10"), created_at: datetime()}]->(michael)
CREATE (agent2)-[:SERVICES {relationship_start: date("2021-11-20"), service_quality: "Excellent", last_contact: date("2024-02-25"), created_at: datetime()}]->(emma)

// Customer referral relationships
CREATE (sarah)-[:REFERRED {referral_date: date("2021-10-15"), referral_bonus: 50.00, conversion_status: "Converted", created_at: datetime()}]->(emma)

// Agent-Branch relationships
CREATE (agent1)-[:WORKS_AT {start_date: date("2018-03-01"), office_location: "Floor 3, Desk 15", parking_space: "A-23", created_at: datetime()}]->(branch_austin)
CREATE (agent2)-[:WORKS_AT {start_date: date("2019-07-15"), office_location: "Floor 2, Desk 8", parking_space: "B-14", created_at: datetime()}]->(branch_dallas)

// Agent-Department relationships
CREATE (agent1)-[:MEMBER_OF {join_date: date("2018-03-01"), role: "Senior Sales Agent", salary_grade: "Grade 7", reports_to: "MGR-001", created_at: datetime()}]->(dept_sales)
CREATE (agent2)-[:MEMBER_OF {join_date: date("2019-07-15"), role: "Sales Agent", salary_grade: "Grade 6", reports_to: "MGR-002", created_at: datetime()}]->(dept_sales);

// ===================================
// STEP 7: VERIFICATION
// ===================================

// Verify Lab 2 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Expected result: 25 nodes, 40 relationships