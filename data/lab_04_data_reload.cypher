// Neo4j Lab 4 - Data Reload Script
// Complete data setup for Lab 4: Bulk Data Import & Quality Control
// Run this script if you need to reload the Lab 4 data state
// Includes Labs 1-3 data + Constraints, Indexes, Bulk Import Data, Additional Agents

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: CREATE CONSTRAINTS AND INDEXES
// ===================================

CREATE CONSTRAINT customer_number_unique IF NOT EXISTS
FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;

CREATE CONSTRAINT policy_number_unique IF NOT EXISTS
FOR (p:Policy) REQUIRE p.policy_number IS UNIQUE;

CREATE CONSTRAINT claim_number_unique IF NOT EXISTS
FOR (cl:Claim) REQUIRE cl.claim_number IS UNIQUE;

CREATE CONSTRAINT agent_id_unique IF NOT EXISTS
FOR (a:Agent) REQUIRE a.agent_id IS UNIQUE;

CREATE CONSTRAINT vin_unique IF NOT EXISTS
FOR (v:Vehicle) REQUIRE v.vin IS UNIQUE;

CREATE INDEX customer_risk_tier IF NOT EXISTS
FOR (c:Customer) ON (c.risk_tier);

CREATE INDEX policy_status IF NOT EXISTS
FOR (p:Policy) ON (p.policy_status);

CREATE INDEX claim_status IF NOT EXISTS
FOR (cl:Claim) ON (cl.claim_status);

CREATE INDEX customer_location IF NOT EXISTS
FOR (c:Customer) ON (c.city, c.state);

// ===================================
// STEP 3: LABS 1-3 FOUNDATION ASSUMED
// ===================================
// Labs 1-3 foundation entities (customers, agents, products, policies, claims, etc.) already loaded
// Lab 4 adds constraints, indexes, bulk import data, and additional agents

// ===================================
// STEP 4: BULK CUSTOMER IMPORT
// ===================================

WITH [
  {customer_number: "CUST-001237", first_name: "James", last_name: "Wilson", city: "Houston", state: "TX", zip_code: "77002", credit_score: 685, risk_tier: "Standard", customer_since: date("2019-03-15"), lifetime_value: 8900.00},
  {customer_number: "CUST-001238", first_name: "Maria", last_name: "Garcia", city: "Dallas", state: "TX", zip_code: "75201", credit_score: 745, risk_tier: "Preferred", customer_since: date("2020-07-22"), lifetime_value: 15600.00},
  {customer_number: "CUST-001239", first_name: "Robert", last_name: "Kim", city: "Austin", state: "TX", zip_code: "78703", credit_score: 720, risk_tier: "Standard", customer_since: date("2021-11-08"), lifetime_value: 12300.00},
  {customer_number: "CUST-001240", first_name: "Jennifer", last_name: "Brown", city: "San Antonio", state: "TX", zip_code: "78201", credit_score: 660, risk_tier: "Standard", customer_since: date("2018-05-12"), lifetime_value: 9800.00},
  {customer_number: "CUST-001241", first_name: "William", last_name: "Davis", city: "Austin", state: "TX", zip_code: "78704", credit_score: 780, risk_tier: "Preferred", customer_since: date("2022-01-30"), lifetime_value: 18900.00},
  {customer_number: "CUST-001242", first_name: "Linda", last_name: "Miller", city: "Houston", state: "TX", zip_code: "77003", credit_score: 635, risk_tier: "Substandard", customer_since: date("2017-09-14"), lifetime_value: 6700.00},
  {customer_number: "CUST-001243", first_name: "Christopher", last_name: "Anderson", city: "Dallas", state: "TX", zip_code: "75202", credit_score: 710, risk_tier: "Standard", customer_since: date("2020-12-03"), lifetime_value: 11400.00},
  {customer_number: "CUST-001244", first_name: "Patricia", last_name: "Taylor", city: "Austin", state: "TX", zip_code: "78705", credit_score: 755, risk_tier: "Preferred", customer_since: date("2019-06-18"), lifetime_value: 16800.00},
  {customer_number: "CUST-001245", first_name: "Matthew", last_name: "Thomas", city: "San Antonio", state: "TX", zip_code: "78202", credit_score: 695, risk_tier: "Standard", customer_since: date("2021-04-25"), lifetime_value: 10200.00},
  {customer_number: "CUST-001246", first_name: "Barbara", last_name: "Jackson", city: "Houston", state: "TX", zip_code: "77004", credit_score: 725, risk_tier: "Standard", customer_since: date("2018-10-07"), lifetime_value: 13700.00}
] AS customerData

