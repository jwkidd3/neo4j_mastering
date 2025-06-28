# Lab 6: Social Network Analytics & Business Intelligence

**Duration:** 90 minutes  
**Objective:** Build comprehensive social network analytics, KPI dashboards, and business intelligence reporting systems

## Prerequisites

- Completed Labs 1-5 successfully with advanced path analysis experience
- Understanding of variable-length paths and complex query patterns from Lab 5
- Familiarity with aggregation functions and statistical analysis
- Knowledge of social network data model from Lab 3

## Learning Outcomes

By the end of this lab, you will:
- Calculate comprehensive engagement metrics and user activity patterns
- Analyze content popularity and viral spread mechanisms across the network
- Build temporal analysis of network growth and evolution over time
- Create sophisticated user segmentation based on behavior and demographics
- Develop executive-level KPI dashboards with actionable business insights
- Implement cohort analysis for user retention and engagement tracking
- Perform sentiment analysis on content and interaction patterns
- Build predictive analytics for content performance and user growth

## Part 1: User Engagement Analytics (20 minutes)

### Step 1: Comprehensive User Activity Metrics
```cypher
// Calculate detailed user engagement and activity metrics
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)<-[:REPLIES_TO]-(comment:Comment)
OPTIONAL MATCH (u)-[:LIKES]->(liked_content)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)

WITH u,
     count(DISTINCT post) AS posts_created,
     count(DISTINCT liker) AS total_likes_received,
     count(DISTINCT comment) AS total_comments_received,
     count(DISTINCT liked_content) AS content_liked,
     count(DISTINCT following) AS users_following,
     count(DISTINCT follower) AS users_followers

RETURN u.username AS username,
       u.fullName AS full_name,
       u.location AS location,
       posts_created,
       total_likes_received,
       total_comments_received,
       content_liked,
       users_following,
       users_followers,
       // Calculate engagement ratios
       CASE WHEN posts_created > 0 
            THEN round(total_likes_received * 1.0 / posts_created * 100) / 100 
            ELSE 0 END AS avg_likes_per_post,
       CASE WHEN users_followers > 0 
            THEN round(total_likes_received * 1.0 / users_followers * 100) 
            ELSE 0 END AS engagement_rate_percent,
       CASE WHEN users_following > 0 
            THEN round(users_followers * 1.0 / users_following * 100) / 100 
            ELSE 0 END AS follower_following_ratio,
       // Activity score calculation
       posts_created * 3 + content_liked * 1 + users_following * 2 AS activity_score
ORDER BY engagement_rate_percent DESC, activity_score DESC
```

### Step 2: Content Performance Analysis
```cypher
// Analyze post performance with detailed engagement metrics
MATCH (u:User)-[:POSTED]->(post:Post)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)<-[:REPLIES_TO]-(comment:Comment)<-[:COMMENTED_ON]-(commenter:User)
OPTIONAL MATCH (post)-[:TAGGED_WITH]->(topic:Topic)

WITH post, u,
     count(DISTINCT liker) AS likes_count,
     count(DISTINCT comment) AS comments_count,
     count(DISTINCT commenter) AS unique_commenters,
     collect(DISTINCT topic.name) AS topics,
     duration.between(post.timestamp, datetime()).days AS days_since_posted

// Calculate viral coefficient and engagement velocity
WITH post, u, likes_count, comments_count, unique_commenters, topics, days_since_posted,
     likes_count + comments_count * 2 AS total_engagement,
     CASE WHEN days_since_posted > 0 
          THEN round((likes_count + comments_count) * 1.0 / days_since_posted * 100) / 100
          ELSE likes_count + comments_count END AS engagement_velocity

RETURN post.postId AS post_id,
       left(post.content, 50) + '...' AS content_preview,
       u.username AS author,
       likes_count,
       comments_count,
       unique_commenters,
       total_engagement,
       engagement_velocity,
       days_since_posted,
       topics,
       // Performance classification
       CASE 
         WHEN total_engagement > 50 THEN 'Viral'
         WHEN total_engagement > 25 THEN 'High Performing'
         WHEN total_engagement > 10 THEN 'Good Performing'
         WHEN total_engagement > 5 THEN 'Average'
         ELSE 'Low Performing'
       END AS performance_category,
       // Virality score (engagement relative to author's follower count)
       CASE WHEN u.followerCount > 0 
            THEN round(total_engagement * 100.0 / u.followerCount)
            ELSE total_engagement END AS virality_score
ORDER BY total_engagement DESC, engagement_velocity DESC
LIMIT 15
```

