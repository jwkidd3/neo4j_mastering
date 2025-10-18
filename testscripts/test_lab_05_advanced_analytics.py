"""
Test Suite for Lab 5: Advanced Analytics Foundation
Expected State: 200 nodes, 300 relationships
"""

import pytest


class TestLab05:
    """Test Lab 5: Advanced Analytics Foundation"""

    def test_node_count_day1_complete(self, db_validator):
        """Verify node count for Day 1 completion"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 200, f"Expected at least 200 nodes for Day 1 completion, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 200+)")

    def test_relationship_count_day1_complete(self, db_validator):
        """Verify relationship count for Day 1 completion"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 250, f"Expected at least 250 relationships for Day 1 completion, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 250+)")

    def test_risk_assessment_nodes(self, db_validator):
        """Verify RiskAssessment nodes were created"""
        risk_count = db_validator.count_nodes("RiskAssessment")
        assert risk_count >= 10, f"Expected at least 10 risk assessments, got {risk_count}"
        print(f"  ✓ RiskAssessment nodes: {risk_count}")

    def test_customer_profile_nodes(self, db_validator):
        """Verify CustomerProfile nodes were created"""
        profile_count = db_validator.count_nodes("CustomerProfile")
        assert profile_count >= 10, f"Expected at least 10 customer profiles, got {profile_count}"
        print(f"  ✓ CustomerProfile nodes: {profile_count}")

    def test_cross_sell_opportunity_nodes(self, db_validator):
        """Verify CrossSellOpportunity nodes were created"""
        opportunity_count = db_validator.count_nodes("CrossSellOpportunity")
        assert opportunity_count >= 10, f"Expected at least 10 cross-sell opportunities, got {opportunity_count}"
        print(f"  ✓ CrossSellOpportunity nodes: {opportunity_count}")

    def test_predictive_model_nodes(self, db_validator):
        """Verify PredictiveModel nodes were created"""
        prediction_count = db_validator.count_nodes("PredictiveModel")
        assert prediction_count >= 10, f"Expected at least 10 predictive models, got {prediction_count}"
        print(f"  ✓ PredictiveModel nodes: {prediction_count}")

    def test_business_kpi_nodes(self, db_validator):
        """Verify BusinessKPI nodes were created"""
        kpi_count = db_validator.count_nodes("BusinessKPI")
        assert kpi_count >= 1, f"Expected at least 1 business KPI, got {kpi_count}"
        print(f"  ✓ BusinessKPI nodes: {kpi_count}")

    def test_has_risk_assessment_relationship(self, db_validator):
        """Verify HAS_RISK_ASSESSMENT relationships exist"""
        has_risk = db_validator.count_relationships("HAS_RISK_ASSESSMENT")
        assert has_risk >= 10, f"Expected at least 10 HAS_RISK_ASSESSMENT relationships, got {has_risk}"
        print(f"  ✓ HAS_RISK_ASSESSMENT relationships: {has_risk}")

    def test_has_profile_relationship(self, db_validator):
        """Verify HAS_PROFILE relationships exist"""
        has_profile = db_validator.count_relationships("HAS_PROFILE")
        assert has_profile >= 10, f"Expected at least 10 HAS_PROFILE relationships, got {has_profile}"
        print(f"  ✓ HAS_PROFILE relationships: {has_profile}")

    def test_has_prediction_relationship(self, db_validator):
        """Verify HAS_PREDICTION relationships exist"""
        has_prediction = db_validator.count_relationships("HAS_PREDICTION")
        assert has_prediction >= 10, f"Expected at least 10 HAS_PREDICTION relationships, got {has_prediction}"
        print(f"  ✓ HAS_PREDICTION relationships: {has_prediction}")

    def test_has_opportunity_relationship(self, db_validator):
        """Verify HAS_OPPORTUNITY relationships exist"""
        has_opportunity = db_validator.count_relationships("HAS_OPPORTUNITY")
        assert has_opportunity >= 10, f"Expected at least 10 HAS_OPPORTUNITY relationships, got {has_opportunity}"
        print(f"  ✓ HAS_OPPORTUNITY relationships: {has_opportunity}")

    def test_risk_assessment_properties(self, query_executor):
        """Verify risk assessment has complete properties"""
        query = """
        MATCH (r:RiskAssessment)
        WHERE r.risk_score IS NOT NULL
        RETURN count(r) as complete_assessments
        """
        result = query_executor(query)
        assert result[0]['complete_assessments'] >= 10, "Not enough complete risk assessments"
        print(f"  ✓ Risk assessment properties validated")

    def test_customer_profile_completeness(self, query_executor):
        """Verify customer profiles have complete analytics data"""
        query = """
        MATCH (cp:CustomerProfile)
        WHERE cp.profitability_score IS NOT NULL
          AND cp.lifetime_value IS NOT NULL
        RETURN count(cp) as complete_profiles
        """
        result = query_executor(query)
        assert result[0]['complete_profiles'] >= 10, "Not enough complete customer profiles"
        print(f"  ✓ Customer profile completeness validated")

    def test_predictive_model_metrics(self, query_executor):
        """Verify predictive models have churn and LTV predictions"""
        query = """
        MATCH (pm:PredictiveModel)
        WHERE pm.churn_probability IS NOT NULL
          AND pm.cross_sell_probability IS NOT NULL
        RETURN count(pm) as complete_predictions
        """
        result = query_executor(query)
        assert result[0]['complete_predictions'] >= 10, "Not enough complete predictive models"
        print(f"  ✓ Predictive model metrics validated")

    def test_customer_360_view(self, query_executor):
        """Verify customer 360-degree view is complete"""
        query = """
        MATCH (c:Customer)
        MATCH (c)-[:HAS_PROFILE]->(profile:CustomerProfile)
        MATCH (c)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)
        MATCH (c)-[:HAS_PREDICTION]->(prediction:PredictiveModel)
        RETURN count(c) as customers_with_360_view
        """
        result = query_executor(query)
        assert result[0]['customers_with_360_view'] >= 10, "Not enough customers with 360-degree views"
        print(f"  ✓ Customer 360-degree view validated: {result[0]['customers_with_360_view']} customers")

    def test_customer_segmentation(self, query_executor):
        """Verify customer segmentation exists"""
        query = """
        MATCH (cp:CustomerProfile)
        RETURN cp.customer_segment as segment, count(*) as count
        ORDER BY count DESC
        """
        result = query_executor(query)
        assert len(result) >= 2, "Expected at least 2 customer segments"
        print(f"  ✓ Customer segmentation validated: {len(result)} segments")

    def test_cross_sell_recommendations(self, query_executor):
        """Verify cross-sell opportunities have recommendations"""
        query = """
        MATCH (cso:CrossSellOpportunity)
        RETURN count(cso) as opportunities_with_recommendations
        """
        result = query_executor(query)
        assert result[0]['opportunities_with_recommendations'] >= 10, "Not enough opportunities with recommendations"
        print(f"  ✓ Cross-sell recommendations validated")

    def test_business_kpi_metrics(self, query_executor):
        """Verify BusinessKPI has complete metrics"""
        query = """
        MATCH (kpi:BusinessKPI)
        RETURN kpi.total_customers as customers,
               kpi.total_active_policies as policies,
               kpi.total_premium_portfolio as premium,
               kpi.loss_ratio as loss_ratio
        """
        result = query_executor(query)
        assert len(result) >= 1, "BusinessKPI not found"

        kpi = result[0]
        assert kpi['customers'] is not None and kpi['customers'] > 0
        assert kpi['policies'] is not None and kpi['policies'] > 0
        assert kpi['premium'] is not None and kpi['premium'] > 0
        assert kpi['loss_ratio'] is not None
        print("  ✓ BusinessKPI metrics validated")

    def test_risk_profitability_correlation(self, query_executor):
        """Verify risk and profitability data correlation"""
        query = """
        MATCH (c:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
        MATCH (c)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)
        WHERE profile.profitability_score IS NOT NULL
          AND risk.risk_score IS NOT NULL
        RETURN count(*) as customers_with_correlation
        """
        result = query_executor(query)
        assert result[0]['customers_with_correlation'] >= 10, "Not enough customers with risk-profitability correlation"
        print(f"  ✓ Risk-profitability correlation validated")

    # ===================================
    # OPERATIONAL TESTS: Lab 5 Operations
    # ===================================

    def test_operation_risk_score_calculation(self, query_executor):
        """Test: Students can calculate risk scores from customer data"""
        query = """
        MATCH (c:Customer)-[:HAS_RISK_ASSESSMENT]->(r:RiskAssessment)
        WHERE c.risk_tier IS NOT NULL AND c.credit_score IS NOT NULL
        RETURN c.customer_number as customer,
               c.risk_tier as tier,
               c.credit_score as credit,
               r.risk_score as calculated_score
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "Risk score calculation query failed"
        for row in result:
            assert row['calculated_score'] is not None
            assert row['calculated_score'] > 0
        print(f"  ✓ Risk score calculation operation works ({len(result)} examples)")

    def test_operation_optional_match_pattern(self, query_executor):
        """Test: Students can use OPTIONAL MATCH for incomplete data"""
        query = """
        MATCH (c:Customer)
        OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(claim:Claim)
        RETURN c.customer_number as customer,
               count(DISTINCT p) AS policy_count,
               count(DISTINCT claim) AS claim_count
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "OPTIONAL MATCH pattern failed"
        for row in result:
            assert row['policy_count'] >= 0
        print(f"  ✓ OPTIONAL MATCH operation works ({len(result)} customers)")

    def test_operation_duration_calculations(self, query_executor):
        """Test: Students can calculate durations and ages"""
        query = """
        MATCH (c:Customer)
        WHERE c.date_of_birth IS NOT NULL
        WITH c,
             duration.between(c.date_of_birth, date()).years AS age
        WHERE age > 0 AND age < 120
        RETURN c.customer_number as customer, age
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1, "Duration calculation failed"
        for row in result:
            assert row['age'] > 0 and row['age'] < 120
        print(f"  ✓ Duration calculation operation works ({len(result)} examples)")

    def test_operation_case_segmentation(self, query_executor):
        """Test: Students can use CASE statements for segmentation"""
        query = """
        MATCH (cp:CustomerProfile)
        WHERE cp.lifetime_value IS NOT NULL
        WITH cp,
             CASE
               WHEN cp.lifetime_value > 15000 THEN "Premium"
               WHEN cp.lifetime_value > 10000 THEN "High-Value"
               WHEN cp.lifetime_value > 5000 THEN "Standard"
               ELSE "Basic"
             END AS value_segment
        RETURN value_segment, count(*) as count
        ORDER BY count DESC
        """
        result = query_executor(query)
        assert len(result) >= 2, "CASE segmentation failed"
        print(f"  ✓ CASE segmentation operation works ({len(result)} segments)")

    def test_operation_coalesce_null_handling(self, query_executor):
        """Test: Students can handle nulls with COALESCE"""
        query = """
        MATCH (c:Customer)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(claim:Claim)
        WITH c,
             count(claim) AS claim_count,
             sum(claim.claim_amount) AS total_claims
        RETURN c.customer_number as customer,
               claim_count,
               COALESCE(total_claims, 0.0) AS total_claim_amount
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "COALESCE operation failed"
        for row in result:
            assert row['total_claim_amount'] is not None
            assert row['total_claim_amount'] >= 0
        print(f"  ✓ COALESCE null handling works ({len(result)} examples)")

    def test_operation_aggregate_functions(self, query_executor):
        """Test: Students can use count, sum, avg, min, max"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN count(c) AS total_customers,
               count(p) AS total_policies,
               sum(p.annual_premium) AS total_premium,
               avg(p.annual_premium) AS avg_premium,
               min(p.annual_premium) AS min_premium,
               max(p.annual_premium) AS max_premium
        """
        result = query_executor(query)
        assert len(result) == 1, "Aggregate functions query failed"
        row = result[0]
        assert row['total_customers'] > 0
        assert row['total_policies'] > 0
        assert row['max_premium'] >= row['min_premium']
        print(f"  ✓ Aggregate functions operation works")

    def test_operation_collect_aggregation(self, query_executor):
        """Test: Students can use collect() to aggregate into lists"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.customer_number as customer,
               collect(p.product_type) AS products,
               size(collect(p)) AS policy_count
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "COLLECT aggregation failed"
        for row in result:
            assert len(row['products']) > 0
            assert row['policy_count'] == len(row['products'])
        print(f"  ✓ COLLECT aggregation operation works ({len(result)} examples)")

    def test_operation_distinct_counting(self, query_executor):
        """Test: Students can use DISTINCT for unique counts"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        MATCH (a:Agent)-[:SERVICES]->(c)
        RETURN a.agent_id as agent,
               count(DISTINCT c) AS unique_customers,
               count(DISTINCT p) AS unique_policies,
               count(p) AS total_policy_records
        ORDER BY unique_customers DESC
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1, "DISTINCT counting failed"
        for row in result:
            assert row['total_policy_records'] >= row['unique_policies']
        print(f"  ✓ DISTINCT counting operation works ({len(result)} agents)")

    def test_lab5_day1_summary(self, db_validator, query_executor):
        """Print Lab 5 and Day 1 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        customers = db_validator.count_nodes("Customer")
        policies = db_validator.count_nodes("Policy")
        claims = db_validator.count_nodes("Claim")
        risk_assessments = db_validator.count_nodes("RiskAssessment")
        profiles = db_validator.count_nodes("CustomerProfile")
        predictions = db_validator.count_nodes("PredictiveModel")

        # Get unique node types
        labels = db_validator.get_all_labels()

        print("\n  Lab 5 / Day 1 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Customers: {customers}, Policies: {policies}, Claims: {claims}")
        print(f"    Risk Assessments: {risk_assessments}, Profiles: {profiles}")
        print(f"    ✓ Risk score calculations")
        print(f"    ✓ OPTIONAL MATCH patterns")
        print(f"    ✓ Duration calculations")
        print(f"    ✓ CASE segmentation")
        print(f"    ✓ COALESCE null handling")
        print(f"    ✓ Aggregate functions (count, sum, avg, min, max)")
        print(f"    ✓ COLLECT aggregations")
        print(f"    ✓ DISTINCT counting")
        print("  ✓ Lab 5 validation complete")
        print("  ✓✓✓ DAY 1 COMPLETE ✓✓✓")
