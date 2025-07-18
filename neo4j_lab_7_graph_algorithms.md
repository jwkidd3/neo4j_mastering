# Neo4j Lab 7: Graph Algorithms for Insurance Analytics

## Overview
**Duration:** 45 minutes  
**Objective:** Apply centrality algorithms and community detection to identify customer influence, agent networks, and fraud patterns in insurance operations

Building on Lab 6's customer analytics, you'll now leverage the Graph Data Science library to apply advanced algorithms that reveal hidden patterns, identify influential customers, optimize agent territories, and detect potential fraud rings through network analysis.

---

## Part 1: Graph Data Science Setup and Data Verification (10 minutes)

### Step 1: Verify Graph Data Science Library
Let's confirm the Graph Data Science library is available and explore its capabilities:

```cypher
// Check available Graph Data Science algorithms
CALL gds.list() YIELD name, description
WHERE name CONTAINS "centrality" OR name CONTAINS "community" OR name CONTAINS "similarity"
RETURN name, description
ORDER BY name
LIMIT 10
```

### Step 2: Verify Current Data Structure
```cypher
// Check what node types and relationships we have from previous labs
CALL db.labels() YIELD label
RETURN label
ORDER BY label
```

```cypher
// Check relationship types
CALL db.relationshipTypes() YIELD relationshipType
RETURN relationshipType
ORDER BY relationshipType
```

### Step 3: Examine Customer Network Structure
```cypher
// Analyze the customer network we've built in previous labs
MATCH (c:Customer)
OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
OPTIONAL MATCH (a:Agent)-[:SERVICES]->(c)
OPTIONAL MATCH (c)-[:REFERRED]->(referred:Customer)
RETURN c.customer_number AS customer_id,
       c.first_name + " " + c.last_name AS customer_name,
       count(DISTINCT p) AS policies_held,
       a.first_name + " " + a.last_name AS agent_name,
       count(DISTINCT referred) AS customers_referred
ORDER BY policies_held DESC, customers_referred DESC
LIMIT 10
```

### Step 4: Create Graph Projection Based on Actual Data
```cypher
// Create a graph projection using the relationships we actually have
CALL gds.graph.project(
    'insurance-network',
    {
        Customer: {
            properties: ['lifetime_value', 'credit_score']
        },
        Agent: {
            properties: ['ytd_sales', 'customer_count']
        },
        Policy: {
            properties: ['annual_premium']
        }
    },
    {
        SERVICES: {
            orientation: 'UNDIRECTED'
        },
        HOLDS_POLICY: {
            orientation: 'UNDIRECTED'
        },
        REFERRED: {
            orientation: 'NATURAL'
        }
    }
)
YIELD graphName, nodeCount, relationshipCount
RETURN graphName, nodeCount, relationshipCount
```

---

## Part 2: Customer Influence Analysis with Centrality Algorithms (15 minutes)

### Step 5: PageRank Analysis for Customer Influence
```cypher
// Calculate PageRank to identify influential customers in the network
CALL gds.pageRank.write(
    'insurance-network',
    {
        writeProperty: 'pagerank_score',
        maxIterations: 20,
        dampingFactor: 0.85,
        nodeLabels: ['Customer']
    }
)
YIELD nodePropertiesWritten, iterations, didConverge
RETURN nodePropertiesWritten, iterations, didConverge
```

### Step 6: Analyze Customer Influence Rankings
```cypher
// Find the most influential customers based on PageRank
MATCH (c:Customer)
WHERE exists(c.pagerank_score)
OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
WITH c, sum(p.annual_premium) AS total_premium
RETURN c.first_name + " " + c.last_name AS customer_name,
       c.customer_number AS customer_id,
       round(c.pagerank_score * 10000) / 10000 AS influence_score,
       c.lifetime_value AS ltv,
       c.risk_tier AS risk_level,
       c.city AS location,
       COALESCE(total_premium, 0) AS annual_premium
ORDER BY c.pagerank_score DESC
LIMIT 10
```

### Step 7: Betweenness Centrality for Key Connectors
```cypher
// Calculate betweenness centrality to find customers who bridge different groups
CALL gds.betweenness.write(
    'insurance-network',
    {
        writeProperty: 'betweenness_score',
        nodeLabels: ['Customer']
    }
)
YIELD nodePropertiesWritten, computeMillis
RETURN nodePropertiesWritten, computeMillis
```

### Step 8: Identify Bridge Customers
```cypher
// Find customers who serve as bridges between different network segments
MATCH (c:Customer)
WHERE exists(c.betweenness_score) AND c.betweenness_score > 0
RETURN c.first_name + " " + c.last_name AS customer_name,
       c.customer_number AS customer_id,
       round(c.betweenness_score * 100) / 100 AS bridge_score,
       round(COALESCE(c.pagerank_score, 0) * 10000) / 10000 AS influence_score,
       c.risk_tier AS risk_level,
       c.city AS location
ORDER BY c.betweenness_score DESC
LIMIT 10
```

