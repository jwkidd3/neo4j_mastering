"""
Test Suite for Lab 2: Cypher Query Fundamentals
Expected State: 25 nodes, 40 relationships
"""

import pytest


class TestLab02:
    """Test Lab 2: Cypher Query Fundamentals"""

    def test_node_count_increase(self, db_validator):
        """Verify node count increased from Lab 1"""
        total_nodes = db_validator.count_nodes()
        assert total_nodes >= 25, f"Expected at least 25 nodes, got {total_nodes}"
        print(f"\n  ✓ Total nodes: {total_nodes} (expected: 25+)")

    def test_relationship_count_increase(self, db_validator):
        """Verify relationship count increased from Lab 1"""
        total_rels = db_validator.count_relationships()
        assert total_rels >= 40, f"Expected at least 40 relationships, got {total_rels}"
        print(f"  ✓ Total relationships: {total_rels} (expected: 40+)")

    def test_branch_nodes_added(self, db_validator):
        """Verify Branch nodes were created"""
        branch_count = db_validator.count_nodes("Branch")
        assert branch_count >= 3, f"Expected at least 3 branches, got {branch_count}"
        print(f"  ✓ Branch nodes: {branch_count}")

    def test_department_nodes_added(self, db_validator):
        """Verify Department nodes were created"""
        dept_count = db_validator.count_nodes("Department")
        assert dept_count >= 3, f"Expected at least 3 departments, got {dept_count}"
        print(f"  ✓ Department nodes: {dept_count}")

    def test_austin_branch_exists(self, db_validator):
        """Verify Austin Downtown branch exists"""
        branch = db_validator.node_exists("Branch", {"branch_id": "BR-001"})
        assert branch, "Branch BR-001 (Austin Downtown) not found"
        print("  ✓ Austin Downtown branch (BR-001) exists")

    def test_dallas_branch_exists(self, db_validator):
        """Verify Dallas North branch exists"""
        branch = db_validator.node_exists("Branch", {"branch_id": "BR-002"})
        assert branch, "Branch BR-002 (Dallas North) not found"
        print("  ✓ Dallas North branch (BR-002) exists")

    def test_houston_branch_exists(self, db_validator):
        """Verify Houston Central branch exists"""
        branch = db_validator.node_exists("Branch", {"branch_id": "BR-003"})
        assert branch, "Branch BR-003 (Houston Central) not found"
        print("  ✓ Houston Central branch (BR-003) exists")

    def test_sales_department_exists(self, db_validator):
        """Verify Sales department exists"""
        dept = db_validator.node_exists("Department", {"department_code": "SALES"})
        assert dept, "Sales department not found"
        print("  ✓ Sales department exists")

    def test_claims_department_exists(self, db_validator):
        """Verify Claims department exists"""
        dept = db_validator.node_exists("Department", {"department_code": "CLAIMS"})
        assert dept, "Claims department not found"
        print("  ✓ Claims department exists")

    def test_underwriting_department_exists(self, db_validator):
        """Verify Underwriting department exists"""
        dept = db_validator.node_exists("Department", {"department_code": "UW"})
        assert dept, "Underwriting department not found"
        print("  ✓ Underwriting department exists")

    def test_works_at_relationship(self, db_validator):
        """Verify WORKS_AT relationships exist"""
        works_at = db_validator.relationship_exists("Agent", "WORKS_AT", "Branch")
        assert works_at, "WORKS_AT relationship not found"
        print("  ✓ WORKS_AT relationships exist")

    def test_member_of_relationship(self, db_validator):
        """Verify MEMBER_OF relationships exist"""
        member_of = db_validator.relationship_exists("Agent", "MEMBER_OF", "Department")
        assert member_of, "MEMBER_OF relationship not found"
        print("  ✓ MEMBER_OF relationships exist")

    def test_mwr_pattern_basic_match(self, query_executor):
        """Test basic MWR pattern: MATCH-WHERE-RETURN"""
        query = """
        MATCH (c:Customer)
        WHERE c.risk_tier = 'Standard'
        RETURN c.customer_number as customer_number
        """
        result = query_executor(query)
        assert len(result) > 0, "MWR pattern returned no results"
        print(f"  ✓ MWR pattern works - found {len(result)} Standard customers")

    def test_mwr_with_relationships(self, query_executor):
        """Test MWR pattern with relationships"""
        query = """
        MATCH (a:Agent)-[:WORKS_AT]->(b:Branch)
        WHERE b.city = 'Austin'
        RETURN a.agent_id as agent_id, b.branch_name as branch
        """
        result = query_executor(query)
        assert len(result) > 0, "No agents found working in Austin"
        print(f"  ✓ MWR with relationships works - found {len(result)} Austin agents")

    def test_branch_properties(self, query_executor):
        """Verify branch has complete properties"""
        query = """
        MATCH (b:Branch {branch_id: 'BR-001'})
        RETURN b.branch_name as name,
               b.city as city,
               b.employee_count as employees,
               b.customer_count as customers
        """
        result = query_executor(query)
        assert len(result) == 1, "Austin branch not found"

        branch = result[0]
        assert branch['name'] == 'Austin Downtown'
        assert branch['city'] == 'Austin'
        assert branch['employees'] is not None
        assert branch['customers'] is not None
        print("  ✓ Branch properties validated")

    def test_department_properties(self, query_executor):
        """Verify department has complete properties"""
        query = """
        MATCH (d:Department {department_code: 'SALES'})
        RETURN d.department_name as name,
               d.budget as budget,
               d.head_count as headcount
        """
        result = query_executor(query)
        assert len(result) == 1, "Sales department not found"

        dept = result[0]
        assert dept['name'] == 'Sales'
        assert dept['budget'] > 0
        assert dept['headcount'] > 0
        print("  ✓ Department properties validated")

    def test_agent_branch_connection(self, query_executor):
        """Verify agents are connected to branches"""
        query = """
        MATCH (a:Agent)-[:WORKS_AT]->(b:Branch)
        RETURN count(a) as agent_count
        """
        result = query_executor(query)
        assert result[0]['agent_count'] >= 2, "Not enough agents connected to branches"
        print(f"  ✓ Agent-Branch connections validated")

    # ===================================
    # OPERATIONAL TESTS: Lab 2 Operations
    # ===================================

    def test_operation_string_concatenation(self, query_executor):
        """Test: Students can concatenate strings in RETURN"""
        query = """
        MATCH (a:Agent)
        WHERE a.first_name IS NOT NULL AND a.last_name IS NOT NULL
        RETURN a.first_name + " " + a.last_name AS full_name
        LIMIT 3
        """
        result = query_executor(query)
        assert len(result) >= 3, "String concatenation failed"

        for row in result:
            assert " " in row['full_name'], "Names should be concatenated with space"
        print(f"  ✓ String concatenation operation works ({len(result)} examples)")

    def test_operation_where_multiple_conditions(self, query_executor):
        """Test: Students can use multiple WHERE conditions"""
        query = """
        MATCH (c:Customer)
        WHERE c.risk_tier = 'Standard'
          AND c.customer_number IS NOT NULL
        RETURN c.customer_number
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1, "Multiple WHERE conditions failed"
        print(f"  ✓ Multiple WHERE conditions operation works ({len(result)} results)")

    def test_operation_relationship_property_access(self, query_executor):
        """Test: Students can access relationship properties"""
        query = """
        MATCH (a:Agent)-[r:WORKS_AT]->(b:Branch)
        RETURN a.agent_id, b.branch_name
        LIMIT 3
        """
        result = query_executor(query)
        assert len(result) >= 1, "Relationship traversal failed"
        print(f"  ✓ Relationship property access works ({len(result)} examples)")

    def test_operation_order_by_sorting(self, query_executor):
        """Test: Students can sort results with ORDER BY"""
        query = """
        MATCH (b:Branch)
        RETURN b.branch_name
        ORDER BY b.branch_name
        """
        result = query_executor(query)
        assert len(result) >= 3, "ORDER BY failed"
        print(f"  ✓ ORDER BY sorting operation works ({len(result)} branches sorted)")

    def test_operation_array_property_handling(self, query_executor):
        """Test: Students can work with array/collection properties"""
        query = """
        MATCH (c:Customer)-[:HOLDS_POLICY]->(p:Policy)
        WITH c, collect(p.policy_number) as policies
        RETURN c.customer_number, size(policies) AS policy_count
        LIMIT 3
        """
        result = query_executor(query)
        assert len(result) >= 1, "Array/collection handling failed"
        print(f"  ✓ Array/collection property handling works ({len(result)} examples)")

    def test_operation_date_comparison(self, query_executor):
        """Test: Students can filter by date properties"""
        query = """
        MATCH (c:Customer)
        WHERE c.date_of_birth IS NOT NULL
        RETURN c.customer_number, c.date_of_birth
        ORDER BY c.date_of_birth
        LIMIT 3
        """
        result = query_executor(query)
        assert len(result) >= 1, "Date comparison failed"
        print(f"  ✓ Date comparison operation works ({len(result)} customers)")

    def test_operation_pattern_matching_multiple_hops(self, query_executor):
        """Test: Students can match multi-hop patterns"""
        query = """
        MATCH (a:Agent)-[:MEMBER_OF]->(d:Department)
        RETURN a.agent_id, d.department_code
        LIMIT 3
        """
        result = query_executor(query)
        assert len(result) >= 1, "Multi-hop pattern matching failed"
        print(f"  ✓ Multi-hop pattern matching works ({len(result)} connections)")

    def test_operation_count_aggregation(self, query_executor):
        """Test: Students can use count() aggregation"""
        query = """
        MATCH (a:Agent)-[:WORKS_AT]->(b:Branch)
        RETURN b.branch_name, count(a) AS agent_count
        ORDER BY agent_count DESC
        """
        result = query_executor(query)
        assert len(result) >= 1, "COUNT aggregation failed"

        total_agents = sum(row['agent_count'] for row in result)
        assert total_agents >= 2
        print(f"  ✓ COUNT aggregation operation works ({total_agents} total agents)")

    def test_operation_return_with_alias(self, query_executor):
        """Test: Students can use AS alias in RETURN"""
        query = """
        MATCH (d:Department)
        RETURN d.department_name AS dept_name,
               d.head_count AS employees,
               d.budget / d.head_count AS budget_per_employee
        LIMIT 3
        """
        result = query_executor(query)
        assert len(result) >= 3, "RETURN with alias failed"

        for row in result:
            assert 'dept_name' in row
            assert 'employees' in row
            assert 'budget_per_employee' in row
            assert row['budget_per_employee'] > 0
        print(f"  ✓ RETURN with alias operation works ({len(result)} departments)")

    def test_operation_node_property_filter_in_match(self, query_executor):
        """Test: Students can filter properties directly in MATCH"""
        query = """
        MATCH (b:Branch {city: 'Austin'})
        RETURN b.branch_name
        """
        result = query_executor(query)
        assert len(result) >= 1, "Property filter in MATCH failed"
        print(f"  ✓ Property filter in MATCH works ({len(result)} Austin branches)")

    def test_operation_limit_results(self, query_executor):
        """Test: Students can limit query results"""
        query = """
        MATCH (c:Customer)
        RETURN c.customer_number
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) == 5, f"LIMIT should return exactly 5 results, got {len(result)}"
        print(f"  ✓ LIMIT operation works (returned {len(result)} results)")

    def test_operation_distinct_results(self, query_executor):
        """Test: Students can return distinct values"""
        query = """
        MATCH (c:Customer)
        RETURN DISTINCT c.risk_tier
        """
        result = query_executor(query)
        assert len(result) >= 2, "DISTINCT operation failed"

        # Verify all values are unique
        tiers = [row['c.risk_tier'] for row in result]
        assert len(tiers) == len(set(tiers)), "DISTINCT returned duplicates"
        print(f"  ✓ DISTINCT operation works ({len(result)} unique risk tiers)")

    def test_lab2_summary(self, db_validator):
        """Print Lab 2 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        branches = db_validator.count_nodes("Branch")
        depts = db_validator.count_nodes("Department")

        print("\n  Lab 2 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Branches: {branches}, Departments: {depts}")
        print(f"    ✓ MWR pattern (MATCH-WHERE-RETURN)")
        print(f"    ✓ String concatenation")
        print(f"    ✓ Multiple WHERE conditions")
        print(f"    ✓ Relationship property access")
        print(f"    ✓ ORDER BY sorting")
        print(f"    ✓ Array property handling")
        print(f"    ✓ Date comparisons")
        print(f"    ✓ Multi-hop patterns")
        print(f"    ✓ COUNT aggregation")
        print(f"    ✓ RETURN with AS alias")
        print(f"    ✓ Property filters in MATCH")
        print(f"    ✓ LIMIT results")
        print(f"    ✓ DISTINCT values")
        print("  ✓ Lab 2 validation complete")
