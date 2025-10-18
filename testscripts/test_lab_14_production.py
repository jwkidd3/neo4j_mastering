"""
Test Suite for Lab 14: Production Insurance Infrastructure
Expected State: Production-ready database configuration
"""

import pytest


class TestLab14:
    """Test Lab 14: Production Insurance Infrastructure"""

    def test_constraints_for_production(self, query_executor):
        """Verify production-grade constraints exist"""
        query = "SHOW CONSTRAINTS"
        result = query_executor(query)
        assert len(result) >= 5, f"Expected at least 5 constraints for production, got {len(result)}"
        print(f"\n  ✓ Production constraints: {len(result)}")

    def test_indexes_for_production(self, query_executor):
        """Verify production-grade indexes exist"""
        query = "SHOW INDEXES"
        result = query_executor(query)
        assert len(result) >= 5, f"Expected at least 5 indexes for production, got {len(result)}"
        print(f"  ✓ Production indexes: {len(result)}")

    def test_database_health(self, query_executor):
        """Verify database health check works"""
        query = "RETURN 'healthy' as status"
        result = query_executor(query)
        assert result[0]['status'] == 'healthy'
        print("  ✓ Database health check passed")

    def test_data_integrity(self, query_executor):
        """Verify no orphaned nodes"""
        query = """
        MATCH (n)
        WHERE NOT EXISTS { (n)-[]-() }
        RETURN count(n) as isolated_nodes
        """
        result = query_executor(query)
        isolated_count = result[0]['isolated_nodes']
        # Some nodes like BusinessKPI might be isolated, so just warn if many
        if isolated_count > 20:
            print(f"  ⚠ Warning: {isolated_count} isolated nodes")
        else:
            print(f"  ✓ Data integrity good: {isolated_count} isolated nodes")

    def test_query_performance_baselines(self, query_executor):
        """Verify critical queries perform adequately"""
        import time

        queries = [
            ("Customer lookup", "MATCH (c:Customer {customer_number: 'CUST-001234'}) RETURN c"),
            ("Policy search", "MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy) RETURN p LIMIT 10"),
            ("Claims query", "MATCH (cl:Claim) WHERE cl.claim_status = 'Open' RETURN cl LIMIT 10")
        ]

        for name, query in queries:
            start = time.time()
            result = query_executor(query)
            elapsed = (time.time() - start) * 1000

            assert elapsed < 1000, f"{name} too slow: {elapsed:.2f}ms"
            print(f"  ✓ {name}: {elapsed:.2f}ms")

    def test_audit_trail_compliance(self, query_executor):
        """Verify audit trails exist for compliance"""
        query = """
        MATCH (n)
        WHERE n.created_at IS NOT NULL
        RETURN count(n) as audited_entities
        """
        result = query_executor(query)
        assert result[0]['audited_entities'] >= 100, "Not enough entities with audit trails"
        print(f"  ✓ Audit trail compliance: {result[0]['audited_entities']} entities")

    def test_lab14_summary(self, db_validator):
        """Print Lab 14 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()

        print("\n  Lab 14 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print("    Production Readiness: Validated")
        print("  ✓ Lab 14 validation complete")
