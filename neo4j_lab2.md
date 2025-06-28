# Lab 2: Advanced Cypher Foundations

**Duration:** 60 minutes  
**Objective:** Master advanced Cypher operations, complex data types, and sophisticated query patterns

## Prerequisites

- Completed Lab 1 successfully
- Neo4j Desktop project with social network data from Lab 1
- Familiarity with basic Cypher syntax and Neo4j Browser interface
- Understanding of nodes, relationships, and properties

## Learning Outcomes

By the end of this lab, you will:
- Create complex node and relationship structures with multiple labels
- Master advanced WHERE clause filtering and conditional logic
- Work with multiple data types including temporal, spatial, and collections
- Implement string operations, regular expressions, and pattern matching
- Use MERGE for upsert operations and data consistency
- Handle NULL values and optional patterns effectively
- Build parameterized queries for dynamic data operations
- Optimize query performance with indexes and constraints

## Part 1: Advanced Node and Relationship Creation (15 minutes)

### Step 1: Clean Slate and Advanced Data Types
Start by expanding your existing social network with more sophisticated data:

```cypher
// Create a person with rich temporal and collection data
CREATE (emma:Person:Employee:Manager {
  name: "Emma Wilson",
  age: 34,
  email: "emma.wilson@techcorp.com",
  birthDate: date('1989-06-15'),
  joinedCompany: datetime('2021-03-01T09:00:00'),
  skills: ['Python', 'Machine Learning', 'Team Leadership', 'Data Science'],
  certifications: ['AWS Solutions Architect', 'PMP', 'Scrum Master'],
  performance_scores: [4.2, 4.5, 4.8, 4.3, 4.6],
  salary: 145000,
  location: point({latitude: 37.7749, longitude: -122.4194}),
  isRemote: false
})
```

### Step 2: Create Complex Company Structures
```cypher
// Create a more detailed company with nested information
CREATE (techCorp2:Company:TechCompany {
  name: "TechCorp Advanced Division",
  industry: "Artificial Intelligence",
  founded: date('2015-08-20'),
  headquarters: point({latitude: 37.7849, longitude: -122.4094}),
  employees: 1200,
  departments: ['Engineering', 'Data Science', 'Product', 'Sales', 'Marketing'],
  technologies: ['Python', 'Kubernetes', 'TensorFlow', 'React', 'GraphQL'],
  revenue: 250000000,
  isPublic: true,
  stockTicker: "TCAD"
})
```

### Step 3: Advanced Relationship Creation with Rich Metadata
```cypher
// Connect Emma to existing network with detailed relationships
MATCH (emma:Person {name: "Emma Wilson"}), 
      (alice:Person {name: "Alice Johnson"}),
      (techCorp:Company {name: "TechCorp"})

CREATE (emma)-[:MANAGES {
  since: date('2022-01-15'),
  teamSize: 8,
  budget: 2500000,
  responsibilities: ['Team Development', 'Technical Strategy', 'Hiring'],
  reportingStructure: 'Director'
}]->(alice),

(emma)-[:WORKS_FOR {
  position: "Senior Engineering Manager",
  department: "Data Science",
  since: datetime('2021-03-01T09:00:00'),
  salary: 145000,
  benefits: ['Health Insurance', 'Stock Options', '401k Match'],
  workLocation: 'Hybrid'
}]->(techCorp),

(emma)-[:MENTORS {
  since: date('2022-06-01'),
  frequency: 'Weekly',
  focusAreas: ['Career Development', 'Technical Skills', 'Leadership'],
  meetingType: 'One-on-One'
}]->(alice)
```

### Step 4: Create Project and Skill Networks
```cypher
// Create projects with complex metadata
CREATE (aiProject:Project {
  name: "Customer Intelligence Platform",
  projectId: "CIP-2024-001",
  startDate: date('2024-01-15'),
  expectedEndDate: date('2024-08-30'),
  budget: 1800000,
  status: "In Progress",
  technologies: ['Python', 'TensorFlow', 'Kubernetes', 'PostgreSQL'],
  phases: ['Requirements', 'Design', 'Development', 'Testing', 'Deployment'],
  currentPhase: "Development",
  riskLevel: "Medium",
  clientImportance: "High"
}),

(mobileApp:Project {
  name: "Mobile Analytics Dashboard",
  projectId: "MAD-2024-002", 
  startDate: date('2024-02-01'),
  expectedEndDate: date('2024-06-15'),
  budget: 950000,
  status: "Planning",
  technologies: ['React Native', 'Node.js', 'MongoDB', 'AWS'],
  phases: ['Discovery', 'MVP', 'Full Features', 'Launch'],
  currentPhase: "Discovery",
  riskLevel: "Low",
  clientImportance: "Medium"
})
```

