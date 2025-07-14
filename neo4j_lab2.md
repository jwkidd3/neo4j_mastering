# Lab 2: Advanced Cypher Foundations

**Duration:** 60 minutes  
**Objective:** Master advanced Cypher operations, complex data types, and sophisticated query patterns

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop 2** (connection client)
- **Docker Desktop** with Neo4j Enterprise 2025.06.0 running
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

✅ **From Previous Labs:**
- **Completed Lab 1** with "social" database created
- **Basic social network** with people and companies
- **Remote connection** set up in Desktop 2
- **Basic Cypher knowledge** and graph concepts

## Learning Outcomes

By the end of this lab, you will:
- Build upon the social network created in Lab 1
- Create complex node and relationship structures with multiple labels
- Master advanced WHERE clause filtering and conditional logic
- Work with multiple data types including temporal, spatial, and collections
- Implement string operations, regular expressions, and pattern matching
- Use MERGE for upsert operations and data consistency
- Handle NULL values and optional patterns effectively
- Build parameterized queries for dynamic data operations
- Optimize query performance with indexes and constraints

## Part 1: Environment Setup and Verification (5 minutes)

### Step 1: Connect to Social Database
Launch Neo4j Browser and ensure you're working with the social database from Lab 1:

```cypher
// Switch to social database
:use social
```

```cypher
// Verify existing data from Lab 1
MATCH (n) RETURN count(n) AS total_nodes, labels(n) AS node_types
```

```cypher
// Clear the result panel
:clear
```

**Expected Result:** Should show people and companies from Lab 1

### Step 2: Verify Enterprise Features
```cypher
// Check available procedures (APOC should be available)
SHOW PROCEDURES 
WHERE name STARTS WITH "apoc"
```

```cypher
// Check system information
:sysinfo
```

**Expected Result:** Multiple APOC procedures available and Neo4j Enterprise 2025.06.0 connected

## Part 2: Advanced Node and Relationship Creation (15 minutes)

### Step 3: Extend Existing Social Network
Build upon the people from Lab 1 with more sophisticated data:

```cypher
// Add rich data to Alice from Lab 1
MATCH (alice:Person {name: "Alice Johnson"})
SET alice:Employee:Manager,
    alice.birthDate = date('1998-03-15'),
    alice.joinedCompany = datetime('2020-09-01T09:00:00'),
    alice.skills = ['Python', 'JavaScript', 'React', 'Node.js', 'GraphQL'],
    alice.certifications = ['AWS Developer', 'React Certified'],
    alice.performance_scores = [4.2, 4.5, 4.8, 4.3, 4.6],
    alice.salary = 125000,
    alice.location = point({latitude: 37.7749, longitude: -122.4194}),
    alice.isRemote = false
RETURN alice
```

### Step 4: Create Advanced Company Structures
```cypher
// Enhance TechCorp from Lab 1
MATCH (tc:Company {name: "TechCorp"})
SET tc:TechCompany,
    tc.departments = ['Engineering', 'Product', 'Marketing', 'Sales'],
    tc.stock_price = 284.50,
    tc.revenue_2023 = 2400000000,
    tc.locations = ['San Francisco', 'New York', 'Austin', 'London'],
    tc.tech_stack = ['Neo4j', 'Python', 'React', 'Kubernetes', 'AWS']
RETURN tc
```

### Step 5: Add Departments and Projects
```cypher
// Create department nodes
CREATE (eng:Department {
  name: "Engineering",
  head: "Sarah Chen",
  budget: 15000000,
  size: 120,
  established: date('2010-01-01')
})

CREATE (product:Department {
  name: "Product",
  head: "Mike Rodriguez",
  budget: 8000000,
  size: 45,
  established: date('2012-06-01')
})
```

```cypher
// Create project nodes with rich metadata
CREATE (platform:Project {
  projectId: "PROJ-001",
  name: "Next-Gen Platform",
  status: "In Progress",
  budget: 5000000,
  startDate: date('2024-01-15'),
  expectedEnd: date('2024-12-31'),
  priority: "High",
  technologies: ['Neo4j', 'Python', 'React', 'Kubernetes'],
  team_size: 12,
  completion_percentage: 45.7
})

CREATE (mobile:Project {
  projectId: "PROJ-002", 
  name: "Mobile App Redesign",
  status: "Planning",
  budget: 2500000,
  startDate: date('2024-06-01'),
  expectedEnd: date('2025-03-31'),
  priority: "Medium",
  technologies: ['React Native', 'GraphQL', 'Firebase'],
  team_size: 8,
  completion_percentage: 12.3
})
```

