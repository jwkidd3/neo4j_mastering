# Lab 3: Building Complex Social Networks

**Duration:** 90 minutes  
**Objective:** Design and implement a comprehensive social network with advanced relationship patterns and content interactions

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop** (connection client)
- **Docker Desktop** with Neo4j Enterprise 2025.06.0 running (container name: neo4j)
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

✅ **From Previous Labs:**
- **Completed Labs 1 and 2** with "social" database created
- **Advanced Cypher knowledge** from Lab 2
- **Understanding of constraints, indexes, and MERGE operations**
- **Remote connection** set up in Neo4j Desktop

## Learning Outcomes

By the end of this lab, you will:
- Build upon the advanced Cypher skills from Lab 2
- Design comprehensive social network data models
- Create users, posts, comments, likes, and complex interactions
- Implement topic tagging and content categorization systems
- Build location-based relationships and check-ins
- Write advanced multi-hop relationship queries
- Create sophisticated friend recommendation algorithms
- Analyze social network patterns and engagement metrics

## Part 1: Environment Setup and Social Network Planning (10 minutes)

### Step 1: Connect to Social Database
Launch Neo4j Browser and ensure you're working with the social database:

```cypher
// Switch to social database
:use social
```

```cypher
// Check current data from previous labs
MATCH (n) RETURN count(n) AS total_nodes, collect(DISTINCT labels(n)) AS node_types
```

```cypher
// Clear result panel
:clear
```

### Step 2: Verify Enterprise Features and Create Social Network Schema
```cypher
// Check available procedures
SHOW PROCEDURES 
WHERE name STARTS WITH "apoc"
```

```cypher
// Clear previous lab data to build comprehensive social network
MATCH (n) DETACH DELETE n
```

**Expected Result:** Clean database ready for comprehensive social network

## Part 2: Enhanced User Profiles and Data Model (15 minutes)

### Step 3: Create Rich User Profiles
```cypher
// Create users with comprehensive social media profiles
CREATE (alice:User:Person {
  userId: 'alice_smith',
  username: 'alice_codes',
  email: 'alice.smith@email.com',
  fullName: 'Alice Smith',
  bio: 'Software engineer passionate about AI and coffee ☕',
  age: 25,
  location: 'San Francisco, CA',
  coordinates: point({latitude: 37.7749, longitude: -122.4194}),
  joinDate: date('2020-03-15'),
  isVerified: true,
  followerCount: 1250,
  followingCount: 890,
  postCount: 342,
  interests: ['Technology', 'AI', 'Coffee', 'Photography'],
  profilePicture: 'https://example.com/alice.jpg',
  isPrivate: false
}),

(bob:User:Person {
  userId: 'bob_jones',
  username: 'bob_travels',
  email: 'bob.jones@email.com',
  fullName: 'Bob Jones',
  bio: 'Travel photographer | Adventure seeker | Coffee enthusiast 📸✈️',
  age: 30,
  location: 'New York, NY',
  coordinates: point({latitude: 40.7128, longitude: -74.0060}),
  joinDate: date('2019-08-22'),
  isVerified: false,
  followerCount: 2100,
  followingCount: 1450,
  postCount: 576,
  interests: ['Photography', 'Travel', 'Coffee', 'Nature'],
  profilePicture: 'https://example.com/bob.jpg',
  isPrivate: false
}),

(carol:User:Person {
  userId: 'carol_davis',
  username: 'carol_creates',
  email: 'carol.davis@email.com',
  fullName: 'Carol Davis',
  bio: 'Digital artist and art curator | Exploring the intersection of technology and creativity 🎨',
  age: 28,
  location: 'London, UK',
  coordinates: point({latitude: 51.5074, longitude: -0.1278}),
  joinDate: date('2019-05-10'),
  isVerified: true,
  followerCount: 3200,
  followingCount: 2100,
  postCount: 892,
  interests: ['Art', 'Digital Design', 'Technology', 'Museums'],
  profilePicture: 'https://example.com/carol.jpg',
  isPrivate: false
}),

(eve:User:Person {
  userId: 'eve_brown',
  username: 'eve_fitness',
  email: 'eve.brown@email.com',
  fullName: 'Eve Brown',
  bio: 'Fitness coach and wellness enthusiast | Helping people live their healthiest lives 💪',
  age: 26,
  location: 'Sydney, Australia',
  coordinates: point({latitude: -33.8688, longitude: 151.2093}),
  joinDate: date('2021-01-15'),
  isVerified: false,
  followerCount: 1800,
  followingCount: 1200,
  postCount: 445,
  interests: ['Fitness', 'Wellness', 'Nutrition', 'Yoga'],
  profilePicture: 'https://example.com/eve.jpg',
  isPrivate: false
}),

(frank:User:Person {
  userId: 'frank_miller',
  username: 'frank_music',
  email: 'frank.miller@email.com',
  fullName: 'Frank Miller',
  bio: 'Indie musician and coffee shop regular | Creating soundscapes and melodies 🎵',
  age: 27,
  location: 'Austin, TX',
  coordinates: point({latitude: 30.2672, longitude: -97.7431}),
  joinDate: date('2019-12-03'),
  isVerified: false,
  followerCount: 756,
  followingCount: 890,
  postCount: 178,
  interests: ['Music', 'Coffee', 'Indie Culture', 'Songwriting'],
  profilePicture: 'https://example.com/frank.jpg',
  isPrivate: false
})
```

