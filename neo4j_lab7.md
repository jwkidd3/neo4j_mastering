# Lab 7: Pathfinding & Centrality Measures

**Duration:** 90 minutes  
**Objective:** Implement advanced graph algorithms for pathfinding, centrality analysis, and network topology understanding

## Prerequisites

- Completed Labs 1-6 successfully with comprehensive social network analytics experience
- Understanding of variable-length paths and complex query patterns from Lab 5
- Familiarity with business intelligence concepts from Lab 6
- Knowledge of network analysis and statistical aggregations

## Learning Outcomes

By the end of this lab, you will:
- Implement Dijkstra and breadth-first search algorithms for optimal pathfinding
- Calculate various centrality measures for influence and importance analysis
- Detect communities and clusters using algorithmic approaches
- Identify bridges and critical connection points in network topology
- Analyze network robustness and resilience to node/edge removal
- Optimize algorithms for large-scale data processing and performance
- Apply graph algorithms to solve real-world business problems
- Build comprehensive network analysis dashboards with algorithm results

## Part 1: Advanced Pathfinding Algorithms (25 minutes)

### Step 1: Verify Social Network Data and Add Algorithm Infrastructure
```cypher
// Check network completeness and add algorithm-friendly properties
MATCH (u:User) 
RETURN count(u) AS total_users

MATCH ()-[r:FOLLOWS]->() 
RETURN count(r) AS follow_relationships

// Add algorithm-friendly properties to relationships for weighted pathfinding
MATCH ()-[r:FOLLOWS]->()
SET r.weight = CASE 
  WHEN r.relationship = 'close' THEN 1
  WHEN r.relationship = 'friend' THEN 2
  WHEN r.relationship = 'colleague' THEN 3
  WHEN r.relationship = 'professional' THEN 4
  ELSE 5
END,
r.trust_score = CASE 
  WHEN r.notificationsEnabled = true AND r.relationship IN ['close', 'friend'] THEN 0.9
  WHEN r.notificationsEnabled = true THEN 0.7
  WHEN r.relationship IN ['close', 'friend'] THEN 0.6
  ELSE 0.4
END

RETURN "Algorithm properties added to relationships" AS status
```

### Step 2: Implement Breadth-First Search (BFS) Algorithm
```cypher
// BFS implementation for unweighted shortest paths
WITH ['alice_codes', 'carol_creates'] AS target_users
UNWIND target_users AS start_username

MATCH (start:User {username: start_username})

// BFS traversal to find shortest paths to all reachable nodes
CALL {
  WITH start
  MATCH path = (start)-[:FOLLOWS*1..5]->(destination:User)
  WITH destination, min(length(path)) AS shortest_distance, start
  WHERE shortest_distance <= 4  // Limit to reasonable distances
  RETURN destination, shortest_distance, start
}

RETURN start.username AS source_user,
       destination.username AS destination_user,
       destination.fullName AS destination_name,
       shortest_distance,
       // Calculate reachability metrics
       CASE 
         WHEN shortest_distance = 1 THEN 'Direct Connection'
         WHEN shortest_distance = 2 THEN 'Friend of Friend'
         WHEN shortest_distance = 3 THEN 'Extended Network'
         ELSE 'Distant Connection'
       END AS connection_strength,
       // Estimate information flow time (hops as proxy for time)
       shortest_distance * 6 AS estimated_hours_to_reach
ORDER BY start.username, shortest_distance, destination_user
```

### Step 3: Implement Weighted Dijkstra Algorithm
```cypher
// Dijkstra's algorithm implementation for weighted shortest paths
MATCH (alice:User {username: 'alice_codes'})

// Find weighted shortest paths considering relationship quality
CALL {
  WITH alice
  MATCH path = (alice)-[:FOLLOWS*1..4]->(destination:User)
  WHERE destination <> alice
  
  // Calculate total path weight (lower is better)
  WITH path, destination,
       reduce(total_weight = 0, rel IN relationships(path) | total_weight + rel.weight) AS path_weight,
       reduce(trust_product = 1.0, rel IN relationships(path) | trust_product * rel.trust_score) AS path_trust
  
  // Find minimum weight path to each destination
  WITH destination, min(path_weight) AS min_weight, path_trust
  WHERE min_weight <= 12  // Reasonable weight threshold
  
  RETURN destination, min_weight, path_trust
}

RETURN alice.username AS source,
       destination.username AS target,
       destination.fullName AS target_name,
       min_weight AS optimal_path_cost,
       round(path_trust * 1000) / 1000 AS path_trust_score,
       // Quality assessment
       CASE 
         WHEN min_weight <= 4 THEN 'High Quality Path'
         WHEN min_weight <= 7 THEN 'Medium Quality Path'
         WHEN min_weight <= 10 THEN 'Low Quality Path'
         ELSE 'Poor Quality Path'
       END AS path_quality,
       // Trust level assessment
       CASE 
         WHEN path_trust > 0.7 THEN 'High Trust'
         WHEN path_trust > 0.5 THEN 'Medium Trust'
         WHEN path_trust > 0.3 THEN 'Low Trust'
         ELSE 'Very Low Trust'
       END AS trust_level
ORDER BY min_weight, path_trust DESC
LIMIT 15
```

