# Neo4j Lab 1: Enterprise Setup & Docker Connection

## Overview
**Duration:** 45 minutes  
**Objective:** Establish Neo4j Enterprise environment and master professional client-server architecture patterns using insurance industry data

In this lab, you'll work with Neo4j Enterprise 2025.06.0 running in Docker, connecting via Neo4j Desktop to mirror real-world enterprise deployment patterns. This setup reflects how Neo4j is actually deployed in production insurance environments.

---

## Part 1: Docker Neo4j Enterprise Verification (5 minutes)

### Step 1: Verify Docker Neo4j Enterprise Container
Your environment includes a pre-configured Neo4j Enterprise container. Let's verify it's running:

```bash
# Check if Neo4j container is running
docker ps | grep neo4j

# Expected output should show:
# CONTAINER ID   IMAGE           COMMAND     CREATED     STATUS      PORTS                              NAMES
# [container_id] neo4j:enterprise ...        ...         Up X hours  0.0.0.0:7474->7474/tcp, 0.0.0.0:7687->7687/tcp   neo4j
```

If the container isn't running, start it:
```bash
docker start neo4j
```

### Step 2: Verify Enterprise Edition and Version
Check that you're running Neo4j Enterprise 2025.06.0:

```bash
# Check Neo4j version and edition
docker exec neo4j neo4j version

# Expected output:
# neo4j 2025.06.0
# Edition: Enterprise
```

### Step 3: Confirm Enterprise Features Available
Verify that APOC is available:

```bash
# List installed plugins
docker exec neo4j ls /var/lib/neo4j/plugins/

# Should show:
# apoc-[version].jar
```

**✅ Verification Complete:** You now have Neo4j Enterprise 2025.06.0 running in Docker with enterprise features enabled.

---

## Part 2: Neo4j Desktop Remote Connection (10 minutes)

### Step 4: Launch Neo4j Desktop
Open Neo4j Desktop on your system. This demonstrates the **professional client-server architecture** used in enterprise insurance environments.

### Step 5: Create Remote Connection
Instead of creating a local database, we'll connect to our Docker Enterprise instance:

1. **Click "New" → "Remote connection"**
2. **Configure connection:**
   - **Name:** `Docker Neo4j Enterprise Insurance`
   - **Connect URL:** `neo4j://localhost:7687`
   - **Database:** `neo4j` (default)
   - **Username:** `neo4j`
   - **Password:** `password`

3. **Click "Connect"**

### Step 6: Verify Remote Connection
Once connected, you should see:
- **Green connection indicator**
- **Enterprise edition badge**
- **Available databases** (neo4j, system)

**Enterprise Architecture Note:** This client-server pattern mirrors how insurance analysts and underwriters connect to centralized Neo4j instances in production environments.

---

## Part 3: Enterprise Database Creation (5 minutes)

### Step 7: Create Dedicated Insurance Database
Enterprise Neo4j supports multiple databases for **multi-tenancy** in insurance environments:

1. **Open Neo4j Browser** from Desktop connection
2. **Switch to system database:**
   ```cypher
   :use system
   ```

3. **Create a dedicated database for insurance data:**
   ```cypher
   CREATE DATABASE insurance IF NOT EXISTS
   ```

4. **Switch to your new database:**
   ```cypher
   :use insurance
   ```

5. **Verify database creation:**
   ```cypher
   SHOW DATABASES
   ```

**Enterprise Pattern:** Separate databases for different insurance lines (auto, home, life), business units, or regulatory environments.

---

## Part 4: Enterprise Features Exploration (10 minutes)

### Step 8: Explore APOC Procedures for Insurance
APOC (Awesome Procedures on Cypher) provides enterprise-grade functionality for insurance operations:

```cypher
// List available APOC procedures relevant to insurance
CALL apoc.help("") YIELD name, text
WHERE name CONTAINS "date" OR name CONTAINS "uuid" OR name CONTAINS "math"
RETURN name, text
LIMIT 10
```

### Step 9: Test Enterprise Metadata Functions for Insurance
```cypher
// Generate insurance policy numbers and claim IDs
RETURN randomUUID() AS policy_id,
       "POL-" + toString(toInteger(rand() * 1000000)) AS policy_number
```