UNWIND customerData AS row
MERGE (c:Customer:Individual {customer_number: row.customer_number})
ON CREATE SET
  c.id = randomUUID(),
  c.first_name = row.first_name,
  c.last_name = row.last_name,
  c.email = toLower(row.first_name) + "." + toLower(row.last_name) + "@email.com",
  c.phone = "555-" + toString(toInteger(rand() * 9000) + 1000),
  c.address = toString(toInteger(rand() * 9999) + 1) + " " +
    CASE toInteger(rand() * 10)
      WHEN 0 THEN "Main St" WHEN 1 THEN "Oak Ave" WHEN 2 THEN "Pine Dr"
      WHEN 3 THEN "Elm St" WHEN 4 THEN "Maple Ave" WHEN 5 THEN "Cedar Ln"
      WHEN 6 THEN "Park Blvd" WHEN 7 THEN "First St" WHEN 8 THEN "Second Ave"
      ELSE "Third Dr" END,
  c.city = row.city, c.state = row.state, c.zip_code = row.zip_code,
  c.date_of_birth = date("1970-01-01") + duration({days: toInteger(rand() * 7300)}),
  c.ssn_last_four = toString(toInteger(rand() * 9000) + 1000),
  c.credit_score = row.credit_score, c.customer_since = row.customer_since,
  c.risk_tier = row.risk_tier, c.lifetime_value = row.lifetime_value,
  c.created_at = datetime(), c.created_by = "bulk_import_system",
  c.last_updated = datetime(), c.version = 1;

// ===================================
// STEP 5: BULK AUTO POLICY IMPORT
// ===================================

WITH [
  {customer_number: "CUST-001237", policy_number: "POL-AUTO-001237", auto_make: "Ford", auto_model: "F-150", auto_year: 2021, vin: "1FTFW1E50MFC12345", annual_premium: 1450.00, deductible: 500},
  {customer_number: "CUST-001238", policy_number: "POL-AUTO-001238", auto_make: "Chevrolet", auto_model: "Malibu", auto_year: 2022, vin: "1G1ZD5ST5NF123456", annual_premium: 1180.00, deductible: 250},
  {customer_number: "CUST-001239", policy_number: "POL-AUTO-001239", auto_make: "Nissan", auto_model: "Altima", auto_year: 2023, vin: "1N4BL4BV5PC123456", annual_premium: 1220.00, deductible: 500},
  {customer_number: "CUST-001240", policy_number: "POL-AUTO-001240", auto_make: "Hyundai", auto_model: "Elantra", auto_year: 2020, vin: "KMHL14JA8LA123456", annual_premium: 1100.00, deductible: 1000},
  {customer_number: "CUST-001241", policy_number: "POL-AUTO-001241", auto_make: "BMW", auto_model: "X5", auto_year: 2023, vin: "5UXCR6C09P9123456", annual_premium: 2200.00, deductible: 250},
  {customer_number: "CUST-001242", policy_number: "POL-AUTO-001242", auto_make: "Kia", auto_model: "Forte", auto_year: 2019, vin: "3KPF24AD8KE123456", annual_premium: 1350.00, deductible: 1000},
  {customer_number: "CUST-001243", policy_number: "POL-AUTO-001243", auto_make: "Subaru", auto_model: "Outback", auto_year: 2022, vin: "4S4BSANC1N3123456", annual_premium: 1380.00, deductible: 500},
  {customer_number: "CUST-001244", policy_number: "POL-AUTO-001244", auto_make: "Audi", auto_model: "Q7", auto_year: 2023, vin: "WA1VAAF70PD123456", annual_premium: 2400.00, deductible: 250},
  {customer_number: "CUST-001245", policy_number: "POL-AUTO-001245", auto_make: "Mazda", auto_model: "CX-5", auto_year: 2021, vin: "JM3KFBCM1M0123456", annual_premium: 1280.00, deductible: 500},
  {customer_number: "CUST-001246", policy_number: "POL-AUTO-001246", auto_make: "Volkswagen", auto_model: "Jetta", auto_year: 2022, vin: "3VW2B7AJ4NM123456", annual_premium: 1150.00, deductible: 750}
] AS policyData

UNWIND policyData AS row
MATCH (customer:Customer {customer_number: row.customer_number})
MERGE (policy:Policy:Auto:Active {policy_number: row.policy_number})
ON CREATE SET
  policy.id = randomUUID(), policy.product_type = "Auto", policy.policy_status = "Active",
  policy.effective_date = date() - duration({days: toInteger(rand() * 365)}),
  policy.expiration_date = date() + duration({months: toInteger(rand() * 6) + 6}),
  policy.annual_premium = row.annual_premium, policy.deductible = row.deductible,
  policy.coverage_limit = 100000 + toInteger(rand() * 400000),
  policy.payment_frequency =
    CASE toInteger(rand() * 4) WHEN 0 THEN "Monthly" WHEN 1 THEN "Quarterly" WHEN 2 THEN "Semi-Annual" ELSE "Annual" END,
  policy.auto_make = row.auto_make, policy.auto_model = row.auto_model, policy.auto_year = row.auto_year,
  policy.vin = row.vin, policy.vehicle_value = row.annual_premium * (15 + toInteger(rand() * 20)),
  policy.usage_type = "Personal", policy.created_at = datetime(),
  policy.created_by = "bulk_import_system", policy.underwriter = "system_auto", policy.version = 1