### Step 4: All-Pairs Shortest Path Analysis
```cypher
// Calculate shortest paths between all user pairs for network analysis
MATCH (u1:User), (u2:User)
WHERE u1 <> u2 AND id(u1) < id(u2)  // Avoid duplicates

OPTIONAL MATCH path = shortestPath((u1)-[:FOLLOWS*1..6]-(u2))

WITH u1, u2, 
     CASE WHEN path IS NOT NULL THEN length(path) ELSE null END AS distance,
     path

// Aggregate distance statistics
WITH collect({
  user1: u1.username,
  user2: u2.username,
  distance: distance,
  is_connected: distance IS NOT NULL
}) AS all_pairs

UNWIND all_pairs AS pair
WITH pair.distance AS dist, count(*) AS pair_count,
     sum(CASE WHEN pair.is_connected THEN 1 ELSE 0 END) AS connected_pairs,
     count(*) AS total_pairs

RETURN dist AS distance,
       pair_count AS pairs_at_distance,
       round(pair_count * 100.0 / total_pairs) AS percentage_of_pairs,
       connected_pairs AS total_connected_pairs,
       round(connected_pairs * 100.0 / total_pairs) AS network_connectivity_percent
ORDER BY distance
```

### Step 5: Path Redundancy and Alternative Routes
```cypher
// Find alternative paths and analyze path redundancy
MATCH (alice:User {username: 'alice_codes'}), (target:User)
WHERE alice <> target

// Find multiple paths between users
MATCH paths = allShortestPaths((alice)-[:FOLLOWS*1..5]-(target))
WITH target, collect(paths) AS all_paths, length(paths) AS shortest_distance

WHERE size(all_paths) > 0
WITH target, all_paths, shortest_distance,
     size(all_paths) AS path_count,
     // Calculate path diversity
     size(reduce(all_nodes = [], path IN all_paths | 
       all_nodes + [node IN nodes(path) WHERE NOT node IN all_nodes])) AS unique_nodes_in_paths

RETURN target.username AS destination,
       target.fullName AS destination_name,
       shortest_distance,
       path_count AS alternative_paths,
       unique_nodes_in_paths,
       // Redundancy analysis
       CASE 
         WHEN path_count = 1 THEN 'Single Point of Failure'
         WHEN path_count <= 2 THEN 'Low Redundancy'
         WHEN path_count <= 4 THEN 'Medium Redundancy'
         ELSE 'High Redundancy'
       END AS redundancy_level,
       // Network resilience score
       round((path_count + unique_nodes_in_paths) * 100.0 / (shortest_distance + 1)) AS resilience_score
ORDER BY resilience_score DESC, path_count DESC
LIMIT 12
```

## Part 2: Centrality Measures Implementation (25 minutes)

### Step 6: Degree Centrality Analysis
```cypher
// Calculate degree centrality (in-degree, out-degree, total)
MATCH (u:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(in_follower:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(out_following:User)

WITH u,
     count(DISTINCT in_follower) AS in_degree,
     count(DISTINCT out_following) AS out_degree

// Calculate network-wide statistics for normalization
MATCH (all_users:User)
WITH u, in_degree, out_degree, count(all_users) - 1 AS max_possible_degree

RETURN u.username AS username,
       u.fullName AS full_name,
       in_degree AS followers_count,
       out_degree AS following_count,
       in_degree + out_degree AS total_degree,
       // Normalized centrality scores (0-1)
       round(in_degree * 1000.0 / max_possible_degree) / 1000 AS in_degree_centrality,
       round(out_degree * 1000.0 / max_possible_degree) / 1000 AS out_degree_centrality,
       round((in_degree + out_degree) * 1000.0 / (max_possible_degree * 2)) / 1000 AS total_degree_centrality,
       // Influence indicators
       CASE 
         WHEN in_degree > out_degree * 2 THEN 'Influencer (High In-Degree)'
         WHEN out_degree > in_degree * 2 THEN 'Connector (High Out-Degree)'
         WHEN in_degree + out_degree > max_possible_degree * 0.3 THEN 'Hub (High Total Degree)'
         ELSE 'Regular User'
       END AS centrality_profile,
       // Social capital score
       round((in_degree * 2 + out_degree) / 3.0) AS social_capital_score
ORDER BY total_degree_centrality DESC, in_degree DESC
```