### Step 3: Topic Performance and Trending Analysis
```cypher
// Analyze topic performance and identify trending topics
MATCH (topic:Topic)<-[:TAGGED_WITH]-(post:Post)<-[:POSTED]-(author:User)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)<-[:REPLIES_TO]-(comment:Comment)

// Calculate recency weights for trending analysis
WITH topic, post, author,
     count(DISTINCT liker) AS post_likes,
     count(DISTINCT comment) AS post_comments,
     duration.between(post.timestamp, datetime()).days AS days_old,
     // Exponential decay for recency (more recent posts weighted higher)
     exp(-0.1 * duration.between(post.timestamp, datetime()).days) AS recency_weight

WITH topic,
     count(DISTINCT post) AS total_posts,
     count(DISTINCT author) AS unique_authors,
     sum(post_likes) AS total_likes,
     sum(post_comments) AS total_comments,
     avg(post_likes) AS avg_likes_per_post,
     sum(post_likes * recency_weight) + sum(post_comments * recency_weight * 2) AS trending_score,
     max(days_old) AS oldest_post_days,
     min(days_old) AS newest_post_days

RETURN topic.name AS topic_name,
       total_posts,
       unique_authors,
       total_likes,
       total_comments,
       round(avg_likes_per_post * 100) / 100 AS avg_likes_per_post,
       round(trending_score * 100) / 100 AS trending_score,
       oldest_post_days,
       newest_post_days,
       // Topic health indicators
       CASE WHEN trending_score > 100 THEN 'Hot Trending'
            WHEN trending_score > 50 THEN 'Trending'
            WHEN trending_score > 20 THEN 'Active'
            WHEN trending_score > 5 THEN 'Moderate'
            ELSE 'Low Activity' END AS trend_status,
       // Author diversity (high = not dominated by single author)
       round(unique_authors * 100.0 / total_posts) AS author_diversity_percent
ORDER BY trending_score DESC, total_posts DESC
```

### Step 4: User Influence and Authority Metrics
```cypher
// Calculate comprehensive influence metrics for users
MATCH (u:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (u)-[:POSTED]->(post2:Post)<-[:REPLIES_TO]-(comment:Comment)

// Calculate influence through content engagement
WITH u,
     count(DISTINCT follower) AS direct_followers,
     count(DISTINCT liker) AS content_likes,
     count(DISTINCT comment) AS content_comments,
     count(DISTINCT post) AS total_posts

// Calculate second-degree influence (followers of followers)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower)-[:FOLLOWS]->(fof:User)
WITH u, direct_followers, content_likes, content_comments, total_posts,
     count(DISTINCT fof) AS second_degree_reach

// Calculate influence through interactions with high-influence users
OPTIONAL MATCH (u)-[:LIKES|COMMENTED_ON]->(content)<-[:POSTED]-(influencer:User)
WHERE influencer.followerCount > 1000
WITH u, direct_followers, content_likes, content_comments, total_posts, second_degree_reach,
     count(DISTINCT influencer) AS interactions_with_influencers

RETURN u.username AS username,
       u.fullName AS full_name,
       direct_followers,
       second_degree_reach,
       content_likes,
       content_comments,
       total_posts,
       interactions_with_influencers,
       // Authority scores
       CASE WHEN total_posts > 0 
            THEN round(content_likes * 1.0 / total_posts * 100) / 100 
            ELSE 0 END AS content_authority,
       round((direct_followers * 2 + second_degree_reach * 0.5 + content_likes * 3) / 10) AS influence_score,
       // Influence classification
       CASE 
         WHEN direct_followers > 2000 THEN 'Macro Influencer'
         WHEN direct_followers > 1000 THEN 'Micro Influencer'
         WHEN direct_followers > 500 THEN 'Rising Influencer'
         WHEN content_likes > 100 THEN 'Content Authority'
         ELSE 'Community Member'
       END AS influence_tier,
       // Engagement quality (high engagement relative to followers)
       CASE WHEN direct_followers > 0 
            THEN round(content_likes * 100.0 / direct_followers)
            ELSE content_likes END AS engagement_quality
ORDER BY influence_score DESC, content_authority DESC
```

