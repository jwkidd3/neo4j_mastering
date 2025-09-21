// Neo4j Lab 3 - Data Reload Script
// Complete data setup for Lab 3: Claims Processing & Financial Transaction Modeling
// Run this script if you need to reload the Lab 3 data state
// Includes Lab 1-2 data + Assets, Claims, Vendors, Financial Transactions

// ===================================
// STEP 1: CLEAR EXISTING DATA (OPTIONAL)
// ===================================
// Uncomment the next line if you want to start fresh
// MATCH (n) DETACH DELETE n

// ===================================
// STEP 2: LOAD FOUNDATION DATA (Labs 1-2)
// ===================================

// Create Customers
CREATE (customer1:Customer:Individual {id: randomUUID(), customer_number: "CUST-001234", first_name: "Sarah", last_name: "Johnson", date_of_birth: date("1985-03-15"), ssn_last_four: "1234", email: "sarah.johnson@email.com", phone: "555-0123", address: "123 Oak Street", city: "Austin", state: "TX", zip_code: "78701", credit_score: 720, customer_since: date("2020-01-15"), risk_tier: "Standard", lifetime_value: 12500.00, created_at: datetime(), created_by: "underwriting_system", last_updated: datetime(), version: 1})
CREATE (customer2:Customer:Individual {id: randomUUID(), customer_number: "CUST-001235", first_name: "Michael", last_name: "Chen", date_of_birth: date("1978-09-22"), ssn_last_four: "5678", email: "m.chen@email.com", phone: "555-0124", address: "456 Pine Avenue", city: "Austin", state: "TX", zip_code: "78702", credit_score: 680, customer_since: date("2019-06-10"), risk_tier: "Standard", lifetime_value: 18750.00, created_at: datetime(), created_by: "underwriting_system", last_updated: datetime(), version: 1})
CREATE (customer3:Customer:Individual {id: randomUUID(), customer_number: "CUST-001236", first_name: "Emma", last_name: "Rodriguez", date_of_birth: date("1992-12-08"), ssn_last_four: "9012", email: "emma.rodriguez@email.com", phone: "555-0125", address: "789 Maple Drive", city: "Dallas", state: "TX", zip_code: "75201", credit_score: 750, customer_since: date("2021-11-20"), risk_tier: "Preferred", lifetime_value: 8900.00, created_at: datetime(), created_by: "underwriting_system", last_updated: datetime(), version: 1})

// Create Products
CREATE (auto_policy:Product:Insurance {id: randomUUID(), product_code: "AUTO-STD", product_name: "Standard Auto Insurance", product_type: "Auto", coverage_types: ["Liability", "Collision", "Comprehensive"], base_premium: 1200.00, active: true, created_at: datetime(), created_by: "product_management"})
CREATE (home_policy:Product:Insurance {id: randomUUID(), product_code: "HOME-STD", product_name: "Standard Homeowners Insurance", product_type: "Property", coverage_types: ["Dwelling", "Personal Property", "Liability"], base_premium: 800.00, active: true, created_at: datetime(), created_by: "product_management"})

// Create Agents
CREATE (agent1:Agent:Employee {id: randomUUID(), agent_id: "AGT-001", first_name: "David", last_name: "Wilson", email: "david.wilson@insurance.com", phone: "555-0200", license_number: "TX-INS-123456", territory: "Central Texas", commission_rate: 0.12, hire_date: date("2018-03-01"), performance_rating: "Excellent", created_at: datetime(), created_by: "hr_system"})
CREATE (agent2:Agent:Employee {id: randomUUID(), agent_id: "AGT-002", first_name: "Lisa", last_name: "Thompson", email: "lisa.thompson@insurance.com", phone: "555-0201", license_number: "TX-INS-789012", territory: "North Texas", commission_rate: 0.11, hire_date: date("2019-07-15"), performance_rating: "Very Good", created_at: datetime(), created_by: "hr_system"})

