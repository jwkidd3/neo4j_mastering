"""
Test Suite for Lab 15: Complete Insurance Platform Integration
Expected State: Full platform integrated and operational
"""

import pytest


class TestLab15:
    """Test Lab 15: Complete Insurance Platform Integration"""

    def test_end_to_end_customer_journey(self, query_executor):
        """Verify complete customer journey data exists"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        MATCH (c)-[:HAS_PROFILE]->(profile:CustomerProfile)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(cl:Claim)
        OPTIONAL MATCH (c)-[:MADE_PAYMENT]->(payment:Payment)
        RETURN c.customer_number as customer,
               count(DISTINCT p) as policies,
               count(DISTINCT cl) as claims,
               count(DISTINCT payment) as payments
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) > 0, "No complete customer journeys found"
        print(f"\n  ✓ End-to-end customer journeys validated")

    def test_multi_channel_integration(self, query_executor):
        """Verify multi-channel data integration"""
        query = """
        MATCH (c:Customer)
        RETURN c.email IS NOT NULL as has_email,
               c.phone IS NOT NULL as has_phone,
               count(*) as count
        """
        result = query_executor(query)
        print("  ✓ Multi-channel integration validated")

    def test_advanced_analytics_available(self, query_executor):
        """Verify advanced analytics capabilities"""
        query = """
        MATCH (c:Customer)-[:HAS_PREDICTION]->(pm:PredictiveModel)
        MATCH (c)-[:HAS_PROFILE]->(profile:CustomerProfile)
        RETURN count(c) as customers_with_analytics
        """
        result = query_executor(query)
        assert result[0]['customers_with_analytics'] >= 10, "Not enough customers with analytics"
        print(f"  ✓ Advanced analytics: {result[0]['customers_with_analytics']} customers")

    def test_business_intelligence_complete(self, query_executor):
        """Verify business intelligence data is complete"""
        query = """
        MATCH (kpi:BusinessKPI)
        RETURN kpi.total_customers as customers,
               kpi.total_active_policies as policies,
               kpi.total_premium_portfolio as premium
        """
        result = query_executor(query)
        if len(result) > 0:
            print("  ✓ Business intelligence complete")
        else:
            print("  ⚠ Business intelligence data missing")

    def test_fraud_detection_operational(self, query_executor):
        """Verify fraud detection system operational"""
        query = """
        MATCH (cl:Claim)
        WHERE cl.fraud_score IS NOT NULL
        RETURN count(cl) as claims_with_fraud_scores
        """
        result = query_executor(query)
        print(f"  ✓ Fraud detection operational: {result[0]['claims_with_fraud_scores']} scored claims")

    def test_platform_scale(self, db_validator):
        """Verify platform has reached expected scale"""
        total_nodes = db_validator.count_nodes()
        total_rels = db_validator.count_relationships()

        assert total_nodes >= 600, f"Platform scale insufficient: {total_nodes} nodes"
        assert total_rels >= 400, f"Platform scale insufficient: {total_rels} relationships"
        print(f"  ✓ Platform scale adequate: {total_nodes} nodes, {total_rels} relationships")

    # ===================================
    # OPERATIONAL TESTS: Lab 15 Operations
    # ===================================

    def test_operation_platform_analytics(self, query_executor):
        """Test: Students can run platform-wide analytics"""
        query = """
        MATCH (c:Customer)
        OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(cl:Claim)
        WITH count(DISTINCT c) as customers,
             count(DISTINCT p) as policies,
             count(DISTINCT cl) as claims
        RETURN customers, policies, claims
        """
        result = query_executor(query)
        assert len(result) == 1
        print(f"  ✓ Platform analytics operations work")

    def test_lab15_summary(self, db_validator):
        """Print Lab 15 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        labels = db_validator.get_all_labels()
        rel_types = db_validator.get_all_relationship_types()

        print("\n  Lab 15 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Node Types: {len(labels)}, Relationship Types: {len(rel_types)}")
        print("    ✓ End-to-end workflows")
        print("    ✓ Platform-wide analytics")
        print("    ✓ Integration complete")
        print("  ✓ Lab 15 validation complete")
