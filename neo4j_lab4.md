# Lab 4: Interactive Visualizations & Multi-Tool Analytics

**Duration:** 75 minutes  
**Objective:** Master Neo4j visualization tools and create interactive analytics dashboards using multiple platforms

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop** (connection client)
- **Docker Desktop** with Neo4j Enterprise 2025.06.0 running (container name: neo4j)
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

✅ **From Previous Labs:**
- **Completed Lab 3** successfully with full social network data
- **Neo4j Desktop** project with social network from Lab 3
- **Understanding of Cypher** query language and complex patterns
- **Familiarity with Neo4j Browser** interface

## Learning Outcomes

By the end of this lab, you will:
- Master Neo4j Browser styling and customization techniques
- Export graph data to Python DataFrames for analysis
- Create interactive network diagrams with Plotly
- Build statistical charts combining graph and traditional metrics
- Develop comprehensive social network analytics dashboard
- Practice data visualization workflows for different user types

## Part 1: Advanced Neo4j Browser Visualizations (20 minutes)

### Step 1: Verify Your Social Network Data
First, let's ensure all data from Lab 3 is available:

```cypher
// Switch to social database
:use social
```

```cypher
// Check data completeness - run each query separately
MATCH (u:User) 
RETURN count(u) AS total_users,
       count(DISTINCT u.location) AS unique_locations
```

```cypher
MATCH (p:Post) 
RETURN count(p) AS total_posts
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

**Expected Results:** 6 users, 6+ posts, 8+ follows, 6+ likes, 8 topics

### Step 2: Create Dynamic User Network Visualization
```cypher
// Visualize the complete social network with relationships
MATCH (u1:User)-[r:FOLLOWS]->(u2:User)
RETURN u1, r, u2
```

This query will display the social network with default styling. You can explore the network by clicking and dragging nodes to see the connection patterns.

### Step 3: Advanced Browser Styling
Let's customize the visualization for better business presentation:

```cypher
// Create a comprehensive network view
MATCH (n)-[r]-(m) 
WHERE n:User OR n:Post OR n:Topic
RETURN n, r, m
LIMIT 50
```

**Professional Browser Styling:**
1. **Click "User" label** in the result panel (bottom left)
2. **Choose node color** (e.g., blue for users)
3. **Set node caption** to display username: `{username}`
4. **Adjust node size** based on followers

**Customize Post Nodes:**
1. **Click "Post" label** in the result panel
2. **Choose different color** (e.g., orange for posts)
3. **Set caption** to show content preview: `{content}`
4. **Use smaller size** for posts

**Relationship Styling:**
1. **Click on FOLLOWS relationships** to see connection patterns
2. **Click on LIKES relationships** to view engagement
3. **Observe relationship directions** and property details

### Step 4: Business Intelligence Visualization
```cypher
// Find influential users and their impact
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
OPTIONAL MATCH (p)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (follower:User)-[:FOLLOWS]->(u)
WITH u, 
     count(DISTINCT p) AS posts_count,
     count(DISTINCT liker) AS total_likes,
     count(DISTINCT follower) AS follower_count
WHERE follower_count > 0
RETURN u.username AS username,
       u.location AS location,
       follower_count,
       posts_count,
       total_likes,
       (follower_count + total_likes) AS influence_score
ORDER BY influence_score DESC
```

### Step 5: Topic and Content Network Analysis
```cypher
// Visualize content ecosystem
MATCH (u:User)-[:POSTED]->(p:Post)-[:TAGGED_WITH]->(t:Topic)
OPTIONAL MATCH (p)<-[:LIKES]-(liker:User)
RETURN u, p, t, count(liker) AS engagement_count
ORDER BY engagement_count DESC
LIMIT 20
```

## Part 2: Python Integration Setup (10 minutes)

### Step 6: Launch Jupyter Lab and Connect to Neo4j
Open a terminal and start Jupyter Lab:

```bash
jupyter lab
```

Create a new Python notebook named "lab4_social_network_analytics.ipynb"

### Step 7: Import Required Libraries
```python
# Import essential libraries for graph analytics
from neo4j import GraphDatabase
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import networkx as nx
import numpy as np

