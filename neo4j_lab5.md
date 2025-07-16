# Lab 5: Variable-Length Paths & Complex Queries

**Duration:** 75 minutes  
**Objective:** Master advanced Cypher patterns, variable-length path traversals, and query optimization techniques

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop** (connection client)
- **Docker Desktop** with Neo4j Enterprise 2025.06.0 running (container name: neo4j)
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

✅ **From Previous Labs:**
- **Completed Labs 1-4** successfully with full social network data
- **"Social" database** created and populated from Lab 3
- **Understanding of Cypher** query language and complex patterns
- **Remote connection** set up to Docker Neo4j Enterprise instance
- **Familiarity with Neo4j Browser** interface and visualization

## Learning Outcomes

By the end of this lab, you will:
- Implement variable-length path traversals for complex network analysis
- Find shortest paths between users across multiple relationship types
- Create advanced recommendation systems using multi-hop patterns
- Build influence propagation models with decay factors
- Practice query performance optimization and profiling techniques
- Develop sophisticated friend-of-friend discovery algorithms
- Analyze network connectivity patterns and path diversity
- Master complex WHERE clause filtering on variable-length paths

## Part 1: Environment Setup and Variable-Length Path Fundamentals (15 minutes)

### Step 1: Connect to Social Database and Verify Data
First, ensure your Docker Neo4j instance is running and connect to the social database:

```cypher
// Switch to social database created in Lab 3
:use social
```

```cypher
// Check network structure and completeness
MATCH (u:User) 
RETURN count(u) AS total_users,
       count(DISTINCT u.location) AS unique_locations
```

```cypher
MATCH ()-[r:FOLLOWS]->() 
RETURN count(r) AS follow_relationships
```

```cypher
MATCH ()-[r:LIKES]->() 
RETURN count(r) AS like_relationships
```

```cypher
MATCH (t:Topic) 
RETURN count(t) AS total_topics
```

```cypher
MATCH (p:Post)
RETURN count(p) AS total_posts
```

**Expected Results:** 6 users, 8+ follows, 6+ likes, 8 topics, 6+ posts

### Step 2: Review Network Structure from Lab 3
```cypher
// Display user network with usernames for reference
MATCH (u:User)
RETURN u.username AS username, 
       u.fullName AS full_name,
       u.location AS location,
       u.followerCount AS followers
ORDER BY followers DESC
```

### Step 3: Basic Variable-Length Path Syntax
```cypher
// Basic variable-length path - explore unlimited depth carefully
MATCH path = (alice:User {username: 'alice_codes'})-[:FOLLOWS*1..3]->(connected:User)
RETURN connected.username AS reachable_user, 
       length(path) AS hops_away,
       [node IN nodes(path) | node.username] AS path_through_users
ORDER BY hops_away, reachable_user
```

### Step 4: Bidirectional Variable Paths
```cypher
// Find users connected in either direction (undirected search)
MATCH path = (alice:User {username: 'alice_codes'})-[:FOLLOWS*1..2]-(connected:User)
WHERE alice <> connected
RETURN DISTINCT connected.username AS connected_user,
       min(length(path)) AS shortest_distance,
       collect(DISTINCT [node IN nodes(path) | node.username]) AS all_paths
ORDER BY shortest_distance, connected_user
```

### Step 5: Multiple Relationship Types in Variable Paths
```cypher
// Navigate through different types of relationships
MATCH path = (alice:User {username: 'alice_codes'})-[:FOLLOWS|LIKES*1..3]->(target)
WHERE target:User OR target:Post
RETURN labels(target) AS target_type,
       CASE 
         WHEN target:User THEN target.username 
         WHEN target:Post THEN target.postId 
         ELSE 'Unknown'
       END AS identifier,
       length(path) AS distance,
       [rel IN relationships(path) | type(rel)] AS relationship_types
ORDER BY distance, target_type
LIMIT 12
```

### Step 6: Variable Paths with Property Filtering
```cypher
// Filter paths based on node and relationship properties
MATCH path = (start:User)-[:FOLLOWS*1..3]->(end:User)
WHERE start <> end
RETURN COALESCE(start.username, start.userId) AS start_user,
       COALESCE(end.username, end.userId) AS end_user,
       length(path) AS hops,
       [node IN nodes(path) | COALESCE(node.username, node.userId)] AS path_users
ORDER BY hops, start_user
LIMIT 10
```

