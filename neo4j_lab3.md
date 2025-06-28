# Lab 3: Building Complex Social Networks

**Duration:** 90 minutes  
**Objective:** Design and implement a comprehensive social network with advanced relationship patterns and content interactions

## Prerequisites

- Completed Labs 1 and 2 successfully
- Understanding of advanced Cypher operations from Lab 2
- Familiarity with Neo4j Desktop, Browser, and basic Bloom usage
- Knowledge of MERGE operations, indexes, and constraints

## Learning Outcomes

By the end of this lab, you will:
- Design comprehensive social network data models
- Create users, posts, comments, likes, and complex interactions
- Implement topic tagging and content categorization systems
- Build location-based relationships and check-ins
- Write advanced multi-hop relationship queries
- Practice data import from CSV files
- Create sophisticated friend recommendation algorithms
- Analyze social network patterns and engagement metrics

## Part 1: Social Network Data Model Design (15 minutes)

### Step 1: Clear Previous Data and Plan New Model
```cypher
// Clear existing data to start fresh
MATCH (n) DETACH DELETE n
```

### Step 2: Create Enhanced User Profiles
```cypher
// Create users with rich social media profiles
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
})
```

```cypher
CREATE (bob:User:Person {
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
  followingCount: 650,
  postCount: 567,
  interests: ['Photography', 'Travel', 'Coffee', 'Nature'],
  profilePicture: 'https://example.com/bob.jpg',
  isPrivate: false
})
```

```cypher
CREATE (carol:User:Person {
  userId: 'carol_davis',
  username: 'carol_creates',
  email: 'carol.davis@email.com',
  fullName: 'Carol Davis',
  bio: 'Digital artist & curator | London-based | Art is life 🎨',
  age: 28,
  location: 'London, UK',
  coordinates: point({latitude: 51.5074, longitude: -0.1278}),
  joinDate: date('2020-11-10'),
  isVerified: true,
  followerCount: 3400,
  followingCount: 1200,
  postCount: 289,
  interests: ['Art', 'Design', 'Museums', 'Culture'],
  profilePicture: 'https://example.com/carol.jpg',
  isPrivate: false
})
```

```cypher
CREATE (david:User:Person {
  userId: 'david_wilson',
  username: 'david_designs',
  email: 'david.wilson@email.com',
  fullName: 'David Wilson',
  bio: 'UX Designer creating beautiful digital experiences 💻',
  age: 32,
  location: 'Toronto, Canada',
  coordinates: point({latitude: 43.6532, longitude: -79.3832}),
  joinDate: date('2018-05-12'),
  isVerified: false,
  followerCount: 890,
  followingCount: 1100,
  postCount: 445,
  interests: ['Design', 'UX', 'Technology', 'Minimalism'],
  profilePicture: 'https://example.com/david.jpg',
  isPrivate: false
})
```

```cypher
CREATE (eve:User:Person {
  userId: 'eve_brown',
  username: 'eve_runs',
  email: 'eve.brown@email.com',
  fullName: 'Eve Brown',
  bio: 'Marathon runner 🏃‍♀️ | Fitness coach | Inspiring healthy living',
  age: 26,
  location: 'Berlin, Germany',
  coordinates: point({latitude: 52.5200, longitude: 13.4050}),
  joinDate: date('2021-01-08'),
  isVerified: false,
  followerCount: 1680,
  followingCount: 420,
  postCount: 234,
  interests: ['Fitness', 'Running', 'Health', 'Nutrition'],
  profilePicture: 'https://example.com/eve.jpg',
  isPrivate: false
})
```

```cypher
CREATE (frank:User:Person {
  userId: 'frank_miller',
  username: 'frank_music',
  email: 'frank.miller@email.com',
  fullName: 'Frank Miller',
  bio: 'Indie musician & songwriter 🎵 | Coffee shop performer',
  age: 29,
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

### Step 3: Create Topic Categories
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

## Part 2: Building Social Connections (20 minutes)

### Step 4: Create Following Relationships
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
  since: datetime('2021-02-10T09:15:00'),
  notificationsEnabled: true,
  relationship: 'professional'
}]->(carol)

MATCH (alice:User {userId: 'alice_smith'}), (david:User {userId: 'david_wilson'})
CREATE (alice)-[:FOLLOWS {
  since: datetime('2020-09-20T16:45:00'),
  notificationsEnabled: false,
  relationship: 'colleague'
}]->(david)
```

