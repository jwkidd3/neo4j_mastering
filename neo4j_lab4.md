# Lab 4: Interactive Visualizations & Multi-Tool Analytics

**Duration:** 75 minutes  
**Objective:** Master Neo4j visualization tools and create interactive analytics dashboards using multiple platforms

## Prerequisites

- Completed Lab 3 successfully with full social network data
- Neo4j Desktop project with social network from Lab 3
- Understanding of Cypher query language and complex patterns
- Familiarity with Neo4j Browser interface

## Learning Outcomes

By the end of this lab, you will:
- Master Neo4j Browser styling and customization techniques
- Explore data using Neo4j Bloom's natural language interface
- Create business-friendly visualizations with Bloom perspectives
- Export graph data to Python DataFrames for analysis
- Create interactive network diagrams with Plotly
- Build statistical charts combining graph and traditional metrics
- Develop comprehensive social network analytics dashboard
- Practice multi-tool workflows for different user types

## Part 1: Advanced Neo4j Browser Visualizations (20 minutes)

### Step 1: Verify Your Social Network Data
First, let's ensure all data from Lab 3 is available:

```cypher
// Check data completeness
MATCH (u:User) 
RETURN count(u) AS total_users,
       count(DISTINCT u.location) AS unique_locations

MATCH (p:Post) 
RETURN count(p) AS total_posts

MATCH ()-[r:FOLLOWS]->() 
RETURN count(r) AS follow_relationships

MATCH ()-[r:LIKES]->() 
RETURN count(r) AS like_relationships

MATCH (t:Topic) 
RETURN count(t) AS total_topics
```

**Expected Results:** 6 users, 6+ posts, 8+ follows, 6+ likes, 8 topics

### Step 2: Create Dynamic User Network Visualization
```cypher
// Visualize the complete social network with relationships
MATCH (u1:User)-[r:FOLLOWS]->(u2:User)
RETURN u1, r, u2
```

**Customize the visualization:**
1. **Click on `:User` in the result panel**
2. **Set node properties:**
   - **Color:** Based on location (different color per city)
   - **Size:** Based on followerCount
   - **Caption:** Show username instead of internal ID
3. **Click on `:FOLLOWS` relationship type**
4. **Set relationship properties:**
   - **Color:** Different color for relationship types
   - **Caption:** Show 'relationship' property

### Step 3: Advanced Graph Styling with Conditional Colors
```cypher
// Create a query that shows user influence
MATCH (u:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
WITH u, count(DISTINCT follower) AS followers, count(DISTINCT liker) AS total_likes
RETURN u, followers, total_likes,
       CASE 
         WHEN followers > 2000 THEN 'High Influence'
         WHEN followers > 1000 THEN 'Medium Influence'
         ELSE 'Growing Influence'
       END AS influence_level
```

**Styling Instructions:**
1. **Click on the `:User` label** in results
2. **Set Size:** Use the `followers` property
3. **Set Color:** Use the `influence_level` property for conditional coloring
4. **Set Caption:** Display both `username` and `influence_level`

### Step 4: Content Flow Visualization
```cypher
// Visualize how content flows through the network
MATCH (author:User)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (post)-[:TAGGED_WITH]->(topic:Topic)
RETURN author, post, liker, topic
LIMIT 20
```

**Advanced Styling:**
1. **Customize Node Types:**
   - **Users:** Blue circles, size by followerCount
   - **Posts:** Green squares, size by likes
   - **Topics:** Orange triangles, fixed size
2. **Customize Relationships:**
   - **POSTED:** Thick blue arrows
   - **LIKES:** Thin red arrows  
   - **TAGGED_WITH:** Dashed gray lines

### Step 5: Geographic Distribution Analysis
```cypher
// Show users and their locations with engagement
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)
RETURN u.username AS username,
       u.location AS location,
       u.coordinates AS coordinates,
       count(post) AS posts_count,
       u.followerCount AS followers
ORDER BY followers DESC
```

