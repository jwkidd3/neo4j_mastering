# Lab 1: Neo4j Remote Connection Setup and First Cypher Steps

**Duration:** 45 minutes  
**Objective:** Connect to Neo4j Docker instance via Desktop 2 remote connection and create your first graph

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop 2** (connection client)
- **Docker Desktop** with Neo4j instance running
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

## Learning Outcomes

By the end of this lab, you will:
- Set up remote connection to Neo4j Docker instance via Desktop 2
- Connect to Neo4j Browser through remote connection
- Master Neo4j Browser interface for Cypher development
- Create and switch to a dedicated database
- Understand Cypher's ASCII art syntax
- Create nodes and relationships with properties
- Write pattern-matching queries
- Build your first social network graph
- Connect to Neo4j from Python/Jupyter

## Part 1: Docker and Desktop 2 Connection Setup (10 minutes)

### Step 1: Verify Neo4j Docker Instance
Open terminal/command prompt and verify Neo4j is running:
```bash
docker ps | grep neo4j
```
**Expected Result:** Should show a running Neo4j container

If no container is running, start it (using Neo4j Enterprise for this course):
```bash
# Stop any existing Neo4j container
docker stop neo4j 2>/dev/null
docker rm neo4j 2>/dev/null

# Start Neo4j Enterprise 2025.06.0 with APOC and GDS
docker run --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  -e NEO4J_PLUGINS='["apoc","graph-data-science"]' \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -d \
  neo4j:enterprise
```

**Note:** This course uses Neo4j Enterprise Edition 2025.06.0 which provides advanced features. Bloom requires a separate license file not included in educational environments.

### Step 2: Launch Neo4j Desktop 2
1. **Find Neo4j Desktop** on your system:
   - **Windows**: Start Menu → Neo4j Desktop
   - **Mac**: Applications folder → Neo4j Desktop
   - **Linux**: Applications menu → Neo4j Desktop
2. **Launch the application**
3. **Wait for startup** - You should see the Neo4j Desktop 2 interface

**Expected Result:** Neo4j Desktop 2 connection interface (no local databases)

### Step 3: Create Remote Connection in Desktop 2
1. **Look for "Connect" or "Add Connection" option** in Desktop 2
2. **Choose "Remote Connection" or "Connect to Server"**
3. **Configure connection details:**
   - **Connection URL:** bolt://localhost:7687
   - **Username:** neo4j  
   - **Password:** password
   - **Name:** Docker Neo4j (optional, referring to the "neo4j" container)
4. **Test Connection** - should show successful connection
5. **Save the connection**

**Expected Result:** Successful remote connection to Docker Neo4j container

### Step 4: Access Neo4j Browser via Desktop 2
1. **Select your remote connection** in Desktop 2
2. **Click "Open Browser" or similar option**
3. **Neo4j Browser should launch** in your web browser

**Alternative - Direct Browser Access:**
1. **Open web browser** manually  
2. **Navigate to:** http://localhost:7474
3. **Connection should work** since Docker instance is running

### Step 5: Connect in Neo4j Browser
1. **Connection URL:** bolt://localhost:7687 (should be pre-filled)
2. **Username:** neo4j
3. **Password:** password
4. **Click "Connect"**

**Expected Result:** Neo4j Browser interface with empty database

## Part 2: Environment Verification and First Setup (7 minutes)

### Step 6: Verify Connection and Empty Database
Run these verification queries in Neo4j Browser:

```cypher
// Check connection and system info
:sysinfo
```

```cypher
// Verify we have an empty database
MATCH (n) RETURN count(n) AS total_nodes
```

```cypher
// Check available procedures (APOC should be available)
SHOW PROCEDURES 
WHERE name STARTS WITH "apoc"
```

**Expected Output:** 
- System information showing Neo4j Enterprise 2025.06.0 connected
- 0 total nodes (empty database)
- Multiple APOC procedures listed

### Step 7: Explore Browser Interface Components
- **Query Editor:** Top section where you type Cypher
- **Result Panel:** Shows query results, graphs, and tables  
- **Left Sidebar:** Database information (should show empty database)
- **Right Sidebar:** Query history and favorites