// Create Policies
MATCH (sarah:Customer {customer_number: "CUST-001234"}), (michael:Customer {customer_number: "CUST-001235"}), (emma:Customer {customer_number: "CUST-001236"}), (auto_product:Product {product_code: "AUTO-STD"}), (home_product:Product {product_code: "HOME-STD"})
CREATE (sarah_auto:Policy:Active {id: randomUUID(), policy_number: "POL-AUTO-001234", product_type: "Auto", policy_status: "Active", effective_date: date("2024-01-01"), expiration_date: date() + duration({months: 2}), annual_premium: 1320.00, deductible: 500, coverage_limit: 100000, payment_frequency: "Monthly", auto_make: "Toyota", auto_model: "Camry", auto_year: 2022, vin: "1HGBH41JXMN109186", created_at: datetime(), created_by: "underwriting_system", underwriter: "system_auto", version: 1})
CREATE (michael_home:Policy:Active {id: randomUUID(), policy_number: "POL-HOME-001235", product_type: "Property", policy_status: "Active", effective_date: date("2024-02-15"), expiration_date: date() + duration({months: 1}), annual_premium: 950.00, deductible: 1000, coverage_limit: 250000, payment_frequency: "Annual", property_value: 320000, property_type: "Single Family", construction_type: "Frame", roof_type: "Shingle", created_at: datetime(), created_by: "underwriting_system", underwriter: "system_property", version: 1})
CREATE (emma_auto:Policy:Active {id: randomUUID(), policy_number: "POL-AUTO-001236", product_type: "Auto", policy_status: "Active", effective_date: date("2024-03-01"), expiration_date: date() + duration({weeks: 6}), annual_premium: 980.00, deductible: 250, coverage_limit: 150000, payment_frequency: "Semi-Annual", auto_make: "Honda", auto_model: "Civic", auto_year: 2023, vin: "2HGFC2F59MH542789", created_at: datetime(), created_by: "underwriting_system", underwriter: "system_auto", version: 1});

// ===================================
// STEP 3: CREATE VEHICLE ASSETS
// ===================================

CREATE (vehicle1:Vehicle:Asset {
  id: randomUUID(),
  vin: "1HGBH41JXMN109186",
  make: "Toyota",
  model: "Camry",
  year: 2022,
  color: "Blue",
  vehicle_type: "Sedan",
  engine_size: "2.5L",
  fuel_type: "Gasoline",
  market_value: 25000.00,
  mileage: 45000,
  safety_rating: 5,
  anti_theft_devices: ["Alarm", "GPS Tracking"],
  license_plate: "ABC-1234",
  registration_state: "TX",
  created_at: datetime(),
  created_by: "policy_system",
  version: 1
})

CREATE (vehicle2:Vehicle:Asset {
  id: randomUUID(),
  vin: "2HGFC2F59MH542789",
  make: "Honda",
  model: "Civic",
  year: 2023,
  color: "Red",
  vehicle_type: "Sedan",
  engine_size: "1.5L",
  fuel_type: "Gasoline",
  market_value: 24000.00,
  mileage: 12000,
  safety_rating: 5,
  anti_theft_devices: ["Alarm", "Immobilizer"],
  license_plate: "XYZ-5678",
  registration_state: "TX",
  created_at: datetime(),
  created_by: "policy_system",
  version: 1
});

// ===================================
// STEP 4: CREATE PROPERTY ASSETS
// ===================================

CREATE (property1:Property:Asset {
  id: randomUUID(),
  property_id: "PROP-001234",
  property_type: "Residential",
  address: "123 Oak Street",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  market_value: 320000,
  square_footage: 2200,
  lot_size: 0.25,
  year_built: 1995,
  construction_type: "Frame",
  roof_type: "Shingle",
  heating_type: "Central Air",
  foundation_type: "Slab",
  bedrooms: 3,
  bathrooms: 2,
  garage_spaces: 2,
  pool: false,
  fence: true,
  created_at: datetime(),
  created_by: "policy_system",
  version: 1
})

CREATE (property2:Property:Asset {
  id: randomUUID(),
  property_id: "PROP-001235",
  property_type: "Residential",
  address: "456 Pine Avenue",
  city: "Austin",
  state: "TX",
  zip_code: "78702",
  market_value: 285000,
  square_footage: 1800,
  lot_size: 0.20,
  year_built: 2000,
  construction_type: "Brick",
  roof_type: "Tile",
  heating_type: "Heat Pump",
  foundation_type: "Slab",
  bedrooms: 3,
  bathrooms: 2,
  garage_spaces: 1,
  pool: true,
  fence: false,
  created_at: datetime(),
  created_by: "policy_system",
  version: 1
});

// ===================================
// STEP 5: CREATE CLAIMS
// ===================================