```cypher
// Bob follows travel and photography enthusiasts
MATCH (bob:User {userId: 'bob_jones'}), (alice:User {userId: 'alice_smith'})
CREATE (bob)-[:FOLLOWS {
  since: datetime('2020-03-25T16:20:00'),
  notificationsEnabled: true,
  relationship: 'colleague'
}]->(alice)

MATCH (bob:User {userId: 'bob_jones'}), (carol:User {userId: 'carol_davis'})
CREATE (bob)-[:FOLLOWS {
  since: datetime('2020-04-10T11:30:00'),
  notificationsEnabled: true,
  relationship: 'professional'
}]->(carol)

MATCH (bob:User {userId: 'bob_jones'}), (frank:User {userId: 'frank_miller'})
CREATE (bob)-[:FOLLOWS {
  since: datetime('2021-03-10T08:20:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(frank)
```

```cypher
// Carol follows everyone (social butterfly)
MATCH (carol:User {userId: 'carol_davis'}), (alice:User {userId: 'alice_smith'})
CREATE (carol)-[:FOLLOWS {
  since: datetime('2020-01-25T12:00:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(alice)

MATCH (carol:User {userId: 'carol_davis'}), (eve:User {userId: 'eve_brown'})
CREATE (carol)-[:FOLLOWS {
  since: datetime('2020-09-20T14:45:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(eve)

MATCH (carol:User {userId: 'carol_davis'}), (david:User {userId: 'david_wilson'})
CREATE (carol)-[:FOLLOWS {
  since: datetime('2021-06-12T10:15:00'),
  notificationsEnabled: false,
  relationship: 'acquaintance'
}]->(david)
```

```cypher
// Additional follows
MATCH (david:User {userId: 'david_wilson'}), (alice:User {userId: 'alice_smith'})
CREATE (david)-[:FOLLOWS {
  since: datetime('2021-07-01T16:30:00'),
  notificationsEnabled: true,
  relationship: 'professional'
}]->(alice)

MATCH (eve:User {userId: 'eve_brown'}), (carol:User {userId: 'carol_davis'})
CREATE (eve)-[:FOLLOWS {
  since: datetime('2020-09-25T13:15:00'),
  notificationsEnabled: true,
  relationship: 'friend'
}]->(carol)
```

### Step 5: Create Topic Following Relationships
```cypher
// Users follow topics they're interested in
MATCH (alice:User {userId: 'alice_smith'}), 
      (tech:Topic {topicId: 'technology'}), 
      (coffee:Topic {topicId: 'coffee'}),
      (science:Topic {topicId: 'science'})
CREATE (alice)-[:INTERESTED_IN {since: date('2020-03-15')}]->(tech),
       (alice)-[:INTERESTED_IN {since: date('2020-04-01')}]->(coffee),
       (alice)-[:INTERESTED_IN {since: date('2020-05-10')}]->(science)

MATCH (bob:User {userId: 'bob_jones'}), 
      (photo:Topic {topicId: 'photography'}), 
      (travel:Topic {topicId: 'travel'}),
      (coffee:Topic {topicId: 'coffee'})
CREATE (bob)-[:INTERESTED_IN {since: date('2019-08-22')}]->(photo),
       (bob)-[:INTERESTED_IN {since: date('2019-09-01')}]->(travel),
       (bob)-[:INTERESTED_IN {since: date('2020-01-15')}]->(coffee)

MATCH (carol:User {userId: 'carol_davis'}), 
      (art:Topic {topicId: 'art'}), 
      (photo:Topic {topicId: 'photography'})
CREATE (carol)-[:INTERESTED_IN {since: date('2020-11-10')}]->(art),
       (carol)-[:INTERESTED_IN {since: date('2020-12-01')}]->(photo)

MATCH (eve:User {userId: 'eve_brown'}), 
      (fitness:Topic {topicId: 'fitness'})
CREATE (eve)-[:INTERESTED_IN {since: date('2021-01-08')}]->(fitness)

MATCH (frank:User {userId: 'frank_miller'}), 
      (music:Topic {topicId: 'music'}), 
      (coffee:Topic {topicId: 'coffee'})
CREATE (frank)-[:INTERESTED_IN {since: date('2019-12-03')}]->(music),
       (frank)-[:INTERESTED_IN {since: date('2020-01-20')}]->(coffee)
```

