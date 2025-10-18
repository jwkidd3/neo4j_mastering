@echo off
REM ##############################################################################
REM Neo4j Mastering Course - Test Runner Script (Windows)
REM
REM This script runs the comprehensive test suite for all 17 labs
REM ##############################################################################

echo ==============================================================================
echo Neo4j Mastering Course - Comprehensive Test Suite
echo ==============================================================================
echo.

REM Check if pytest is installed
python -c "import pytest" 2>nul
if errorlevel 1 (
    echo ERROR: pytest is not installed
    echo Please install pytest: pip install pytest
    exit /b 1
)

REM Check if Neo4j Python driver is installed
python -c "import neo4j" 2>nul
if errorlevel 1 (
    echo ERROR: Neo4j Python driver is not installed
    echo Please install neo4j driver: pip install neo4j
    exit /b 1
)

echo [92m√ Prerequisites check passed[0m
echo.

REM Check Neo4j connection
echo Checking Neo4j connection...
python -c "from neo4j import GraphDatabase; driver = GraphDatabase.driver('neo4j://localhost:7687', auth=('neo4j', 'password')); driver.verify_connectivity(); driver.close()" 2>nul
if errorlevel 1 (
    echo [91m× Cannot connect to Neo4j[0m
    echo Please ensure Neo4j is running on localhost:7687
    echo Default credentials: neo4j/password
    exit /b 1
)

echo [92m√ Neo4j connection successful[0m
echo.

echo ==============================================================================
echo Running test suite...
echo ==============================================================================
echo.

REM Change to script directory
cd /d "%~dp0"

REM Run the test runner
python test_runner.py %*
if errorlevel 1 (
    echo.
    echo [91m×××TEST SUITE FAILED ×××[0m
    exit /b 1
)

echo.
echo [92m√√√ TEST SUITE COMPLETED SUCCESSFULLY √√√[0m
exit /b 0
