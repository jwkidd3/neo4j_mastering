"""
Test Suite for Lab 3: Claims Processing & Financial Transaction Modeling
Expected State: 60 nodes, 85 relationships
"""

import pytest


class TestLab03:
    """Test Lab 3: Claims Processing & Financial Transaction Modeling"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 2"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 60, f"Expected at least 60 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 60+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 2"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 85, f"Expected at least 85 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 85+)")

    def test_vehicle_assets_added(self, db_validator):
        """Verify Vehicle asset nodes were created"""
        vehicle_count = db_validator.count_nodes("Vehicle")
        assert vehicle_count >= 2, f"Expected at least 2 vehicles, got {vehicle_count}"
        print(f"  ✓ Vehicle nodes: {vehicle_count}")

    def test_property_assets_added(self, db_validator):
        """Verify Property asset nodes were created"""
        property_count = db_validator.count_nodes("Property")
        assert property_count >= 1, f"Expected at least 1 property, got {property_count}"
        print(f"  ✓ Property nodes: {property_count}")

    def test_claim_nodes_added(self, db_validator):
        """Verify Claim nodes were created"""
        claim_count = db_validator.count_nodes("Claim")
        assert claim_count >= 3, f"Expected at least 3 claims, got {claim_count}"
        print(f"  ✓ Claim nodes: {claim_count}")

    def test_repair_shop_nodes_added(self, db_validator):
        """Verify RepairShop vendor nodes were created"""
        repair_count = db_validator.count_nodes("RepairShop")
        assert repair_count >= 3, f"Expected at least 3 repair shops, got {repair_count}"
        print(f"  ✓ RepairShop nodes: {repair_count}")

    def test_payment_nodes_added(self, db_validator):
        """Verify Payment nodes were created"""
        payment_count = db_validator.count_nodes("Payment")
        assert payment_count >= 3, f"Expected at least 3 payments, got {payment_count}"
        print(f"  ✓ Payment nodes: {payment_count}")

    def test_invoice_nodes_added(self, db_validator):
        """Verify Invoice nodes were created"""
        invoice_count = db_validator.count_nodes("Invoice")
        assert invoice_count >= 2, f"Expected at least 2 invoices, got {invoice_count}"
        print(f"  ✓ Invoice nodes: {invoice_count}")

    def test_covers_relationship(self, db_validator):
        """Verify COVERS relationships exist (policy covers asset)"""
        covers = db_validator.count_relationships("COVERS")
        assert covers >= 3, f"Expected at least 3 COVERS relationships, got {covers}"
        print(f"  ✓ COVERS relationships: {covers}")

    def test_filed_claim_relationship(self, db_validator):
        """Verify FILED_CLAIM relationships exist"""
        filed_claim = db_validator.count_relationships("FILED_CLAIM")
        assert filed_claim >= 3, f"Expected at least 3 FILED_CLAIM relationships, got {filed_claim}"
        print(f"  ✓ FILED_CLAIM relationships: {filed_claim}")

    def test_involves_asset_relationship(self, db_validator):
        """Verify INVOLVES_ASSET relationships exist"""
        involves = db_validator.count_relationships("INVOLVES_ASSET")
        assert involves >= 3, f"Expected at least 3 INVOLVES_ASSET relationships, got {involves}"
        print(f"  ✓ INVOLVES_ASSET relationships: {involves}")

    def test_assigned_to_relationship(self, db_validator):
        """Verify ASSIGNED_TO relationships exist (claim to vendor)"""
        assigned = db_validator.count_relationships("ASSIGNED_TO")
        assert assigned >= 3, f"Expected at least 3 ASSIGNED_TO relationships, got {assigned}"
        print(f"  ✓ ASSIGNED_TO relationships: {assigned}")

    def test_made_payment_relationship(self, db_validator):
        """Verify MADE_PAYMENT relationships exist"""
        made_payment = db_validator.count_relationships("MADE_PAYMENT")
        assert made_payment >= 3, f"Expected at least 3 MADE_PAYMENT relationships, got {made_payment}"
        print(f"  ✓ MADE_PAYMENT relationships: {made_payment}")

    def test_applied_to_relationship(self, db_validator):
        """Verify APPLIED_TO relationships exist (payment to policy)"""
        applied_to = db_validator.count_relationships("APPLIED_TO")
        assert applied_to >= 3, f"Expected at least 3 APPLIED_TO relationships, got {applied_to}"
        print(f"  ✓ APPLIED_TO relationships: {applied_to}")

    def test_specific_claim_exists(self, db_validator):
        """Verify specific claim exists"""
        claim = db_validator.node_exists("Claim", {"claim_number": "CLM-AUTO-001234"})
        assert claim, "Claim CLM-AUTO-001234 not found"
        print("  ✓ Claim CLM-AUTO-001234 exists")

    def test_claim_properties(self, query_executor):
        """Verify claim has complete properties"""
        query = """
        MATCH (cl:Claim {claim_number: 'CLM-AUTO-001234'})
        RETURN cl.claim_type as type,
               cl.claim_status as status,
               cl.claim_amount as amount,
               cl.fault_determination as fault
        """
        result = query_executor(query)
        assert len(result) == 1, "Claim CLM-AUTO-001234 not found"

        claim = result[0]
        assert claim['type'] == 'Auto'
        assert claim['status'] is not None
        assert claim['amount'] > 0
        assert claim['fault'] is not None
        print("  ✓ Claim properties validated")

    def test_vehicle_properties(self, query_executor):
        """Verify vehicle has complete properties"""
        query = """
        MATCH (v:Vehicle {vin: '1HGBH41JXMN109186'})
        RETURN v.make as make,
               v.model as model,
               v.year as year,
               v.market_value as value
        """
        result = query_executor(query)
        assert len(result) == 1, "Vehicle with VIN 1HGBH41JXMN109186 not found"

        vehicle = result[0]
        assert vehicle['make'] == 'Toyota'
        assert vehicle['model'] == 'Camry'
        assert vehicle['year'] == 2022
        assert vehicle['value'] > 0
        print("  ✓ Vehicle properties validated")

    def test_claims_workflow(self, query_executor):
        """Verify complete claims workflow exists"""
        query = """
        MATCH (customer:Customer)-[:FILED_CLAIM]->(claim:Claim)
        MATCH (claim)-[:INVOLVES_ASSET]->(asset)
        MATCH (claim)-[:ASSIGNED_TO]->(vendor:RepairShop)
        RETURN count(*) as complete_workflows
        """
        result = query_executor(query)
        assert result[0]['complete_workflows'] >= 3, "Not enough complete claim workflows"
        print(f"  ✓ Complete claims workflows validated")

    def test_financial_workflow(self, query_executor):
        """Verify financial transaction workflow exists"""
        query = """
        MATCH (customer:Customer)-[:MADE_PAYMENT]->(payment:Payment)
        MATCH (payment)-[:APPLIED_TO]->(policy:Policy)
        RETURN count(*) as payment_flows
        """
        result = query_executor(query)
        assert result[0]['payment_flows'] >= 3, "Not enough payment workflows"
        print(f"  ✓ Financial workflows validated")

    def test_lab3_summary(self, db_validator):
        """Print Lab 3 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        claims = db_validator.count_nodes("Claim")
        vehicles = db_validator.count_nodes("Vehicle")
        properties = db_validator.count_nodes("Property")
        payments = db_validator.count_nodes("Payment")

        print("\n  Lab 3 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    Claims: {claims}")
        print(f"    Vehicles: {vehicles}")
        print(f"    Properties: {properties}")
        print(f"    Payments: {payments}")
        print("  ✓ Lab 3 validation complete")