```cypher
// Create timestamps for policy effective dates and audit trails
RETURN datetime() AS created_at, 
       date() AS policy_effective_date,
       date() + duration({years: 1}) AS policy_expiration_date
```

---

## Part 5: Insurance Graph Creation with Enterprise Patterns (15 minutes)

### Step 11: Create Insurance Customers with Enterprise Metadata
Let's build an insurance customer network with comprehensive enterprise metadata:

```cypher
// Create customers with insurance-specific enterprise metadata
CREATE (customer1:Customer:Individual {
  id: randomUUID(),
  customer_number: "CUST-001234",
  first_name: "Sarah",
  last_name: "Johnson",
  date_of_birth: date("1985-03-15"),
  ssn_last_four: "1234",
  email: "sarah.johnson@email.com",
  phone: "555-0123",
  address: "123 Oak Street",
  city: "Austin",
  state: "TX",
  zip_code: "78701",
  credit_score: 720,
  customer_since: date("2020-01-15"),
  risk_tier: "Standard",
  lifetime_value: 12500.00,
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
})

CREATE (customer2:Customer:Individual {
  id: randomUUID(),
  customer_number: "CUST-001235",
  first_name: "Michael",
  last_name: "Chen",
  date_of_birth: date("1978-09-22"),
  ssn_last_four: "5678",
  email: "m.chen@email.com",
  phone: "555-0124",
  address: "456 Pine Avenue",
  city: "Austin",
  state: "TX",
  zip_code: "78702",
  credit_score: 680,
  customer_since: date("2019-06-10"),
  risk_tier: "Standard",
  lifetime_value: 18750.00,
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
})

CREATE (customer3:Customer:Individual {
  id: randomUUID(),
  customer_number: "CUST-001236",
  first_name: "Emma",
  last_name: "Rodriguez",
  date_of_birth: date("1992-12-08"),
  ssn_last_four: "9012",
  email: "emma.rodriguez@email.com",
  phone: "555-0125",
  address: "789 Maple Drive",
  city: "Dallas",
  state: "TX",
  zip_code: "75201",
  credit_score: 750,
  customer_since: date("2021-11-20"),
  risk_tier: "Preferred",
  lifetime_value: 8900.00,
  created_at: datetime(),
  created_by: "underwriting_system",
  last_updated: datetime(),
  version: 1
})
```

### Step 12: Create Insurance Products and Agents
```cypher
// Create insurance products
CREATE (auto_policy:Product:Insurance {
  id: randomUUID(),
  product_code: "AUTO-STD",
  product_name: "Standard Auto Insurance",
  product_type: "Auto",
  coverage_types: ["Liability", "Collision", "Comprehensive"],
  base_premium: 1200.00,
  active: true,
  created_at: datetime(),
  created_by: "product_management"
})

CREATE (home_policy:Product:Insurance {
  id: randomUUID(),
  product_code: "HOME-STD",
  product_name: "Standard Homeowners Insurance",
  product_type: "Property",
  coverage_types: ["Dwelling", "Personal Property", "Liability"],
  base_premium: 800.00,
  active: true,
  created_at: datetime(),
  created_by: "product_management"
})

// Create insurance agents
CREATE (agent1:Agent:Employee {
  id: randomUUID(),
  agent_id: "AGT-001",
  first_name: "David",
  last_name: "Wilson",
  email: "david.wilson@insurance.com",
  phone: "555-0200",
  license_number: "TX-INS-123456",
  territory: "Central Texas",
  commission_rate: 0.12,
  hire_date: date("2018-03-01"),
  performance_rating: "Excellent",
  created_at: datetime(),
  created_by: "hr_system"
})

CREATE (agent2:Agent:Employee {
  id: randomUUID(),
  agent_id: "AGT-002",
  first_name: "Lisa",
  last_name: "Thompson",
  email: "lisa.thompson@insurance.com",
  phone: "555-0201",
  license_number: "TX-INS-789012",
  territory: "North Texas",
  commission_rate: 0.11,
  hire_date: date("2019-07-15"),
  performance_rating: "Very Good",
  created_at: datetime(),
  created_by: "hr_system"
})
```

