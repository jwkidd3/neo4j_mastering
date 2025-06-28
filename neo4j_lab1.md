# Lab 1: Neo4j Setup and First Steps with Cypher

**Duration:** 45 minutes  
**Objective:** Master Neo4j ecosystem tools and create your first graph with Cypher fundamentals

## Prerequisites

- Docker, Python, Jupyter Lab, and Neo4j Desktop are pre-installed
- Web browser (Chrome or Firefox recommended)
- Basic understanding of databases and query concepts

## Learning Outcomes

By the end of this lab, you will:
- Navigate Neo4j Desktop for project management
- Launch and configure Neo4j databases
- Master Neo4j Browser interface for Cypher development
- Explore Neo4j Bloom for visual graph discovery
- Understand Cypher's ASCII art syntax
- Create nodes and relationships with properties
- Write pattern-matching queries
- Build your first social network graph
- Visualize graph data across multiple Neo4j tools

## Part 1: Neo4j Desktop Project Setup (8 minutes)

### Step 1: Launch Neo4j Desktop
1. **Open Neo4j Desktop** from your applications/dock
2. **Wait for startup** - Desktop should show the main interface
3. **Check status** - Ensure all services show green indicators

**Expected Result:** Neo4j Desktop main interface with project management panel

### Step 2: Create Your First Project
1. **Click "New Project"** button (or use existing project if available)
2. **Name your project:** "Neo4j Course - Social Network"
3. **Add description:** "Learning graph databases with social network modeling"
4. **Create project** - You should see a new project tile

### Step 3: Create and Configure Database
1. **Within your project, click "Add Database"**
2. **Choose "Local DBMS"**
3. **Configure database:**
   - **Name:** social-network-db
   - **Password:** coursepassword
   - **Version:** Latest available (likely 5.x)
4. **Click "Create"**
5. **Wait for database creation** (30-60 seconds)

### Step 4: Install Essential Plugins
1. **Select your database** in the project
2. **Click "Plugins" tab**
3. **Install APOC:** Click "Install" next to APOC Core
4. **Install GDS:** Click "Install" next to Graph Data Science Library
5. **Wait for installation** to complete

**Verification:** Database shows "Stopped" status with green indicators for plugins

## Part 2: Neo4j Browser Exploration (10 minutes)

### Step 5: Start Database and Launch Browser
1. **Click "Start" button** on your database
2. **Wait for startup** (shows "Running" status)
3. **Click "Open" button** to launch Neo4j Browser
4. **Alternative:** Navigate directly to http://localhost:7474

### Step 6: Connect to Database
1. **Connection URL:** bolt://localhost:7687 (should be pre-filled)
2. **Username:** neo4j
3. **Password:** coursepassword (what you set in Step 3)
4. **Click "Connect"**

**Expected Result:** Neo4j Browser interface with query editor at top

### Step 7: Browser Interface Tour
Explore the main interface components:

```cypher
// Run this command to get help
:help
```

```cypher
// Check your database status
:sysinfo
```

```cypher
// See available procedures (should include APOC)
CALL dbms.procedures() YIELD name 
WHERE name STARTS WITH "apoc" 
RETURN count(name) AS apoc_procedures
```

**Expected Output:** Should show multiple APOC procedures available

### Step 8: Understanding the Browser Layout
- **Query Editor:** Top section where you type Cypher
- **Result Panel:** Shows query results, graphs, and tables
- **Left Sidebar:** Database information and guides
- **Right Sidebar:** Query history and favorites

## Part 3: Cypher ASCII Art and First Nodes (12 minutes)

### Step 9: Learn Cypher Visual Syntax
Cypher uses ASCII art to represent graph patterns. Practice reading these patterns:

```cypher
// Node patterns (read these out loud)
()                    // "any node"
(n)                   // "node with variable n"
(p:Person)            // "person node with variable p"
(p:Person {name: "Alice"})  // "person Alice"
```

```cypher
// Relationship patterns
-->                   // "directed relationship"
-[:KNOWS]->          // "knows relationship"
-[r:KNOWS {since: 2020}]->  // "knows relationship with property"
```

### Step 10: Create Your First People
Let's build a social network step by step:

```cypher
// Create your first person
CREATE (alice:Person {
  name: "Alice Johnson", 
  age: 25, 
  city: "San Francisco",
  profession: "Software Engineer"
})
RETURN alice
```

