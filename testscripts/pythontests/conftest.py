"""
Pytest configuration and fixtures for Python labs testing
"""

import pytest
from neo4j import GraphDatabase
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Neo4j connection settings
NEO4J_URI = os.getenv("NEO4J_URI", "neo4j://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "password")
NEO4J_DATABASE = os.getenv("NEO4J_DATABASE", "neo4j")


@pytest.fixture(scope="session")
def neo4j_driver():
    """Provide a Neo4j driver instance for the entire test session."""
    logger.info(f"Connecting to Neo4j at {NEO4J_URI}")
    driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

    # Verify connectivity
    try:
        driver.verify_connectivity()
        logger.info("✓ Neo4j connection verified")
    except Exception as e:
        pytest.fail(f"Failed to connect to Neo4j: {e}")

    yield driver

    # Cleanup
    driver.close()
    logger.info("Neo4j driver closed")


@pytest.fixture(scope="function")
def neo4j_session(neo4j_driver):
    """Provide a Neo4j session for each test function."""
    with neo4j_driver.session(database=NEO4J_DATABASE) as session:
        yield session


@pytest.fixture(scope="function")
def clean_test_data(neo4j_session):
    """Clean test data before and after each test."""
    # Clean before test
    neo4j_session.run("MATCH (n:TestNode) DETACH DELETE n")
    neo4j_session.run("MATCH (n:TestCustomer) DETACH DELETE n")
    neo4j_session.run("MATCH (n:TestPolicy) DETACH DELETE n")

    yield

    # Clean after test
    neo4j_session.run("MATCH (n:TestNode) DETACH DELETE n")
    neo4j_session.run("MATCH (n:TestCustomer) DETACH DELETE n")
    neo4j_session.run("MATCH (n:TestPolicy) DETACH DELETE n")


@pytest.fixture(scope="session")
def verify_neo4j_plugins(neo4j_driver):
    """Verify that required Neo4j plugins are available."""
    with neo4j_driver.session(database=NEO4J_DATABASE) as session:
        # Check APOC
        try:
            result = session.run("RETURN apoc.version() AS version")
            apoc_version = result.single()["version"]
            logger.info(f"✓ APOC plugin available: {apoc_version}")
        except Exception as e:
            logger.warning(f"⚠ APOC plugin not available: {e}")

        # Check GDS
        try:
            result = session.run("RETURN gds.version() AS version")
            gds_version = result.single()["version"]
            logger.info(f"✓ GDS plugin available: {gds_version}")
        except Exception as e:
            logger.warning(f"⚠ GDS plugin not available: {e}")


@pytest.fixture(scope="session", autouse=True)
def setup_test_environment(verify_neo4j_plugins):
    """Set up test environment before running tests."""
    logger.info("=" * 80)
    logger.info("PYTHON LABS TEST SUITE - Labs 12-17")
    logger.info("=" * 80)
    yield
    logger.info("=" * 80)
    logger.info("Test suite completed")
    logger.info("=" * 80)


def pytest_collection_modifyitems(config, items):
    """Add custom test markers based on test file names."""
    for item in items:
        # Add lab markers based on test name
        if "lab12" in item.nodeid.lower():
            item.add_marker(pytest.mark.lab12)
        elif "lab13" in item.nodeid.lower():
            item.add_marker(pytest.mark.lab13)
        elif "lab14" in item.nodeid.lower():
            item.add_marker(pytest.mark.lab14)
        elif "lab15" in item.nodeid.lower():
            item.add_marker(pytest.mark.lab15)
        elif "lab16" in item.nodeid.lower():
            item.add_marker(pytest.mark.lab16)
        elif "lab17" in item.nodeid.lower():
            item.add_marker(pytest.mark.lab17)


def pytest_configure(config):
    """Configure pytest with custom settings."""
    config.addinivalue_line(
        "markers", "smoke: Quick smoke tests"
    )
    config.addinivalue_line(
        "markers", "unit: Unit tests"
    )