## Part 2: Shortest Path Algorithms (15 minutes)

### Step 7: Single Shortest Path Analysis
```cypher
// Find the shortest path between two specific users
MATCH (user1:User)-[:FOLLOWS*]->(user2:User)
WHERE user1 <> user2
WITH user1, user2
LIMIT 1

MATCH path = shortestPath((user1)-[:FOLLOWS*]-(user2))
RETURN COALESCE(user1.username, user1.userId, user1.fullName) AS user1_id,
       COALESCE(user2.username, user2.userId, user2.fullName) AS user2_id,
       length(path) AS distance,
       [node IN nodes(path) | COALESCE(node.username, node.userId, node.fullName)] AS users_in_path,
       [rel IN relationships(path) | type(rel)] AS relationship_types
```

### Step 8: All Shortest Paths Discovery
```cypher
// Find all shortest paths between users (multiple equivalent routes)
MATCH (alice:User {username: 'alice_codes'}), (carol:User {username: 'carol_creates'})
MATCH paths = allShortestPaths((alice)-[:FOLLOWS*]-(carol))
WITH paths, length(paths) AS distance
RETURN distance,
       count(paths) AS number_of_shortest_paths,
       collect([node IN nodes(paths) | node.username]) AS all_path_routes
```

### Step 9: Constrained Shortest Paths
```cypher
// Find shortest paths with specific constraints
MATCH (alice:User {username: 'alice_codes'}), (target:User)
WHERE target <> alice
MATCH path = shortestPath((alice)-[:FOLLOWS*]-(target))
WHERE ALL(rel IN relationships(path) WHERE 
  rel.notificationsEnabled = true OR rel.relationship IN ['friend', 'close']
)
RETURN target.username AS reachable_user,
       length(path) AS distance,
       [rel IN relationships(path) | rel.relationship] AS connection_quality,
       [node IN nodes(path) | node.username] AS path_users
ORDER BY distance, reachable_user
```

### Step 10: Shortest Path with Interest Alignment
```cypher
// Find paths through users with shared interests
MATCH (alice:User {username: 'alice_codes'}), (target:User)
WHERE target <> alice
MATCH path = shortestPath((alice)-[:FOLLOWS*]-(target))
WHERE ANY(middle IN nodes(path)[1..-1] WHERE 
  EXISTS((middle)-[:INTERESTED_IN]->(:Topic)<-[:INTERESTED_IN]-(alice))
)
RETURN target.username AS reachable_through_interests,
       length(path) AS distance,
       [node IN nodes(path) | node.username] AS shared_interest_path,
       // Find shared interests in path
       [middle IN nodes(path)[1..-1] WHERE 
         EXISTS((middle)-[:INTERESTED_IN]->(:Topic)<-[:INTERESTED_IN]-(alice))
       | middle.username] AS users_with_shared_interests
ORDER BY distance
LIMIT 8
```

## Part 3: Advanced Recommendation Systems (20 minutes)

### Step 11: Basic Friend Recommendations - Data Exploration
```cypher
// First, let's see who Alice currently follows
MATCH (alice:User {username: 'alice_codes'})-[:FOLLOWS]->(following:User)
RETURN alice.username AS alice, 
       following.username AS alice_follows
ORDER BY following.username
```

### Step 12: Find Potential Recommendations
```cypher
// Find users Alice doesn't follow (potential recommendations)
MATCH (alice:User {username: 'alice_codes'})
MATCH (potential:User)
WHERE alice <> potential 
  AND NOT (alice)-[:FOLLOWS]->(potential)
RETURN potential.username AS not_following,
       potential.fullName AS full_name,
       potential.location AS location
ORDER BY potential.username
```

### Step 13: Calculate Mutual Connections
```cypher
// Find mutual connections for each potential friend
MATCH (alice:User {username: 'alice_codes'})
MATCH (potential:User)
WHERE alice <> potential 
  AND NOT (alice)-[:FOLLOWS]->(potential)

OPTIONAL MATCH (alice)-[:FOLLOWS]->(mutual:User)<-[:FOLLOWS]-(potential)
WITH potential, collect(DISTINCT mutual.username) AS mutual_friends

RETURN potential.username AS recommendation,
       potential.fullName AS full_name,
       size(mutual_friends) AS mutual_count,
       mutual_friends
ORDER BY mutual_count DESC, recommendation
```

