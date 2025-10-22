// Neo4j Lab 16 - Data Reload Script
// Complete data setup for Lab 16: Multi-Line Insurance Platform
// Run this script if you need to reload the Lab 16 data state
// Includes Labs 1-15 data + Multi-Line Insurance Infrastructure

// ===================================
// STEP 1: LOAD LAB 15 FOUNDATION
// ===================================
// This builds on Lab 15 - ensure you have the foundation

// Import Lab 15 data first (this is a prerequisite)
// The lab_15_data_reload.cypher should be run first or data should exist

// ===================================
// STEP 2: MULTI-LINE INSURANCE ENTITIES
// ===================================

// Create Life Insurance Products
MERGE (lp1:Product:LifeInsurance {product_code: "LIFE-TERM-20"})
ON CREATE SET lp1.product_name = "20-Year Term Life Insurance",
    lp1.product_type = "Life",
    lp1.product_category = "Term Life",
    lp1.coverage_term_years = 20,
    lp1.max_coverage_amount = 5000000,
    lp1.min_coverage_amount = 100000,
    lp1.premium_calculation_method = "Age-Based",
    lp1.medical_exam_required = true,
    lp1.conversion_allowed = true,
    lp1.is_active = true,
    lp1.created_at = datetime()

MERGE (lp2:Product:LifeInsurance {product_code: "LIFE-WHOLE"})
ON CREATE SET lp2.product_name = "Whole Life Insurance",
    lp2.product_type = "Life",
    lp2.product_category = "Permanent Life",
    lp2.coverage_term_years = null,
    lp2.max_coverage_amount = 10000000,
    lp2.min_coverage_amount = 50000,
    lp2.premium_calculation_method = "Level Premium",
    lp2.medical_exam_required = true,
    lp2.cash_value_accumulation = true,
    lp2.is_active = true,
    lp2.created_at = datetime()

MERGE (lp3:Product:LifeInsurance {product_code: "LIFE-UNIVERSAL"})
ON CREATE SET lp3.product_name = "Universal Life Insurance",
    lp3.product_type = "Life",
    lp3.product_category = "Permanent Life",
    lp3.coverage_term_years = null,
    lp3.max_coverage_amount = 15000000,
    lp3.min_coverage_amount = 100000,
    lp3.premium_calculation_method = "Flexible Premium",
    lp3.medical_exam_required = true,
    lp3.cash_value_accumulation = true,
    lp3.investment_options = true,
    lp3.is_active = true,
    lp3.created_at = datetime();

// Create Commercial Insurance Products
MERGE (cp1:Product:CommercialInsurance {product_code: "COMM-GL"})
ON CREATE SET cp1.product_name = "Commercial General Liability",
    cp1.product_type = "Commercial",
    cp1.product_category = "Liability",
    cp1.coverage_type = "General Liability",
    cp1.max_coverage_amount = 10000000,
    cp1.min_coverage_amount = 500000,
    cp1.business_types_eligible = ["Retail", "Manufacturing", "Services"],
    cp1.policy_term_months = 12,
    cp1.is_active = true,
    cp1.created_at = datetime()

MERGE (cp2:Product:CommercialInsurance {product_code: "COMM-PROPERTY"})
ON CREATE SET cp2.product_name = "Commercial Property Insurance",
    cp2.product_type = "Commercial",
    cp2.product_category = "Property",
    cp2.coverage_type = "Building and Contents",
    cp2.max_coverage_amount = 50000000,
    cp2.min_coverage_amount = 100000,
    cp2.business_types_eligible = ["Retail", "Manufacturing", "Office", "Warehouse"],
    cp2.policy_term_months = 12,
    cp2.is_active = true,
    cp2.created_at = datetime()

MERGE (cp3:Product:CommercialInsurance {product_code: "COMM-WC"})
ON CREATE SET cp3.product_name = "Workers' Compensation Insurance",
    cp3.product_type = "Commercial",
    cp3.product_category = "Workers Compensation",
    cp3.coverage_type = "Employee Injury Protection",
    cp3.max_coverage_amount = null,
    cp3.min_coverage_amount = null,
    cp3.business_types_eligible = ["All"],
    cp3.policy_term_months = 12,
    cp3.mandatory_in_states = ["All 50 states"],
    cp3.is_active = true,
    cp3.created_at = datetime();

// Create Reinsurance Contracts
MERGE (rc1:ReinsuranceContract {contract_id: "REINS-2024-001"})
ON CREATE SET rc1.contract_name = "Catastrophe Excess of Loss Treaty",
    rc1.contract_type = "Excess of Loss",
    rc1.effective_date = date("2024-01-01"),
    rc1.expiration_date = date("2024-12-31"),
    rc1.reinsurer_name = "Global Re Limited",
    rc1.retention_amount = 10000000,
    rc1.limit_amount = 100000000,
    rc1.premium_amount = 5000000,
    rc1.coverage_territory = "United States",
    rc1.lines_of_business = ["Auto", "Homeowners"],
    rc1.contract_status = "Active",
    rc1.created_at = datetime()

