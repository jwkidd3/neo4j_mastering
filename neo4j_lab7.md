# Lab 7: Pathfinding & Centrality Measures

**Duration:** 90 minutes  
**Objective:** Implement advanced graph algorithms for pathfinding, centrality analysis, and network topology understanding

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop** (connection client)
- **Docker Desktop** with Neo4j Enterprise 2025.06.0 running (container name: neo4j)
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

✅ **From Previous Labs:**
- **Completed Labs 1-6** successfully with comprehensive social network analytics experience
- **"Social" database** created and populated from Lab 3
- **Understanding of variable-length paths** and complex query patterns from Lab 5
- **Business intelligence concepts** from Lab 6
- **Remote connection** set up to Docker Neo4j Enterprise instance
- **Familiarity with Neo4j Browser** interface and optimization techniques

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

### Step 1: Connect to Social Database and Verify Advanced Data
```cypher
// Switch to social database from Lab 3
:use social
```

```cypher
// Verify comprehensive data from all previous labs
MATCH (u:User) 
RETURN count(u) AS total_users,
       count(DISTINCT u.location) AS unique_locations,
       count(DISTINCT u.profession) AS unique_professions
```

```cypher
MATCH ()-[r:FOLLOWS]->() 
RETURN count(r) AS follow_relationships,
       avg(COUNT { (startNode(r))<-[:FOLLOWS]-() }) AS avg_followers
```

```cypher
MATCH ()-[r:LIKES]->() 
RETURN count(r) AS like_interactions
```

```cypher
MATCH (p:Post)
OPTIONAL MATCH (p)-[:TAGGED_WITH]->(t:Topic)
RETURN count(p) AS total_posts,
       count(DISTINCT t) AS unique_post_topics
```

**Expected Results:** 6 users, 8+ follows, 6+ likes, 8+ topics, 6+ posts

### Step 2: Add Algorithm Infrastructure and Relationship Weights
```cypher
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

### Step 3: Implement Breadth-First Search (BFS) Algorithm
```cypher
// BFS implementation for unweighted shortest paths
WITH ['alice_codes', 'carol_creates'] AS target_users
UNWIND target_users AS start_username

MATCH (source:User {username: start_username})

// BFS traversal to find shortest paths to all reachable nodes
CALL (source) {
  MATCH path = (source)-[:FOLLOWS*1..5]->(destination:User)
  WITH destination, min(length(path)) AS shortest_distance
  WHERE shortest_distance <= 4  // Limit to reasonable distances
  RETURN destination, shortest_distance
}

RETURN source.username AS source_user,
       destination.username AS destination_user,
       destination.fullName AS destination_name,
       shortest_distance,
       // Path efficiency classification
       CASE shortest_distance
         WHEN 1 THEN 'Direct Connection'
         WHEN 2 THEN 'Friend of Friend'
         WHEN 3 THEN 'Extended Network'
         ELSE 'Distant Network'
       END AS connection_type,
       // Reachability score (inverse of distance)
       round(100.0 / shortest_distance) AS reachability_score
ORDER BY source_user, shortest_distance, destination_user
```

### Step 4: Implement Dijkstra's Algorithm for Weighted Paths
```cypher
// Dijkstra's algorithm implementation using trust scores and relationship weights
MATCH (alice:User {username: 'alice_codes'})

// Find weighted shortest paths considering trust scores and relationship strength
CALL (alice) {
  MATCH path = (alice)-[rels:FOLLOWS*1..4]->(destination:User)
  WITH destination, path, rels,
       reduce(total_weight = 0, rel IN rels | total_weight + rel.weight) AS path_weight,
       reduce(trust_product = 1.0, rel IN rels | trust_product * rel.trust_score) AS path_trust
  
  // Calculate composite pathfinding score (lower is better for weight, higher for trust)
  WITH destination, path, path_weight, path_trust,
       path_weight - (path_trust * 2) AS composite_score  // Trust reduces effective weight
  
  // Find best path to each destination
  ORDER BY destination, composite_score
  WITH destination, collect({path: path, weight: path_weight, trust: path_trust, score: composite_score})[0] AS best_path
  
  RETURN destination, best_path.path AS optimal_path, best_path.weight AS total_weight, 
         best_path.trust AS trust_score, best_path.score AS optimization_score
}