### Step 9: Agent Network Performance Analysis
```cypher
// Calculate degree centrality for agents to measure their customer connections
CALL gds.degree.write(
    'insurance-network',
    {
        writeProperty: 'network_reach',
        nodeLabels: ['Agent'],
        relationshipTypes: ['SERVICES']
    }
)
YIELD nodePropertiesWritten
RETURN nodePropertiesWritten
```

### Step 10: Analyze Agent Network Performance
```cypher
// Analyze agent network performance using centrality metrics
MATCH (agent:Agent)
WHERE exists(agent.network_reach)
OPTIONAL MATCH (agent)-[:SERVICES]->(customer:Customer)
WITH agent, 
     count(DISTINCT customer) AS actual_customers,
     sum(customer.lifetime_value) AS portfolio_value
RETURN agent.first_name + " " + agent.last_name AS agent_name,
       agent.territory AS territory,
       agent.network_reach AS network_connections,
       actual_customers AS customers_managed,
       round(COALESCE(portfolio_value, 0) * 100) / 100 AS total_portfolio_value,
       agent.performance_rating AS rating,
       round(agent.network_reach * 1.0 / GREATEST(actual_customers, 1) * 100) / 100 AS network_efficiency
ORDER BY agent.network_reach DESC
```

---

## Part 3: Community Detection for Market Segmentation (12 minutes)

### Step 11: Louvain Community Detection
```cypher
// Apply Louvain algorithm to detect customer communities
CALL gds.louvain.write(
    'insurance-network',
    {
        writeProperty: 'community_id',
        nodeLabels: ['Customer'],
        relationshipTypes: ['SERVICES', 'REFERRED'],
        includeIntermediateCommunities: false
    }
)
YIELD nodePropertiesWritten, communityCount, modularity
RETURN nodePropertiesWritten, communityCount, modularity
```

### Step 12: Analyze Customer Communities
```cypher
// Analyze the characteristics of detected communities
MATCH (c:Customer)
WHERE exists(c.community_id)
WITH c.community_id AS community,
     count(c) AS community_size,
     avg(c.lifetime_value) AS avg_ltv,
     avg(c.credit_score) AS avg_credit_score,
     collect(DISTINCT c.risk_tier) AS risk_tiers,
     collect(DISTINCT c.city) AS cities

RETURN community,
       community_size,
       round(avg_ltv * 100) / 100 AS avg_lifetime_value,
       round(avg_credit_score) AS avg_credit_score,
       risk_tiers,
       cities[0..3] AS primary_cities
ORDER BY community_size DESC
```

### Step 13: Geographic Community Analysis
```cypher
// Analyze geographic distribution within communities
MATCH (c:Customer)
WHERE exists(c.community_id)
WITH c.community_id AS community,
     c.city AS city,
     count(c) AS customers_in_city
ORDER BY community, customers_in_city DESC

WITH community,
     collect({city: city, customer_count: customers_in_city}) AS city_distribution

RETURN community,
       size(city_distribution) AS cities_in_community,
       city_distribution[0..3] AS top_cities,
       reduce(total = 0, city_data IN city_distribution | total + city_data.customer_count) AS total_customers
ORDER BY total_customers DESC
```

### Step 14: Cross-Sell Opportunities by Community
```cypher
// Identify cross-sell patterns within communities
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
WHERE exists(c.community_id)
WITH c.community_id AS community,
     c.customer_number AS customer_id,
     collect(DISTINCT p.product_type) AS customer_products,
     c.lifetime_value AS ltv

WITH community,
     count(customer_id) AS customers_in_community,
     collect(DISTINCT customer_products) AS all_products_in_community,
     avg(ltv) AS avg_community_ltv,
     size([cust IN collect({customer: customer_id, products: customer_products}) 
           WHERE size(cust.products) = 1]) AS single_product_customers

WHERE customers_in_community >= 3

RETURN community,
       customers_in_community,
       all_products_in_community[0..3] AS sample_product_combinations,
       round(avg_community_ltv * 100) / 100 AS avg_ltv,
       single_product_customers,
       round((single_product_customers * 100.0 / customers_in_community) * 10) / 10 AS cross_sell_opportunity_percent,
       CASE 
         WHEN single_product_customers * 100.0 / customers_in_community > 70 THEN "High Cross-Sell Potential"
         WHEN single_product_customers * 100.0 / customers_in_community > 50 THEN "Medium Cross-Sell Potential"
         ELSE "Low Cross-Sell Potential"
       END AS opportunity_rating
ORDER BY cross_sell_opportunity_percent DESC
```

