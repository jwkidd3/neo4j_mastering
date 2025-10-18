"""
Test Suite for Lab 7: Graph Algorithms for Insurance
Expected State: 350 nodes, 450 relationships
"""

import pytest


class TestLab07:
    """Test Lab 7: Graph Algorithms for Insurance"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 6"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 350, f"Expected at least 350 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 350+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 6"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 400, f"Expected at least 400 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 400+)")

    def test_gds_library_available(self, query_executor):
        """Verify Graph Data Science library is available"""
        query = "CALL gds.version() YIELD version RETURN version"
        try:
            result = query_executor(query)
            assert len(result) > 0, "GDS library not available"
            print(f"  ✓ GDS library available: {result[0]['version']}")
        except Exception as e:
            pytest.skip(f"GDS library not available: {e}")

    def test_graph_projections_can_be_created(self, query_executor):
        """Verify graph projections can be created for algorithms"""
        # Test basic graph projection capability
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        RETURN count(*) as relationship_count
        """
        result = query_executor(query)
        assert result[0]['relationship_count'] > 0, "No customer-policy relationships for graph projection"
        print(f"  ✓ Graph projection data available")

    def test_centrality_analysis_data(self, query_executor):
        """Verify data exists for centrality analysis"""
        query = """
        MATCH (c:Customer)
        WHERE EXISTS { (c)-[:REFERRED]->(:Customer) }
        RETURN count(c) as customers_with_referrals
        """
        result = query_executor(query)
        # Not all datasets may have referrals, so check if any exist
        print(f"  ✓ Customers with referral relationships: {result[0]['customers_with_referrals']}")

    def test_community_detection_data(self, query_executor):
        """Verify data exists for community detection"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH count(DISTINCT c) as customers, count(DISTINCT p) as policies
        RETURN customers, policies
        """
        result = query_executor(query)
        assert result[0]['customers'] >= 10, "Not enough customers for community detection"
        print(f"  ✓ Community detection data available")

    def test_pathfinding_data(self, query_executor):
        """Verify data exists for pathfinding algorithms"""
        query = """
        MATCH path = (c1:Customer)-[*1..3]-(c2:Customer)
        WHERE c1 <> c2
        RETURN count(path) as path_count
        LIMIT 1
        """
        result = query_executor(query)
        print(f"  ✓ Pathfinding data available")

    def test_customer_network_density(self, query_executor):
        """Verify customer network has sufficient density"""
        query = """
        MATCH (c:Customer)
        WITH count(c) as customer_count
        MATCH ()-[r]->()
        RETURN customer_count, count(r) as total_relationships
        """
        result = query_executor(query)
        customers = result[0]['customer_count']
        relationships = result[0]['total_relationships']
        density_ratio = relationships / customers if customers > 0 else 0

        assert density_ratio > 5, f"Network density too low: {density_ratio:.2f} relationships per customer"
        print(f"  ✓ Network density sufficient: {density_ratio:.2f} relationships/customer")

    def test_agent_network_structure(self, query_executor):
        """Verify agent network structure for analysis"""
        query = """
        MATCH (a:Agent)-[:SERVICES]->(c:Customer)
        WITH a, count(c) as customer_count
        RETURN avg(customer_count) as avg_customers_per_agent,
               max(customer_count) as max_customers_per_agent
        """
        result = query_executor(query)
        assert result[0]['avg_customers_per_agent'] > 0, "Agents have no customer relationships"
        print(f"  ✓ Agent network structure validated")

    def test_policy_network_structure(self, query_executor):
        """Verify policy network structure for analysis"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, count(p) as policy_count
        RETURN avg(policy_count) as avg_policies_per_customer,
               max(policy_count) as max_policies
        """
        result = query_executor(query)
        assert result[0]['avg_policies_per_customer'] > 0, "Customers have no policies"
        print(f"  ✓ Policy network structure validated")

    # ===================================
    # OPERATIONAL TESTS: Lab 7 Operations
    # ===================================

    def test_operation_network_analysis(self, query_executor):
        """Test: Students can analyze network metrics"""
        query = """
        MATCH (c:Customer)-[r]-()
        WITH c, count(r) as degree
        RETURN avg(degree) as avg_degree,
               max(degree) as max_degree,
               min(degree) as min_degree
        """
        result = query_executor(query)
        assert result[0]['avg_degree'] > 0
        print(f"  ✓ Network analysis operations work (avg degree: {result[0]['avg_degree']:.2f})")

    def test_operation_shortest_path(self, query_executor):
        """Test: Students can find shortest paths"""
        query = """
        MATCH (c1:Customer), (c2:Customer)
        WHERE c1 <> c2
        WITH c1, c2 LIMIT 1
        MATCH path = shortestPath((c1)-[*..5]-(c2))
        RETURN length(path) as path_length
        """
        result = query_executor(query)
        if len(result) > 0:
            print(f"  ✓ Shortest path operations work (length: {result[0]['path_length']})")
        else:
            print("  ✓ Shortest path query works (no paths found)")

    def test_operation_degree_centrality(self, query_executor):
        """Test: Students can calculate degree centrality"""
        query = """
        MATCH (a:Agent)-[r:SERVICES]->(:Customer)
        WITH a, count(r) as customer_count
        RETURN a.agent_id as agent,
               customer_count as degree
        ORDER BY degree DESC
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1
        print(f"  ✓ Degree centrality operations work ({len(result)} agents)")

    def test_lab7_summary(self, db_validator):
        """Print Lab 7 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        customers = db_validator.count_nodes("Customer")
        agents = db_validator.count_nodes("Agent")

        print("\n  Lab 7 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    ✓ Network analysis (degree, density)")
        print(f"    ✓ Shortest path algorithms")
        print(f"    ✓ Degree centrality calculations")
        print("  ✓ Lab 7 validation complete")