print("✅ All libraries imported successfully")
```

### Step 8: Establish Neo4j Connection
```python
# Connect to Docker Neo4j instance
try:
    driver = GraphDatabase.driver("bolt://localhost:7687", 
                                 auth=("neo4j", "password"), 
                                 database="social")
    driver.verify_connectivity()
    print("✅ Connected to Neo4j Docker container successfully!")
    
    # Test query
    with driver.session() as session:
        result = session.run("RETURN 'Docker Neo4j connection works!' AS message")
        print(result.single()["message"])
        
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("Check Docker Neo4j container is running")
```

### Step 9: Create Data Export Function
```python
# Utility function for running queries and returning DataFrames
def run_query(query, database="social"):
    """Execute Cypher query and return results as pandas DataFrame"""
    with driver.session(database=database) as session:
        result = session.run(query)
        data = [record.data() for record in result]
        return pd.DataFrame(data)

# Test the function
test_df = run_query("MATCH (u:User) RETURN count(u) AS user_count")
print(f"✅ Data export function working. User count: {test_df.iloc[0]['user_count']}")
```

## Part 3: Data Export and Analysis (15 minutes)

### Step 10: Export User Data
```python
# Export comprehensive user data
users_query = """
MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
OPTIONAL MATCH (p)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (follower:User)-[:FOLLOWS]->(u)
OPTIONAL MATCH (u)-[:INTERESTED_IN]->(topic:Topic)
WITH u, 
     count(DISTINCT p) AS posts_count,
     count(DISTINCT liker) AS total_likes_received,
     count(DISTINCT follower) AS followers,
     count(DISTINCT topic) AS interests_count
RETURN u.username AS username,
       u.age AS age,
       u.location AS location,
       followers,
       posts_count,
       total_likes_received,
       interests_count
ORDER BY followers DESC
"""

users_df = run_query(users_query)
print("User Data Shape:", users_df.shape)
print("\nUser Data Preview:")
print(users_df.head())
```

### Step 11: Export Relationship Data
```python
# Export relationship network
relationships_query = """
MATCH (u1:User)-[r:FOLLOWS]->(u2:User)
RETURN u1.username AS from_user,
       u2.username AS to_user,
       r.since AS relationship_since,
       'FOLLOWS' AS relationship_type
"""

relationships_df = run_query(relationships_query)
print("Relationships Data Shape:", relationships_df.shape)
print("\nRelationships Preview:")
print(relationships_df.head())
```

## Part 4: Interactive Plotly Visualizations (15 minutes)

### Step 12: Build NetworkX Graph Structure
```python
# Create NetworkX graph from Neo4j data
G = nx.from_pandas_edgelist(relationships_df, 
                           source='from_user', 
                           target='to_user',
                           create_using=nx.DiGraph())

# Add node attributes from user data
for _, row in users_df.iterrows():
    if row['username'] in G.nodes():
        G.nodes[row['username']]['location'] = row['location']
        G.nodes[row['username']]['followers'] = row['followers']
        G.nodes[row['username']]['total_likes'] = row['total_likes_received']

# Generate optimal layout for visualization
pos = nx.spring_layout(G, k=3, iterations=50)

print(f"✅ Graph created with {G.number_of_nodes()} nodes and {G.number_of_edges()} edges")
print(f"✅ Layout generated for {len(pos)} positions")
```

### Step 13: Create Interactive Network Visualization
```python
# Create edge traces for network connections
edge_x = []
edge_y = []
for edge in G.edges():
    x0, y0 = pos[edge[0]]
    x1, y1 = pos[edge[1]]
    edge_x.extend([x0, x1, None])
    edge_y.extend([y0, y1, None])

edge_trace = go.Scatter(x=edge_x, y=edge_y,
                       line=dict(width=2, color='lightgray'),
                       hoverinfo='none',
                       mode='lines')

# Create node traces with interactive features
node_x = []
node_y = []
node_text = []
node_color = []
node_size = []

for node in G.nodes():
    x, y = pos[node]
    node_x.append(x)
    node_y.append(y)
    
    # Get node attributes
    followers = G.nodes[node].get('followers', 0)
    location = G.nodes[node].get('location', 'Unknown')
    total_likes = G.nodes[node].get('total_likes', 0)
    
    node_text.append(f"{node}<br>Followers: {followers}<br>Location: {location}<br>Likes: {total_likes}")
    node_color.append(followers)
    node_size.append(max(15, followers * 2))  # Scale node size by followers

node_trace = go.Scatter(x=node_x, y=node_y,
                       mode='markers+text',
                       hoverinfo='text',
                       text=[node for node in G.nodes()],
                       hovertext=node_text,
                       textposition="middle center",
                       marker=dict(size=node_size,
                                 color=node_color,
                                 colorscale='blues',
                                 showscale=True,
                                 colorbar=dict(title="Followers")))

