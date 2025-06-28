# Lab 5: Variable-Length Paths & Complex Queries

**Duration:** 75 minutes  
**Objective:** Master advanced Cypher patterns, variable-length path traversals, and query optimization techniques

## Prerequisites

- Completed Labs 1-4 successfully with social network data
- Understanding of basic Cypher syntax and pattern matching
- Familiarity with Neo4j Browser and query execution
- Knowledge of social network relationships from Lab 3

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

## Part 1: Variable-Length Path Fundamentals (15 minutes)

### Step 1: Verify Social Network Data
First, ensure your social network from Lab 3 is available:

```cypher
// Check network structure and completeness
MATCH (u:User) 
RETURN count(u) AS total_users

MATCH ()-[r:FOLLOWS]->() 
RETURN count(r) AS follow_relationships

MATCH ()-[r:LIKES]->() 
RETURN count(r) AS like_relationships

MATCH (t:Topic) 
RETURN count(t) AS total_topics

MATCH (p:Post)
RETURN count(p) AS total_posts
```

**Expected Results:** 6 users, 8+ follows, 6+ likes, 8 topics, 6+ posts

### Step 2: Basic Variable-Length Path Syntax
```cypher
// Basic variable-length path - explore unlimited depth carefully
MATCH path = (alice:User {username: 'alice_codes'})-[:FOLLOWS*1..3]->(connected:User)
RETURN connected.username AS reachable_user, 
       length(path) AS hops_away,
       [node IN nodes(path) | node.username] AS path_through_users
ORDER BY hops_away, reachable_user
```

### Step 3: Bidirectional Variable Paths
```cypher
// Find users connected in either direction (undirected search)
MATCH path = (alice:User {username: 'alice_codes'})-[:FOLLOWS*1..2]-(connected:User)
WHERE alice <> connected
RETURN DISTINCT connected.username AS connected_user,
       min(length(path)) AS shortest_distance,
       collect(DISTINCT [node IN nodes(path) | node.username]) AS all_paths
ORDER BY shortest_distance, connected_user
```

### Step 4: Multiple Relationship Types in Variable Paths
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

### Step 5: Variable Paths with Property Filtering
```cypher
// Filter paths based on node and relationship properties
MATCH path = (start:User {username: 'alice_codes'})-[:FOLLOWS*2..4]->(end:User)
WHERE ALL(node IN nodes(path)[1..-1] WHERE node.followerCount > 500)
  AND ALL(rel IN relationships(path) WHERE rel.since > datetime('2020-01-01'))
RETURN end.username AS discovered_user,
       end.followerCount AS followers,
       length(path) AS hops,
       [node IN nodes(path) | node.username] AS path_users,
       [rel IN relationships(path) | rel.since] AS relationship_dates
ORDER BY hops, followers DESC
```

## Part 2: Shortest Path Algorithms (15 minutes)

### Step 6: Single Shortest Path Analysis
```cypher
// Find the shortest path between two specific users
MATCH (alice:User {username: 'alice_codes'}), (bob:User {username: 'bob_travels'})
MATCH path = shortestPath((alice)-[:FOLLOWS*]-(bob))
RETURN path,
       length(path) AS distance,
       [node IN nodes(path) | node.username] AS users_in_path,
       [rel IN relationships(path) | type(rel)] AS relationship_types,
       [rel IN relationships(path) | rel.relationship] AS relationship_qualities
```

### Step 7: All Shortest Paths Discovery
```cypher
// Find all shortest paths between users (multiple equivalent routes)
MATCH (alice:User {username: 'alice_codes'}), (carol:User {username: 'carol_creates'})
MATCH paths = allShortestPaths((alice)-[:FOLLOWS*]-(carol))
WITH paths, length(paths) AS distance
RETURN distance,
       count(paths) AS number_of_shortest_paths,
       collect([node IN nodes(paths) | node.username]) AS all_path_routes
```

### Step 8: Constrained Shortest Paths
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
       [rel IN relationships(path) | rel.relationship] AS relationship_qualities,
       [rel IN relationships(path) | rel.since] AS relationship_dates