## Part 3: Creating Rich Content - Posts and Interactions (25 minutes)

### Step 6: Create Posts with Rich Metadata
```cypher
// Alice's tech-focused posts
MATCH (alice:User {userId: 'alice_smith'})
CREATE 
  (alice)-[:POSTED]->(:Post {
    postId: 'post_001',
    content: 'Just discovered an amazing new coffee shop in SF with the fastest Wi-Fi I\'ve ever experienced! ☕ Perfect for remote work sessions.',
    timestamp: datetime('2023-06-01T10:30:00'),
    likes: 23,
    shares: 3,
    visibility: 'public'
  }),
  (alice)-[:POSTED]->(:Post {
    postId: 'post_002',
    content: 'Working on some exciting new machine learning projects. The intersection of AI and human creativity never ceases to amaze me! 🤖💡',
    timestamp: datetime('2023-06-03T14:15:00'),
    likes: 45,
    shares: 8,
    visibility: 'public'
  })

// Bob's photography-focused posts
MATCH (bob:User {userId: 'bob_jones'})
CREATE 
  (bob)-[:POSTED]->(:Post {
    postId: 'post_003',
    content: 'Captured some stunning sunset photos in Central Park today 📸 The golden hour never disappoints!',
    timestamp: datetime('2023-06-02T19:45:00'),
    likes: 89,
    shares: 15,
    visibility: 'public'
  }),
  (bob)-[:POSTED]->(:Post {
    postId: 'post_004',
    content: 'Planning my next adventure - thinking about visiting Japan for cherry blossom season! 🌸🇯🇵 Any recommendations?',
    timestamp: datetime('2023-06-05T11:20:00'),
    likes: 34,
    shares: 6,
    visibility: 'public'
  })

// Carol's art-focused posts
MATCH (carol:User {userId: 'carol_davis'})
CREATE 
  (carol)-[:POSTED]->(:Post {
    postId: 'post_005',
    content: 'Opened a new contemporary art exhibition today featuring emerging London artists. So proud of the incredible talent in our city! 🎨',
    timestamp: datetime('2023-06-01T16:00:00'),
    likes: 56,
    shares: 9,
    visibility: 'public'
  })

// Eve's fitness posts
MATCH (eve:User {userId: 'eve_brown'})
CREATE 
  (eve)-[:POSTED]->(:Post {
    postId: 'post_006',
    content: 'Completed my first marathon in Berlin! 26.2 miles of pure determination and an incredible crowd 🏃‍♀️🏅',
    timestamp: datetime('2023-06-04T15:45:00'),
    likes: 78,
    shares: 14,
    visibility: 'public'
  })
```

### Step 7: Tag Posts with Topics
```cypher
// Tag Alice's posts
MATCH (post1:Post {postId: 'post_001'}), (tech:Topic {topicId: 'technology'})
CREATE (post1)-[:TAGGED_WITH]->(tech)

MATCH (post2:Post {postId: 'post_002'}), (tech:Topic {topicId: 'technology'}), (science:Topic {topicId: 'science'})
CREATE (post2)-[:TAGGED_WITH]->(tech), (post2)-[:TAGGED_WITH]->(science)

// Tag Bob's posts
MATCH (post3:Post {postId: 'post_003'}), (photo:Topic {topicId: 'photography'})
CREATE (post3)-[:TAGGED_WITH]->(photo)

MATCH (post4:Post {postId: 'post_004'}), (travel:Topic {topicId: 'travel'}), (photo:Topic {topicId: 'photography'})
CREATE (post4)-[:TAGGED_WITH]->(travel), (post4)-[:TAGGED_WITH]->(photo)

// Tag Carol's posts
MATCH (post5:Post {postId: 'post_005'}), (art:Topic {topicId: 'art'})
CREATE (post5)-[:TAGGED_WITH]->(art)

// Tag Eve's posts
MATCH (post6:Post {postId: 'post_006'}), (fitness:Topic {topicId: 'fitness'})
CREATE (post6)-[:TAGGED_WITH]->(fitness)
```