MERGE (customer)-[:HOLDS_POLICY {
  relationship_start: policy.effective_date,
  policyholder_type: "Primary",
  created_at: datetime()
}]->(policy);

// ===================================
// STEP 6: CREATE CORRESPONDING VEHICLES
// ===================================

MATCH (policy:Policy:Auto)
WHERE policy.policy_number STARTS WITH "POL-AUTO-00124"
AND NOT EXISTS { (policy)-[:COVERS]->(:Vehicle) }

WITH policy
MERGE (vehicle:Vehicle:Asset {vin: policy.vin})
ON CREATE SET
  vehicle.id = randomUUID(), vehicle.make = policy.auto_make, vehicle.model = policy.auto_model,
  vehicle.year = policy.auto_year,
  vehicle.color = CASE toInteger(rand() * 8) WHEN 0 THEN "White" WHEN 1 THEN "Black" WHEN 2 THEN "Silver" WHEN 3 THEN "Blue" WHEN 4 THEN "Red" WHEN 5 THEN "Gray" WHEN 6 THEN "Green" ELSE "Brown" END,
  vehicle.vehicle_type = CASE WHEN policy.auto_model IN ["F-150"] THEN "Truck" WHEN policy.auto_model IN ["X5", "Q7", "CX-5"] THEN "SUV" ELSE "Sedan" END,
  vehicle.engine_size = CASE toInteger(rand() * 4) WHEN 0 THEN "1.5L" WHEN 1 THEN "2.0L" WHEN 2 THEN "2.5L" ELSE "3.0L" END,
  vehicle.fuel_type = CASE toInteger(rand() * 3) WHEN 0 THEN "Gasoline" WHEN 1 THEN "Hybrid" ELSE "Electric" END,
  vehicle.market_value = policy.vehicle_value, vehicle.mileage = 5000 + toInteger(rand() * 80000),
  vehicle.safety_rating = 4 + toInteger(rand() * 2), vehicle.anti_theft_devices = ["Alarm"],
  vehicle.license_plate = toString(toInteger(rand() * 9) + 1) +
    CASE toInteger(rand() * 26) WHEN 0 THEN "A" WHEN 1 THEN "B" WHEN 2 THEN "C" WHEN 3 THEN "D" WHEN 4 THEN "E" WHEN 5 THEN "F" WHEN 6 THEN "G" WHEN 7 THEN "H" WHEN 8 THEN "I" WHEN 9 THEN "J" WHEN 10 THEN "K" WHEN 11 THEN "L" WHEN 12 THEN "M" WHEN 13 THEN "N" WHEN 14 THEN "O" WHEN 15 THEN "P" WHEN 16 THEN "Q" WHEN 17 THEN "R" WHEN 18 THEN "S" WHEN 19 THEN "T" WHEN 20 THEN "U" WHEN 21 THEN "V" WHEN 22 THEN "W" WHEN 23 THEN "X" WHEN 24 THEN "Y" ELSE "Z" END +
    CASE toInteger(rand() * 26) WHEN 0 THEN "A" WHEN 1 THEN "B" WHEN 2 THEN "C" WHEN 3 THEN "D" WHEN 4 THEN "E" WHEN 5 THEN "F" WHEN 6 THEN "G" WHEN 7 THEN "H" WHEN 8 THEN "I" WHEN 9 THEN "J" WHEN 10 THEN "K" WHEN 11 THEN "L" WHEN 12 THEN "M" WHEN 13 THEN "N" WHEN 14 THEN "O" WHEN 15 THEN "P" WHEN 16 THEN "Q" WHEN 17 THEN "R" WHEN 18 THEN "S" WHEN 19 THEN "T" WHEN 20 THEN "U" WHEN 21 THEN "V" WHEN 22 THEN "W" WHEN 23 THEN "X" WHEN 24 THEN "Y" ELSE "Z" END + "-" + toString(toInteger(rand() * 9000) + 1000),
  vehicle.registration_state = "TX", vehicle.created_at = datetime(),
  vehicle.created_by = "bulk_import_system", vehicle.version = 1

MERGE (policy)-[:COVERS {
  coverage_start: policy.effective_date,
  coverage_types: ["Liability", "Collision", "Comprehensive"],
  deductible_collision: policy.deductible,
  deductible_comprehensive: policy.deductible,
  created_at: datetime()
}]->(vehicle);

