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

## Data Files and Lab Mapping

### CSV Files (for Bulk Import)
All 6 CSV files are primarily used in **Lab 4: Bulk Data Import & Quality Control**:
- `customers.csv` - Customer demographics and risk profiles (20 records)
- `policies.csv` - Auto and Property insurance policies (30 records)
- `claims.csv` - Insurance claims with settlement history (18 records)
- `agents.csv` - Insurance agents with performance metrics (10 records)
- `products.csv` - Insurance product offerings (8 records)
- `branches.csv` - Branch office locations (5 records)

See `BULK_LOAD_GUIDE.md` for step-by-step CSV loading instructions.

### Data Reload Scripts (Cumulative Lab Data)
Data reload scripts are **cumulative** - each script includes all previous lab data plus new additions:

| Script | Lab(s) Covered | Purpose | New Data Added |
|--------|----------------|---------|----------------|
| `lab_01_data_reload.cypher` | Lab 1 | Enterprise Setup & Docker Connection | Foundation: Customers, Agents, Products, Policies, Basic Relationships |
| `lab_02_data_reload.cypher` | Labs 1-2 | Cypher Query Fundamentals | + Organizational Structure, Departments, Branch Hierarchy |
| `lab_03_data_reload.cypher` | Labs 1-3 | Claims Processing & Financial Modeling | + Assets, Claims, Vendors, Financial Transactions, Payment History |
| `lab_04_data_reload.cypher` | Labs 1-4 | Bulk Data Import & Quality Control | + Constraints, Indexes, Bulk Customer/Policy Data, Additional Agents |
| `lab_05_data_reload.cypher` | Labs 1-5 | Advanced Analytics Foundation | + Analytics Foundation, Risk Assessments, KPIs, Metrics |
| `lab_06_data_reload.cypher` | Labs 1-6 | Customer Intelligence & Segmentation | + Customer Profiles, Behavioral Analytics, Segmentation Data |
| `lab_07_data_reload.cypher`* | Lab 15 | Multi-Line Insurance Platform | + Life Insurance, Commercial Insurance, Specialty Products, Reinsurance |

**Note:** `lab_07_data_reload.cypher` is named this way for historical reasons but actually contains data for Lab 15 (Multi-Line Insurance Platform). Labs 7-14 work with the data from Labs 1-6 without requiring new data reload scripts.

### Labs Without Dedicated Reload Scripts
The following labs work with existing data (Labs 1-6) and don't require new data:
- **Lab 7:** Performance Optimization - Optimizes existing data with indexes and query tuning
- **Lab 8:** Advanced Fraud Detection - Analyzes existing claims and transactions
- **Lab 9:** Enterprise Compliance & Audit - Monitors existing data
- **Lab 10:** Predictive Analytics & Machine Learning - Analyzes existing patterns
- **Lab 11:** Python Driver & Service Architecture - Uses existing database
- **Lab 12:** Production Insurance API - Accesses existing data via API
- **Lab 13:** Interactive Insurance Web Application - Visualizes existing data
- **Lab 14:** Production Deployment - Deploys existing infrastructure
- **Lab 15:** Multi-Line Insurance Platform - Uses `lab_07_data_reload.cypher`

## Quick Reference: Which Data File to Load?

**Starting a specific lab from scratch?** Use this guide:

- **Lab 1:** Run `lab_01_data_reload.cypher`
- **Lab 2:** Run `lab_02_data_reload.cypher` (includes Lab 1 data)
- **Lab 3:** Run `lab_03_data_reload.cypher` (includes Labs 1-2 data)
- **Lab 4:** Run `lab_04_data_reload.cypher` + Load CSV files using `BULK_LOAD_GUIDE.md`
- **Lab 5:** Run `lab_05_data_reload.cypher` (includes Labs 1-4 data)
- **Lab 6:** Run `lab_06_data_reload.cypher` (includes Labs 1-5 data)
- **Labs 7-14:** Run `lab_06_data_reload.cypher` (Labs 7-14 work with Labs 1-6 data)
- **Lab 15:** Run `lab_07_data_reload.cypher` (includes Labs 1-14 data + multi-line insurance)

**Pro Tip:** To jump directly to any lab, simply run that lab's reload script. It includes all prerequisite data from previous labs.

---

## Data Quality

All CSV files include:
- ✅ Header row with column names
- ✅ Consistent data types
- ✅ Valid foreign key references
- ✅ Realistic business data
- ✅ Complete fields (no missing required data)

## License

This is sample data for educational purposes only.
