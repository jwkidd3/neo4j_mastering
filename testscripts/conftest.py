"""
Neo4j Mastering Course - Test Suite Configuration
Pytest fixtures and shared utilities for testing all 17 labs
"""

import pytest
from neo4j import GraphDatabase
from typing import Generator, Dict, Any
import os
from datetime import datetime


# ==========================================
# Neo4j Connection Configuration
# ==========================================

NEO4J_CONFIG = {
    "uri": os.getenv("NEO4J_URI", "neo4j://localhost:7687"),
    "user": os.getenv("NEO4J_USER", "neo4j"),
    "password": os.getenv("NEO4J_PASSWORD", "password"),
    "database": os.getenv("NEO4J_DATABASE", "insurance")
}


# ==========================================
# Pytest Fixtures
# ==========================================

@pytest.fixture(scope="session")
def neo4j_driver():
    """
    Create a Neo4j driver for the entire test session.
    Yields the driver and closes it after all tests complete.
    """
    driver = GraphDatabase.driver(
        NEO4J_CONFIG["uri"],
        auth=(NEO4J_CONFIG["user"], NEO4J_CONFIG["password"])
    )

    # Verify connection
    try:
        driver.verify_connectivity()
        print(f"\n✓ Connected to Neo4j at {NEO4J_CONFIG['uri']}")
    except Exception as e:
        pytest.fail(f"Failed to connect to Neo4j: {e}")

    yield driver

    driver.close()
    print("\n✓ Neo4j connection closed")


@pytest.fixture(scope="function")
def neo4j_session(neo4j_driver):
    """
    Create a Neo4j session for each test function.
    Automatically uses the insurance database.
    """
    with neo4j_driver.session(database=NEO4J_CONFIG["database"]) as session:
        yield session


@pytest.fixture(scope="function")
def query_executor(neo4j_session):
    """
    Provides a simple query execution function for tests.
    Returns query results as a list of dictionaries.
    """
    def execute_query(cypher: str, parameters: Dict[str, Any] = None) -> list:
        """Execute a Cypher query and return results"""
        result = neo4j_session.run(cypher, parameters or {})
        return [dict(record) for record in result]

    return execute_query


# ==========================================
# Database State Validation Helpers
# ==========================================

@pytest.fixture(scope="function")
def db_validator(query_executor):
    """
    Provides validation helper functions for database state.
    """
    class DBValidator:
        def __init__(self, executor):
            self.execute = executor

        def count_nodes(self, label: str = None) -> int:
            """Count nodes, optionally filtered by label"""
            if label:
                query = f"MATCH (n:{label}) RETURN count(n) as count"
            else:
                query = "MATCH (n) RETURN count(n) as count"
            result = self.execute(query)
            return result[0]['count'] if result else 0

        def count_relationships(self, rel_type: str = None) -> int:
            """Count relationships, optionally filtered by type"""
            if rel_type:
                query = f"MATCH ()-[r:{rel_type}]->() RETURN count(r) as count"
            else:
                query = "MATCH ()-[r]->() RETURN count(r) as count"
            result = self.execute(query)
            return result[0]['count'] if result else 0

        def node_exists(self, label: str, properties: Dict[str, Any]) -> bool:
            """Check if a node with specific properties exists"""
            where_clauses = [f"n.{key} = ${key}" for key in properties.keys()]
            query = f"MATCH (n:{label}) WHERE {' AND '.join(where_clauses)} RETURN count(n) as count"
            result = self.execute(query, properties)
            return result[0]['count'] > 0 if result else False

        def get_node(self, label: str, properties: Dict[str, Any]) -> Dict[str, Any]:
            """Get a specific node by properties"""
            where_clauses = [f"n.{key} = ${key}" for key in properties.keys()]
            query = f"MATCH (n:{label}) WHERE {' AND '.join(where_clauses)} RETURN n"
            result = self.execute(query, properties)
            return dict(result[0]['n']) if result else None

        def relationship_exists(self, start_label: str, rel_type: str, end_label: str) -> bool:
            """Check if a relationship type exists between node types"""
            query = f"MATCH (:{start_label})-[r:{rel_type}]->(:{end_label}) RETURN count(r) as count"
            result = self.execute(query)
            return result[0]['count'] > 0 if result else False

        def constraint_exists(self, constraint_name: str) -> bool:
            """Check if a constraint exists"""
            query = "SHOW CONSTRAINTS YIELD name WHERE name = $name RETURN count(*) as count"
            result = self.execute(query, {"name": constraint_name})
            return result[0]['count'] > 0 if result else False

        def index_exists(self, index_name: str) -> bool:
            """Check if an index exists"""
            query = "SHOW INDEXES YIELD name WHERE name = $name RETURN count(*) as count"
            result = self.execute(query, {"name": index_name})
            return result[0]['count'] > 0 if result else False

        def get_all_labels(self) -> list:
            """Get all node labels in the database"""
            query = "CALL db.labels()"
            result = self.execute(query)
            return [record['label'] for record in result]

        def get_all_relationship_types(self) -> list:
            """Get all relationship types in the database"""
            query = "CALL db.relationshipTypes()"
            result = self.execute(query)
            return [record['relationshipType'] for record in result]

    return DBValidator(query_executor)


# ==========================================
# Test Report Helpers
# ==========================================

@pytest.fixture(scope="session")
def test_report():
    """
    Maintains a test report across the entire session.
    """
    report = {
        "start_time": datetime.now(),
        "tests_run": 0,
        "tests_passed": 0,
        "tests_failed": 0,
        "lab_results": {}
    }

    yield report

    # Print summary at end of session
    report["end_time"] = datetime.now()
    duration = (report["end_time"] - report["start_time"]).total_seconds()

    print("\n" + "="*70)
    print("NEO4J MASTERING COURSE - TEST SUITE SUMMARY")
    print("="*70)
    print(f"Duration: {duration:.2f} seconds")
    print(f"Tests Run: {report['tests_run']}")
    print(f"Tests Passed: {report['tests_passed']}")
    print(f"Tests Failed: {report['tests_failed']}")
    print(f"Success Rate: {(report['tests_passed']/report['tests_run']*100) if report['tests_run'] > 0 else 0:.1f}%")
    print("="*70)


# ==========================================
# Pytest Hooks for Custom Reporting
# ==========================================

def pytest_runtest_logreport(report):
    """Hook to track test results"""
    if report.when == "call":
        # This will be called for each test
        pass


# ==========================================
# Utility Functions
# ==========================================

def compare_counts(actual: int, expected: int, entity_type: str) -> bool:
    """
    Compare actual vs expected counts with helpful error message.
    """
    if actual == expected:
        print(f"  ✓ {entity_type}: {actual} (expected: {expected})")
        return True
    else:
        print(f"  ✗ {entity_type}: {actual} (expected: {expected}) - MISMATCH!")
        return False