Try these browser commands:
```cypher
:clear    // Clear results
:sysinfo  // System information
```

**To explore database schema (using standard Cypher):**
```cypher
// Check what's in the database (should be empty initially)
MATCH (n) RETURN n LIMIT 10

// This will show nothing since database is empty
// We'll use this command later after creating nodes
```

**Browser Help:** Look for help icons (?) in the Browser interface or explore the sidebar panels for guides and documentation.

### Step 8: Verify Enterprise Features
Let's confirm we have access to Enterprise capabilities:

```cypher
// Check Neo4j version and edition (should show Enterprise 2025.06.0)
CALL dbms.components() YIELD name, versions, edition
RETURN name, versions, edition
```

```cypher
// Check Enterprise-specific features available
SHOW PROCEDURES 
WHERE name CONTAINS "gds" OR name CONTAINS "apoc"
```

**Expected Result:** Should show Enterprise edition and many procedures available

## Part 3: Building Your First Graph from Scratch (18 minutes)

### Step 9: Create and Switch to Social Database
Before building our social network, let's create a dedicated database:

```cypher
// Create a new database called 'social'
CREATE DATABASE social
```

```cypher
// Switch to the social database
:use social
```

**Expected Result:** You should see confirmation that you're now using the "social" database.

### Step 10: Learn Cypher Visual Syntax
Now that we're in our dedicated social database, let's learn Cypher's ASCII art patterns:

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

### Step 11: Create Your First Social Network
Starting with our dedicated social database, let's build a complete social network:

```cypher
// Create your first person
CREATE (alice:Person {
  name: "Alice Johnson", 
  age: 25, 
  city: "San Francisco",
  profession: "Software Engineer",
  email: "alice@techcorp.com"
})
RETURN alice
```

**Explore:** Click the node in the visualization to see its properties.

```cypher
// Create more people with diverse backgrounds
CREATE (bob:Person {
  name: "Bob Smith", 
  age: 30, 
  city: "New York",
  profession: "Product Manager",
  email: "bob@techcorp.com"
})
```

```cypher
CREATE (carol:Person {
  name: "Carol Davis", 
  age: 28, 
  city: "London",
  profession: "Data Scientist",
  email: "carol@research.co.uk"
})
```

```cypher
CREATE (david:Person {
  name: "David Lee", 
  age: 32, 
  city: "Tokyo",
  profession: "UX Designer",
  email: "david@design.jp"
})
```

```cypher
CREATE (emma:Person {
  name: "Emma Wilson", 
  age: 27, 
  city: "Berlin",
  profession: "DevOps Engineer",
  email: "emma@cloudtech.de"
})
```

### Step 12: Create Companies and Organizations
```cypher
// Create tech companies
CREATE (techcorp:Company {
  name: "TechCorp", 
  industry: "Technology", 
  founded: 2010, 
  employees: 500,
  headquarters: "San Francisco",
  website: "www.techcorp.com"
})
```

```cypher
CREATE (startupx:Company {
  name: "StartupX", 
  industry: "AI/ML", 
  founded: 2018, 
  employees: 25,
  headquarters: "London",
  website: "www.startupx.ai"
})
```

### Step 13: Check Your Progress
```cypher
// See all nodes you've created so far
MATCH (n) RETURN n
```

**Expected Result:** 5 Person nodes and 2 Company nodes displayed in a graph visualization

### Step 14: Create Professional Relationships
```cypher
// Alice and Bob work at TechCorp
MATCH (alice:Person {name: "Alice Johnson"}), (techcorp:Company {name: "TechCorp"})
CREATE (alice)-[:WORKS_FOR {
  since: 2020, 
  role: "Senior Software Engineer", 
  department: "Platform Engineering",
  salary_range: "120k-150k"
}]->(techcorp)
```

```cypher
MATCH (bob:Person {name: "Bob Smith"}), (techcorp:Company {name: "TechCorp"})
CREATE (bob)-[:WORKS_FOR {
  since: 2019, 
  role: "Product Manager", 
  department: "Core Products",
  salary_range: "130k-160k"
}]->(techcorp)
```

