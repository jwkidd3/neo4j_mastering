# Neo4j 3-Day Course: Student Setup Guide

## Course Environment Overview
**Duration:** 3 Days (21.5 hours total)  
**Format:** 70% Labs (Jupyter Notebooks + Neo4j Tools), 30% Presentations  
**Platform:** Pre-configured environment with all tools installed  
**Languages:** Cypher (Days 1-2) + Python with Neo4j Driver (Day 3)

---

## Pre-Installed Software Environment

Your course environment comes fully configured with:

### Core Database Platform
- **Neo4j Desktop** - Project management and database administration
- **Neo4j Community Edition** - Graph database engine
- **Neo4j Browser** - Interactive Cypher development interface
- **Neo4j Bloom** - Visual graph exploration for business users

### Development Tools
- **Docker Desktop** - Container platform for deployment scenarios
- **Python 3.8+** - Programming language with pip package manager
- **Jupyter Lab** - Interactive notebook development environment
- **Web Browser** - Chrome/Firefox for Neo4j interfaces

### Neo4j Extensions & Libraries
- **APOC Procedures** - Advanced operations and functions
- **Graph Data Science Library** - Machine learning and analytics algorithms
- **Neo4j Python Driver** - Official Python connector with latest features

---

## Course Learning Environment

### What's Ready to Use
✅ **Neo4j Desktop** with sample projects and configurations  
✅ **Jupyter Lab** with pre-installed graph analysis packages  
✅ **Docker containers** configured for production-like scenarios  
✅ **Sample datasets** for social networks and business applications  
✅ **Python packages** including pandas, plotly, networkx, and more  

### What You'll Learn to Use
- **Neo4j Desktop interface** for project and database management
- **Cypher query language** for graph data operations
- **Neo4j Browser** for interactive development and visualization
- **Neo4j Bloom** for business-friendly graph exploration
- **Python integration** for application development
- **Production deployment** with Docker and monitoring

---

## Day 1: Environment Verification and First Steps

### Quick Start Checklist (5 minutes)

#### 1. Verify Neo4j Desktop
1. **Launch Neo4j Desktop** from your applications
2. **Check status:** Green indicators for all services
3. **Browse projects:** Ensure sample projects are available
4. **Test database creation:** Create a new project successfully

#### 2. Verify Neo4j Browser Access
1. **Open Neo4j Browser** via Desktop or direct navigation to http://localhost:7474
2. **Connect with credentials:** Use default neo4j/password (will be updated in Lab 1)
3. **Run test query:** Execute `:server status` command
4. **Verify result:** Should show "Connected" status

#### 3. Verify Jupyter Lab
1. **Launch Jupyter Lab** from terminal: `jupyter lab`
2. **Check packages:** Open new notebook and test imports
3. **Test Neo4j connection:** Verify Python driver connectivity
4. **Explore interface:** Familiarize with notebook environment

#### 4. Quick Connectivity Test
Run this verification in a Jupyter notebook:

```python
# Test all required packages
import neo4j
import pandas as pd
import matplotlib.pyplot as plt
import plotly.graph_objects as go
import networkx as nx
print("✅ All packages imported successfully")

# Test Neo4j connectivity  
from neo4j import GraphDatabase
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))
with driver.session() as session:
    result = session.run("RETURN 'Environment Ready!' as message")
    print(f"✅ {result.single()['message']}")
driver.close()
```

---

## Course Structure and Daily Flow

### Day 1: Graph Database Fundamentals (6.75 hours)
**Morning Focus:** Understanding graphs and Neo4j ecosystem
- **Neo4j Desktop** project setup and management
- **Cypher fundamentals** with ASCII art syntax
- **Social network modeling** hands-on practice
- **Visualization tools** including Browser and Bloom

**Tools Used:** Neo4j Desktop, Browser, Bloom
**Key Skills:** Graph thinking, Cypher basics, data modeling

### Day 2: Advanced Analytics & Algorithms (7.75 hours)
**Morning Focus:** Complex queries and graph algorithms
- **Advanced Cypher patterns** and performance optimization
- **Graph algorithms** for centrality and community detection
- **Social network analytics** with real-world applications
- **Algorithm implementation** and performance tuning

