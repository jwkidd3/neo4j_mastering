"""
Test Suite for Lab 12: Python Driver & Service Architecture
Expected State: Database + Python driver validation
"""

import pytest


class TestLab12:
    """Test Lab 12: Python Driver & Service Architecture"""

    def test_python_driver_connection(self, neo4j_driver):
        """Verify Python driver can connect"""
        assert neo4j_driver is not None
        try:
            neo4j_driver.verify_connectivity()
            print("\n  ✓ Python driver connection successful")
        except Exception as e:
            pytest.fail(f"Python driver connection failed: {e}")

    def test_session_creation(self, neo4j_session):
        """Verify session creation works"""
        assert neo4j_session is not None
        print("  ✓ Session creation successful")

    def test_simple_query_execution(self, query_executor):
        """Verify simple query execution via Python"""
        result = query_executor("RETURN 1 as test")
        assert len(result) == 1
        assert result[0]['test'] == 1
        print("  ✓ Simple query execution works")

    def test_parameterized_query(self, query_executor):
        """Verify parameterized queries work"""
        query = "RETURN $param as result"
        result = query_executor(query, {"param": "test_value"})
        assert len(result) == 1
        assert result[0]['result'] == "test_value"
        print("  ✓ Parameterized queries work")

    def test_customer_retrieval_via_python(self, query_executor):
        """Verify customer data retrieval via Python driver"""
        query = """
        MATCH (c:Customer)
        RETURN c.customer_number as customer_number,
               c.first_name as first_name,
               c.last_name as last_name
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) > 0, "No customers found via Python driver"
        assert 'customer_number' in result[0]
        assert 'first_name' in result[0]
        print(f"  ✓ Retrieved {len(result)} customers via Python driver")

    def test_policy_retrieval_via_python(self, query_executor):
        """Verify policy data retrieval via Python driver"""
        query = """
        MATCH (p:Policy)
        RETURN p.policy_number as policy_number,
               p.product_type as product_type,
               p.annual_premium as premium
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) > 0, "No policies found via Python driver"
        assert 'policy_number' in result[0]
        print(f"  ✓ Retrieved {len(result)} policies via Python driver")

    def test_relationship_traversal_via_python(self, query_executor):
        """Verify relationship traversal via Python driver"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.customer_number as customer,
               p.policy_number as policy
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) > 0, "No customer-policy relationships found"
        print(f"  ✓ Relationship traversal works via Python driver")

    def test_aggregation_via_python(self, query_executor):
        """Verify aggregation queries via Python driver"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.customer_number as customer,
               count(p) as policy_count,
               sum(p.annual_premium) as total_premium
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) > 0, "Aggregation query failed"
        assert 'policy_count' in result[0]
        assert 'total_premium' in result[0]
        print("  ✓ Aggregation queries work via Python driver")

    def test_transaction_execution(self, neo4j_session):
        """Verify transaction execution works"""
        def create_test_node(tx):
            result = tx.run("CREATE (n:TestNode {id: $id}) RETURN n", id="test_lab12")
            return result.single()

        def delete_test_node(tx):
            tx.run("MATCH (n:TestNode {id: 'test_lab12'}) DELETE n")

        # Create and delete in transaction
        neo4j_session.execute_write(create_test_node)
        neo4j_session.execute_write(delete_test_node)
        print("  ✓ Transaction execution works")

    def test_error_handling(self, neo4j_session):
        """Verify error handling works"""
        try:
            neo4j_session.run("INVALID CYPHER QUERY")
            pytest.fail("Should have raised an error")
        except Exception as e:
            print("  ✓ Error handling works")

    def test_lab12_summary(self, db_validator):
        """Print Lab 12 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()

        print("\n  Lab 12 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print("    Python Driver: Operational")
        print("  ✓ Lab 12 validation complete")
