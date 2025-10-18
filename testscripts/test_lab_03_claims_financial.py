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

    # ===================================
    # OPERATIONAL TESTS: Lab 3 Operations
    # ===================================

    def test_operation_claims_status_aggregation(self, query_executor):
        """Test: Students can aggregate claims by status with financial totals"""
        query = """
        MATCH (c:Claim)
        RETURN c.claim_status AS status,
               count(c) AS claim_count,
               avg(c.claim_amount) AS avg_claim_amount,
               sum(c.claim_amount) AS total_claim_amount
        ORDER BY claim_count DESC
        """
        result = query_executor(query)
        assert len(result) >= 1, "Claims aggregation failed"

        for row in result:
            assert row['claim_count'] > 0
            assert row['avg_claim_amount'] > 0
            assert row['total_claim_amount'] > 0
        print(f"  ✓ Claims status aggregation operation works ({len(result)} statuses)")

    def test_operation_multi_hop_claims_workflow(self, query_executor):
        """Test: Students can query complete claims workflow pattern"""
        query = """
        MATCH (customer:Customer)-[:FILED_CLAIM]->(claim:Claim)
        MATCH (claim)-[:INVOLVES_ASSET]->(asset)
        RETURN customer.first_name + " " + customer.last_name AS customer_name,
               claim.claim_number AS claim_number,
               claim.claim_type AS claim_type,
               labels(asset)[0] AS asset_type,
               claim.claim_amount AS claim_amount,
               claim.claim_status AS status
        ORDER BY claim.claim_amount DESC
        """
        result = query_executor(query)
        assert len(result) >= 3, "Multi-hop claims workflow query failed"

        for row in result:
            assert " " in row['customer_name']
            assert row['asset_type'] in ['Vehicle', 'Property', 'Asset']
            assert row['claim_amount'] > 0
        print(f"  ✓ Multi-hop claims workflow operation works ({len(result)} claims)")

    def test_operation_financial_payment_aggregation(self, query_executor):
        """Test: Students can aggregate payments by method"""
        query = """
        MATCH (p:Payment)
        WHERE p.payment_type = "Premium"
        RETURN count(p) AS total_payments,
               sum(p.amount) AS total_premiums_collected,
               avg(p.amount) AS average_payment,
               p.payment_method AS payment_method
        ORDER BY total_premiums_collected DESC
        """
        result = query_executor(query)
        assert len(result) >= 1, "Payment aggregation failed"

        total_collected = sum(row['total_premiums_collected'] for row in result)
        assert total_collected > 0
        print(f"  ✓ Financial payment aggregation works (${total_collected:.2f} total)")

    def test_operation_vendor_performance_analysis(self, query_executor):
        """Test: Students can analyze vendor performance with aggregations"""
        query = """
        MATCH (vendor:RepairShop)<-[:ASSIGNED_TO]-(claim:Claim)
        RETURN vendor.business_name AS vendor,
               vendor.specialization AS services,
               count(claim) AS claims_assigned,
               avg(claim.claim_amount) AS avg_claim_value,
               vendor.rating AS vendor_rating,
               vendor.average_repair_time AS avg_repair_days
        ORDER BY claims_assigned DESC
        """
        result = query_executor(query)
        assert len(result) >= 3, "Vendor performance analysis failed"

        for row in result:
            assert row['claims_assigned'] > 0
            assert row['avg_claim_value'] > 0
            assert row['vendor_rating'] > 0
        print(f"  ✓ Vendor performance analysis works ({len(result)} vendors)")

    def test_operation_relationship_property_filtering(self, query_executor):
        """Test: Students can filter by relationship properties"""
        query = """
        MATCH (claim:Claim)-[r:INVOLVES_ASSET]->(asset)
        WHERE r.damage_severity IS NOT NULL
        RETURN claim.claim_number as claim_number,
               r.damage_type as damage_type,
               r.damage_severity as severity,
               r.estimated_repair_cost as repair_cost
        ORDER BY r.estimated_repair_cost DESC
        """
        result = query_executor(query)
        assert len(result) >= 3, "Relationship property filtering failed"

        for row in result:
            assert row['severity'] in ['Minor', 'Moderate', 'Major', 'Severe']
            assert row['repair_cost'] > 0
        print(f"  ✓ Relationship property filtering works ({len(result)} claims)")

    def test_operation_date_based_filtering(self, query_executor):
        """Test: Students can filter claims by date ranges"""
        query = """
        MATCH (c:Claim)
        WHERE c.incident_date >= date('2024-06-01')
          AND c.incident_date <= date('2024-07-31')
        RETURN c.claim_number as claim_number,
               c.incident_date as incident_date,
               c.report_date as report_date,
               duration.between(c.incident_date, c.report_date).days as days_to_report
        ORDER BY c.incident_date
        """
        result = query_executor(query)
        assert len(result) >= 1, "Date-based filtering failed"

        for row in result:
            assert str(row['incident_date']) >= '2024-06-01'
            assert str(row['incident_date']) <= '2024-07-31'
            assert row['days_to_report'] >= 0
        print(f"  ✓ Date-based filtering operation works ({len(result)} claims)")

    def test_operation_asset_coverage_details(self, query_executor):
        """Test: Students can access relationship properties for coverage"""
        query = """
        MATCH (policy:Policy)-[r:COVERS]->(asset)
        RETURN policy.policy_number as policy_number,
               labels(asset)[0] as asset_type,
               r.coverage_types as coverage_types,
               r.coverage_start as coverage_start
        """
        result = query_executor(query)
        assert len(result) >= 3, "Asset coverage query failed"

        for row in result:
            assert isinstance(row['coverage_types'], list)
            assert len(row['coverage_types']) > 0
            assert row['coverage_start'] is not None
        print(f"  ✓ Asset coverage details operation works ({len(result)} coverages)")

    def test_operation_optional_match_settlements(self, query_executor):
        """Test: Students can use OPTIONAL MATCH for settlements"""
        query = """
        MATCH (claim:Claim)
        OPTIONAL MATCH (settlement:Payment)-[:SETTLES_CLAIM]->(claim)
        RETURN claim.claim_number as claim_number,
               claim.claim_amount as claim_amount,
               claim.claim_status as status,
               COALESCE(settlement.amount, 0.0) as settlement_amount,
               CASE WHEN settlement IS NULL THEN "Not Settled" ELSE "Settled" END as settlement_status
        ORDER BY claim.claim_amount DESC
        """
        result = query_executor(query)
        assert len(result) >= 3, "OPTIONAL MATCH for settlements failed"

        for row in result:
            assert row['settlement_status'] in ['Settled', 'Not Settled']
            assert row['settlement_amount'] >= 0
        print(f"  ✓ OPTIONAL MATCH settlement operation works ({len(result)} claims)")

    def test_operation_payment_application_tracking(self, query_executor):
        """Test: Students can track payment applications to policies"""
        query = """
        MATCH (customer:Customer)-[:MADE_PAYMENT]->(payment:Payment)
        MATCH (payment)-[r:APPLIED_TO]->(policy:Policy)
        RETURN customer.customer_number as customer,
               payment.payment_id as payment_id,
               payment.amount as amount,
               r.amount_applied as amount_applied,
               r.remaining_balance as remaining_balance,
               policy.policy_number as policy
        """
        result = query_executor(query)
        assert len(result) >= 3, "Payment application tracking failed"

        for row in result:
            assert row['amount'] > 0
            assert row['amount_applied'] > 0
            assert row['remaining_balance'] >= 0
        print(f"  ✓ Payment application tracking works ({len(result)} payments)")

    def test_operation_claim_investigation_filtering(self, query_executor):
        """Test: Students can filter claims by investigation criteria"""
        query = """
        MATCH (c:Claim)
        WHERE c.fraud_score IS NOT NULL
        WITH c,
             CASE
               WHEN c.fraud_score > 0.7 THEN "High Risk"
               WHEN c.fraud_score > 0.3 THEN "Medium Risk"
               ELSE "Low Risk"
             END AS fraud_risk_level
        RETURN fraud_risk_level,
               count(c) AS claim_count,
               avg(c.fraud_score) AS avg_fraud_score,
               sum(c.claim_amount) AS total_exposure
        ORDER BY avg_fraud_score DESC
        """
        result = query_executor(query)
        assert len(result) >= 1, "Claim investigation filtering failed"

        for row in result:
            assert row['fraud_risk_level'] in ['High Risk', 'Medium Risk', 'Low Risk']
            assert row['claim_count'] > 0
        print(f"  ✓ Claim investigation filtering works ({len(result)} risk levels)")

    def test_operation_complete_workflow_visualization(self, query_executor):
        """Test: Students can query complete business workflow"""
        query = """
        MATCH (customer:Customer)-[:FILED_CLAIM]->(claim:Claim)
        MATCH (claim)-[:INVOLVES_ASSET]->(asset)
        MATCH (claim)-[:ASSIGNED_TO]->(vendor:RepairShop)
        RETURN customer.customer_number as customer,
               claim.claim_number as claim,
               labels(asset)[0] as asset_type,
               vendor.business_name as vendor,
               claim.claim_amount as amount,
               vendor.average_repair_time as estimated_days
        """
        result = query_executor(query)
        assert len(result) >= 3, "Complete workflow query failed"

        for row in result:
            assert row['customer'] is not None
            assert row['claim'] is not None
            assert row['vendor'] is not None
            assert row['amount'] > 0
        print(f"  ✓ Complete workflow visualization works ({len(result)} workflows)")

    def test_operation_financial_reconciliation(self, query_executor):
        """Test: Students can perform financial reconciliation calculations"""
        query = """
        MATCH (customer:Customer)
        OPTIONAL MATCH (customer)-[:MADE_PAYMENT]->(payment:Payment)
        WHERE payment.payment_type = "Premium"
        OPTIONAL MATCH (customer)-[:FILED_CLAIM]->(claim:Claim)
        WITH customer,
             COALESCE(sum(payment.amount), 0.0) as total_paid,
             COALESCE(sum(claim.claim_amount), 0.0) as total_claimed,
             count(DISTINCT payment) as payment_count,
             count(DISTINCT claim) as claim_count
        WHERE payment_count > 0 OR claim_count > 0
        RETURN customer.customer_number as customer,
               total_paid,
               total_claimed,
               CASE WHEN total_paid > 0 THEN total_claimed / total_paid ELSE 0.0 END as claims_ratio,
               payment_count,
               claim_count
        ORDER BY claims_ratio DESC
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1, "Financial reconciliation failed"

        for row in result:
            assert row['total_paid'] >= 0
            assert row['total_claimed'] >= 0
            assert row['claims_ratio'] >= 0
        print(f"  ✓ Financial reconciliation operation works ({len(result)} customers)")

    def test_operation_asset_valuation_analysis(self, query_executor):
        """Test: Students can analyze asset values and coverage"""
        query = """
        MATCH (asset)
        WHERE asset:Vehicle OR asset:Property
        OPTIONAL MATCH (policy:Policy)-[r:COVERS]->(asset)
        WITH labels(asset)[0] as asset_type,
             count(asset) as asset_count,
             avg(asset.market_value) as avg_value,
             sum(asset.market_value) as total_value,
             count(policy) as policies_count
        RETURN asset_type,
               asset_count,
               round(avg_value * 100) / 100 as avg_value,
               round(total_value * 100) / 100 as total_value,
               policies_count
        ORDER BY total_value DESC
        """
        result = query_executor(query)
        assert len(result) >= 2, "Asset valuation analysis failed"

        for row in result:
            assert row['asset_type'] in ['Vehicle', 'Property', 'Asset']
            assert row['asset_count'] > 0
            assert row['avg_value'] > 0
        print(f"  ✓ Asset valuation analysis works ({len(result)} asset types)")

    def test_lab3_summary(self, db_validator):
        """Print Lab 3 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        claims = db_validator.count_nodes("Claim")
        vehicles = db_validator.count_nodes("Vehicle")
        properties = db_validator.count_nodes("Property")
        payments = db_validator.count_nodes("Payment")

        print("\n  Lab 3 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Claims: {claims}, Vehicles: {vehicles}, Properties: {properties}")
        print(f"    Payments: {payments}")
        print(f"    ✓ Claims status aggregation")
        print(f"    ✓ Multi-hop claims workflow")
        print(f"    ✓ Financial payment aggregation")
        print(f"    ✓ Vendor performance analysis")
        print(f"    ✓ Relationship property filtering")
        print(f"    ✓ Date-based filtering with duration")
        print(f"    ✓ Asset coverage details")
        print(f"    ✓ OPTIONAL MATCH settlements")
        print(f"    ✓ Payment application tracking")
        print(f"    ✓ Claim investigation filtering with CASE")
        print(f"    ✓ Complete workflow visualization")
        print(f"    ✓ Financial reconciliation")
        print(f"    ✓ Asset valuation analysis")
        print("  ✓ Lab 3 validation complete")
