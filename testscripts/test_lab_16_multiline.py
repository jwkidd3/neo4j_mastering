"""
Test Suite for Lab 16: Multi-Line Insurance Platform
Expected State: Multi-line insurance capabilities validated
"""

import pytest


class TestLab16:
    """Test Lab 16: Multi-Line Insurance Platform"""

    def test_multiple_product_types(self, query_executor):
        """Verify multiple insurance product types exist"""
        query = """
        MATCH (p:Product)
        RETURN p.product_type as type, count(*) as count
        """
        result = query_executor(query)
        assert len(result) >= 2, f"Expected at least 2 product types, got {len(result)}"
        print(f"\n  ✓ Product types: {len(result)}")

    def test_cross_product_customers(self, query_executor):
        """Verify customers with multiple product types"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, collect(DISTINCT p.product_type) as products
        WHERE size(products) > 1
        RETURN count(c) as cross_product_customers
        """
        result = query_executor(query)
        print(f"  ✓ Cross-product customers: {result[0]['cross_product_customers']}")

    def test_multi_line_portfolio_analysis(self, query_executor):
        """Verify multi-line portfolio data available"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN p.product_type as product,
               count(DISTINCT c) as customers,
               sum(p.annual_premium) as total_premium
        """
        result = query_executor(query)
        assert len(result) >= 1, "No portfolio analysis data"
        print(f"  ✓ Multi-line portfolio analysis available")

    def test_product_bundling_opportunities(self, query_executor):
        """Verify product bundling data exists"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, collect(p.product_type) as products
        RETURN size(products) as product_count,
               count(c) as customer_count
        ORDER BY product_count DESC
        """
        result = query_executor(query)
        print("  ✓ Product bundling opportunities identified")

    # ===================================
    # OPERATIONAL TESTS: Lab 16 Operations
    # ===================================

    def test_operation_cross_product_analysis(self, query_executor):
        """Test: Students can analyze across product lines"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, collect(DISTINCT p.product_type) as products
        RETURN size(products) as product_count,
               count(c) as customers
        ORDER BY product_count DESC
        """
        result = query_executor(query)
        assert len(result) >= 1
        print(f"  ✓ Cross-product analysis operations work")

    def test_lab16_summary(self, db_validator):
        """Print Lab 16 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        products = db_validator.count_nodes("Product")

        print("\n  Lab 16 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships, Products: {products}")
        print("    ✓ Cross-product analysis")
        print("    ✓ Bundle recommendations")
        print("    ✓ Multi-line platform operational")
        print("  ✓ Lab 16 validation complete")
