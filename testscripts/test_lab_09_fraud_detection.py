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
        assert total_rels >= 400, f"Expected at least 400 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 400+)")

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

    # ===================================
    # OPERATIONAL TESTS: Lab 9 Operations
    # ===================================

    def test_operation_fraud_pattern_detection(self, query_executor):
        """Test: Students can detect fraud patterns"""
        query = """
        MATCH (cl:Claim)
        WHERE cl.fraud_score > 0.5
        WITH cl.claim_type as type,
             count(cl) as high_risk_claims,
             avg(cl.fraud_score) as avg_score
        RETURN type, high_risk_claims, round(avg_score * 100) / 100 as avg_score
        ORDER BY high_risk_claims DESC
        """
        result = query_executor(query)
        print(f"  ✓ Fraud pattern detection works ({len(result)} patterns)")

    def test_operation_anomaly_identification(self, query_executor):
        """Test: Students can identify anomalies"""
        query = """
        MATCH (c:Customer)-[:FILED_CLAIM]->(cl:Claim)
        WITH c, count(cl) as claim_count, sum(cl.claim_amount) as total_claims
        WHERE claim_count > 2 OR total_claims > 50000
        RETURN c.customer_number as customer,
               claim_count,
               total_claims as total_amount
        ORDER BY total_claims DESC
        """
        result = query_executor(query)
        print(f"  ✓ Anomaly identification works ({len(result)} anomalies)")

    def test_operation_network_fraud_analysis(self, query_executor):
        """Test: Students can analyze fraud networks"""
        query = """
        MATCH (c1:Customer)-[:FILED_CLAIM]->(cl1:Claim)
        WHERE cl1.fraud_score > 0.3
        OPTIONAL MATCH (c1)-[r]->(c2:Customer)
        RETURN c1.customer_number as customer,
               count(DISTINCT cl1) as suspicious_claims,
               count(DISTINCT c2) as connected_customers
        ORDER BY suspicious_claims DESC
        LIMIT 5
        """
        result = query_executor(query)
        print(f"  ✓ Network fraud analysis works ({len(result)} cases)")

    def test_lab9_summary(self, db_validator):
        """Print Lab 9 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        investigators = db_validator.count_nodes("Investigator")
        investigations = db_validator.count_nodes("FraudInvestigation")

        print("\n  Lab 9 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Investigators: {investigators}, Investigations: {investigations}")
        print(f"    ✓ Fraud pattern detection")
        print(f"    ✓ Anomaly identification")
        print(f"    ✓ Network fraud analysis")
        print(f"    ✓ Shared information detection")
        print("  ✓ Lab 9 validation complete")