### Step 14: Add Interest-Based Scoring
```cypher
// Complete recommendation system with mutual friends and shared interests
MATCH (alice:User {username: 'alice_codes'})
MATCH (potential:User)
WHERE alice <> potential 
  AND NOT (alice)-[:FOLLOWS]->(potential)

// Find mutual connections
OPTIONAL MATCH (alice)-[:FOLLOWS]->(mutual:User)<-[:FOLLOWS]-(potential)
WITH potential, count(DISTINCT mutual) AS mutual_connections

// Find shared interests
OPTIONAL MATCH (alice)-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(potential)
WITH potential, mutual_connections, count(DISTINCT topic) AS shared_interests

// Calculate recommendation score
WITH potential, mutual_connections, shared_interests,
     (mutual_connections * 2) + shared_interests AS recommendation_score

RETURN potential.username AS recommendation,
       potential.fullName AS full_name,
       potential.location AS location,
       mutual_connections,
       shared_interests,
       recommendation_score,
       CASE 
         WHEN recommendation_score >= 3 THEN 'Highly Recommended'
         WHEN recommendation_score >= 1 THEN 'Recommended'
         ELSE 'Consider'
       END AS recommendation_level
ORDER BY recommendation_score DESC, potential.username
```

### Step 15: Content-Based Discovery Engine
```cypher
// First, check what topics Alice is interested in
MATCH (alice:User {username: 'alice_codes'})-[:INTERESTED_IN]->(topic:Topic)
RETURN alice.username AS user, topic.name AS interests
ORDER BY topic.name
```

```cypher
// Find posts by people Alice follows that match her interests
MATCH (alice:User {username: 'alice_codes'})-[:INTERESTED_IN]->(alice_topic:Topic)
MATCH (alice)-[:FOLLOWS]->(followed:User)-[:POSTED]->(post:Post)-[:TAGGED_WITH]->(post_topic:Topic)
WHERE alice_topic = post_topic

RETURN post.postId AS recommended_post,
       post.content AS content_preview,
       followed.username AS posted_by,
       post_topic.name AS matching_topic,
       post.likes AS likes_count,
       'Direct Interest Match' AS recommendation_reason
ORDER BY post.likes DESC
LIMIT 5
```

```cypher
// Alternative: Find popular posts from Alice's network regardless of topic matching
MATCH (alice:User {username: 'alice_codes'})-[:FOLLOWS*1..2]->(connected:User)-[:POSTED]->(post:Post)
WITH post, connected, 
     post.likes AS engagement_score,
     CASE WHEN (alice)-[:FOLLOWS]->(connected) THEN 'Direct Connection' ELSE 'Friend of Friend' END AS connection_type

RETURN post.postId AS recommended_post,
       post.content AS content_preview,
       connected.username AS posted_by,
       post.likes AS likes_count,
       connection_type,
       engagement_score AS relevance_score
ORDER BY engagement_score DESC
LIMIT 8
```

### Step 16: Interest Expansion Recommendations
```cypher
// First, see what Alice is currently interested in
MATCH (alice:User {username: 'alice_codes'})-[:INTERESTED_IN]->(alice_topics:Topic)
RETURN alice.username AS user, 
       collect(alice_topics.name) AS current_interests
```

```cypher
// Find new topics that Alice's network is interested in
MATCH (alice:User {username: 'alice_codes'})-[:INTERESTED_IN]->(alice_topics:Topic)
WITH alice, collect(alice_topics.name) AS current_interests

MATCH (alice)-[:FOLLOWS*1..2]->(connected:User)-[:INTERESTED_IN]->(new_topic:Topic)
WHERE NOT new_topic.name IN current_interests

RETURN new_topic.name AS recommended_topic,
       new_topic.description AS topic_description,
       count(DISTINCT connected) AS connections_interested,
       collect(DISTINCT connected.username) AS interested_users,
       'Network Interest' AS recommendation_reason
ORDER BY connections_interested DESC
LIMIT 8
```

