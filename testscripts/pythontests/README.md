# Neo4j Python Labs Test Suite

## Overview

This test suite validates **Python application code** from Labs 12-17 of the Neo4j Mastering Course. While Labs 1-11 focus on Cypher queries (tested separately), Labs 12-17 teach Python application development with Neo4j.

## Quick Start

### Run All Tests
```bash
cd testscripts/pythontests
./run_python_tests.sh
```

That's it! The script will:
- ✅ Create/activate Python virtual environment
- ✅ Install all required dependencies
- ✅ Check Neo4j connectivity
- ✅ Run comprehensive Python test suite
- ✅ Display detailed results

### Expected Output
```
================================================================================
NEO4J MASTERING COURSE - PYTHON LABS TEST VERIFICATION
================================================================================

Testing Python application code from Labs 12-17...

Activating virtual environment...
Installing/updating test dependencies...
✓ Dependencies installed

Checking Neo4j connectivity...
✓ Neo4j is running and accessible

================================================================================
Running Python test suite...
================================================================================

test_python_labs.py::TestLab12PythonDriver::test_driver_connection PASSED
test_python_labs.py::TestLab12PythonDriver::test_basic_query_execution PASSED
...
test_python_labs.py::TestIntegration::test_end_to_end_customer_workflow PASSED

30+ passed in 5.23s

================================================================================
TEST SUMMARY
================================================================================
✓ ALL PYTHON TESTS PASSED

Test Coverage:
  - Lab 12: Python Driver & Service Architecture ✓
  - Lab 13: Production Insurance API Development ✓
  - Lab 14: Interactive Insurance Web Application ✓
  - Lab 15: Production Deployment ✓
  - Lab 16: Multi-Line Insurance Platform ✓
  - Lab 17: Innovation Showcase & Future Capabilities ✓

Integration Tests:
  - End-to-end customer workflows ✓
  - Bulk operations performance ✓

Result: Python application code validated ✓
================================================================================
```

## What Gets Tested

### Lab 12: Python Driver & Service Architecture
- ✅ Neo4j driver connectivity
- ✅ Basic query execution
- ✅ Node creation via driver
- ✅ Parameterized queries (injection prevention)
- ✅ Transaction rollback handling
- ✅ Service layer patterns

### Lab 13: Production Insurance API Development
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Policy search API functionality
- ✅ API error handling patterns
- ✅ Parameter validation
- ✅ Response formatting

### Lab 14: Interactive Insurance Web Application
- ✅ Dashboard data aggregation
- ✅ Search functionality
- ✅ Data presentation patterns
- ✅ Multi-entity queries

### Lab 15: Production Deployment
- ✅ Connection pooling
- ✅ Health check endpoints
- ✅ Metrics collection
- ✅ Production-ready patterns

### Lab 16: Multi-Line Insurance Platform
- ✅ Multi-product line support
- ✅ Cross-sell opportunity identification
- ✅ Product line aggregation
- ✅ Complex business logic

### Lab 17: Innovation Showcase
- ✅ Advanced graph analytics patterns
- ✅ Temporal queries
- ✅ Pattern matching capabilities
- ✅ Network analysis

### Integration Tests
- ✅ End-to-end customer workflows
- ✅ Bulk operations performance
- ✅ Multi-lab scenarios

## Prerequisites

### Required
- **Neo4j 5.26.9 Enterprise** running on localhost:7687
- **Python 3.8+**
- **Credentials:** neo4j/password

### Setup

1. **Start Neo4j** (if not already running):
   ```bash
   cd ../../mac
   ./start-neo4j.sh
   ```

2. **Run tests** (creates venv automatically):
   ```bash
   cd testscripts/pythontests
   ./run_python_tests.sh
   ```

## Test Suite Components

### Main Files

- **`run_python_tests.sh`** - Main test runner script (use this!)
- **`test_python_labs.py`** - Comprehensive test suite (30+ tests)
- **`conftest.py`** - Pytest fixtures and configuration
- **`pytest.ini`** - Pytest settings
- **`requirements.txt`** - Python dependencies

### Test Organization

```
test_python_labs.py
├── TestLab12PythonDriver (6 tests)
│   ├── test_driver_connection
│   ├── test_basic_query_execution
│   ├── test_create_node_via_driver
│   ├── test_parameterized_query
│   ├── test_transaction_rollback
│   └── test_customer_service_layer
├── TestLab13ProductionAPI (3 tests)
│   ├── test_customer_api_crud
│   ├── test_policy_search_api
│   └── test_api_error_handling
├── TestLab14WebApplication (2 tests)
│   ├── test_dashboard_data_aggregation
│   └── test_search_functionality
├── TestLab15ProductionDeployment (3 tests)
│   ├── test_connection_pooling
│   ├── test_health_check_endpoint
│   └── test_metrics_collection
├── TestLab16MultiLinePlatform (2 tests)
│   ├── test_multi_line_product_support
│   └── test_cross_sell_opportunities
├── TestLab17InnovationShowcase (3 tests)
│   ├── test_graph_analytics_patterns
│   ├── test_temporal_queries
│   └── test_pattern_matching_advanced
└── TestIntegration (2 tests)
    ├── test_end_to_end_customer_workflow
    └── test_performance_bulk_operations
```