MERGE (rc2:ReinsuranceContract {contract_id: "REINS-2024-002"})
ON CREATE SET rc2.contract_name = "Quota Share Treaty - Life",
    rc2.contract_type = "Quota Share",
    rc2.effective_date = date("2024-01-01"),
    rc2.expiration_date = date("2024-12-31"),
    rc2.reinsurer_name = "Life Reinsurance Corp",
    rc2.ceding_percentage = 0.30,
    rc2.commission_rate = 0.25,
    rc2.premium_amount = 8000000,
    rc2.coverage_territory = "North America",
    rc2.lines_of_business = ["Term Life", "Whole Life"],
    rc2.contract_status = "Active",
    rc2.created_at = datetime();

// Create Partner Organizations
MERGE (po1:PartnerOrganization {partner_id: "PART-BROKER-001"})
ON CREATE SET po1.partner_name = "Premier Insurance Brokers Inc",
    po1.partner_type = "Broker",
    po1.partnership_status = "Active",
    po1.partnership_start_date = date("2020-01-01"),
    po1.commission_rate = 0.12,
    po1.total_policies_written = 2500,
    po1.total_premium_volume = 15000000,
    po1.contact_person = "James Anderson",
    po1.contact_email = "james.anderson@premierbrokers.com",
    po1.contact_phone = "+1-555-0101",
    po1.created_at = datetime()

MERGE (po2:PartnerOrganization {partner_id: "PART-AGENCY-001"})
ON CREATE SET po2.partner_name = "Nationwide Agents Network",
    po2.partner_type = "Agency",
    po2.partnership_status = "Active",
    po2.partnership_start_date = date("2018-06-01"),
    po2.commission_rate = 0.15,
    po2.total_policies_written = 5000,
    po2.total_premium_volume = 28000000,
    po2.contact_person = "Maria Garcia",
    po2.contact_email = "m.garcia@nationwideagents.com",
    po2.contact_phone = "+1-555-0102",
    po2.created_at = datetime()

MERGE (po3:PartnerOrganization {partner_id: "PART-MGA-001"})
ON CREATE SET po3.partner_name = "Specialty Lines MGA",
    po3.partner_type = "MGA",
    po3.partnership_status = "Active",
    po3.partnership_start_date = date("2022-03-01"),
    po3.commission_rate = 0.18,
    po3.total_policies_written = 800,
    po3.total_premium_volume = 12000000,
    po3.specialty_lines = ["Commercial", "Professional Liability"],
    po3.contact_person = "Robert Chen",
    po3.contact_email = "r.chen@specialtylines.com",
    po3.contact_phone = "+1-555-0103",
    po3.created_at = datetime();

// Create Business Entities (Commercial customers)
MERGE (be1:BusinessEntity {business_id: "BUS-001"})
ON CREATE SET be1.business_name = "TechStart Solutions LLC",
    be1.business_type = "Technology Services",
    be1.industry = "Information Technology",
    be1.tax_id = "12-3456789",
    be1.incorporation_date = date("2020-05-15"),
    be1.employee_count = 45,
    be1.annual_revenue = 8500000,
    be1.primary_contact = "David Thompson",
    be1.contact_email = "david@techstart.com",
    be1.contact_phone = "+1-555-0201",
    be1.created_at = datetime()

MERGE (be2:BusinessEntity {business_id: "BUS-002"})
ON CREATE SET be2.business_name = "Riverside Manufacturing Co",
    be2.business_type = "Manufacturing",
    be2.industry = "Industrial Manufacturing",
    be2.tax_id = "98-7654321",
    be2.incorporation_date = date("1995-08-22"),
    be2.employee_count = 250,
    be2.annual_revenue = 45000000,
    be2.primary_contact = "Susan Martinez",
    be2.contact_email = "s.martinez@riverside-mfg.com",
    be2.contact_phone = "+1-555-0202",
    be2.created_at = datetime();

// Create Life Insurance Policies
MERGE (lip1:Policy:LifePolicy {policy_number: "LIFE-POL-2024-001"})
ON CREATE SET lip1.customer_id = "CUST-001234",
    lip1.product_code = "LIFE-TERM-20",
    lip1.policy_status = "Active",
    lip1.effective_date = date("2024-01-15"),
    lip1.expiration_date = date("2044-01-15"),
    lip1.coverage_amount = 1000000,
    lip1.annual_premium = 850.00,
    lip1.beneficiary_name = "Emily Johnson",
    lip1.beneficiary_relationship = "Spouse",
    lip1.medical_exam_completed = true,
    lip1.created_at = datetime()