# Create and display the interactive figure
fig = go.Figure(data=[edge_trace, node_trace],
               layout=go.Layout(
                title=dict(text='Interactive Social Network Graph', font=dict(size=16)),
                showlegend=False,
                hovermode='closest',
                margin=dict(b=20,l=5,r=5,t=40),
                annotations=[ dict(
                    text="Node size = followers, color = followers count",
                    showarrow=False,
                    xref="paper", yref="paper",
                    x=0.005, y=-0.002,
                    xanchor="left", yanchor="bottom",
                    font=dict(color="gray", size=12)
                )],
                xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                yaxis=dict(showgrid=False, zeroline=False, showticklabels=False)))

fig.show()

# Alternative display methods if above doesn't work
print("✅ Network graph created successfully!")
print(f"Graph contains {len(node_x)} nodes and {len(edge_x)//3} edges")

# If graph doesn't display, try these alternatives:
# fig.show(renderer="browser")  # Opens in browser
# fig.write_html("network_graph.html")  # Saves to file
```

### Step 14: Geographic Distribution Analysis
```python
# Create geographic distribution chart
location_counts = users_df['location'].value_counts()

fig_geo = px.bar(x=location_counts.index, 
                 y=location_counts.values,
                 title='User Distribution by Location',
                 labels={'x': 'Location', 'y': 'Number of Users'},
                 color=location_counts.values,
                 color_continuous_scale='blues')

fig_geo.update_layout(showlegend=False, 
                     xaxis_title="Location",
                     yaxis_title="Number of Users")
fig_geo.show()

# Geographic influence analysis
geo_influence = users_df.groupby('location').agg({
    'followers': 'mean',
    'total_likes_received': 'mean',
    'interests_count': 'mean'
}).round(2)

print("\nInfluence by Location:")
print(geo_influence)
```

### Step 15: Multi-Chart Analytics Dashboard
```python
# Create comprehensive dashboard
fig_dashboard = make_subplots(
    rows=2, cols=2,
    subplot_titles=('User Age Distribution', 'Followers vs Engagement', 
                   'Interest Diversity', 'Network Metrics Summary'),
    specs=[[{"type": "histogram"}, {"type": "scatter"}],
           [{"type": "bar"}, {"type": "table"}]]
)

# Age distribution
fig_dashboard.add_trace(
    go.Histogram(x=users_df['age'], name='Age Distribution', nbinsx=10),
    row=1, col=1
)

# Followers vs engagement scatter
fig_dashboard.add_trace(
    go.Scatter(x=users_df['followers'], 
              y=users_df['total_likes_received'],
              mode='markers+text',
              text=users_df['username'],
              textposition="top center",
              name='Engagement Analysis',
              marker=dict(size=12, color='blue')),
    row=1, col=2
)

# Interest diversity by location
location_interests = users_df.groupby('location')['interests_count'].mean()
fig_dashboard.add_trace(
    go.Bar(x=location_interests.index, y=location_interests.values, name='Avg Interests'),
    row=2, col=1
)

# Network summary table
summary_data = [
    ['Total Users', len(users_df)],
    ['Total Connections', len(relationships_df)],
    ['Average Followers', round(users_df['followers'].mean(), 1)],
    ['Most Active Location', users_df['location'].value_counts().index[0]],
    ['Network Density', round(len(relationships_df) / (len(users_df) * (len(users_df) - 1)), 3)]
]

fig_dashboard.add_trace(
    go.Table(
        header=dict(values=['Metric', 'Value']),
        cells=dict(values=list(zip(*summary_data)))
    ),
    row=2, col=2
)

fig_dashboard.update_layout(height=800, showlegend=False, 
                           title_text="Social Network Analytics Dashboard")
fig_dashboard.show()

# Alternative display methods if dashboard doesn't appear
print("✅ Dashboard created successfully!")
print(f"Dashboard contains {len(users_df)} users across {len(location_interests)} locations")

# If dashboard doesn't display, try these alternatives:
# fig_dashboard.show(renderer="browser")  # Opens in browser
# fig_dashboard.write_html("analytics_dashboard.html")  # Saves to file

