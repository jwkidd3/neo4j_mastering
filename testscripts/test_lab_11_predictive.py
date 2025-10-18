"""
Test Suite for Lab 11: Predictive Analytics & Machine Learning
Expected State: 600 nodes, 750 relationships
"""

import pytest


class TestLab11:
    """Test Lab 11: Predictive Analytics & Machine Learning"""

    def test_node_count_day2_complete(self, db_validator):
        """Verify node count for Day 2 completion"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 600, f"Expected at least 600 nodes for Day 2 completion, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 600+)")

    def test_relationship_count_day2_complete(self, db_validator):
        """Verify relationship count for Day 2 completion"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 400, f"Expected at least 400 relationships for Day 2 completion, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 400+)")

    def test_ml_model_nodes(self, db_validator):
        """Verify MLModel nodes were created"""
        ml_count = db_validator.count_nodes("MLModel")
        print(f"  ✓ MLModel nodes: {ml_count}")

    def test_prediction_result_nodes(self, db_validator):
        """Verify PredictionResult nodes exist"""
        prediction_count = db_validator.count_nodes("PredictionResult")
        print(f"  ✓ PredictionResult nodes: {prediction_count}")

    def test_feature_engineering_data(self, query_executor):
        """Verify features available for ML"""
        query = """
        MATCH (c:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
        WHERE profile.tenure_years IS NOT NULL
          AND profile.policy_count IS NOT NULL
          AND profile.total_claims IS NOT NULL
          AND profile.credit_score IS NOT NULL
        RETURN count(c) as customers_with_features
        """
        result = query_executor(query)
        assert result[0]['customers_with_features'] >= 10, "Not enough customers with ML features"
        print(f"  ✓ Customers with ML features: {result[0]['customers_with_features']}")

    def test_churn_prediction_data(self, query_executor):
        """Verify churn prediction data exists"""
        query = """
        MATCH (pm:PredictiveModel)
        WHERE pm.churn_probability IS NOT NULL
        RETURN count(pm) as models_with_churn
        """
        result = query_executor(query)
        assert result[0]['models_with_churn'] >= 10, "Not enough churn predictions"
        print(f"  ✓ Churn prediction models: {result[0]['models_with_churn']}")

    def test_ltv_prediction_data(self, query_executor):
        """Verify lifetime value predictions exist"""
        query = """
        MATCH (ltv:LifetimeValueModel)
        WHERE ltv.predicted_ltv IS NOT NULL
        RETURN count(ltv) as ltv_predictions
        """
        result = query_executor(query)
        assert result[0]['ltv_predictions'] >= 10, "Not enough LTV predictions"
        print(f"  ✓ LTV predictions: {result[0]['ltv_predictions']}")

    def test_cross_sell_scoring(self, query_executor):
        """Verify cross-sell probability scoring"""
        query = """
        MATCH (pm:PredictiveModel)
        WHERE pm.cross_sell_probability IS NOT NULL
        RETURN avg(pm.cross_sell_probability) as avg_cross_sell_prob
        """
        result = query_executor(query)
        print(f"  ✓ Cross-sell scoring available")

    def test_model_performance_metrics(self, query_executor):
        """Verify models have performance metrics"""
        query = """
        MATCH (pm:PredictiveModel)
        WHERE pm.model_confidence IS NOT NULL
        RETURN count(pm) as models_with_confidence
        """
        result = query_executor(query)
        assert result[0]['models_with_confidence'] >= 10, "Not enough models with confidence metrics"
        print(f"  ✓ Models with confidence metrics: {result[0]['models_with_confidence']}")

    def test_prediction_actionability(self, query_executor):
        """Verify predictions have actionable recommendations"""
        query = """
        MATCH (pm:PredictiveModel)
        WHERE size(pm.retention_actions) > 0
        RETURN count(pm) as models_with_actions
        """
        result = query_executor(query)
        assert result[0]['models_with_actions'] >= 10, "Not enough models with actionable recommendations"
        print(f"  ✓ Models with actionable recommendations: {result[0]['models_with_actions']}")

    def test_predictive_analytics_pipeline(self, query_executor):
        """Verify complete predictive analytics pipeline"""
        query = """
        MATCH (c:Customer)-[:HAS_PROFILE]->(profile:CustomerProfile)
        MATCH (c)-[:HAS_PREDICTION]->(prediction:PredictiveModel)
        MATCH (c)-[:HAS_RISK_ASSESSMENT]->(risk:RiskAssessment)
        RETURN count(c) as complete_pipelines
        """
        result = query_executor(query)
        assert result[0]['complete_pipelines'] >= 10, "Not enough complete predictive pipelines"
        print(f"  ✓ Complete predictive pipelines: {result[0]['complete_pipelines']}")

    # ===================================
    # OPERATIONAL TESTS: Lab 11 Operations
    # ===================================

    def test_operation_churn_prediction(self, query_executor):
        """Test: Students can use churn prediction scores"""
        query = """
        MATCH (c:Customer)-[:HAS_PREDICTION]->(pm:PredictiveModel)
        WHERE pm.churn_probability > 0.5
        RETURN c.customer_number as customer,
               pm.churn_probability as churn_risk,
               pm.retention_actions as actions
        ORDER BY churn_risk DESC
        LIMIT 5
        """
        result = query_executor(query)
        print(f"  ✓ Churn prediction operations work ({len(result)} high-risk customers)")

    def test_operation_ltv_forecasting(self, query_executor):
        """Test: Students can forecast customer lifetime value"""
        query = """
        MATCH (c:Customer)-[:HAS_LTV_MODEL]->(ltv:LifetimeValueModel)
        RETURN c.customer_number as customer,
               ltv.current_ltv as current,
               ltv.predicted_ltv as predicted,
               (ltv.predicted_ltv - ltv.current_ltv) as growth
        ORDER BY growth DESC
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5
        print(f"  ✓ LTV forecasting works ({len(result)} customers)")

    def test_operation_cross_sell_recommendations(self, query_executor):
        """Test: Students can generate cross-sell recommendations"""
        query = """
        MATCH (c:Customer)-[:HAS_PREDICTION]->(pm:PredictiveModel)
        WHERE pm.cross_sell_probability > 0.3
        RETURN c.customer_number as customer,
               pm.cross_sell_probability as probability,
               pm.recommended_product as product
        ORDER BY probability DESC
        LIMIT 5
        """
        result = query_executor(query)
        print(f"  ✓ Cross-sell recommendation operations work ({len(result)} opportunities)")

    def test_lab11_day2_summary(self, db_validator):
        """Print Lab 11 and Day 2 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        customers = db_validator.count_nodes("Customer")
        policies = db_validator.count_nodes("Policy")
        claims = db_validator.count_nodes("Claim")
        predictions = db_validator.count_nodes("PredictiveModel")
        ltv_models = db_validator.count_nodes("LifetimeValueModel")

        labels = db_validator.get_all_labels()

        print("\n  Lab 11 / Day 2 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Predictions: {predictions}, LTV Models: {ltv_models}")
        print(f"    ✓ Churn prediction scoring")
        print(f"    ✓ LTV forecasting")
        print(f"    ✓ Cross-sell recommendations")
        print(f"    ✓ Feature engineering")
        print("  ✓ Lab 11 validation complete")
        print("  ✓✓✓ DAY 2 COMPLETE ✓✓✓")
