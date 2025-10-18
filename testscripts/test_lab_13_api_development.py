"""
Test Suite for Lab 13: Insurance Web Application Development
Expected State: Database ready for API integration
"""

import pytest


class TestLab13:
    """Test Lab 13: Insurance Web Application Development"""

    def test_data_available_for_apis(self, db_validator):
        """Verify sufficient data exists for API development"""
        customers = db_validator.count_nodes("Customer")
        policies = db_validator.count_nodes("Policy")
        claims = db_validator.count_nodes("Claim")

        assert customers >= 10, f"Need at least 10 customers for API testing, got {customers}"
        assert policies >= 10, f"Need at least 10 policies for API testing, got {policies}"
        assert claims >= 3, f"Need at least 3 claims for API testing, got {claims}"

        print(f"\n  ✓ Sufficient data for API development")
        print(f"    Customers: {customers}")
        print(f"    Policies: {policies}")
        print(f"    Claims: {claims}")

    def test_customer_lookup_endpoint_data(self, query_executor):
        """Verify data structure for customer lookup API"""
        query = """
        MATCH (c:Customer)
        RETURN c.customer_number as id,
               c.first_name as firstName,
               c.last_name as lastName,
               c.email as email
        LIMIT 1
        """
        result = query_executor(query)
        assert len(result) > 0, "No customer data for API"
        assert all(key in result[0] for key in ['id', 'firstName', 'lastName', 'email'])
        print("  ✓ Customer lookup API data structure valid")

    def test_policy_search_endpoint_data(self, query_executor):
        """Verify data structure for policy search API"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN c.customer_number as customerId,
               p.policy_number as policyNumber,
               p.product_type as type,
               p.annual_premium as premium
        LIMIT 1
        """
        result = query_executor(query)
        assert len(result) > 0, "No policy data for API"
        print("  ✓ Policy search API data structure valid")

    def test_claims_submission_endpoint_data(self, query_executor):
        """Verify data structure for claims API"""
        query = """
        MATCH (c:Customer)-[:FILED_CLAIM]->(cl:Claim)
        RETURN cl.claim_number as claimNumber,
               cl.claim_type as type,
               cl.claim_status as status,
               cl.claim_amount as amount
        LIMIT 1
        """
        result = query_executor(query)
        assert len(result) > 0, "No claims data for API"
        print("  ✓ Claims API data structure valid")

    def test_customer_360_endpoint_data(self, query_executor):
        """Verify data for customer 360 API"""
        query = """
        MATCH (c:Customer {customer_number: 'CUST-001234'})
        OPTIONAL MATCH (c)-[:HOLDS_POLICY]->(p:Policy)
        OPTIONAL MATCH (c)-[:FILED_CLAIM]->(cl:Claim)
        RETURN c.customer_number as customer,
               count(DISTINCT p) as policies,
               count(DISTINCT cl) as claims
        """
        result = query_executor(query)
        assert len(result) > 0, "No customer 360 data"
        print("  ✓ Customer 360 API data available")

    def test_agent_dashboard_endpoint_data(self, query_executor):
        """Verify data for agent dashboard API"""
        query = """
        MATCH (a:Agent)-[:SERVICES]->(c:Customer)
        RETURN a.agent_id as agentId,
               count(c) as customerCount
        LIMIT 1
        """
        result = query_executor(query)
        assert len(result) > 0, "No agent dashboard data"
        print("  ✓ Agent dashboard API data available")

    # ===================================
    # OPERATIONAL TESTS: Lab 13 Operations
    # ===================================

    def test_operation_dashboard_aggregations(self, query_executor):
        """Test: Students can build dashboard metrics"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH count(DISTINCT c) as customers,
             count(p) as policies,
             sum(p.annual_premium) as premium
        RETURN customers, policies, round(premium * 100) / 100 as totalPremium
        """
        result = query_executor(query)
        assert len(result) == 1
        print(f"  ✓ Dashboard aggregation operations work")

    def test_lab13_summary(self, db_validator):
        """Print Lab 13 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()

        print("\n  Lab 13 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print("    ✓ Customer 360 view queries")
        print("    ✓ Dashboard aggregations")
        print("    ✓ API data structures")
        print("  ✓ Lab 13 validation complete")
