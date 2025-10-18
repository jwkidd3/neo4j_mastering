"""
Test Suite for Lab 6: Advanced Customer Intelligence & Segmentation
Expected State: 280 nodes, 380 relationships
"""

import pytest


class TestLab06:
    """Test Lab 6: Advanced Customer Intelligence & Segmentation"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 5"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 280, f"Expected at least 280 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 280+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 5"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 380, f"Expected at least 380 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 380+)")

    def test_lifetime_value_model_nodes(self, db_validator):
        """Verify LifetimeValueModel nodes were created"""
        ltv_count = db_validator.count_nodes("LifetimeValueModel")
        assert ltv_count >= 10, f"Expected at least 10 LTV models, got {ltv_count}"
        print(f"  ✓ LifetimeValueModel nodes: {ltv_count}")

    def test_commission_nodes(self, db_validator):
        """Verify Commission nodes were created"""
        commission_count = db_validator.count_nodes("Commission")
        assert commission_count >= 5, f"Expected at least 5 commissions, got {commission_count}"
        print(f"  ✓ Commission nodes: {commission_count}")

    def test_behavioral_segment_nodes(self, db_validator):
        """Verify BehavioralSegment nodes were created"""
        segment_count = db_validator.count_nodes("BehavioralSegment")
        assert segment_count >= 10, f"Expected at least 10 behavioral segments, got {segment_count}"
        print(f"  ✓ BehavioralSegment nodes: {segment_count}")

    def test_marketing_campaign_nodes(self, db_validator):
        """Verify MarketingCampaign nodes were created"""
        campaign_count = db_validator.count_nodes("MarketingCampaign")
        assert campaign_count >= 3, f"Expected at least 3 campaigns, got {campaign_count}"
        print(f"  ✓ MarketingCampaign nodes: {campaign_count}")

    def test_customer_journey_nodes(self, db_validator):
        """Verify CustomerJourney nodes were created"""
        journey_count = db_validator.count_nodes("CustomerJourney")
        assert journey_count >= 10, f"Expected at least 10 customer journeys, got {journey_count}"
        print(f"  ✓ CustomerJourney nodes: {journey_count}")

    def test_ltv_calculations(self, query_executor):
        """Verify LTV models have complete calculations"""
        query = """
        MATCH (ltv:LifetimeValueModel)
        WHERE ltv.current_ltv IS NOT NULL
          AND ltv.predicted_ltv IS NOT NULL
          AND ltv.retention_probability IS NOT NULL
        RETURN count(ltv) as complete_ltv_models
        """
        result = query_executor(query)
        assert result[0]['complete_ltv_models'] >= 10, "Not enough complete LTV models"
        print(f"  ✓ LTV calculations validated")

    def test_behavioral_segmentation(self, query_executor):
        """Verify behavioral segmentation tiers exist"""
        query = """
        MATCH (bs:BehavioralSegment)
        RETURN bs.behavioral_tier as tier, count(*) as count
        ORDER BY count DESC
        """
        result = query_executor(query)
        assert len(result) >= 3, f"Expected at least 3 behavioral tiers, got {len(result)}"
        print(f"  ✓ Behavioral segmentation validated: {len(result)} tiers")

    def test_marketing_campaign_targeting(self, query_executor):
        """Verify marketing campaigns have targeting data"""
        query = """
        MATCH (mc:MarketingCampaign)
        WHERE size(mc.target_segments) > 0
          AND mc.expected_response_rate IS NOT NULL
        RETURN count(mc) as campaigns_with_targeting
        """
        result = query_executor(query)
        assert result[0]['campaigns_with_targeting'] >= 3, "Not enough campaigns with targeting"
        print(f"  ✓ Marketing campaign targeting validated")

    def test_customer_journey_predictions(self, query_executor):
        """Verify customer journeys have predictive data"""
        query = """
        MATCH (cj:CustomerJourney)
        WHERE cj.predicted_path IS NOT NULL
          AND cj.success_probability IS NOT NULL
        RETURN count(cj) as journeys_with_predictions
        """
        result = query_executor(query)
        assert result[0]['journeys_with_predictions'] >= 10, "Not enough journeys with predictions"
        print(f"  ✓ Customer journey predictions validated")

    def test_commission_tracking(self, query_executor):
        """Verify commission tracking for agents"""
        query = """
        MATCH (a:Agent)-[:EARNED_COMMISSION]->(c:Commission)
        RETURN count(*) as commission_relationships
        """
        result = query_executor(query)
        assert result[0]['commission_relationships'] >= 5, "Not enough commission relationships"
        print(f"  ✓ Commission tracking validated")

    def test_lab6_summary(self, db_validator):
        """Print Lab 6 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        ltv_models = db_validator.count_nodes("LifetimeValueModel")
        segments = db_validator.count_nodes("BehavioralSegment")
        campaigns = db_validator.count_nodes("MarketingCampaign")

        print("\n  Lab 6 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    LTV Models: {ltv_models}")
        print(f"    Behavioral Segments: {segments}")
        print(f"    Marketing Campaigns: {campaigns}")
        print("  ✓ Lab 6 validation complete")