## Running Tests Manually

### Run Full Suite
```bash
cd testscripts/pythontests
source .venv/bin/activate
pytest test_python_labs.py
```

### Run Specific Lab
```bash
pytest test_python_labs.py -k "lab12"
pytest test_python_labs.py -k "lab13"
```

### Run by Marker
```bash
pytest test_python_labs.py -m "driver"      # Driver tests only
pytest test_python_labs.py -m "api"         # API tests only
pytest test_python_labs.py -m "integration" # Integration tests only
```

### Run With Verbose Output
```bash
pytest test_python_labs.py -v
```

### Run Specific Test
```bash
pytest test_python_labs.py::TestLab12PythonDriver::test_driver_connection
```

## Test Markers

Available pytest markers:
- `lab12` - Lab 12 tests
- `lab13` - Lab 13 tests
- `lab14` - Lab 14 tests
- `lab15` - Lab 15 tests
- `lab16` - Lab 16 tests
- `lab17` - Lab 17 tests
- `driver` - Neo4j driver tests
- `api` - API functionality tests
- `service` - Service layer tests
- `integration` - Integration tests
- `slow` - Slow-running tests

## Configuration

### Environment Variables

Set these if using non-default values:

```bash
export NEO4J_URI="neo4j://localhost:7687"
export NEO4J_USER="neo4j"
export NEO4J_PASSWORD="password"
export NEO4J_DATABASE="neo4j"
```

### Pytest Configuration

Edit `pytest.ini` for custom settings:

```ini
[pytest]
addopts = --tb=short -q --disable-warnings
timeout = 300
```

## Troubleshooting

### Neo4j Not Running
```
Error: Neo4j is not accessible
Solution: cd ../../mac && ./start-neo4j.sh
```

### Virtual Environment Issues
```
Error: Virtual environment not found
Solution: python3 -m venv .venv && source .venv/bin/activate
```

### Missing Dependencies
```
Error: ModuleNotFoundError
Solution: source .venv/bin/activate && pip install -r requirements.txt
```

### Tests Failing
```
Error: Tests failing with connection errors
Solutions:
  1. Check Neo4j is running: docker ps | grep neo4j
  2. Verify credentials: neo4j/password
  3. Check port 7687 is accessible
```

## Differences from Cypher Tests

| Aspect | Cypher Tests (Labs 1-11) | Python Tests (Labs 12-17) |
|--------|-------------------------|---------------------------|
| Focus | Cypher query syntax | Python application code |
| Test Count | 176 queries | 30+ Python tests |
| Location | `testscripts/` | `testscripts/pythontests/` |
| What's Tested | Query execution | Driver, API, services, integration |
| Dependencies | pytest, neo4j driver | pytest, neo4j, fastapi, etc. |
| Test Type | Query validation | Unit + Integration tests |

## Success Criteria

The Python test suite achieves:
- ✅ **30+ Tests**: Covering all Python labs
- ✅ **Driver Testing**: Connection, queries, transactions
- ✅ **Service Layer**: CRUD operations, business logic
- ✅ **API Patterns**: REST endpoints, error handling
- ✅ **Integration**: End-to-end workflows
- ✅ **Production Ready**: Deployment, monitoring patterns

## Support

For issues:
1. Verify Neo4j is running: `docker ps | grep neo4j`
2. Check Python version: `python3 --version` (need 3.8+)
3. Verify venv activated: `which python` (should show .venv path)
4. Run with verbose output: `pytest test_python_labs.py -v`
5. Check specific failing test individually

## Notes

- **Clean Test Data**: Tests use `TestNode`, `TestCustomer`, `TestPolicy` labels to avoid affecting production data
- **Automatic Cleanup**: Test fixtures clean up data before and after each test
- **Isolated Tests**: Each test is independent and can run in any order
- **Fast Execution**: Full suite typically runs in < 10 seconds
- **Production Patterns**: Tests validate real-world Python + Neo4j patterns

---

**Last Updated:** 2025-10-20
**Test Suite Version:** 1.0
**Compatible with:** Neo4j Enterprise 5.26.9, Python 3.8+