### Step 4: Create Topic Categories
```cypher
// Create topic nodes for content categorization
CREATE (technology:Topic {
  topicId: 'technology',
  name: 'Technology',
  description: 'Software, AI, gadgets, and tech trends',
  followerCount: 45000,
  postCount: 12000,
  trending: true
}),

(photography:Topic {
  topicId: 'photography',
  name: 'Photography',
  description: 'Visual storytelling and photo techniques',
  followerCount: 38000,
  postCount: 25000,
  trending: false
}),

(travel:Topic {
  topicId: 'travel',
  name: 'Travel',
  description: 'Adventures, destinations, and travel tips',
  followerCount: 52000,
  postCount: 18000,
  trending: true
}),

(art:Topic {
  topicId: 'art',
  name: 'Art',
  description: 'Visual arts, digital art, and creativity',
  followerCount: 29000,
  postCount: 15000,
  trending: false
}),

(fitness:Topic {
  topicId: 'fitness',
  name: 'Fitness',
  description: 'Health, exercise, and wellness',
  followerCount: 41000,
  postCount: 22000,
  trending: true
}),

(music:Topic {
  topicId: 'music',
  name: 'Music',
  description: 'Songs, artists, and musical experiences',
  followerCount: 67000,
  postCount: 31000,
  trending: false
}),

(coffee:Topic {
  topicId: 'coffee',
  name: 'Coffee',
  description: 'Coffee culture, brewing, and café experiences',
  followerCount: 15000,
  postCount: 8000,
  trending: false
}),

(science:Topic {
  topicId: 'science',
  name: 'Science',
  description: 'Research, discoveries, and scientific discussion',
  followerCount: 23000,
  postCount: 7500,
  trending: false
})
```

### Step 5: Create Data Integrity Constraints
```cypher
// Create constraints for data integrity
CREATE CONSTRAINT user_id_unique FOR (u:User) REQUIRE u.userId IS UNIQUE;
CREATE CONSTRAINT topic_id_unique FOR (t:Topic) REQUIRE t.topicId IS UNIQUE;
CREATE CONSTRAINT post_id_unique FOR (p:Post) REQUIRE p.postId IS UNIQUE;
```

**Expected Result:** Database constraints created successfully

## Part 3: Building Social Connections (20 minutes)

### Step 6: Create Following Relationships
```cypher
// Alice follows several people (tech enthusiast network)
MATCH (alice:User {userId: 'alice_smith'}), (bob:User {userId: 'bob_jones'})
CREATE (alice)-[:FOLLOWS {
  since: datetime('2020-06-15T14:30:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(bob)

MATCH (alice:User {userId: 'alice_smith'}), (carol:User {userId: 'carol_davis'})
CREATE (alice)-[:FOLLOWS {
  since: datetime('2021-01-20T16:45:00'),
  notificationsEnabled: true,
  relationship: 'professional'
}]->(carol)

MATCH (alice:User {userId: 'alice_smith'}), (frank:User {userId: 'frank_miller'})
CREATE (alice)-[:FOLLOWS {
  since: datetime('2020-02-10T11:20:00'),
  notificationsEnabled: false,
  relationship: 'interest'
}]->(frank)
```