**Click the node** in the visualization to see its properties.

```cypher
// Create more people with different properties
CREATE (bob:Person {
  name: "Bob Smith", 
  age: 30, 
  city: "New York",
  profession: "Product Manager"
})
```

```cypher
CREATE (carol:Person {
  name: "Carol Davis", 
  age: 28, 
  city: "London",
  profession: "Data Scientist"
})
```

```cypher
CREATE (david:Person {
  name: "David Lee", 
  age: 32, 
  city: "Tokyo",
  profession: "UX Designer"
})
```

### Step 11: View Your Created Nodes
```cypher
// See all people you've created
MATCH (p:Person) 
RETURN p
```

**Exploration:** 
- Drag the nodes around to rearrange
- Click on different nodes to see their properties
- Notice how Neo4j automatically colors nodes by label

### Step 12: Customize Visualization
1. **Click on "Person" label** in the result panel (bottom left)
2. **Choose a color** for Person nodes
3. **Set caption** to show "name" property instead of ID
4. **Set size** based on "age" property (optional)

## Part 4: Creating Relationships and Patterns (10 minutes)

### Step 13: Connect People with Relationships
```cypher
// Alice knows Bob (they're college friends)
MATCH (alice:Person {name: "Alice Johnson"}), (bob:Person {name: "Bob Smith"})
CREATE (alice)-[:KNOWS {
  since: 2018, 
  relationship: "college friends",
  strength: "close"
}]->(bob)
```

```cypher
// Bob knows Carol (work colleagues, mutual)
MATCH (bob:Person {name: "Bob Smith"}), (carol:Person {name: "Carol Davis"})
CREATE (bob)-[:KNOWS {since: 2021, relationship: "work colleagues"}]->(carol),
       (carol)-[:KNOWS {since: 2021, relationship: "work colleagues"}]->(bob)
```

```cypher
// Carol knows David (university friends)
MATCH (carol:Person {name: "Carol Davis"}), (david:Person {name: "David Lee"})
CREATE (carol)-[:KNOWS {since: 2019, relationship: "university friends"}]->(david)
```

### Step 14: Add Companies and Work Relationships
```cypher
// Create companies
CREATE (techCorp:Company {
  name: "TechCorp", 
  industry: "Software", 
  employees: 500,
  founded: 2010
})
```

```cypher
CREATE (designStudio:Company {
  name: "Design Studio", 
  industry: "Creative", 
  employees: 50,
  founded: 2015
})
```

### Step 15: Connect People to Companies
```cypher
// Alice works for TechCorp
MATCH (alice:Person {name: "Alice Johnson"}), (techCorp:Company {name: "TechCorp"})
CREATE (alice)-[:WORKS_FOR {
  position: "Software Engineer",
  since: 2022,
  salary: 120000
}]->(techCorp)
```

```cypher
// Bob also works for TechCorp
MATCH (bob:Person {name: "Bob Smith"}), (techCorp:Company {name: "TechCorp"})
CREATE (bob)-[:WORKS_FOR {
  position: "Product Manager",
  since: 2021,
  salary: 130000
}]->(techCorp)
```

```cypher
// David works for Design Studio
MATCH (david:Person {name: "David Lee"}), (designStudio:Company {name: "Design Studio"})
CREATE (david)-[:WORKS_FOR {
  position: "UX Designer",
  since: 2020,
  salary: 95000
}]->(designStudio)
```

### Step 16: View Your Complete Network
```cypher
// See everything you've created
MATCH (n) 
RETURN n
```

**Network Exploration:**
- Can you identify the clusters in your network?
- Which people work for the same company?
- How are people connected through relationships?

## Part 5: Pattern Matching and Queries (12 minutes)

### Step 17: Basic Pattern Matching
```cypher
// Find all friendships
MATCH (p1:Person)-[knows:KNOWS]->(p2:Person) 
RETURN p1.name AS person1, 
       p2.name AS person2, 
       knows.relationship AS relationship_type,
       knows.since AS friends_since
ORDER BY knows.since
```

