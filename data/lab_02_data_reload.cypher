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
// STEP 2: LAB 1 FOUNDATION ASSUMED
// ===================================
// This lab builds on Lab 1 - entities created in Lab 1 are assumed to exist
// Using MATCH to reference existing entities from Lab 1

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
// STEP 5: LAB 1 POLICIES ASSUMED
// ===================================
// Policies and their relationships were already created in Lab 1
// Lab 2 only adds organizational structure (branches, departments, agent assignments)

// ===================================
// STEP 6: CREATE LAB 2 RELATIONSHIPS (NEW ONLY)
// ===================================
// Note: Customer-Policy-Agent-Product relationships already exist from Lab 1
// Only creating NEW relationships introduced in Lab 2

// Agent-Branch relationships (NEW in Lab 2)
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"})
MATCH (branch_austin:Branch {branch_id: "BR-001"})
MATCH (branch_dallas:Branch {branch_id: "BR-002"})
MATCH (dept_sales:Department {department_code: "SALES"})

CREATE (agent1)-[:WORKS_AT {start_date: date("2018-03-01"), office_location: "Floor 3, Desk 15", parking_space: "A-23", created_at: datetime()}]->(branch_austin)
CREATE (agent2)-[:WORKS_AT {start_date: date("2019-07-15"), office_location: "Floor 2, Desk 8", parking_space: "B-14", created_at: datetime()}]->(branch_dallas)

// Agent-Department relationships (NEW in Lab 2)
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

// Expected result after Lab 2: 16 nodes, 14 relationships
// (Lab 1: 10 nodes + Lab 2: 6 nodes = 16 nodes)
// (Lab 1: 10 relationships + Lab 2: 4 relationships = 14 relationships)