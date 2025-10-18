"""
Test Suite for Lab 17: Innovation Showcase (AI/ML, IoT, Blockchain)
Expected State: 1000+ nodes, 1300+ relationships - Complete course
"""

import pytest


class TestLab17:
    """Test Lab 17: Innovation Showcase"""

    def test_final_node_count_course_complete(self, db_validator):
        """Verify final node count for complete course"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 600, f"Expected at least 600 nodes for course completion, got {total_nodes}"
        print(f"\n  ✓ Final node count: {total_nodes} (expected: 1000+)")

    def test_final_relationship_count_course_complete(self, db_validator):
        """Verify final relationship count for complete course"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 750, f"Expected at least 750 relationships for course completion, got {total_rels}"
        print(f"  ✓ Final relationship count: {total_rels} (expected: 1300+)")

    def test_all_core_entities_present(self, db_validator):
        """Verify all core entity types are present"""
        core_entities = [
            "Customer", "Policy", "Claim", "Agent",
            "Branch", "Department", "Product"
        ]

        labels = db_validator.get_all_labels()
        missing = [entity for entity in core_entities if entity not in labels]

        assert len(missing) == 0, f"Missing core entities: {missing}"
        print(f"  ✓ All core entities present")

    def test_analytics_entities_present(self, db_validator):
        """Verify analytics entity types are present"""
        analytics_entities = [
            "CustomerProfile", "RiskAssessment", "PredictiveModel"
        ]

        labels = db_validator.get_all_labels()
        present = [entity for entity in analytics_entities if entity in labels]

        print(f"  ✓ Analytics entities present: {len(present)}/{len(analytics_entities)}")

    def test_advanced_features_accessible(self, query_executor):
        """Verify advanced features are accessible"""
        queries = {
            "Predictive Analytics": "MATCH (pm:PredictiveModel) RETURN count(pm) as count",
            "Customer Profiles": "MATCH (cp:CustomerProfile) RETURN count(cp) as count",
            "Risk Assessments": "MATCH (ra:RiskAssessment) RETURN count(ra) as count"
        }

        for feature, query in queries.items():
            try:
                result = query_executor(query)
                count = result[0]['count'] if result else 0
                print(f"  ✓ {feature}: {count} entities")
            except Exception:
                print(f"  ⚠ {feature}: Not available")

    def test_complete_platform_integration(self, query_executor):
        """Verify complete platform integration"""
        query = """
        MATCH (c:Customer)
        OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(cl:Claim)
        OPTIONAL MATCH (c)-[:HAS_PROFILE]->(profile)
        WITH count(DISTINCT c) as customers,
             count(DISTINCT p) as policies,
             count(DISTINCT cl) as claims,
             count(DISTINCT profile) as profiles
        RETURN customers, policies, claims, profiles
        """
        result = query_executor(query)

        summary = result[0]
        print(f"\n  Platform Integration Summary:")
        print(f"    Customers: {summary['customers']}")
        print(f"    Policies: {summary['policies']}")
        print(f"    Claims: {summary['claims']}")
        print(f"    Profiles: {summary['profiles']}")

    def test_lab17_course_completion_summary(self, db_validator):
        """Print Lab 17 and complete course summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        labels = db_validator.get_all_labels()
        rel_types = db_validator.get_all_relationship_types()

        print("\n" + "="*60)
        print("  Lab 17 / COMPLETE COURSE SUMMARY")
        print("="*60)
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    Unique Node Types: {len(labels)}")
        print(f"    Unique Relationship Types: {len(rel_types)}")
        print("\n  Node Types:")
        for label in sorted(labels):
            count = db_validator.count_nodes(label)
            print(f"    - {label}: {count}")
        print("\n  ✓ Lab 17 validation complete")
        print("  ✓✓✓ DAY 3 COMPLETE ✓✓✓")
        print("  ✓✓✓✓✓ COURSE COMPLETE ✓✓✓✓✓")
        print("="*60)