**Tools Used:** Neo4j Browser, Jupyter Lab
**Key Skills:** Complex queries, algorithm implementation, analytics

### Day 3: Python Integration & Production (7.0 hours)
**Morning Focus:** Professional application development
- **Enterprise data modeling** and best practices
- **Python application development** with Neo4j driver
- **Production deployment** strategies and monitoring
- **Full-stack applications** with web interfaces

**Tools Used:** Jupyter Lab, Python, Docker
**Key Skills:** Application development, deployment, production readiness

---

## Learning Resources and Support

### Built-in Help Systems
- **Neo4j Browser:** Type `:help` for command reference
- **Neo4j Desktop:** Built-in guides and documentation
- **APOC Procedures:** `:help apoc` for available functions
- **Cypher Reference:** `:help cypher` for syntax guide

### Course Materials Location
- **Lab Guides:** Markdown files in `~/neo4j-course/labs/`
- **Sample Data:** CSV files in `~/neo4j-course/data/`
- **Jupyter Notebooks:** Template notebooks in `~/neo4j-course/notebooks/`
- **Python Scripts:** Starter code in `~/neo4j-course/scripts/`

### Documentation Quick Links
- **Neo4j Documentation:** https://neo4j.com/docs/
- **Cypher Manual:** https://neo4j.com/docs/cypher-manual/current/
- **Python Driver Guide:** https://neo4j.com/docs/python-manual/current/
- **APOC Documentation:** https://neo4j.com/labs/apoc/

---

## Daily Environment Startup

### Standard Startup Procedure (2 minutes)

```bash
# 1. Start Neo4j Desktop (if not auto-started)
# Launch from applications or dock

# 2. Start Jupyter Lab for development
jupyter lab
# Opens automatically in browser at http://localhost:8888

# 3. Verify Neo4j connectivity
# Neo4j Browser available at http://localhost:7474
```

### Troubleshooting Quick Fixes

#### Neo4j Desktop Issues
```bash
# If Desktop won't start
sudo pkill -f neo4j
# Restart Neo4j Desktop application

# If database won't start
# Use Desktop interface: Stop → Start database
# Check logs in Desktop for specific errors
```

#### Jupyter Lab Issues  
```bash
# If Jupyter won't start
jupyter lab --port=8889  # Try different port

# If packages missing
pip install --upgrade neo4j pandas plotly networkx

# If kernel dies
# Restart kernel in Jupyter interface
```

#### Connectivity Issues
```bash
# Test Neo4j connection
curl http://localhost:7474
# Should return HTML response

# Check Docker containers (if using Docker deployment)
docker ps | grep neo4j

# Reset database (if needed)
# Use Neo4j Desktop: Stop → Delete → Create new database
```

---

## Course Project Structure

### Recommended Directory Organization
```
~/neo4j-course/
├── labs/              # Lab exercise guides
│   ├── day1/         # Day 1 lab materials
│   ├── day2/         # Day 2 lab materials  
│   └── day3/         # Day 3 lab materials
├── notebooks/         # Jupyter notebook workspace
│   ├── day1/         # Day 1 development notebooks
│   ├── day2/         # Day 2 analytics notebooks
│   └── day3/         # Day 3 application notebooks
├── data/             # Sample datasets and imports
│   ├── social-network/
│   ├── e-commerce/
│   └── enterprise/
├── scripts/          # Python application code
│   ├── utils/        # Utility functions
│   └── apps/         # Full applications
└── exports/          # Query results and visualizations
```

### Data Persistence Strategy
- **Neo4j Desktop Projects:** Automatic data persistence across sessions
- **Jupyter Notebooks:** Auto-save enabled, manual save recommended
- **Lab Progress:** Each lab builds on previous work
- **Final Projects:** Comprehensive applications using all learned skills

---

## Assessment and Progress Tracking

### Daily Learning Checkpoints
- **Lab Completion:** Practical exercises with measurable outcomes
- **Knowledge Checks:** Quick assessments integrated into presentations
- **Peer Collaboration:** Group problem-solving and code review
- **Progress Portfolio:** Collection of working queries and applications

### Skills Development Path
1. **Day 1 Outcomes:** Graph thinking, Cypher fundamentals, data modeling
2. **Day 2 Outcomes:** Advanced analytics, algorithm implementation, optimization
3. **Day 3 Outcomes:** Professional development, Python integration, deployment