RETURN destination.username AS destination_user,
       destination.fullName AS destination_name,
       length(optimal_path) AS path_length,
       total_weight AS cumulative_weight,
       round(trust_score * 1000) / 1000 AS path_trust_score,
       round(optimization_score * 100) / 100 AS dijkstra_score,
       // Path quality assessment
       CASE 
         WHEN trust_score > 0.7 AND total_weight <= 6 THEN 'High Quality Path'
         WHEN trust_score > 0.5 AND total_weight <= 10 THEN 'Good Quality Path'
         WHEN trust_score > 0.3 THEN 'Fair Quality Path'
         ELSE 'Low Quality Path'
       END AS path_quality,
       [node IN nodes(optimal_path) | node.username] AS path_nodes
ORDER BY dijkstra_score ASC, trust_score DESC
LIMIT 8
```

### Step 5: All-Pairs Shortest Path Analysis
```cypher
// Calculate shortest paths between all user pairs for network analysis
MATCH (source:User), (target:User)
WHERE source <> target AND id(source) < id(target)  // Avoid duplicates and self-loops

OPTIONAL MATCH path = shortestPath((source)-[:FOLLOWS*1..6]-(target))

WITH source, target, 
     CASE WHEN path IS NOT NULL THEN length(path) ELSE null END AS distance,
     path IS NOT NULL AS is_connected