**Export this data for Python analysis:**
1. **Click the download icon** in the result panel
2. **Choose "Export CSV"**
3. **Save as:** `user_locations.csv`

## Part 2: Neo4j Bloom Visual Exploration (15 minutes)

### Step 6: Launch and Configure Neo4j Bloom
1. **Return to Neo4j Desktop**
2. **In your project, click the dropdown** next to "Open"
3. **Select "Neo4j Bloom"**
4. **Wait for Bloom to initialize** (30-60 seconds)

### Step 7: Natural Language Search Exploration
Try these natural language searches in Bloom:

**Basic Entity Discovery:**
- Type: `User` (shows all users)
- Type: `Alice` (finds Alice specifically)
- Type: `Technology` (finds the technology topic)
- Type: `Post` (shows all posts)

**Relationship Discovery:**
- Type: `User follows User` (shows follow relationships)
- Type: `User likes Post` (shows engagement)
- Type: `Post tagged with Topic` (shows content categorization)

### Step 8: Interactive Network Exploration
1. **Search for:** `alice_codes`
2. **When Alice appears, right-click** her node
3. **Select "Expand"** to see her immediate connections
4. **Continue expanding** other users to build the network
5. **Use the mouse** to:
   - **Drag nodes** to rearrange the layout
   - **Double-click nodes** to see detailed properties
   - **Use mouse wheel** to zoom in/out

### Step 9: Create Custom Bloom Perspective
1. **Click "Create Perspective"** in the top menu
2. **Name it:** "Social Network Analytics"
3. **Configure Node Categories:**
   - **User nodes:**
     - Size: Based on `followerCount`
     - Color: By `location` 
     - Caption: `{username} ({location})`
   - **Post nodes:**
     - Size: Based on `likes`
     - Color: Fixed green
     - Caption: `{likes} likes`
   - **Topic nodes:**
     - Size: Fixed medium
     - Color: By `trending` property
     - Caption: `{name}`

4. **Save the perspective**

### Step 10: Business User Scenario
Simulate a business stakeholder analysis:

1. **Search:** `fitness` to find fitness-related content
2. **Expand the topic** to see connected posts and users
3. **Right-click on Eve** (fitness enthusiast)
4. **Select "Shortest path to"** and choose Alice
5. **Analyze the connection path** between users

**Questions to explore:**
- How are different user communities connected?
- Which topics have the most engagement?
- What's the shortest path between any two users?

## Part 3: Python Data Export and Analysis Setup (15 minutes)

### Step 11: Launch Jupyter Lab and Create Analytics Notebook
1. **Open Terminal/Command Prompt**
2. **Navigate to your course directory:**
```bash
cd ~/neo4j-course/notebooks/day1
```
3. **Launch Jupyter Lab:**
```bash
jupyter lab
```
4. **Create new notebook:** `social_network_analytics.ipynb`

### Step 12: Install Required Python Packages
In your first notebook cell:

```python
# Install required packages for visualization
import subprocess
import sys

packages = ['neo4j', 'pandas', 'plotly', 'networkx', 'matplotlib', 'seaborn']

for package in packages:
    try:
        __import__(package)
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

print("✅ All packages ready!")
```

### Step 13: Establish Neo4j Connection
```python
# Import libraries and connect to Neo4j
from neo4j import GraphDatabase
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import networkx as nx
import matplotlib.pyplot as plt
import seaborn as sns

# Neo4j connection
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "coursepassword"))

def run_query(query, parameters=None):
    """Helper function to run Neo4j queries and return DataFrame"""
    with driver.session() as session:
        result = session.run(query, parameters)
        return pd.DataFrame([record.data() for record in result])

# Test connection
test_df = run_query("MATCH (u:User) RETURN count(u) AS user_count")
print(f"Connected! Found {test_df['user_count'].iloc[0]} users in database")
```

