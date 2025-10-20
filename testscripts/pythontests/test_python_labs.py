"""
Comprehensive test suite for Neo4j Python Labs 12-17

Tests cover:
- Lab 12: Python Driver & Service Architecture
- Lab 13: Production Insurance API Development
- Lab 14: Interactive Insurance Web Application
- Lab 15: Production Deployment
- Lab 16: Multi-Line Insurance Platform
- Lab 17: Innovation Showcase & Future Capabilities
"""

import pytest
from neo4j import GraphDatabase
from datetime import datetime, timedelta
import uuid
import logging

logger = logging.getLogger(__name__)


# ============================================================================
# Lab 12: Python Driver & Service Architecture Tests
# ============================================================================

class TestLab12PythonDriver:
    """Tests for Lab 12 - Python Driver & Service Architecture"""

    @pytest.mark.lab12
    @pytest.mark.driver
    def test_driver_connection(self, neo4j_driver):
        """Test that Neo4j driver can connect successfully"""
        assert neo4j_driver is not None
        neo4j_driver.verify_connectivity()

    @pytest.mark.lab12
    @pytest.mark.driver
    def test_basic_query_execution(self, neo4j_session):
        """Test basic Cypher query execution via Python driver"""
        result = neo4j_session.run("RETURN 1 AS number")
        record = result.single()
        assert record["number"] == 1

    @pytest.mark.lab12
    @pytest.mark.driver
    def test_create_node_via_driver(self, neo4j_session, clean_test_data):
        """Test creating a node using Python driver"""
        # Create a test node
        result = neo4j_session.run(
            """
            CREATE (n:TestNode {name: $name, created: datetime()})
            RETURN n.name AS name
            """,
            name="Test Customer"
        )
        record = result.single()
        assert record["name"] == "Test Customer"

        # Verify node was created
        verify_result = neo4j_session.run(
            "MATCH (n:TestNode {name: $name}) RETURN count(n) AS count",
            name="Test Customer"
        )
        assert verify_result.single()["count"] == 1

    @pytest.mark.lab12
    @pytest.mark.driver
    def test_parameterized_query(self, neo4j_session, clean_test_data):
        """Test parameterized queries to prevent injection"""
        customer_name = "Alice Smith"
        customer_email = "alice@example.com"

        # Create customer with parameters
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {
                name: $name,
                email: $email,
                created_at: datetime()
            })
            """,
            name=customer_name,
            email=customer_email
        )

        # Query with parameters
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer {email: $email})
            RETURN c.name AS name, c.email AS email
            """,
            email=customer_email
        )
        record = result.single()
        assert record["name"] == customer_name
        assert record["email"] == customer_email

    @pytest.mark.lab12
    @pytest.mark.driver
    def test_transaction_rollback(self, neo4j_driver, clean_test_data):
        """Test transaction rollback on error"""
        with neo4j_driver.session() as session:
            try:
                with session.begin_transaction() as tx:
                    tx.run("CREATE (n:TestNode {name: 'Temp'})")
                    # Force an error
                    tx.run("INVALID CYPHER QUERY")
                    tx.commit()
            except Exception:
                pass  # Expected to fail

        # Verify node was NOT created (transaction rolled back)
        with neo4j_driver.session() as session:
            result = session.run(
                "MATCH (n:TestNode {name: 'Temp'}) RETURN count(n) AS count"
            )
            assert result.single()["count"] == 0

    @pytest.mark.lab12
    @pytest.mark.service
    def test_customer_service_layer(self, neo4j_session, clean_test_data):
        """Test customer service layer pattern from Lab 12"""

        class CustomerService:
            def __init__(self, session):
                self.session = session

            def create_customer(self, customer_data):
                """Create a new customer"""
                result = self.session.run(
                    """
                    CREATE (c:TestCustomer {
                        customer_id: $customer_id,
                        name: $name,
                        email: $email,
                        created_at: datetime()
                    })
                    RETURN c.customer_id AS customer_id
                    """,
                    **customer_data
                )
                return result.single()["customer_id"]

            def get_customer(self, customer_id):
                """Get customer by ID"""
                result = self.session.run(
                    """
                    MATCH (c:TestCustomer {customer_id: $customer_id})
                    RETURN c.customer_id AS customer_id,
                           c.name AS name,
                           c.email AS email
                    """,
                    customer_id=customer_id
                )
                return result.single()

        # Test the service layer
        service = CustomerService(neo4j_session)

        customer_data = {
            "customer_id": str(uuid.uuid4()),
            "name": "Bob Johnson",
            "email": "bob@example.com"
        }

        # Create customer
        customer_id = service.create_customer(customer_data)
        assert customer_id == customer_data["customer_id"]

        # Retrieve customer
        customer = service.get_customer(customer_id)
        assert customer["name"] == "Bob Johnson"
        assert customer["email"] == "bob@example.com"


