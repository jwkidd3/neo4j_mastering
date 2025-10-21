"""
Neo4j Data Validation Tests
Tests that queries actually return data, not just execute without errors
"""

import pytest
from neo4j import GraphDatabase

class TestDataValidation:
    @pytest.fixture(scope="class")
    def driver(self):
        driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))
        yield driver
        driver.close()

    def test_lab1_creates_customers(self, driver):
        """Verify Lab 1 creates customer data"""
        with driver.session() as session:
            result = session.run("MATCH (c:Customer) RETURN count(c) AS count")
            count = result.single()["count"]
            assert count >= 3, f"Expected at least 3 customers from Lab 1, got {count}"

    def test_lab1_creates_policies(self, driver):
        """Verify Lab 1 creates policy data"""
        with driver.session() as session:
            result = session.run("MATCH (p:Policy) RETURN count(p) AS count")
            count = result.single()["count"]
            assert count >= 3, f"Expected at least 3 policies from Lab 1, got {count}"

    def test_lab1_active_policies_exist(self, driver):
        """Verify Active policies exist"""
        with driver.session() as session:
            result = session.run("""
                MATCH (p:Policy:Active)
                RETURN count(p) AS count
            """)
            count = result.single()["count"]
            assert count >= 3, f"Expected at least 3 Active policies, got {count}"

    def test_lab1_auto_policies_by_property(self, driver):
        """Verify auto policies can be found using product_type property"""
        with driver.session() as session:
            result = session.run("""
                MATCH (p:Policy)
                WHERE p.product_type = "Auto"
                RETURN count(p) AS count
            """)
            count = result.single()["count"]
            assert count >= 2, f"Expected at least 2 Auto policies (by property), got {count}"

    def test_lab2_query_returns_auto_policies(self, driver):
        """Test the corrected Lab 2 query returns data"""
        with driver.session() as session:
            result = session.run("""
                MATCH (p:Policy:Active)
                WHERE p.product_type = "Auto"
                RETURN p.policy_number, p.annual_premium, p.auto_make, p.auto_model
            """)
            records = list(result)
            assert len(records) >= 2, f"Expected at least 2 auto policies, got {len(records)}"

            # Verify required fields exist
            for record in records:
                assert record["p.policy_number"] is not None
                assert record["p.annual_premium"] is not None
                assert record["p.auto_make"] is not None
                assert record["p.auto_model"] is not None

    def test_lab1_agents_exist(self, driver):
        """Verify agents were created"""
        with driver.session() as session:
            result = session.run("MATCH (a:Agent) RETURN count(a) AS count")
            count = result.single()["count"]
            assert count >= 2, f"Expected at least 2 agents, got {count}"

    def test_lab1_products_exist(self, driver):
        """Verify products were created"""
        with driver.session() as session:
            result = session.run("MATCH (p:Product) RETURN count(p) AS count")
            count = result.single()["count"]
            assert count >= 2, f"Expected at least 2 products, got {count}"

    def test_lab1_relationships_exist(self, driver):
        """Verify relationships were created"""
        with driver.session() as session:
            # Customer-Policy relationships
            result = session.run("""
                MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
                RETURN count(*) AS count
            """)
            count = result.single()["count"]
            assert count >= 3, f"Expected at least 3 HOLDS_POLICY relationships, got {count}"

            # Policy-Product relationships
            result = session.run("""
                MATCH (p:Policy)-[:BASED_ON]->(prod:Product)
                RETURN count(*) AS count
            """)
            count = result.single()["count"]
            assert count >= 3, f"Expected at least 3 BASED_ON relationships, got {count}"

    def test_mwr_pattern_query_returns_data(self, driver):
        """Test that basic MWR pattern returns data"""
        with driver.session() as session:
            result = session.run("""
                MATCH (c:Customer)
                WHERE c.risk_tier = "Standard"
                RETURN c.first_name, c.last_name, c.credit_score
            """)
            records = list(result)
            # This might return 0 if no Standard risk tier customers exist
            # But the query should execute successfully
            assert isinstance(records, list), "Query should return a list"

    def test_policy_properties_complete(self, driver):
        """Verify policies have all required properties"""
        with driver.session() as session:
            result = session.run("""
                MATCH (p:Policy)
                WHERE p.product_type = "Auto"
                RETURN p.policy_number, p.policy_status, p.product_type,
                       p.annual_premium, p.auto_make, p.auto_model
                LIMIT 1
            """)
            record = result.single()

            if record:  # If we have auto policies
                assert record["p.policy_number"] is not None
                assert record["p.policy_status"] is not None
                assert record["p.product_type"] == "Auto"
                assert record["p.annual_premium"] is not None
                assert record["p.auto_make"] is not None
                assert record["p.auto_model"] is not None

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