```cypher
// Alternative: Find topics from popular posts in Alice's network
MATCH (alice:User {username: 'alice_codes'})-[:INTERESTED_IN]->(alice_topics:Topic)
WITH alice, collect(alice_topics.name) AS current_interests

MATCH (alice)-[:FOLLOWS]->(followed:User)-[:POSTED]->(post:Post)-[:TAGGED_WITH]->(topic:Topic)
WHERE NOT topic.name IN current_interests

WITH topic, avg(post.likes) AS avg_engagement, count(post) AS post_count
WHERE post_count >= 1

RETURN topic.name AS recommended_topic,
       topic.description AS topic_description,
       post_count AS posts_about_topic,
       round(avg_engagement) AS avg_likes_per_post,
       'Popular Content' AS recommendation_reason
ORDER BY avg_engagement DESC, post_count DESC
LIMIT 6
```

## Part 4: Influence Propagation and Network Analysis (15 minutes)

### Step 17: Viral Content Propagation Model
```cypher
// First, let's see what posts exist in our network
MATCH (p:Post)
RETURN p.postId AS available_posts, p.content AS content_preview, p.likes AS likes
ORDER BY p.likes DESC
LIMIT 5
```

```cypher
// WORKING VERSION - Simple influence model without posts
MATCH (influencer:User)
OPTIONAL MATCH (influencer)-[:FOLLOWS*1..2]->(potential_viewer:User)
WHERE potential_viewer IS NOT NULL AND influencer <> potential_viewer

// Calculate influence based on network position
OPTIONAL MATCH (influencer)<-[:FOLLOWS]-(followers:User)
OPTIONAL MATCH (potential_viewer)-[:FOLLOWS]->(following:User)

WITH influencer, potential_viewer,
     count(DISTINCT followers) AS influencer_followers,
     count(DISTINCT following) AS viewer_activity,
     length(shortestPath((influencer)-[:FOLLOWS*]-(potential_viewer))) AS distance

WHERE distance IS NOT NULL

// Simple influence calculation
WITH influencer, potential_viewer, distance, influencer_followers, viewer_activity,
     (COALESCE(influencer_followers, 0) * 0.1) + (1.0 / distance) + (viewer_activity * 0.05) AS influence_score

RETURN COALESCE(influencer.username, influencer.userId) AS influencer,
       COALESCE(potential_viewer.username, potential_viewer.userId) AS potential_viewer,
       distance AS degrees_separation,
       influencer_followers AS influencer_reach,
       viewer_activity AS viewer_connections,
       round(influence_score * 100) / 100 AS influence_probability,
       CASE 
         WHEN influence_score >= 2 THEN 'High Influence'
         WHEN influence_score >= 1 THEN 'Medium Influence'
         ELSE 'Low Influence'
       END AS influence_level
ORDER BY influence_score DESC
LIMIT 10
```

### Step 18: Network Diameter and Eccentricity Analysis
```cypher
// Calculate network diameter and user eccentricity (longest shortest path)
MATCH (a:User), (b:User)
WHERE a <> b
MATCH path = shortestPath((a)-[:FOLLOWS*]-(b))
WITH a, max(length(path)) AS eccentricity
WHERE eccentricity IS NOT NULL

RETURN a.username AS user,
       eccentricity,
       CASE 
         WHEN eccentricity <= 2 THEN 'Central'
         WHEN eccentricity <= 3 THEN 'Semi-Central'
         WHEN eccentricity <= 4 THEN 'Peripheral'
         ELSE 'Remote'
       END AS network_position
ORDER BY eccentricity DESC
```

### Step 19: Bridge Detection and Network Vulnerability
```cypher
// Find users who appear frequently on shortest paths (bridge nodes)
MATCH (a:User), (b:User)
WHERE a <> b AND id(a) < id(b)
MATCH path = shortestPath((a)-[:FOLLOWS*]-(b))
WITH nodes(path) AS path_nodes
UNWIND path_nodes AS node
WITH node, count(*) AS times_on_shortest_paths
WHERE node:User AND times_on_shortest_paths > 1

// Calculate bridge importance
MATCH (total_users:User)
WITH node, times_on_shortest_paths, count(total_users) AS total_user_count
WITH node, times_on_shortest_paths,
     round(times_on_shortest_paths * 100.0 / (total_user_count * (total_user_count - 1) / 2)) AS bridge_percentage

RETURN node.username AS potential_bridge,
       node.fullName AS full_name,
       node.followerCount AS followers,
       times_on_shortest_paths AS betweenness_approximation,
       bridge_percentage,
       CASE 
         WHEN bridge_percentage > 20 THEN 'Critical Bridge'
         WHEN bridge_percentage > 10 THEN 'Important Bridge'
         WHEN bridge_percentage > 5 THEN 'Minor Bridge'
         ELSE 'Not a Bridge'
       END AS bridge_importance
ORDER BY times_on_shortest_paths DESC
LIMIT 6
```

