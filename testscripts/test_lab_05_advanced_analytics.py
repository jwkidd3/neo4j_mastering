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
        assert total_rels >= 300, f"Expected at least 300 relationships for Day 1 completion, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 300+)")

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
          AND r.assessment_type IS NOT NULL
          AND r.confidence_level IS NOT NULL
        RETURN count(r) as complete_assessments
        """
        result = query_executor(query)
        assert result[0]['complete_assessments'] >= 10, "Not enough complete risk assessments"
        print(f"  ✓ Risk assessment properties validated")

    def test_customer_profile_completeness(self, query_executor):
        """Verify customer profiles have complete analytics data"""
        query = """
        MATCH (cp:CustomerProfile)
        WHERE cp.customer_segment IS NOT NULL
          AND cp.profitability_score IS NOT NULL
          AND cp.retention_risk IS NOT NULL
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
          AND pm.predicted_ltv IS NOT NULL
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
        WHERE size(cso.recommended_products) > 0
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

        print("\n  Lab 5 / Day 1 Completion Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    Customers: {customers}")
        print(f"    Policies: {policies}")
        print(f"    Claims: {claims}")
        print(f"    Risk Assessments: {risk_assessments}")
        print(f"    Customer Profiles: {profiles}")
        print(f"    Predictive Models: {predictions}")
        print(f"    Unique Node Types: {len(labels)}")
        print("  ✓ Lab 5 validation complete")
        print("  ✓✓✓ DAY 1 COMPLETE ✓✓✓")