ORDER BY distance, reachable_user
```

### Step 9: Weighted Shortest Path Calculation
```cypher
// Calculate weighted paths based on relationship strength and recency
MATCH path = (alice:User {username: 'alice_codes'})-[:FOLLOWS*1..4]-(target:User)
WHERE target <> alice
WITH path, target,
     reduce(weight = 0, rel IN relationships(path) | 
       weight + 
       // Relationship quality weight
       CASE 
         WHEN rel.relationship = 'close' THEN 1
         WHEN rel.relationship = 'friend' THEN 2  
         WHEN rel.relationship = 'colleague' THEN 3
         WHEN rel.relationship = 'professional' THEN 4
         ELSE 5
       END +
       // Recency weight (older relationships cost more)
       CASE 
         WHEN rel.since > datetime('2022-01-01') THEN 0
         WHEN rel.since > datetime('2021-01-01') THEN 1
         ELSE 2
       END
     ) AS total_weight
RETURN target.username AS user,
       length(path) AS hops,
       total_weight,
       round(total_weight * 1.0 / length(path) * 100) / 100 AS avg_weight_per_hop,
       [node IN nodes(path) | node.username] AS path_users
ORDER BY total_weight, hops
LIMIT 8
```

## Part 3: Advanced Recommendation Systems (20 minutes)

### Step 10: Enhanced Friend-of-Friend Recommendations
```cypher
// Find potential friends through mutual connections with scoring
MATCH (user:User {username: 'alice_codes'})-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(potential:User)
WHERE NOT (user)-[:FOLLOWS]->(potential) 
  AND potential <> user
  AND potential.isPrivate = false  // Only recommend public profiles

// Calculate shared interests
OPTIONAL MATCH (user)-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(potential)
WITH user, potential, 
     count(DISTINCT friend) AS mutual_friends,
     collect(DISTINCT friend.username) AS mutual_friend_names,
     count(DISTINCT topic) AS shared_interests,
     collect(DISTINCT topic.name) AS shared_topics

// Calculate location proximity bonus
WITH *, 
     CASE WHEN user.location = potential.location THEN 2 ELSE 0 END AS location_bonus,
     mutual_friends * 3 + shared_interests * 2 AS base_score

RETURN potential.username AS recommended_user,
       potential.fullName AS full_name,
       potential.location AS location,
       mutual_friends,
       shared_interests,
       shared_topics,
       base_score + location_bonus AS recommendation_score,
       mutual_friend_names
ORDER BY recommendation_score DESC, mutual_friends DESC
LIMIT 5
```

### Step 11: Interest-Based Content Discovery
```cypher
// Recommend users based on shared interests and content quality
MATCH (user:User {username: 'alice_codes'})-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(similar:User)
WHERE user <> similar AND NOT (user)-[:FOLLOWS]->(similar)

// Find their content in shared topics
MATCH (similar)-[:POSTED]->(post:Post)-[:TAGGED_WITH]->(topic)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)

WITH user, similar, topic, post, count(DISTINCT liker) AS post_likes
WITH user, similar, 
     collect(DISTINCT topic.name) AS shared_topics,
     count(DISTINCT post) AS relevant_posts,
     avg(post_likes) AS avg_engagement_per_post,
     sum(post_likes) AS total_engagement

WHERE relevant_posts > 0
RETURN similar.username AS recommended_user,
       similar.fullName AS full_name,
       similar.followerCount AS followers,
       size(shared_topics) AS shared_interests,
       shared_topics,
       relevant_posts AS posts_in_shared_topics,
       round(avg_engagement_per_post) AS avg_likes_per_post,
       total_engagement
ORDER BY shared_interests DESC, total_engagement DESC, followers DESC
LIMIT 6
```

### Step 12: Multi-Hop Content Discovery Through Network
```cypher
// Find interesting content through extended network with decay factor
MATCH (user:User {username: 'alice_codes'})-[:FOLLOWS*1..3]->(author:User)-[:POSTED]->(post:Post)
WHERE NOT (user)-[:FOLLOWS]->(author)  // Content from non-followed users
  AND post.timestamp > datetime() - duration('P14D')  // Last 2 weeks

// Calculate network distance and content engagement
WITH user, post, author, 
     min(length((user)-[:FOLLOWS*]->(author))) AS degrees_of_separation

OPTIONAL MATCH (post)-[:TAGGED_WITH]->(topic:Topic)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (user)-[:INTERESTED_IN]->(user_topic:Topic)

