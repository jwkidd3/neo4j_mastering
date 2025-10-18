#!/bin/bash
##############################################################################
# Neo4j Mastering Course - Test Runner Script (Unix/Mac/Linux)
#
# This script runs the comprehensive test suite for all 17 labs
##############################################################################

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================================================================="
echo "Neo4j Mastering Course - Comprehensive Test Suite"
echo "=============================================================================="
echo ""

# Check if pytest is installed
if ! command -v pytest &> /dev/null; then
    echo -e "${RED}ERROR: pytest is not installed${NC}"
    echo "Please install pytest: pip install pytest"
    exit 1
fi

# Check if Neo4j Python driver is installed
if ! python3 -c "import neo4j" 2>/dev/null; then
    echo -e "${RED}ERROR: Neo4j Python driver is not installed${NC}"
    echo "Please install neo4j driver: pip install neo4j"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites check passed${NC}"
echo ""

# Check Neo4j connection
echo "Checking Neo4j connection..."
if python3 -c "from neo4j import GraphDatabase; driver = GraphDatabase.driver('neo4j://localhost:7687', auth=('neo4j', 'password')); driver.verify_connectivity(); driver.close()" 2>/dev/null; then
    echo -e "${GREEN}✓ Neo4j connection successful${NC}"
else
    echo -e "${RED}✗ Cannot connect to Neo4j${NC}"
    echo "Please ensure Neo4j is running on localhost:7687"
    echo "Default credentials: neo4j/password"
    exit 1
fi

echo ""
echo "=============================================================================="
echo "Running test suite..."
echo "=============================================================================="
echo ""

# Change to script directory
cd "$SCRIPT_DIR"

# Run the test runner
if python3 test_runner.py "$@"; then
    echo ""
    echo -e "${GREEN}✓✓✓ TEST SUITE COMPLETED SUCCESSFULLY ✓✓✓${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}✗✗✗ TEST SUITE FAILED ✗✗✗${NC}"
    exit 1
fi