### Step 6: Create Complex Relationships
```cypher
// Connect Alice to department and projects
MATCH (alice:Person {name: "Alice Johnson"}), 
      (eng:Department {name: "Engineering"}),
      (platform:Project {name: "Next-Gen Platform"})
CREATE (alice)-[:MEMBER_OF {since: date('2020-09-01'), role: "Senior Engineer"}]->(eng),
       (alice)-[:ASSIGNED_TO {role: "Tech Lead", allocation: 0.8, since: date('2024-01-15')}]->(platform)
```

```cypher
// Create skill nodes and relationships
CREATE (python:Skill {name: "Python", category: "Programming", level: "Advanced", demand: "High"}),
       (react:Skill {name: "React", category: "Frontend", level: "Advanced", demand: "High"}),
       (graphql:Skill {name: "GraphQL", category: "API", level: "Intermediate", demand: "Medium"})

// Connect Alice to skills with proficiency levels
MATCH (alice:Person {name: "Alice Johnson"}),
      (python:Skill {name: "Python"}),
      (react:Skill {name: "React"}),
      (graphql:Skill {name: "GraphQL"})
CREATE (alice)-[:HAS_SKILL {proficiency: 9, years_experience: 5, last_used: date('2024-12-01')}]->(python),
       (alice)-[:HAS_SKILL {proficiency: 8, years_experience: 3, last_used: date('2024-12-01')}]->(react),
       (alice)-[:HAS_SKILL {proficiency: 7, years_experience: 2, last_used: date('2024-11-15')}]->(graphql)
```

## Part 3: Advanced WHERE Clause and Filtering (12 minutes)

### Step 7: Complex Filtering Patterns
```cypher
// Find employees with specific skill combinations
MATCH (p:Person)-[hs:HAS_SKILL]->(s:Skill)
WHERE s.name IN ['Python', 'React'] 
  AND hs.proficiency >= 8
  AND p.salary > 100000
WITH p, COLLECT(s.name) AS skills, COUNT(s) AS skill_count
WHERE skill_count >= 2
RETURN p.name AS developer,
       p.salary AS salary,
       skills AS advanced_skills,
       skill_count AS total_advanced_skills
ORDER BY p.salary DESC
```

### Step 8: String Operations and Pattern Matching
```cypher
// Find all TechCorp email addresses with pattern matching
MATCH (p:Person)
WHERE p.email =~ '.*@techcorp\\.com$'
  AND p.name =~ 'A.*'  // Names starting with 'A'
RETURN p.name AS employee,
       p.email AS email,
       p.profession AS role
ORDER BY p.name
```

```cypher
// Advanced string operations
MATCH (p:Person)
WHERE p.email IS NOT NULL
RETURN p.name AS name,
       toUpper(left(p.name, 1)) + toLower(substring(p.name, 1)) AS formatted_name,
       split(p.email, '@')[0] AS username,
       split(p.email, '@')[1] AS domain,
       size(p.name) AS name_length,
       p.email CONTAINS 'techcorp' AS is_techcorp_employee
```

### Step 9: Temporal Data Operations
```cypher
// Advanced date calculations
MATCH (p:Person)
WHERE p.birthDate IS NOT NULL AND p.joinedCompany IS NOT NULL
WITH p, 
     duration.between(p.birthDate, date()).years AS age_calculated,
     date().year - p.birthDate.year AS simple_age,
     p.joinedCompany AS joined_company,
     duration.between(date(p.joinedCompany), date()).years AS years_at_company
WHERE years_at_company > 0
RETURN p.name AS employee,
       p.birthDate AS birth_date,
       age_calculated AS exact_age,
       simple_age AS approximate_age,
       joined_company AS join_date,
       years_at_company,
       // Calculate years until retirement (assuming age 65)
       65 - age_calculated AS years_to_retirement
ORDER BY years_at_company DESC
```

### Step 10: Working with Collections and Arrays
```cypher
// Advanced collection operations
MATCH (p:Person)
WHERE p.skills IS NOT NULL AND size(p.skills) > 0
RETURN p.name AS developer,
       p.skills AS all_skills,
       size(p.skills) AS skill_count,
       head(p.skills) AS primary_skill,
       tail(p.skills) AS other_skills,
       p.skills[0..2] AS top_3_skills,
       'Python' IN p.skills AS knows_python,
       [skill IN p.skills WHERE skill CONTAINS 'Script'] AS script_skills,
       [skill IN p.skills WHERE size(skill) > 6] AS long_skill_names
```

