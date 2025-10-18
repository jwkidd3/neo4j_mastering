"""
Test Suite for Lab 8: Performance Optimization
Expected State: 400 nodes, 500 relationships
"""

import pytest


class TestLab08:
    """Test Lab 8: Performance Optimization"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 7"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 400, f"Expected at least 400 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 400+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 7"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 500, f"Expected at least 500 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 500+)")

    def test_indexes_exist(self, query_executor):
        """Verify performance indexes exist"""
        query = "SHOW INDEXES"
        result = query_executor(query)
        assert len(result) >= 5, f"Expected at least 5 indexes, got {len(result)}"
        print(f"  ✓ Indexes exist: {len(result)}")

    def test_constraints_exist(self, query_executor):
        """Verify constraints exist"""
        query = "SHOW CONSTRAINTS"
        result = query_executor(query)
        assert len(result) >= 5, f"Expected at least 5 constraints, got {len(result)}"
        print(f"  ✓ Constraints exist: {len(result)}")

    def test_customer_index_exists(self, query_executor):
        """Verify customer-related indexes exist"""
        query = "SHOW INDEXES YIELD name WHERE name CONTAINS 'customer' RETURN count(*) as count"
        result = query_executor(query)
        assert result[0]['count'] >= 1, "No customer indexes found"
        print(f"  ✓ Customer indexes exist")

    def test_policy_index_exists(self, query_executor):
        """Verify policy-related indexes exist"""
        query = "SHOW INDEXES YIELD name WHERE name CONTAINS 'policy' RETURN count(*) as count"
        result = query_executor(query)
        assert result[0]['count'] >= 1, "No policy indexes found"
        print(f"  ✓ Policy indexes exist")

    def test_query_performance_baseline(self, query_executor):
        """Test basic query performance"""
        import time

        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.customer_number, p.policy_number
        LIMIT 100
        """

        start_time = time.time()
        result = query_executor(query)
        end_time = time.time()

        execution_time = (end_time - start_time) * 1000  # Convert to milliseconds

        assert execution_time < 5000, f"Query too slow: {execution_time:.2f}ms"
        print(f"  ✓ Query performance acceptable: {execution_time:.2f}ms")

    def test_indexed_query_performance(self, query_executor):
        """Test indexed property query performance"""
        import time

        query = """
        MATCH (c:Customer {customer_number: 'CUST-001234'})
        RETURN c
        """

        start_time = time.time()
        result = query_executor(query)
        end_time = time.time()

        execution_time = (end_time - start_time) * 1000  # Convert to milliseconds

        assert len(result) > 0, "Indexed query returned no results"
        assert execution_time < 1000, f"Indexed query too slow: {execution_time:.2f}ms"
        print(f"  ✓ Indexed query performance: {execution_time:.2f}ms")

    def test_aggregation_performance(self, query_executor):
        """Test aggregation query performance"""
        import time

        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.risk_tier as risk_tier,
               count(p) as policy_count,
               sum(p.annual_premium) as total_premium
        """

        start_time = time.time()
        result = query_executor(query)
        end_time = time.time()

        execution_time = (end_time - start_time) * 1000

        assert len(result) > 0, "Aggregation query returned no results"
        print(f"  ✓ Aggregation performance: {execution_time:.2f}ms")

    def test_database_statistics(self, query_executor):
        """Verify database statistics are available"""
        query = "CALL apoc.meta.stats() YIELD nodeCount, relCount RETURN nodeCount, relCount"
        try:
            result = query_executor(query)
            assert len(result) > 0, "Database statistics not available"
            print(f"  ✓ Database statistics available")
        except Exception:
            # APOC might not be available in all environments
            print("  ⚠ APOC not available for statistics")

    def test_lab8_summary(self, db_validator):
        """Print Lab 8 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()

        print("\n  Lab 8 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print("  ✓ Lab 8 validation complete")
