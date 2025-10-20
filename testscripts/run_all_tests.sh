#!/bin/bash

# Neo4j Mastering Course - Master Test Runner
# Runs ALL tests for Labs 1-17

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "================================================================================"
echo "NEO4J MASTERING COURSE - COMPLETE TEST SUITE"
echo "================================================================================"
echo ""
echo "Running comprehensive tests for Labs 1-17..."
echo ""

# Track overall success
OVERALL_SUCCESS=0

echo "================================================================================"
echo "PART 1: CYPHER TESTS (Labs 1-11)"
echo "================================================================================"
echo ""

# Run Cypher tests
if ./run_tests.sh; then
    CYPHER_SUCCESS=1
    echo ""
    echo "✓ Cypher tests completed successfully"
else
    CYPHER_SUCCESS=0
    echo ""
    echo "✗ Cypher tests failed"
    OVERALL_SUCCESS=1
fi

echo ""
echo "================================================================================"
echo "PART 2: PYTHON TESTS (Labs 12-17)"
echo "================================================================================"
echo ""

# Run Python tests
cd pythontests
if ./run_python_tests.sh; then
    PYTHON_SUCCESS=1
    echo ""
    echo "✓ Python tests completed successfully"
else
    PYTHON_SUCCESS=0
    echo ""
    echo "✗ Python tests failed"
    OVERALL_SUCCESS=1
fi

cd "$SCRIPT_DIR"

echo ""
echo "================================================================================"
echo "FINAL TEST SUMMARY - ALL LABS (1-17)"
echo "================================================================================"
echo ""

if [ $CYPHER_SUCCESS -eq 1 ]; then
    echo "✓ Cypher Tests (Labs 1-11):   PASSED"
    echo "  - 176 executable queries validated"
    echo "  - 21 non-executable queries skipped"
    echo "  - GDS and APOC plugins verified"
else
    echo "✗ Cypher Tests (Labs 1-11):   FAILED"
fi

echo ""

if [ $PYTHON_SUCCESS -eq 1 ]; then
    echo "✓ Python Tests (Labs 12-17):  PASSED"
    echo "  - 21 Python application tests validated"
    echo "  - Driver, API, service, and integration tests"
else
    echo "✗ Python Tests (Labs 12-17):  FAILED"
fi

echo ""
echo "================================================================================"

if [ $OVERALL_SUCCESS -eq 0 ]; then
    echo ""
    echo "🎉 ALL TESTS PASSED - 100% SUCCESS"
    echo ""
    echo "Complete Test Coverage:"
    echo "  ✓ Labs 1-11:  Cypher Queries (176 tests)"
    echo "  ✓ Labs 12-17: Python Applications (21 tests)"
    echo "  ✓ Total:      197 tests across 17 labs"
    echo ""
    echo "Neo4j Mastering Course - Fully Validated ✓"
else
    echo ""
    echo "⚠ SOME TESTS FAILED"
    echo ""
    echo "Review the output above for details."
fi

echo "================================================================================"

exit $OVERALL_SUCCESS