## Part 2: Temporal Network Analysis (25 minutes)

### Step 5: Network Growth Over Time
```cypher
// Analyze how the network has grown over time
MATCH (u:User)
WITH date.truncate('month', u.joinDate) AS join_month, count(u) AS new_users
ORDER BY join_month

// Calculate cumulative user growth
WITH collect({month: join_month, new_users: new_users}) AS monthly_data
UNWIND range(0, size(monthly_data)-1) AS i
WITH monthly_data[i] AS current_month, 
     reduce(cumulative = 0, j IN range(0, i) | cumulative + monthly_data[j].new_users) AS cumulative_users

RETURN current_month.month AS month,
       current_month.new_users AS new_users_this_month,
       cumulative_users,
       CASE WHEN i > 0 
            THEN round((current_month.new_users * 100.0 / cumulative_users) * 100) / 100
            ELSE 100.0 END AS growth_rate_percent
ORDER BY month
```

### Step 6: Content Creation Patterns Over Time
```cypher
// Analyze content creation patterns and peak activity periods
MATCH (u:User)-[:POSTED]->(post:Post)
WITH date.truncate('week', post.timestamp) AS week,
     count(post) AS posts_this_week,
     count(DISTINCT u) AS active_authors

OPTIONAL MATCH (post2:Post)<-[:LIKES]-(liker:User)
WHERE date.truncate('week', post2.timestamp) = week
WITH week, posts_this_week, active_authors,
     count(DISTINCT liker) AS total_likes_this_week

RETURN week,
       posts_this_week,
       active_authors,
       total_likes_this_week,
       round(posts_this_week * 1.0 / active_authors * 100) / 100 AS avg_posts_per_author,
       round(total_likes_this_week * 1.0 / posts_this_week * 100) / 100 AS avg_likes_per_post,
       // Activity level classification
       CASE 
         WHEN posts_this_week > 15 THEN 'High Activity'
         WHEN posts_this_week > 10 THEN 'Moderate Activity'
         WHEN posts_this_week > 5 THEN 'Low Activity'
         ELSE 'Very Low Activity'
       END AS activity_level
ORDER BY week
```

### Step 7: Relationship Formation Patterns
```cypher
// Analyze how relationships form over time
MATCH (u1:User)-[follows:FOLLOWS]->(u2:User)
WITH date.truncate('month', follows.since) AS month,
     count(follows) AS new_relationships,
     count(DISTINCT u1) AS active_followers,
     count(DISTINCT u2) AS users_gained_followers

ORDER BY month
WITH collect({
  month: month, 
  new_relationships: new_relationships,
  active_followers: active_followers,
  users_gained_followers: users_gained_followers
}) AS monthly_relationship_data

UNWIND range(0, size(monthly_relationship_data)-1) AS i
WITH monthly_relationship_data[i] AS current_data,
     CASE WHEN i > 0 
          THEN monthly_relationship_data[i-1].new_relationships 
          ELSE 0 END AS previous_month_relationships

RETURN current_data.month AS month,
       current_data.new_relationships AS new_follows,
       current_data.active_followers AS users_who_followed,
       current_data.users_gained_followers AS users_who_gained_followers,
       // Growth metrics
       CASE WHEN previous_month_relationships > 0 
            THEN round((current_data.new_relationships - previous_month_relationships) * 100.0 / previous_month_relationships)
            ELSE 0 END AS relationship_growth_percent,
       // Network density indicators
       round(current_data.new_relationships * 1.0 / current_data.active_followers * 100) / 100 AS avg_follows_per_active_user
ORDER BY month
```