```cypher
// Bob's photography network
MATCH (bob:User {userId: 'bob_jones'}), (carol:User {userId: 'carol_davis'})
CREATE (bob)-[:FOLLOWS {
  since: datetime('2021-03-05T09:15:00'),
  notificationsEnabled: true,
  relationship: 'creative'
}]->(carol)

MATCH (bob:User {userId: 'bob_jones'}), (eve:User {userId: 'eve_brown'})
CREATE (bob)-[:FOLLOWS {
  since: datetime('2021-05-12T14:30:00'),
  notificationsEnabled: false,
  relationship: 'casual'
}]->(eve)

MATCH (bob:User {userId: 'bob_jones'}), (alice:User {userId: 'alice_smith'})
CREATE (bob)-[:FOLLOWS {
  since: datetime('2020-06-16T10:00:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(alice)
```

```cypher
// Carol's art community connections
MATCH (carol:User {userId: 'carol_davis'}), (eve:User {userId: 'eve_brown'})
CREATE (carol)-[:FOLLOWS {
  since: datetime('2021-02-18T13:45:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(eve)

MATCH (carol:User {userId: 'carol_davis'}), (frank:User {userId: 'frank_miller'})
CREATE (carol)-[:FOLLOWS {
  since: datetime('2020-12-01T15:20:00'),
  notificationsEnabled: true,
  relationship: 'artistic'
}]->(frank)
```

```cypher
// Additional mutual connections
MATCH (eve:User {userId: 'eve_brown'}), (alice:User {userId: 'alice_smith'})
CREATE (eve)-[:FOLLOWS {
  since: datetime('2021-03-10T12:30:00'),
  notificationsEnabled: true,
  relationship: 'professional'
}]->(alice)

MATCH (eve:User {userId: 'eve_brown'}), (carol:User {userId: 'carol_davis'})
CREATE (eve)-[:FOLLOWS {
  since: datetime('2021-02-25T13:15:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(carol)

MATCH (frank:User {userId: 'frank_miller'}), (alice:User {userId: 'alice_smith'})
CREATE (frank)-[:FOLLOWS {
  since: datetime('2020-02-15T16:00:00'),
  notificationsEnabled: false,
  relationship: 'mutual'
}]->(alice)
```

### Step 7: Create Topic Interest Relationships
```cypher
// Users follow topics they're interested in
MATCH (alice:User {userId: 'alice_smith'}), 
      (tech:Topic {topicId: 'technology'}), 
      (coffee:Topic {topicId: 'coffee'}),
      (science:Topic {topicId: 'science'})
CREATE (alice)-[:INTERESTED_IN {since: date('2020-03-15')}]->(tech),
       (alice)-[:INTERESTED_IN {since: date('2020-04-01')}]->(coffee),
       (alice)-[:INTERESTED_IN {since: date('2020-05-10')}]->(science)
```

```cypher
MATCH (bob:User {userId: 'bob_jones'}), 
      (photo:Topic {topicId: 'photography'}), 
      (travel:Topic {topicId: 'travel'}),
      (coffee:Topic {topicId: 'coffee'})
CREATE (bob)-[:INTERESTED_IN {since: date('2019-08-22')}]->(photo),
       (bob)-[:INTERESTED_IN {since: date('2019-09-01')}]->(travel),
       (bob)-[:INTERESTED_IN {since: date('2020-01-15')}]->(coffee)
```

```cypher
MATCH (carol:User {userId: 'carol_davis'}), 
      (art:Topic {topicId: 'art'}), 
      (photo:Topic {topicId: 'photography'})
CREATE (carol)-[:INTERESTED_IN {since: date('2020-11-10')}]->(art),
       (carol)-[:INTERESTED_IN {since: date('2020-12-01')}]->(photo)
```

```cypher
MATCH (eve:User {userId: 'eve_brown'}), 
      (fitness:Topic {topicId: 'fitness'})
CREATE (eve)-[:INTERESTED_IN {since: date('2021-01-08')}]->(fitness)
```

```cypher
MATCH (frank:User {userId: 'frank_miller'}), 
      (music:Topic {topicId: 'music'}), 
      (coffee:Topic {topicId: 'coffee'})
CREATE (frank)-[:INTERESTED_IN {since: date('2019-12-03')}]->(music),
       (frank)-[:INTERESTED_IN {since: date('2020-01-20')}]->(coffee)
```

## Visualization Break: Explore Your Social Network (5 minutes)

### Step 8: Visualize the Network You've Built
Now that you've created a comprehensive social network, let's explore it visually:

```cypher
// View the entire social network
MATCH (n)-[r]-(m) 
RETURN n, r, m
```

**Interactive Exploration:**
1. **Click and drag nodes** to rearrange the layout
2. **Click on User nodes** to see profile information
3. **Click on Topic nodes** to see categories
4. **Click on relationships** to see when connections were made

