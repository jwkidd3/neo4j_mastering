# Lab 8: Community Detection & Real-World Applications

**Duration:** 75 minutes  
**Objective:** Build simple community detection and recommendation systems using your social network data

## Prerequisites

- Completed Labs 1-7 with social network data
- Connected to Neo4j via Desktop 2 (container name: neo4j)

## Learning Outcomes

By the end of this lab, you will:
- Create simple communities based on user attributes
- Build basic recommendation systems
- Analyze network patterns
- Monitor network health

## Part 1: Simple Community Detection (15 minutes)

### Step 1: Check Your Data

```cypher
:use social
```

```cypher
MATCH (u:User)
RETURN count(u) AS total_users,
       collect(u.username)[0..5] AS sample_users
```

```cypher
MATCH (u:User)
RETURN u.username AS user,
       u.location AS location,
       u.profession AS profession
ORDER BY u.location, u.profession
```

### Step 2: Create Location-Based Communities

```cypher
MATCH (u:User)
WHERE u.location IS NOT NULL
SET u.community = 'LOC_' + replace(u.location, ' ', '_')
RETURN u.location AS location,
       u.community AS community_id,
       count(u) AS users_in_community
ORDER BY users_in_community DESC
```

```cypher
// Check what communities were created and what users still need assignment
MATCH (u:User)
RETURN u.username AS user,
       u.location AS location,
       u.profession AS profession,
       u.community AS current_community
ORDER BY u.community
```

```cypher
// For users without location, use profession
MATCH (u:User)
WHERE u.community IS NULL AND u.profession IS NOT NULL
SET u.community = 'PROF_' + replace(u.profession, ' ', '_')
RETURN u.profession AS profession,
       u.community AS community_id,
       count(u) AS users_in_community
ORDER BY users_in_community DESC
```

```cypher
// Check if any users still need assignment
MATCH (u:User)
WHERE u.community IS NULL
RETURN count(u) AS users_without_community,
       collect(u.username) AS unassigned_users
```

```cypher
// Give remaining users a default community
MATCH (u:User)
WHERE u.community IS NULL
SET u.community = 'DEFAULT'
RETURN 'DEFAULT' AS community_id,
       count(u) AS users_in_community
```

### Step 3: View Communities

```cypher
MATCH (u:User)
RETURN u.community AS community,
       count(u) AS size,
       collect(u.username) AS members
ORDER BY size DESC
```

## Part 2: Simple Recommendations (20 minutes)

### Step 4: Find a User for Testing

```cypher
MATCH (u:User)
RETURN u.username AS available_users,
       u.location AS location,
       u.community AS community
ORDER BY u.username
LIMIT 5
```

### Step 5: Friend Recommendations

```cypher
MATCH (target:User)
WITH target
LIMIT 1

MATCH (other:User)
WHERE other <> target 
  AND NOT (target)-[:FOLLOWS]->(other)

RETURN target.username AS for_user,
       other.username AS recommended_friend,
       COALESCE(other.location, 'Unknown') AS location,
       COALESCE(other.profession, 'Unknown') AS profession,
       other.community AS community
LIMIT 5
```

### Step 6: Content Recommendations

```cypher
MATCH (target:User)
WITH target
LIMIT 1

MATCH (post:Post)<-[:POSTED]-(author:User)
WHERE author <> target
  AND NOT (target)-[:LIKED]->(post)

RETURN target.username AS for_user,
       post.id AS post_id,
       left(post.content, 60) + '...' AS preview,
       author.username AS posted_by,
       COALESCE(post.tags, []) AS topics
ORDER BY post.timestamp DESC
LIMIT 5
```

### Step 7: Topic Recommendations

```cypher
MATCH (target:User)
WITH target
LIMIT 1

MATCH (topic:Topic)
WHERE NOT (target)-[:INTERESTED_IN]->(topic)

RETURN target.username AS for_user,
       topic.name AS recommended_topic,
       'Available topic' AS reason
LIMIT 5
```

## Part 3: Network Analysis (20 minutes)

### Step 8: Community Analysis

```cypher
MATCH (u:User)
RETURN u.community AS community,
       count(u) AS community_size,
       collect(u.username) AS members
ORDER BY community_size DESC
```

### Step 9: User Activity Levels

