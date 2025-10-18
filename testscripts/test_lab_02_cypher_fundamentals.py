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

    def test_lab2_summary(self, db_validator):
        """Print Lab 2 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        branches = db_validator.count_nodes("Branch")
        depts = db_validator.count_nodes("Department")

        print("\n  Lab 2 Summary:")
        print(f"    Total Nodes: {nodes}")
        print(f"    Total Relationships: {rels}")
        print(f"    Branches: {branches}")
        print(f"    Departments: {depts}")
        print("  ✓ Lab 2 validation complete")
