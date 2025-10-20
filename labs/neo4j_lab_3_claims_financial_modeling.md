# Neo4j Lab 3: Claims Processing & Financial Transaction Modeling

## Overview
**Duration:** 45 minutes  
**Objective:** Implement complete claims processing workflows and financial transaction systems, adding critical business processes to the insurance network

Building on Lab 2's organizational structure, you'll now add the core business processes that drive insurance operations: claims processing, asset management, vendor networks, and financial transactions.

---

## Part 1: Asset Entities - Vehicles and Properties (10 minutes)

### Step 1: Create Vehicle Assets
Let's create the actual assets covered by our insurance policies:

```cypher
// Create vehicles associated with auto policies
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
})
```

### Step 2: Create Property Assets
```cypher
// Create properties for homeowners policies
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
})
```

### Step 3: Connect Assets to Policies
```cypher
// Link vehicles to auto policies
MATCH (vehicle1:Vehicle {vin: "1HGBH41JXMN109186"})
MATCH (vehicle2:Vehicle {vin: "2HGFC2F59MH542789"})
MATCH (sarah_auto:Policy {policy_number: "POL-AUTO-001234"})
MATCH (emma_auto:Policy {policy_number: "POL-AUTO-001236"})

CREATE (sarah_auto)-[:COVERS {
  coverage_start: date("2024-01-01"),
  coverage_types: ["Liability", "Collision", "Comprehensive"],
  deductible_collision: 500,
  deductible_comprehensive: 500,
  created_at: datetime()
}]->(vehicle1)

CREATE (emma_auto)-[:COVERS {
  coverage_start: date("2024-03-01"), 
  coverage_types: ["Liability", "Collision", "Comprehensive"],
  deductible_collision: 250,
  deductible_comprehensive: 250,
  created_at: datetime()
}]->(vehicle2)
```

```cypher
// Link properties to home policies  
MATCH (property1:Property {property_id: "PROP-001234"})
MATCH (property2:Property {property_id: "PROP-001235"})
MATCH (michael_home:Policy {policy_number: "POL-HOME-001235"})

CREATE (michael_home)-[:COVERS {
  coverage_start: date("2024-02-15"),
  coverage_types: ["Dwelling", "Personal Property", "Liability"],
  dwelling_limit: 250000,
  personal_property_limit: 125000,
  liability_limit: 100000,
  created_at: datetime()
}]->(property1)
```

---

## Part 2: Claims Processing System (15 minutes)

### Step 4: Create Insurance Claims
```cypher
// Create auto accident claim
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
  // Location data
  incident_latitude: 30.2672,
  incident_longitude: -97.7431,
  incident_address: "I-35 Southbound, Austin, TX",
  weather_conditions: "Clear",
  police_report: true,
  police_report_number: "APD-2024-156789",
  // Processing data
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
})
```

### Step 5: Create Vendor Network
```cypher
// Create repair shops and service providers
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
})
```

### Step 6: Create Claims Relationships

#### Part A: Customer Filed Claims
```cypher
// Connect claims to customers
MATCH (claim1:Claim {claim_number: "CLM-AUTO-001234"})
MATCH (claim2:Claim {claim_number: "CLM-AUTO-002345"})
MATCH (claim3:Claim {claim_number: "CLM-PROP-003456"})
MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (michael:Customer {customer_number: "CUST-001235"})

CREATE (sarah)-[:FILED_CLAIM {
  filing_date: date("2024-06-16"),
  filing_method: "Phone",
  filing_location: "Customer Service",
  created_at: datetime()
}]->(claim1)

CREATE (emma)-[:FILED_CLAIM {
  filing_date: date("2024-07-02"),
  filing_method: "Mobile App",
  filing_location: "Self Service",
  created_at: datetime()
}]->(claim2)

CREATE (michael)-[:FILED_CLAIM {
  filing_date: date("2024-07-21"),
  filing_method: "Phone",
  filing_location: "Emergency Hotline",
  created_at: datetime()
}]->(claim3)
```