### Step 7: Betweenness Centrality Approximation
```cypher
// Approximate betweenness centrality by counting shortest path appearances
MATCH (source:User), (target:User)
WHERE source <> target AND id(source) < id(target)

// Find shortest paths between all pairs
MATCH path = shortestPath((source)-[:FOLLOWS*]-(target))
WHERE length(path) <= 5  // Limit for performance

// Extract intermediate nodes (excluding source and target)
UNWIND nodes(path)[1..-1] AS intermediate_node
WHERE intermediate_node:User

WITH intermediate_node, count(*) AS times_on_shortest_paths
WHERE times_on_shortest_paths > 0

// Calculate total possible paths for normalization
MATCH (all_users:User)
WITH intermediate_node, times_on_shortest_paths, count(all_users) AS total_users
WITH intermediate_node, times_on_shortest_paths, 
     (total_users * (total_users - 1) / 2) AS total_possible_pairs

RETURN intermediate_node.username AS username,
       intermediate_node.fullName AS full_name,
       times_on_shortest_paths AS betweenness_count,
       round(times_on_shortest_paths * 1000.0 / total_possible_pairs) / 1000 AS betweenness_centrality,
       // Bridge importance classification
       CASE 
         WHEN times_on_shortest_paths > total_possible_pairs * 0.1 THEN 'Critical Bridge'
         WHEN times_on_shortest_paths > total_possible_pairs * 0.05 THEN 'Important Bridge'
         WHEN times_on_shortest_paths > total_possible_pairs * 0.02 THEN 'Minor Bridge'
         ELSE 'Regular Node'
       END AS bridge_importance,
       // Network vulnerability if removed
       CASE 
         WHEN times_on_shortest_paths > total_possible_pairs * 0.1 THEN 'High Impact if Removed'
         WHEN times_on_shortest_paths > total_possible_pairs * 0.05 THEN 'Medium Impact if Removed'
         ELSE 'Low Impact if Removed'
       END AS removal_impact
ORDER BY betweenness_centrality DESC
LIMIT 10
```

### Step 8: Closeness Centrality Calculation
```cypher
// Calculate closeness centrality (average distance to all reachable nodes)
MATCH (u:User)

// Calculate distances to all reachable users
CALL {
  WITH u
  MATCH path = shortestPath((u)-[:FOLLOWS*1..6]-(other:User))
  WHERE other <> u
  RETURN other, length(path) AS distance
}

WITH u, collect({user: other, distance: distance}) AS distances
WHERE size(distances) > 0

// Calculate closeness metrics
WITH u, distances,
     size(distances) AS reachable_users,
     reduce(total_distance = 0, d IN distances | total_distance + d.distance) AS sum_distances

MATCH (all_users:User)
WITH u, reachable_users, sum_distances, count(all_users) - 1 AS total_other_users

RETURN u.username AS username,
       u.fullName AS full_name,
       reachable_users,
       total_other_users,
       round(reachable_users * 100.0 / total_other_users) AS reachability_percent,
       round(sum_distances * 1.0 / reachable_users * 100) / 100 AS avg_distance,
       // Closeness centrality (inverse of average distance, normalized)
       CASE WHEN sum_distances > 0 
            THEN round(reachable_users * 1000.0 / sum_distances) / 1000
            ELSE 0 END AS closeness_centrality,
       // Efficiency score (reachability weighted by closeness)
       CASE WHEN sum_distances > 0 
            THEN round((reachable_users * 1.0 / total_other_users) * (reachable_users * 1.0 / sum_distances) * 1000) / 1000
            ELSE 0 END AS efficiency_score,
       // Centrality classification
       CASE 
         WHEN reachable_users = total_other_users AND sum_distances <= total_other_users * 2 THEN 'Central Hub'
         WHEN reachable_users > total_other_users * 0.8 THEN 'Well Connected'
         WHEN reachable_users > total_other_users * 0.5 THEN 'Moderately Connected'
         ELSE 'Peripherally Connected'
       END AS connection_profile
ORDER BY closeness_centrality DESC, reachability_percent DESC
```