```cypher
// Carol works at StartupX
MATCH (carol:Person {name: "Carol Davis"}), (startupx:Company {name: "StartupX"})
CREATE (carol)-[:WORKS_FOR {
  since: 2021, 
  role: "Lead Data Scientist", 
  department: "Research",
  salary_range: "100k-140k"
}]->(startupx)
```

### Step 15: Create Personal Relationships
```cypher
// Alice knows Bob (colleagues at TechCorp)
MATCH (alice:Person {name: "Alice Johnson"}), (bob:Person {name: "Bob Smith"})
CREATE (alice)-[:KNOWS {
  since: 2020, 
  relationship: "colleague", 
  context: "work",
  strength: 8
}]->(bob)
```

```cypher
// Bob knows Carol (university friends)
MATCH (bob:Person {name: "Bob Smith"}), (carol:Person {name: "Carol Davis"})
CREATE (bob)-[:KNOWS {
  since: 2015, 
  relationship: "friend", 
  context: "university",
  strength: 9
}]->(carol)
```

```cypher
// Alice knows David (met at tech conference)
MATCH (alice:Person {name: "Alice Johnson"}), (david:Person {name: "David Lee"})
CREATE (alice)-[:KNOWS {
  since: 2022, 
  relationship: "professional contact", 
  context: "tech conference",
  strength: 6
}]->(david)
```

```cypher
// Emma knows Carol (online tech community)
MATCH (emma:Person {name: "Emma Wilson"}), (carol:Person {name: "Carol Davis"})
CREATE (emma)-[:KNOWS {
  since: 2021, 
  relationship: "online friend", 
  context: "tech community",
  strength: 7
}]->(carol)
```

### Step 16: View Your Complete Network
```cypher
// See the complete social network with relationships
MATCH (n)-[r]-(m) RETURN n, r, m
```

**Expected Result:** Complete graph showing people, companies, and all relationships

## Part 4: Querying Your Social Network (7 minutes)

### Step 17: Basic Pattern Matching
```cypher
// Find all people who work for TechCorp
MATCH (p:Person)-[:WORKS_FOR]->(c:Company {name: "TechCorp"})
RETURN p.name AS employee, p.profession AS role, p.city AS location
```

```cypher
// Find all of Alice's connections
MATCH (alice:Person {name: "Alice Johnson"})-[:KNOWS]-(friend)
RETURN alice.name AS person, friend.name AS connection, friend.city AS friend_city
```

```cypher
// Find people in engineering roles
MATCH (p:Person)
WHERE p.profession CONTAINS "Engineer" 
RETURN p.name AS name, p.profession AS job, p.city AS location
```

### Step 18: Advanced Relationship Queries
```cypher
// Find colleagues (people who work at the same company)
MATCH (p1:Person)-[:WORKS_FOR]->(c:Company)<-[:WORKS_FOR]-(p2:Person)
WHERE p1 <> p2
RETURN p1.name AS person1, p2.name AS person2, c.name AS company
```

```cypher
// Find friends of friends (potential new connections)
MATCH (start:Person {name: "Alice Johnson"})-[:KNOWS*2]-(friend_of_friend)
WHERE start <> friend_of_friend
RETURN DISTINCT friend_of_friend.name AS potential_connection, 
       friend_of_friend.profession AS their_job
```

```cypher
// Find strongest relationships
MATCH (p1:Person)-[k:KNOWS]-(p2:Person)
WHERE k.strength >= 8
RETURN p1.name AS person1, p2.name AS person2, k.strength AS strength, k.context AS context
ORDER BY k.strength DESC
```

### Step 19: Business Intelligence Queries
```cypher
// Count people by city (geographic distribution)
MATCH (p:Person)
RETURN p.city AS city, count(p) AS people_count
ORDER BY people_count DESC
```

```cypher
// Average age by profession
MATCH (p:Person)
RETURN p.profession AS job, avg(p.age) AS average_age, count(p) AS count
ORDER BY average_age DESC
```

```cypher
// Company analysis - employees and locations
MATCH (c:Company)<-[:WORKS_FOR]-(p:Person)
RETURN c.name AS company, 
       count(p) AS employee_count,
       collect(DISTINCT p.city) AS employee_cities,
       collect(p.profession) AS roles
```