### Step 13: Create Insurance Policies with Rich Metadata
```cypher
// Create insurance policies with comprehensive enterprise metadata
MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (auto_product:Product {product_code: "AUTO-STD"})
MATCH (home_product:Product {product_code: "HOME-STD"})
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"})

// Sarah's auto policy
CREATE (sarah_auto:Policy:Active {
  id: randomUUID(),
  policy_number: "POL-AUTO-001234",
  product_type: "Auto",
  policy_status: "Active",
  effective_date: date("2024-01-01"),
  expiration_date: date() + duration({months: 2}),
  annual_premium: 1320.00,
  deductible: 500,
  coverage_limit: 100000,
  payment_frequency: "Monthly",
  auto_make: "Toyota",
  auto_model: "Camry",
  auto_year: 2022,
  vin: "1HGBH41JXMN109186",
  created_at: datetime(),
  created_by: "underwriting_system",
  underwriter: "system_auto",
  version: 1
})

// Michael's home policy
CREATE (michael_home:Policy:Active {
  id: randomUUID(),
  policy_number: "POL-HOME-001235",
  product_type: "Property",
  policy_status: "Active",
  effective_date: date("2024-02-15"),
  expiration_date: date() + duration({months: 1}),
  annual_premium: 950.00,
  deductible: 1000,
  coverage_limit: 250000,
  payment_frequency: "Annual",
  property_value: 320000,
  property_type: "Single Family",
  construction_type: "Frame",
  roof_type: "Shingle",
  created_at: datetime(),
  created_by: "underwriting_system",
  underwriter: "system_property",
  version: 1
})

// Emma's auto policy
CREATE (emma_auto:Policy:Active {
  id: randomUUID(),
  policy_number: "POL-AUTO-001236",
  product_type: "Auto",
  policy_status: "Active",
  effective_date: date("2024-03-01"),
  expiration_date: date() + duration({weeks: 6}),
  annual_premium: 980.00,
  deductible: 250,
  coverage_limit: 150000,
  payment_frequency: "Semi-Annual",
  auto_make: "Honda",
  auto_model: "Civic",
  auto_year: 2023,
  vin: "2HGFC2F59MH542789",
  created_at: datetime(),
  created_by: "underwriting_system",
  underwriter: "system_auto",
  version: 1
})
```

### Step 14: Create Insurance Relationships

#### Part A: Customer-Policy Relationships
```cypher
// Create Customer-Policy relationships
MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (sarah_auto:Policy {policy_number: "POL-AUTO-001234"})
MATCH (michael_home:Policy {policy_number: "POL-HOME-001235"})
MATCH (emma_auto:Policy {policy_number: "POL-AUTO-001236"})

CREATE (sarah)-[:HOLDS_POLICY {
  relationship_start: date("2024-01-01"),
  policyholder_type: "Primary",
  created_at: datetime()
}]->(sarah_auto)

CREATE (michael)-[:HOLDS_POLICY {
  relationship_start: date("2024-02-15"),
  policyholder_type: "Primary",
  created_at: datetime()
}]->(michael_home)

CREATE (emma)-[:HOLDS_POLICY {
  relationship_start: date("2024-03-01"),
  policyholder_type: "Primary",
  created_at: datetime()
}]->(emma_auto)
```

#### Part B: Policy-Product Relationships
```cypher
// Create Policy-Product relationships
MATCH (sarah_auto:Policy {policy_number: "POL-AUTO-001234"})
MATCH (michael_home:Policy {policy_number: "POL-HOME-001235"})
MATCH (emma_auto:Policy {policy_number: "POL-AUTO-001236"})
MATCH (auto_product:Product {product_code: "AUTO-STD"})
MATCH (home_product:Product {product_code: "HOME-STD"})

CREATE (sarah_auto)-[:BASED_ON {
  underwriting_date: date("2023-12-15"),
  risk_assessment: "Standard",
  created_at: datetime()
}]->(auto_product)

CREATE (michael_home)-[:BASED_ON {
  underwriting_date: date("2024-01-20"),
  risk_assessment: "Standard",
  created_at: datetime()
}]->(home_product)

CREATE (emma_auto)-[:BASED_ON {
  underwriting_date: date("2024-02-10"),
  risk_assessment: "Preferred",
  created_at: datetime()
}]->(auto_product)
```