# ============================================================================
# Lab 13: Production Insurance API Development Tests
# ============================================================================

class TestLab13ProductionAPI:
    """Tests for Lab 13 - Production Insurance API Development"""

    @pytest.mark.lab13
    @pytest.mark.api
    def test_customer_api_crud(self, neo4j_session, clean_test_data):
        """Test CRUD operations for customer API"""

        class CustomerAPI:
            def __init__(self, session):
                self.session = session

            def create(self, data):
                result = self.session.run(
                    """
                    CREATE (c:TestCustomer {
                        customer_number: $customer_number,
                        first_name: $first_name,
                        last_name: $last_name,
                        email: $email,
                        created_at: datetime()
                    })
                    RETURN c
                    """,
                    **data
                )
                return result.single()["c"]

            def read(self, customer_number):
                result = self.session.run(
                    """
                    MATCH (c:TestCustomer {customer_number: $customer_number})
                    RETURN c
                    """,
                    customer_number=customer_number
                )
                record = result.single()
                return record["c"] if record else None

            def update(self, customer_number, updates):
                self.session.run(
                    """
                    MATCH (c:TestCustomer {customer_number: $customer_number})
                    SET c += $updates, c.updated_at = datetime()
                    """,
                    customer_number=customer_number,
                    updates=updates
                )

            def delete(self, customer_number):
                self.session.run(
                    """
                    MATCH (c:TestCustomer {customer_number: $customer_number})
                    DETACH DELETE c
                    """,
                    customer_number=customer_number
                )

        api = CustomerAPI(neo4j_session)

        # Create
        customer_data = {
            "customer_number": "CUST-TEST-001",
            "first_name": "Jane",
            "last_name": "Doe",
            "email": "jane.doe@example.com"
        }
        customer = api.create(customer_data)
        assert customer["first_name"] == "Jane"

        # Read
        retrieved = api.read("CUST-TEST-001")
        assert retrieved is not None
        assert retrieved["email"] == "jane.doe@example.com"

        # Update
        api.update("CUST-TEST-001", {"email": "jane.updated@example.com"})
        updated = api.read("CUST-TEST-001")
        assert updated["email"] == "jane.updated@example.com"

        # Delete
        api.delete("CUST-TEST-001")
        deleted = api.read("CUST-TEST-001")
        assert deleted is None

    @pytest.mark.lab13
    @pytest.mark.api
    def test_policy_search_api(self, neo4j_session, clean_test_data):
        """Test policy search API functionality"""
        # Create test data
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {customer_number: 'CUST-001', name: 'Test User'})
            CREATE (p1:TestPolicy {policy_number: 'POL-001', type: 'AUTO', premium: 1000})
            CREATE (p2:TestPolicy {policy_number: 'POL-002', type: 'HOME', premium: 800})
            CREATE (c)-[:HOLDS_TEST_POLICY]->(p1)
            CREATE (c)-[:HOLDS_TEST_POLICY]->(p2)
            """
        )

        # Search for policies by type
        result = neo4j_session.run(
            """
            MATCH (p:TestPolicy {type: $policy_type})
            RETURN p.policy_number AS policy_number, p.premium AS premium
            ORDER BY p.premium DESC
            """,
            policy_type="AUTO"
        )
        policies = [record.data() for record in result]
        assert len(policies) == 1
        assert policies[0]["policy_number"] == "POL-001"

    @pytest.mark.lab13
    @pytest.mark.api
    def test_api_error_handling(self, neo4j_session):
        """Test API error handling patterns"""

        class SafeCustomerAPI:
            def __init__(self, session):
                self.session = session

            def get_customer_safe(self, customer_number):
                try:
                    result = self.session.run(
                        """
                        MATCH (c:TestCustomer {customer_number: $customer_number})
                        RETURN c
                        """,
                        customer_number=customer_number
                    )
                    record = result.single()
                    if not record:
                        return {"error": "Customer not found"}, 404
                    return {"data": dict(record["c"])}, 200
                except Exception as e:
                    return {"error": str(e)}, 500

        api = SafeCustomerAPI(neo4j_session)

        # Test not found
        response, status = api.get_customer_safe("NONEXISTENT")
        assert status == 404
        assert "error" in response


# ============================================================================
# Lab 14: Interactive Insurance Web Application Tests
# ============================================================================

class TestLab14WebApplication:
    """Tests for Lab 14 - Interactive Insurance Web Application"""

    @pytest.mark.lab14
    @pytest.mark.integration
    def test_dashboard_data_aggregation(self, neo4j_session, clean_test_data):
        """Test dashboard data aggregation"""
        # Create test data
        neo4j_session.run(
            """
            CREATE (c1:TestCustomer {customer_number: 'CUST-001', name: 'Alice'})
            CREATE (c2:TestCustomer {customer_number: 'CUST-002', name: 'Bob'})
            CREATE (p1:TestPolicy {policy_number: 'POL-001', annual_premium: 1200, status: 'active'})
            CREATE (p2:TestPolicy {policy_number: 'POL-002', annual_premium: 800, status: 'active'})
            CREATE (p3:TestPolicy {policy_number: 'POL-003', annual_premium: 1500, status: 'pending'})
            CREATE (c1)-[:HOLDS_TEST_POLICY]->(p1)
            CREATE (c1)-[:HOLDS_TEST_POLICY]->(p2)
            CREATE (c2)-[:HOLDS_TEST_POLICY]->(p3)
            """
        )

        # Dashboard query
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer)-[:HOLDS_TEST_POLICY]->(p:TestPolicy)
            WITH count(DISTINCT c) AS total_customers,
                 count(DISTINCT p) AS total_policies,
                 sum(p.annual_premium) AS total_premium
            RETURN total_customers, total_policies, total_premium
            """
        )
        dashboard = result.single()

        assert dashboard["total_customers"] == 2
        assert dashboard["total_policies"] == 3
        assert dashboard["total_premium"] == 3500

    @pytest.mark.lab14
    def test_search_functionality(self, neo4j_session, clean_test_data):
        """Test search functionality for web application"""
        # Create test data
        neo4j_session.run(
            """
            CREATE (c1:TestCustomer {name: 'Alice Smith', email: 'alice@example.com'})
            CREATE (c2:TestCustomer {name: 'Bob Smith', email: 'bob@example.com'})
            CREATE (c3:TestCustomer {name: 'Charlie Jones', email: 'charlie@example.com'})
            """
        )

        # Search by name pattern
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer)
            WHERE c.name CONTAINS $search_term
            RETURN c.name AS name, c.email AS email
            ORDER BY c.name
            """,
            search_term="Smith"
        )
        customers = [record.data() for record in result]
        assert len(customers) == 2
        assert customers[0]["name"] == "Alice Smith"
        assert customers[1]["name"] == "Bob Smith"


# ============================================================================
# Lab 15: Production Deployment Tests
# ============================================================================

class TestLab15ProductionDeployment:
    """Tests for Lab 15 - Production Deployment"""

    @pytest.mark.lab15
    def test_connection_pooling(self, neo4j_driver):
        """Test connection pooling configuration"""
        # Verify driver has connection pool
        assert neo4j_driver is not None

        # Execute multiple queries to test pooling
        for i in range(5):
            with neo4j_driver.session() as session:
                result = session.run("RETURN $i AS number", i=i)
                assert result.single()["number"] == i

    @pytest.mark.lab15
    def test_health_check_endpoint(self, neo4j_session):
        """Test health check functionality"""

        def health_check():
            """Health check function"""
            try:
                result = neo4j_session.run("RETURN 1 AS health")
                return result.single()["health"] == 1
            except Exception:
                return False

        assert health_check() is True

    @pytest.mark.lab15
    def test_metrics_collection(self, neo4j_session, clean_test_data):
        """Test metrics collection for monitoring"""
        # Create some test data
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {name: 'Metrics Test'})
            CREATE (p:TestPolicy {policy_number: 'POL-METRICS-001'})
            """
        )

        # Collect metrics
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer)
            WITH count(c) AS customer_count
            MATCH (p:TestPolicy)
            RETURN customer_count, count(p) AS policy_count
            """
        )
        metrics = result.single()

        assert metrics["customer_count"] >= 1
        assert metrics["policy_count"] >= 1


# ============================================================================
# Lab 16: Multi-Line Insurance Platform Tests
# ============================================================================

class TestLab16MultiLinePlatform:
    """Tests for Lab 16 - Multi-Line Insurance Platform"""

    @pytest.mark.lab16
    def test_multi_line_product_support(self, neo4j_session, clean_test_data):
        """Test support for multiple insurance product lines"""
        # Create multi-line products
        neo4j_session.run(
            """
            CREATE (auto:TestPolicy {type: 'AUTO', product_line: 'Personal', premium: 1200})
            CREATE (home:TestPolicy {type: 'HOME', product_line: 'Personal', premium: 800})
            CREATE (commercial:TestPolicy {type: 'COMMERCIAL', product_line: 'Business', premium: 5000})
            CREATE (life:TestPolicy {type: 'LIFE', product_line: 'Life', premium: 2000})
            """
        )

        # Query by product line
        result = neo4j_session.run(
            """
            MATCH (p:TestPolicy)
            RETURN p.product_line AS line,
                   count(p) AS count,
                   sum(p.premium) AS total_premium
            ORDER BY line
            """
        )
        lines = [record.data() for record in result]

        # Verify we have multiple product lines
        assert len(lines) >= 3

    @pytest.mark.lab16
    def test_cross_sell_opportunities(self, neo4j_session, clean_test_data):
        """Test cross-sell opportunity identification"""
        # Create customer with only one policy type
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {customer_number: 'CUST-CROSS-001', name: 'Cross Sell Customer'})
            CREATE (p:TestPolicy {policy_number: 'POL-AUTO-001', type: 'AUTO'})
            CREATE (c)-[:HOLDS_TEST_POLICY]->(p)
            """
        )

        # Find customers without HOME insurance (cross-sell opportunity)
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer {customer_number: 'CUST-CROSS-001'})
            WHERE NOT EXISTS {
                MATCH (c)-[:HOLDS_TEST_POLICY]->(p:TestPolicy {type: 'HOME'})
            }
            RETURN c.customer_number AS customer_number, 'HOME' AS opportunity
            """
        )
        opportunities = [record.data() for record in result]
        assert len(opportunities) == 1
        assert opportunities[0]["opportunity"] == "HOME"


# ============================================================================
# Lab 17: Innovation Showcase Tests
# ============================================================================

class TestLab17InnovationShowcase:
    """Tests for Lab 17 - Innovation Showcase & Future Capabilities"""

    @pytest.mark.lab17
    def test_graph_analytics_patterns(self, neo4j_session, clean_test_data):
        """Test advanced graph analytics patterns"""
        # Create a small network
        neo4j_session.run(
            """
            CREATE (c1:TestCustomer {name: 'Customer1'})
            CREATE (c2:TestCustomer {name: 'Customer2'})
            CREATE (c3:TestCustomer {name: 'Customer3'})
            CREATE (c1)-[:REFERRED]->(c2)
            CREATE (c2)-[:REFERRED]->(c3)
            CREATE (c1)-[:REFERRED]->(c3)
            """
        )

        # Calculate referral network depth
        result = neo4j_session.run(
            """
            MATCH path = (c1:TestCustomer)-[:REFERRED*]->(c2:TestCustomer)
            RETURN c1.name AS source,
                   c2.name AS target,
                   length(path) AS depth
            ORDER BY depth DESC
            LIMIT 1
            """
        )
        longest_path = result.single()
        assert longest_path["depth"] >= 1

    @pytest.mark.lab17
    def test_temporal_queries(self, neo4j_session, clean_test_data):
        """Test temporal query patterns"""
        # Create data with timestamps
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {
                name: 'Temporal Test',
                created_at: datetime(),
                last_updated: datetime()
            })
            """
        )

        # Query with temporal filter
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer {name: 'Temporal Test'})
            WHERE c.created_at <= datetime()
            RETURN c.name AS name, c.created_at AS created
            """
        )
        record = result.single()
        assert record is not None
        assert record["name"] == "Temporal Test"

    @pytest.mark.lab17
    def test_pattern_matching_advanced(self, neo4j_session, clean_test_data):
        """Test advanced pattern matching capabilities"""
        # Create complex relationship pattern
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {name: 'Customer'})
            CREATE (p:TestPolicy {type: 'AUTO'})
            CREATE (a:Agent {name: 'Agent'})
            CREATE (c)-[:HOLDS_TEST_POLICY]->(p)
            CREATE (a)-[:SERVICES]->(c)
            """
        )

        # Match complex pattern
        result = neo4j_session.run(
            """
            MATCH (a:Agent)-[:SERVICES]->(c:TestCustomer)-[:HOLDS_TEST_POLICY]->(p:TestPolicy)
            RETURN a.name AS agent, c.name AS customer, p.type AS policy_type
            """
        )
        pattern = result.single()
        assert pattern is not None
        assert pattern["agent"] == "Agent"
        assert pattern["policy_type"] == "AUTO"


