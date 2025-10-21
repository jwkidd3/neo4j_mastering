# Neo4j Mastering Course

A comprehensive 3-day (18 hours) Neo4j training course with hands-on labs, presentations, and automated testing.

## 📚 Course Overview

- **Duration:** 18 hours (6 hours per day)
- **Format:** 70% Labs (12.6 hours) / 30% Presentations (5.4 hours)
- **Labs:** 17 hands-on labs
- **Platform:** Neo4j Enterprise 5.26.9 (Docker)
- **Domain:** Insurance Company (1000+ entities)
- **Languages:** Cypher → Python progression

## 🗂️ Directory Structure

```
neo4j_mastering/
├── labs/                    # 17 lab markdown files
├── presentations/           # 3 HTML presentations (Reveal.js)
├── testscripts/            # Comprehensive test suite (188+ tests)
├── data/                   # 8 data reload scripts
├── design_architecture/     # Technical reference documentation (4 files)
├── insurance/              # Insurance database scripts
├── scripts/                # Utility scripts (Windows batch files)
└── README.md               # Complete course documentation
```

## 🛠️ Environment Setup

### Prerequisites

**Required Software:**
- Docker Desktop (for Neo4j Enterprise)
- Python 3.8+ (for Day 3 labs and testing)
- Neo4j Desktop (optional but recommended)
- Modern web browser (for presentations and Neo4j Browser)

**Hardware Requirements:**
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space
- Internet connection for Docker images

### ⚠️ Important: Windows Users - GDS Compatibility

**The Graph Data Science (GDS) plugin may not work on Windows.** This affects Lab 7 (Graph Algorithms) primarily.

**Solutions:**
- ✅ Lab 7 includes complete alternative exercises using native Cypher
- ✅ All learning objectives are achievable without GDS
- ✅ See [WINDOWS_GDS_GUIDE.md](WINDOWS_GDS_GUIDE.md) for detailed instructions

**Affected Labs:**
- Lab 1 (Step 10): Minor - just a preview, alternative provided
- Lab 7: Major - full alternatives provided at beginning of lab
- Lab 15: None - just configuration reference

### Step 1: Neo4j Enterprise Setup (Docker)

**Mac/Linux:**
```bash
docker run --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  -e NEO4J_PLUGINS='["apoc","graph-data-science"]' \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -d neo4j:5.26.9-enterprise
```

**Windows (PowerShell):**
```powershell
docker run --name neo4j `
  -p 7474:7474 -p 7687:7687 `
  -v $HOME/neo4j/data:/data `
  -v $HOME/neo4j/logs:/logs `
  -v $HOME/neo4j/import:/var/lib/neo4j/import `
  -e NEO4J_AUTH=neo4j/password `
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes `
  -d neo4j:5.26.9-enterprise

# Install APOC plugin
docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/apoc-5.26.9-core.jar https://github.com/neo4j/apoc/releases/download/5.26.9/apoc-5.26.9-core.jar"

# Install Graph Data Science plugin
docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/neo4j-graph-data-science-2.12.1.jar https://github.com/neo4j/graph-data-science/releases/download/2.12.1/neo4j-graph-data-science-2.12.1.jar"

# Restart Neo4j to load plugins
docker restart neo4j
```

**Verify Installation:**
```bash
# Check container is running
docker ps | grep neo4j

# Access Neo4j Browser
# Open http://localhost:7474
# Login: neo4j / password
```

### Step 2: Python Environment Setup (Day 3)

**Create Virtual Environment:**
```bash
# Navigate to course directory
cd /path/to/neo4j_mastering

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Mac/Linux:
source venv/bin/activate

# On Windows (Command Prompt):
venv\Scripts\activate.bat

# On Windows (PowerShell):
Set-ExecutionPolicy Unrestricted -Force
venv\Scripts\Activate.ps1
```

**Install Dependencies:**
```bash
# Install test suite requirements
pip install -r testscripts/requirements.txt

# Or install packages individually
pip install pytest neo4j python-dotenv

# For Jupyter notebooks (Day 3 labs)
pip install notebook ipykernel pandas numpy matplotlib

# Register Jupyter kernel
python -m ipykernel install --user --name=neo4j-course --display-name "Python 3 (Neo4j Course)"
```

**Launch Jupyter (optional):**
```bash
jupyter lab
```

### Step 3: Verify Setup (Optional)

**Run Automated Test Suite:**

The test scripts handle EVERYTHING automatically (Docker + Python + Neo4j):

```bash
cd testscripts
./run_tests.sh  # Mac/Linux
# or
run_tests.bat   # Windows
```

This will:
- Pull Neo4j image if needed
- Create and start container
- Set up Python environment
- Run all tests
- Clean up everything

**Manual Verification (Optional - For Course Development):**

```bash
# Check Docker is running
docker info

