# Neo4j Mastering Course - Comprehensive Test Suite

This directory contains a comprehensive automated test suite that validates every step in all 17 labs of the Neo4j Mastering Course.

## 📋 Overview

The test suite provides:
- ✅ Automated validation of all 17 labs
- ✅ Database state verification at each stage
- ✅ Node and relationship count validation
- ✅ Query functionality testing
- ✅ Data integrity checks
- ✅ Performance benchmarking
- ✅ Comprehensive reporting

## 🏗️ Test Suite Structure

```
testscripts/
├── conftest.py                          # Pytest fixtures and shared utilities
├── test_runner.py                       # Master test orchestrator
├── run_tests.sh                         # Unix/Mac/Linux test runner
├── run_tests.bat                        # Windows test runner
├── README.md                            # This file
│
├── # Day 1 Tests (Fundamentals)
├── test_lab_01_setup.py                 # Lab 1: Enterprise Setup
├── test_lab_02_cypher_fundamentals.py   # Lab 2: Cypher Fundamentals
├── test_lab_03_claims_financial.py      # Lab 3: Claims & Financial
├── test_lab_04_bulk_import.py           # Lab 4: Bulk Data Import
├── test_lab_05_advanced_analytics.py    # Lab 5: Advanced Analytics
│
├── # Day 2 Tests (Advanced Analytics)
├── test_lab_06_customer_analytics.py    # Lab 6: Customer Intelligence
├── test_lab_07_graph_algorithms.py      # Lab 7: Graph Algorithms
├── test_lab_08_performance.py           # Lab 8: Performance Optimization
├── test_lab_09_fraud_detection.py       # Lab 9: Fraud Detection
├── test_lab_10_compliance.py            # Lab 10: Compliance & Audit
├── test_lab_11_predictive.py            # Lab 11: Predictive Analytics
│
└── # Day 3 Tests (Python Integration)
    ├── test_lab_12_python_driver.py     # Lab 12: Python Driver
    ├── test_lab_13_api_development.py   # Lab 13: API Development
    ├── test_lab_14_production.py        # Lab 14: Production Infrastructure
    ├── test_lab_15_integration.py       # Lab 15: Platform Integration
    ├── test_lab_16_multiline.py         # Lab 16: Multi-Line Platform
    └── test_lab_17_innovation.py        # Lab 17: Innovation Showcase
```

## 🚀 Quick Start

### Prerequisites

**The test scripts are completely self-contained and automated!**

You only need:

1. **Docker** installed and running
   - Docker Desktop (Mac/Windows) or Docker Engine (Linux)
   - Check with: `docker --version`
   - Ensure Docker daemon is running

2. **Python 3.8 or higher** installed
   - Check with: `python3 --version` (Mac/Linux) or `python --version` (Windows)

**That's it! No other manual setup required.**

### Running All Tests

**The scripts will automatically:**
- ✅ Check Docker and Python installation
- ✅ Pull Neo4j Enterprise 5.26.9 image (if not already present)
- ✅ Create and start Neo4j container
- ✅ Install APOC plugin
- ✅ Wait for Neo4j to be ready
- ✅ Create insurance database
- ✅ **Load Labs 1-8 sequentially** (foundation: ~400 nodes, ~500 relationships)
- ✅ **Load Lab 17 advanced features** (Labs 9-17: additional ~600 nodes, ~800 relationships)
- ✅ Create temporary Python virtual environment
- ✅ Install all required packages (pytest, neo4j, etc.)
- ✅ Run the comprehensive test suite (188+ tests)
- ✅ Clean up and delete everything:
  - Python virtual environment
  - Neo4j container
  - Neo4j image (if pulled during this run)

**Complete isolation - no manual setup, no leftover artifacts!**

**Note:** Data loads progressively (Labs 1→2→3→4→5→6→7→8→17) to build the complete insurance platform. All 17 lab tests validate against the full dataset (1000+ nodes, 1300+ relationships).

#### Unix/Mac/Linux:
```bash
cd testscripts
./run_tests.sh
```

#### Windows:
```cmd
cd testscripts
run_tests.bat
```

**What happens:**
1. Script checks prerequisites (Docker, Python)
2. Sets up complete Neo4j environment
3. Sets up Python test environment
4. Runs all tests
5. Cleans up everything automatically

**Time:** First run ~5-10 minutes (image download), subsequent runs ~2-3 minutes

#### Python Direct (Advanced - Not Recommended):
```bash
# This requires manual Docker and environment setup
# Start Neo4j manually first
docker run -d --name neo4j -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  neo4j:5.26.9-enterprise

# Install dependencies
cd testscripts
pip install -r requirements.txt

# Run tests
python test_runner.py

# Manual cleanup required
docker stop neo4j && docker rm neo4j
```

### Running Specific Tests

#### Test a Single Lab:
```bash
# Test only Lab 5
pytest test_lab_05_advanced_analytics.py -v

# Or using the test runner
python test_runner.py --lab 5
```

#### Test a Single Day:
```bash
# Test all Day 1 labs (Labs 1-5)
python test_runner.py --day 1

# Test all Day 2 labs (Labs 6-11)
python test_runner.py --day 2

# Test all Day 3 labs (Labs 12-17)
python test_runner.py --day 3
```

#### Test a Specific Test Function:
```bash
pytest test_lab_01_setup.py::TestLab01::test_customer_nodes_exist -v
```

## 📊 Expected Database States

### Lab 1: Enterprise Setup
- **Nodes:** 10+
- **Relationships:** 15+
- **Entities:** Customer, Policy, Agent, Product

### Lab 5: Day 1 Complete
- **Nodes:** 200+
- **Relationships:** 300+
- **Added:** RiskAssessment, CustomerProfile, PredictiveModel