### Step 5: Connect People to Projects with Roles
```cypher
// Create sophisticated work relationships
MATCH (emma:Person {name: "Emma Wilson"}), 
      (alice:Person {name: "Alice Johnson"}),
      (bob:Person {name: "Bob Smith"}),
      (aiProject:Project {name: "Customer Intelligence Platform"}),
      (mobileApp:Project {name: "Mobile Analytics Dashboard"})

CREATE (emma)-[:LEADS {
  role: "Technical Lead",
  responsibility: "Architecture and Team Management",
  allocation: 0.6,
  since: date('2024-01-15')
}]->(aiProject),

(alice)-[:WORKS_ON {
  role: "Senior Developer",
  responsibility: "ML Model Development",
  allocation: 0.8,
  since: date('2024-01-20'),
  primaryTechnologies: ['Python', 'TensorFlow', 'Pandas']
}]->(aiProject),

(bob)-[:LEADS {
  role: "Product Manager",
  responsibility: "Requirements and Stakeholder Management",
  allocation: 0.4,
  since: date('2024-02-01')
}]->(mobileApp)
```

## Part 2: Advanced WHERE Clause Operations (12 minutes)

### Step 6: Complex Filtering with Multiple Conditions
```cypher
// Find employees with specific criteria combinations
MATCH (p:Person)-[works:WORKS_FOR]->(c:Company)
WHERE p.age BETWEEN 25 AND 35 
  AND works.salary > 100000 
  AND c.industry CONTAINS "Software"
  AND p.skills IS NOT NULL
RETURN p.name AS employee, 
       p.age AS age,
       works.salary AS salary,
       p.skills AS skills,
       c.name AS company
ORDER BY works.salary DESC
```

### Step 7: String Operations and Pattern Matching
```cypher
// Advanced string filtering and manipulation
MATCH (p:Person)
WHERE p.email =~ '.*@techcorp\\.com$'  // Regex for TechCorp emails
  AND p.name STARTS WITH 'A' OR p.name ENDS WITH 'son'
  AND size(p.skills) >= 3
RETURN p.name AS name,
       p.email AS email,
       p.skills AS skills,
       size(p.skills) AS skill_count
```

### Step 8: Date and Temporal Filtering
```cypher
// Find people who joined in the last 3 years
MATCH (p:Person)-[works:WORKS_FOR]->(c:Company)
WHERE works.since > datetime() - duration('P3Y')  // Last 3 years
  AND date(works.since) > date('2021-01-01')
RETURN p.name AS employee,
       works.since AS join_date,
       duration.between(works.since, datetime()).years AS years_employed,
       c.name AS company
ORDER BY works.since DESC
```

### Step 9: Collection and Array Operations
```cypher
// Advanced collection filtering and operations
MATCH (p:Person)
WHERE ANY(skill IN p.skills WHERE skill CONTAINS 'Python')
  AND size(p.skills) > 2
  AND ALL(score IN p.performance_scores WHERE score >= 4.0)
RETURN p.name AS name,
       [skill IN p.skills WHERE skill CONTAINS 'Data' | skill] AS data_skills,
       reduce(total = 0.0, score IN p.performance_scores | total + score) / size(p.performance_scores) AS avg_performance
```

### Step 10: Spatial and Geographic Queries
```cypher
// Find people within a certain distance of headquarters
MATCH (p:Person), (c:Company {name: "TechCorp Advanced Division"})
WHERE distance(p.location, c.headquarters) < 50000  // Within 50km
RETURN p.name AS employee,
       round(distance(p.location, c.headquarters) / 1000) AS distance_km,
       p.isRemote AS remote_status
ORDER BY distance_km
```

## Part 3: MERGE Operations and Data Consistency (10 minutes)