### Step 8: Cohort Analysis - User Retention
```cypher
// Perform cohort analysis to understand user retention patterns
MATCH (u:User)
WITH date.truncate('month', u.joinDate) AS cohort_month, u
ORDER BY cohort_month

// For each cohort, analyze activity in subsequent months
MATCH (u)-[:POSTED]->(post:Post)
WITH cohort_month, u, post,
     date.truncate('month', post.timestamp) AS activity_month,
     duration.between(cohort_month, date.truncate('month', post.timestamp)).months AS months_after_join

WHERE months_after_join >= 0 AND months_after_join <= 12  // First 12 months

WITH cohort_month, months_after_join,
     count(DISTINCT u) AS active_users_in_month,
     count(post) AS total_posts

// Get cohort sizes
MATCH (cohort_user:User)
WHERE date.truncate('month', cohort_user.joinDate) = cohort_month
WITH cohort_month, months_after_join, active_users_in_month, total_posts,
     count(cohort_user) AS cohort_size

RETURN cohort_month,
       months_after_join,
       cohort_size,
       active_users_in_month,
       total_posts,
       round(active_users_in_month * 100.0 / cohort_size) AS retention_rate_percent,
       round(total_posts * 1.0 / active_users_in_month * 100) / 100 AS avg_posts_per_active_user,
       // Retention classification
       CASE 
         WHEN active_users_in_month * 100.0 / cohort_size > 75 THEN 'Excellent Retention'
         WHEN active_users_in_month * 100.0 / cohort_size > 50 THEN 'Good Retention'
         WHEN active_users_in_month * 100.0 / cohort_size > 25 THEN 'Moderate Retention'
         ELSE 'Poor Retention'
       END AS retention_quality
ORDER BY cohort_month, months_after_join
```

## Part 3: Advanced User Segmentation (20 minutes)

### Step 9: Behavioral User Segmentation
```cypher
// Create comprehensive user segments based on behavior patterns
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)
OPTIONAL MATCH (u)-[:LIKES]->(liked_content)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (u)-[:INTERESTED_IN]->(topic:Topic)

WITH u,
     count(DISTINCT post) AS posts_created,
     count(DISTINCT liked_content) AS content_interactions,
     count(DISTINCT following) AS users_following,
     count(DISTINCT follower) AS users_followers,
     count(DISTINCT topic) AS topics_interested,
     duration.between(u.joinDate, datetime()).days AS days_on_platform

// Calculate behavioral scores
WITH u, posts_created, content_interactions, users_following, users_followers, topics_interested, days_on_platform,
     // Content creation score (0-100)
     CASE WHEN days_on_platform > 0 
          THEN min(100, round(posts_created * 30.0 / days_on_platform * 100))
          ELSE 0 END AS creation_score,
     // Social engagement score (0-100)
     min(100, round((content_interactions + users_following) * 2)) AS engagement_score,
     // Influence score (0-100)
     min(100, round(users_followers * 5 + posts_created * 2)) AS influence_score,
     // Diversity score (variety of interests, 0-100)
     min(100, topics_interested * 10) AS diversity_score

// Create user segments based on behavioral patterns
RETURN u.username AS username,
       u.fullName AS full_name,
       u.location AS location,
       creation_score,
       engagement_score,
       influence_score,
       diversity_score,
       posts_created,
       content_interactions,
       users_followers,
       users_following,
       days_on_platform,
       // Primary segment classification
       CASE 
         WHEN creation_score > 70 AND influence_score > 60 THEN 'Content Creator & Influencer'
         WHEN creation_score > 70 THEN 'Content Creator'
         WHEN influence_score > 60 THEN 'Influencer'
         WHEN engagement_score > 70 THEN 'Active Community Member'
         WHEN engagement_score > 40 THEN 'Casual User'
         WHEN days_on_platform < 30 THEN 'New User'
         ELSE 'Inactive User'
       END AS primary_segment,
       // Secondary characteristics
       CASE 
         WHEN diversity_score > 60 THEN 'Diverse Interests'
         WHEN diversity_score > 30 THEN 'Focused Interests'
         ELSE 'Limited Interests'
       END AS interest_profile,
       // Engagement pattern
       CASE 
         WHEN content_interactions > posts_created * 3 THEN 'Consumer-Heavy'
         WHEN posts_created > content_interactions THEN 'Creator-Heavy'
         ELSE 'Balanced'
       END AS engagement_pattern
ORDER BY influence_score + creation_score + engagement_score DESC
```