# Debug: Check if data exists for charts
print(f"Age data available: {not users_df['age'].empty}")
print(f"Location data available: {len(location_interests) > 0}")
print(f"Summary data rows: {len(summary_data)}")
```

## Part 5: Advanced Network Analysis (10 minutes)

### Step 16: Calculate Network Metrics
```python
# Advanced network analysis
def calculate_network_metrics():
    """Calculate comprehensive network metrics"""
    
    # Basic metrics
    num_nodes = G.number_of_nodes()
    num_edges = G.number_of_edges()
    density = nx.density(G)
    
    # Degree analysis
    degrees = dict(G.degree())
    avg_degree = sum(degrees.values()) / len(degrees)
    
    # Centrality measures
    betweenness = nx.betweenness_centrality(G)
    
    # Find most influential users
    followers_dict = {user: data['followers'] for user, data in G.nodes(data=True)}
    following_dict = dict(G.out_degree())
    
    most_followers = max(followers_dict.items(), key=lambda x: x[1])
    most_following = max(following_dict.items(), key=lambda x: x[1])
    most_between = max(betweenness.items(), key=lambda x: x[1])
    
    return {
        'nodes': num_nodes,
        'edges': num_edges,
        'density': round(density, 3),
        'avg_degree': round(avg_degree, 2),
        'most_followed_user': most_followers[0],
        'most_active_user': most_following[0],
        'most_bridge_user': most_between[0]
    }

network_metrics = calculate_network_metrics()

print("=== NETWORK ANALYSIS RESULTS ===")
for key, value in network_metrics.items():
    print(f"{key.replace('_', ' ').title()}: {value}")
```

### Step 17: Content Performance Analytics
```python
# Analyze content performance
content_query = """
MATCH (p:Post)
OPTIONAL MATCH (p)<-[:LIKES]-(liker:User)
OPTIONAL MATCH (p)<-[:POSTED]-(author:User)
OPTIONAL MATCH (p)-[:TAGGED_WITH]->(topic:Topic)
RETURN p.content AS content,
       author.username AS author,
       p.likes AS like_count,
       count(DISTINCT liker) AS actual_likes,
       count(DISTINCT topic) AS topic_count,
       p.timestamp AS post_time
ORDER BY p.likes DESC
"""

content_df = run_query(content_query)

print("=== CONTENT PERFORMANCE ANALYSIS ===")
print(f"Total Posts: {len(content_df)}")
print(f"Average Likes per Post: {content_df['like_count'].mean():.1f}")
print(f"Most Liked Post: {content_df.iloc[0]['like_count']} likes")
print(f"Top Performing Author: {content_df.iloc[0]['author']}")

# Create content performance visualization
fig_content = px.bar(content_df.head(10), 
                    x='author', 
                    y='like_count',
                    title='Top 10 Posts by Engagement',
                    labels={'like_count': 'Number of Likes', 'author': 'Post Author'},
                    color='like_count',
                    color_continuous_scale='viridis')

fig_content.update_layout(xaxis_tickangle=-45)
fig_content.show()
```

### Step 18: Multi-Tool Workflow Summary
```python
# Create comprehensive analysis summary
summary_stats = {
    'Total Users': len(users_df),
    'Total Relationships': len(relationships_df),
    'Average Followers': round(users_df['followers'].mean()),
    'Average Engagement': round(users_df['total_likes_received'].mean()),
    'Most Engaged User': users_df.loc[users_df['total_likes_received'].idxmax(), 'username'],
    'Most Connected City': users_df['location'].value_counts().index[0],
    'Network Density': round(len(relationships_df) / (len(users_df) * (len(users_df) - 1)), 3)
}

print("=== SOCIAL NETWORK ANALYSIS SUMMARY ===")
for key, value in summary_stats.items():
    print(f"{key}: {value}")

# Close Neo4j connection
driver.close()
```

### Step 19: Multi-Tool Comparison Table
Create a comparison of when to use each tool:

```python
import pandas as pd

tool_comparison = pd.DataFrame({
    'Tool': ['Neo4j Browser', 'Python/Jupyter'],
    'Best For': [
        'Technical query development and advanced visualization',
        'Advanced analytics and custom visualizations'
    ],
    'User Type': [
        'Developers, Data Engineers, Business Analysts',
        'Data Scientists, Analysts'
    ],
    'Strengths': [
        'Cypher development, Schema exploration, Interactive visualization',
        'Statistical analysis, Custom dashboards'
    ],
    'Use Cases': [
        'Query optimization, Data modeling, Business presentations',
        'Machine learning, Complex analytics'
    ]
})

print("\n=== DATA VISUALIZATION WORKFLOW GUIDE ===")
print(tool_comparison.to_string(index=False))
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

### If Neo4j Browser styling issues:
- **Refresh browser** and re-run queries
- **Clear result panel** with `:clear` command
- **Reset styling** by clicking node/relationship type buttons
- **Limit result size** with `LIMIT` clause for better performance