WITH post, author, topic, degrees_of_separation,
     count(DISTINCT liker) AS likes,
     CASE WHEN topic.name IN collect(user_topic.name) THEN 2 ELSE 0 END AS topic_bonus,
     // Decay factor based on network distance
     CASE degrees_of_separation
       WHEN 1 THEN 1.0
       WHEN 2 THEN 0.7
       WHEN 3 THEN 0.4
       ELSE 0.1
     END AS distance_factor

// Score content with decay and interest alignment
WITH post, author, degrees_of_separation, likes, topic_bonus,
     round((likes + topic_bonus) * distance_factor) AS content_score

WHERE content_score >= 1  // Minimum score threshold
RETURN post.content AS content,
       author.username AS author,
       collect(DISTINCT topic.name) AS topics,
       likes AS raw_likes,
       content_score,
       degrees_of_separation,
       post.timestamp AS posted_at
ORDER BY content_score DESC, degrees_of_separation ASC
LIMIT 8
```

### Step 13: Influence Propagation with Relationship Quality
```cypher
// Model how influence spreads through network with relationship quality factors
MATCH (influencer:User {username: 'carol_creates'})
MATCH path = (influencer)-[:FOLLOWS*1..4]->(reached:User)

WITH influencer, reached, path, length(path) AS distance,
     // Calculate influence decay based on relationship quality and distance
     reduce(influence = 1.0, rel IN relationships(path) | 
       influence * 
       // Relationship quality multiplier
       CASE 
         WHEN rel.relationship = 'close' THEN 0.95
         WHEN rel.relationship = 'friend' THEN 0.85
         WHEN rel.relationship = 'colleague' THEN 0.70
         WHEN rel.relationship = 'professional' THEN 0.55
         ELSE 0.40
       END *
       // Notification enabled multiplier
       CASE WHEN rel.notificationsEnabled = true THEN 1.0 ELSE 0.8 END *
       // Recency multiplier
       CASE 
         WHEN rel.since > datetime('2022-01-01') THEN 1.0
         WHEN rel.since > datetime('2021-01-01') THEN 0.9
         ELSE 0.8
       END
     ) AS influence_strength

WHERE influence_strength > 0.05  // Minimum influence threshold (5%)

// Add follower count amplification
WITH *, 
     influence_strength * (1 + log10(reached.followerCount + 1) / 10) AS amplified_influence

RETURN reached.username AS influenced_user,
       reached.followerCount AS user_followers,
       distance AS hops_from_source,
       round(influence_strength * 1000) / 10 AS influence_percentage,
       round(amplified_influence * 1000) / 10 AS amplified_influence_percentage,
       CASE 
         WHEN amplified_influence > 0.6 THEN 'High Influence'
         WHEN amplified_influence > 0.3 THEN 'Medium Influence'
         WHEN amplified_influence > 0.1 THEN 'Low Influence'
         ELSE 'Minimal Influence'
       END AS influence_level,
       [node IN nodes(path) | node.username] AS influence_path
ORDER BY amplified_influence DESC
LIMIT 10
```

## Part 4: Complex Network Analysis Patterns (15 minutes)

### Step 14: Network Diameter and Eccentricity Analysis
```cypher
// Calculate network diameter and individual node eccentricity
MATCH (a:User), (b:User)
WHERE a <> b AND id(a) < id(b)  // Avoid duplicate pairs
MATCH path = shortestPath((a)-[:FOLLOWS*]-(b))
WITH a, max(length(path)) AS eccentricity
ORDER BY eccentricity DESC
WITH collect({user: a.username, eccentricity: eccentricity}) AS user_eccentricities,
     max(eccentricity) AS network_diameter

RETURN network_diameter,
       [u IN user_eccentricities WHERE u.eccentricity = network_diameter | u.user] AS peripheral_users,
       user_eccentricities[0..5] AS top_central_users
```

### Step 15: Path Redundancy and Network Resilience
```cypher
// Analyze path redundancy between users (network resilience)
MATCH (alice:User {username: 'alice_codes'}), (target:User)
WHERE alice <> target

// Find all paths of length up to diameter + 1
MATCH paths = allShortestPaths((alice)-[:FOLLOWS*1..5]-(target))
WITH target, 
     count(paths) AS path_count,
     length(paths) AS shortest_distance,
     collect(distinct [node IN nodes(paths) | node.username]) AS all_path_routes