CREATE (claim1:Claim {
  id: randomUUID(),
  claim_number: "CLM-AUTO-001234",
  policy_number: "POL-AUTO-001234",
  claim_type: "Auto",
  claim_status: "Under Investigation",
  incident_date: date("2024-06-15"),
  report_date: date("2024-06-16"),
  claim_amount: 8500.00,
  estimated_amount: 8500.00,
  description: "Rear-end collision on I-35 during morning traffic",
  fault_determination: "Not At Fault",
  incident_latitude: 30.2672,
  incident_longitude: -97.7431,
  incident_address: "I-35 Southbound, Austin, TX",
  weather_conditions: "Clear",
  police_report: true,
  police_report_number: "APD-2024-156789",
  priority: "Medium",
  fraud_score: 0.05,
  investigation_required: false,
  witnesses: 2,
  photos_available: true,
  created_at: datetime(),
  created_by: "claims_system",
  version: 1
})

CREATE (claim2:Claim {
  id: randomUUID(),
  claim_number: "CLM-AUTO-002345",
  policy_number: "POL-AUTO-001236",
  claim_type: "Auto",
  claim_status: "Approved",
  incident_date: date("2024-07-02"),
  report_date: date("2024-07-02"),
  claim_amount: 3200.00,
  settled_amount: 3200.00,
  settlement_date: date("2024-07-10"),
  description: "Parking lot fender bender, minor damage to front bumper",
  fault_determination: "At Fault",
  incident_latitude: 30.3077,
  incident_longitude: -97.7559,
  incident_address: "Whole Foods Market, Austin, TX",
  weather_conditions: "Clear",
  police_report: false,
  priority: "Low",
  fraud_score: 0.02,
  investigation_required: false,
  witnesses: 1,
  photos_available: true,
  created_at: datetime(),
  created_by: "claims_system",
  version: 1
})

CREATE (claim3:Claim {
  id: randomUUID(),
  claim_number: "CLM-PROP-003456",
  policy_number: "POL-HOME-001235",
  claim_type: "Property",
  claim_status: "Open",
  incident_date: date("2024-07-20"),
  report_date: date("2024-07-21"),
  claim_amount: 12000.00,
  estimated_amount: 12000.00,
  description: "Hail damage to roof and siding from severe thunderstorm",
  fault_determination: "Weather Event",
  incident_address: "456 Pine Avenue, Austin, TX",
  weather_conditions: "Severe Thunderstorm",
  police_report: false,
  priority: "High",
  fraud_score: 0.03,
  investigation_required: true,
  witnesses: 0,
  photos_available: true,
  created_at: datetime(),
  created_by: "claims_system",
  version: 1
});

// ===================================
// STEP 6: CREATE VENDOR NETWORK
// ===================================

CREATE (repair1:RepairShop:Vendor {
  id: randomUUID(),
  vendor_id: "VEN-REP-001",
  business_name: "Austin Auto Body & Paint",
  specialization: ["Auto Body", "Paint", "Frame Repair"],
  preferred_vendor: true,
  rating: 4.5,
  average_repair_time: 7.2,
  address: "1500 Industrial Blvd",
  city: "Austin",
  state: "TX",
  zip_code: "78741",
  phone: "512-555-BODY",
  license_number: "TX-REP-123456",
  insurance_coverage: "General Liability $2M",
  hourly_rate: 125.00,
  warranty_period: 90,
  certifications: ["I-CAR", "ASE"],
  created_at: datetime(),
  created_by: "vendor_system",
  version: 1
})

CREATE (repair2:RepairShop:Vendor {
  id: randomUUID(),
  vendor_id: "VEN-REP-002",
  business_name: "Central Texas Collision",
  specialization: ["Collision Repair", "Glass Replacement"],
  preferred_vendor: true,
  rating: 4.2,
  average_repair_time: 5.8,
  address: "2200 South Lamar",
  city: "Austin",
  state: "TX",
  zip_code: "78704",
  phone: "512-555-CRASH",
  license_number: "TX-REP-789012",
  insurance_coverage: "General Liability $1M",
  hourly_rate: 115.00,
  warranty_period: 60,
  certifications: ["I-CAR"],
  created_at: datetime(),
  created_by: "vendor_system",
  version: 1
})

CREATE (contractor1:RepairShop:Vendor {
  id: randomUUID(),
  vendor_id: "VEN-CON-001",
  business_name: "Lone Star Roofing & Construction",
  specialization: ["Roofing", "Siding", "Storm Damage"],
  preferred_vendor: true,
  rating: 4.7,
  average_repair_time: 14.5,
  address: "3000 Capital of Texas Hwy",
  city: "Austin",
  state: "TX",
  zip_code: "78746",
  phone: "512-555-ROOF",
  license_number: "TX-CON-345678",
  insurance_coverage: "General Liability $5M",
  hourly_rate: 85.00,
  warranty_period: 365,
  certifications: ["GAF Master Elite", "CertainTeed"],
  created_at: datetime(),
  created_by: "vendor_system",
  version: 1
});