// Collect all distance measurements
WITH collect({
  source: source.username,
  target: target.username,
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

### Step 6: Path Redundancy and Alternative Routes Analysis
```cypher
// Find alternative paths and analyze path redundancy for network resilience
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

### Step 7: Degree Centrality Analysis
```cypher
// Calculate comprehensive degree centrality (in-degree, out-degree, total)
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

### Step 8: Betweenness Centrality Approximation
```cypher
// Approximate betweenness centrality by counting shortest path appearances
MATCH (source:User), (target:User)
WHERE source <> target AND id(source) < id(target)

// Find shortest paths between all pairs
MATCH path = shortestPath((source)-[:FOLLOWS*]-(target))
WHERE length(path) <= 5  // Limit for performance

// Extract intermediate nodes (excluding source and target)
WITH path, [node IN nodes(path)[1..-1] WHERE node:User] AS intermediate_nodes
UNWIND intermediate_nodes AS intermediate_node

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

### Step 9: Closeness Centrality Calculation
```cypher
// Calculate closeness centrality based on average shortest path distances
MATCH (center:User)

// Find shortest paths from this user to all other reachable users
CALL {
  WITH center
  MATCH path = shortestPath((center)-[:FOLLOWS*1..6]-(other:User))
  WHERE other <> center
  RETURN length(path) AS distance
}

WITH center, collect(distance) AS all_distances
WHERE size(all_distances) > 0

WITH center, all_distances,
     reduce(sum = 0, d IN all_distances | sum + d) AS total_distance,
     size(all_distances) AS reachable_nodes

// Calculate closeness centrality (inverse of average distance)
WITH center, all_distances, total_distance, reachable_nodes,
     total_distance * 1.0 / reachable_nodes AS average_distance,
     reachable_nodes * 1.0 / total_distance AS closeness_centrality

RETURN center.username AS username,
       center.fullName AS full_name,
       reachable_nodes AS nodes_reachable,
       round(average_distance * 100) / 100 AS avg_distance_to_others,
       round(closeness_centrality * 1000) / 1000 AS closeness_centrality,
       // Centrality classification
       CASE 
         WHEN closeness_centrality > 0.4 THEN 'Highly Central'
         WHEN closeness_centrality > 0.25 THEN 'Moderately Central'
         WHEN closeness_centrality > 0.15 THEN 'Somewhat Central'
         ELSE 'Peripheral'
       END AS centrality_classification,
       // Efficiency score for reaching network
       round(reachable_nodes * 100.0 / total_distance) AS network_efficiency_score
ORDER BY closeness_centrality DESC
```

### Step 10: PageRank Algorithm Implementation
```cypher
// Initialize PageRank values
MATCH (user:User)
SET user.pagerank = 1.0

WITH count(user) AS total_users, 0.85 AS damping_factor
MATCH (user:User)

// Calculate PageRank using power iteration method
OPTIONAL MATCH (user)<-[incoming:FOLLOWS]-(follower:User)
OPTIONAL MATCH (follower)-[:FOLLOWS]->(following_target:User)

WITH user, total_users, damping_factor,
     collect({
       follower: follower,
       follower_pagerank: follower.pagerank,
       follower_out_degree: COUNT { (follower)-[:FOLLOWS]->() }
     }) AS incoming_links

WITH user, total_users, damping_factor, incoming_links,
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

### Step 11: Eigenvector Centrality Approximation
```cypher
// Simplified eigenvector centrality calculation based on follower influence
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

### Step 12: Triangle Counting and Clustering Coefficient
```cypher
// Count triangles and calculate clustering coefficient for community detection
MATCH (u:User)

// Find triangles: user follows two people who follow each other
OPTIONAL MATCH (u)-[:FOLLOWS]->(friend1:User)-[:FOLLOWS]->(friend2:User)
WHERE (u)-[:FOLLOWS]->(friend2)

WITH u, count(DISTINCT friend1) AS triangles,
     COUNT { (u)-[:FOLLOWS]->() } AS out_degree

// Calculate possible triangles and clustering coefficient
WITH u, triangles, out_degree,
     CASE WHEN out_degree >= 2 
          THEN (out_degree * (out_degree - 1)) / 2 
          ELSE 0 END AS possible_triangles

WITH u, triangles, out_degree, possible_triangles,
     // Clustering coefficient (0-1)
     CASE WHEN possible_triangles > 0 
          THEN round(triangles * 1000.0 / possible_triangles) / 1000
          ELSE 0.0 END AS clustering_coefficient

RETURN u.username AS username,
       u.fullName AS full_name,
       triangles AS triangle_count,
       out_degree AS connections,
       possible_triangles,
       clustering_coefficient,
       // Community structure indicator
       CASE 
         WHEN triangles > 2 AND clustering_coefficient > 0.5 THEN 'Dense Community Core'
         WHEN triangles > 1 AND clustering_coefficient > 0.3 THEN 'Community Member'
         WHEN triangles > 0 THEN 'Loosely Connected'
         ELSE 'Isolated or Star Node'
       END AS community_role
ORDER BY clustering_coefficient DESC, triangle_count DESC
```

### Step 13: Label Propagation Community Detection
```cypher
// Initialize community labels with user IDs
MATCH (u:User)
SET u.community_label = u.username

// Simulate one iteration of label propagation
WITH 1 AS iteration
MATCH (u:User)-[:FOLLOWS]->(neighbor:User)

// For each user, collect neighbor labels and find most common
WITH u, collect(neighbor.community_label) AS neighbor_labels
WHERE size(neighbor_labels) > 0

// Find most frequent label using APOC
WITH u, neighbor_labels,
     apoc.coll.frequencies(neighbor_labels) AS label_frequencies

// Sort frequencies and get the top one
WITH u, label_frequencies
ORDER BY u.username
WITH u, 
     reduce(top = null, freq IN label_frequencies | 
       CASE WHEN top IS NULL OR freq.count > top.count 
            THEN freq 
            ELSE top END
     ) AS most_frequent_label

// Update community label if neighbors suggest change
SET u.community_label = COALESCE(most_frequent_label.item, u.community_label)

// Required WITH clause after SET operation
WITH count(*) AS updated_users

// Analyze detected communities
MATCH (u:User)
WITH u.community_label AS community, collect(u) AS members
WHERE size(members) > 1

// Calculate internal connectivity first
WITH community, members,
     reduce(internal_edges = 0, member IN members |
       internal_edges + COUNT { (member)-[:FOLLOWS]->(:User {community_label: community}) }
     ) AS internal_connections

RETURN community AS community_id,
       size(members) AS community_size,
       [member IN members | member.username] AS community_members,
       [member IN members | member.fullName] AS member_names,
       internal_connections,
       // Community cohesion metrics
       CASE 
         WHEN size(members) > 2 AND internal_connections > size(members) THEN 'Cohesive Community'
         WHEN internal_connections > 0 THEN 'Loose Community'
         ELSE 'Disconnected Group'
       END AS community_cohesion
ORDER BY community_size DESC, internal_connections DESC
```

### Step 14: Interest-Based Community Analysis
```cypher
// Analyze communities based on shared interests and topic preferences
MATCH (u:User)-[:INTERESTED_IN]->(topic:Topic)
WITH topic, collect(u) AS interested_users
WHERE size(interested_users) >= 2

// Analyze cross-topic user overlaps
WITH topic, interested_users,
     // Calculate internal social connections
     reduce(social_connections = 0, user IN interested_users |
       social_connections + COUNT { (user)-[:FOLLOWS]->(:User) }
     ) AS total_social_connections

RETURN topic.name AS interest_topic,
       topic.description AS topic_description,
       size(interested_users) AS community_size,
       [user IN interested_users | user.username] AS community_members,
       total_social_connections AS social_connectivity,
       round(total_social_connections * 1.0 / size(interested_users)) AS avg_connections_per_member,
       // Interest community strength
       CASE 
         WHEN size(interested_users) > 3 AND total_social_connections > size(interested_users) * 2 THEN 'Strong Interest Community'
         WHEN total_social_connections > size(interested_users) THEN 'Moderate Interest Community'
         WHEN total_social_connections > 0 THEN 'Weak Interest Community'
         ELSE 'Isolated Interest Group'
       END AS community_strength
ORDER BY community_size DESC, social_connectivity DESC
```

## Part 4: Network Topology and Resilience Analysis (20 minutes)

### Step 15: Critical Node Identification
```cypher
// Identify critical nodes whose removal would fragment the network
MATCH (critical_candidate:User)

// Calculate the impact of removing this user
CALL {
  WITH critical_candidate
  
  // Find all users except the critical candidate
  MATCH (remaining:User)
  WHERE remaining <> critical_candidate
  
  // Check connectivity without the critical candidate
  MATCH (source:User), (target:User)
  WHERE source <> target AND source <> critical_candidate AND target <> critical_candidate
    AND id(source) < id(target)
  
  // Find paths that don't go through the critical candidate
  OPTIONAL MATCH path = shortestPath((source)-[:FOLLOWS*1..6]-(target))
  WHERE NONE(node IN nodes(path) WHERE node = critical_candidate)
  
  WITH source, target, path IS NOT NULL AS can_connect_without_critical
  
  RETURN sum(CASE WHEN can_connect_without_critical THEN 1 ELSE 0 END) AS connected_pairs_without,
         count(*) AS total_pairs_without
}

// Calculate baseline connectivity with all nodes
CALL {
  MATCH (source:User), (target:User)
  WHERE source <> target AND id(source) < id(target)
  
  OPTIONAL MATCH path = shortestPath((source)-[:FOLLOWS*1..6]-(target))
  
  RETURN sum(CASE WHEN path IS NOT NULL THEN 1 ELSE 0 END) AS connected_pairs_baseline,
         count(*) AS total_pairs_baseline
}

WITH critical_candidate, connected_pairs_without, total_pairs_without,
     connected_pairs_baseline, total_pairs_baseline,
     connected_pairs_baseline - connected_pairs_without AS connectivity_lost

RETURN critical_candidate.username AS username,
       critical_candidate.fullName AS full_name,
       connected_pairs_baseline AS baseline_connectivity,
       connected_pairs_without AS connectivity_without_user,
       connectivity_lost AS pairs_disconnected,
       round(connectivity_lost * 100.0 / connected_pairs_baseline) AS connectivity_impact_percent,
       // Critical node classification
       CASE 
         WHEN connectivity_lost > connected_pairs_baseline * 0.2 THEN 'Extremely Critical'
         WHEN connectivity_lost > connected_pairs_baseline * 0.1 THEN 'Highly Critical'
         WHEN connectivity_lost > connected_pairs_baseline * 0.05 THEN 'Moderately Critical'
         WHEN connectivity_lost > 0 THEN 'Somewhat Critical'
         ELSE 'Non-Critical'
       END AS criticality_level
ORDER BY connectivity_impact_percent DESC, connectivity_lost DESC
LIMIT 8
```

### Step 16: Bridge Detection and Network Fragmentation Analysis
```cypher
// Identify bridge edges critical for network connectivity
MATCH (source:User)-[bridge:FOLLOWS]->(target:User)

// Test network connectivity without this specific edge
CALL (source, target, bridge) {
  // Look for alternative paths that don't use this bridge edge
  OPTIONAL MATCH alt_path = (source)-[:FOLLOWS*1..4]-(target)
  WHERE length(alt_path) > 1  // Must be longer than direct connection
    AND NOT bridge IN relationships(alt_path)
  
  RETURN alt_path IS NOT NULL AS has_alternative_path
}

WITH source, target, bridge, has_alternative_path

RETURN source.username AS source_user,
       target.username AS target_user,
       source.fullName AS source_name,
       target.fullName AS target_name,
       COALESCE(bridge.relationship, 'standard') AS relationship_type,
       COALESCE(bridge.trust_score, 0.5) AS trust_score,
       has_alternative_path AS has_alternatives,
       // Bridge importance based on alternative paths
       CASE 
         WHEN NOT has_alternative_path THEN 'Critical Bridge - No Alternatives'
         WHEN COALESCE(bridge.trust_score, 0.5) > 0.8 THEN 'High-Trust Bridge'
         WHEN COALESCE(bridge.relationship, 'standard') IN ['close', 'friend'] THEN 'Strong Social Bridge'
         ELSE 'Standard Bridge'
       END AS bridge_importance,
       // Impact of removal
       CASE 
         WHEN NOT has_alternative_path THEN 'Network Fragmentation Risk'
         WHEN COALESCE(bridge.trust_score, 0.5) > 0.7 THEN 'Reduced Network Quality'
         ELSE 'Minimal Impact'
       END AS removal_impact,
       // Additional bridge metrics
       CASE WHEN NOT has_alternative_path THEN 1 ELSE 0 END AS is_critical_bridge
ORDER BY is_critical_bridge DESC, trust_score DESC
```

### Step 17: Network Diameter and Small-World Analysis
```cypher
// Calculate network diameter and analyze small-world properties
MATCH (source:User), (target:User)
WHERE source <> target AND id(source) < id(target)

OPTIONAL MATCH path = shortestPath((source)-[:FOLLOWS*1..8]-(target))

WITH collect(CASE WHEN path IS NOT NULL THEN length(path) ELSE null END) AS all_distances

WITH [d IN all_distances WHERE d IS NOT NULL] AS connected_distances,
     size([d IN all_distances WHERE d IS NOT NULL]) AS connected_pairs,
     size(all_distances) AS total_pairs

// Calculate network metrics first
WITH connected_distances, connected_pairs, total_pairs,
     reduce(sum = 0, d IN connected_distances | sum + d) AS total_distance,
     max(connected_distances) AS network_diameter,
     min(connected_distances) AS minimum_distance

// Calculate average path length
WITH connected_distances, connected_pairs, total_pairs, total_distance, network_diameter, minimum_distance,
     round(total_distance * 1.0 / size(connected_distances) * 100) / 100 AS average_path_length

RETURN network_diameter,
       minimum_distance,
       average_path_length,
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

- [ ] Connected to social database and verified comprehensive data from previous labs
- [ ] Added algorithm infrastructure with relationship weights and trust scores
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
- [ ] Identified critical nodes and network vulnerability points
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

### Performance issues with large algorithms:
```cypher
// Use LIMIT to test queries with smaller datasets
MATCH (n:User) RETURN n LIMIT 100

// Profile algorithms to identify bottlenecks
PROFILE MATCH path = shortestPath((a:User)-[:FOLLOWS*]-(b:User))
RETURN length(path)
```

---

**🎉 Lab 7 Complete!**

You now possess advanced graph algorithm implementation skills that enable sophisticated network analysis, influence measurement, and community detection. These algorithmic foundations prepare you for building production-ready recommendation systems and network monitoring applications in Lab 8!