### Advanced Visualization Options:
```cypher
// Focus on user follows network
MATCH (u1:User)-[f:FOLLOWS]->(u2:User)
RETURN u1, f, u2
```

```cypher
// View user interests
MATCH (u:User)-[i:INTERESTED_IN]->(t:Topic)
RETURN u, i, t
```

**Customize the Display:**
1. **Click "User" label** in the result panel → Choose color (e.g., blue)
2. **Click "Topic" label** → Choose different color (e.g., green)  
3. **Set node captions** to show usernames: `{username}`
4. **Zoom and pan** to explore different areas of the network

**Expected Result:** Rich visual network showing users, their connections, and topic interests

## Part 4: Creating Rich Content - Posts and Interactions (25 minutes)

### Step 9: Create Location Check-ins
```cypher
// Create location nodes and check-in relationships
CREATE (cafe:Location {
  venueId: 'blue_bottle_sf',
  name: 'Blue Bottle Coffee',
  type: 'Café',
  address: '66 Mint St, San Francisco, CA 94103',
  coordinates: point({latitude: 37.7849, longitude: -122.3977}),
  rating: 4.5,
  priceRange: '$$'
}),

(park:Location {
  venueId: 'central_park',
  name: 'Central Park',
  type: 'Park',
  address: 'New York, NY 10024',
  coordinates: point({latitude: 40.7829, longitude: -73.9654}),
  rating: 4.8,
  priceRange: 'Free'
}),

(museum:Location {
  venueId: 'tate_modern',
  name: 'Tate Modern',
  type: 'Museum',
  address: 'Bankside, London SE1 9TG, UK',
  coordinates: point({latitude: 51.5076, longitude: -0.0994}),
  rating: 4.6,
  priceRange: 'Free-$'
})
```

```cypher
// Create check-in relationships
MATCH (alice:User {userId: 'alice_smith'}), (cafe:Location {venueId: 'blue_bottle_sf'})
CREATE (alice)-[:CHECKED_IN {
  timestamp: datetime('2023-06-01T09:30:00'),
  rating: 5,
  review: 'Perfect spot for coding with amazing coffee!'
}]->(cafe)

MATCH (bob:User {userId: 'bob_jones'}), (park:Location {venueId: 'central_park'})
CREATE (bob)-[:CHECKED_IN {
  timestamp: datetime('2023-06-02T19:30:00'),
  rating: 5,
  review: 'Perfect lighting for sunset photography'
}]->(park)

MATCH (carol:User {userId: 'carol_davis'}), (museum:Location {venueId: 'tate_modern'})
CREATE (carol)-[:CHECKED_IN {
  timestamp: datetime('2023-06-01T15:30:00'),
  rating: 5,
  review: 'Incredible contemporary art collection!'
}]->(museum)
```

### Step 10: Create Posts with Rich Metadata
```cypher
// Alice's tech-focused posts
MATCH (alice:User {userId: 'alice_smith'})
CREATE 
  (alice)-[:POSTED]->(post1:Post {
    postId: 'post_001',
    content: 'Just discovered an amazing new coffee shop in SF with the fastest Wi-Fi I\'ve ever experienced! ☕ Perfect for remote work sessions.',
    timestamp: datetime('2023-06-01T10:30:00'),
    likes: 23,
    shares: 3,
    visibility: 'public'
  }),
  (alice)-[:POSTED]->(post2:Post {
    postId: 'post_002',
    content: 'Working on some exciting new machine learning projects. The intersection of AI and human creativity never ceases to amaze me! 🤖💡',
    timestamp: datetime('2023-06-03T14:15:00'),
    likes: 45,
    shares: 8,
    visibility: 'public'
  })
```

```cypher
// Bob's photography-focused posts
MATCH (bob:User {userId: 'bob_jones'})
CREATE 
  (bob)-[:POSTED]->(post3:Post {
    postId: 'post_003',
    content: 'Captured some stunning sunset photos in Central Park today 📸 The golden hour never disappoints!',
    timestamp: datetime('2023-06-02T19:45:00'),
    likes: 67,
    shares: 12,
    visibility: 'public'
  }),
  (bob)-[:POSTED]->(post4:Post {
    postId: 'post_004',
    content: 'Travel tip: Always pack an extra memory card! Just filled up 3 cards shooting the Brooklyn Bridge 🌉',
    timestamp: datetime('2023-06-04T08:20:00'),
    likes: 34,
    shares: 6,
    visibility: 'public'
  })
```

