"""
Test Suite for Lab 1: Enterprise Setup & Docker Connection
Expected State: 10 nodes, 15 relationships
"""

import pytest


class TestLab01:
    """Test Lab 1: Enterprise Setup & Docker Connection"""

    def test_database_connection(self, neo4j_session):
        """Verify Neo4j connection to insurance database"""
        result = neo4j_session.run("RETURN 'connection test' as test")
        assert result.single()['test'] == 'connection test'
        print("\n  ✓ Database connection successful")

    def test_node_count(self, db_validator):
        """Verify total node count for Lab 1"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 10, f"Expected at least 10 nodes, got {total_nodes}"
        print(f"  ✓ Total nodes: {total_nodes} (expected: 10+)")

    def test_relationship_count(self, db_validator):
        """Verify total relationship count for Lab 1"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 15, f"Expected at least 15 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 15+)")

    def test_customer_nodes_exist(self, db_validator):
        """Verify Customer nodes were created"""
        customer_count = db_validator.count_nodes("Customer")
        assert customer_count >= 3, f"Expected at least 3 customers, got {customer_count}"
        print(f"  ✓ Customer nodes: {customer_count}")

    def test_specific_customer_sarah(self, db_validator):
        """Verify Sarah Johnson customer exists"""
        sarah = db_validator.node_exists("Customer", {"customer_number": "CUST-001234"})
        assert sarah, "Customer CUST-001234 (Sarah Johnson) not found"
        print("  ✓ Sarah Johnson (CUST-001234) exists")

    def test_specific_customer_michael(self, db_validator):
        """Verify Michael Chen customer exists"""
        michael = db_validator.node_exists("Customer", {"customer_number": "CUST-001235"})
        assert michael, "Customer CUST-001235 (Michael Chen) not found"
        print("  ✓ Michael Chen (CUST-001235) exists")

    def test_specific_customer_emma(self, db_validator):
        """Verify Emma Rodriguez customer exists"""
        emma = db_validator.node_exists("Customer", {"customer_number": "CUST-001236"})
        assert emma, "Customer CUST-001236 (Emma Rodriguez) not found"
        print("  ✓ Emma Rodriguez (CUST-001236) exists")

    def test_policy_nodes_exist(self, db_validator):
        """Verify Policy nodes were created"""
        policy_count = db_validator.count_nodes("Policy")
        assert policy_count >= 3, f"Expected at least 3 policies, got {policy_count}"
        print(f"  ✓ Policy nodes: {policy_count}")

    def test_agent_nodes_exist(self, db_validator):
        """Verify Agent nodes were created"""
        agent_count = db_validator.count_nodes("Agent")
        assert agent_count >= 2, f"Expected at least 2 agents, got {agent_count}"
        print(f"  ✓ Agent nodes: {agent_count}")

    def test_product_nodes_exist(self, db_validator):
        """Verify Product nodes were created"""
        product_count = db_validator.count_nodes("Product")
        assert product_count >= 2, f"Expected at least 2 products, got {product_count}"
        print(f"  ✓ Product nodes: {product_count}")

    def test_holds_policy_relationship(self, db_validator):
        """Verify HOLDS_POLICY relationships exist"""
        holds_policy = db_validator.relationship_exists("Customer", "HOLDS_POLICY", "Policy")
        assert holds_policy, "HOLDS_POLICY relationship not found"
        print("  ✓ HOLDS_POLICY relationships exist")

    def test_services_relationship(self, db_validator):
        """Verify SERVICES relationships exist"""
        services = db_validator.relationship_exists("Agent", "SERVICES", "Customer")
        assert services, "SERVICES relationship not found"
        print("  ✓ SERVICES relationships exist")

    def test_based_on_relationship(self, db_validator):
        """Verify BASED_ON relationships exist"""
        based_on = db_validator.relationship_exists("Policy", "BASED_ON", "Product")
        assert based_on, "BASED_ON relationship not found"
        print("  ✓ BASED_ON relationships exist")

    def test_customer_properties(self, db_validator, query_executor):
        """Verify customer properties are complete"""
        query = """
        MATCH (c:Customer {customer_number: 'CUST-001234'})
        RETURN c.first_name as first_name,
               c.last_name as last_name,
               c.email as email,
               c.credit_score as credit_score,
               c.risk_tier as risk_tier
        """
        result = query_executor(query)
        assert len(result) == 1, "Sarah Johnson not found"

        customer = result[0]
        assert customer['first_name'] == 'Sarah'
        assert customer['last_name'] == 'Johnson'
        assert customer['email'] is not None
        assert customer['credit_score'] == 720
        assert customer['risk_tier'] == 'Standard'
        print("  ✓ Customer properties validated")

    def test_policy_properties(self, db_validator, query_executor):
        """Verify policy properties are complete"""
        query = """
        MATCH (p:Policy {policy_number: 'POL-AUTO-001234'})
        RETURN p.product_type as product_type,
               p.policy_status as status,
               p.annual_premium as premium
        """
        result = query_executor(query)
        assert len(result) == 1, "Policy POL-AUTO-001234 not found"

        policy = result[0]
        assert policy['product_type'] == 'Auto'
        assert policy['status'] == 'Active'
        assert policy['premium'] > 0
        print("  ✓ Policy properties validated")

    def test_lab1_summary(self, db_validator):
        """Print Lab 1 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        labels = db_validator.get_all_labels()

        print("\n  Lab 1 Summary:")
        print(f"    Nodes: {nodes}")
        print(f"    Relationships: {rels}")
        print(f"    Node Types: {', '.join(sorted(labels))}")
        print("  ✓ Lab 1 validation complete")