// ===================================
// STEP 7: CREATE ADDITIONAL AGENTS
// ===================================

WITH [
  {agent_id: "AGT-003", first_name: "Sarah", last_name: "Williams", territory: "Houston Metro", branch_id: "BR-003", performance_rating: "Very Good"},
  {agent_id: "AGT-004", first_name: "Michael", last_name: "Jones", territory: "Dallas Metro", branch_id: "BR-002", performance_rating: "Excellent"},
  {agent_id: "AGT-005", first_name: "Jessica", last_name: "Brown", territory: "San Antonio", branch_id: "BR-001", performance_rating: "Good"},
  {agent_id: "AGT-006", first_name: "Christopher", last_name: "Davis", territory: "Central Austin", branch_id: "BR-001", performance_rating: "Very Good"}
] AS agentData

UNWIND agentData AS row
MERGE (agent:Agent:Employee {agent_id: row.agent_id})
ON CREATE SET
  agent.id = randomUUID(), agent.employee_id = "EMP-" + toString(20000 + toInteger(rand() * 10000)),
  agent.first_name = row.first_name, agent.last_name = row.last_name,
  agent.email = toLower(row.first_name) + "." + toLower(row.last_name) + "@insurance.com",
  agent.phone = "555-" + toString(toInteger(rand() * 9000) + 1000),
  agent.license_number = "TX-INS-" + toString(100000 + toInteger(rand() * 900000)),
  agent.license_expiration = date() + duration({years: 2}), agent.territory = row.territory,
  agent.commission_rate = 0.10 + (rand() * 0.05),
  agent.hire_date = date() - duration({years: toInteger(rand() * 8) + 1}),
  agent.performance_rating = row.performance_rating,
  agent.ytd_sales = 50000 + toInteger(rand() * 100000), agent.customer_count = 0,
  agent.sales_quota = 120000 + toInteger(rand() * 80000),
  agent.created_at = datetime(), agent.created_by = "hr_system", agent.version = 1;

// ===================================
// STEP 8: ASSIGN CUSTOMERS TO AGENTS BY TERRITORY
// ===================================

MATCH (customer:Customer)
WHERE NOT EXISTS { (customer)<-[:SERVICES]-(:Agent) }

WITH customer,
  CASE customer.city
    WHEN "Houston" THEN "AGT-003"
    WHEN "Dallas" THEN "AGT-004"
    WHEN "San Antonio" THEN "AGT-005"
    WHEN "Austin" THEN
      CASE toInteger(rand() * 3)
        WHEN 0 THEN "AGT-001"
        WHEN 1 THEN "AGT-002"
        ELSE "AGT-006"
      END
    ELSE "AGT-001"
  END AS assigned_agent_id

MATCH (agent:Agent {agent_id: assigned_agent_id})
MERGE (agent)-[:SERVICES {
  relationship_start: customer.customer_since,
  service_quality:
    CASE toInteger(rand() * 4)
      WHEN 0 THEN "Excellent" WHEN 1 THEN "Very Good" WHEN 2 THEN "Good" ELSE "Satisfactory" END,
  last_contact: date() - duration({days: toInteger(rand() * 90)}),
  created_at: datetime()
}]->(customer)

WITH agent, count(customer) AS new_customers
SET agent.customer_count = agent.customer_count + new_customers;

// ===================================
// STEP 9: ADD MORE VEHICLES TO MEET TEST REQUIREMENTS
// ===================================
// Tests require at least 12 vehicles total, add 3 more

UNWIND range(1, 3) AS idx
CREATE (v:Vehicle {
  id: randomUUID(),
  vin: substring(toString(randomUUID()), 0, 17),
  make: ["Honda", "Toyota", "Ford"][idx % 3],
  model: ["Accord", "Camry", "F-150"][idx % 3],
  year: 2020 + (idx % 3),
  license_plate: toString(toInteger(rand() * 9) + 1) + substring("ABCDEFGHIJKLMNOPQRSTUVWXYZ", toInteger(rand() * 26), 1) + substring("ABCDEFGHIJKLMNOPQRSTUVWXYZ", toInteger(rand() * 26), 1) + "-" + toString(toInteger(rand() * 9000) + 1000),
  color: ["Blue", "Silver", "Black"][idx % 3],
  vehicle_type: "Automobile",
  mileage: toInteger(25000 + rand() * 50000),
  created_at: datetime(),
  created_by: "bulk_import",
  version: 1
});

// ===================================
// STEP 10: LAB 1-3 ENTITIES ALREADY EXIST
// ===================================
// Original policies and relationships were created in Labs 1-3
// Lab 4 only adds new bulk import data and additional agents

// ===================================
// STEP 11: VERIFICATION
// ===================================

// Verify Lab 4 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Expected result: 150 nodes, 200 relationships