---

## Part 4: Fraud Detection Through Network Analysis (8 minutes)

### Step 15: Create Fraud Detection Graph Projection
```cypher
// First, check what fraud-related entities we have from previous labs
MATCH (c:Claim)
OPTIONAL MATCH (c)-[:ASSIGNED_TO]->(vendor)
RETURN count(c) AS total_claims, 
       count(vendor) AS claims_with_vendors,
       collect(DISTINCT labels(vendor)[0])[0..3] AS vendor_types
```

### Step 16: Fraud Analysis Based on Available Data
```cypher
// Analyze claim patterns that might indicate fraud using available relationships
MATCH (customer:Customer)-[:FILED_CLAIM]->(claim:Claim)
OPTIONAL MATCH (claim)-[:ASSIGNED_TO]->(vendor:RepairShop)
WITH customer, vendor, 
     count(claim) AS claims_count,
     sum(claim.claim_amount) AS total_claim_amount,
     avg(claim.fraud_score) AS avg_fraud_score,
     collect(claim.incident_date) AS claim_dates

WHERE claims_count > 1 OR total_claim_amount > 10000

RETURN customer.first_name + " " + customer.last_name AS customer_name,
       COALESCE(vendor.business_name, "No Vendor") AS vendor_name,
       claims_count,
       round(total_claim_amount * 100) / 100 AS total_claims_amount,
       round(COALESCE(avg_fraud_score, 0) * 100) / 100 AS avg_fraud_score,
       CASE 
         WHEN claims_count >= 3 THEN "High Risk - Multiple Claims"
         WHEN total_claim_amount > 15000 THEN "High Risk - Large Amount"
         WHEN avg_fraud_score > 0.3 THEN "Medium Risk - Fraud Score"
         ELSE "Low Risk"
       END AS fraud_risk_assessment
ORDER BY total_claim_amount DESC, claims_count DESC
LIMIT 10
```

### Step 17: Network-Based Fraud Patterns
```cypher
// Look for shared vendors or patterns that might indicate organized fraud
MATCH (c1:Customer)-[:FILED_CLAIM]->(claim1:Claim)-[:ASSIGNED_TO]->(vendor:RepairShop)
MATCH (c2:Customer)-[:FILED_CLAIM]->(claim2:Claim)-[:ASSIGNED_TO]->(vendor)
WHERE c1 <> c2 
AND claim1.incident_date IS NOT NULL 
AND claim2.incident_date IS NOT NULL

WITH vendor,
     c1, c2, claim1, claim2,
     abs(duration.between(claim1.incident_date, claim2.incident_date).days) AS days_apart

WHERE days_apart <= 30

WITH vendor,
     count(DISTINCT [c1.customer_number, c2.customer_number]) AS customer_pairs,
     collect(DISTINCT c1.customer_number + "-" + c2.customer_number)[0..5] AS sample_pairs,
     avg(claim1.claim_amount + claim2.claim_amount) AS avg_combined_amount,
     count(*) AS suspicious_claim_pairs

WHERE customer_pairs >= 2

RETURN vendor.business_name AS vendor_name,
       vendor.vendor_id AS vendor_id,
       customer_pairs AS unique_customer_pairs,
       suspicious_claim_pairs AS claims_within_30_days,
       round(avg_combined_amount * 100) / 100 AS avg_combined_claim_amount,
       vendor.rating AS vendor_rating,
       CASE 
         WHEN customer_pairs >= 3 AND avg_combined_amount > 8000 THEN "High Fraud Risk"
         WHEN customer_pairs >= 2 AND avg_combined_amount > 5000 THEN "Medium Fraud Risk"
         ELSE "Low Fraud Risk"
       END AS fraud_risk_level
ORDER BY customer_pairs DESC, avg_combined_amount DESC
```

---

## Part 5: Algorithm Results Analysis and Business Insights (5 minutes)

### Step 18: Customer Influence and Value Correlation
```cypher
// Analyze correlation between network influence and business value
MATCH (c:Customer)
WHERE exists(c.pagerank_score) AND exists(c.betweenness_score)

WITH c,
     CASE 
       WHEN c.pagerank_score > 0.15 THEN "High Influence"
       WHEN c.pagerank_score > 0.05 THEN "Medium Influence"
       ELSE "Low Influence"
     END AS influence_category

RETURN influence_category,
       count(c) AS customer_count,
       round(avg(c.lifetime_value) * 100) / 100 AS avg_lifetime_value,
       round(avg(c.pagerank_score) * 10000) / 10000 AS avg_influence_score,
       round(avg(c.betweenness_score) * 100) / 100 AS avg_bridge_score,
       collect(DISTINCT c.risk_tier) AS risk_tiers_present
ORDER BY avg_lifetime_value DESC
```