### Step 8: Create Comments and Engagement
```cypher
// Comments on Alice's coffee post
MATCH (alice_post:Post {postId: 'post_001'}), (bob:User {userId: 'bob_jones'})
CREATE (bob)-[:COMMENTED_ON]->(comment1:Comment {
  commentId: 'comment_001',
  content: 'Which coffee shop? I need to check it out when I visit SF next month!',
  timestamp: datetime('2023-06-01T11:15:00'),
  likes: 5
})-[:REPLIES_TO]->(alice_post)

MATCH (alice_post:Post {postId: 'post_001'}), (carol:User {userId: 'carol_davis'})
CREATE (carol)-[:COMMENTED_ON]->(comment2:Comment {
  commentId: 'comment_002',
  content: 'Love finding those hidden gems with great Wi-Fi! Perfect for creative work too 🎨',
  timestamp: datetime('2023-06-01T12:30:00'),
  likes: 3
})-[:REPLIES_TO]->(alice_post)

// Comments on Bob's travel post
MATCH (bob_post:Post {postId: 'post_004'}), (carol:User {userId: 'carol_davis'})
CREATE (carol)-[:COMMENTED_ON]->(comment3:Comment {
  commentId: 'comment_003',
  content: 'Tokyo and Kyoto are absolutely magical during cherry blossom season! Make sure to visit Philosopher\'s Path in Kyoto 🌸',
  timestamp: datetime('2023-06-05T12:45:00'),
  likes: 12
})-[:REPLIES_TO]->(bob_post)

MATCH (bob_post:Post {postId: 'post_004'}), (david:User {userId: 'david_wilson'})
CREATE (david)-[:COMMENTED_ON]->(comment4:Comment {
  commentId: 'comment_004',
  content: 'I went last year! The crowds can be intense but totally worth it. Book accommodations early!',
  timestamp: datetime('2023-06-05T13:20:00'),
  likes: 8
})-[:REPLIES_TO]->(bob_post)
```

### Step 9: Create Like Relationships
```cypher
// Users like various posts
MATCH (bob:User {userId: 'bob_jones'}), (alice_post:Post {postId: 'post_001'})
CREATE (bob)-[:LIKES {timestamp: datetime('2023-06-01T10:45:00')}]->(alice_post)

MATCH (carol:User {userId: 'carol_davis'}), (alice_post:Post {postId: 'post_001'})
CREATE (carol)-[:LIKES {timestamp: datetime('2023-06-01T11:00:00')}]->(alice_post)

MATCH (david:User {userId: 'david_wilson'}), (alice_post:Post {postId: 'post_002'})
CREATE (david)-[:LIKES {timestamp: datetime('2023-06-03T14:30:00')}]->(alice_post)

MATCH (alice:User {userId: 'alice_smith'}), (bob_post:Post {postId: 'post_003'})
CREATE (alice)-[:LIKES {timestamp: datetime('2023-06-02T20:00:00')}]->(bob_post)

MATCH (carol:User {userId: 'carol_davis'}), (bob_post:Post {postId: 'post_003'})
CREATE (carol)-[:LIKES {timestamp: datetime('2023-06-02T20:15:00')}]->(bob_post)

MATCH (eve:User {userId: 'eve_brown'}), (bob_post:Post {postId: 'post_003'})
CREATE (eve)-[:LIKES {timestamp: datetime('2023-06-02T21:30:00')}]->(bob_post)

// Users like comments too
MATCH (alice:User {userId: 'alice_smith'}), (comment:Comment {commentId: 'comment_001'})
CREATE (alice)-[:LIKES {timestamp: datetime('2023-06-01T11:20:00')}]->(comment)

MATCH (bob:User {userId: 'bob_jones'}), (comment:Comment {commentId: 'comment_003'})
CREATE (bob)-[:LIKES {timestamp: datetime('2023-06-05T13:00:00')}]->(comment)
```

## Part 4: Advanced Pattern Matching and Queries (20 minutes)

### Step 10: Multi-hop Relationship Queries
```cypher
// Find friends of friends who aren't already connected
MATCH (user:User {userId: 'alice_smith'})-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(fof:User)
WHERE NOT (user)-[:FOLLOWS]->(fof) AND fof <> user
RETURN DISTINCT fof.fullName AS potential_friend, 
       fof.username AS username,
       count(friend) AS mutual_friends,
       fof.interests AS shared_interests
ORDER BY mutual_friends DESC, fof.followerCount DESC
LIMIT 5
```