MERGE (lip2:Policy:LifePolicy {policy_number: "LIFE-POL-2024-002"})
ON CREATE SET lip2.customer_id = "CUST-001235",
    lip2.product_code = "LIFE-WHOLE",
    lip2.policy_status = "Active",
    lip2.effective_date = date("2024-02-01"),
    lip2.expiration_date = null,
    lip2.coverage_amount = 500000,
    lip2.annual_premium = 3500.00,
    lip2.cash_value = 0.00,
    lip2.beneficiary_name = "Michael Williams",
    lip2.beneficiary_relationship = "Child",
    lip2.medical_exam_completed = true,
    lip2.created_at = datetime();

// Create Commercial Policies
MERGE (cop1:Policy:CommercialPolicy {policy_number: "COMM-POL-2024-001"})
ON CREATE SET cop1.business_id = "BUS-001",
    cop1.product_code = "COMM-GL",
    cop1.policy_status = "Active",
    cop1.effective_date = date("2024-01-01"),
    cop1.expiration_date = date("2025-01-01"),
    cop1.coverage_amount = 2000000,
    cop1.annual_premium = 12000.00,
    cop1.deductible = 5000.00,
    cop1.partner_id = "PART-BROKER-001",
    cop1.created_at = datetime()

MERGE (cop2:Policy:CommercialPolicy {policy_number: "COMM-POL-2024-002"})
ON CREATE SET cop2.business_id = "BUS-002",
    cop2.product_code = "COMM-PROPERTY",
    cop2.policy_status = "Active",
    cop2.effective_date = date("2024-02-01"),
    cop2.expiration_date = date("2025-02-01"),
    cop2.coverage_amount = 25000000,
    cop2.annual_premium = 85000.00,
    cop2.deductible = 25000.00,
    cop2.partner_id = "PART-MGA-001",
    cop2.created_at = datetime();

// Create Product Lines
MERGE (pl1:ProductLine {line_id: "LINE-PERSONAL"})
ON CREATE SET pl1.line_name = "Personal Lines",
    pl1.line_category = "Individual Insurance",
    pl1.product_count = 8,
    pl1.total_policies = 25000,
    pl1.total_premium_volume = 125000000,
    pl1.market_share_percentage = 0.15,
    pl1.created_at = datetime()

MERGE (pl2:ProductLine {line_id: "LINE-LIFE"})
ON CREATE SET pl2.line_name = "Life Insurance",
    pl2.line_category = "Life and Health",
    pl2.product_count = 5,
    pl2.total_policies = 12000,
    pl2.total_premium_volume = 85000000,
    pl2.market_share_percentage = 0.08,
    pl2.created_at = datetime()

MERGE (pl3:ProductLine {line_id: "LINE-COMMERCIAL"})
ON CREATE SET pl3.line_name = "Commercial Lines",
    pl3.line_category = "Business Insurance",
    pl3.product_count = 12,
    pl3.total_policies = 3500,
    pl3.total_premium_volume = 145000000,
    pl3.market_share_percentage = 0.12,
    pl3.created_at = datetime();

// ===================================
// STEP 3: MULTI-LINE INSURANCE RELATIONSHIPS
// ===================================

// Link Life Insurance Products to Product Line
MATCH (lp:LifeInsurance)
MATCH (pl:ProductLine {line_id: "LINE-LIFE"})
MERGE (lp)-[r:BELONGS_TO_LINE]->(pl)
ON CREATE SET r.created_at = datetime();

// Link Commercial Insurance Products to Product Line
MATCH (cp:CommercialInsurance)
MATCH (pl:ProductLine {line_id: "LINE-COMMERCIAL"})
MERGE (cp)-[r:BELONGS_TO_LINE]->(pl)
ON CREATE SET r.created_at = datetime();