## Part 5: Neo4j Browser Advanced Visualization (3 minutes)

### Step 20: Neo4j Enterprise Features Available
**Important Note:** This course uses Neo4j Enterprise Edition 2025.06.0, which provides advanced features beyond Community Edition.

**Enterprise Features Available:**
- **Advanced Security:** Role-based access control
- **Performance Monitoring:** Enhanced metrics and monitoring
- **Graph Data Science:** Advanced algorithms and machine learning
- **APOC Procedures:** Extended library of graph operations
- **High Availability:** Clustering capabilities (not used in this course)

**Bloom Status:** While Enterprise edition includes Bloom capabilities, it requires a separate license file for full activation.

### Step 21: Enterprise-Enhanced Browser Visualization
Let's explore Neo4j Browser with Enterprise edition features:

```cypher
// Create a comprehensive view of your social network
MATCH (n)-[r]-(m) 
RETURN n, r, m
```

**Enterprise Browser Features:**
1. **Enhanced Performance:** Faster query execution with Enterprise optimizations
2. **Advanced Monitoring:** Query performance metrics available
3. **Extended Procedures:** Access to full APOC and GDS libraries
4. **Professional Styling:** All standard visualization capabilities
5. **Security Features:** User management and access controls

**Browser Visualization Features:**
1. **Interactive Layout:** Click and drag nodes to rearrange
2. **Zoom Controls:** Use mouse wheel to zoom in/out
3. **Node Styling:** Customize colors and appearance
4. **Relationship Inspection:** Click on edges to see properties
5. **Multi-selection:** Hold Ctrl/Cmd to select multiple nodes

### Step 22: Enterprise Graph Analytics Preview
**Bonus Enterprise Features:** Let's preview some advanced capabilities available in later labs:

```cypher
// Example: Advanced APOC procedure (Enterprise enhanced)
CALL apoc.meta.graph() YIELD nodes, relationships
RETURN nodes, relationships
```

```cypher
// Example: Check Graph Data Science availability
CALL gds.version() YIELD gdsVersion
RETURN gdsVersion
```

**Professional Graph Styling:**
**Customize Person Nodes:**
1. **Click "Person" label** in the result panel (bottom left)
2. **Choose node color** (e.g., blue for people)
3. **Set node caption** to display name: `{name}`
4. **Adjust node size** based on importance

**Customize Company Nodes:**
1. **Click "Company" label** in the result panel
2. **Choose different color** (e.g., orange for companies)
3. **Set caption** to show company name: `{name}`
4. **Use larger size** to represent organizations

**Relationship Styling:**
1. **Click on KNOWS relationships** to see strength and context
2. **Click on WORKS_FOR relationships** to view role details
3. **Observe relationship directions** and property details

## Part 6: Python Integration Verification (5 minutes)

### Step 23: Launch Jupyter Lab
Open a terminal and run:
```bash
jupyter lab
```

### Step 24: Test Neo4j Python Connection
1. **Create new Python notebook**
2. **Name it:** "neo4j_social_network_analysis.ipynb"
3. **Run this code:**

```python
# Connect to Neo4j Docker instance from Python
from neo4j import GraphDatabase
import pandas as pd

# Connect using same credentials as Browser (to social database)
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"), database="social")

# Query the social network we just created
with driver.session() as session:
    # Get all people and their details
    result = session.run("""
        MATCH (p:Person) 
        RETURN p.name AS name, p.age AS age, p.city AS city, 
               p.profession AS job, p.email AS email
        ORDER BY p.name
    """)
    people_df = pd.DataFrame([record.data() for record in result])
    print("People in our social network:")
    print(people_df)
    
    # Get relationship analysis
    result2 = session.run("""
        MATCH (p1:Person)-[k:KNOWS]-(p2:Person)
        RETURN p1.name AS person1, p2.name AS person2, 
               k.relationship AS type, k.strength AS strength
        ORDER BY k.strength DESC
    """)
    relationships_df = pd.DataFrame([record.data() for record in result2])
    print("\nRelationships in our network:")
    print(relationships_df)

driver.close()
print("✅ Python connection and analysis successful!")
```

**Expected Output:** DataFrames showing the social network data you created

## Lab Completion Checklist