### Python connection issues:
```python
# Detailed connection test
from neo4j import GraphDatabase
try:
    driver = GraphDatabase.driver("bolt://localhost:7687", 
                                 auth=("neo4j", "password"), 
                                 database="social")
    driver.verify_connectivity()
    print("✅ Connection successful!")
    
    # Test query
    with driver.session() as session:
        result = session.run("RETURN 'Docker Neo4j connection works!' AS message")
        print(result.single()["message"])
        
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("Check Docker Neo4j container is running")
finally:
    if 'driver' in locals():
        driver.close()
```

### Plotly visualization not displaying:
```python
# Install/update Plotly
!pip install --upgrade plotly

# For Jupyter Lab, install extensions
!jupyter labextension install jupyterlab-plotly
```

### Jupyter kernel crashes:
```bash
# Restart Jupyter Lab
jupyter lab --port=8889  # Try different port if needed
```

## Lab Completion Checklist

- [ ] Mastered advanced Neo4j Browser styling and customization
- [ ] Created complex multi-layer network visualizations
- [ ] Developed business intelligence visualizations in Browser
- [ ] Exported graph data to Python DataFrames successfully
- [ ] Built interactive network visualizations with Plotly
- [ ] Created geographic distribution maps
- [ ] Developed multi-chart analytics dashboards
- [ ] Performed advanced network analysis and influence metrics
- [ ] Demonstrated content performance analytics
- [ ] Understood data visualization workflow applications

## Key Concepts Mastered

1. **Advanced Browser Visualization:** Custom styling, conditional formatting, multi-layer networks
2. **Business Intelligence Visualization:** Complex query visualization, influence analysis
3. **Python Integration:** Data export, DataFrame manipulation
4. **Interactive Visualizations:** Plotly network graphs, geographic maps
5. **Analytics Dashboards:** Multi-chart layouts, comparative analysis
6. **Network Analysis:** Influence metrics, engagement calculations
7. **Content Analytics:** Performance tracking, virality analysis
8. **Data Visualization Workflows:** When to use each approach effectively
9. **Business Presentation:** Creating stakeholder-friendly visualizations
10. **Technical Documentation:** Comprehensive analysis reporting

## Tool-Specific Skills Developed

### Neo4j Browser
- Advanced Cypher query development
- Custom node and relationship styling
- Multi-layer network visualization
- Data export and sharing capabilities
- Performance analysis and optimization
- Business intelligence visualization techniques

### Python/Jupyter
- Neo4j driver integration and data extraction
- Plotly interactive visualization development
- NetworkX graph analysis and metrics
- Statistical analysis and reporting
- Dashboard creation and presentation

## Next Steps

Congratulations! You've mastered the Neo4j ecosystem for social network analysis:
- Technical development with Neo4j Browser
- Advanced visualization techniques and styling
- Python integration for advanced analytics
- Data visualization workflows for different audiences

**Moving to Day 2**, you'll dive deeper into:
- Advanced Cypher patterns and optimization
- Graph algorithms and network science
- Large-scale analytics and performance tuning
- Production-ready graph applications

## Practice Exercises (Optional)

Try these advanced challenges:

1. **Advanced Browser Techniques:** Create sophisticated multi-layer visualizations in Neo4j Browser
2. **Real-time Monitoring:** Build a Python dashboard that updates with new data
3. **Comparative Analysis:** Compare your network metrics to industry benchmarks
4. **User Segmentation:** Create detailed user personas based on behavior patterns
5. **Predictive Analytics:** Build models to predict user engagement and growth

## Quick Reference

**Data Visualization Workflow:**
1. **Development:** Neo4j Browser for Cypher development and advanced visualization
2. **Business Intelligence:** Neo4j Browser with custom styling for presentations
3. **Advanced Analytics:** Python/Jupyter for statistical analysis and dashboards
4. **Production:** Export insights back to operational systems

**Key Python Libraries:**
- `neo4j`: Database connectivity
- `pandas`: Data manipulation
- `plotly`: Interactive visualizations
- `networkx`: Graph analysis
- `matplotlib/seaborn`: Statistical plots

---

**🎉 Lab 4 Complete!**

You now have comprehensive skills across Neo4j visualization and analytics, from technical development to business presentations to advanced analytics. This visualization proficiency prepares you perfectly for the advanced graph algorithms and large-scale analytics you'll explore in Day 2 of the course!