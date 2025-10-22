# Neo4j Bulk Data Loading Guide

This guide demonstrates how to load the insurance dataset CSV files into Neo4j using the `LOAD CSV` command.

## CSV Files Overview

The dataset includes 6 CSV files representing the complete insurance domain model:

1. **customers.csv** - 20 customer records with demographics and risk profiles
2. **policies.csv** - 30 policy records (Auto and Property insurance)
3. **claims.csv** - 18 claims records with settlement history
4. **agents.csv** - 10 insurance agent records with performance metrics
5. **products.csv** - 8 insurance product offerings
6. **branches.csv** - 5 branch office locations

## File Placement

All CSV files are located in the `data/` directory relative to the project root:

```
/Users/jwkidd3/classes_in_development/neo4j_mastering/data/
├── customers.csv
├── policies.csv
├── claims.csv
├── agents.csv
├── products.csv
└── branches.csv
```

## Loading Strategy

Follow this order to maintain referential integrity:

1. **Load Base Entities** (no dependencies)
   - Branches
   - Products
   - Agents
   - Customers

2. **Load Dependent Entities** (have foreign keys)
   - Policies (depends on Customers, Products)
   - Claims (depends on Policies)

3. **Create Relationships**
   - Customer-Policy relationships
   - Policy-Product relationships
   - Policy-Claim relationships
   - Agent-Customer relationships
   - Agent-Branch relationships

## Step-by-Step Loading Process

### Prerequisites

```cypher
// 1. Clear existing data (CAUTION: deletes everything!)
MATCH (n) DETACH DELETE n;

// 2. Create constraints for data integrity
CREATE CONSTRAINT customer_number_unique IF NOT EXISTS
FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;

CREATE CONSTRAINT policy_number_unique IF NOT EXISTS
FOR (p:Policy) REQUIRE p.policy_number IS UNIQUE;

CREATE CONSTRAINT claim_number_unique IF NOT EXISTS
FOR (c:Claim) REQUIRE c.claim_number IS UNIQUE;

CREATE CONSTRAINT agent_id_unique IF NOT EXISTS
FOR (a:Agent) REQUIRE a.agent_id IS UNIQUE;

CREATE CONSTRAINT product_code_unique IF NOT EXISTS
FOR (p:Product) REQUIRE p.product_code IS UNIQUE;

CREATE CONSTRAINT branch_id_unique IF NOT EXISTS
FOR (b:Branch) REQUIRE b.branch_id IS UNIQUE;
```

### 1. Load Branches

```cypher
LOAD CSV WITH HEADERS FROM 'file:///branches.csv' AS row
CREATE (b:Branch {
  branch_id: row.branch_id,
  branch_name: row.branch_name,
  address: row.address,
  city: row.city,
  state: row.state,
  zip_code: row.zip_code,
  phone: row.phone,
  manager_name: row.manager_name,
  region: row.region,
  office_type: row.office_type,
  opening_date: date(row.opening_date)
});

// Verify: Should return 5 branches
MATCH (b:Branch) RETURN count(b) AS branch_count;
```

### 2. Load Products

```cypher
LOAD CSV WITH HEADERS FROM 'file:///products.csv' AS row
CREATE (p:Product {
  product_code: row.product_code,
  product_name: row.product_name,
  product_type: row.product_type,
  coverage_category: row.coverage_category,
  base_rate: toFloat(row.base_rate),
  risk_multiplier: toFloat(row.risk_multiplier),
  min_coverage: toInteger(row.min_coverage),
  max_coverage: toInteger(row.max_coverage),
  deductible_options: row.deductible_options,
  description: row.description
});

// Verify: Should return 8 products
MATCH (p:Product) RETURN count(p) AS product_count;
```

### 3. Load Agents

```cypher
LOAD CSV WITH HEADERS FROM 'file:///agents.csv' AS row
CREATE (a:Agent {
  agent_id: row.agent_id,
  first_name: row.first_name,
  last_name: row.last_name,
  email: row.email,
  phone: row.phone,
  territory: row.territory,
  license_number: row.license_number,
  hire_date: date(row.hire_date),
  total_sales_ytd: toFloat(row.total_sales_ytd),
  performance_rating: row.performance_rating,
  branch_id: row.branch_id
});

// Verify: Should return 10 agents
MATCH (a:Agent) RETURN count(a) AS agent_count;
```

### 4. Load Customers

```cypher
LOAD CSV WITH HEADERS FROM 'file:///customers.csv' AS row
CREATE (c:Customer {
  customer_number: row.customer_number,
  first_name: row.first_name,
  last_name: row.last_name,
  email: row.email,
  phone: row.phone,
  date_of_birth: date(row.date_of_birth),
  ssn_last_four: row.ssn_last_four,
  address: row.address,
  city: row.city,
  state: row.state,
  zip_code: row.zip_code,
  credit_score: toInteger(row.credit_score),
  risk_tier: row.risk_tier,
  customer_since: date(row.customer_since),
  lifetime_value: toFloat(row.lifetime_value),
  preferred_contact: row.preferred_contact,
  customer_status: row.customer_status
});

// Verify: Should return 20 customers
MATCH (c:Customer) RETURN count(c) AS customer_count;
```

