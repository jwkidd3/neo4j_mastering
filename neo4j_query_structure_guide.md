# Neo4j Cypher Query Structure - Reference Guide

## Table of Contents
1. [Core Query Structure](#core-query-structure)
2. [Essential Components](#essential-components)
3. [Node and Relationship Syntax](#node-and-relationship-syntax)
4. [Query Types](#query-types)
5. [Common Clauses](#common-clauses)
6. [Query Patterns](#query-patterns)
7. [Practical Examples](#practical-examples)
8. [Best Practices](#best-practices)

## Core Query Structure

### Basic Pattern
```cypher
MATCH (pattern)
WHERE conditions
RETURN results
```

### Memory Aid: "MWR"
- **M**ATCH what you want to find
- **W**HERE to filter it (optional)
- **R**ETURN what you need

## Essential Components

### 1. MATCH - Finding Data
```cypher
MATCH (variable:Label {property: 'value'})
```

### 2. WHERE - Filtering (Optional)
```cypher
WHERE variable.property > 100
```

### 3. RETURN - Returning Results
```cypher
RETURN variable.property
```

### Complete Basic Example
```cypher
MATCH (u:User)
WHERE u.age > 25
RETURN u.name, u.email
```

## Node and Relationship Syntax

### Node Patterns

```cypher
// Basic node
(n)

// Node with label
(n:Person)

// Node with properties
(n:Person {name: 'Alice'})

// Node with variable and multiple labels
(alice:Person:Employee {name: 'Alice'})
```

### Relationship Patterns

```cypher
// Any relationship (undirected)
-[r]-

// Directed relationship
-[r]->

// Relationship with type
-[r:FOLLOWS]->

// Relationship with properties
-[r:FOLLOWS {since: '2020'}]->

// Variable length relationships
-[r:FOLLOWS*1..3]->

// Multiple relationship types
-[r:FOLLOWS|LIKES]->
```

### Property Access

```cypher
// Dot notation
user.name

// Bracket notation (for dynamic properties)
user['name']

// All properties
properties(user)

// Check if property exists
EXISTS(user.email)
```

## Query Types

### Read Queries

```cypher
// Simple node query
MATCH (u:User)
RETURN u

// Relationship query
MATCH (a:User)-[r:FOLLOWS]->(b:User)
RETURN a.name, b.name, r.since

// Path query
MATCH path = (a:User)-[:FOLLOWS*1..3]->(b:User)
WHERE a.name = 'Alice'
RETURN path

// Aggregation query
MATCH (u:User)
RETURN count(u) AS total_users
```

### Write Queries

```cypher
// Create nodes
CREATE (u:User {name: 'Alice', age: 30})

// Create relationships
MATCH (a:User {name: 'Alice'}), (b:User {name: 'Bob'})
CREATE (a)-[:FOLLOWS {since: date()}]->(b)

// Update properties
MATCH (u:User {name: 'Alice'})
SET u.age = 31

// Delete nodes and relationships
MATCH (u:User {name: 'Alice'})
DETACH DELETE u
```

### Merge Operations (Upsert)

```cypher
// Create or update
MERGE (u:User {email: 'alice@example.com'})
ON CREATE SET u.name = 'Alice', u.created = timestamp()
ON MATCH SET u.lastLogin = timestamp()

// Merge relationships
MATCH (a:User {name: 'Alice'}), (b:User {name: 'Bob'})
MERGE (a)-[r:FOLLOWS]->(b)
ON CREATE SET r.since = date()
```

## Common Clauses

### WITH - Passing Results Forward
```cypher
MATCH (u:User)
WITH u, count(*) AS user_count
WHERE user_count > 5
RETURN u.name
```

### ORDER BY - Sorting Results
```cypher
MATCH (u:User)
RETURN u.name, u.age
ORDER BY u.age DESC, u.name ASC
```

### LIMIT and SKIP - Pagination
```cypher
MATCH (u:User)
RETURN u
ORDER BY u.name
SKIP 10
LIMIT 5
```

### OPTIONAL MATCH - Nullable Patterns
```cypher
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
RETURN u.name, count(p) AS post_count
```

### UNION - Combining Results
```cypher
MATCH (u:User)
RETURN u.name AS name, 'User' AS type

UNION

MATCH (c:Company)
RETURN c.name AS name, 'Company' AS type
```

### UNWIND - Expanding Lists
```cypher
WITH ['Alice', 'Bob', 'Carol'] AS names
UNWIND names AS name
CREATE (:User {name: name})
```

## Query Patterns

### Simple Pattern
```cypher
MATCH (pattern)
RETURN results
```

### Filtered Pattern
```cypher
MATCH (pattern)
WHERE conditions
RETURN results
ORDER BY field
LIMIT number
```

### Complex Multi-Step Pattern
```cypher
MATCH (initial_pattern)
WHERE initial_conditions
WITH variables
MATCH (additional_pattern)
WHERE additional_conditions
OPTIONAL MATCH (optional_pattern)
WITH processed_variables
RETURN final_results
ORDER BY sorting_criteria
LIMIT result_count
```

### Aggregation Pattern
```cypher
MATCH (pattern)
WHERE conditions
WITH grouping_variables, aggregation_function(variable) AS result
RETURN grouping_variables, result
ORDER BY result DESC
```

## Practical Examples

### Social Network Queries

#### Find User's Posts
```cypher
MATCH (u:User {name: 'Alice'})-[:POSTED]->(p:Post)
RETURN p.title, p.content, p.created
ORDER BY p.created DESC
```

#### Mutual Friends
```cypher
MATCH (me:User {name: 'Alice'})-[:FOLLOWS]->(friend:User)
MATCH (me)-[:FOLLOWS]->(mutual:User)<-[:FOLLOWS]-(friend)
WHERE mutual <> me AND mutual <> friend
RETURN friend.name AS friend,
       collect(mutual.name) AS mutual_friends
```

#### Friend Recommendations
```cypher
MATCH (me:User {name: 'Alice'})
MATCH (me)-[:FOLLOWS]->(friend)-[:FOLLOWS]->(recommendation)
WHERE NOT (me)-[:FOLLOWS]->(recommendation) 
  AND recommendation <> me
RETURN recommendation.name AS suggested_user,
       count(*) AS mutual_connections
ORDER BY mutual_connections DESC
LIMIT 5
```

### Analytics Queries

#### User Engagement Statistics
```cypher
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(posts:Post)
OPTIONAL MATCH (u)-[:LIKES]->(liked:Post)
RETURN u.name AS user,
       count(DISTINCT posts) AS posts_created,
       count(DISTINCT liked) AS posts_liked,
       COALESCE(u.followerCount, 0) AS followers
ORDER BY posts_created DESC
```

#### Popular Content
```cypher
MATCH (p:Post)<-[l:LIKES]-(u:User)
RETURN p.title AS post_title,
       p.author AS author,
       count(l) AS like_count,
       collect(u.name)[0..5] AS sample_likers
ORDER BY like_count DESC
LIMIT 10
```

#### Network Analysis
```cypher
MATCH (u:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(followers:User)
RETURN u.name AS user,
       count(DISTINCT following) AS following_count,
       count(DISTINCT followers) AS follower_count,
       CASE 
         WHEN count(DISTINCT followers) > count(DISTINCT following) 
         THEN 'Influencer'
         ELSE 'Regular User'
       END AS user_type
ORDER BY follower_count DESC
```

## Best Practices

### Query Structure Guidelines

1. **Start with MATCH** - Always begin by matching the pattern you need
2. **Filter early with WHERE** - Apply filters as early as possible
3. **Use WITH strategically** - Break complex queries into manageable steps
4. **Order matters** - Place expensive operations (like aggregations) after filtering
5. **Limit results** - Always use LIMIT for potentially large result sets

### Performance Tips

```cypher
// Good: Filter early
MATCH (u:User {status: 'active'})
WHERE u.age > 25
RETURN u.name

// Better: Use indexes
MATCH (u:User)
WHERE u.email = 'alice@example.com'  // Assumes index on email
RETURN u

// Best: Strategic WITH usage
MATCH (u:User)
WHERE u.active = true
WITH u
LIMIT 100
MATCH (u)-[:POSTED]->(p:Post)
RETURN u.name, count(p)
```

### Readability Guidelines

```cypher
// Use descriptive variable names
MATCH (author:User)-[:WROTE]->(article:Post)
WHERE article.published = true
RETURN author.name, article.title

// Break complex queries with WITH
MATCH (u:User)
WHERE u.active = true
WITH u, u.followerCount AS followers
WHERE followers > 1000
MATCH (u)-[:POSTED]->(p:Post)
RETURN u.name, count(p) AS total_posts
ORDER BY total_posts DESC
```

### Common Patterns to Remember

#### Pattern Matching
```cypher
// Single hop
(a)-[:REL]->(b)

// Multi-hop
(a)-[:REL*1..3]->(b)

// Variable length with different types
(a)-[:FOLLOWS|LIKES*]->(b)
```

#### Conditional Logic
```cypher
// CASE expressions
CASE 
  WHEN condition1 THEN result1
  WHEN condition2 THEN result2
  ELSE default_result
END

// COALESCE for null handling
COALESCE(u.nickname, u.firstName, 'Unknown')
```

#### Collections and Aggregations
```cypher
// Collect results
collect(u.name) AS names

// Aggregate functions
count(u), avg(u.age), sum(u.score), max(u.created)

// List operations
size(collection), head(collection), tail(collection)
```

## Syntax Rules Summary

### Required Elements
- Every query must end with **RETURN**, **CREATE**, **SET**, **DELETE**, or another terminating clause
- Variables are **case-sensitive**
- Labels conventionally start with **capital letters**
- Properties are enclosed in **curly braces { }**

### Optional Elements
- **WHERE** clauses for filtering
- **ORDER BY** for sorting
- **LIMIT** for result size control
- **WITH** for intermediate processing

### Reserved Keywords
```
MATCH, WHERE, RETURN, CREATE, SET, DELETE, MERGE, UNION, WITH, 
ORDER BY, LIMIT, SKIP, OPTIONAL MATCH, CASE, WHEN, THEN, ELSE, END
```

---

## Quick Reference Card

| Component | Syntax | Purpose |
|-----------|--------|---------|
| Node | `(n:Label {prop: 'value'})` | Match/create nodes |
| Relationship | `-[r:TYPE]->` | Match/create relationships |
| Property | `node.property` | Access node/relationship properties |
| Filter | `WHERE condition` | Filter results |
| Return | `RETURN expression` | Specify output |
| Create | `CREATE (pattern)` | Create new data |
| Update | `SET node.prop = value` | Modify existing data |
| Delete | `DELETE node` | Remove data |

**Remember: Start simple, build complexity gradually, and always test your patterns!**