### Step 9: PageRank Algorithm Implementation
```cypher
// Simplified PageRank calculation using iterative approach
MATCH (u:User)
WITH collect(u) AS all_users

// Initialize PageRank values
UNWIND all_users AS user
SET user.pagerank = 1.0 / size(all_users)

// Perform PageRank iterations (simplified version)
WITH all_users, 0.85 AS damping_factor

// Single iteration for demonstration (in practice, would need multiple iterations)
UNWIND all_users AS user
MATCH (user)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (follower)-[:FOLLOWS]->(following:User)

WITH user, damping_factor, size(all_users) AS total_users,
     collect({
       follower: follower,
       follower_pagerank: follower.pagerank,
       follower_out_degree: count(following)
     }) AS incoming_links

WITH user, damping_factor, total_users, incoming_links,
     // Calculate PageRank contribution from incoming links
     reduce(pr_sum = 0.0, link IN incoming_links | 
       pr_sum + (link.follower_pagerank / CASE WHEN link.follower_out_degree > 0 THEN link.follower_out_degree ELSE 1 END)
     ) AS incoming_pagerank

// Update PageRank value
SET user.pagerank_new = (1.0 - damping_factor) / total_users + damping_factor * incoming_pagerank

WITH user, user.pagerank AS old_pr, user.pagerank_new AS new_pr
SET user.pagerank = new_pr

RETURN user.username AS username,
       user.fullName AS full_name,
       round(new_pr * 10000) / 10000 AS pagerank_score,
       round(old_pr * 10000) / 10000 AS previous_score,
       round((new_pr - old_pr) * 10000) / 10000 AS score_change,
       // PageRank classification
       CASE 
         WHEN new_pr > 0.003 THEN 'High Authority'
         WHEN new_pr > 0.002 THEN 'Medium Authority'
         WHEN new_pr > 0.001 THEN 'Low Authority'
         ELSE 'Minimal Authority'
       END AS authority_level
ORDER BY pagerank_score DESC
```

### Step 10: Eigenvector Centrality Approximation
```cypher
// Simplified eigenvector centrality calculation
MATCH (u:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (follower)<-[:FOLLOWS]-(fof:User)

WITH u,
     count(DISTINCT follower) AS direct_followers,
     count(DISTINCT fof) AS second_degree_followers,
     collect(DISTINCT follower.followerCount) AS follower_influence_scores

// Calculate eigenvector centrality approximation
WITH u, direct_followers, second_degree_followers, follower_influence_scores,
     // Sum of follower influence scores
     reduce(influence_sum = 0, score IN follower_influence_scores | influence_sum + score) AS total_follower_influence

RETURN u.username AS username,
       u.fullName AS full_name,
       direct_followers,
       second_degree_followers,
       total_follower_influence,
       // Eigenvector centrality approximation
       round((direct_followers + total_follower_influence * 0.001 + second_degree_followers * 0.1) / 10) AS eigenvector_centrality,
       // Influence quality score
       CASE WHEN direct_followers > 0 
            THEN round(total_follower_influence * 1.0 / direct_followers)
            ELSE 0 END AS avg_follower_influence,
       // Authority classification
       CASE 
         WHEN total_follower_influence > 5000 THEN 'Connected to Major Influencers'
         WHEN total_follower_influence > 2000 THEN 'Connected to Medium Influencers'
         WHEN total_follower_influence > 500 THEN 'Connected to Minor Influencers'
         ELSE 'Connected to Regular Users'
       END AS influence_network_quality
ORDER BY eigenvector_centrality DESC, total_follower_influence DESC
```

## Part 3: Community Detection and Clustering (20 minutes)

