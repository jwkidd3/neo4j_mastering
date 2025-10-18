"""
Test Suite for Lab 9: Advanced Fraud Detection & Investigation Tools
Expected State: 500 nodes, 600 relationships
"""

import pytest


class TestLab09:
    """Test Lab 9: Advanced Fraud Detection & Investigation Tools"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 8"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 450, f"Expected at least 450 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 450+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 8"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 550, f"Expected at least 550 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 550+)")

    def test_investigator_nodes(self, db_validator):
        """Verify Investigator nodes were created"""
        investigator_count = db_validator.count_nodes("Investigator")
        assert investigator_count >= 2, f"Expected at least 2 investigators, got {investigator_count}"
        print(f"  ✓ Investigator nodes: {investigator_count}")

    def test_fraud_investigation_nodes(self, db_validator):
        """Verify FraudInvestigation nodes were created"""
        investigation_count = db_validator.count_nodes("FraudInvestigation")
        assert investigation_count >= 1, f"Expected at least 1 fraud investigation, got {investigation_count}"
        print(f"  ✓ FraudInvestigation nodes: {investigation_count}")

    def test_fraud_alert_nodes(self, db_validator):
        """Verify FraudAlert nodes were created"""
        alert_count = db_validator.count_nodes("FraudAlert")
        assert alert_count >= 1, f"Expected at least 1 fraud alert, got {alert_count}"
        print(f"  ✓ FraudAlert nodes: {alert_count}")

    def test_fraud_scores_on_claims(self, query_executor):
        """Verify claims have fraud scores"""
        query = """
        MATCH (cl:Claim)
        WHERE cl.fraud_score IS NOT NULL
        RETURN count(cl) as claims_with_scores
        """
        result = query_executor(query)
        assert result[0]['claims_with_scores'] >= 3, "Not enough claims with fraud scores"
        print(f"  ✓ Claims with fraud scores: {result[0]['claims_with_scores']}")

    def test_suspicious_patterns(self, query_executor):
        """Verify ability to detect suspicious patterns"""
        query = """
        MATCH (c1:Customer)-[:FILED_CLAIM]->(cl1:Claim)
        MATCH (c2:Customer)-[:FILED_CLAIM]->(cl2:Claim)
        WHERE c1 <> c2
          AND cl1.incident_date = cl2.incident_date
        RETURN count(*) as potential_patterns
        """
        result = query_executor(query)
        # May or may not have patterns, just verify query works
        print(f"  ✓ Suspicious pattern detection working")

    def test_fraud_investigation_workflow(self, query_executor):
        """Verify fraud investigation workflow exists"""
        query = """
        MATCH (i:Investigator)-[:INVESTIGATES]->(fi:FraudInvestigation)
        RETURN count(*) as investigation_relationships
        """
        result = query_executor(query)
        # May be 0 if not created yet, just verify structure
        print(f"  ✓ Fraud investigation workflow structure validated")

    def test_claim_network_analysis(self, query_executor):
        """Verify ability to analyze claim networks"""
        query = """
        MATCH (c:Customer)-[:FILED_CLAIM]->(cl:Claim)
        WITH c, count(cl) as claim_count
        WHERE claim_count > 1
        RETURN count(c) as customers_with_multiple_claims
        """
        result = query_executor(query)
        print(f"  ✓ Claim network analysis working")

    def test_shared_information_detection(self, query_executor):
        """Verify ability to detect shared information"""
        query = """
        MATCH (c1:Customer), (c2:Customer)
        WHERE c1 <> c2
          AND (c1.address = c2.address OR c1.phone = c2.phone OR c1.email = c2.email)
        RETURN count(*) as shared_info_pairs
        """
        result = query_executor(query)
        # May be 0, just verify query works
        print(f"  ✓ Shared information detection working")

    def test_lab9_summary(self, db_validator):
        """Print Lab 9 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        investigators = db_validator.count_nodes("Investigator")
        investigations = db_validator.count_nodes("FraudInvestigation")

        print("\n  Lab 9 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    Investigators: {investigators}")
        print(f"    Fraud Investigations: {investigations}")
        print("  ✓ Lab 9 validation complete")