// Analyze path diversity
WITH target, path_count, shortest_distance, all_path_routes,
     size(reduce(all_nodes = [], path IN all_path_routes | all_nodes + path)) AS total_nodes_in_paths,
     size(reduce(unique_nodes = [], path IN all_path_routes | 
       unique_nodes + [node IN path WHERE NOT node IN unique_nodes])) AS unique_nodes_in_paths

WHERE path_count > 0
RETURN target.username AS connected_user,
       shortest_distance,
       path_count AS number_of_paths,
       round(unique_nodes_in_paths * 100.0 / total_nodes_in_paths) AS path_diversity_percentage,
       CASE 
         WHEN path_count = 1 THEN 'Single Point of Failure'
         WHEN path_count <= 2 THEN 'Low Redundancy'
         WHEN path_count <= 4 THEN 'Medium Redundancy'
         ELSE 'High Redundancy'
       END AS resilience_level,
       all_path_routes
ORDER BY path_count DESC, shortest_distance
LIMIT 8
```

### Step 16: Bridge Detection and Network Vulnerability
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

### Step 17: Network Reachability and Influence Radius
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

### Step 18: Query Profiling and Execution Analysis
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
4. **Note any cartesian products** - joins without proper filtering

### Step 19: Optimized Query Patterns
```cypher
// Optimized version using strategic query structure
MATCH (user:User)
WHERE user.username = 'alice_codes'

// Use WITH to control intermediate result size
WITH user
MATCH (user)-[:FOLLOWS*1..2]->(level2:User)
WHERE level2.followerCount > 1000

// Limit early to prevent large intermediate results
WITH user, level2
LIMIT 50

// Extend to third level only for promising candidates
MATCH (level2)-[:FOLLOWS]->(level3:User)
WHERE level3.location CONTAINS 'York'
  AND NOT level3 = user

RETURN level3.username AS discovered_user,
       level3.location AS location,
       level3.followerCount AS followers,
       min(length((user)-[:FOLLOWS*]->(level3))) AS shortest_distance
ORDER BY followers DESC
LIMIT 10
```

### Step 20: Index Optimization and Verification
```cypher
// Check existing indexes
SHOW INDEXES

// Create missing indexes for better performance
CREATE INDEX user_username_index IF NOT EXISTS FOR (u:User) ON (u.username);
CREATE INDEX user_location_index IF NOT EXISTS FOR (u:User) ON (u.location);
CREATE INDEX user_follower_count_index IF NOT EXISTS FOR (u:User) ON (u.followerCount);
CREATE INDEX follow_relationship_since IF NOT EXISTS FOR ()-[r:FOLLOWS]-() ON (r.since);
```

```cypher
// Test optimized query performance with indexes
PROFILE
MATCH (user:User)
WHERE user.username = 'alice_codes'
WITH user
MATCH (user)-[:FOLLOWS*1..3]->(target:User)
WHERE target.location CONTAINS 'York'
USING INDEX target:User(location)  // Hint to use location index
RETURN target.username, target.location
LIMIT 10
```

### Step 21: Memory-Efficient Complex Path Analysis
```cypher
// Memory-efficient approach for large network analysis
MATCH (user:User {username: 'alice_codes'})

// Process in stages to control memory usage
WITH user
MATCH (user)-[:FOLLOWS*1..2]->(second_degree:User)
WITH user, collect(DISTINCT second_degree) AS level_2_users

// Process level 2 connections in batches
UNWIND level_2_users AS friend
MATCH (friend)-[:FOLLOWS]->(potential:User)
WHERE NOT (user)-[:FOLLOWS]->(potential) 
  AND potential <> user
  AND potential.isPrivate = false

// Aggregate recommendation data
WITH user, potential,
     count(*) AS recommendation_strength,
     collect(DISTINCT friend.username) AS connecting_friends

WHERE recommendation_strength >= 2  // Minimum threshold

RETURN potential.username AS recommendation,
       potential.fullName AS full_name,
       recommendation_strength,
       connecting_friends,
       size(connecting_friends) AS unique_connection_points
ORDER BY recommendation_strength DESC, unique_connection_points DESC
LIMIT 5
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