### Step 11: Triangle Counting and Clustering Coefficient
```cypher
// Count triangles and calculate clustering coefficient for each user
MATCH (u:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(friend1:User)-[:FOLLOWS]->(friend2:User)-[:FOLLOWS]->(u)

WITH u, count(DISTINCT friend1) AS triangles

// Count total possible triangles (based on user's degree)
MATCH (u)-[:FOLLOWS]->(neighbor:User)
WITH u, triangles, count(neighbor) AS degree

// Calculate clustering coefficient
WITH u, triangles, degree,
     CASE WHEN degree >= 2 
          THEN degree * (degree - 1) / 2 
          ELSE 0 END AS possible_triangles

RETURN u.username AS username,
       u.fullName AS full_name,
       triangles,
       degree AS out_degree,
       possible_triangles,
       // Clustering coefficient
       CASE WHEN possible_triangles > 0 
            THEN round(triangles * 1000.0 / possible_triangles) / 1000
            ELSE 0 END AS clustering_coefficient,
       // Network density around user
       CASE 
         WHEN possible_triangles > 0 AND triangles * 1.0 / possible_triangles > 0.7 THEN 'Tight Cluster'
         WHEN possible_triangles > 0 AND triangles * 1.0 / possible_triangles > 0.4 THEN 'Moderate Cluster'
         WHEN possible_triangles > 0 AND triangles * 1.0 / possible_triangles > 0.1 THEN 'Loose Cluster'
         ELSE 'No Local Clustering'
       END AS local_clustering_level
ORDER BY clustering_coefficient DESC, triangles DESC
```

### Step 12: Label Propagation Community Detection
```cypher
// Initialize each user with their own community label
MATCH (u:User)
SET u.community_label = id(u)

// Perform label propagation iterations
WITH 1 AS iteration_count

// Single iteration of label propagation
MATCH (u:User)-[:FOLLOWS]->(neighbor:User)
WITH u, neighbor.community_label AS neighbor_label, count(*) AS label_frequency
ORDER BY u, label_frequency DESC

// Update to most common neighbor label
WITH u, collect(neighbor_label)[0] AS most_common_label
SET u.community_label = most_common_label

// Analyze detected communities
MATCH (u:User)
WITH u.community_label AS community_id, collect(u) AS community_members

RETURN community_id,
       size(community_members) AS community_size,
       [member IN community_members | member.username] AS member_usernames,
       [member IN community_members | member.location] AS member_locations,
       // Calculate location diversity
       size(apoc.coll.toSet([member IN community_members | member.location])) AS unique_locations,
       // Community characteristics
       CASE 
         WHEN size(community_members) >= 3 THEN 'Significant Community'
         WHEN size(community_members) = 2 THEN 'Pair Community'
         ELSE 'Isolated User'
       END AS community_type
ORDER BY community_size DESC
```

### Step 13: Interest-Based Community Analysis
```cypher
// Detect communities based on shared interests and interactions
MATCH (u:User)-[:INTERESTED_IN]->(topic:Topic)
WITH topic, collect(u) AS users_interested

WHERE size(users_interested) >= 2

// Analyze interaction patterns within interest communities
UNWIND users_interested AS user1
UNWIND users_interested AS user2
WHERE user1 <> user2

OPTIONAL MATCH (user1)-[interaction:FOLLOWS|LIKES|COMMENTED_ON]-(user2)
WITH topic, user1, user2, count(interaction) AS interaction_strength

// Aggregate community metrics
WITH topic.name AS topic_name,
     count(DISTINCT user1) AS community_size,
     avg(interaction_strength) AS avg_interaction_strength,
     count(CASE WHEN interaction_strength > 0 THEN 1 END) AS connected_pairs,
     count(*) AS total_possible_pairs

RETURN topic_name,
       community_size,
       round(avg_interaction_strength * 100) / 100 AS avg_interactions,
       connected_pairs,
       total_possible_pairs,
       round(connected_pairs * 100.0 / total_possible_pairs) AS connectivity_percentage,
       // Community cohesion classification
       CASE 
         WHEN connected_pairs * 100.0 / total_possible_pairs > 50 THEN 'Highly Cohesive'
         WHEN connected_pairs * 100.0 / total_possible_pairs > 25 THEN 'Moderately Cohesive'
         WHEN connected_pairs * 100.0 / total_possible_pairs > 10 THEN 'Loosely Cohesive'
         ELSE 'Interest Group Only'
       END AS cohesion_level
ORDER BY connectivity_percentage DESC, community_size DESC
```