### Step 14: Extract User Network Data
```python
# Get user network data for visualization
users_query = """
MATCH (u:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
RETURN u.userId AS user_id,
       u.username AS username,
       u.fullName AS full_name,
       u.location AS location,
       u.followerCount AS followers,
       u.followingCount AS following,
       u.coordinates.latitude AS lat,
       u.coordinates.longitude AS lng,
       count(DISTINCT follower) AS actual_followers,
       count(DISTINCT following) AS actual_following,
       count(DISTINCT liker) AS total_likes_received
"""

users_df = run_query(users_query)
print("User Data Summary:")
print(users_df.head())
```

### Step 15: Extract Relationship Network
```python
# Get relationship data for network visualization
relationships_query = """
MATCH (u1:User)-[r:FOLLOWS]->(u2:User)
RETURN u1.username AS source,
       u2.username AS target,
       r.since AS since,
       r.relationship AS relationship_type
"""

relationships_df = run_query(relationships_query)
print(f"Found {len(relationships_df)} follow relationships")
print(relationships_df.head())
```

## Part 4: Interactive Network Visualizations with Plotly (15 minutes)

### Step 16: Create Interactive Social Network Graph
```python
# Create NetworkX graph for layout calculation
G = nx.from_pandas_edgelist(relationships_df, 'source', 'target', create_using=nx.DiGraph())

# Calculate layout positions
pos = nx.spring_layout(G, k=3, iterations=50)

# Prepare edge traces for Plotly
edge_x = []
edge_y = []
edge_info = []

for edge in G.edges():
    x0, y0 = pos[edge[0]]
    x1, y1 = pos[edge[1]]
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

# Create edge trace
edge_trace = go.Scatter(
    x=edge_x, y=edge_y,
    line=dict(width=1, color='#888'),
    hoverinfo='none',
    mode='lines'
)

# Prepare node traces
node_x = []
node_y = []
node_text = []
node_sizes = []
node_colors = []

for node in G.nodes():
    x, y = pos[node]
    node_x.append(x)
    node_y.append(y)
    
    # Get user info
    user_info = users_df[users_df['username'] == node].iloc[0]
    node_text.append(f"{user_info['full_name']}<br>"
                    f"@{user_info['username']}<br>"
                    f"Location: {user_info['location']}<br>"
                    f"Followers: {user_info['followers']}")
    
    # Size based on followers
    node_sizes.append(max(15, user_info['followers'] / 100))
    
    # Color based on location
    location_colors = {
        'San Francisco, CA': '#1f77b4',
        'New York, NY': '#ff7f0e', 
        'London, UK': '#2ca02c',
        'Toronto, Canada': '#d62728',
        'Berlin, Germany': '#9467bd',
        'Austin, TX': '#8c564b'
    }
    node_colors.append(location_colors.get(user_info['location'], '#17becf'))

# Create node trace
node_trace = go.Scatter(
    x=node_x, y=node_y,
    mode='markers+text',
    hoverinfo='text',
    text=[users_df[users_df['username'] == node]['username'].iloc[0] for node in G.nodes()],
    textposition='middle center',
    hovertext=node_text,
    marker=dict(
        size=node_sizes,
        color=node_colors,
        line=dict(width=2, color='white')
    )
)

# Create figure
fig = go.Figure(data=[edge_trace, node_trace],
               layout=go.Layout(
                title='Interactive Social Network Visualization',
                titlefont_size=16,
                showlegend=False,
                hovermode='closest',
                margin=dict(b=20,l=5,r=5,t=40),
                annotations=[ dict(
                    text="Hover over nodes for user details",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002,
                    xanchor='left', yanchor='bottom',
                    font=dict(color="gray", size=12)
                )],
                xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                yaxis=dict(showgrid=False, zeroline=False, showticklabels=False)
                ))

fig.show()
```