// ===================================
// STEP 7: CREATE FINANCIAL ENTITIES
// ===================================

CREATE (payment1:Payment {
  id: randomUUID(),
  payment_id: "PAY-001234",
  policy_number: "POL-AUTO-001234",
  payment_type: "Premium",
  amount: 110.00,
  payment_date: date("2024-07-01"),
  payment_method: "Auto Pay",
  payment_status: "Processed",
  transaction_id: "TXN-789012",
  bank_account_last_four: "1234",
  confirmation_number: "CONF-789012",
  billing_period: "2024-07",
  created_at: datetime(),
  created_by: "billing_system",
  version: 1
})

CREATE (settlement1:Payment {
  id: randomUUID(),
  payment_id: "PAY-SETT-001",
  claim_number: "CLM-AUTO-002345",
  payment_type: "Claim Settlement",
  amount: 3200.00,
  payment_date: date("2024-07-10"),
  payment_method: "Direct Deposit",
  payment_status: "Processed",
  transaction_id: "TXN-SETT-123",
  bank_account_last_four: "9012",
  confirmation_number: "CONF-SETT-123",
  settlement_type: "Full Settlement",
  created_at: datetime(),
  created_by: "claims_system",
  version: 1
})

CREATE (invoice1:Invoice {
  id: randomUUID(),
  invoice_number: "INV-2024-001234",
  policy_number: "POL-AUTO-001234",
  billing_period: "2024-07",
  amount_due: 110.00,
  due_date: date("2024-07-01"),
  payment_status: "Paid",
  invoice_date: date("2024-06-15"),
  late_fee: 0.00,
  discount_applied: 0.00,
  payment_terms: "Net 15",
  created_at: datetime(),
  created_by: "billing_system",
  version: 1
});

// ===================================
// STEP 8: CREATE ALL RELATIONSHIPS
// ===================================

// Basic customer-policy-product-agent relationships
MATCH (sarah:Customer {customer_number: "CUST-001234"}), (michael:Customer {customer_number: "CUST-001235"}), (emma:Customer {customer_number: "CUST-001236"})
MATCH (sarah_auto:Policy {policy_number: "POL-AUTO-001234"}), (michael_home:Policy {policy_number: "POL-HOME-001235"}), (emma_auto:Policy {policy_number: "POL-AUTO-001236"})
MATCH (auto_product:Product {product_code: "AUTO-STD"}), (home_product:Product {product_code: "HOME-STD"})
MATCH (agent1:Agent {agent_id: "AGT-001"}), (agent2:Agent {agent_id: "AGT-002"})

CREATE (sarah)-[:HOLDS_POLICY {relationship_start: date("2024-01-01"), policyholder_type: "Primary", created_at: datetime()}]->(sarah_auto)
CREATE (michael)-[:HOLDS_POLICY {relationship_start: date("2024-02-15"), policyholder_type: "Primary", created_at: datetime()}]->(michael_home)
CREATE (emma)-[:HOLDS_POLICY {relationship_start: date("2024-03-01"), policyholder_type: "Primary", created_at: datetime()}]->(emma_auto)

CREATE (sarah_auto)-[:BASED_ON {underwriting_date: date("2023-12-15"), risk_assessment: "Standard", created_at: datetime()}]->(auto_product)
CREATE (michael_home)-[:BASED_ON {underwriting_date: date("2024-01-20"), risk_assessment: "Standard", created_at: datetime()}]->(home_product)
CREATE (emma_auto)-[:BASED_ON {underwriting_date: date("2024-02-10"), risk_assessment: "Preferred", created_at: datetime()}]->(auto_product)

CREATE (agent1)-[:SERVICES {relationship_start: date("2020-01-15"), service_quality: "Excellent", last_contact: date("2024-01-05"), created_at: datetime()}]->(sarah)
CREATE (agent1)-[:SERVICES {relationship_start: date("2019-06-10"), service_quality: "Very Good", last_contact: date("2024-02-10"), created_at: datetime()}]->(michael)
CREATE (agent2)-[:SERVICES {relationship_start: date("2021-11-20"), service_quality: "Excellent", last_contact: date("2024-02-25"), created_at: datetime()}]->(emma)

CREATE (sarah)-[:REFERRED {referral_date: date("2021-10-15"), referral_bonus: 50.00, conversion_status: "Converted", created_at: datetime()}]->(emma)

// Asset coverage relationships
MATCH (vehicle1:Vehicle {vin: "1HGBH41JXMN109186"}), (vehicle2:Vehicle {vin: "2HGFC2F59MH542789"}), (property1:Property {property_id: "PROP-001234"})