```cypher
// Carol's art-focused posts
MATCH (carol:User {userId: 'carol_davis'})
CREATE 
  (carol)-[:POSTED]->(post5:Post {
    postId: 'post_005',
    content: 'Opening reception for the new contemporary art exhibition tonight! So excited to share these incredible pieces with everyone 🎨',
    timestamp: datetime('2023-06-01T16:00:00'),
    likes: 52,
    shares: 15,
    visibility: 'public'
  }),
  (carol)-[:POSTED]->(post6:Post {
    postId: 'post_006',
    content: 'Working on a new digital art series exploring the intersection of nature and technology. Here\'s a sneak peek!',
    timestamp: datetime('2023-06-05T11:30:00'),
    likes: 78,
    shares: 22,
    visibility: 'public'
  })
```

### Step 11: Create Topic Tags for Posts
```cypher
// Tag posts with relevant topics
MATCH (post1:Post {postId: 'post_001'}), (coffee:Topic {topicId: 'coffee'})
CREATE (post1)-[:TAGGED_WITH]->(coffee)

MATCH (post1:Post {postId: 'post_001'}), (tech:Topic {topicId: 'technology'})
CREATE (post1)-[:TAGGED_WITH]->(tech)

MATCH (post2:Post {postId: 'post_002'}), (tech:Topic {topicId: 'technology'})
CREATE (post2)-[:TAGGED_WITH]->(tech)

MATCH (post3:Post {postId: 'post_003'}), (photography:Topic {topicId: 'photography'})
CREATE (post3)-[:TAGGED_WITH]->(photography)

MATCH (post4:Post {postId: 'post_004'}), (photography:Topic {topicId: 'photography'})
CREATE (post4)-[:TAGGED_WITH]->(photography)

MATCH (post4:Post {postId: 'post_004'}), (travel:Topic {topicId: 'travel'})
CREATE (post4)-[:TAGGED_WITH]->(travel)

MATCH (post5:Post {postId: 'post_005'}), (art:Topic {topicId: 'art'})
CREATE (post5)-[:TAGGED_WITH]->(art)

MATCH (post6:Post {postId: 'post_006'}), (art:Topic {topicId: 'art'})
CREATE (post6)-[:TAGGED_WITH]->(art)

MATCH (post6:Post {postId: 'post_006'}), (tech:Topic {topicId: 'technology'})
CREATE (post6)-[:TAGGED_WITH]->(tech)
```

### Step 12: Create Likes and Engagement
```cypher
// Create like relationships
MATCH (bob:User {userId: 'bob_jones'}), (post1:Post {postId: 'post_001'})
CREATE (bob)-[:LIKES {timestamp: datetime('2023-06-01T11:15:00')}]->(post1)

MATCH (carol:User {userId: 'carol_davis'}), (post1:Post {postId: 'post_001'})
CREATE (carol)-[:LIKES {timestamp: datetime('2023-06-01T11:45:00')}]->(post1)

MATCH (alice:User {userId: 'alice_smith'}), (post3:Post {postId: 'post_003'})
CREATE (alice)-[:LIKES {timestamp: datetime('2023-06-02T20:00:00')}]->(post3)

MATCH (carol:User {userId: 'carol_davis'}), (post3:Post {postId: 'post_003'})
CREATE (carol)-[:LIKES {timestamp: datetime('2023-06-02T20:15:00')}]->(post3)

MATCH (alice:User {userId: 'alice_smith'}), (post5:Post {postId: 'post_005'})
CREATE (alice)-[:LIKES {timestamp: datetime('2023-06-01T16:30:00')}]->(post5)

MATCH (bob:User {userId: 'bob_jones'}), (post5:Post {postId: 'post_005'})
CREATE (bob)-[:LIKES {timestamp: datetime('2023-06-01T17:00:00')}]->(post5)
```

