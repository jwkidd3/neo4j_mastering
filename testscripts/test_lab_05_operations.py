"""
Operational Test Suite for Lab 5: Advanced Analytics Foundation
Tests that validate students can EXECUTE all operations taught in the lab
"""

import pytest


class TestLab05Operations:
    """Test Lab 5: All Student Operations Coverage"""

    # ===================================
    # PART 1: RISK ASSESSMENT OPERATIONS
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

        # Verify risk scores are reasonable (should be based on tier + credit)
        for row in result:
            assert row['calculated_score'] is not None
            assert row['calculated_score'] > 0
        print(f"  ✓ Risk score calculation operation works ({len(result)} examples)")

    def test_operation_territory_risk_aggregation(self, query_executor):
        """Test: Students can aggregate risk by territory"""
        query = """
        MATCH (c:Customer)-[:HAS_RISK_ASSESSMENT]->(r:RiskAssessment)
        WITH c.city AS territory,
             count(c) AS customer_count,
             avg(r.risk_score) AS avg_risk_score,
             avg(c.credit_score) AS avg_credit_score
        WHERE customer_count > 0
        RETURN territory,
               customer_count,
               round(avg_risk_score * 100) / 100 as avg_risk,
               round(avg_credit_score * 100) / 100 as avg_credit
        ORDER BY avg_risk_score DESC
        """
        result = query_executor(query)
        assert len(result) >= 1, "Territory aggregation query failed"

        for row in result:
            assert row['customer_count'] > 0
            assert row['avg_risk'] is not None
            assert row['avg_credit'] is not None
        print(f"  ✓ Territory risk aggregation operation works ({len(result)} territories)")

    def test_operation_policy_risk_correlation(self, query_executor):
        """Test: Students can correlate risk with policy types"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        MATCH (c)-[:HAS_RISK_ASSESSMENT]->(r:RiskAssessment)
        WITH p.product_type AS product_type,
             c.risk_tier AS risk_tier,
             avg(r.risk_score) AS avg_risk_score,
             avg(p.annual_premium) AS avg_premium,
             count(p) AS policy_count
        WHERE policy_count > 0
        RETURN product_type,
               risk_tier,
               policy_count,
               round(avg_risk_score * 100) / 100 AS avg_risk,
               round(avg_premium * 100) / 100 AS avg_premium
        ORDER BY product_type, avg_risk_score DESC
        LIMIT 10
        """
        result = query_executor(query)
        assert len(result) >= 1, "Policy-risk correlation query failed"

        for row in result:
            assert row['policy_count'] > 0
            assert row['avg_risk'] is not None
            assert row['avg_premium'] > 0
        print(f"  ✓ Policy-risk correlation operation works ({len(result)} combinations)")

    # ===================================
    # PART 2: CUSTOMER 360 OPERATIONS
    # ===================================

    def test_operation_optional_match_pattern(self, query_executor):
        """Test: Students can use OPTIONAL MATCH for incomplete data"""
        query = """
        MATCH (c:Customer)
        OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(claim:Claim)
        OPTIONAL MATCH (c)-[:MADE_PAYMENT]->(payment:Payment)
        RETURN c.customer_number as customer,
               count(DISTINCT p) AS policy_count,
               count(DISTINCT claim) AS claim_count,
               count(DISTINCT payment) AS payment_count
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "OPTIONAL MATCH pattern failed"

        # Some customers may have 0 claims or payments - that's OK with OPTIONAL
        for row in result:
            assert 'customer' in row
            assert row['policy_count'] >= 0  # May be 0 with OPTIONAL MATCH
        print(f"  ✓ OPTIONAL MATCH operation works ({len(result)} customers)")

    def test_operation_duration_calculations(self, query_executor):
        """Test: Students can calculate durations and ages"""
        query = """
        MATCH (c:Customer)
        WHERE c.date_of_birth IS NOT NULL AND c.customer_since IS NOT NULL
        WITH c,
             duration.between(c.date_of_birth, date()).years AS age,
             duration.between(c.customer_since, date()).years AS tenure_years
        RETURN c.customer_number as customer,
               age,
               tenure_years
        WHERE age > 0 AND tenure_years >= 0
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "Duration calculation failed"

        for row in result:
            assert row['age'] > 0 and row['age'] < 120  # Reasonable age
            assert row['tenure_years'] >= 0
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

        segments = [row['value_segment'] for row in result]
        assert len(segments) > 0
        print(f"  ✓ CASE segmentation operation works ({len(result)} segments)")

    def test_operation_ratio_calculations(self, query_executor):
        """Test: Students can calculate ratios and derived metrics"""
        query = """
        MATCH (cp:CustomerProfile)
        WHERE cp.total_annual_premium IS NOT NULL
          AND cp.total_claim_amount IS NOT NULL
          AND cp.total_annual_premium > 0
        WITH cp,
             cp.total_claim_amount / cp.total_annual_premium AS claims_ratio,
             CASE WHEN cp.policy_count > 0
                  THEN cp.total_annual_premium / cp.policy_count
                  ELSE 0.0
             END AS avg_policy_premium
        WHERE claims_ratio >= 0
        RETURN cp.customer_id as customer,
               round(claims_ratio * 100) / 100 as claims_ratio,
               round(avg_policy_premium * 100) / 100 as avg_premium
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1, "Ratio calculation failed"

        for row in result:
            assert row['claims_ratio'] >= 0
            assert row['avg_premium'] >= 0
        print(f"  ✓ Ratio calculation operation works ({len(result)} examples)")

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
            # total_claim_amount should never be null thanks to COALESCE
            assert row['total_claim_amount'] is not None
            assert row['total_claim_amount'] >= 0
        print(f"  ✓ COALESCE null handling works ({len(result)} examples)")

    # ===================================
    # PART 3: BUSINESS INTELLIGENCE OPERATIONS
    # ===================================

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
        assert row['total_premium'] > 0
        assert row['avg_premium'] > 0
        assert row['min_premium'] > 0
        assert row['max_premium'] >= row['min_premium']
        print(f"  ✓ Aggregate functions operation works")

    def test_operation_grouping_with_having(self, query_executor):
        """Test: Students can group and filter with aggregates"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, count(p) AS policy_count, sum(p.annual_premium) AS total_premium
        WHERE policy_count > 0
        RETURN c.risk_tier as risk_tier,
               count(c) AS customer_count,
               avg(policy_count) AS avg_policies_per_customer,
               sum(total_premium) AS tier_total_premium
        ORDER BY tier_total_premium DESC
        """
        result = query_executor(query)
        assert len(result) >= 1, "GROUP BY with filtering failed"

        for row in result:
            assert row['customer_count'] > 0
            assert row['tier_total_premium'] > 0
        print(f"  ✓ Grouping with filtering operation works ({len(result)} groups)")

    def test_operation_cross_sell_identification(self, query_executor):
        """Test: Students can identify cross-sell opportunities"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, collect(DISTINCT p.product_type) AS held_products, count(p) AS policy_count
        WHERE policy_count > 0 AND size(held_products) < 3
        RETURN c.customer_number as customer,
               policy_count,
               held_products,
               CASE
                 WHEN NOT "Home Insurance" IN held_products THEN "Home Insurance"
                 WHEN NOT "Auto Insurance" IN held_products THEN "Auto Insurance"
                 WHEN NOT "Life Insurance" IN held_products THEN "Life Insurance"
                 ELSE "Umbrella Policy"
               END AS recommended_product
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1, "Cross-sell identification failed"

        for row in result:
            assert row['policy_count'] > 0
            assert len(row['held_products']) > 0
            assert row['recommended_product'] is not None
        print(f"  ✓ Cross-sell identification operation works ({len(result)} opportunities)")

    # ===================================
    # PART 4: ADVANCED ANALYTICS OPERATIONS
    # ===================================

    def test_operation_collect_aggregation(self, query_executor):
        """Test: Students can use collect() to aggregate into lists"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.customer_number as customer,
               collect(p.product_type) AS products,
               collect(p.annual_premium) AS premiums,
               size(collect(p)) AS policy_count
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "COLLECT aggregation failed"

        for row in result:
            assert len(row['products']) > 0
            assert len(row['premiums']) > 0
            assert row['policy_count'] == len(row['products'])
        print(f"  ✓ COLLECT aggregation operation works ({len(result)} examples)")

    def test_operation_pattern_matching_chains(self, query_executor):
        """Test: Students can chain multiple relationship patterns"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)<-[:FILED_CLAIM_FOR]-(claim:Claim)
        RETURN c.customer_number as customer,
               p.policy_number as policy,
               count(claim) AS claims_on_policy
        ORDER BY claims_on_policy DESC
        LIMIT 5
        """
        result = query_executor(query)
        # May be 0 if no claims filed
        assert isinstance(result, list), "Pattern chain query failed"
        print(f"  ✓ Pattern matching chains operation works ({len(result)} results)")

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
            # total_policy_records should be >= unique_policies
            assert row['total_policy_records'] >= row['unique_policies']
        print(f"  ✓ DISTINCT counting operation works ({len(result)} agents)")

    def test_operation_conditional_aggregation(self, query_executor):
        """Test: Students can conditionally aggregate data"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(claim:Claim)
        WHERE claim.claim_status = "Approved"
        RETURN c.customer_number as customer,
               count(p) AS total_policies,
               count(claim) AS approved_claims,
               CASE
                 WHEN count(claim) = 0 THEN "No Claims"
                 WHEN count(claim) <= count(p) THEN "Normal"
                 ELSE "High Claims"
               END AS claims_profile
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 5, "Conditional aggregation failed"

        for row in result:
            assert row['total_policies'] >= 0
            assert row['approved_claims'] >= 0
            assert row['claims_profile'] in ["No Claims", "Normal", "High Claims"]
        print(f"  ✓ Conditional aggregation operation works ({len(result)} examples)")

    def test_lab5_operations_summary(self, db_validator):
        """Verify all Lab 5 operations are executable"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()

        print("\n  Lab 5 Operations Coverage Summary:")
        print(f"    Data foundation: {nodes} nodes, {rels} relationships")
        print(f"    ✓ Risk score calculations")
        print(f"    ✓ Territory aggregations")
        print(f"    ✓ OPTIONAL MATCH patterns")
        print(f"    ✓ Duration calculations")
        print(f"    ✓ CASE segmentation")
        print(f"    ✓ Ratio/percentage calculations")
        print(f"    ✓ COALESCE null handling")
        print(f"    ✓ Aggregate functions (count, sum, avg, min, max)")
        print(f"    ✓ COLLECT aggregations")
        print(f"    ✓ Pattern matching chains")
        print(f"    ✓ DISTINCT counting")
        print(f"    ✓ Conditional aggregations")
        print("  ✓ All Lab 5 operations validated")
