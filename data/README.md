# Neo4j Insurance Dataset - CSV Files

This directory contains sample insurance data in CSV format for bulk loading into Neo4j.

## Files Included

| File | Records | Description |
|------|---------|-------------|
| `customers.csv` | 20 | Customer demographics, risk profiles, and contact information |
| `policies.csv` | 30 | Auto and Property insurance policies with coverage details |
| `claims.csv` | 18 | Insurance claims with settlement history and status |
| `agents.csv` | 10 | Insurance agents with performance metrics and territories |
| `products.csv` | 8 | Insurance product offerings (Auto, Property, Condo, Umbrella) |
| `branches.csv` | 5 | Branch office locations across Texas |

## Data Model

```
Customer --[HOLDS_POLICY]--> Policy --[BASED_ON]--> Product
                                |
                                +--> [HAS_CLAIM] --> Claim

Agent --[MANAGES]--> Customer
Agent --[WORKS_AT]--> Branch
```

## Quick Start

1. **Copy CSV files to Neo4j import directory:**
   ```bash
   # For Docker
   docker cp data/*.csv neo4j:/var/lib/neo4j/import/

   # For local installation
   cp data/*.csv /var/lib/neo4j/import/
   ```

2. **Load data using the complete guide:**
   See `BULK_LOAD_GUIDE.md` for detailed step-by-step instructions.

3. **Quick load (all-in-one script):**
   ```cypher
   // See BULK_LOAD_GUIDE.md section "Complete Loading Script"
   ```

## Data Characteristics

- **Geographic Coverage**: Austin, Dallas, Houston (Texas)
- **Policy Types**: Auto Insurance, Property Insurance
- **Date Range**: 2017-2025
- **Customer Risk Tiers**: Preferred, Standard
- **Claim Statuses**: Open, In Review, Settled
- **Agent Performance**: Excellent, Very Good, Good

## Relationships

- Each customer can have multiple policies (1:N)
- Each policy is based on one product (N:1)
- Each policy can have multiple claims (1:N)
- Each agent manages multiple customers (1:N)
- Each agent works at one branch (N:1)

## Sample Queries

After loading the data:

```cypher
// Find high-value customers
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
WHERE c.risk_tier = 'Preferred'
RETURN c.first_name, c.last_name, sum(p.annual_premium) AS total_premium
ORDER BY total_premium DESC
LIMIT 10;

// Analyze claims by policy type
MATCH (p:Policy)-[:HAS_CLAIM]->(c:Claim)
RETURN p.product_type,
       count(c) AS claim_count,
       avg(c.claim_amount) AS avg_claim_amount
ORDER BY claim_count DESC;

// Top performing agents
MATCH (a:Agent)-[:MANAGES]->(c:Customer)-[:HOLDS_POLICY]->(p:Policy)
RETURN a.first_name + ' ' + a.last_name AS agent,
       count(DISTINCT c) AS customers,
       count(p) AS policies,
       sum(p.annual_premium) AS total_premium
ORDER BY total_premium DESC;
```

## Usage in Labs

These CSV files support:
- Lab 4: Bulk Data Import
- Lab 5: Advanced Cypher Queries
- Lab 6: Data Quality & Validation
- Lab 7: Graph Algorithms

## Data Quality

All CSV files include:
- ✅ Header row with column names
- ✅ Consistent data types
- ✅ Valid foreign key references
- ✅ Realistic business data
- ✅ Complete fields (no missing required data)

## License

This is sample data for educational purposes only.