# ============================================================================
# Integration Tests
# ============================================================================

class TestIntegration:
    """Integration tests across multiple labs"""

    @pytest.mark.integration
    def test_end_to_end_customer_workflow(self, neo4j_session, clean_test_data):
        """Test complete customer workflow from creation to policy assignment"""
        customer_number = f"CUST-E2E-{uuid.uuid4().hex[:8]}"
        policy_number = f"POL-E2E-{uuid.uuid4().hex[:8]}"

        # 1. Create customer (Lab 12-13)
        neo4j_session.run(
            """
            CREATE (c:TestCustomer {
                customer_number: $customer_number,
                name: 'End-to-End Test Customer',
                email: 'e2e@example.com',
                created_at: datetime()
            })
            """,
            customer_number=customer_number
        )

        # 2. Create policy (Lab 13)
        neo4j_session.run(
            """
            CREATE (p:TestPolicy {
                policy_number: $policy_number,
                type: 'AUTO',
                annual_premium: 1500,
                status: 'active',
                created_at: datetime()
            })
            """,
            policy_number=policy_number
        )

        # 3. Link customer to policy (Lab 13-14)
        neo4j_session.run(
            """
            MATCH (c:TestCustomer {customer_number: $customer_number})
            MATCH (p:TestPolicy {policy_number: $policy_number})
            CREATE (c)-[:HOLDS_TEST_POLICY {since: datetime()}]->(p)
            """,
            customer_number=customer_number,
            policy_number=policy_number
        )

        # 4. Verify complete workflow (Lab 14-15)
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer {customer_number: $customer_number})
                  -[r:HOLDS_TEST_POLICY]->(p:TestPolicy {policy_number: $policy_number})
            RETURN c.name AS customer_name,
                   p.type AS policy_type,
                   p.annual_premium AS premium,
                   r.since IS NOT NULL AS has_link_date
            """,
            customer_number=customer_number,
            policy_number=policy_number
        )

        workflow = result.single()
        assert workflow is not None
        assert workflow["customer_name"] == 'End-to-End Test Customer'
        assert workflow["policy_type"] == 'AUTO'
        assert workflow["premium"] == 1500
        assert workflow["has_link_date"] is True

    @pytest.mark.integration
    @pytest.mark.slow
    def test_performance_bulk_operations(self, neo4j_session, clean_test_data):
        """Test bulk operations performance"""
        # Create bulk test data
        batch_size = 100

        neo4j_session.run(
            """
            UNWIND range(1, $batch_size) AS i
            CREATE (c:TestCustomer {
                customer_number: 'BULK-' + toString(i),
                name: 'Bulk Customer ' + toString(i),
                created_at: datetime()
            })
            """,
            batch_size=batch_size
        )

        # Verify bulk creation
        result = neo4j_session.run(
            """
            MATCH (c:TestCustomer)
            WHERE c.customer_number STARTS WITH 'BULK-'
            RETURN count(c) AS count
            """
        )
        count = result.single()["count"]
        assert count == batch_size
