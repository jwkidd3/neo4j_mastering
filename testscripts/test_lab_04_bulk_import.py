"""
Test Suite for Lab 4: Bulk Data Import & Quality Control
Expected State: 150 nodes, 200 relationships
"""

import pytest


class TestLab04:
    """Test Lab 4: Bulk Data Import & Quality Control"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 3"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 150, f"Expected at least 150 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 150+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 3"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 200, f"Expected at least 200 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 200+)")

    def test_customer_count_after_bulk_import(self, db_validator):
        """Verify bulk customer import added more customers"""
        customer_count = db_validator.count_nodes("Customer")
        assert customer_count >= 13, f"Expected at least 13 customers after bulk import, got {customer_count}"
        print(f"  ✓ Customer count after bulk import: {customer_count}")

    def test_policy_count_after_bulk_import(self, db_validator):
        """Verify bulk policy creation"""
        policy_count = db_validator.count_nodes("Policy")
        assert policy_count >= 13, f"Expected at least 13 policies after bulk import, got {policy_count}"
        print(f"  ✓ Policy count after bulk import: {policy_count}")

    def test_agent_expansion(self, db_validator):
        """Verify additional agents were created"""
        agent_count = db_validator.count_nodes("Agent")
        assert agent_count >= 6, f"Expected at least 6 agents, got {agent_count}"
        print(f"  ✓ Agent count: {agent_count}")

    def test_vehicle_expansion(self, db_validator):
        """Verify vehicles created for new policies"""
        vehicle_count = db_validator.count_nodes("Vehicle")
        assert vehicle_count >= 12, f"Expected at least 12 vehicles, got {vehicle_count}"
        print(f"  ✓ Vehicle count: {vehicle_count}")

    def test_constraints_created(self, query_executor):
        """Verify database constraints were created"""
        query = "SHOW CONSTRAINTS YIELD name, type"
        result = query_executor(query)
        assert len(result) >= 5, f"Expected at least 5 constraints, got {len(result)}"
        print(f"  ✓ Constraints created: {len(result)}")

    def test_customer_number_constraint(self, query_executor):
        """Verify customer_number uniqueness constraint exists"""
        query = "SHOW CONSTRAINTS YIELD name WHERE name CONTAINS 'customer' RETURN count(*) as count"
        result = query_executor(query)
        assert result[0]['count'] >= 1, "Customer uniqueness constraint not found"
        print("  ✓ Customer number constraint exists")

    def test_policy_number_constraint(self, query_executor):
        """Verify policy_number uniqueness constraint exists"""
        query = "SHOW CONSTRAINTS YIELD name WHERE name CONTAINS 'policy' RETURN count(*) as count"
        result = query_executor(query)
        assert result[0]['count'] >= 1, "Policy uniqueness constraint not found"
        print("  ✓ Policy number constraint exists")

    def test_vin_constraint(self, query_executor):
        """Verify VIN uniqueness constraint exists"""
        query = "SHOW CONSTRAINTS YIELD name WHERE name CONTAINS 'vin' RETURN count(*) as count"
        result = query_executor(query)
        assert result[0]['count'] >= 1, "VIN uniqueness constraint not found"
        print("  ✓ VIN constraint exists")

    def test_indexes_created(self, query_executor):
        """Verify performance indexes were created"""
        query = "SHOW INDEXES YIELD name WHERE name CONTAINS 'customer' OR name CONTAINS 'policy' OR name CONTAINS 'claim'"
        result = query_executor(query)
        assert len(result) >= 3, f"Expected at least 3 indexes, got {len(result)}"
        print(f"  ✓ Performance indexes created: {len(result)}")

    def test_bulk_imported_customers_exist(self, query_executor):
        """Verify specific bulk-imported customers exist"""
        customer_numbers = ["CUST-001237", "CUST-001238", "CUST-001239", "CUST-001240"]
        query = """
        MATCH (c:Customer)
        WHERE c.customer_number IN $customer_numbers
        RETURN count(c) as count
        """
        result = query_executor(query, {"customer_numbers": customer_numbers})
        assert result[0]['count'] == len(customer_numbers), f"Not all bulk-imported customers found"
        print(f"  ✓ Bulk-imported customers validated")

    def test_territory_assignment(self, query_executor):
        """Verify customers assigned to agents by territory"""
        query = """
        MATCH (agent:Agent)-[:SERVICES]->(customer:Customer)
        RETURN agent.territory as territory, count(customer) as customer_count
        ORDER BY customer_count DESC
        """
        result = query_executor(query)
        assert len(result) >= 4, "Not enough territory assignments"
        print(f"  ✓ Territory assignments validated: {len(result)} territories")

    def test_agent_workload_distribution(self, query_executor):
        """Verify agents have reasonable customer workloads"""
        query = """
        MATCH (agent:Agent)-[:SERVICES]->(customer:Customer)
        RETURN agent.agent_id as agent_id,
               count(customer) as customer_count
        ORDER BY customer_count DESC
        """
        result = query_executor(query)
        assert len(result) >= 4, "Not enough agents with customers"

        # Verify no agent is overloaded (arbitrary threshold)
        for agent in result:
            assert agent['customer_count'] <= 10, f"Agent {agent['agent_id']} has too many customers"
        print(f"  ✓ Agent workload distribution validated")

    def test_data_quality_no_orphaned_policies(self, query_executor):
        """Verify no policies exist without customer relationships"""
        query = """
        MATCH (p:Policy)
        WHERE NOT EXISTS { MATCH (p)<-[:HOLDS_POLICY]-(:Customer) }
        RETURN count(p) as orphaned_policies
        """
        result = query_executor(query)
        assert result[0]['orphaned_policies'] == 0, f"Found {result[0]['orphaned_policies']} orphaned policies"
        print("  ✓ No orphaned policies found")

    def test_data_quality_customer_credit_scores(self, query_executor):
        """Verify customer credit scores are in valid range"""
        query = """
        MATCH (c:Customer)
        WHERE c.credit_score < 300 OR c.credit_score > 850
        RETURN count(c) as invalid_scores
        """
        result = query_executor(query)
        assert result[0]['invalid_scores'] == 0, f"Found {result[0]['invalid_scores']} invalid credit scores"
        print("  ✓ All credit scores valid (300-850)")

    def test_geographic_distribution(self, query_executor):
        """Verify customers distributed across multiple cities"""
        query = """
        MATCH (c:Customer)
        RETURN c.city as city, count(c) as count
        ORDER BY count DESC
        """
        result = query_executor(query)
        assert len(result) >= 3, "Customers should be in at least 3 cities"
        print(f"  ✓ Geographic distribution validated: {len(result)} cities")

    def test_lab4_summary(self, db_validator):
        """Print Lab 4 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        customers = db_validator.count_nodes("Customer")
        policies = db_validator.count_nodes("Policy")
        agents = db_validator.count_nodes("Agent")
        vehicles = db_validator.count_nodes("Vehicle")

        print("\n  Lab 4 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    Customers: {customers}")
        print(f"    Policies: {policies}")
        print(f"    Agents: {agents}")
        print(f"    Vehicles: {vehicles}")
        print("  ✓ Lab 4 validation complete")