### 5. Load Policies

```cypher
LOAD CSV WITH HEADERS FROM 'file:///policies.csv' AS row
CREATE (p:Policy {
  policy_number: row.policy_number,
  customer_number: row.customer_number,
  product_type: row.product_type,
  policy_status: row.policy_status,
  annual_premium: toFloat(row.annual_premium),
  effective_date: date(row.effective_date),
  expiration_date: date(row.expiration_date),
  coverage_amount: toInteger(row.coverage_amount),
  deductible: toInteger(row.deductible),
  auto_make: CASE WHEN row.auto_make = '' THEN null ELSE row.auto_make END,
  auto_model: CASE WHEN row.auto_model = '' THEN null ELSE row.auto_model END,
  auto_year: CASE WHEN row.auto_year = '' THEN null ELSE toInteger(row.auto_year) END,
  auto_vin: CASE WHEN row.auto_vin = '' THEN null ELSE row.auto_vin END,
  property_type: CASE WHEN row.property_type = '' THEN null ELSE row.property_type END,
  property_address: CASE WHEN row.property_address = '' THEN null ELSE row.property_address END,
  property_value: CASE WHEN row.property_value = '' THEN null ELSE toInteger(row.property_value) END
});

// Add secondary labels based on policy type and status
MATCH (p:Policy)
WHERE p.policy_status = 'Active'
SET p:Active;

// Verify: Should return 30 policies
MATCH (p:Policy) RETURN count(p) AS policy_count;
MATCH (p:Policy:Active) RETURN count(p) AS active_policy_count;
```

### 6. Load Claims

```cypher
LOAD CSV WITH HEADERS FROM 'file:///claims.csv' AS row
CREATE (c:Claim {
  claim_number: row.claim_number,
  policy_number: row.policy_number,
  claim_date: date(row.claim_date),
  claim_type: row.claim_type,
  claim_status: row.claim_status,
  claim_amount: toFloat(row.claim_amount),
  settled_amount: toFloat(row.settled_amount),
  claim_description: row.claim_description,
  adjuster_name: row.adjuster_name,
  filed_date: date(row.filed_date),
  settled_date: CASE WHEN row.settled_date = '' THEN null ELSE date(row.settled_date) END
});

// Verify: Should return 18 claims
MATCH (c:Claim) RETURN count(c) AS claim_count;
```

### 7. Create Relationships

```cypher
// Customer HOLDS_POLICY Policy
MATCH (c:Customer), (p:Policy)
WHERE c.customer_number = p.customer_number
CREATE (c)-[:HOLDS_POLICY]->(p);

// Policy BASED_ON Product (match by product_type)
MATCH (pol:Policy), (prod:Product)
WHERE pol.product_type = prod.product_type
  AND prod.product_name CONTAINS 'Standard'  // Use standard products
CREATE (pol)-[:BASED_ON]->(prod);

// Policy HAS_CLAIM Claim
MATCH (p:Policy), (c:Claim)
WHERE p.policy_number = c.policy_number
CREATE (p)-[:HAS_CLAIM]->(c);

// Agent WORKS_AT Branch
MATCH (a:Agent), (b:Branch)
WHERE a.branch_id = b.branch_id
CREATE (a)-[:WORKS_AT]->(b);

// Agent MANAGES Customer (assign based on territory/city match)
MATCH (a:Agent), (c:Customer)
WHERE a.territory CONTAINS c.city
  OR (a.territory = 'Central Texas' AND c.city = 'Austin')
  OR (a.territory = 'North Texas' AND c.city = 'Dallas')
  OR (a.territory = 'Houston Metro' AND c.city = 'Houston')
WITH a, c
ORDER BY a.agent_id, c.customer_number
WITH a, collect(c)[0..3] AS customers  // Max 3 customers per agent
UNWIND customers AS customer
CREATE (a)-[:MANAGES]->(customer);

// Verify relationships
MATCH ()-[r]->() RETURN type(r) AS relationship, count(r) AS count;
```

## Using HTTP URLs (Alternative)

If you want to load from HTTP instead of local files:

```cypher
// Example: Load from GitHub or web server
LOAD CSV WITH HEADERS FROM 'https://your-server.com/data/customers.csv' AS row
CREATE (c:Customer {...});
```

## Verification Queries

After loading, verify the data:

```cypher
// 1. Node counts by label
MATCH (n)
RETURN labels(n)[0] AS label, count(n) AS count
ORDER BY count DESC;

// 2. Relationship counts
MATCH ()-[r]->()
RETURN type(r) AS relationship, count(r) AS count
ORDER BY count DESC;

// 3. Sample customer with policies
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
RETURN c.first_name, c.last_name, count(p) AS policy_count
ORDER BY policy_count DESC
LIMIT 5;

// 4. Sample policy with product and claims
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)-[:BASED_ON]->(prod:Product)
OPTIONAL MATCH (p)-[:HAS_CLAIM]->(claim:Claim)
RETURN c.first_name + ' ' + c.last_name AS customer,
       p.policy_number,
       prod.product_name,
       count(claim) AS claim_count
LIMIT 10;

// 5. Agent performance
MATCH (a:Agent)-[:MANAGES]->(c:Customer)
OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
RETURN a.first_name + ' ' + a.last_name AS agent,
       count(DISTINCT c) AS customers,
       count(p) AS total_policies,
       a.performance_rating
ORDER BY customers DESC;
```

## Expected Results

After successful loading:

- **Customers**: 20 nodes
- **Policies**: 30 nodes
- **Claims**: 18 nodes
- **Agents**: 10 nodes
- **Products**: 8 nodes
- **Branches**: 5 nodes
- **Total Nodes**: 91 nodes

**Relationships**:
- HOLDS_POLICY: 30 relationships
- BASED_ON: 30 relationships
- HAS_CLAIM: 18 relationships
- WORKS_AT: 10 relationships
- MANAGES: ~20-30 relationships (varies by assignment logic)

## Troubleshooting

### File Not Found Error

```
Neo.ClientError.Statement.ExternalResourceFailed: Couldn't load the external resource
```

**Solution**:
1. Ensure CSV files are in Neo4j's `import` directory
2. For Docker: Copy files to container's import directory
   ```bash
   docker cp data/customers.csv neo4j:/var/lib/neo4j/import/
   ```
3. Or use HTTP URLs instead of `file:///`

### Data Type Errors

```
Type mismatch: expected Integer but was String
```

**Solution**:
Use conversion functions: `toInteger()`, `toFloat()`, `date()`, etc.

### Constraint Violations

```
Node already exists with this unique property value
```

**Solution**:
Either:
1. Use `MERGE` instead of `CREATE`
2. Or clear database first: `MATCH (n) DETACH DELETE n`

## Performance Tips

1. **Use PERIODIC COMMIT** for large files (>1000 rows):
   ```cypher
   USING PERIODIC COMMIT 500
   LOAD CSV WITH HEADERS FROM 'file:///large_file.csv' AS row
   CREATE (...);
   ```

2. **Create indexes** before loading for faster lookups:
   ```cypher
   CREATE INDEX customer_number_index IF NOT EXISTS
   FOR (c:Customer) ON (c.customer_number);
   ```

3. **Batch relationship creation** using `WITH` and `collect()`:
   ```cypher
   MATCH (c:Customer)
   WITH c LIMIT 1000
   MATCH (p:Policy)
   WHERE c.customer_number = p.customer_number
   CREATE (c)-[:HOLDS_POLICY]->(p);
   ```

## Complete Loading Script

For convenience, here's a complete script to run all steps:

```cypher
// Step 1: Clear and prepare
MATCH (n) DETACH DELETE n;

// Step 2: Create constraints
CREATE CONSTRAINT customer_number_unique IF NOT EXISTS FOR (c:Customer) REQUIRE c.customer_number IS UNIQUE;
CREATE CONSTRAINT policy_number_unique IF NOT EXISTS FOR (p:Policy) REQUIRE p.policy_number IS UNIQUE;
CREATE CONSTRAINT claim_number_unique IF NOT EXISTS FOR (c:Claim) REQUIRE c.claim_number IS UNIQUE;
CREATE CONSTRAINT agent_id_unique IF NOT EXISTS FOR (a:Agent) REQUIRE a.agent_id IS UNIQUE;
CREATE CONSTRAINT product_code_unique IF NOT EXISTS FOR (p:Product) REQUIRE p.product_code IS UNIQUE;
CREATE CONSTRAINT branch_id_unique IF NOT EXISTS FOR (b:Branch) REQUIRE b.branch_id IS UNIQUE;

// Step 3: Load all entities (use the queries from sections 1-6 above)

// Step 4: Create all relationships (use the queries from section 7 above)

// Step 5: Verify
MATCH (n) RETURN labels(n)[0] AS label, count(n) AS count ORDER BY count DESC;
```

## Next Steps

After loading the data, you can:

1. **Create additional indexes** for query performance
2. **Add more secondary labels** for specialized queries
3. **Run graph algorithms** using GDS
4. **Create projections** for analytics
5. **Build dashboards** with Neo4j Bloom

Happy graph querying!