### Step 11: Understanding MERGE for Upsert Operations
```cypher
// MERGE creates if not exists, matches if exists
MERGE (dept:Department {name: "Data Science"})
ON CREATE SET dept.created = datetime(),
              dept.budget = 5000000,
              dept.headCount = 0
ON MATCH SET dept.lastUpdated = datetime()
RETURN dept
```

### Step 12: Complex MERGE with Relationships
```cypher
// Ensure person belongs to department (create relationship if needed)
MATCH (emma:Person {name: "Emma Wilson"})
MERGE (dept:Department {name: "Data Science"})
MERGE (emma)-[membership:MEMBER_OF]->(dept)
ON CREATE SET membership.since = date('2021-03-01'),
              membership.role = "Manager"
ON MATCH SET membership.lastActive = date()
RETURN emma, membership, dept
```

### Step 13: MERGE with Multiple Properties
```cypher
// Create or update skill nodes and relationships
MATCH (p:Person)
WHERE p.skills IS NOT NULL
UNWIND p.skills AS skillName
MERGE (skill:Skill {name: skillName})
ON CREATE SET skill.category = CASE 
  WHEN skillName IN ['Python', 'Java', 'JavaScript'] THEN 'Programming'
  WHEN skillName IN ['Machine Learning', 'Data Science'] THEN 'Analytics' 
  WHEN skillName IN ['Team Leadership', 'Project Management'] THEN 'Management'
  ELSE 'Other'
END
MERGE (p)-[has:HAS_SKILL]->(skill)
ON CREATE SET has.proficiency = 'Intermediate',
              has.since = date('2020-01-01')
```

## Part 4: NULL Handling and Optional Patterns (8 minutes)

### Step 14: Working with NULL Values
```cypher
// Find people with incomplete profiles
MATCH (p:Person)
WHERE p.email IS NULL 
   OR p.birthDate IS NULL 
   OR p.skills IS NULL 
   OR size(p.skills) = 0
RETURN p.name AS person,
       CASE WHEN p.email IS NULL THEN 'Missing Email' ELSE 'Has Email' END AS email_status,
       CASE WHEN p.birthDate IS NULL THEN 'Missing Birth Date' ELSE 'Has Birth Date' END AS birthdate_status,
       CASE WHEN p.skills IS NULL OR size(p.skills) = 0 THEN 'No Skills Listed' ELSE 'Has Skills' END AS skills_status
```

### Step 15: OPTIONAL MATCH for Flexible Queries
```cypher
// Find all people and their optional project assignments
MATCH (p:Person)
OPTIONAL MATCH (p)-[works_on:WORKS_ON|LEADS]->(project:Project)
RETURN p.name AS person,
       COLLECT(DISTINCT project.name) AS projects,
       COLLECT(DISTINCT type(works_on)) AS relationship_types,
       CASE WHEN project IS NULL THEN 'No Active Projects' ELSE 'Has Projects' END AS project_status
```

### Step 16: Handling Optional Relationships with COALESCE
```cypher
// Get employee info with safe defaults for missing data
MATCH (p:Person)
OPTIONAL MATCH (p)-[works:WORKS_FOR]->(c:Company)
OPTIONAL MATCH (p)-[manages:MANAGES]->(subordinate:Person)
RETURN p.name AS employee,
       COALESCE(c.name, 'No Company') AS company,
       COALESCE(works.position, 'No Position') AS position,
       COALESCE(works.salary, 0) AS salary,
       COUNT(DISTINCT subordinate) AS direct_reports
```

## Part 5: Parameterized Queries and Dynamic Operations (8 minutes)

### Step 17: Using Parameters for Dynamic Queries
```cypher
// Set parameters for dynamic queries
:param min_salary => 100000
:param required_skills => ['Python', 'Machine Learning']
:param company_name => 'TechCorp'
```

```cypher
// Use parameters in queries
MATCH (p:Person)-[works:WORKS_FOR]->(c:Company)
WHERE works.salary >= $min_salary
  AND c.name CONTAINS $company_name
  AND ANY(skill IN $required_skills WHERE skill IN p.skills)
RETURN p.name AS candidate,
       works.salary AS salary,
       p.skills AS all_skills,
       [skill IN p.skills WHERE skill IN $required_skills] AS matching_skills
ORDER BY works.salary DESC
```