### Final Project Demonstration
- **Working Application:** Complete graph-powered application
- **Technical Presentation:** Architecture and implementation explanation
- **Business Value:** Real-world application and benefits demonstration

---

## Production Readiness Preparation

### Course Completion Skills
Upon finishing this course, you'll be prepared to:
- **Design and implement** production graph databases
- **Develop applications** using Neo4j and Python
- **Optimize performance** for real-world workloads
- **Deploy and monitor** graph applications in production
- **Apply graph thinking** to complex business problems

### Next Steps and Certification
- **Neo4j Professional Certification:** Industry-recognized credentials
- **Advanced Graph Algorithms:** Specialized algorithm development
- **Enterprise Deployment:** Clustering and high-availability systems
- **Domain Applications:** Industry-specific graph implementations

---

## Support and Communication

### During the Course
- **Instructor Support:** Available during all lab sessions
- **Peer Collaboration:** Encouraged for complex challenges
- **Technical Issues:** Immediate troubleshooting assistance
- **Learning Resources:** Comprehensive documentation and examples

### Post-Course Resources
- **Course Materials:** Full access to all lab guides and examples
- **Community Forums:** Neo4j community for ongoing support
- **Documentation:** Complete reference materials and tutorials
- **Certification Path:** Guidance for professional development

---

## Emergency Backup Plans

### If Primary Environment Fails
1. **Neo4j Aura Cloud:** Free cloud database backup (https://aura.neo4j.io)
2. **Docker Containers:** Portable environment recreation
3. **Google Colab:** Cloud-based Jupyter notebooks
4. **Alternative Datasets:** Simplified data for core learning

### Critical File Backup
- **Export queries:** Save important Cypher statements
- **Download notebooks:** Local copies of development work
- **Screenshot progress:** Visual documentation of achievements
- **Note key insights:** Written summary of learning outcomes

---

## Quick Reference

### Essential URLs
- **Neo4j Browser:** http://localhost:7474
- **Jupyter Lab:** http://localhost:8888
- **Neo4j Desktop:** Local application interface

### Default Credentials
- **Neo4j Database:** neo4j / password (updated in Lab 1)
- **Neo4j Desktop:** Local user authentication
- **Jupyter Lab:** No authentication required locally

### Essential Commands
```cypher
// Neo4j Browser basics
:help                  // Get help
:clear                 // Clear results  
:server status         // Check connection
:sysinfo              // System information

// Basic Cypher patterns
CREATE (n:Label {property: 'value'})
MATCH (n) RETURN n
MATCH (a)-[:RELATION]->(b) RETURN a, b
```

### Python Driver Basics
```python
from neo4j import GraphDatabase

# Connection
driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))

# Query execution  
with driver.session() as session:
    result = session.run("MATCH (n) RETURN count(n) as total")
    count = result.single()["total"]
    print(f"Total nodes: {count}")

# Cleanup
driver.close()
```

---

**🚀 Ready to Explore the Graph Universe!**

Your environment is fully configured and ready for an intensive journey into graph databases. The combination of Neo4j Desktop, Browser, Bloom, and Python provides a comprehensive toolkit for mastering graph technologies. Let's build amazing graph-powered applications together!

---

## Course Day-by-Day Environment Usage

### Day 1 Environment Flow
1. **Morning:** Neo4j Desktop orientation and project setup
2. **Midday:** Neo4j Browser for Cypher development
3. **Afternoon:** Neo4j Bloom for business visualization
4. **Integration:** Basic Python connectivity verification

### Day 2 Environment Flow  
1. **Morning:** Advanced Cypher development in Browser
2. **Midday:** Jupyter Lab for analytics and algorithms
3. **Afternoon:** Performance optimization and monitoring
4. **Integration:** Complex query development and testing

### Day 3 Environment Flow
1. **Morning:** Enterprise modeling in Neo4j Desktop
2. **Midday:** Python application development in Jupyter
3. **Afternoon:** Production deployment with Docker
4. **Integration:** Complete application demonstration

This progression ensures you master each tool in the Neo4j ecosystem while building practical, production-ready skills.