### Step 10: Geographic and Demographic Analysis
```cypher
// Analyze user distribution and behavior by geographic and demographic factors
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)

WITH u.location AS location,
     u.age AS age,
     count(DISTINCT u) AS user_count,
     avg(u.followerCount) AS avg_followers,
     count(DISTINCT post) AS total_posts,
     count(DISTINCT liker) AS total_likes_received,
     count(DISTINCT following) AS total_follows_made

// Age group classification
WITH location, age, user_count, avg_followers, total_posts, total_likes_received, total_follows_made,
     CASE 
       WHEN age < 25 THEN 'Gen Z (18-24)'
       WHEN age < 35 THEN 'Millennials (25-34)'
       WHEN age < 45 THEN 'Gen X (35-44)'
       ELSE 'Older (45+)'
     END AS age_group

RETURN location,
       age_group,
       user_count,
       round(avg_followers) AS avg_followers,
       total_posts,
       total_likes_received,
       total_follows_made,
       // Engagement metrics by demographic
       CASE WHEN user_count > 0 
            THEN round(total_posts * 1.0 / user_count * 100) / 100 
            ELSE 0 END AS avg_posts_per_user,
       CASE WHEN total_posts > 0 
            THEN round(total_likes_received * 1.0 / total_posts * 100) / 100 
            ELSE 0 END AS avg_likes_per_post,
       CASE WHEN user_count > 0 
            THEN round(total_follows_made * 1.0 / user_count * 100) / 100 
            ELSE 0 END AS avg_follows_per_user,
       // Activity classification
       CASE 
         WHEN total_posts * 1.0 / user_count > 10 THEN 'High Activity Region'
         WHEN total_posts * 1.0 / user_count > 5 THEN 'Moderate Activity Region'
         ELSE 'Low Activity Region'
       END AS regional_activity_level
ORDER BY user_count DESC, avg_followers DESC
```

### Step 11: Interest-Based Community Detection
```cypher
// Identify communities based on shared interests and interaction patterns
MATCH (topic:Topic)<-[:INTERESTED_IN]-(u:User)
WITH topic, collect(u) AS interested_users

// Find users who interact with each other within topic communities
UNWIND interested_users AS user1
UNWIND interested_users AS user2
WHERE user1 <> user2

OPTIONAL MATCH (user1)-[:FOLLOWS|LIKES|COMMENTED_ON]-(user2)
WITH topic, user1, user2, count(*) AS interaction_strength
WHERE interaction_strength > 0

// Aggregate community interaction data
WITH topic.name AS topic_name,
     count(DISTINCT user1) AS community_size,
     count(*) AS total_interactions,
     avg(interaction_strength) AS avg_interaction_strength

MATCH (topic_again:Topic {name: topic_name})<-[:INTERESTED_IN]-(community_user:User)
OPTIONAL MATCH (community_user)-[:POSTED]->(post:Post)-[:TAGGED_WITH]->(topic_again)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)

WITH topic_name, community_size, total_interactions, avg_interaction_strength,
     count(DISTINCT post) AS community_posts,
     count(DISTINCT liker) AS community_engagement

RETURN topic_name,
       community_size,
       total_interactions,
       round(avg_interaction_strength * 100) / 100 AS avg_interaction_strength,
       community_posts,
       community_engagement,
       // Community health metrics
       round(total_interactions * 1.0 / (community_size * (community_size - 1)) * 100) AS connectedness_percent,
       CASE WHEN community_size > 0 
            THEN round(community_posts * 1.0 / community_size * 100) / 100 
            ELSE 0 END AS avg_posts_per_member,
       CASE WHEN community_posts > 0 
            THEN round(community_engagement * 1.0 / community_posts * 100) / 100 
            ELSE 0 END AS avg_engagement_per_post,
       // Community classification
       CASE 
         WHEN connectedness_percent > 20 THEN 'Tight-Knit Community'
         WHEN connectedness_percent > 10 THEN 'Connected Community'
         WHEN connectedness_percent > 5 THEN 'Loose Community'
         ELSE 'Interest Group'
       END AS community_type
ORDER BY community_size DESC, connectedness_percent DESC
```

## Part 4: Executive KPI Dashboard (15 minutes)