# Check Python version
python3 --version  # Should be 3.8+
```

## 🚀 Quick Start

### For Students

1. **Complete Environment Setup** (see above)

2. **Follow Daily Course Structure:**
   - **Day 1:** Labs 1-5 + Presentation 1
   - **Day 2:** Labs 6-11 + Presentation 2
   - **Day 3:** Labs 12-17 + Presentation 3

3. **Access Materials:**
   - Labs: `labs/neo4j_lab_*.md`
   - Presentations: `presentations/neo4j_day*.html` (open in browser)
   - Neo4j Browser: http://localhost:7474

4. **If You Get Stuck:**
   - Use data reload scripts to reset database state
   - Run tests to verify your progress
   - Check testscripts/README.md for troubleshooting

### For Instructors

1. **Preparation:**
   ```bash
   # Verify all materials present
   ls labs/*.md | wc -l          # Should show 17
   ls presentations/*.html | wc -l  # Should show 3
   ls data/*.cypher | wc -l      # Should show 8

   # Validate entire course (fully automated)
   cd testscripts && ./run_tests.sh
   # Script automatically: pulls image, starts Neo4j, runs tests, cleans up
   # Prerequisites: Docker + Python 3.8+ only
   ```

2. **Teaching Flow:**
   - Open presentations from `presentations/` folder
   - Guide students through labs in `labs/` folder
   - Use data reload scripts if students need to catch up:
     ```bash
     docker exec -i neo4j cypher-shell -u neo4j -p password \
       -d insurance < data/lab_05_data_reload.cypher
     ```

3. **Validate Student Progress:**
   ```bash
   # Quick validation - completely automated (recommended)
   cd testscripts && ./run_tests.sh
   # No setup needed! Script handles Docker, Neo4j, Python, everything.

   # Manual testing (requires Neo4j already running)
   pip install -r testscripts/requirements.txt
   pytest testscripts/test_lab_01_setup.py -v   # Check Lab 1
   pytest testscripts/test_lab_05_*.py -v       # Check Day 1 complete
   python testscripts/test_runner.py --day 1    # Test all Day 1 labs
   ```

## 📖 Course Content

### Day 1: Fundamentals (Labs 1-5)
**Duration:** 6 hours | **Database Evolution:** 10 nodes → 200+ nodes

**Topics:**
- Enterprise Setup & Docker Connection
- Cypher Query Fundamentals (MWR Pattern)
- Claims & Financial Transaction Modeling
- Bulk Data Import & Quality Control
- Advanced Analytics Foundation

**Key Skills:**
- Neo4j Enterprise deployment in Docker
- Cypher MATCH-WHERE-RETURN patterns
- Property graph modeling for insurance domain
- CSV bulk import strategies
- Customer 360-degree views

### Day 2: Advanced Analytics (Labs 6-11)
**Duration:** 6 hours | **Database Evolution:** 200+ nodes → 600+ nodes

**Topics:**
- Customer Intelligence & Segmentation
- Graph Algorithms for Insurance
- Performance Optimization
- Fraud Detection & Investigation
- Compliance & Audit Trail Implementation
- Predictive Analytics & Machine Learning

**Key Skills:**
- Centrality algorithms and community detection
- Query optimization and indexing strategies
- Network-based fraud detection patterns
- Regulatory compliance modeling
- Graph-based predictive analytics

### Day 3: Production (Labs 12-17)
**Duration:** 6 hours | **Database Evolution:** 600+ nodes → 1000+ nodes

**Topics:**
- Python Driver & Service Architecture
- Insurance Web Application Development
- Production Infrastructure & Deployment
- Complete Platform Integration
- Multi-Line Insurance Platform
- Innovation Showcase (AI/ML, IoT, Blockchain)

**Key Skills:**
- Neo4j Python driver and connection management
- RESTful API development with graph backend
- Production deployment patterns
- Real-time web applications
- Enterprise system integration

## 📊 Database Evolution

The course progressively builds a comprehensive insurance database:

| Lab | Nodes | Relationships | Key Additions |
|-----|-------|---------------|---------------|
| Lab 1 | 10 | 15 | Customers, Policies, Agents |
| Lab 2 | 25 | 40 | Family relationships, multiple policies |
| Lab 3 | 60 | 85 | Claims, financial transactions |
| Lab 4 | 150 | 200 | Bulk customer/policy import |
| Lab 5 | 200 | 300 | Risk assessments, analytics |
| Lab 6 | 280 | 380 | Customer segmentation |
| Lab 7 | 350 | 450 | Community structures |
| Lab 8 | 400 | 500 | Performance optimizations |
| Lab 9 | 480 | 580 | Fraud detection patterns |
| Lab 10 | 550 | 650 | Compliance records |
| Lab 11 | 600 | 750 | Predictive models |
| Lab 12 | 650 | 800 | Python service integration |
| Lab 13 | 720 | 900 | API endpoints |
| Lab 14 | 800 | 1000 | Web application features |
| Lab 15 | 850 | 1100 | Production infrastructure |
| Lab 16 | 950 | 1200 | Multi-line insurance |
| Lab 17 | 1000+ | 1300+ | Innovation capabilities |

## 🧪 Testing & Validation

The course includes a comprehensive automated test suite with 188+ individual tests covering all lab steps.

### Automated Test Suite (Recommended)

**Prerequisites:**
- Docker installed and running
- Python 3.8+ installed

**That's it! Everything else is automated.**

**Run All Tests:**

```bash
cd testscripts
./run_tests.sh              # Mac/Linux
run_tests.bat               # Windows
```

**The scripts automatically:**
- ✅ Check Docker and Python are installed
- ✅ Pull Neo4j Enterprise 5.26.9 image
- ✅ Create and start Neo4j container
- ✅ Install APOC plugin
- ✅ Create insurance database
- ✅ **Load Labs 1-8 sequentially** (foundation: ~400 nodes, ~500 relationships)
- ✅ **Load Lab 17 advanced features** (Labs 9-17: additional ~600 nodes, ~800 relationships)
- ✅ Set up Python virtual environment
- ✅ Install all required packages
- ✅ Run comprehensive test suite (188+ tests)
- ✅ Clean up and delete everything:
  - Python virtual environment
  - Neo4j container
  - Neo4j image (if downloaded)
  - All temporary volumes

**Complete isolation - no manual setup, no leftover artifacts!**

**Time:** First run ~5-10 minutes (image download), subsequent runs ~2-3 minutes

**Note:** Data is loaded progressively - Labs 1-8 build on each other sequentially, then Lab 17 adds all advanced features. Final database: **1000+ nodes, 1300+ relationships** representing the complete insurance platform.

### Manual Testing (Advanced)

**Test Specific Labs (Requires Manual Setup):**
```bash
# 1. Start Neo4j manually
docker run -d --name neo4j -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  neo4j:5.26.9-enterprise

# 2. Install dependencies
pip install -r testscripts/requirements.txt

# 3. Run specific tests
pytest testscripts/test_lab_05_*.py -v     # Test Lab 5
pytest testscripts/test_lab_1*.py -v       # Test Labs 10-17
python testscripts/test_runner.py --lab 5  # Test Lab 5
python testscripts/test_runner.py --day 1  # Test Day 1 (Labs 1-5)

# 4. Manual cleanup
docker stop neo4j && docker rm neo4j
```

### Expected Test Results
- ✅ All node counts match expected values
- ✅ All relationship types exist
- ✅ Constraints and indexes properly configured
- ✅ Query performance meets benchmarks
- ✅ Data integrity checks pass

See `testscripts/README.md` for detailed testing documentation.

## 🔄 Data Recovery

If students need to reset their database to a specific lab state:

### Important: Labs Build Progressively
Each lab builds upon the previous lab's data. To load a specific lab state, you must load all previous labs sequentially.

### Loading Specific Lab States

```bash
# Example: Load Lab 3 state
# Must load Labs 1, 2, then 3 in sequence
docker exec -i neo4j cypher-shell -u neo4j -p password -d insurance < data/lab_01_data_reload.cypher
docker exec -i neo4j cypher-shell -u neo4j -p password -d insurance < data/lab_02_data_reload.cypher
docker exec -i neo4j cypher-shell -u neo4j -p password -d insurance < data/lab_03_data_reload.cypher

# Example: Load Lab 5 state (Day 1 complete)
# Load Labs 1-5 sequentially
for i in {01..05}; do
  docker exec -i neo4j cypher-shell -u neo4j -p password \
    -d insurance < data/lab_${i}_data_reload.cypher
done

# Example: Load Lab 8 state (Day 2 midpoint)
# Load Labs 1-8 sequentially
for i in {01..08}; do
  docker exec -i neo4j cypher-shell -u neo4j -p password \
    -d insurance < data/lab_${i}_data_reload.cypher
done

# Example: Load complete Lab 17 state (Full platform)
# Load Labs 1-8, then Lab 17 (which contains Labs 9-17)
for i in {01..08}; do
  docker exec -i neo4j cypher-shell -u neo4j -p password \
    -d insurance < data/lab_${i}_data_reload.cypher
done
docker exec -i neo4j cypher-shell -u neo4j -p password \
  -d insurance < data/lab_17_data_reload.cypher
```

### Available Data Reload Scripts
- **Labs 1-8:** Individual files that build progressively
  - `lab_01_data_reload.cypher` → `lab_08_data_reload.cypher`
  - Each lab adds entities to the previous lab's data

- **Labs 9-17:** Individual files that require Labs 1-8 foundation
  - `lab_09_data_reload.cypher` → `lab_16_data_reload.cypher` (individual advanced features)
  - `lab_17_data_reload.cypher` (comprehensive Labs 9-17 in one file)

### Quick Reference
| Target State | Command |
|-------------|---------|
| Lab 1 | Load lab_01 |
| Lab 5 (Day 1) | Load labs 01→05 sequentially |
| Lab 8 (Day 2 mid) | Load labs 01→08 sequentially |
| Lab 11 | Load labs 01→08, then lab_11 |
| Lab 17 (Complete) | Load labs 01→08, then lab_17 |

## 🎯 Learning Outcomes

By the end of this course, students will be able to:

✅ **Deploy & Configure**
- Set up Neo4j Enterprise in Docker with APOC and GDS plugins
- Configure remote connections using Neo4j Desktop
- Implement enterprise security and authentication

✅ **Query & Model**
- Write complex Cypher queries using the MWR pattern
- Model insurance business domains in graph databases
- Design efficient graph schemas with proper relationships

✅ **Import & Manage**
- Implement bulk data import with quality controls
- Create and enforce constraints and indexes
- Manage database state and data lifecycle

✅ **Analyze & Optimize**
- Build customer 360-degree views and analytics
- Apply graph algorithms for fraud detection
- Optimize query performance with indexes and profiling

✅ **Build & Deploy**
- Integrate Neo4j with Python applications
- Build production-ready REST APIs
- Deploy and monitor Neo4j in production environments

✅ **Enterprise Capabilities**
- Implement enterprise security and compliance
- Create audit trails and regulatory reporting
- Build multi-line insurance platforms

## 📁 Key Files & Directories

### Course Materials
- `labs/` - All 17 lab markdown files organized by day
- `presentations/` - 3 HTML presentations using Reveal.js
- `data/` - 8 data reload scripts for database state recovery

### Testing & Validation
- `testscripts/` - Complete automated test suite
- `testscripts/README.md` - Test suite documentation and usage guide
- `testscripts/requirements.txt` - Python dependencies for testing

### Data & Scripts
- `insurance/` - Insurance database creation scripts
- `scripts/` - Utility scripts for Neo4j management (Windows)

### Reference Documentation
- `design_architecture/neo4j_query_structure_guide.md` - MWR pattern reference
- `design_architecture/neo4j_node_types_summary.md` - Entity catalog
- `design_architecture/neo4j_enterprise_architecture.md` - Enterprise architecture patterns
- `design_architecture/neo4j_clustering_replication.md` - Clustering and replication guide

## 📊 Course Statistics

- **Total Labs:** 17 (5.6 per day)
- **Total Presentations:** 3 (1 per day)
- **Total Tests:** 188+ individual test functions
- **Lab Content:** 20,154 lines across 17 labs
- **Test Coverage:** 100% of all lab steps
- **Database Growth:** 10 nodes → 1000+ nodes
- **Relationship Growth:** 15 relationships → 1300+ relationships

## 📞 Support & Resources

### Course Materials Issues
- Check this README for setup instructions
- Review `testscripts/README.md` for test troubleshooting
- Use data reload scripts to recover database state

### Neo4j Resources
- Neo4j Documentation: https://neo4j.com/docs/
- Neo4j Community: https://community.neo4j.com/
- Cypher Manual: https://neo4j.com/docs/cypher-manual/current/

### Python Integration
- Neo4j Python Driver: https://neo4j.com/docs/python-manual/current/
- Check `testscripts/requirements.txt` for package versions

## 🎓 Target Audience

This course is designed for:
- **Software Engineers** building graph-powered applications
- **Data Engineers** integrating graph databases into pipelines
- **Data Scientists** applying graph analytics to ML models
- **Data Analysts** performing network and customer analytics
- **Technical Architects** designing enterprise graph solutions

### Prerequisites
- Basic programming experience (any language)
- Understanding of databases (SQL helpful but not required)
- Docker familiarity preferred
- Python basics helpful for Day 3

## 📄 License

This course material is for educational purposes.

---

**Version:** 1.0
**Last Updated:** 2025-10-18
**Maintained By:** Training Team
**Neo4j Version:** Enterprise 5.26.9
**Python Version:** 3.8+
