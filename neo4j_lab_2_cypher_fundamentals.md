# Neo4j Lab 2: Cypher Query Fundamentals

## Overview
**Duration:** 45 minutes  
**Objective:** Master advanced Cypher query patterns using the MWR memory aid and expand the insurance network with organizational entities

Building on Lab 1's foundation, you'll now master the fundamental Cypher query structure using the **MWR memory aid** (MATCH-WHERE-RETURN) and expand your insurance database with organizational entities including branches and departments.

---

## Part 1: MWR Memory Aid Mastery (10 minutes)

### Step 1: Understanding the MWR Pattern
The **MWR memory aid** helps structure every Cypher query:
- **M**ATCH: Find patterns in the graph
- **W**HERE: Filter the results  
- **R**ETURN: Specify what to return

### Step 2: Basic MWR Pattern Practice
```cypher
// MWR Pattern: Find all customers
MATCH (c:Customer)           // M - MATCH the pattern
WHERE c.risk_tier = "Standard"  // W - WHERE to filter
RETURN c.first_name, c.last_name, c.credit_score  // R - RETURN specific data
```

```cypher
// MWR Pattern: Find active auto policies
MATCH (p:Policy:Auto)
WHERE p.policy_status = "Active"
RETURN p.policy_number, p.annual_premium, p.auto_make, p.auto_model
```

```cypher
// MWR Pattern: Find agents in specific territory
MATCH (a:Agent)
WHERE a.territory = "Central Texas"
RETURN a.first_name + " " + a.last_name AS agent_name, a.performance_rating
```

### Step 3: MWR with Relationships
```cypher
// MWR Pattern: Find customer-policy relationships
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)    // M - MATCH relationship pattern
WHERE p.annual_premium > 1000                     // W - WHERE condition on premium
RETURN c.first_name + " " + c.last_name AS customer_name,
       p.policy_number,
       p.annual_premium                           // R - RETURN customer and policy data
```

---

## Part 2: Organizational Structure Expansion (15 minutes)

### Step 4: Add Insurance Company Branches
Let's expand our insurance network with branch locations:

```cypher
// Create branch offices using enterprise patterns
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
})
```

### Step 5: Create Department Structure
```cypher
// Create departments with budget and operational data
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
})
```

### Step 6: Connect Agents to Branches
```cypher
// Connect existing agents to branch locations
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"})
MATCH (branch_austin:Branch {branch_id: "BR-001"})
MATCH (branch_dallas:Branch {branch_id: "BR-002"})

// Agent-Branch relationships
CREATE (agent1)-[:WORKS_AT {
  start_date: date("2018-03-01"),
  office_location: "Floor 3, Desk 15",
  parking_space: "A-23",
  created_at: datetime()
}]->(branch_austin)

CREATE (agent2)-[:WORKS_AT {
  start_date: date("2019-07-15"),
  office_location: "Floor 2, Desk 8",
  parking_space: "B-14",
  created_at: datetime()
}]->(branch_dallas)
```

### Step 7: Create Department Relationships
```cypher
// Connect agents to departments
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"}) 
MATCH (dept_sales:Department {department_code: "SALES"})

CREATE (agent1)-[:MEMBER_OF {
  join_date: date("2018-03-01"),
  role: "Senior Sales Agent",
  salary_grade: "Grade 7",
  reports_to: "MGR-001",
  created_at: datetime()
}]->(dept_sales)

CREATE (agent2)-[:MEMBER_OF {
  join_date: date("2019-07-15"),
  role: "Sales Agent",
  salary_grade: "Grade 6", 
  reports_to: "MGR-002",
  created_at: datetime()
}]->(dept_sales)
```

---

## Part 3: Advanced MWR Query Patterns (15 minutes)

### Step 8: Multi-Pattern MWR Queries
```cypher
// MWR: Find agents, their branches, and customer counts
MATCH (a:Agent)-[:WORKS_AT]->(b:Branch)    // M - MATCH agent-branch pattern
MATCH (a)-[:SERVICES]->(c:Customer)        // M - MATCH agent-customer pattern  
WHERE b.city IN ["Austin", "Dallas"]       // W - WHERE filter by cities
RETURN a.first_name + " " + a.last_name AS agent_name,
       b.branch_name AS branch,
       b.city AS city,
       count(c) AS customers_served       // R - RETURN aggregated data
ORDER BY customers_served DESC
```

```cypher
// MWR: Department analysis with budget and headcount
MATCH (d:Department)                      // M - MATCH departments
WHERE d.budget > 2000000                  // W - WHERE budget filter
RETURN d.department_name AS department,
       d.budget AS annual_budget,
       d.head_count AS employees,
       (d.budget / d.head_count) AS budget_per_employee  // R - RETURN calculated metrics
ORDER BY budget_per_employee DESC
```

### Step 9: Complex Relationship Traversals
```cypher
// MWR: Find customer policies through agent relationships
MATCH (c:Customer)-[:SERVICES]-(a:Agent)-[:WORKS_AT]->(b:Branch)  // M - Multi-hop pattern
MATCH (c)-[:HOLDS_POLICY]->(p:Policy)                             // M - Additional pattern
WHERE b.city = "Austin"                                           // W - Filter by branch city
RETURN c.first_name + " " + c.last_name AS customer_name,
       a.first_name + " " + a.last_name AS agent_name,
       b.branch_name AS branch,
       collect(p.product_type) AS policy_types,              // R - Collect multiple policies
       sum(p.annual_premium) AS total_premium                // R - Sum premiums
ORDER BY total_premium DESC
```