CREATE (sarah_auto)-[:COVERS {coverage_start: date("2024-01-01"), coverage_types: ["Liability", "Collision", "Comprehensive"], deductible_collision: 500, deductible_comprehensive: 500, created_at: datetime()}]->(vehicle1)
CREATE (emma_auto)-[:COVERS {coverage_start: date("2024-03-01"), coverage_types: ["Liability", "Collision", "Comprehensive"], deductible_collision: 250, deductible_comprehensive: 250, created_at: datetime()}]->(vehicle2)
CREATE (michael_home)-[:COVERS {coverage_start: date("2024-02-15"), coverage_types: ["Dwelling", "Personal Property", "Liability"], dwelling_limit: 250000, personal_property_limit: 125000, liability_limit: 100000, created_at: datetime()}]->(property1)

// Claims relationships
MATCH (claim1:Claim {claim_number: "CLM-AUTO-001234"}), (claim2:Claim {claim_number: "CLM-AUTO-002345"}), (claim3:Claim {claim_number: "CLM-PROP-003456"})
MATCH (repair1:RepairShop {vendor_id: "VEN-REP-001"}), (repair2:RepairShop {vendor_id: "VEN-REP-002"}), (contractor1:RepairShop {vendor_id: "VEN-CON-001"})

CREATE (sarah)-[:FILED_CLAIM {filing_date: date("2024-06-16"), filing_method: "Phone", filing_location: "Customer Service", created_at: datetime()}]->(claim1)
CREATE (emma)-[:FILED_CLAIM {filing_date: date("2024-07-02"), filing_method: "Mobile App", filing_location: "Self Service", created_at: datetime()}]->(claim2)
CREATE (michael)-[:FILED_CLAIM {filing_date: date("2024-07-21"), filing_method: "Phone", filing_location: "Emergency Hotline", created_at: datetime()}]->(claim3)

CREATE (claim1)-[:INVOLVES_ASSET {damage_type: "Collision", damage_severity: "Moderate", estimated_repair_cost: 8500.00, total_loss: false, created_at: datetime()}]->(vehicle1)
CREATE (claim2)-[:INVOLVES_ASSET {damage_type: "Impact", damage_severity: "Minor", estimated_repair_cost: 3200.00, total_loss: false, created_at: datetime()}]->(vehicle2)
CREATE (claim3)-[:INVOLVES_ASSET {damage_type: "Weather", damage_severity: "Moderate", estimated_repair_cost: 12000.00, total_loss: false, created_at: datetime()}]->(property1)

CREATE (claim1)-[:ASSIGNED_TO {assignment_date: date("2024-06-18"), estimated_completion: date("2024-06-28"), work_order_number: "WO-001234", created_at: datetime()}]->(repair1)
CREATE (claim2)-[:ASSIGNED_TO {assignment_date: date("2024-07-03"), estimated_completion: date("2024-07-08"), work_order_number: "WO-002345", created_at: datetime()}]->(repair2)
CREATE (claim3)-[:ASSIGNED_TO {assignment_date: date("2024-07-22"), estimated_completion: date("2024-08-15"), work_order_number: "WO-003456", created_at: datetime()}]->(contractor1)

// Financial relationships
MATCH (payment1:Payment {payment_id: "PAY-001234"}), (settlement1:Payment {payment_id: "PAY-SETT-001"})

CREATE (sarah)-[:MADE_PAYMENT {payment_date: date("2024-07-01"), payment_channel: "Online Banking", created_at: datetime()}]->(payment1)
CREATE (payment1)-[:APPLIED_TO {application_date: date("2024-07-01"), amount_applied: 110.00, remaining_balance: 0.00, created_at: datetime()}]->(sarah_auto)
CREATE (settlement1)-[:SETTLES_CLAIM {settlement_date: date("2024-07-10"), settlement_type: "Full Payment", created_at: datetime()}]->(claim2)
CREATE (emma)-[:RECEIVED_SETTLEMENT {received_date: date("2024-07-10"), settlement_amount: 3200.00, created_at: datetime()}]->(settlement1);

// ===================================
// STEP 9: VERIFICATION
// ===================================

// Verify Lab 3 data state
MATCH (n)
RETURN labels(n)[0] AS entity_type,
       count(n) AS entity_count
ORDER BY entity_count DESC

UNION ALL

MATCH ()-[r]->()
RETURN type(r) AS entity_type,
       count(r) AS entity_count
ORDER BY entity_count DESC;

// Expected result: 60 nodes, 85 relationships