### Step 14: Modularity Calculation for Community Quality
```cypher
// Calculate modularity to assess community detection quality
MATCH (u1:User)-[:FOLLOWS]->(u2:User)
WITH count(*) AS total_edges

// For each detected community, calculate internal vs external edges
MATCH (u:User)
WITH u.community_label AS community, collect(u) AS members, total_edges

UNWIND members AS member1
UNWIND members AS member2
WHERE member1 <> member2

OPTIONAL MATCH (member1)-[:FOLLOWS]->(member2)
WITH community, count(*) AS internal_edges, total_edges, size(members) AS community_size

// Calculate expected edges under random model
MATCH (u:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(neighbor:User)
WITH community, internal_edges, total_edges, community_size,
     avg(count(neighbor)) AS avg_degree

WITH community, internal_edges, total_edges, community_size, avg_degree,
     // Expected internal edges under random distribution
     (community_size * (community_size - 1) * avg_degree) / (total_edges * 2) AS expected_internal_edges

RETURN community,
       community_size,
       internal_edges,
       round(expected_internal_edges * 100) / 100 AS expected_internal_edges,
       round((internal_edges - expected_internal_edges) * 1000.0 / total_edges) / 1000 AS modularity_contribution,
       // Quality assessment
       CASE 
         WHEN internal_edges > expected_internal_edges * 2 THEN 'Strong Community'
         WHEN internal_edges > expected_internal_edges * 1.5 THEN 'Good Community'
         WHEN internal_edges > expected_internal_edges THEN 'Weak Community'
         ELSE 'Poor Community'
       END AS community_quality
ORDER BY modularity_contribution DESC
```

## Part 4: Network Robustness and Critical Node Analysis (20 minutes)

### Step 15: Critical Node Identification
```cypher
// Identify nodes whose removal would most impact network connectivity
MATCH (u:User)

// Calculate impact of removing each user
CALL {
  WITH u
  
  // Count connections that would be lost
  MATCH (u)-[r:FOLLOWS]-()
  WITH count(r) AS direct_connections_lost
  
  // Count shortest paths that go through this user
  MATCH (source:User), (target:User)
  WHERE source <> target AND source <> u AND target <> u
  
  OPTIONAL MATCH path1 = shortestPath((source)-[:FOLLOWS*]-(target))
  OPTIONAL MATCH path2 = shortestPath((source)-[:FOLLOWS*]-(u)-[:FOLLOWS*]-(target))
  
  WITH direct_connections_lost,
       count(CASE WHEN path1 IS NOT NULL THEN 1 END) AS total_paths_before,
       count(CASE WHEN path2 IS NOT NULL AND u IN nodes(path1) THEN 1 END) AS paths_through_user
  
  RETURN direct_connections_lost, paths_through_user
}

RETURN u.username AS username,
       u.fullName AS full_name,
       direct_connections_lost,
       paths_through_user,
       direct_connections_lost + paths_through_user AS total_impact_score,
       // Criticality classification
       CASE 
         WHEN direct_connections_lost + paths_through_user > 20 THEN 'Critical Node'
         WHEN direct_connections_lost + paths_through_user > 10 THEN 'Important Node'
         WHEN direct_connections_lost + paths_through_user > 5 THEN 'Significant Node'
         ELSE 'Regular Node'
       END AS criticality_level,
       // Network vulnerability assessment
       CASE 
         WHEN paths_through_user > direct_connections_lost THEN 'Bridge Vulnerability'
         WHEN direct_connections_lost > paths_through_user THEN 'Hub Vulnerability'
         ELSE 'Balanced Vulnerability'
       END AS vulnerability_type
ORDER BY total_impact_score DESC
LIMIT 10
```

### Step 16: Network Fragmentation Analysis
```cypher
// Analyze how network fragments when high-degree nodes are removed
MATCH (u:User)
OPTIONAL MATCH (u)-[:FOLLOWS]-()
WITH u, count(*) AS total_degree
ORDER BY total_degree DESC

// Simulate removal of top connected users
WITH collect(u)[0..3] AS top_connected_users

UNWIND top_connected_users AS removed_user

// Calculate remaining network connectivity
MATCH (remaining:User)
WHERE NOT remaining IN top_connected_users

OPTIONAL MATCH path = shortestPath((remaining)-[:FOLLOWS*1..4]-(other:User))
WHERE other <> remaining AND NOT other IN top_connected_users

WITH removed_user, count(DISTINCT remaining) AS remaining_users,
     count(DISTINCT other) AS reachable_users

RETURN removed_user.username AS removed_user,
       removed_user.followerCount AS removed_user_followers,
       remaining_users,
       reachable_users,
       round(reachable_users * 100.0 / remaining_users) AS connectivity_after_removal,
       // Network resilience assessment
       CASE 
         WHEN reachable_users * 100.0 / remaining_users > 80 THEN 'Network Remains Well Connected'
         WHEN reachable_users * 100.0 / remaining_users > 60 THEN 'Network Moderately Fragmented'
         WHEN reachable_users * 100.0 / remaining_users > 40 THEN 'Network Significantly Fragmented'
         ELSE 'Network Severely Fragmented'
       END AS fragmentation_impact
ORDER BY connectivity_after_removal
```