### Step 10: Territory and Geographic Analysis
```cypher
// MWR: Branch performance analysis
MATCH (b:Branch)                          // M - MATCH branches
WHERE b.customer_count > 1000             // W - WHERE customer threshold
RETURN b.branch_name AS branch,
       b.city AS location,
       b.customer_count AS customers,
       b.employee_count AS employees,
       (b.customer_count * 1.0 / b.employee_count) AS customers_per_employee  // R - Efficiency metric
ORDER BY customers_per_employee DESC
```

### Step 11: Optional Patterns with MWR
```cypher
// MWR: Customer analysis with optional agent relationships
MATCH (c:Customer)                        // M - MATCH all customers
OPTIONAL MATCH (c)<-[:SERVICES]-(a:Agent) // M - OPTIONAL agent relationship
WHERE c.risk_tier = "Preferred"           // W - Filter by risk tier
RETURN c.first_name + " " + c.last_name AS customer_name,
       c.credit_score AS credit_score,
       c.lifetime_value AS value,
       COALESCE(a.first_name + " " + a.last_name, "No Agent Assigned") AS agent  // R - Handle optional data
ORDER BY c.lifetime_value DESC
```

---

## Part 4: Business Intelligence with MWR (5 minutes)

### Step 12: Premium Analysis by Location
```cypher
// MWR: Geographic premium distribution
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)    // M - Customer-policy pattern
WHERE p.policy_status = "Active"                  // W - Active policies only
RETURN c.city AS city,
       c.state AS state,
       count(p) AS policy_count,
       avg(p.annual_premium) AS avg_premium,
       sum(p.annual_premium) AS total_premium     // R - Geographic aggregations
ORDER BY total_premium DESC
```

### Step 13: Department Budget Analysis
```cypher
// MWR: Department efficiency metrics
MATCH (d:Department)                              // M - All departments
WHERE d.department_type = "Operations"            // W - Operations departments only
RETURN d.department_name AS department,
       d.budget AS budget,
       d.head_count AS employees,
       (d.budget / d.head_count) AS cost_per_employee,
       d.quarterly_target AS target               // R - Operational metrics
ORDER BY cost_per_employee
```

### Step 14: Cross-Department Analysis
```cypher
// MWR: Employee distribution across departments and branches
MATCH (a:Agent)-[:MEMBER_OF]->(d:Department)      // M - Agent-department
MATCH (a)-[:WORKS_AT]->(b:Branch)                 // M - Agent-branch  
WHERE d.department_type = "Revenue"               // W - Revenue departments
RETURN d.department_name AS department,
       b.branch_name AS branch,
       b.city AS city,
       count(a) AS agent_count,
       avg(a.ytd_sales) AS avg_sales              // R - Cross-dimensional analysis
ORDER BY avg_sales DESC
```

### Step 15: Visual Network Overview
```cypher
// Complete organizational network visualization
MATCH (c:Customer)-[r1:HOLDS_POLICY]->(p:Policy)
MATCH (a:Agent)-[r2:SERVICES]->(c)
MATCH (a)-[r3:WORKS_AT]->(b:Branch)
MATCH (a)-[r4:MEMBER_OF]->(d:Department)
RETURN c, r1, p, a, r2, r3, b, r4, d
```

---

## Neo4j Lab 2 Summary

**🎯 What You've Accomplished:**

### **MWR Memory Aid Mastery**
- ✅ **MATCH-WHERE-RETURN pattern** for structured query building
- ✅ **Multi-pattern queries** combining multiple MATCH clauses
- ✅ **Optional pattern matching** for handling missing relationships
- ✅ **Complex relationship traversals** across multiple entity types

### **Organizational Structure Expansion**
- ✅ **Branch:Location entities** with geographic and operational data
- ✅ **Department entities** with budget, headcount, and performance metrics
- ✅ **Employee-Branch relationships** with office and location details
- ✅ **Department membership** with roles and reporting structures

### **Node Types Added (2 types):**
- ✅ **Branch:Location** - Regional offices with territory coverage and performance metrics
- ✅ **Department** - Organizational units with budget and operational data

### **Database State:** 25 nodes, 40 relationships with organizational hierarchy

### **Advanced Query Capabilities**
- ✅ **Geographic analysis** with branch and territory performance
- ✅ **Department efficiency metrics** with budget and productivity calculations
- ✅ **Cross-dimensional analysis** combining customer, agent, branch, and department data
- ✅ **Business intelligence queries** for operational decision making

---

## Next Steps

You're now ready for **Lab 3: Claims & Financial Modeling**, where you'll:
- Add Claim, Vehicle:Asset, Property:Asset, and RepairShop:Vendor entities
- Implement complete claims processing workflows
- Build financial transaction tracking systems
- Master complex multi-entity relationship patterns
- **Database Evolution:** 25 nodes → 60 nodes, 40 relationships → 85 relationships

**Congratulations!** You've mastered the fundamental MWR query pattern and built a comprehensive organizational structure that supports sophisticated insurance operations and business intelligence analysis.

## Troubleshooting

### If queries return no results:
- Verify the entities exist: `MATCH (n) RETURN labels(n), count(n)`
- Check relationship directions and types
- Ensure WHERE conditions match actual data values

### If performance is slow:
- Add LIMIT clauses during development: `RETURN ... LIMIT 10`
- Use PROFILE to analyze query execution plans
- Check for missing indexes on frequently queried properties