### Step 19: Community-Based Business Insights
```cypher
// Identify business opportunities based on community analysis
MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
WHERE exists(c.community_id) AND exists(c.pagerank_score)

WITH c.community_id AS community,
     avg(c.pagerank_score) AS avg_influence,
     avg(c.lifetime_value) AS avg_ltv,
     count(DISTINCT c) AS customers_in_community,
     collect(DISTINCT p.product_type) AS products_in_community

WHERE customers_in_community >= 3

RETURN community,
       customers_in_community,
       round(avg_influence * 10000) / 10000 AS avg_influence_score,
       round(avg_ltv * 100) / 100 AS avg_lifetime_value,
       products_in_community,
       CASE 
         WHEN avg_influence > 0.1 AND avg_ltv > 10000 THEN "Premium Target Community"
         WHEN avg_influence > 0.05 AND avg_ltv > 8000 THEN "High Value Community"
         WHEN customers_in_community > 5 THEN "Large Market Segment"
         ELSE "Standard Community"
       END AS business_opportunity
ORDER BY avg_influence DESC, avg_ltv DESC
```

### Step 20: Clean Up Graph Projections
```cypher
// Clean up the graph projection to free memory
CALL gds.graph.drop('insurance-network')
YIELD graphName
RETURN "Successfully dropped graph projection: " + graphName AS cleanup_status
```

---

## Neo4j Lab 7 Summary

**🎯 What You've Accomplished:**

### **Graph Algorithm Implementation**
- ✅ **PageRank analysis** identifying the most influential customers in your insurance network
- ✅ **Betweenness centrality** revealing customers who bridge different network segments
- ✅ **Degree centrality** measuring agent network reach and connection efficiency
- ✅ **Community detection** using Louvain algorithm to discover natural customer groupings

### **Business Intelligence Through Network Analysis**
- ✅ **Customer influence scoring** correlating network position with business value
- ✅ **Agent territory optimization** using network metrics to assess coverage efficiency
- ✅ **Community-based segmentation** revealing geographic and behavioral customer clusters
- ✅ **Cross-sell opportunity analysis** identifying high-potential customer communities

### **Fraud Detection Capabilities**
- ✅ **Pattern analysis** detecting suspicious claim timing and vendor relationships
- ✅ **Network-based investigation** identifying potential organized fraud through shared vendors
- ✅ **Risk scoring enhancement** using network position to improve fraud detection accuracy
- ✅ **Investigation support** providing network-based evidence for fraud cases

### **Advanced Analytics Features**
- ✅ **Graph projections** creating specialized views for different analytical purposes
- ✅ **Multi-algorithm workflows** combining centrality measures for comprehensive analysis
- ✅ **Memory management** proper cleanup of graph projections for production environments
- ✅ **Data verification** ensuring algorithms work with actual data structure

### **Database State:** 350 nodes, 450 relationships with algorithmic insights and community structures

### **Enterprise Analytics Readiness**
- ✅ **Production-scale algorithms** handling networks with hundreds of entities efficiently
- ✅ **Business-focused insights** translating network metrics into actionable business intelligence
- ✅ **Fraud prevention** proactive identification of suspicious patterns before claims are paid
- ✅ **Marketing optimization** data-driven customer segmentation and targeting strategies

---

## Next Steps

You're now ready for **Lab 8: Performance Optimization**, where you'll:
- Implement strategic indexing for complex insurance queries
- Optimize graph algorithm performance for large datasets
- Add monitoring and caching strategies for production workloads
- Master query profiling and performance tuning techniques
- **Database Evolution:** 350 nodes → 400 nodes, 450 relationships → 500 relationships

**Congratulations!** You've successfully applied advanced graph algorithms to extract valuable business insights from your insurance network, including customer influence analysis, community detection, and fraud pattern recognition that drive strategic decision-making and operational efficiency.

## Troubleshooting

### If Graph Data Science procedures are not available:
- Verify plugin installation: `CALL gds.list() YIELD name RETURN count(name)`
- Check Docker logs: `docker logs neo4j`
- Restart container: `docker restart neo4j`

### If graph projections fail:
- Check available memory: Add `-e NEO4J_dbms_memory_heap_max__size=2G` to Docker run
- Verify node labels exist: `CALL db.labels()`
- Start with smaller projections using nodeLabels filter

### If algorithm results seem unexpected:
- Check data connectivity: `MATCH (n)-[r]-(m) RETURN type(r), count(*) ORDER BY count(*) DESC`
- Verify sufficient relationships exist for meaningful analysis
- Consider the network size - small networks may have different patterns than expected