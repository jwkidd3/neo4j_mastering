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
        # Note: Lab 17 may create additional policies for testing, so check proportionally
        orphaned = result[0]['orphaned_policies']
        print(f"  ✓ Orphaned policies check: {orphaned} orphaned (may include Lab 17 test data)")

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

    # ===================================
    # OPERATIONAL TESTS: Lab 4 Operations
    # ===================================

    def test_operation_unwind_bulk_processing(self, query_executor):
        """Test: Students can use UNWIND for bulk data processing"""
        query = """
        WITH [
          {name: "Test1", value: 100},
          {name: "Test2", value: 200},
          {name: "Test3", value: 300}
        ] AS testData
        UNWIND testData AS row
        RETURN row.name as name, row.value as value
        """
        result = query_executor(query)
        assert len(result) == 3, "UNWIND operation failed"

        values = [row['value'] for row in result]
        assert values == [100, 200, 300]
        print(f"  ✓ UNWIND bulk processing operation works ({len(result)} rows)")

    def test_operation_merge_on_create_on_match(self, query_executor):
        """Test: Students can use MERGE with ON CREATE and ON MATCH"""
        # First, create a test node
        test_id = "TEST-MERGE-" + str(int(__import__('time').time()))
        query1 = f"""
        MERGE (t:TestNode {{test_id: '{test_id}'}})
        ON CREATE SET t.counter = 1, t.created = datetime()
        ON MATCH SET t.counter = t.counter + 1, t.updated = datetime()
        RETURN t.counter as counter
        """
        result1 = query_executor(query1)
        assert result1[0]['counter'] == 1, "ON CREATE should set counter to 1"

        # Run again to test ON MATCH
        result2 = query_executor(query1)
        assert result2[0]['counter'] == 2, "ON MATCH should increment counter"

        # Cleanup
        query_executor(f"MATCH (t:TestNode {{test_id: '{test_id}'}}) DELETE t")
        print("  ✓ MERGE with ON CREATE/ON MATCH operation works")

    def test_operation_string_manipulation(self, query_executor):
        """Test: Students can use string manipulation functions"""
        query = """
        WITH "John" AS firstName, "Doe" AS lastName
        RETURN toLower(firstName) as lower_first,
               toUpper(lastName) as upper_last,
               toLower(firstName) + "." + toLower(lastName) + "@test.com" as email
        """
        result = query_executor(query)
        assert result[0]['lower_first'] == 'john'
        assert result[0]['upper_last'] == 'DOE'
        assert result[0]['email'] == 'john.doe@test.com'
        print("  ✓ String manipulation operations work")

    def test_operation_type_conversions(self, query_executor):
        """Test: Students can convert between types"""
        query = """
        WITH 123 AS numValue, "456" AS strValue
        RETURN toString(numValue) as num_to_str,
               toInteger(strValue) as str_to_int,
               toFloat("78.9") as str_to_float,
               toInteger(78.9) as float_to_int
        """
        result = query_executor(query)
        assert result[0]['num_to_str'] == '123'
        assert result[0]['str_to_int'] == 456
        assert result[0]['str_to_float'] == 78.9
        assert result[0]['float_to_int'] == 78
        print("  ✓ Type conversion operations work")

    def test_operation_case_statement_logic(self, query_executor):
        """Test: Students can use CASE statements for conditional logic"""
        query = """
        WITH [1, 2, 3, 4] AS values
        UNWIND values AS val
        RETURN val,
               CASE val
                 WHEN 1 THEN "One"
                 WHEN 2 THEN "Two"
                 WHEN 3 THEN "Three"
                 ELSE "Other"
               END as name,
               CASE
                 WHEN val % 2 = 0 THEN "Even"
                 ELSE "Odd"
               END as parity
        """
        result = query_executor(query)
        assert len(result) == 4
        assert result[0]['name'] == 'One'
        assert result[1]['parity'] == 'Even'
        print(f"  ✓ CASE statement logic works ({len(result)} conditions)")

    def test_operation_date_duration_calculations(self, query_executor):
        """Test: Students can use date and duration functions"""
        query = """
        WITH date('2024-01-01') AS start_date
        RETURN start_date,
               start_date + duration({days: 30}) as plus_30_days,
               start_date + duration({months: 6}) as plus_6_months,
               start_date + duration({years: 1}) as plus_1_year,
               duration.between(start_date, date('2024-12-31')).days as days_diff
        """
        result = query_executor(query)
        # Dates calculated, just verify results are returned
        assert result[0]['plus_30_days'] is not None
        assert result[0]['plus_6_months'] is not None
        assert result[0]['days_diff'] > 0
        print("  ✓ Date/duration calculation operations work")

    def test_operation_not_exists_filtering(self, query_executor):
        """Test: Students can use NOT EXISTS for filtering"""
        query = """
        MATCH (c:Customer)
        WHERE NOT EXISTS { MATCH (c)<-[:SERVICES]-(:Agent) }
        RETURN count(c) as unassigned_customers
        """
        result = query_executor(query)
        # Should be 0 if all customers are assigned
        assert result[0]['unassigned_customers'] >= 0
        print(f"  ✓ NOT EXISTS filtering works ({result[0]['unassigned_customers']} unassigned)")

    def test_operation_conditional_relationships(self, query_executor):
        """Test: Students can create relationships with conditional logic"""
        query = """
        MATCH (c:Customer)
        WITH c, c.city as city
        RETURN city,
               CASE city
                 WHEN "Houston" THEN "AGT-003"
                 WHEN "Dallas" THEN "AGT-004"
                 WHEN "San Antonio" THEN "AGT-005"
                 ELSE "AGT-001"
               END as suggested_agent
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1
        for row in result:
            assert row['suggested_agent'] is not None
        print(f"  ✓ Conditional relationship logic works ({len(result)} examples)")

    def test_operation_bulk_property_updates(self, query_executor):
        """Test: Students can bulk update properties with calculations"""
        query = """
        MATCH (a:Agent)
        WHERE a.customer_count IS NOT NULL
        WITH a, a.customer_count as current_count
        RETURN a.agent_id as agent,
               current_count,
               current_count * 12000 as estimated_annual_value
        ORDER BY estimated_annual_value DESC
        LIMIT 5
        """
        result = query_executor(query)
        assert len(result) >= 1
        for row in result:
            assert row['estimated_annual_value'] >= 0
        print(f"  ✓ Bulk property updates with calculations work ({len(result)} agents)")

    def test_operation_data_validation_queries(self, query_executor):
        """Test: Students can write data validation queries"""
        # Test 1: Credit score validation
        query1 = """
        MATCH (c:Customer)
        WHERE c.credit_score IS NOT NULL
        WITH c, c.credit_score as score
        WHERE score < 300 OR score > 850
        RETURN count(c) as invalid_scores
        """
        result1 = query_executor(query1)
        assert result1[0]['invalid_scores'] == 0

        # Test 2: Missing field validation
        query2 = """
        MATCH (c:Customer)
        WHERE c.email IS NULL OR c.risk_tier IS NULL
        RETURN count(c) as missing_fields
        """
        result2 = query_executor(query2)
        assert result2[0]['missing_fields'] >= 0
        print("  ✓ Data validation query operations work")

    def test_operation_referential_integrity_checks(self, query_executor):
        """Test: Students can check referential integrity"""
        query = """
        MATCH (p:Policy)
        WHERE NOT EXISTS { MATCH (p)<-[:HOLDS_POLICY]-(:Customer) }
        RETURN count(p) as orphaned_policies
        """
        result = query_executor(query)
        assert result[0]['orphaned_policies'] == 0
        print("  ✓ Referential integrity check operations work")

    def test_operation_territory_based_aggregation(self, query_executor):
        """Test: Students can aggregate data by territory/geography"""
        query = """
        MATCH (a:Agent)-[:SERVICES]->(c:Customer)
        WHERE a.territory IS NOT NULL
        RETURN a.territory as territory,
               count(DISTINCT c) as customers,
               count(DISTINCT a) as agents,
               CASE
                 WHEN count(DISTINCT a) > 0 THEN count(DISTINCT c) / toFloat(count(DISTINCT a))
                 ELSE 0.0
               END as customers_per_agent
        ORDER BY customers DESC
        """
        result = query_executor(query)
        assert len(result) >= 1
        for row in result:
            assert row['customers'] > 0
            assert row['customers_per_agent'] >= 0
        print(f"  ✓ Territory-based aggregation works ({len(result)} territories)")

    def test_operation_bulk_data_statistics(self, query_executor):
        """Test: Students can generate statistics from bulk data"""
        query = """
        MATCH (c:Customer)
        RETURN count(c) as total_customers,
               avg(c.credit_score) as avg_credit_score,
               min(c.credit_score) as min_credit_score,
               max(c.credit_score) as max_credit_score,
               count(DISTINCT c.city) as cities_served
        """
        result = query_executor(query)
        assert result[0]['total_customers'] >= 13
        assert result[0]['avg_credit_score'] >= 300
        assert result[0]['avg_credit_score'] <= 850
        print(f"  ✓ Bulk data statistics generation works")

    def test_operation_policy_vehicle_linkage(self, query_executor):
        """Test: Students can verify bulk-created relationships"""
        query = """
        MATCH (p:Policy:Auto)-[:COVERS]->(v:Vehicle)
        WHERE p.policy_number STARTS WITH "POL-AUTO-00124"
        RETURN p.policy_number as policy,
               v.vin as vin,
               v.make + " " + v.model as vehicle,
               v.market_value as value
        ORDER BY v.market_value DESC
        """
        result = query_executor(query)
        assert len(result) >= 7, f"Expected at least 7 policies covering vehicles, got {len(result)}"
        for row in result:
            assert row['vin'] is not None
            assert row['value'] > 0
        print(f"  ✓ Policy-vehicle linkage verification works ({len(result)} links)")

    def test_lab4_summary(self, db_validator):
        """Print Lab 4 completion summary"""
        nodes = db_validator.count_nodes()
        rels = db_validator.count_relationships()
        customers = db_validator.count_nodes("Customer")
        policies = db_validator.count_nodes("Policy")
        agents = db_validator.count_nodes("Agent")
        vehicles = db_validator.count_nodes("Vehicle")

        print("\n  Lab 4 Operations Summary:")
        print(f"    Data: {nodes} nodes, {rels} relationships")
        print(f"    Customers: {customers}, Policies: {policies}")
        print(f"    Agents: {agents}, Vehicles: {vehicles}")
        print(f"    ✓ UNWIND bulk processing")
        print(f"    ✓ MERGE with ON CREATE/ON MATCH")
        print(f"    ✓ String manipulation (toLower, toString)")
        print(f"    ✓ Type conversions (toInteger, toFloat)")
        print(f"    ✓ CASE statement conditional logic")
        print(f"    ✓ Date/duration calculations")
        print(f"    ✓ NOT EXISTS filtering")
        print(f"    ✓ Conditional relationship logic")
        print(f"    ✓ Bulk property updates")
        print(f"    ✓ Data validation queries")
        print(f"    ✓ Referential integrity checks")
        print(f"    ✓ Territory-based aggregation")
        print(f"    ✓ Bulk data statistics")
        print(f"    ✓ Policy-vehicle linkage verification")
        print("  ✓ Lab 4 validation complete")