```cypher
// Find people who work for the same company
MATCH (p1:Person)-[:WORKS_FOR]->(company:Company)<-[:WORKS_FOR]-(p2:Person)
WHERE p1 <> p2  // Exclude self-matches
RETURN p1.name AS employee1, 
       p2.name AS employee2, 
       company.name AS company
```

```cypher
// Find colleagues who are also friends
MATCH (p1:Person)-[:KNOWS]->(p2:Person),
      (p1)-[:WORKS_FOR]->(company:Company)<-[:WORKS_FOR]-(p2)
RETURN p1.name AS person1, 
       p2.name AS person2, 
       company.name AS workplace
```

### Step 18: Filtering with WHERE Clauses
```cypher
// Find people older than 27
MATCH (p:Person) 
WHERE p.age > 27 
RETURN p.name AS name, p.age AS age, p.city AS city
ORDER BY p.age DESC
```

```cypher
// Find people in tech companies
MATCH (p:Person)-[:WORKS_FOR]->(c:Company) 
WHERE c.industry = "Software" 
RETURN p.name AS employee, 
       p.profession AS role, 
       c.name AS company
```

```cypher
// Find long-term friendships (before 2020)
MATCH (p1:Person)-[k:KNOWS]->(p2:Person) 
WHERE k.since < 2020 
RETURN p1.name AS person1, 
       p2.name AS person2, 
       k.since AS friendship_started
```

### Step 19: Aggregation and Counting
```cypher
// Count people by city
MATCH (p:Person) 
RETURN p.city AS city, count(p) AS people_count
ORDER BY people_count DESC
```

```cypher
// Count connections per person
MATCH (p:Person) 
OPTIONAL MATCH (p)-[r:KNOWS]-() 
RETURN p.name AS person, 
       count(r) AS total_connections
ORDER BY total_connections DESC
```

```cypher
// Average age by profession
MATCH (p:Person) 
RETURN p.profession AS profession, 
       avg(p.age) AS average_age,
       count(p) AS count
ORDER BY average_age DESC
```

### Step 20: Advanced Pattern Discovery
```cypher
// Find friends of friends (2-hop relationships)
MATCH (alice:Person {name: "Alice Johnson"})-[:KNOWS]->()-[:KNOWS]->(fof:Person)
WHERE fof <> alice  // Exclude Alice herself
RETURN DISTINCT fof.name AS friend_of_friend, fof.profession
```

```cypher
// Find the shortest path between any two people
MATCH path = shortestPath((alice:Person {name: "Alice Johnson"})-[:KNOWS*]-(david:Person {name: "David Lee"}))
RETURN path
```

## Part 6: Neo4j Bloom Visual Exploration (8 minutes)

### Step 21: Launch Neo4j Bloom
1. **Return to Neo4j Desktop**
2. **In your project, click "Open" dropdown** next to your database
3. **Select "Neo4j Bloom"**
4. **Wait for Bloom to load** (may take 30-60 seconds)

### Step 22: Bloom Natural Language Search
1. **In the search bar, try these searches:**
   - Type: `Person` (shows all people)
   - Type: `Alice` (finds Alice Johnson)
   - Type: `TechCorp` (finds the company)
   - Type: `Software Engineer` (finds people by profession)

### Step 23: Interactive Exploration
1. **Click on Alice's node** in Bloom
2. **Click "Expand"** to see her connections
3. **Try expanding other nodes** to explore the network
4. **Double-click nodes** to see detailed properties

### Step 24: Create a Bloom Perspective
1. **Click "Create Perspective"** in Bloom
2. **Name it:** "Social Network View"
3. **Configure node appearance:**
   - Person nodes: Color by city
   - Company nodes: Different color/shape
4. **Save the perspective**

**Bloom Benefits:** Notice how non-technical users can explore the graph without writing Cypher!

## Part 7: Connecting to Python/Jupyter (5 minutes)

### Step 25: Launch Jupyter Lab
Open a terminal and run:
```bash
jupyter lab
```

### Step 26: Create Test Notebook
1. **Create new Python notebook**
2. **Name it:** "neo4j_connection_test.ipynb"

### Step 27: Test Neo4j Python Connection
In your notebook, run:

```python
# Test Neo4j connection from Python
from neo4j import GraphDatabase
import pandas as pd

# Connect to your database
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "coursepassword"))

# Test query
with driver.session() as session:
    result = session.run("MATCH (p:Person) RETURN p.name AS name, p.age AS age")
    df = pd.DataFrame([record.data() for record in result])
    print("People in our graph:")
    print(df)

driver.close()
```

