#!/bin/bash

# Neo4j Mastering Course - Python Labs Test Runner
# Tests Python code functionality from Labs 12-17

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================================================"
echo "NEO4J MASTERING COURSE - PYTHON LABS TEST VERIFICATION"
echo "================================================================================"
echo ""
echo "Testing Python application code from Labs 12-17..."
echo ""

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv .venv
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Install/update dependencies
echo "Installing/updating test dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo "✓ Dependencies installed"
echo ""

# Check Neo4j connectivity
echo "Checking Neo4j connectivity..."
python3 -c "
from neo4j import GraphDatabase
import sys

try:
    driver = GraphDatabase.driver('neo4j://localhost:7687', auth=('neo4j', 'password'))
    driver.verify_connectivity()
    driver.close()
    print('✓ Neo4j is running and accessible')
except Exception as e:
    print(f'✗ Neo4j is not accessible: {e}')
    print('')
    print('Please start Neo4j with: cd ../../mac && ./start-neo4j.sh')
    sys.exit(1)
"

if [ $? -ne 0 ]; then
    exit 1
fi

echo ""
echo "================================================================================"
echo "Running Python test suite..."
echo "================================================================================"
echo ""

# Run comprehensive test suite
pytest test_python_labs.py -v --tb=short

# Capture exit code
EXIT_CODE=$?

echo ""
echo "================================================================================"
echo "TEST SUMMARY"
echo "================================================================================"

if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ ALL PYTHON TESTS PASSED"
    echo ""
    echo "Test Coverage:"
    echo "  - Lab 12: Python Driver & Service Architecture ✓"
    echo "  - Lab 13: Production Insurance API Development ✓"
    echo "  - Lab 14: Interactive Insurance Web Application ✓"
    echo "  - Lab 15: Production Deployment ✓"
    echo "  - Lab 16: Multi-Line Insurance Platform ✓"
    echo "  - Lab 17: Innovation Showcase & Future Capabilities ✓"
    echo ""
    echo "Integration Tests:"
    echo "  - End-to-end customer workflows ✓"
    echo "  - Bulk operations performance ✓"
    echo ""
    echo "Result: Python application code validated ✓"
else
    echo "✗ SOME TESTS FAILED"
    echo ""
    echo "Review the output above for details."
    echo "Common issues:"
    echo "  - Neo4j not running (start with: cd ../../mac && ./start-neo4j.sh)"
    echo "  - Missing Python dependencies (run: pip install -r requirements.txt)"
    echo "  - Database connectivity issues"
fi

echo "================================================================================"

exit $EXIT_CODE