### Lab 11: Day 2 Complete
- **Nodes:** 600+
- **Relationships:** 750+
- **Added:** MLModel, BehavioralSegment, MarketingCampaign

### Lab 17: Course Complete
- **Nodes:** 1000+
- **Relationships:** 1300+
- **Complete:** Full insurance platform with all features

## 🔧 Configuration

### Environment Variables

You can customize the connection via environment variables:

```bash
export NEO4J_URI="neo4j://localhost:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="password"
export NEO4J_DATABASE="insurance"
```

Or create a `.env` file in the testscripts directory:

```
NEO4J_URI=neo4j://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password
NEO4J_DATABASE=insurance
```

## 📖 Test Coverage

### Each Lab Test Validates:

1. **Node Counts**
   - Total nodes match expected state
   - Specific entity types exist
   - Progressive growth from previous labs

2. **Relationship Counts**
   - Total relationships match expected state
   - Specific relationship types exist
   - Proper connections between entities

3. **Data Integrity**
   - Required properties exist
   - No orphaned nodes
   - Valid data ranges (e.g., credit scores 300-850)

4. **Query Functionality**
   - Basic queries return expected results
   - Complex traversals work correctly
   - Aggregations produce valid outputs

5. **Constraints & Indexes**
   - Uniqueness constraints exist where required
   - Performance indexes created
   - Constraint enforcement working

6. **Business Logic**
   - Customer 360-degree views complete
   - Analytics pipelines functional
   - Predictive models operational

## 📝 Test Output

### Success Example:
```
============================================================================
Running Lab 01 Tests (1/17): test_lab_01_setup.py
============================================================================

  ✓ Database connection successful
  ✓ Total nodes: 10 (expected: 10+)
  ✓ Total relationships: 15 (expected: 15+)
  ✓ Customer nodes: 3
  ✓ Sarah Johnson (CUST-001234) exists
  ✓ Policy nodes: 3
  ✓ Agent nodes: 2
  ✓ HOLDS_POLICY relationships exist

  Lab 1 Summary:
    Nodes: 10
    Relationships: 15
    Node Types: Customer, Policy, Agent, Product
  ✓ Lab 1 validation complete

============================================================================
Lab 01: PASSED
============================================================================
```

### Failure Example:
```
============================================================================
Running Lab 04 Tests (4/17): test_lab_04_bulk_import.py
============================================================================

  ✓ Total nodes: 145 (expected: 150+)
  ✗ Assertion Error: Expected at least 150 nodes, got 145

✗ Lab 04: FAILED
============================================================================
```

## 🐛 Troubleshooting

### Connection Errors

**Problem:** Cannot connect to Neo4j
```
Solution:
1. Verify Neo4j is running: docker ps | grep neo4j
2. Check credentials: neo4j/password
3. Verify port 7687 is accessible
4. Test connection: docker exec neo4j cypher-shell -u neo4j -p password
```

### Data Mismatch

**Problem:** Node/relationship counts don't match expected values
```
Solution:
1. Check which lab you've completed
2. Load appropriate data reload script:
   docker exec -i neo4j cypher-shell -u neo4j -p password -d insurance < data/lab_XX_data_reload.cypher
3. Verify database state manually in Neo4j Browser
```

### Test Failures

**Problem:** Specific tests failing
```
Solution:
1. Run with verbose output: pytest test_lab_XX.py -vv
2. Check specific assertion: pytest test_lab_XX.py::TestLabXX::test_name -v
3. Verify data exists: Open Neo4j Browser and run validation queries
```

### Import Errors

**Problem:** Cannot import pytest or neo4j
```
Solution:
pip install pytest neo4j python-dotenv
```

## 📈 Performance Benchmarks

The test suite includes performance benchmarks:

- **Simple queries:** < 1000ms
- **Indexed lookups:** < 1000ms
- **Aggregations:** < 5000ms
- **Complex traversals:** < 5000ms

## 🔄 Continuous Integration

To integrate with CI/CD:

```yaml
# Example GitHub Actions
- name: Run Neo4j Tests
  run: |
    docker-compose up -d neo4j
    pip install pytest neo4j
    cd testscripts
    python test_runner.py
```

## 📚 Additional Resources

- **Main Course:** `/neo4j_mastering/`
- **Course Documentation:** `/README.md` (setup, course structure, learning outcomes)
- **Lab Files:** `/labs/neo4j_lab_*.md`
- **Presentation Files:** `/presentations/neo4j_day*.html`
- **Data Reload Scripts:** `/data/lab_*_data_reload.cypher`

## 🆘 Support

For issues with the test suite:
1. Check the troubleshooting section above
2. Review test output for specific error messages
3. Verify database state matches expected lab completion
4. Ensure all prerequisites are met

## ✅ Test Suite Validation Checklist

Before running tests, ensure:
- [ ] Neo4j is running (docker ps | grep neo4j)
- [ ] Insurance database exists
- [ ] Python 3.8+ installed
- [ ] pytest installed (pip install pytest)
- [ ] neo4j driver installed (pip install neo4j)
- [ ] Labs completed up to the point you want to test
- [ ] Connection credentials are correct

## 🎯 Success Criteria

The test suite passes when:
- ✅ All 17 lab tests pass
- ✅ Database contains expected number of nodes/relationships
- ✅ All constraints and indexes exist
- ✅ Query performance meets benchmarks
- ✅ Data integrity checks pass
- ✅ Business logic validations succeed

---

**Last Updated:** 2025-10-18
**Test Suite Version:** 1.0
**Compatible with:** Neo4j Enterprise 2025.06.0