#### Part B: Claims Involve Assets
```cypher
// Connect claims to assets
MATCH (claim1:Claim {claim_number: "CLM-AUTO-001234"})
MATCH (claim2:Claim {claim_number: "CLM-AUTO-002345"})
MATCH (claim3:Claim {claim_number: "CLM-PROP-003456"})
MATCH (vehicle1:Vehicle {vin: "1HGBH41JXMN109186"})
MATCH (vehicle2:Vehicle {vin: "2HGFC2F59MH542789"})
MATCH (property1:Property {property_id: "PROP-001234"})

CREATE (claim1)-[:INVOLVES_ASSET {
  damage_type: "Collision",
  damage_severity: "Moderate",
  estimated_repair_cost: 8500.00,
  total_loss: false,
  created_at: datetime()
}]->(vehicle1)

CREATE (claim2)-[:INVOLVES_ASSET {
  damage_type: "Impact",
  damage_severity: "Minor",
  estimated_repair_cost: 3200.00,
  total_loss: false,
  created_at: datetime()
}]->(vehicle2)

CREATE (claim3)-[:INVOLVES_ASSET {
  damage_type: "Weather",
  damage_severity: "Moderate",
  estimated_repair_cost: 12000.00,
  total_loss: false,
  created_at: datetime()
}]->(property1)
```

#### Part C: Claims Assigned to Vendors
```cypher
// Connect claims to repair vendors
MATCH (claim1:Claim {claim_number: "CLM-AUTO-001234"})
MATCH (claim2:Claim {claim_number: "CLM-AUTO-002345"})
MATCH (claim3:Claim {claim_number: "CLM-PROP-003456"})
MATCH (repair1:RepairShop {vendor_id: "VEN-REP-001"})
MATCH (repair2:RepairShop {vendor_id: "VEN-REP-002"})
MATCH (contractor1:RepairShop {vendor_id: "VEN-CON-001"})

CREATE (claim1)-[:ASSIGNED_TO {
  assignment_date: date("2024-06-18"),
  estimated_completion: date("2024-06-28"),
  work_order_number: "WO-001234",
  created_at: datetime()
}]->(repair1)

CREATE (claim2)-[:ASSIGNED_TO {
  assignment_date: date("2024-07-03"),
  estimated_completion: date("2024-07-08"),
  work_order_number: "WO-002345",
  created_at: datetime()
}]->(repair2)

CREATE (claim3)-[:ASSIGNED_TO {
  assignment_date: date("2024-07-22"),
  estimated_completion: date("2024-08-15"),
  work_order_number: "WO-003456",
  created_at: datetime()
}]->(contractor1)
```

---

## Part 3: Financial Transaction System (15 minutes)

### Step 7: Create Payment and Invoice Entities
```cypher
// Create premium payments
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

CREATE (payment2:Payment {
  id: randomUUID(),
  payment_id: "PAY-002345",
  policy_number: "POL-HOME-001235",
  payment_type: "Premium",
  amount: 950.00,
  payment_date: date("2024-07-15"),
  payment_method: "Bank Transfer",
  payment_status: "Processed",
  transaction_id: "TXN-890123",
  bank_account_last_four: "5678",
  confirmation_number: "CONF-890123",
  billing_period: "2024-Annual",
  created_at: datetime(),
  created_by: "billing_system",
  version: 1
})

CREATE (payment3:Payment {
  id: randomUUID(),
  payment_id: "PAY-003456",
  policy_number: "POL-AUTO-001236",
  payment_type: "Premium",
  amount: 81.67,
  payment_date: date("2024-07-01"),
  payment_method: "Credit Card",
  payment_status: "Processed",
  transaction_id: "TXN-901234",
  bank_account_last_four: "9012",
  confirmation_number: "CONF-901234",
  billing_period: "2024-07",
  created_at: datetime(),
  created_by: "billing_system",
  version: 1
})

// Create claim settlement payment
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
```