**Expected Output:** DataFrame showing the people you created

## Lab Completion Checklist

- [ ] Successfully created Neo4j Desktop project
- [ ] Configured and started database with APOC/GDS plugins
- [ ] Connected to Neo4j Browser and explored interface
- [ ] Created Person and Company nodes with properties
- [ ] Built KNOWS and WORKS_FOR relationships
- [ ] Wrote pattern-matching queries with WHERE filtering
- [ ] Performed aggregations and statistical queries
- [ ] Explored 2-hop relationships (friends of friends)
- [ ] Used Neo4j Bloom for visual exploration
- [ ] Connected to Neo4j from Python/Jupyter
- [ ] Customized visualizations in both Browser and Bloom

## Key Concepts Mastered

1. **Neo4j Ecosystem Navigation:** Desktop, Browser, Bloom workflow
2. **Cypher ASCII Art:** Reading and writing visual graph patterns
3. **Node Creation:** Labels, properties, and data types
4. **Relationship Modeling:** Directed connections with metadata
5. **Pattern Matching:** MATCH clauses for finding graph structures
6. **Data Filtering:** WHERE conditions and property comparisons
7. **Aggregation:** Counting, averaging, and statistical analysis
8. **Multi-Tool Proficiency:** Technical (Browser) and business (Bloom) interfaces
9. **Python Integration:** Connecting external applications to Neo4j

## Troubleshooting Guide

### Common Issues and Solutions

**Neo4j Desktop won't start:**
```bash
# Check if any Neo4j processes are running
ps aux | grep neo4j
# Kill if necessary and restart Desktop
```

**Database won't start:**
- Check the logs in Neo4j Desktop
- Ensure no port conflicts (7474, 7687)
- Try stopping and starting again

**Browser connection fails:**
- Verify database is running (green status in Desktop)
- Check connection URL: bolt://localhost:7687
- Confirm username/password: neo4j/coursepassword

**Bloom won't load:**
- Ensure database is running
- Try refreshing the browser
- Check if Bloom plugin is properly installed

**Python connection issues:**
```python
# Test basic connectivity
from neo4j import GraphDatabase
try:
    driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "coursepassword"))
    driver.verify_connectivity()
    print("✅ Connection successful!")
except Exception as e:
    print(f"❌ Connection failed: {e}")
finally:
    driver.close()
```

## Next Steps

Congratulations! You've successfully:
- Set up a complete Neo4j development environment
- Created your first graph database with real relationships
- Learned Cypher fundamentals for querying graph data
- Explored multiple tools in the Neo4j ecosystem
- Connected Python to your graph database

**In Lab 2**, we'll dive deeper into:
- Advanced Cypher patterns and operations
- Complex data types and constraints
- Query optimization techniques
- More sophisticated graph modeling

## Practice Exercises (Optional)

If you finish early, try these challenges:

1. **Add Hobbies:** Create Hobby nodes and connect people to their interests
2. **Add Cities:** Create Location nodes and connect people with LIVES_IN relationships
3. **Friend Recommendations:** Write a query to suggest new friends based on mutual connections
4. **Company Analysis:** Find the most connected person in each company
5. **Social Influence:** Identify who has the most connections in the network

## Quick Reference

**Essential Cypher Patterns:**
```cypher
// Create nodes
CREATE (n:Label {property: value})

// Find nodes
MATCH (n:Label) WHERE n.property = value RETURN n

// Create relationships
MATCH (a), (b) WHERE ... CREATE (a)-[:TYPE]->(b)

// Find patterns
MATCH (a)-[:TYPE]->(b) RETURN a, b

// Count and aggregate
MATCH (n) RETURN count(n), avg(n.property)
```

**Neo4j Desktop Workflow:**
1. Create Project → Create Database → Install Plugins → Start Database
2. Open Browser for Cypher development
3. Open Bloom for visual exploration
4. Connect Python for application development

---

**🎉 Lab 1 Complete!**

You now have hands-on experience with the complete Neo4j ecosystem and understand how to create, query, and visualize graph data using multiple tools. This foundation will serve you well as we explore advanced graph analytics in the upcoming labs.