### Step 18: Dynamic Property Access
```cypher
// Dynamic property queries using bracket notation
:param property_name => 'salary'
:param min_value => 120000
```

```cypher
MATCH (p:Person)-[r:WORKS_FOR]->(c:Company)
WHERE r[$property_name] >= $min_value
RETURN p.name AS employee, 
       r[$property_name] AS property_value,
       c.name AS company
```

## Part 6: Performance Optimization with Indexes and Constraints (7 minutes)

### Step 19: Create Indexes for Query Performance
```cypher
// Create indexes on frequently queried properties
CREATE INDEX person_email_index FOR (p:Person) ON (p.email);
CREATE INDEX person_skills_index FOR (p:Person) ON (p.skills);
CREATE INDEX company_name_index FOR (c:Company) ON (c.name);
CREATE INDEX project_status_index FOR (p:Project) ON (p.status);
```

### Step 20: Create Constraints for Data Integrity
```cypher
// Create uniqueness constraints
CREATE CONSTRAINT person_email_unique FOR (p:Person) REQUIRE p.email IS UNIQUE;
CREATE CONSTRAINT company_name_unique FOR (c:Company) REQUIRE c.name IS UNIQUE;
CREATE CONSTRAINT project_id_unique FOR (p:Project) REQUIRE p.projectId IS UNIQUE;
```

### Step 21: Test Performance Impact
```cypher
// Profile a query to see performance impact
PROFILE 
MATCH (p:Person)
WHERE p.email CONTAINS '@techcorp.com'
RETURN p.name, p.email
```

```cypher
// Explain query execution plan
EXPLAIN
MATCH (p:Person)-[w:WORKS_FOR]->(c:Company)
WHERE c.name = 'TechCorp' AND w.salary > 100000
RETURN p.name, w.salary
```

## Part 7: Advanced Query Patterns and Validation (8 minutes)

### Step 22: Complex Aggregations and Statistical Analysis
```cypher
// Comprehensive department analytics
MATCH (p:Person)-[w:WORKS_FOR]->(c:Company)
OPTIONAL MATCH (p)-[:MEMBER_OF]->(d:Department)
WITH d.name AS department, 
     COLLECT(w.salary) AS salaries,
     COLLECT(p.age) AS ages,
     COUNT(p) AS employee_count
RETURN department,
       employee_count,
       round(reduce(total = 0, salary IN salaries | total + salary) * 1.0 / size(salaries)) AS avg_salary,
       min(salaries) AS min_salary,
       max(salaries) AS max_salary,
       round(reduce(total = 0, age IN ages | total + age) * 1.0 / size(ages)) AS avg_age,
       round(stDev(salaries)) AS salary_std_dev
ORDER BY avg_salary DESC
```

### Step 23: Conditional Logic and Case Statements
```cypher
// Create employee performance categories
MATCH (p:Person)
WHERE p.performance_scores IS NOT NULL
WITH p, reduce(total = 0.0, score IN p.performance_scores | total + score) / size(p.performance_scores) AS avg_score
RETURN p.name AS employee,
       round(avg_score * 100) / 100 AS average_score,
       CASE 
         WHEN avg_score >= 4.5 THEN 'Exceptional'
         WHEN avg_score >= 4.0 THEN 'Excellent' 
         WHEN avg_score >= 3.5 THEN 'Good'
         WHEN avg_score >= 3.0 THEN 'Satisfactory'
         ELSE 'Needs Improvement'
       END AS performance_category,
       size(p.performance_scores) AS review_count
ORDER BY avg_score DESC
```

### Step 24: Data Validation and Quality Checks
```cypher
// Validate data quality across the graph
MATCH (p:Person)
OPTIONAL MATCH (p)-[w:WORKS_FOR]->(c:Company)
OPTIONAL MATCH (p)-[:HAS_SKILL]->(s:Skill)
RETURN p.name AS person,
       CASE WHEN p.email IS NULL OR p.email = '' THEN 'Missing Email' ELSE 'Valid' END AS email_check,
       CASE WHEN p.age IS NULL OR p.age < 18 OR p.age > 100 THEN 'Invalid Age' ELSE 'Valid' END AS age_check,
       CASE WHEN w IS NULL THEN 'No Employment' ELSE 'Employed' END AS employment_check,
       CASE WHEN COUNT(s) = 0 THEN 'No Skills' ELSE 'Has Skills' END AS skills_check,
       COUNT(s) AS skill_count
```