### Step 20: Network Reachability and Influence Radius
```cypher
// Analyze each user's reachability and influence radius
MATCH (user:User)
OPTIONAL MATCH (user)-[:FOLLOWS*1..1]->(direct:User)
OPTIONAL MATCH (user)-[:FOLLOWS*2..2]->(second_degree:User)
OPTIONAL MATCH (user)-[:FOLLOWS*3..3]->(third_degree:User)
OPTIONAL MATCH (user)-[:FOLLOWS*4..5]->(extended:User)

WITH user,
     count(DISTINCT direct) AS direct_connections,
     count(DISTINCT second_degree) AS second_degree_connections,
     count(DISTINCT third_degree) AS third_degree_connections,
     count(DISTINCT extended) AS extended_connections

MATCH (total_users:User)
WITH user, direct_connections, second_degree_connections, third_degree_connections, extended_connections,
     count(total_users) - 1 AS total_other_users,
     direct_connections + second_degree_connections + third_degree_connections + extended_connections AS total_reachable

RETURN user.username AS user,
       direct_connections,
       second_degree_connections,
       third_degree_connections,
       extended_connections,
       total_reachable,
       total_other_users,
       round(total_reachable * 100.0 / total_other_users) AS reachability_percentage,
       CASE 
         WHEN total_reachable = total_other_users THEN 'Full Network Reach'
         WHEN total_reachable > total_other_users * 0.8 THEN 'High Network Reach'
         WHEN total_reachable > total_other_users * 0.5 THEN 'Medium Network Reach'
         WHEN total_reachable > total_other_users * 0.2 THEN 'Limited Network Reach'
         ELSE 'Isolated Position'
       END AS reach_classification
ORDER BY reachability_percentage DESC, direct_connections DESC
```

## Part 5: Query Performance Optimization (10 minutes)

### Step 21: Query Profiling and Execution Analysis
```cypher
// Profile a complex variable-length path query to identify bottlenecks
PROFILE
MATCH (user:User {username: 'alice_codes'})-[:FOLLOWS*1..3]->(target:User)
WHERE target.location CONTAINS 'York'
  AND target.followerCount > 1000
RETURN target.username, target.location, target.followerCount
ORDER BY target.followerCount DESC
```

**Performance Analysis Steps:**
1. **Examine the execution plan** - identify expensive operations (high cost numbers)
2. **Check row counts** at each step - look for operations processing many rows
3. **Identify bottlenecks** - operations with high db hits or execution time
4. **Monitor memory usage** - ensure queries don't exceed available memory

### Step 22: Optimized Query Rewrite
```cypher
// Optimized version with strategic filtering and limits
PROFILE
MATCH (user:User {username: 'alice_codes'})
WITH user
MATCH (user)-[:FOLLOWS*1..3]->(target:User)
WHERE target.location CONTAINS 'York'
WITH target
WHERE target.followerCount > 1000
RETURN target.username, target.location, target.followerCount
ORDER BY target.followerCount DESC
LIMIT 10
```

### Step 23: Performance Best Practices Demo
```cypher
// Demonstrate index usage and early filtering
EXPLAIN
MATCH (alice:User {username: 'alice_codes'})  // Uses index on username
WITH alice LIMIT 1  // Limit early to control expansion
MATCH (alice)-[:FOLLOWS*1..2]->(connections:User)
WHERE connections.followerCount > 1000  // Filter early
WITH DISTINCT connections  // Remove duplicates before expensive operations
ORDER BY connections.followerCount DESC
RETURN connections.username, connections.followerCount
LIMIT 5
```

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

### Performance optimization tips:
```cypher
// Profile complex queries
PROFILE MATCH (u:User)-[:FOLLOWS*2]-(potential) RETURN potential LIMIT 10

// Use strategic WITH clauses
MATCH (start:User) WHERE start.username = 'alice_codes'
WITH start
MATCH (start)-[:FOLLOWS*1..3]->(target)
WITH target LIMIT 100
// Continue processing...
```

## Lab Completion Checklist