### Step 13: Create Comments and Conversations
```cypher
// Create comment nodes and relationships
MATCH (bob:User {userId: 'bob_jones'}), (post2:Post {postId: 'post_002'})
CREATE (bob)-[:COMMENTED_ON {timestamp: datetime('2023-06-03T15:30:00')}]->(comment1:Comment {
  commentId: 'comment_001',
  content: 'This sounds fascinating! I\'d love to hear more about how you\'re applying AI to creative processes.',
  timestamp: datetime('2023-06-03T15:30:00'),
  likes: 5
})-[:REPLIES_TO]->(post2)

MATCH (carol:User {userId: 'carol_davis'}), (post2:Post {postId: 'post_002'})
CREATE (carol)-[:COMMENTED_ON {timestamp: datetime('2023-06-03T16:15:00')}]->(comment2:Comment {
  commentId: 'comment_002',
  content: 'As a digital artist, I\'m always interested in the creative applications of AI. Have you experimented with any generative art models?',
  timestamp: datetime('2023-06-03T16:15:00'),
  likes: 8
})-[:REPLIES_TO]->(post2)

MATCH (alice:User {userId: 'alice_smith'}), (comment2:Comment {commentId: 'comment_002'})
CREATE (alice)-[:COMMENTED_ON {timestamp: datetime('2023-06-03T17:00:00')}]->(reply1:Comment {
  commentId: 'comment_003',
  content: '@carol_creates Yes! I\'ve been experimenting with neural style transfer and some GANs. The results are incredible when you find the right balance between human creativity and AI capabilities.',
  timestamp: datetime('2023-06-03T17:00:00'),
  likes: 12
})-[:REPLIES_TO]->(comment2)
```

## Part 5: Advanced Social Network Analytics (20 minutes)

### Step 14: Friend Recommendation Engine
```cypher
// Find potential friends through mutual connections
MATCH (user:User {userId: 'alice_smith'})-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(potential:User)
WHERE NOT (user)-[:FOLLOWS]->(potential) 
  AND potential <> user
RETURN potential.username AS recommended_user,
       potential.fullName AS name,
       potential.bio AS bio,
       count(DISTINCT friend) AS mutual_friends
ORDER BY mutual_friends DESC
LIMIT 5
```

### Step 15: Advanced Recommendations with Shared Interests
```cypher
// Advanced recommendations with shared interests
MATCH (user:User {userId: 'alice_smith'})
MATCH (user)-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(potential:User)
WHERE NOT (user)-[:FOLLOWS]->(potential) AND potential <> user
WITH user, potential, count(DISTINCT friend) AS mutual_friends

OPTIONAL MATCH (user)-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(potential)
WITH potential, mutual_friends, count(DISTINCT topic) AS shared_interests

WITH potential, 
     mutual_friends,
     shared_interests,
     (mutual_friends * 2 + shared_interests * 3) AS recommendation_score
WHERE recommendation_score > 0
RETURN potential.username AS recommended_user,
       potential.fullName AS name,
       mutual_friends,
       shared_interests,
       recommendation_score
ORDER BY recommendation_score DESC
LIMIT 5
```

### Step 16: Content Discovery Through Networks
```cypher
// Find popular posts from people you follow
MATCH (user:User {userId: 'alice_smith'})-[:FOLLOWS]->(following:User)-[:POSTED]->(post:Post)
RETURN post.content AS content,
       following.username AS author,
       post.likes AS likes,
       post.shares AS shares,
       post.timestamp AS posted_at
ORDER BY post.likes DESC, post.timestamp DESC
LIMIT 10
```

### Step 17: Topic-Based Content Recommendations
```cypher
// Find posts from topics you're interested in from people you don't follow
MATCH (user:User {userId: 'alice_smith'})-[:INTERESTED_IN]->(topic:Topic)<-[:TAGGED_WITH]-(post:Post)<-[:POSTED]-(author:User)
WHERE NOT (user)-[:FOLLOWS]->(author)  // From people you don't follow
RETURN post.content AS content,
       author.username AS author,
       topic.name AS topic,
       post.likes AS engagement,
       post.timestamp AS posted_at
ORDER BY post.likes DESC
LIMIT 8
```

### Step 18: Engagement Analysis
```cypher
// Analyze user engagement patterns
MATCH (user:User)-[:POSTED]->(post:Post)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)<-[:REPLIES_TO]-(comment:Comment)
WITH user, 
     count(DISTINCT post) AS total_posts,
     count(DISTINCT liker) AS total_likes,
     count(DISTINCT comment) AS total_comments
WHERE total_posts > 0
RETURN user.username AS author,
       total_posts,
       round(toFloat(total_likes) / total_posts * 100) / 100 AS avg_likes_per_post,
       round(toFloat(total_comments) / total_posts * 100) / 100 AS avg_comments_per_post,
       total_likes
ORDER BY avg_likes_per_post DESC
```

### Step 19: Community Detection
```cypher
// Find users who share common interests (topic-based communities)
MATCH (user1:User)-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(user2:User)
WHERE user1 <> user2
WITH user1, user2, count(DISTINCT topic) AS shared_interests
WHERE shared_interests >= 1
RETURN user1.username AS person1,
       user2.username AS person2,
       shared_interests,
       'Shared Interest Community' AS community_type
ORDER BY shared_interests DESC
LIMIT 10
```