## Lab Completion Checklist

- [ ] Created complex nodes with multiple labels and rich data types
- [ ] Built sophisticated relationships with detailed metadata
- [ ] Mastered advanced WHERE clause filtering and conditions
- [ ] Implemented string operations and regular expressions
- [ ] Used temporal data types and date operations effectively
- [ ] Worked with collections, arrays, and spatial data
- [ ] Applied MERGE operations for data consistency
- [ ] Handled NULL values and optional patterns properly
- [ ] Created parameterized queries for dynamic operations
- [ ] Implemented indexes and constraints for performance
- [ ] Built complex aggregations and statistical analyses
- [ ] Applied conditional logic and data validation patterns

## Key Concepts Mastered

1. **Advanced Data Modeling:** Multiple labels, rich data types, temporal data
2. **Complex Filtering:** Advanced WHERE clauses with multiple conditions
3. **String Operations:** Regular expressions and pattern matching
4. **Collection Operations:** Arrays, lists, and set operations
5. **Temporal Queries:** Date arithmetic and duration calculations
6. **Spatial Operations:** Geographic data and distance calculations
7. **MERGE Operations:** Upsert patterns and data consistency
8. **NULL Handling:** Optional patterns and safe defaults
9. **Parameterized Queries:** Dynamic and reusable query patterns
10. **Performance Optimization:** Indexes, constraints, and query profiling
11. **Statistical Analysis:** Aggregations and mathematical operations
12. **Data Validation:** Quality checks and integrity patterns

## Troubleshooting Guide

### Common Issues and Solutions

**Constraint violation errors:**
```cypher
// Check existing constraints
SHOW CONSTRAINTS
// Drop constraint if needed
DROP CONSTRAINT constraint_name
```

**Index creation failures:**
```cypher
// Check existing indexes
SHOW INDEXES
// Drop index if needed
DROP INDEX index_name
```

**Performance issues with large datasets:**
```cypher
// Use LIMIT to test queries
MATCH (n) RETURN n LIMIT 100

// Profile queries to identify bottlenecks
PROFILE MATCH (p:Person) WHERE p.age > 30 RETURN p
```

**Parameter issues:**
```cypher
// Check current parameters
:params

// Clear all parameters
:params clear
```

## Next Steps

Congratulations! You've mastered advanced Cypher fundamentals including:
- Complex data modeling with rich types and metadata
- Advanced query patterns and optimization techniques
- Data integrity through constraints and indexes
- Statistical analysis and aggregation operations

**In Lab 3**, we'll build upon these foundations to:
- Create large-scale social network models
- Implement complex recommendation algorithms
- Build multi-dimensional relationship networks
- Practice advanced graph analytics patterns

## Practice Exercises (Optional)

Try these advanced challenges:

1. **Skill Gap Analysis:** Find people who need specific skills for project requirements
2. **Performance Correlation:** Analyze correlation between skills and performance scores
3. **Career Path Mapping:** Model promotion paths and career progressions
4. **Project Optimization:** Find optimal team compositions based on skills and availability
5. **Salary Analysis:** Implement fair pay analysis across departments and roles

## Quick Reference

**Advanced Patterns:**
```cypher
// MERGE with conditions
MERGE (n:Label {key: value})
ON CREATE SET n.created = datetime()
ON MATCH SET n.updated = datetime()

// Collections and aggregations
WITH COLLECT(property) AS values
RETURN reduce(total = 0, val IN values | total + val) AS sum

// Optional patterns
OPTIONAL MATCH (n)-[r]->(m)
RETURN n, COALESCE(m.name, 'No connection') AS result

// Parameters
:param name => 'value'
MATCH (n) WHERE n.property = $name RETURN n
```

---

**🎉 Lab 2 Complete!**

You now have advanced Cypher skills for building sophisticated graph databases with complex data models, optimized performance, and robust data integrity. These skills will be essential for the complex social network analytics we'll tackle in Lab 3.