- [ ] Verified Neo4j Docker instance is running
- [ ] Successfully connected to Docker Neo4j via Desktop 2 remote connection
- [ ] Connected to Neo4j Browser through remote connection
- [ ] Created dedicated "social" database and switched to it
- [ ] Started with empty database and built complete social network
- [ ] Created 5 Person nodes and 2 Company nodes with detailed properties
- [ ] Built WORKS_FOR and KNOWS relationships with metadata
- [ ] Wrote pattern-matching queries for network analysis
- [ ] Performed business intelligence and social network analysis
- [ ] Explored friends-of-friends and colleague discovery
- [ ] Used Neo4j Browser advanced visualization features (professional graph styling)
- [ ] Connected to Docker Neo4j from Python/Jupyter successfully
- [ ] Verified complete remote workflow with Docker backend

## Key Concepts Mastered

1. **Remote Connection Setup:** Connecting Desktop 2 to Docker Neo4j Enterprise instance
2. **Database Management:** Creating and switching to dedicated databases
3. **Neo4j Browser Mastery:** Query interface with Enterprise backend
4. **Cypher ASCII Art:** Reading and writing visual graph patterns
5. **Node Creation:** Labels, properties, and comprehensive data modeling
6. **Relationship Modeling:** Professional and personal connections with metadata
7. **Pattern Matching:** Complex relationship traversal and analysis
8. **Social Network Analysis:** Friend discovery and business intelligence
9. **Enterprise Features:** Advanced procedures and capabilities preview
10. **Production Workflow:** Enterprise Docker deployment with remote client access

## Troubleshooting Common Issues

### If Docker Neo4j isn't running:
```bash
# Check if container exists
docker ps -a | grep neo4j

# Start existing container
docker start neo4j

# Or create new container (Neo4j Enterprise for course)
docker run --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  -e NEO4J_PLUGINS='["apoc","graph-data-science"]' \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -d \
  neo4j:enterprise
```

### If Desktop 2 remote connection fails:
- **Check Docker ports:** Ensure 7474 and 7687 are accessible
- **Verify credentials:** neo4j/password (as set in Docker)
- **Test direct connection:** Try browser at http://localhost:7474 first

### If Browser connection fails:
- **Verify Docker instance:** `docker ps | grep neo4j`
- **Check connection URL:** bolt://localhost:7687
- **Confirm credentials:** neo4j/password

### About Neo4j Enterprise Edition:
- **Enterprise features** - Advanced security, monitoring, and performance capabilities
- **Educational licensing** - Enterprise features available for learning environments
- **APOC and GDS** - Full access to advanced graph algorithms and procedures
- **Bloom licensing** - Requires separate license file for full activation
- **Production note** - Organizations use Enterprise for scalable, secure deployments

### If Python connection fails:
```python
# Detailed connection test
from neo4j import GraphDatabase
try:
    driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"), database="social")
    driver.verify_connectivity()
    print("✅ Connection successful!")
    
    # Test query
    with driver.session() as session:
        result = session.run("RETURN 'Docker Neo4j connection works!' AS message")
        print(result.single()["message"])
        
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("Check Docker Neo4j container is running")
finally:
    if 'driver' in locals():
        driver.close()
```

## Understanding the Remote Architecture

This lab demonstrates a **production-grade architecture:**
- **Neo4j Enterprise:** Running in Docker container (enterprise-grade features)
- **Client Tools:** Desktop 2 for management, Browser for development
- **Remote Connections:** Industry-standard connection pattern
- **Enterprise Workflow:** Mirrors real enterprise Neo4j environments

This setup teaches both graph database skills and enterprise deployment patterns used in professional Neo4j implementations.

## Next Steps

You're now ready for **Lab 2: Advanced Cypher Patterns**, where you'll learn:
- Complex pattern matching with your social network
- Advanced aggregation and analytical queries
- Data import and CSV processing
- Performance optimization techniques
- Graph algorithm applications

**Congratulations!** You've successfully built a complete social network from scratch using a Docker-based Neo4j Enterprise instance with remote client connections. This workflow mirrors professional Neo4j development environments and gives you real-world experience with both graph database concepts and modern deployment architectures.