#### Part C: Agent and Referral Relationships
```cypher
// Create Agent-Customer and referral relationships
MATCH (sarah:Customer {customer_number: "CUST-001234"})
MATCH (michael:Customer {customer_number: "CUST-001235"})
MATCH (emma:Customer {customer_number: "CUST-001236"})
MATCH (agent1:Agent {agent_id: "AGT-001"})
MATCH (agent2:Agent {agent_id: "AGT-002"})

CREATE (agent1)-[:SERVICES {
  relationship_start: date("2020-01-15"),
  service_quality: "Excellent",
  last_contact: date("2024-01-05"),
  created_at: datetime()
}]->(sarah)

CREATE (agent1)-[:SERVICES {
  relationship_start: date("2019-06-10"),
  service_quality: "Very Good",
  last_contact: date("2024-02-10"),
  created_at: datetime()
}]->(michael)

CREATE (agent2)-[:SERVICES {
  relationship_start: date("2021-11-20"),
  service_quality: "Excellent",
  last_contact: date("2024-02-25"),
  created_at: datetime()
}]->(emma)

CREATE (sarah)-[:REFERRED {
  referral_date: date("2021-10-15"),
  referral_bonus: 50.00,
  conversion_status: "Converted",
  created_at: datetime()
}]->(emma)
```

### Step 15: Enterprise Insurance Query Patterns
```cypher
// Customer portfolio analysis
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)-[:BASED_ON]->(product:Product)
RETURN c.first_name + " " + c.last_name AS customer_name,
       c.customer_number AS customer_id,
       c.risk_tier AS risk_category,
       collect(product.product_type) AS policy_types,
       sum(p.annual_premium) AS total_annual_premium,
       c.lifetime_value AS customer_lifetime_value
ORDER BY total_annual_premium DESC
```

```cypher
// Agent performance analysis
MATCH (agent:Agent)-[:SERVICES]->(customer:Customer)-[:HOLDS_POLICY]->(policy:Policy)
RETURN agent.first_name + " " + agent.last_name AS agent_name,
       agent.territory AS territory,
       count(DISTINCT customer) AS customers_served,
       count(policy) AS total_policies,
       sum(policy.annual_premium) AS total_premium_volume,
       avg(policy.annual_premium) AS average_policy_premium
ORDER BY total_premium_volume DESC
```

```cypher
// Risk tier distribution analysis
MATCH (c:Customer)
RETURN c.risk_tier AS risk_tier,
       count(c) AS customer_count,
       avg(c.credit_score) AS average_credit_score,
       avg(c.lifetime_value) AS average_lifetime_value
ORDER BY customer_count DESC
```

```cypher
// Policy expiration analysis (renewal pipeline)
MATCH (p:Policy)
WHERE p.expiration_date >= date() AND p.expiration_date <= date() + duration({months: 3})
MATCH (customer:Customer)-[:HOLDS_POLICY]->(p)
RETURN customer.first_name + " " + customer.last_name AS customer_name,
       p.policy_number AS policy_number,
       p.product_type AS policy_type,
       p.expiration_date AS expiration_date,
       p.annual_premium AS annual_premium,
       customer.risk_tier AS risk_tier
ORDER BY p.expiration_date
```

### Step 16: Insurance Network Analysis
```cypher
// Customer referral network analysis
MATCH (referrer:Customer)-[ref:REFERRED]->(referred:Customer)
RETURN referrer.first_name + " " + referrer.last_name AS referrer_name,
       referred.first_name + " " + referred.last_name AS referred_customer,
       ref.referral_date AS referral_date,
       ref.referral_bonus AS bonus_paid,
       ref.conversion_status AS status
ORDER BY ref.referral_date DESC
```

```cypher
// Geographic concentration analysis
MATCH (c:Customer)
RETURN c.city AS city,
       c.state AS state,
       count(c) AS customer_count,
       avg(c.credit_score) AS avg_credit_score,
       collect(DISTINCT c.risk_tier) AS risk_tiers_present
ORDER BY customer_count DESC
```

---

## Part 6: Enterprise Architecture Validation (5 minutes)

### Step 17: Insurance Database Architecture Review
Let's verify our enterprise insurance architecture setup:

```cypher
// Database and connection information
CALL dbms.components() YIELD name, versions, edition
RETURN name, versions[0] AS version, edition
```