### Step 11: Content Discovery Through Networks
```cypher
// Find popular posts from people you follow
MATCH (user:User {userId: 'alice_smith'})-[:FOLLOWS]->(following:User)-[:POSTED]->(post:Post)
WHERE post.timestamp > datetime() - duration('P7D')  // Last 7 days
RETURN post.content AS content,
       following.username AS author,
       post.likes AS likes,
       post.shares AS shares,
       post.timestamp AS posted_at
ORDER BY post.likes DESC, post.timestamp DESC
LIMIT 10
```

### Step 12: Topic-Based Recommendations
```cypher
// Find posts from topics you're interested in
MATCH (user:User {userId: 'alice_smith'})-[:INTERESTED_IN]->(topic:Topic)<-[:TAGGED_WITH]-(post:Post)<-[:POSTED]-(author:User)
WHERE NOT (user)-[:FOLLOWS]->(author)  // From people you don't follow
  AND post.timestamp > datetime() - duration('P3D')  // Last 3 days
RETURN post.content AS content,
       author.username AS author,
       topic.name AS topic,
       post.likes AS engagement,
       post.timestamp AS posted_at
ORDER BY post.likes DESC
LIMIT 8
```

### Step 13: Engagement Analysis
```cypher
// Analyze user engagement patterns
MATCH (user:User)-[:POSTED]->(post:Post)
OPTIONAL MATCH (post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)<-[:REPLIES_TO]-(comment:Comment)
WITH user, post, count(DISTINCT liker) AS likes, count(DISTINCT comment) AS comments
RETURN user.username AS author,
       count(post) AS total_posts,
       avg(likes) AS avg_likes_per_post,
       avg(comments) AS avg_comments_per_post,
       max(likes) AS most_liked_post,
       sum(likes) AS total_likes
ORDER BY avg_likes_per_post DESC
```

### Step 14: Find Influential Users
```cypher
// Find users with high engagement and influence
MATCH (user:User)
OPTIONAL MATCH (user)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (user)<-[:FOLLOWS]-(follower:User)
WITH user, 
     count(DISTINCT liker) AS total_likes_received,
     count(DISTINCT follower) AS followers,
     count(DISTINCT post) AS posts
WHERE posts > 0
RETURN user.username AS username,
       user.fullName AS name,
       followers,
       posts,
       total_likes_received,
       round(total_likes_received * 1.0 / posts) AS avg_likes_per_post,
       round(total_likes_received * 1.0 / followers * 100) AS engagement_rate
ORDER BY engagement_rate DESC, followers DESC
```

## Part 5: Location-Based Features and Check-ins (10 minutes)

### Step 15: Create Location Nodes
```cypher
// Create popular locations for check-ins
CREATE (cafe1:Location:Venue {
  venueId: 'blue_bottle_sf',
  name: 'Blue Bottle Coffee',
  category: 'Coffee Shop',
  city: 'San Francisco',
  address: '300 The Embarcadero, San Francisco, CA',
  coordinates: point({latitude: 37.7849, longitude: -122.3927}),
  rating: 4.5,
  checkInCount: 1240
}),

(museum1:Location:Venue {
  venueId: 'tate_modern',
  name: 'Tate Modern',
  category: 'Museum',
  city: 'London',
  address: 'Bankside, London SE1 9TG, UK',
  coordinates: point({latitude: 51.5076, longitude: -0.0994}),
  rating: 4.8,
  checkInCount: 3450
}),

(park1:Location:Venue {
  venueId: 'central_park',
  name: 'Central Park',
  category: 'Park',
  city: 'New York',
  address: 'New York, NY 10024, USA',
  coordinates: point({latitude: 40.7829, longitude: -73.9654}),
  rating: 4.7,
  checkInCount: 8920
})
```