**Alternative: Network-based community detection**
```cypher
// Find users connected through followers and shared connections
MATCH (user1:User)-[:FOLLOWS]->(common:User)<-[:FOLLOWS]-(user2:User)
WHERE user1 <> user2 AND NOT (user1)-[:FOLLOWS]->(user2)
WITH user1, user2, count(DISTINCT common) AS mutual_connections
WHERE mutual_connections >= 1
RETURN user1.username AS person1,
       user2.username AS person2,
       mutual_connections,
       'Potential Community via Mutual Connections' AS community_type
ORDER BY mutual_connections DESC
LIMIT 10
```

**Check what communities exist:**
```cypher
// First, let's see what topic communities we have
MATCH (topic:Topic)<-[:INTERESTED_IN]-(user:User)
WITH topic, collect(user.username) AS users, count(user) AS user_count
WHERE user_count > 1
RETURN topic.name AS community_topic,
       users AS members,
       user_count
ORDER BY user_count DESC
```

### Step 20: Influence Network Analysis
```cypher
// Calculate user influence based on network position
MATCH (user:User)
OPTIONAL MATCH (user)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (user)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (user)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
WITH user,
     count(DISTINCT follower) AS followers,
     count(DISTINCT following) AS following_count,
     count(DISTINCT post) AS posts,
     count(DISTINCT liker) AS total_likes
WHERE followers > 0
RETURN user.username AS username,
       followers,
       following_count,
       posts,
       total_likes,
       round(toFloat(total_likes) / followers * 100) / 100 AS likes_per_follower,
       round(toFloat(followers) / (followers + following_count) * 100) AS influence_ratio
ORDER BY influence_ratio DESC, followers DESC
```

## Part 6: Advanced Analytics with Parameters (10 minutes)

### Step 21: Parameterized Social Analytics

**GUARANTEED WORKING SOLUTION - Use existing data:**

```cypher
// First, let's see what actually exists in our database
MATCH (n) 
RETURN DISTINCT labels(n) AS node_types, count(n) AS count
ORDER BY count DESC
```

```cypher
// Find ALL posts that exist (regardless of who created them)
MATCH (post:Post)
RETURN post.postId AS post_id, 
       post.content AS content,
       post.likes AS likes
ORDER BY post.likes DESC
```

**WORKING APPROACH 1: Use existing posts with parameters**
```cypher
// Set parameter for minimum engagement
:param {min_likes: 30}
```

```cypher
// Find high-engagement posts (GUARANTEED to work with existing data)
MATCH (post:Post)
WHERE post.likes >= $min_likes
OPTIONAL MATCH (post)<-[:POSTED]-(author:User)
RETURN post.content AS content,
       COALESCE(author.username, 'Unknown Author') AS author,
       post.likes AS likes,
       post.postId AS post_id
ORDER BY post.likes DESC
LIMIT 10
```

**WORKING APPROACH 2: Topic-based parameterized analysis**
```cypher
// Set parameter for topic filtering
:param {topic_name: 'Technology'}
```

```cypher
// Find posts by topic (using existing topic data)
MATCH (topic:Topic {name: $topic_name})<-[:TAGGED_WITH]-(post:Post)
OPTIONAL MATCH (post)<-[:POSTED]-(author:User)
RETURN post.content AS content,
       COALESCE(author.username, 'Unknown') AS author,
       post.likes AS likes,
       topic.name AS topic
ORDER BY post.likes DESC
```

**WORKING APPROACH 3: User-based parameterized queries**
```cypher
// Set parameter for user analysis
:param {username: 'alice_codes'}
```

```cypher
// Find user by username and their interests (uses existing user data)
MATCH (user:User {username: $username})
OPTIONAL MATCH (user)-[:INTERESTED_IN]->(topic:Topic)
RETURN user.username AS user,
       user.fullName AS name,
       user.followerCount AS followers,
       collect(topic.name) AS interests
```

**WORKING APPROACH 4: Multi-parameter content filtering**
```cypher
// Set multiple parameters for flexible filtering
:param {min_engagement: 20, content_keyword: 'coffee'}
```

```cypher
// Filter content by engagement and keywords
MATCH (post:Post)
WHERE post.likes >= $min_engagement 
  AND toLower(post.content) CONTAINS toLower($content_keyword)
OPTIONAL MATCH (post)<-[:POSTED]-(author:User)
RETURN post.content AS content,
       COALESCE(author.username, 'Unknown') AS author,
       post.likes AS engagement
ORDER BY post.likes DESC
```