## Part 4: MERGE Operations and Data Consistency (10 minutes)

### Step 11: Upsert Patterns with MERGE
```cypher
// Create or update person with complex logic
MERGE (dev:Person {email: "new.developer@techcorp.com"})
ON CREATE SET 
  dev.name = "Alex Thompson",
  dev.age = 28,
  dev.created = datetime(),
  dev.status = "New Hire"
ON MATCH SET 
  dev.updated = datetime(),
  dev.status = "Existing Employee"
RETURN dev, dev.status AS operation_result
```

```cypher
// MERGE relationships with properties
MATCH (alex:Person {email: "new.developer@techcorp.com"}),
      (eng:Department {name: "Engineering"})
MERGE (alex)-[r:MEMBER_OF]->(eng)
ON CREATE SET 
  r.since = date(),
  r.role = "Junior Developer",
  r.probation_end = date() + duration({months: 6})
ON MATCH SET 
  r.updated = datetime()
RETURN alex.name AS employee, r.role AS role, r.since AS member_since
```

### Step 12: Conditional MERGE Operations
```cypher
// Create skills if they don't exist and connect to person
UNWIND ['TypeScript', 'Docker', 'Kubernetes'] AS skill_name
MERGE (skill:Skill {name: skill_name})
ON CREATE SET 
  skill.category = CASE skill_name
    WHEN 'TypeScript' THEN 'Programming'
    WHEN 'Docker' THEN 'DevOps'
    WHEN 'Kubernetes' THEN 'DevOps'
  END,
  skill.demand = 'High',
  skill.created = datetime()

WITH skill
MATCH (alex:Person {email: "new.developer@techcorp.com"})
MERGE (alex)-[hs:HAS_SKILL]->(skill)
ON CREATE SET 
  hs.proficiency = 6,
  hs.years_experience = 2,
  hs.acquired_date = date()
RETURN alex.name AS person, skill.name AS skill, hs.proficiency AS level
```

## Part 5: NULL Handling and Optional Patterns (8 minutes)

### Step 13: Safe NULL Handling
```cypher
// Handle missing data gracefully
MATCH (p:Person)
OPTIONAL MATCH (p)-[w:WORKS_FOR]->(c:Company)
OPTIONAL MATCH (p)-[:HAS_SKILL]->(s:Skill)
RETURN p.name AS employee,
       COALESCE(p.age, 'Unknown') AS age,
       COALESCE(c.name, 'Unemployed') AS company,
       CASE 
         WHEN p.salary IS NULL THEN 'Salary Not Disclosed'
         WHEN p.salary < 50000 THEN 'Entry Level'
         WHEN p.salary < 100000 THEN 'Mid Level'
         ELSE 'Senior Level'
       END AS salary_band,
       COALESCE(size(COLLECT(DISTINCT s.name)), 0) AS skill_count
```

### Step 14: Optional Pattern Matching
```cypher
// Find people and their optional project assignments
MATCH (p:Person)
OPTIONAL MATCH (p)-[a:ASSIGNED_TO]->(proj:Project)
OPTIONAL MATCH (p)-[:MEMBER_OF]->(dept:Department)
RETURN p.name AS employee,
       COALESCE(dept.name, 'No Department') AS department,
       COLLECT(DISTINCT proj.name) AS projects,
       size(COLLECT(DISTINCT proj.name)) AS project_count,
       COALESCE(sum(a.allocation), 0) AS total_allocation
ORDER BY total_allocation DESC
```

## Part 6: Performance Optimization (10 minutes)

### Step 15: Create Indexes for Frequently Queried Properties
```cypher
// Create indexes for performance
CREATE INDEX person_email_index FOR (p:Person) ON (p.email);
CREATE INDEX person_skills_index FOR (p:Person) ON (p.skills);
CREATE INDEX company_name_index FOR (c:Company) ON (c.name);
CREATE INDEX project_status_index FOR (p:Project) ON (p.status);
CREATE INDEX skill_name_index FOR (s:Skill) ON (s.name);
```

### Step 16: Create Constraints for Data Integrity
```cypher
// Drop existing indexes before creating constraints
DROP INDEX person_email_index;
DROP INDEX company_name_index;
DROP INDEX skill_name_index;
```