```cypher
// Available insurance-relevant procedures
SHOW PROCEDURES YIELD name
WHERE name STARTS WITH "apoc" OR name STARTS WITH "gds"
RETURN count(*) AS enterprise_procedures_available
```

```cypher
// Insurance database statistics
CALL apoc.meta.stats() YIELD labels, relTypes, nodeCount, relCount
RETURN labels, relTypes, nodeCount, relCount
```

### Step 18: Insurance Query Performance Baseline
```cypher
// Insurance portfolio query performance baseline
PROFILE MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
RETURN c.customer_number, p.policy_number, p.annual_premium
LIMIT 10
```

**Review the query plan** to understand how Neo4j Enterprise optimizes insurance queries.

### Step 19: Visualize Insurance Network
```cypher
// Complete insurance network visualization
MATCH (c:Customer)-[r1:HOLDS_POLICY]->(p:Policy)-[r2:BASED_ON]->(prod:Product)
MATCH (a:Agent)-[r3:SERVICES]->(c)
RETURN c, r1, p, r2, prod, a, r3
```

**Enterprise Visualization:** This query displays the complete insurance ecosystem with customers, policies, products, and agent relationships. Use Neo4j Browser's graph visualization to explore the insurance network structure.

---

## Lab 1 Summary

**🎯 What You've Accomplished:**

### **Enterprise Insurance Architecture Setup**
- ✅ **Docker Neo4j Enterprise 2025.06.0** running with full enterprise features for insurance operations
- ✅ **Professional client-server architecture** using Neo4j Desktop remote connections for insurance environments
- ✅ **Multi-database environment** with dedicated insurance database for regulatory compliance
- ✅ **Enterprise features verification** with APOC for insurance analytics

### **Insurance Domain Modeling**
- ✅ **Customer lifecycle management** with comprehensive policyholder data and risk assessments
- ✅ **Policy administration** with multi-product support and enterprise metadata
- ✅ **Agent relationship tracking** with performance metrics and territory management
- ✅ **Referral network modeling** for customer acquisition and retention analysis

### **Node Types Introduced (4 types):**
- ✅ **Customer:Individual** - Complete policyholder profiles with risk assessment
- ✅ **Product:Insurance** - Auto and property insurance product definitions
- ✅ **Policy:Auto/Property** - Active insurance policies with comprehensive coverage details
- ✅ **Agent:Employee** - Insurance agents with territory and performance tracking

### **Database State:** 10 nodes, 15 relationships with enterprise metadata patterns

### **Enterprise Insurance Readiness**
- ✅ **Regulatory compliance patterns** with audit trails and data lineage
- ✅ **Production-grade metadata** including versioning and system integration tracking
- ✅ **Performance monitoring** with query profiling for insurance workloads
- ✅ **Scalable architecture** supporting multi-line insurance operations

---

## Next Steps

You're now ready for **Lab 2: Cypher Query Fundamentals**, where you'll:
- Master advanced Cypher query patterns using the MWR memory aid for insurance operations
- Expand the insurance network with Branch:Location and Department entities
- Build complex insurance networks with claims, underwriting, and fraud detection patterns
- Apply enterprise performance optimization techniques for insurance workloads
- **Database Evolution:** 10 nodes → 25 nodes, 15 relationships → 40 relationships

**Congratulations!** You've successfully established an enterprise-grade Neo4j insurance environment that mirrors professional deployment patterns used in production systems at major insurance companies for customer 360-degree views, fraud detection, and risk assessment.

## Troubleshooting

### If Docker container isn't running:
```bash
# Check container status
docker ps -a | grep neo4j

# Start container if stopped
docker start neo4j

# Check logs if issues persist
docker logs neo4j
```

### If Desktop connection fails:
- Verify Docker container is running on ports 7474 and 7687
- Confirm credentials: username `neo4j`, password `password`
- Test direct browser connection at `http://localhost:7474`

### If enterprise features aren't available:
```bash
# Verify enterprise license acceptance
docker exec neo4j cat /var/lib/neo4j/conf/neo4j.conf | grep LICENSE_AGREEMENT

# Check plugin installation
docker exec neo4j ls -la /var/lib/neo4j/plugins/
```