### Step 12: Platform Health Metrics
```cypher
// Calculate key platform health indicators for executive reporting
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)
OPTIONAL MATCH (post)<-[:LIKES|COMMENTED_ON]-(engager:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)

// Calculate key metrics
WITH count(DISTINCT u) AS total_users,
     count(DISTINCT post) AS total_posts,
     count(DISTINCT engager) AS total_engagements,
     count(DISTINCT following) AS total_follows

// Calculate additional derived metrics
MATCH (active_user:User)-[:POSTED]->(recent_post:Post)
WHERE recent_post.timestamp > datetime() - duration('P30D')
WITH total_users, total_posts, total_engagements, total_follows,
     count(DISTINCT active_user) AS monthly_active_users

MATCH (new_user:User)
WHERE new_user.joinDate > datetime() - duration('P30D')
WITH total_users, total_posts, total_engagements, total_follows, monthly_active_users,
     count(new_user) AS new_users_this_month

RETURN 'Platform Overview' AS metric_category,
       total_users AS total_registered_users,
       monthly_active_users,
       new_users_this_month,
       total_posts,
       total_engagements,
       total_follows,
       // Key ratios and rates
       round(monthly_active_users * 100.0 / total_users) AS monthly_active_rate_percent,
       round(total_engagements * 1.0 / total_posts * 100) / 100 AS avg_engagements_per_post,
       round(total_posts * 1.0 / monthly_active_users * 100) / 100 AS avg_posts_per_active_user,
       round(new_users_this_month * 100.0 / total_users) AS monthly_growth_rate_percent,
       // Health indicators
       CASE 
         WHEN monthly_active_users * 100.0 / total_users > 60 THEN 'Excellent'
         WHEN monthly_active_users * 100.0 / total_users > 40 THEN 'Good'
         WHEN monthly_active_users * 100.0 / total_users > 20 THEN 'Fair'
         ELSE 'Needs Attention'
       END AS platform_health_status
```

### Step 13: Content Performance KPIs
```cypher
// Analyze content performance trends for strategic insights
MATCH (post:Post)<-[:POSTED]-(author:User)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)<-[:REPLIES_TO]-(comment:Comment)
OPTIONAL MATCH (post)-[:TAGGED_WITH]->(topic:Topic)

WITH post, author, 
     count(DISTINCT liker) AS likes,
     count(DISTINCT comment) AS comments,
     collect(DISTINCT topic.name) AS topics,
     duration.between(post.timestamp, datetime()).days AS age_in_days

// Classify posts by performance and recency
WITH post, author, likes, comments, topics, age_in_days,
     likes + comments * 2 AS total_engagement,
     CASE 
       WHEN age_in_days <= 7 THEN 'This Week'
       WHEN age_in_days <= 30 THEN 'This Month'
       WHEN age_in_days <= 90 THEN 'Last 3 Months'
       ELSE 'Older'
     END AS time_period

// Aggregate by time period
WITH time_period,
     count(post) AS total_posts,
     count(DISTINCT author) AS unique_authors,
     avg(total_engagement) AS avg_engagement,
     max(total_engagement) AS max_engagement,
     sum(total_engagement) AS total_engagement_sum,
     sum(CASE WHEN total_engagement > 20 THEN 1 ELSE 0 END) AS viral_posts,
     sum(CASE WHEN total_engagement = 0 THEN 1 ELSE 0 END) AS zero_engagement_posts

RETURN time_period,
       total_posts,
       unique_authors,
       round(avg_engagement * 100) / 100 AS avg_engagement_per_post,
       max_engagement AS highest_engagement,
       total_engagement_sum,
       viral_posts,
       zero_engagement_posts,
       // Performance indicators
       round(viral_posts * 100.0 / total_posts) AS viral_rate_percent,
       round(zero_engagement_posts * 100.0 / total_posts) AS zero_engagement_rate_percent,
       round(total_posts * 1.0 / unique_authors * 100) / 100 AS avg_posts_per_author,
       // Content quality assessment
       CASE 
         WHEN avg_engagement > 15 THEN 'High Quality Period'
         WHEN avg_engagement > 8 THEN 'Good Quality Period'
         WHEN avg_engagement > 3 THEN 'Average Quality Period'
         ELSE 'Low Quality Period'
       END AS content_quality_assessment
ORDER BY 
  CASE time_period 
    WHEN 'This Week' THEN 1
    WHEN 'This Month' THEN 2  
    WHEN 'Last 3 Months' THEN 3
    ELSE 4 
  END
```