- [ ] Implemented variable-length path traversals with sophisticated depth controls
- [ ] Found shortest paths between users using multiple algorithms and constraints
- [ ] Created advanced recommendation systems with multi-factor scoring
- [ ] Built sophisticated influence propagation models with decay factors
- [ ] Analyzed network diameter, eccentricity, and structural properties
- [ ] Detected bridge nodes and assessed network vulnerability points
- [ ] Calculated comprehensive reachability metrics for network analysis
- [ ] Profiled and optimized complex path queries for performance
- [ ] Implemented memory-efficient approaches for large network traversals
- [ ] Combined multiple advanced patterns for comprehensive network insights

## Key Concepts Mastered

1. **Advanced Variable-Length Paths:** Complex syntax with multiple constraints and filtering
2. **Shortest Path Variants:** Single, multiple, weighted, and constrained pathfinding
3. **Sophisticated Recommendations:** Multi-hop, interest-based, and context-aware systems
4. **Influence Modeling:** Complex propagation with quality factors and amplification
5. **Network Topology Analysis:** Diameter, eccentricity, bridges, and resilience
6. **Performance Optimization:** Profiling, indexing, and memory-efficient patterns
7. **Query Strategy:** Strategic use of WITH clauses and early filtering
8. **Complex Pattern Integration:** Multi-pattern queries for comprehensive analysis

## Performance Best Practices Learned

### Variable-Length Path Optimization:
1. **Always specify maximum depth** to prevent exponential traversal explosion
2. **Use node property indexes** on frequently filtered properties
3. **Apply LIMIT strategically** throughout query pipeline, not just at the end
4. **Consider relationship direction** - directed queries often perform better
5. **Use WITH clauses** to control intermediate result sizes

### Query Strategy Guidelines:
- **Start specific, expand gradually** - begin with constrained patterns
- **Filter early and often** - apply WHERE clauses as soon as possible
- **Use PROFILE, not just EXPLAIN** - get actual performance data
- **Batch large operations** - process large result sets in manageable chunks
- **Monitor memory usage** - use heap and page cache monitoring

## Next Steps

Excellent work! You've mastered sophisticated graph traversal patterns that enable:
- Building enterprise-grade recommendation engines
- Analyzing complex social network structures
- Optimizing graph queries for production performance
- Modeling real-world influence and information propagation

**In Lab 6**, we'll leverage these advanced patterns to:
- Calculate comprehensive social network analytics and KPIs
- Perform temporal analysis of network evolution over time
- Build executive-level reporting dashboards with business intelligence
- Segment users based on sophisticated behavioral and network patterns

## Practice Exercises (Optional)

Challenge yourself with these advanced scenarios:

1. **Viral Cascade Modeling:** Model how content spreads through the network with different engagement thresholds
2. **Network Evolution Analysis:** Compare network structure at different time periods
3. **Influence Bottleneck Analysis:** Find users whose removal would most fragment the network
4. **Cross-Platform Bridge Detection:** Identify users who bridge different interest communities
5. **Real-Time Recommendation Engine:** Build a system that updates recommendations as relationships change

## Quick Reference

**Advanced Variable-Length Path Patterns:**
```cypher
// Constrained depth with property filtering
(a)-[:TYPE*1..3]->(b) WHERE ALL(n IN nodes(path) WHERE n.property > value)

// Multiple relationship types with weights
(a)-[:TYPE1|TYPE2*]->(b) WITH reduce(weight = 0, r IN relationships(path) | weight + r.cost)

// Bidirectional with distance optimization
(a)-[:TYPE*]-(b) WHERE length(path) = min_distance

// Path property analysis
[node IN nodes(path) | node.property]  // Extract node properties
[rel IN relationships(path) | rel.weight]  // Extract relationship weights
```

**Performance Optimization Patterns:**
```cypher
// Strategic WITH usage
MATCH (start:Node) WHERE start.key = 'value'
WITH start
MATCH (start)-[:REL*1..3]->(target)
WHERE target.filter = true
WITH start, target LIMIT 100
// Continue processing...

// Index hints
MATCH (n:Label) WHERE n.property = value
USING INDEX n:Label(property)
RETURN n
```

---

**🎉 Lab 5 Complete!**

You now possess advanced graph traversal and optimization skills that are essential for building production-scale graph applications. These sophisticated pattern-matching capabilities will serve as the foundation for the comprehensive analytics and business intelligence work in Lab 6!