### Step 8: Create Invoice Entities
```cypher
// Create invoices for premium billing
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
})

CREATE (invoice2:Invoice {
  id: randomUUID(),
  invoice_number: "INV-2024-002345",
  policy_number: "POL-HOME-001235",
  billing_period: "2024-Annual",
  amount_due: 950.00,
  due_date: date("2024-07-15"),
  payment_status: "Paid",
  invoice_date: date("2024-06-30"),
  late_fee: 0.00,
  discount_applied: 50.00,
  payment_terms: "Net 30",
  created_at: datetime(),
  created_by: "billing_system",
  version: 1
})
```

### Step 9: Create Financial Relationships

#### Part A: Customer Payment Relationships
```cypher
// Connect customers to payments
MATCH (payment1:Payment {payment_id: "PAY-001234"})
MATCH (payment2:Payment {payment_id: "PAY-002345"})
MATCH (payment3:Payment {payment_id: "PAY-003456"})
MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})

CREATE (sarah)-[:MADE_PAYMENT {
  payment_date: date("2024-07-01"),
  payment_channel: "Online Banking",
  created_at: datetime()
}]->(payment1)

CREATE (michael)-[:MADE_PAYMENT {
  payment_date: date("2024-07-15"),
  payment_channel: "Bank Transfer",
  created_at: datetime()
}]->(payment2)

CREATE (emma)-[:MADE_PAYMENT {
  payment_date: date("2024-07-01"),
  payment_channel: "Auto Pay",
  created_at: datetime()
}]->(payment3)
```

#### Part B: Policy Payment Applications
```cypher
// Connect payments to policies
MATCH (payment1:Payment {payment_id: "PAY-001234"})
MATCH (payment2:Payment {payment_id: "PAY-002345"})
MATCH (payment3:Payment {payment_id: "PAY-003456"})
MATCH (sarah_auto:Policy {policy_number: "POL-AUTO-001234"})
MATCH (michael_home:Policy {policy_number: "POL-HOME-001235"})
MATCH (emma_auto:Policy {policy_number: "POL-AUTO-001236"})

CREATE (payment1)-[:APPLIED_TO {
  application_date: date("2024-07-01"),
  amount_applied: 110.00,
  remaining_balance: 0.00,
  created_at: datetime()
}]->(sarah_auto)

CREATE (payment2)-[:APPLIED_TO {
  application_date: date("2024-07-15"),
  amount_applied: 950.00,
  remaining_balance: 0.00,
  created_at: datetime()
}]->(michael_home)

CREATE (payment3)-[:APPLIED_TO {
  application_date: date("2024-07-01"),
  amount_applied: 81.67,
  remaining_balance: 0.00,
  created_at: datetime()
}]->(emma_auto)
```

#### Part C: Claim Settlement Relationships
```cypher
// Connect settlements to claims and customers
MATCH (settlement1:Payment {payment_id: "PAY-SETT-001"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (claim2:Claim {claim_number: "CLM-AUTO-002345"})

CREATE (settlement1)-[:SETTLES_CLAIM {
  settlement_date: date("2024-07-10"),
  settlement_type: "Full Payment",
  created_at: datetime()
}]->(claim2)

CREATE (emma)-[:RECEIVED_SETTLEMENT {
  received_date: date("2024-07-10"),
  settlement_amount: 3200.00,
  created_at: datetime()
}]->(settlement1)
```

---

## Part 4: Advanced Claims and Financial Analysis (5 minutes)

### Step 10: Claims Analysis Queries
```cypher
// Claims status summary
MATCH (c:Claim)
RETURN c.claim_status AS status,
       count(c) AS claim_count,
       avg(c.claim_amount) AS avg_claim_amount,
       sum(c.claim_amount) AS total_claim_amount
ORDER BY claim_count DESC
```

```cypher
// Claims by customer with asset information
MATCH (customer:Customer)-[:FILED_CLAIM]->(claim:Claim)
MATCH (claim)-[:INVOLVES_ASSET]->(asset)
RETURN customer.first_name + " " + customer.last_name AS customer_name,
       claim.claim_number AS claim_number,
       claim.claim_type AS claim_type,
       labels(asset)[0] AS asset_type,
       claim.claim_amount AS claim_amount,
       claim.claim_status AS status
ORDER BY claim.claim_amount DESC
```

