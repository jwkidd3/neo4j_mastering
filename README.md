# Neo4j Mastering Course

A comprehensive 3-day (18 hours) Neo4j training course with hands-on labs, presentations, and automated testing.

## 📚 Course Overview

- **Duration:** 18 hours (6 hours per day)
- **Format:** 70% Labs (12.6 hours) / 30% Presentations (5.4 hours)
- **Labs:** 17 hands-on labs
- **Platform:** Neo4j Enterprise 2025.06.0 (Docker)
- **Domain:** Insurance Company (1000+ entities)

## 🗂️ Directory Structure

```
neo4j_mastering/
├── labs/                    # 17 lab files (Day 1-3)
├── presentations/           # 3 HTML presentations (Reveal.js)
├── testscripts/            # Comprehensive test suite (188+ tests)
├── data/                   # Data reload scripts (8 files)
├── insurance/              # Insurance database scripts
├── scripts/                # Utility scripts
└── *.md                    # Documentation files
```

See [STRUCTURE.md](STRUCTURE.md) for complete directory layout.

## 🚀 Quick Start

### For Students

1. **Setup Environment:**
   ```bash
   # Start Neo4j
   docker start neo4j
   
   # Setup Python (if doing Day 3)
   python3 -m venv venv
   source venv/bin/activate  # Unix/Mac
   # or: venv\Scripts\activate  # Windows
   pip install -r testscripts/requirements.txt
   ```

2. **Follow Course:**
   - **Day 1:** Labs 1-5 + Presentation 1
   - **Day 2:** Labs 6-11 + Presentation 2
   - **Day 3:** Labs 12-17 + Presentation 3

3. **Access Materials:**
   - Labs: `labs/neo4j_lab_*.md`
   - Presentations: `presentations/neo4j_day*.html`

### For Instructors

1. **Prepare Course:**
   ```bash
   # Verify all materials
   ls labs/*.md | wc -l          # Should show 17
   ls presentations/*.html | wc -l  # Should show 3
   
   # Run validation tests
   cd testscripts
   ./run_tests.sh
   ```

2. **Teaching Flow:**
   - Open presentation from `presentations/` folder
   - Guide students through labs in `labs/` folder
   - Use data reload scripts if students need to catch up

3. **Validate Student Progress:**
   ```bash
   cd testscripts
   pytest test_lab_01_setup.py -v        # Check Lab 1
   pytest test_lab_05_*.py -v            # Check Day 1 complete
   ```

## 📖 Course Content

### Day 1: Fundamentals (Labs 1-5)
- Enterprise Setup & Docker Connection
- Cypher Query Fundamentals (MWR Pattern)
- Claims & Financial Transaction Modeling
- Bulk Data Import & Quality Control
- Advanced Analytics Foundation

**Database Evolution:** 10 nodes → 200+ nodes

### Day 2: Advanced Analytics (Labs 6-11)
- Customer Intelligence & Segmentation
- Graph Algorithms for Insurance
- Performance Optimization
- Fraud Detection & Investigation
- Compliance & Audit Trail Implementation
- Predictive Analytics & Machine Learning

**Database Evolution:** 200+ nodes → 600+ nodes

### Day 3: Production (Labs 12-17)
- Python Driver & Service Architecture
- Insurance Web Application Development
- Production Infrastructure
- Complete Platform Integration
- Multi-Line Insurance Platform
- Innovation Showcase (AI/ML, IoT, Blockchain)

**Database Evolution:** 600+ nodes → 1000+ nodes

## 🧪 Testing

Run comprehensive test suite to validate all labs:

```bash
cd testscripts
./run_tests.sh              # Unix/Mac
# or
run_tests.bat               # Windows
```

Test specific labs:
```bash
pytest test_lab_05_*.py -v  # Test Lab 5
pytest test_lab_1*.py -v    # Test Day 1
```

See [testscripts/README.md](testscripts/README.md) for details.

## 📊 Course Statistics

- **Total Labs:** 17
- **Total Presentations:** 3
- **Total Tests:** 188+ individual test functions
- **Lab Content:** 20,154 lines across 17 labs
- **Presentation Content:** 298 KB across 3 presentations
- **Test Coverage:** 100% of all lab steps
- **Database Growth:** 10 nodes → 1000+ nodes

## 📁 Key Files

### Getting Started
- `STRUCTURE.md` - Complete directory structure
- `course_flow.md` - Detailed 18-hour course flow
- `setup.md` - Environment setup instructions
- `python_env.md` - Python environment setup

### Labs & Presentations
- `labs/` - All 17 lab markdown files
- `presentations/` - All 3 HTML presentation files

### Testing & Validation
- `testscripts/` - Complete automated test suite
- `testscripts/README.md` - Test suite documentation

### Reference
- `neo4j_query_structure_guide.md` - MWR pattern reference
- `neo4j_node_types_summary.md` - Entity catalog
- `neo4j_3day_course_outline.md` - Learning outcomes

## 🔄 Data Recovery

If students need to reset their database to a specific lab state:

```bash
# Load Lab 3 state
docker exec -i neo4j cypher-shell -u neo4j -p password \
  -d insurance < data/lab_03_data_reload.cypher

# Load Lab 5 state (Day 1 complete)
docker exec -i neo4j cypher-shell -u neo4j -p password \
  -d insurance < data/lab_05_data_reload.cypher
```

## 🎯 Learning Outcomes

By the end of this course, students will be able to:

✅ Set up and configure Neo4j Enterprise in Docker  
✅ Write complex Cypher queries using the MWR pattern  
✅ Model insurance business domains in graph databases  
✅ Implement bulk data import with quality controls  
✅ Build customer 360-degree views and analytics  
✅ Apply graph algorithms for fraud detection  
✅ Optimize query performance with indexes and constraints  
✅ Integrate Neo4j with Python applications  
✅ Build production-ready REST APIs  
✅ Deploy and monitor Neo4j in production  
✅ Implement enterprise security and compliance  

## 🛠️ Technical Requirements

### Software
- Docker Desktop
- Neo4j Enterprise 2025.06.0 (Docker image: neo4j:enterprise)
- Python 3.8+
- Neo4j Desktop (optional but recommended)
- Modern web browser

### Hardware
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space
- Internet connection for Docker images

## 📞 Support

### Course Materials Issues
- Check [STRUCTURE.md](STRUCTURE.md) for file locations
- Review [testscripts/README.md](testscripts/README.md) for test troubleshooting

### Neo4j Issues
- Neo4j Documentation: https://neo4j.com/docs/
- Neo4j Community: https://community.neo4j.com/

### Python Integration Issues
- Review `python_env.md` for setup instructions
- Check Python requirements: `testscripts/requirements.txt`

## 📄 License

This course material is for educational purposes.

## 🎓 About

Neo4j Mastering Course - A comprehensive training program for software engineers, data engineers, and architects who want to master Neo4j from fundamentals through production deployment using real-world insurance industry scenarios.

---

**Version:** 1.0  
**Last Updated:** 2025-10-18  
**Maintained By:** Training Team