### Step 14: User Growth and Retention Dashboard
```cypher
// Create comprehensive user growth and retention metrics
MATCH (u:User)
WITH date.truncate('month', u.joinDate) AS join_month,
     u.joinDate AS exact_join_date,
     u

// Calculate monthly cohorts and their current activity
OPTIONAL MATCH (u)-[:POSTED]->(recent_post:Post)
WHERE recent_post.timestamp > datetime() - duration('P30D')
WITH join_month, u, 
     CASE WHEN recent_post IS NOT NULL THEN 1 ELSE 0 END AS is_active_this_month

// Aggregate metrics by cohort month
WITH join_month,
     count(u) AS cohort_size,
     sum(is_active_this_month) AS currently_active,
     duration.between(join_month, datetime()).months AS months_since_cohort

// Calculate retention and engagement metrics
RETURN join_month,
       cohort_size,
       currently_active,
       months_since_cohort,
       round(currently_active * 100.0 / cohort_size) AS retention_rate_percent,
       // Cohort health classification
       CASE 
         WHEN currently_active * 100.0 / cohort_size > 50 THEN 'Healthy Cohort'
         WHEN currently_active * 100.0 / cohort_size > 25 THEN 'Stable Cohort'
         WHEN currently_active * 100.0 / cohort_size > 10 THEN 'Declining Cohort'
         ELSE 'At-Risk Cohort'
       END AS cohort_health,
       // Lifecycle stage
       CASE 
         WHEN months_since_cohort < 3 THEN 'New Cohort'
         WHEN months_since_cohort < 12 THEN 'Maturing Cohort'
         ELSE 'Established Cohort'
       END AS cohort_lifecycle_stage
ORDER BY join_month DESC
```

### Step 15: Predictive Analytics and Recommendations
```cypher
// Generate predictive insights and strategic recommendations
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)

WITH u,
     count(DISTINCT post) AS user_posts,
     count(DISTINCT following) AS user_following,
     count(DISTINCT follower) AS user_followers,
     duration.between(u.joinDate, datetime()).days AS days_on_platform

// Calculate user trajectory and predict future behavior
WITH u, user_posts, user_following, user_followers, days_on_platform,
     CASE WHEN days_on_platform > 0 
          THEN user_posts * 30.0 / days_on_platform 
          ELSE 0 END AS projected_monthly_posts,
     CASE WHEN days_on_platform > 30 
          THEN (user_followers - 0) * 30.0 / days_on_platform 
          ELSE 0 END AS projected_monthly_follower_growth

// Classify user growth patterns and predict outcomes
WITH u, user_posts, user_followers, days_on_platform, projected_monthly_posts, projected_monthly_follower_growth,
     CASE 
       WHEN projected_monthly_posts > 10 AND projected_monthly_follower_growth > 50 THEN 'High Growth Potential'
       WHEN projected_monthly_posts > 5 AND projected_monthly_follower_growth > 20 THEN 'Moderate Growth Potential'
       WHEN projected_monthly_posts > 1 THEN 'Stable User'
       WHEN days_on_platform > 60 AND user_posts = 0 THEN 'At Risk of Churn'
       ELSE 'New/Inactive User'
     END AS user_trajectory

// Aggregate predictions by trajectory type
WITH user_trajectory,
     count(*) AS user_count,
     avg(user_followers) AS avg_current_followers,
     avg(projected_monthly_posts) AS avg_predicted_posts,
     avg(projected_monthly_follower_growth) AS avg_predicted_growth

RETURN user_trajectory,
       user_count,
       round(avg_current_followers) AS avg_current_followers,
       round(avg_predicted_posts * 100) / 100 AS avg_predicted_monthly_posts,
       round(avg_predicted_growth * 100) / 100 AS avg_predicted_monthly_growth,
       // Strategic recommendations
       CASE user_trajectory
         WHEN 'High Growth Potential' THEN 'Invest in creator tools and monetization features'
         WHEN 'Moderate Growth Potential' THEN 'Provide growth coaching and community features'
         WHEN 'Stable User' THEN 'Focus on retention and engagement features'
         WHEN 'At Risk of Churn' THEN 'Implement re-engagement campaigns'
         ELSE 'Improve onboarding and initial user experience'
       END AS strategic_recommendation,
       // Expected impact
       round(user_count * avg_predicted_posts * 6) AS projected_6_month_posts_from_segment
ORDER BY user_count DESC
```