### Step 16: Create Check-in Relationships
```cypher
// Users check in at locations
MATCH (alice:User {userId: 'alice_smith'}), (cafe:Location {venueId: 'blue_bottle_sf'})
CREATE (alice)-[:CHECKED_IN {
  timestamp: datetime('2023-06-01T10:15:00'),
  rating: 5,
  review: 'Amazing coffee and super fast Wi-Fi!'
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

## Part 6: Advanced Social Network Analytics (15 minutes)

### Step 17: Community Detection
```cypher
// Find communities based on mutual follows and shared interests
MATCH (user1:User)-[:FOLLOWS]->(user2:User)-[:FOLLOWS]->(user3:User)
WHERE (user1)-[:FOLLOWS]->(user3)
  AND id(user1) < id(user2) < id(user3)  // Avoid duplicates
OPTIONAL MATCH (user1)-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(user2)
OPTIONAL MATCH (user2)-[:INTERESTED_IN]->(topic2:Topic)<-[:INTERESTED_IN]-(user3)
OPTIONAL MATCH (user1)-[:INTERESTED_IN]->(topic3:Topic)<-[:INTERESTED_IN]-(user3)
WITH user1, user2, user3, 
     count(DISTINCT topic) + count(DISTINCT topic2) + count(DISTINCT topic3) AS shared_interests
WHERE shared_interests > 0
RETURN user1.username AS user1, 
       user2.username AS user2, 
       user3.username AS user3,
       shared_interests
ORDER BY shared_interests DESC
```

### Step 18: Content Virality Analysis
```cypher
// Analyze how content spreads through the network
MATCH (post:Post)<-[:LIKES]-(user:User)
WITH post, count(user) AS likes
MATCH (post)<-[:POSTED]-(author:User)<-[:FOLLOWS]-(follower:User)
WITH post, author, likes, count(DISTINCT follower) AS potential_reach
MATCH (post)-[:TAGGED_WITH]->(topic:Topic)
RETURN post.postId AS post_id,
       post.content AS content,
       author.username AS author,
       likes,
       potential_reach,
       round(likes * 1.0 / potential_reach * 100) AS virality_score,
       collect(topic.name) AS topics
ORDER BY virality_score DESC
LIMIT 5
```

### Step 19: Influence Network Analysis
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
       round(total_likes * 1.0 / followers) AS likes_per_follower,
       round(followers * 1.0 / (followers + following_count) * 100) AS influence_ratio
ORDER BY influence_ratio DESC, followers DESC
```

### Step 20: Recommendation Engine
```cypher
// Advanced friend recommendations based on multiple factors
MATCH (user:User {userId: 'alice_smith'})
MATCH (user)-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(potential:User)
WHERE NOT (user)-[:FOLLOWS]->(potential) 
  AND potential <> user

// Calculate shared interests
OPTIONAL MATCH (user)-[:INTERESTED_IN]->(topic:Topic)<-[:INTERESTED_IN]-(potential)
WITH user, potential, count(DISTINCT topic) AS shared_interests

// Calculate mutual friends
MATCH (user)-[:FOLLOWS]->(mutual:User)-[:FOLLOWS]->(potential)
WITH user, potential, shared_interests, count(DISTINCT mutual) AS mutual_friends

// Calculate location proximity
WITH user, potential, shared_interests, mutual_friends,
     CASE WHEN distance(user.coordinates, potential.coordinates) < 100000 
          THEN 1 ELSE 0 END AS location_bonus

// Calculate recommendation score
WITH potential, 
     shared_interests * 3 + mutual_friends * 2 + location_bonus AS recommendation_score

WHERE recommendation_score > 2
RETURN potential.username AS recommended_user,
       potential.fullName AS name,
       potential.bio AS bio,
       shared_interests,
       mutual_friends,
       recommendation_score
ORDER BY recommendation_score DESC
LIMIT 5
```

## Lab Completion Checklist

- [ ] Created comprehensive user profiles with rich metadata
- [ ] Built complex social relationship networks (follows, interests)
- [ ] Implemented content creation system (posts, comments, likes)
- [ ] Created topic-based categorization and tagging
- [ ] Built location-based check-in functionality
- [ ] Wrote advanced multi-hop relationship queries
- [ ] Implemented friend recommendation algorithms
- [ ] Analyzed network patterns and user engagement
- [ ] Created community detection queries
- [ ] Built content virality and influence analysis

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

You now have expertise in building and analyzing complex social networks with sophisticated relationship patterns, content systems, and analytics capabilities. This knowledge prepares you for advanced visualization and Python integration in the final lab of Day 1.