### Step 17: Geographic Distribution Visualization
```python
# Create world map showing user locations
fig = go.Figure()

# Add user locations
fig.add_trace(go.Scattermapbox(
    lat=users_df['lat'],
    lon=users_df['lng'],
    mode='markers',
    marker=dict(
        size=users_df['followers'] / 100,
        color=users_df['total_likes_received'],
        colorscale='Viridis',
        showscale=True,
        colorbar=dict(title="Total Likes Received")
    ),
    text=users_df['full_name'] + '<br>' + 
         'Followers: ' + users_df['followers'].astype(str) + '<br>' +
         'Likes Received: ' + users_df['total_likes_received'].astype(str),
    hovertemplate='<b>%{text}</b><extra></extra>'
))

# Update layout for map
fig.update_layout(
    title='Global User Distribution and Engagement',
    mapbox=dict(
        style='open-street-map',
        center=dict(lat=40, lon=-20),
        zoom=1
    ),
    height=600,
    margin=dict(l=0, r=0, t=30, b=0)
)

fig.show()
```

### Step 18: Engagement Analytics Dashboard
```python
# Create multi-chart dashboard
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=('User Engagement by Location', 'Follower vs Following Analysis', 
                   'Content Engagement Distribution', 'User Activity Heatmap'),
    specs=[[{"secondary_y": False}, {"secondary_y": False}],
           [{"secondary_y": False}, {"secondary_y": False}]]
)

# Chart 1: Engagement by location
location_stats = users_df.groupby('location').agg({
    'followers': 'mean',
    'total_likes_received': 'mean',
    'username': 'count'
}).round(0)

fig.add_trace(
    go.Bar(x=location_stats.index, 
           y=location_stats['followers'],
           name='Avg Followers',
           marker_color='lightblue'),
    row=1, col=1
)

# Chart 2: Follower vs Following scatter
fig.add_trace(
    go.Scatter(x=users_df['followers'], 
               y=users_df['following'],
               mode='markers+text',
               text=users_df['username'],
               textposition='top center',
               marker=dict(size=10, color='orange'),
               name='Users'),
    row=1, col=2
)

# Chart 3: Likes distribution
fig.add_trace(
    go.Histogram(x=users_df['total_likes_received'],
                 nbinsx=10,
                 name='Likes Distribution',
                 marker_color='green'),
    row=2, col=1
)

# Chart 4: Simple activity comparison
fig.add_trace(
    go.Bar(x=users_df['username'],
           y=users_df['total_likes_received'],
           name='Total Likes',
           marker_color='red'),
    row=2, col=2
)

# Update layout
fig.update_layout(height=800, showlegend=False, title_text="Social Network Analytics Dashboard")
fig.show()
```

## Part 5: Advanced Analytics and Insights (10 minutes)

### Step 19: Content Performance Analysis
```python
# Analyze post performance
posts_query = """
MATCH (u:User)-[:POSTED]->(p:Post)
OPTIONAL MATCH (p)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (p)-[:TAGGED_WITH]->(t:Topic)
RETURN u.username AS author,
       p.postId AS post_id,
       p.content AS content,
       p.likes AS likes,
       p.timestamp AS timestamp,
       count(DISTINCT liker) AS actual_likes,
       collect(DISTINCT t.name) AS topics
"""

posts_df = run_query(posts_query)

# Create content performance visualization
fig = px.scatter(posts_df, 
                x='likes', 
                y='actual_likes',
                hover_data=['author', 'content'],
                color='author',
                size=[len(str(content)) for content in posts_df['content']],
                title='Content Performance: Expected vs Actual Likes')

fig.update_layout(
    xaxis_title="Reported Likes",
    yaxis_title="Actual Likes (from relationships)",
    height=500
)

fig.show()

# Show content summary
print("Content Performance Summary:")
print(posts_df[['author', 'likes', 'actual_likes', 'topics']].head())
```