### Step 17: Bridge Edge Detection
```cypher
// Find critical edges (bridges) whose removal would disconnect components
MATCH (u1:User)-[r:FOLLOWS]->(u2:User)

// For each edge, check if its removal disconnects previously connected nodes
CALL {
  WITH u1, u2, r
  
  // Check if there's an alternative path not using this edge
  OPTIONAL MATCH alt_path = shortestPath((u1)-[:FOLLOWS*2..5]-(u2))
  WHERE NOT r IN relationships(alt_path)
  
  RETURN CASE WHEN alt_path IS NULL THEN 1 ELSE 0 END AS is_bridge
}

WHERE is_bridge = 1

RETURN u1.username AS source_user,
       u2.username AS target_user,
       r.relationship AS relationship_type,
       r.since AS relationship_since,
       r.weight AS relationship_weight,
       // Bridge importance assessment
       CASE 
         WHEN r.relationship IN ['close', 'friend'] THEN 'Critical Social Bridge'
         WHEN r.relationship = 'colleague' THEN 'Professional Bridge'
         WHEN r.relationship = 'professional' THEN 'Business Bridge'
         ELSE 'Casual Bridge'
       END AS bridge_type,
       // Removal impact
       'Network Disconnection' AS removal_impact
ORDER BY r.weight, relationship_since
```

### Step 18: Network Diameter and Small-World Properties
```cypher
// Calculate network diameter and analyze small-world characteristics
MATCH (u1:User), (u2:User)
WHERE u1 <> u2 AND id(u1) < id(u2)

OPTIONAL MATCH path = shortestPath((u1)-[:FOLLOWS*1..6]-(u2))

WITH collect(CASE WHEN path IS NOT NULL THEN length(path) ELSE null END) AS all_distances

WITH [d IN all_distances WHERE d IS NOT NULL] AS connected_distances,
     size([d IN all_distances WHERE d IS NOT NULL]) AS connected_pairs,
     size(all_distances) AS total_pairs

// Calculate network metrics
WITH connected_distances, connected_pairs, total_pairs,
     reduce(sum = 0, d IN connected_distances | sum + d) AS total_distance,
     max(connected_distances) AS network_diameter,
     min(connected_distances) AS minimum_distance

RETURN network_diameter,
       minimum_distance,
       round(total_distance * 1.0 / size(connected_distances) * 100) / 100 AS average_path_length,
       round(connected_pairs * 100.0 / total_pairs) AS network_connectivity_percent,
       size(connected_distances) AS reachable_pairs,
       total_pairs AS total_possible_pairs,
       // Small-world assessment
       CASE 
         WHEN network_diameter <= 6 AND average_path_length <= 3 THEN 'Strong Small-World Network'
         WHEN network_diameter <= 8 AND average_path_length <= 4 THEN 'Small-World Network'
         WHEN network_diameter <= 10 THEN 'Large-World Network'
         ELSE 'Very Large Network'
       END AS small_world_classification,
       // Network efficiency
       CASE 
         WHEN average_path_length <= 2.5 THEN 'Highly Efficient'
         WHEN average_path_length <= 3.5 THEN 'Efficient'
         WHEN average_path_length <= 4.5 THEN 'Moderately Efficient'
         ELSE 'Inefficient'
       END AS network_efficiency
```

## Lab Completion Checklist