// Link Life Policies to Customers
MATCH (lip:LifePolicy {policy_number: "LIFE-POL-2024-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:HOLDS_LIFE_POLICY]->(lip)
ON CREATE SET r.relationship_start = lip.effective_date

MATCH (lip:LifePolicy {policy_number: "LIFE-POL-2024-002"})
MATCH (c:Customer {customer_number: "CUST-001235"})
MERGE (c)-[r:HOLDS_LIFE_POLICY]->(lip)
ON CREATE SET r.relationship_start = lip.effective_date;

// Link Commercial Policies to Business Entities
MATCH (cop:CommercialPolicy {policy_number: "COMM-POL-2024-001"})
MATCH (be:BusinessEntity {business_id: "BUS-001"})
MERGE (be)-[r:HOLDS_COMMERCIAL_POLICY]->(cop)
ON CREATE SET r.relationship_start = cop.effective_date

MATCH (cop:CommercialPolicy {policy_number: "COMM-POL-2024-002"})
MATCH (be:BusinessEntity {business_id: "BUS-002"})
MERGE (be)-[r:HOLDS_COMMERCIAL_POLICY]->(cop)
ON CREATE SET r.relationship_start = cop.effective_date;

// Link Life Policies to Products
MATCH (lip:LifePolicy {policy_number: "LIFE-POL-2024-001"})
MATCH (lp:LifeInsurance {product_code: "LIFE-TERM-20"})
MERGE (lip)-[r:BASED_ON_PRODUCT]->(lp)

MATCH (lip:LifePolicy {policy_number: "LIFE-POL-2024-002"})
MATCH (lp:LifeInsurance {product_code: "LIFE-WHOLE"})
MERGE (lip)-[r:BASED_ON_PRODUCT]->(lp);

// Link Commercial Policies to Products
MATCH (cop:CommercialPolicy {policy_number: "COMM-POL-2024-001"})
MATCH (cp:CommercialInsurance {product_code: "COMM-GL"})
MERGE (cop)-[r:BASED_ON_PRODUCT]->(cp)

MATCH (cop:CommercialPolicy {policy_number: "COMM-POL-2024-002"})
MATCH (cp:CommercialInsurance {product_code: "COMM-PROPERTY"})
MERGE (cop)-[r:BASED_ON_PRODUCT]->(cp);

// Link Commercial Policies to Partner Organizations
MATCH (cop:CommercialPolicy {policy_number: "COMM-POL-2024-001"})
MATCH (po:PartnerOrganization {partner_id: "PART-BROKER-001"})
MERGE (cop)-[r:DISTRIBUTED_BY]->(po)
ON CREATE SET r.commission_rate = po.commission_rate,
    r.commission_amount = cop.annual_premium * po.commission_rate

MATCH (cop:CommercialPolicy {policy_number: "COMM-POL-2024-002"})
MATCH (po:PartnerOrganization {partner_id: "PART-MGA-001"})
MERGE (cop)-[r:DISTRIBUTED_BY]->(po)
ON CREATE SET r.commission_rate = po.commission_rate,
    r.commission_amount = cop.annual_premium * po.commission_rate;

// Link Reinsurance Contracts to Product Lines
MATCH (rc:ReinsuranceContract {contract_id: "REINS-2024-001"})
MATCH (pl:ProductLine {line_id: "LINE-PERSONAL"})
MERGE (rc)-[r:COVERS_PRODUCT_LINE]->(pl)
ON CREATE SET r.effective_date = rc.effective_date

MATCH (rc:ReinsuranceContract {contract_id: "REINS-2024-002"})
MATCH (pl:ProductLine {line_id: "LINE-LIFE"})
MERGE (rc)-[r:COVERS_PRODUCT_LINE]->(pl)
ON CREATE SET r.effective_date = rc.effective_date;

// Link Business Entities to Customers (owners)
MATCH (be:BusinessEntity {business_id: "BUS-001"})
MATCH (c:Customer {customer_number: "CUST-001234"})
MERGE (c)-[r:OWNS_BUSINESS]->(be)
ON CREATE SET r.ownership_percentage = 100,
    r.title = "Owner"

MATCH (be:BusinessEntity {business_id: "BUS-002"})
MATCH (c:Customer {customer_number: "CUST-001235"})
MERGE (c)-[r:OWNS_BUSINESS]->(be)
ON CREATE SET r.ownership_percentage = 45,
    r.title = "Partner";

// Link Partner Organizations to Agents
MATCH (po:PartnerOrganization {partner_id: "PART-BROKER-001"})
MATCH (a:Agent)
WHERE a.name CONTAINS "Anderson" OR a.name CONTAINS "Johnson"
WITH po, a LIMIT 1
MERGE (a)-[r:WORKS_FOR_PARTNER]->(po)
ON CREATE SET r.start_date = date("2020-01-01"),
    r.employment_type = "Full-time";

// Create cross-sell relationships
MATCH (lip:LifePolicy {policy_number: "LIFE-POL-2024-001"})
MATCH (p:Policy {policy_number: "POL-2024-001"})
WHERE NOT p:LifePolicy AND NOT p:CommercialPolicy
MERGE (lip)-[r:CROSS_SELL_OPPORTUNITY]->(p)
ON CREATE SET r.opportunity_score = 0.78,
    r.recommended_product = "Home + Life Bundle";

// ===================================
// VERIFICATION QUERIES
// ===================================

// Verify node counts
MATCH (n)
RETURN labels(n)[0] AS entity_type, count(n) AS entity_count
ORDER BY entity_count DESC;

// Expected result: ~950 nodes, ~1200 relationships with multi-line insurance infrastructure