```cypher
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
OPTIONAL MATCH (u)-[:FOLLOWS]->(f:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)

WITH u,
     count(DISTINCT p) AS posts,
     count(DISTINCT f) AS follows,
     count(DISTINCT follower) AS followers

RETURN u.username AS user,
       u.community AS community,
       posts,
       follows,
       followers,
       posts + follows + followers AS activity_score,
       CASE 
         WHEN posts + follows + followers > 8 THEN 'Very Active'
         WHEN posts + follows + followers > 4 THEN 'Active'
         WHEN posts + follows + followers > 0 THEN 'Moderate'
         ELSE 'Inactive'
       END AS activity_level
ORDER BY activity_score DESC
```

### Step 10: Popular Content

```cypher
MATCH (p:Post)<-[:POSTED]-(author:User)
RETURN COALESCE(p.id, 'post_' + toString(id(p))) AS post_id,
       left(COALESCE(p.content, 'No content'), 50) + '...' AS preview,
       author.username AS author,
       author.community AS author_community,
       COALESCE(p.tags, []) AS topics
ORDER BY p.timestamp DESC
LIMIT 10
```

## Part 4: Simple Monitoring (20 minutes)

### Step 11: Network Health Dashboard

```cypher
// Overall network statistics
MATCH (u:User) 
WITH count(u) AS total_users

MATCH ()-[f:FOLLOWS]->() 
WITH total_users, count(f) AS total_follows

MATCH (p:Post)
WITH total_users, total_follows, count(p) AS total_posts

MATCH ()-[l:LIKES]->()
WITH total_users, total_follows, total_posts, count(l) AS total_likes

RETURN total_users AS users,
       total_follows AS connections,
       total_posts AS posts,
       total_likes AS likes,
       round(total_follows * 1.0 / total_users * 100) / 100 AS avg_connections_per_user,
       round(total_likes * 1.0 / total_posts * 100) / 100 AS avg_likes_per_post
```

### Step 12: Community Health

```cypher
MATCH (u:User)
RETURN u.community AS community,
       count(u) AS community_size,
       'Basic community info' AS status
ORDER BY community_size DESC
```

### Step 13: Activity Monitoring

```cypher
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
WHERE p.timestamp > datetime() - duration('P7D')  // Last 7 days

WITH u, count(p) AS recent_posts
WITH collect(recent_posts) AS all_posts,
     avg(recent_posts) AS avg_posts

UNWIND all_posts AS user_posts
WITH user_posts, avg_posts,
     CASE 
       WHEN user_posts > avg_posts * 2 THEN 'High Activity'
       WHEN user_posts > avg_posts THEN 'Above Average'
       WHEN user_posts > 0 THEN 'Normal'
       ELSE 'Inactive'
     END AS activity_level

RETURN activity_level,
       count(*) AS user_count
ORDER BY 
  CASE activity_level
    WHEN 'High Activity' THEN 1
    WHEN 'Above Average' THEN 2
    WHEN 'Normal' THEN 3
    ELSE 4
  END
```

## Lab Completion Checklist

- [ ] Connected to social database and verified data
- [ ] Created location-based communities
- [ ] Built friend recommendations using community data
- [ ] Generated content and topic recommendations
- [ ] Analyzed community connectivity and health
- [ ] Measured user activity levels
- [ ] Identified popular content
- [ ] Created network health dashboard
- [ ] Monitored community and user activity

## Key Concepts Mastered

1. **Simple Community Detection:** Attribute-based grouping (location, profession)
2. **Multi-Signal Recommendations:** Friends, content, and topics using community data
3. **Network Analysis:** Community connectivity and user activity patterns
4. **Basic Monitoring:** Health metrics and activity tracking

## Summary

Great work! You've built a practical community detection and recommendation system using simple, reliable techniques:

- **Communities** based on real user attributes (location, profession)
- **Recommendations** that work with your actual data
- **Analytics** that provide meaningful insights
- **Monitoring** for network health and activity

These simple approaches are often more effective than complex algorithms because they:
- Work reliably with small datasets
- Are easy to understand and debug
- Provide clear, actionable insights
- Can be easily extended and improved

## Next Steps

**Moving to Day 3**, you'll use these foundations to:
- Build enterprise data models with proper security
- Create Python applications using these recommendation algorithms
- Deploy production systems with monitoring and optimization
- Develop full-stack applications with web interfaces

---

**🎉 Lab 8 Complete!**

You now have practical experience with community detection, recommendation systems, and network analysis using simple, effective techniques that work with real data!