- [ ] Implemented breadth-first search (BFS) for unweighted shortest paths
- [ ] Built Dijkstra's algorithm for weighted pathfinding with trust scores
- [ ] Calculated all-pairs shortest paths for comprehensive network analysis
- [ ] Analyzed path redundancy and alternative routing capabilities
- [ ] Computed degree centrality with normalization and classification
- [ ] Approximated betweenness centrality for bridge detection
- [ ] Calculated closeness centrality and reachability metrics
- [ ] Implemented PageRank algorithm for authority scoring
- [ ] Approximated eigenvector centrality based on follower influence
- [ ] Performed triangle counting and clustering coefficient analysis
- [ ] Implemented label propagation for community detection
- [ ] Analyzed interest-based communities with cohesion metrics
- [ ] Calculated modularity for community quality assessment
- [ ] Identified critical nodes and network vulnerability points
- [ ] Analyzed network fragmentation under node removal scenarios
- [ ] Detected bridge edges critical for network connectivity
- [ ] Measured network diameter and small-world properties

## Key Concepts Mastered

1. **Advanced Pathfinding:** BFS, Dijkstra, weighted paths, alternative routes
2. **Centrality Analysis:** Degree, betweenness, closeness, PageRank, eigenvector
3. **Community Detection:** Label propagation, modularity, interest-based clustering
4. **Network Robustness:** Critical nodes, bridge detection, fragmentation analysis
5. **Algorithm Optimization:** Performance tuning, memory management, scalability
6. **Real-World Applications:** Business insights from algorithmic analysis
7. **Network Topology:** Diameter, connectivity, small-world properties
8. **Quality Metrics:** Modularity, clustering coefficients, efficiency measures

## Business Applications Demonstrated

### 1. **Recommendation Systems**
- **Friend suggestions** based on shortest path algorithms
- **Content discovery** through centrality-based influence scores
- **Community recommendations** using clustering algorithms

### 2. **Risk Management**
- **Critical user identification** for platform stability
- **Bridge detection** for preventing network fragmentation
- **Vulnerability assessment** for system resilience planning

### 3. **Marketing and Influence**
- **Influencer identification** through multiple centrality measures
- **Viral marketing path optimization** using shortest path algorithms
- **Community targeting** based on algorithmic community detection

### 4. **Network Optimization**
- **Connection recommendations** to improve network efficiency
- **Bottleneck identification** through betweenness centrality
- **Structural improvement** suggestions based on small-world analysis

## Performance Optimization Techniques

### 1. **Algorithm Efficiency**
- **Limited path depth** to prevent exponential complexity
- **Strategic indexing** on relationship properties for weighted algorithms
- **Batch processing** for all-pairs calculations
- **Memory-conscious** implementations for large networks

### 2. **Query Optimization**
- **Early termination** conditions in pathfinding algorithms
- **Selective node processing** based on degree thresholds
- **Incremental calculations** for centrality measures
- **Parallel processing** where applicable in Cypher

## Next Steps

Excellent work! You've implemented comprehensive graph algorithms that provide:
- **Advanced pathfinding capabilities** for routing and recommendation
- **Sophisticated centrality analysis** for influence and importance ranking
- **Robust community detection** for user segmentation and targeting
- **Network resilience assessment** for risk management and optimization

**In Lab 8**, we'll build upon these algorithms to:
- **Implement advanced community detection** with hierarchical clustering
- **Build comprehensive recommendation engines** using multiple algorithms
- **Create real-time monitoring systems** for network health and performance
- **Develop predictive models** using graph features and machine learning integration

## Practice Exercises (Optional)

Extend your algorithmic capabilities:

1. **Multi-Layer Centrality:** Calculate centrality across different relationship types
2. **Dynamic Algorithms:** Implement incremental updates for real-time systems
3. **Scalability Testing:** Benchmark algorithms with larger synthetic datasets
4. **Hybrid Approaches:** Combine multiple algorithms for enhanced accuracy
5. **Business Metrics:** Create custom algorithms for specific business KPIs

## Quick Reference

**Algorithm Implementation Patterns:**
```cypher
// BFS Template
MATCH path = (start)-[:REL*1..max_depth]->(target)
WITH target, min(length(path)) AS shortest_distance
RETURN target, shortest_distance

// Centrality Template
MATCH (node)
OPTIONAL MATCH (node)-[relations]-(neighbors)
WITH node, count(relations) AS degree
RETURN node, degree, normalize(degree) AS centrality

// Community Detection Template
MATCH (node)-[:REL]-(neighbor)
WITH node, collect(neighbor.label) AS neighbor_labels
SET node.label = most_frequent(neighbor_labels)
```

---

**🎉 Lab 7 Complete!**

You now possess advanced graph algorithm implementation skills that enable sophisticated network analysis, influence measurement, and community detection. These algorithmic foundations prepare you for building production-ready recommendation systems and network monitoring applications in Lab 8!