## Lab Completion Checklist

- [ ] Calculated comprehensive user engagement metrics and activity patterns
- [ ] Analyzed content performance with viral coefficient and engagement velocity
- [ ] Built temporal analysis showing network evolution and growth patterns
- [ ] Performed cohort analysis for user retention tracking
- [ ] Created sophisticated behavioral user segmentation
- [ ] Analyzed geographic and demographic user distribution patterns
- [ ] Detected interest-based communities and measured community health
- [ ] Built executive KPI dashboard with platform health metrics
- [ ] Developed predictive analytics for user growth and content performance
- [ ] Generated strategic recommendations based on data insights

## Key Concepts Mastered

1. **Advanced Analytics Patterns:** Complex aggregations with business logic
2. **Temporal Analysis:** Time-series patterns and trend identification
3. **Cohort Analysis:** User retention and lifecycle understanding
4. **User Segmentation:** Behavioral clustering and persona development
5. **Community Detection:** Interest-based group identification
6. **KPI Development:** Executive-level metrics and dashboards
7. **Predictive Analytics:** Growth forecasting and risk identification
8. **Strategic Insights:** Data-driven recommendations and action plans

## Business Intelligence Insights Generated

### Platform Health Indicators:
- **User Engagement Rates:** Monthly active user percentages and trends
- **Content Quality Metrics:** Viral rates, engagement velocity, topic performance
- **Growth Trajectories:** User acquisition, retention, and expansion patterns
- **Community Health:** Connectedness, diversity, and interaction strength

### Strategic Recommendations:
- **High-Growth Users:** Investment in creator tools and monetization
- **At-Risk Segments:** Re-engagement campaigns and onboarding improvements  
- **Content Strategy:** Topic optimization based on trending analysis
- **Community Building:** Interest-based feature development

## Next Steps

Outstanding work! You've built a comprehensive business intelligence system that provides:
- **Executive-level KPI dashboards** for strategic decision making
- **Detailed user analytics** for product and marketing optimization
- **Predictive insights** for proactive platform management
- **Community analysis** for feature development and user experience

**In Lab 7**, we'll dive deeper into:
- **Graph algorithms implementation** for pathfinding and centrality analysis
- **Advanced community detection** using algorithmic approaches
- **Network optimization** for performance and scalability
- **Real-world algorithm applications** for business problems

## Practice Exercises (Optional)

Extend your analytics capabilities:

1. **A/B Testing Framework:** Compare metrics between user segments for feature testing
2. **Sentiment Analysis:** Analyze content tone and user satisfaction indicators
3. **Influence Cascade Modeling:** Track how trends and information spread
4. **Revenue Optimization:** Model potential monetization based on user behavior
5. **Risk Assessment:** Identify users likely to violate community guidelines

## Quick Reference

**Business Analytics Patterns:**
```cypher
// Cohort analysis template
MATCH (entity) 
WITH date.truncate('month', entity.timestamp) AS cohort, entity
// Add activity measurements
WITH cohort, count(entity) AS cohort_size, activity_metrics
RETURN cohort, cohort_size, retention_calculations

// Segmentation template  
MATCH (entity)
WITH entity, calculated_scores
// Apply scoring logic
RETURN entity, segment_classification, behavioral_patterns

// Trending analysis template
MATCH (content)
WITH content, recency_weight * engagement_metrics AS trending_score
RETURN content, trending_score, trend_classification
```

---

**🎉 Lab 6 Complete!**

You now possess comprehensive business intelligence and analytics skills for social networks. These capabilities enable you to build executive dashboards, perform strategic analysis, and generate actionable insights that drive business value from graph data!