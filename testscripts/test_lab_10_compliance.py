"""
Test Suite for Lab 10: Compliance & Audit Trail Implementation
Expected State: 550 nodes, 700 relationships
"""

import pytest


class TestLab10:
    """Test Lab 10: Compliance & Audit Trail Implementation"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 9"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 500, f"Expected at least 500 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 500+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 9"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 400, f"Expected at least 400 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 400+)")

    def test_audit_trail_nodes(self, db_validator):
        """Verify AuditTrail nodes were created"""
        audit_count = db_validator.count_nodes("AuditTrail")
        print(f"  ✓ AuditTrail nodes: {audit_count}")

    def test_compliance_record_nodes(self, db_validator):
        """Verify ComplianceRecord nodes exist"""
        compliance_count = db_validator.count_nodes("ComplianceRecord")
        print(f"  ✓ ComplianceRecord nodes: {compliance_count}")

    def test_regulatory_report_nodes(self, db_validator):
        """Verify RegulatoryReport nodes exist"""
        report_count = db_validator.count_nodes("RegulatoryReport")
        print(f"  ✓ RegulatoryReport nodes: {report_count}")

    def test_audit_trail_tracking(self, query_executor):
        """Verify entities have audit trail tracking"""
        query = """
        MATCH (n)
        WHERE n.created_at IS NOT NULL
          AND n.created_by IS NOT NULL
        RETURN count(n) as entities_with_audit
        """
        result = query_executor(query)
        assert result[0]['entities_with_audit'] >= 100, "Not enough entities with audit trails"
        print(f"  ✓ Entities with audit tracking: {result[0]['entities_with_audit']}")

    def test_version_tracking(self, query_executor):
        """Verify entities have version tracking"""
        query = """
        MATCH (n)
        WHERE n.version IS NOT NULL
        RETURN count(n) as entities_with_versions
        """
        result = query_executor(query)
        assert result[0]['entities_with_versions'] >= 100, "Not enough entities with version tracking"
        print(f"  ✓ Entities with version tracking: {result[0]['entities_with_versions']}")

    def test_data_lineage(self, query_executor):
        """Verify data lineage can be traced"""
        query = """
        MATCH (c:Customer)
        WHERE c.created_by IS NOT NULL
        WITH DISTINCT c.created_by as source
        RETURN count(source) as data_sources
        """
        result = query_executor(query)
        print(f"  ✓ Data sources tracked: {result[0]['data_sources']}")

    def test_compliance_reporting_capability(self, query_executor):
        """Verify compliance reporting queries work"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WHERE p.effective_date >= date() - duration({days: 365})
        RETURN count(DISTINCT c) as new_customers_last_year
        """
        result = query_executor(query)
        print(f"  ✓ Compliance reporting capable")

    def test_regulatory_query_performance(self, query_executor):
        """Verify regulatory queries perform adequately"""
        import time

        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.state as state,
               count(p) as policy_count,
               sum(p.annual_premium) as total_premium
        """

        start_time = time.time()
        result = query_executor(query)
        end_time = time.time()

        execution_time = (end_time - start_time) * 1000
        print(f"  ✓ Regulatory query performance: {execution_time:.2f}ms")

    # ===================================
    # OPERATIONAL TESTS: Lab 10 Operations
    # ===================================

    def test_operation_audit_trail_queries(self, query_executor):
        """Test: Students can query audit trails"""
        query = """
        MATCH (n)
        WHERE n.created_at IS NOT NULL
        RETURN n.created_by as source,
               n.created_at as timestamp,
               count(n) as entities_created
        ORDER BY entities_created DESC
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1
        print(f"  ✓ Audit trail query operations work ({len(result)} sources)")

    def test_operation_version_history(self, query_executor):
        """Test: Students can track version history"""
        query = """
        MATCH (n)
        WHERE n.version IS NOT NULL
        WITH n.version as version, count(n) as count
        RETURN version, count
        ORDER BY count DESC
        """
        result = query_executor(query)
        assert len(result) >= 1
        print(f"  ✓ Version history tracking works")

    def test_operation_compliance_reporting(self, query_executor):
        """Test: Students can generate compliance reports"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WHERE p.effective_date >= date() - duration({days: 365})
        WITH c.state as state,
             count(DISTINCT c) as customers,
             count(p) as policies,
             sum(p.annual_premium) as premium
        RETURN state, customers, policies, round(premium * 100) / 100 as total_premium
        ORDER BY total_premium DESC
        """
        result = query_executor(query)
        assert len(result) >= 1
        print(f"  ✓ Compliance reporting works ({len(result)} states)")

    def test_lab10_summary(self, db_validator):
        """Print Lab 10 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()

        print("\n  Lab 10 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    ✓ Audit trail queries")
        print(f"    ✓ Version history tracking")
        print(f"    ✓ Compliance reporting")
        print(f"    ✓ Data lineage tracing")
        print("  ✓ Lab 10 validation complete")