```cypher
// Create uniqueness constraints (these will automatically create indexes)
CREATE CONSTRAINT person_email_unique FOR (p:Person) REQUIRE p.email IS UNIQUE;
CREATE CONSTRAINT company_name_unique FOR (c:Company) REQUIRE c.name IS UNIQUE;
CREATE CONSTRAINT project_id_unique FOR (p:Project) REQUIRE p.projectId IS UNIQUE;
CREATE CONSTRAINT skill_name_unique FOR (s:Skill) REQUIRE s.name IS UNIQUE;
```

### Step 17: Test Performance Impact
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

## Part 7: Advanced Query Patterns and Validation (10 minutes)

### Step 18: Complex Aggregations and Statistical Analysis
```cypher
// Company analytics based on actual data from Lab 1
MATCH (p:Person)-[w:WORKS_FOR]->(c:Company)
WITH c.name AS company, 
     COLLECT(p.age) AS ages,
     COLLECT(p.city) AS cities,
     COUNT(p) AS employee_count
WHERE employee_count > 0
RETURN company,
       employee_count,
       CASE WHEN size(ages) > 0 AND ALL(age IN ages WHERE age IS NOT NULL)
            THEN round(reduce(total = 0, age IN ages | total + age) * 1.0 / size(ages))
            ELSE NULL END AS avg_age,
       apoc.coll.min(ages) AS min_age,
       apoc.coll.max(ages) AS max_age,
       size(apoc.coll.toSet(cities)) AS cities_represented,
       apoc.coll.toSet(cities) AS employee_cities
ORDER BY employee_count DESC
```

### Step 19: Conditional Logic and Case Statements
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

### Step 20: Data Validation and Quality Checks
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

## Part 8: Parameterized Queries (5 minutes)

### Step 21: Dynamic Query Parameters
```cypher
// Set parameters for reusable queries (correct Neo4j 2025.06.0 syntax)
:param {skill_name: 'Python', min_proficiency: 8, min_salary: 100000}
```

```cypher
// Use parameters in queries
MATCH (p:Person)-[hs:HAS_SKILL]->(s:Skill {name: $skill_name})
WHERE hs.proficiency >= $min_proficiency 
  AND p.salary >= $min_salary
RETURN p.name AS expert,
       p.salary AS salary,
       hs.proficiency AS skill_level,
       hs.years_experience AS experience
ORDER BY hs.proficiency DESC, p.salary DESC
```

**Alternative method if skill data doesn't exist yet:**
```cypher
// Simple parameter example with existing data
:param {min_age: 25, city_filter: 'San Francisco'}
```

```cypher
// Query using parameters with Lab 1 data
MATCH (p:Person)
WHERE p.age >= $min_age AND p.city = $city_filter
RETURN p.name AS person, p.age AS age, p.city AS city, p.profession AS job
```

```cypher
// Clear parameters
:params clear
```

## Lab Completion Checklist

- [ ] Successfully connected to "social" database from Lab 1
- [ ] Extended existing social network with advanced data types
- [ ] Created complex nodes with multiple labels and rich metadata
- [ ] Built sophisticated relationships with detailed properties
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

## Troubleshooting Common Issues

### If Docker Neo4j isn't running:
```bash
# Check container status
docker ps -a | grep neo4j

# Start the neo4j container
docker start neo4j
```

### If wrong database:
```cypher
// Switch to social database
:use social
```

### If connection fails:
- **Verify container:** `docker ps | grep neo4j`
- **Check connection:** bolt://localhost:7687
- **Confirm credentials:** neo4j/password

### Constraint violation errors:
```cypher
// Check existing constraints
SHOW CONSTRAINTS
// Drop constraint if needed (replace constraint_name with actual name)
// DROP CONSTRAINT constraint_name
```

### Index creation failures:
```cypher
// Check existing indexes
SHOW INDEXES
// Drop index if needed (replace index_name with actual name)
// DROP INDEX index_name
```

### Performance issues:
```cypher
// Use LIMIT to test queries
MATCH (n) RETURN n LIMIT 100

// Profile queries to identify bottlenecks
PROFILE MATCH (p:Person) WHERE p.age > 30 RETURN p
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

You now have advanced Cypher skills for building sophisticated graph databases with complex data models, optimized performance, and robust data integrity. These skills will be essential for the complex social network analytics we'll tackle in Lab 3!