### Step 11: Financial Performance Analysis
```cypher
// Premium collection summary
MATCH (p:Payment)
WHERE p.payment_type = "Premium"
RETURN count(p) AS total_payments,
       sum(p.amount) AS total_premiums_collected,
       avg(p.amount) AS average_payment,
       p.payment_method AS payment_method
ORDER BY total_premiums_collected DESC
```

```cypher
// Vendor performance analysis
MATCH (vendor:RepairShop)<-[:ASSIGNED_TO]-(claim:Claim)
RETURN vendor.business_name AS vendor,
       vendor.specialization AS services,
       count(claim) AS claims_assigned,
       avg(claim.claim_amount) AS avg_claim_value,
       vendor.rating AS vendor_rating,
       vendor.average_repair_time AS avg_repair_days
ORDER BY claims_assigned DESC
```

### Step 12: Complete Business Process Visualization
```cypher
// Complete claims and financial workflow visualization
MATCH (customer:Customer)-[r1:FILED_CLAIM]->(claim:Claim)
MATCH (claim)-[r2:INVOLVES_ASSET]->(asset)
MATCH (claim)-[r3:ASSIGNED_TO]->(vendor:RepairShop)
MATCH (customer)-[r4:MADE_PAYMENT]->(payment:Payment)
MATCH (payment)-[r5:APPLIED_TO]->(policy:Policy)
RETURN customer, r1, claim, r2, asset, r3, vendor, r4, payment, r5, policy
```

---

## Neo4j Lab 3 Summary

**🎯 What You've Accomplished:**

### **Claims Processing System**
- ✅ **Complete claims workflow** from incident reporting to vendor assignment
- ✅ **Asset management** with vehicles and properties linked to policies
- ✅ **Vendor network** with repair shops and contractors for claim services
- ✅ **Investigation tracking** with fraud scores and priority management

### **Financial Transaction System**
- ✅ **Premium payment processing** with multiple payment methods
- ✅ **Claim settlement payments** with direct deposit and settlement tracking
- ✅ **Invoice generation** with billing periods and payment terms
- ✅ **Financial relationship tracking** connecting customers, payments, and policies

### **Node Types Added (4 types):**
- ✅ **Claim** - Complete claims processing with investigation and settlement data
- ✅ **Vehicle:Asset/Property:Asset** - Insured assets with comprehensive coverage details
- ✅ **RepairShop:Vendor** - Service provider network with ratings and specializations
- ✅ **Payment/Invoice** - Financial transactions and billing management

### **Database State:** 60 nodes, 85 relationships with complete business workflows

### **Advanced Business Processes**
- ✅ **End-to-end claims processing** from filing to settlement
- ✅ **Asset coverage tracking** with damage assessment and repair coordination
- ✅ **Vendor management** with performance metrics and assignment workflows
- ✅ **Financial operations** with payment processing and settlement distribution

---

## Next Steps

You're now ready for **Lab 4: Bulk Data Import & Quality Control**, where you'll:
- Import large datasets using CSV processing for 100+ customers
- Implement data validation patterns and quality controls
- Add Invoice and expanded Payment entities for comprehensive financial tracking
- Master error handling and data consistency maintenance
- **Database Evolution:** 60 nodes → 150 nodes, 85 relationships → 200 relationships

**Congratulations!** You've built a comprehensive insurance business process system that handles the complete lifecycle from policy coverage through claims processing to financial settlement - the core operations that drive any insurance company.

## Troubleshooting

### If relationships aren't created:
- Check that all referenced entities exist with correct properties
- Verify MATCH clauses use exact property values from CREATE statements
- Use `MATCH (n) WHERE n.property_name = "value" RETURN n` to verify entities

### If claims queries return unexpected results:
- Check claim_status values: "Open", "Under Investigation", "Approved", "Denied", "Closed"
- Verify date formats and ranges in WHERE clauses
- Use PROFILE to analyze query performance with larger datasets