**WORKING APPROACH 5: Community analysis with parameters**
```cypher
// Set parameter for community size
:param {min_community_size: 2}
```

```cypher
// Find topic communities above minimum size
MATCH (topic:Topic)<-[:INTERESTED_IN]-(user:User)
WITH topic, count(user) AS community_size, collect(user.username) AS members
WHERE community_size >= $min_community_size
RETURN topic.name AS community_topic,
       community_size,
       members
ORDER BY community_size DESC
```

**Clear all parameters:**
```cypher
:params clear
```

**Summary of what students learn:**
- **Parameter syntax**: `:param {key: value}` and `$key` usage
- **Flexible filtering**: Using parameters for dynamic queries  
- **Multiple parameter types**: Numbers, strings, and complex filtering
- **Real-world applications**: Content filtering, community analysis, user discovery
- **Fallback strategies**: Multiple approaches when data connections vary

## Lab Completion Checklist

- [ ] Successfully connected to "social" database from previous labs
- [ ] Created comprehensive user profiles with rich metadata
- [ ] Built complex social relationship networks (follows, interests)
- [ ] Implemented content creation system (posts, comments, likes)
- [ ] Created topic-based categorization and tagging
- [ ] Built location-based check-in functionality
- [ ] Wrote advanced multi-hop relationship queries
- [ ] Implemented friend recommendation algorithms
- [ ] Analyzed network patterns and user engagement
- [ ] Created community detection queries
- [ ] Built content discovery and influence analysis
- [ ] Used parameterized queries for dynamic analysis

## Key Concepts Mastered

1. **Complex Data Modeling:** Rich user profiles, posts, and interactions
2. **Multi-dimensional Relationships:** Follows, interests, engagement, location
3. **Content Networks:** Posts, comments, likes, and sharing patterns
4. **Topic Classification:** Categorization and discovery systems
5. **Advanced Pattern Matching:** Multi-hop traversals and complex filters
6. **Recommendation Systems:** Friend and content discovery algorithms
7. **Network Analytics:** Influence, engagement, and virality metrics
8. **Community Detection:** Finding clusters and groups in social networks
9. **Location Intelligence:** Geographic relationships and proximity
10. **Social Graph Analysis:** Understanding network topology and dynamics

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

### If constraint errors occur:
```cypher
// Check existing constraints
SHOW CONSTRAINTS
// Drop constraint if needed (replace constraint_name with actual name)
// DROP CONSTRAINT constraint_name
```

### Performance optimization:
```cypher
// Profile complex queries
PROFILE MATCH (u:User)-[:FOLLOWS*2]-(potential) RETURN potential LIMIT 10
```

## Next Steps

Congratulations! You've built a sophisticated social network with:
- Complex user and content models
- Advanced relationship patterns
- Multi-dimensional analytics capabilities
- Real-world recommendation systems

**In Lab 4**, we'll focus on:
- Interactive visualizations across Neo4j tools
- Advanced analytics dashboards
- Multi-tool workflows (Desktop, Browser, Bloom)
- Python integration for custom analytics

## Practice Exercises (Optional)

Try these advanced challenges:

1. **Trending Topics:** Find topics gaining popularity over time
2. **Content Lifecycle:** Track how posts spread through the network
3. **User Segmentation:** Group users by behavior and engagement patterns
4. **Geographic Analysis:** Find location-based communities and trends
5. **Influence Campaigns:** Model how ideas spread through social networks

## Quick Reference

**Social Network Patterns:**
```cypher
// Friend recommendations
MATCH (user)-[:FOLLOWS]->(friend)-[:FOLLOWS]->(potential)
WHERE NOT (user)-[:FOLLOWS]->(potential)
RETURN potential, count(friend) AS mutual_friends

// Content discovery
MATCH (user)-[:INTERESTED_IN]->(topic)<-[:TAGGED_WITH]-(post)
RETURN post ORDER BY post.likes DESC

// Engagement analysis
MATCH (user)-[:POSTED]->(post)<-[:LIKES]-(liker)
RETURN user, avg(count(liker)) AS avg_engagement
```

---

**🎉 Lab 3 Complete!**

You now have expertise in building and analyzing complex social networks with sophisticated relationship patterns, content systems, and analytics capabilities. This knowledge prepares you for advanced visualization and Python integration in Lab 4!