### Step 20: Network Influence Analysis
```python
# Calculate network metrics
influence_query = """
MATCH (u:User)
OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower:User)
OPTIONAL MATCH (u)-[:FOLLOWS]->(following:User)
OPTIONAL MATCH (u)-[:POSTED]->(post:Post)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (follower)-[:POSTED]->(follower_post:Post)<-[:LIKES]-(follower_liker:User)
WITH u,
     count(DISTINCT follower) AS followers,
     count(DISTINCT following) AS following,
     count(DISTINCT liker) AS likes_received,
     avg(count(DISTINCT follower_liker)) AS avg_follower_engagement
RETURN u.username AS username,
       u.fullName AS full_name,
       followers,
       following,
       likes_received,
       CASE WHEN followers > 0 THEN round(likes_received * 1.0 / followers * 100) ELSE 0 END AS engagement_rate,
       CASE 
         WHEN followers > 2000 THEN 'Macro Influencer'
         WHEN followers > 1000 THEN 'Micro Influencer' 
         WHEN followers > 500 THEN 'Rising Influencer'
         ELSE 'Community Member'
       END AS influence_category
ORDER BY followers DESC
"""

influence_df = run_query(influence_query)

# Create influence visualization
fig = px.scatter(influence_df,
                x='followers',
                y='engagement_rate', 
                size='likes_received',
                color='influence_category',
                hover_name='username',
                title='User Influence Analysis: Followers vs Engagement Rate')

fig.update_layout(
    xaxis_title="Number of Followers",
    yaxis_title="Engagement Rate (%)",
    height=500
)

fig.show()

print("Influence Analysis:")
print(influence_df)
```

## Part 6: Multi-Tool Workflow Summary (5 minutes)

### Step 21: Create Workflow Summary
```python
# Generate summary report
summary_stats = {
    'Total Users': len(users_df),
    'Total Relationships': len(relationships_df),
    'Average Followers': users_df['followers'].mean(),
    'Most Engaged User': users_df.loc[users_df['total_likes_received'].idxmax(), 'username'],
    'Most Connected City': users_df['location'].value_counts().index[0],
    'Network Density': len(relationships_df) / (len(users_df) * (len(users_df) - 1))
}

print("=== SOCIAL NETWORK ANALYSIS SUMMARY ===")
for key, value in summary_stats.items():
    print(f"{key}: {value}")

# Close Neo4j connection
driver.close()
```

### Step 22: Multi-Tool Comparison Table
Create a comparison of when to use each tool:

```python
import pandas as pd

tool_comparison = pd.DataFrame({
    'Tool': ['Neo4j Browser', 'Neo4j Bloom', 'Python/Jupyter'],
    'Best For': [
        'Technical query development and debugging',
        'Business user exploration and presentations', 
        'Advanced analytics and custom visualizations'
    ],
    'User Type': [
        'Developers, Data Engineers',
        'Business Analysts, Stakeholders',
        'Data Scientists, Analysts'
    ],
    'Strengths': [
        'Cypher development, Schema exploration',
        'Natural language, Visual discovery',
        'Statistical analysis, Custom dashboards'
    ],
    'Use Cases': [
        'Query optimization, Data modeling',
        'Executive demos, Pattern discovery',
        'Machine learning, Complex analytics'
    ]
})

print("\n=== MULTI-TOOL WORKFLOW GUIDE ===")
print(tool_comparison.to_string(index=False))
```

## Lab Completion Checklist

- [ ] Mastered advanced Neo4j Browser styling and customization
- [ ] Explored data using Neo4j Bloom's natural language interface
- [ ] Created custom Bloom perspectives for business users
- [ ] Exported graph data to Python DataFrames successfully
- [ ] Built interactive network visualizations with Plotly
- [ ] Created geographic distribution maps
- [ ] Developed multi-chart analytics dashboards
- [ ] Performed advanced network analysis and influence metrics
- [ ] Demonstrated content performance analytics
- [ ] Understood multi-tool workflow applications

## Key Concepts Mastered

1. **Advanced Browser Visualization:** Custom styling, conditional formatting
2. **Bloom Business Intelligence:** Natural language queries, perspective creation
3. **Python Integration:** Data export, DataFrame manipulation
4. **Interactive Visualizations:** Plotly network graphs, geographic maps
5. **Analytics Dashboards:** Multi-chart layouts, comparative analysis
6. **Network Analysis:** Influence metrics, engagement calculations
7. **Content Analytics:** Performance tracking, virality analysis
8. **Multi-Tool Workflows:** When to use each tool effectively
9. **Business Presentation:** Creating stakeholder-friendly visualizations
10. **Technical Documentation:** Comprehensive analysis reporting

## Tool-Specific Skills Developed

### Neo4j Browser
- Advanced Cypher query development
- Custom node and relationship styling
- Data export and sharing capabilities
- Performance analysis and optimization

### Neo4j Bloom  
- Natural language graph exploration
- Custom perspective creation for different audiences
- Interactive network discovery
- Business stakeholder presentations

### Python/Jupyter
- Neo4j driver integration and data extraction
- Plotly interactive visualization development
- NetworkX graph analysis and metrics
- Statistical analysis and reporting

## Next Steps

Congratulations! You've mastered the complete Neo4j ecosystem for social network analysis:
- Technical development with Neo4j Browser
- Business intelligence with Neo4j Bloom  
- Advanced analytics with Python integration
- Multi-tool workflows for different audiences

**Moving to Day 2**, you'll dive deeper into:
- Advanced Cypher patterns and optimization
- Graph algorithms and network science
- Large-scale analytics and performance tuning
- Production-ready graph applications

## Practice Exercises (Optional)

Try these advanced challenges:

1. **Executive Dashboard:** Create a Bloom perspective optimized for C-level presentations
2. **Real-time Monitoring:** Build a Python dashboard that updates with new data
3. **Comparative Analysis:** Compare your network metrics to industry benchmarks
4. **User Segmentation:** Create detailed user personas based on behavior patterns
5. **Predictive Analytics:** Build models to predict user engagement and growth

## Troubleshooting Guide

### Common Issues and Solutions

**Plotly visualization not displaying:**
```python
# Install/update Plotly
!pip install --upgrade plotly

# For Jupyter Lab, install extensions
!jupyter labextension install jupyterlab-plotly
```

**Neo4j connection issues:**
```python
# Test connection with timeout
from neo4j import GraphDatabase
import time

def test_connection():
    try:
        driver = GraphDatabase.driver("bolt://localhost:7687", 
                                    auth=("neo4j", "coursepassword"),
                                    connection_timeout=5)
        driver.verify_connectivity()
        print("✅ Connection successful!")
        return driver
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return None

driver = test_connection()
```

**Bloom not loading:**
- Ensure database is running in Neo4j Desktop
- Try refreshing the browser
- Check that Bloom plugin is properly installed

**Jupyter kernel crashes:**
```bash
# Restart Jupyter Lab
jupyter lab --port=8889  # Try different port if needed
```

## Quick Reference

**Multi-Tool Workflow:**
1. **Development:** Neo4j Browser for Cypher development and testing
2. **Business Intelligence:** Neo4j Bloom for stakeholder presentations
3. **Advanced Analytics:** Python/Jupyter for statistical analysis
4. **Production:** Export insights back to operational systems

**Key Python Libraries:**
- `neo4j`: Database connectivity
- `pandas`: Data manipulation
- `plotly`: Interactive visualizations
- `networkx`: Graph analysis
- `matplotlib/seaborn`: Statistical plots

---

**🎉 Lab 4 Complete!**

You now have comprehensive skills across the entire Neo4j ecosystem, from technical development to business presentations to advanced analytics. This multi-tool proficiency prepares you perfectly for the advanced graph algorithms and large-scale analytics you'll explore in Day 2 of the course!