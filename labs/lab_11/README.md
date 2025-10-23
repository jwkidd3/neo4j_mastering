# Neo4j Lab 11: Python Driver & Service Architecture

## Overview

This lab covers building Python applications with Neo4j driver integration, implementing enterprise-grade service architecture patterns with proper error handling and automated testing for graph operations.

**Duration:** 45 minutes
**Prerequisites:** Completed Neo4j Labs 1-10, Neo4j Enterprise running in Docker, Python 3.8+

## Notebooks

The lab is organized into 5 comprehensive Jupyter notebooks:

### 1. **01_python_driver_setup_and_basics.ipynb** (10 minutes)
- Environment setup and dependency installation
- Neo4j Python driver configuration
- Connection verification and health checks
- Enterprise connection manager implementation with pooling and retry logic

**Key Concepts:**
- Connection management
- Environment variables configuration
- Health monitoring
- Retry logic with exponential backoff

---

### 2. **02_pydantic_models_and_validation.ipynb** (10 minutes)
- Pydantic model creation for insurance entities
- Data validation and type safety
- Custom validators for business rules
- Enum types for controlled values

**Key Concepts:**
- Type-safe data models
- Validation rules enforcement
- Customer, Policy, Claim, and RiskAssessment models
- Business logic validation

---

### 3. **03_repository_and_service_layer.ipynb** (15 minutes)
- Abstract repository base class
- Customer repository with CRUD operations
- Insurance service layer with business logic
- Transaction management
- Complex business operations (customer creation, claim processing)

**Key Concepts:**
- Repository pattern
- Service layer architecture
- Transaction management
- Business logic encapsulation
- Customer 360-degree view

---

### 4. **04_testing_and_integration.ipynb** (10 minutes)
- Unit testing with pytest
- Data validation testing
- Connection resilience tests
- Integration testing with live database
- Performance measurement
- Data consistency verification

**Key Concepts:**
- Unit testing strategies
- Integration testing
- Test data management
- Performance metrics
- Automated cleanup

---

### 5. **05_monitoring_and_production.ipynb** (10 minutes)
- System metrics collection (CPU, memory, disk)
- Database performance monitoring
- Application health checks
- Alert generation
- Comprehensive reporting
- Lab completion verification

**Key Concepts:**
- Production monitoring
- Health score calculation
- Alert thresholds
- Observability
- Production readiness

---

## Learning Objectives

By completing this lab, you will:

1. ✅ Implement enterprise-grade Neo4j connection management
2. ✅ Create type-safe data models with Pydantic validation
3. ✅ Build repository and service layer architecture
4. ✅ Develop comprehensive testing strategies
5. ✅ Implement production monitoring and health checks
6. ✅ Apply clean architecture patterns
7. ✅ Handle errors and implement retry logic
8. ✅ Perform transaction management
9. ✅ Create audit trails and logging

## Technologies Used

- **Neo4j Python Driver** (5.26.0): Official Neo4j driver for Python
- **Pydantic** (2.5.0): Data validation using Python type annotations
- **pytest** (8.0.0): Testing framework
- **python-dotenv** (1.0.0): Environment variable management
- **psutil**: System and process monitoring
- **typing-extensions**: Extended type hints

## Database State Evolution

- **Starting:** 650 nodes, 800 relationships (from Lab 10)
- **Ending:** 650+ nodes, 800+ relationships (with test data)
- **Target for Lab 7:** 720 nodes, 900 relationships

## Running the Notebooks

### Prerequisites

1. Start Neo4j Docker container:
```bash
docker ps  # Verify neo4j container is running
# If not running:
docker start neo4j
```

2. Install required Python packages:
```bash
pip install neo4j==5.26.0 pydantic==2.5.0 pytest==8.0.0 python-dotenv==1.0.0 psutil
```

3. Create `.env` file in lab_11 directory:
```env
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=password
NEO4J_DATABASE=neo4j
```

### Execution Order

**Important:** Run notebooks in sequence as each builds upon the previous:

1. Start with `01_python_driver_setup_and_basics.ipynb`
2. Then `02_pydantic_models_and_validation.ipynb`
3. Followed by `03_repository_and_service_layer.ipynb`
4. Then `04_testing_and_integration.ipynb`
5. Finally `05_monitoring_and_production.ipynb`

### Launch Jupyter Lab

```bash
# Navigate to lab directory
cd /path/to/labs/lab_11

# Start Jupyter Lab
jupyter lab
```

## Key Features Implemented

### Connection Management
- Connection pooling with configurable pool size
- Automatic retry logic with exponential backoff
- Health checks and metrics tracking
- Thread-safe operations

### Data Models
- Customer, Policy, Claim, RiskAssessment models
- Comprehensive validation rules
- Type safety with Pydantic
- Enum types for controlled values

### Repository Pattern
- Abstract base repository
- CRUD operations
- Advanced search capabilities
- Data type conversion

### Service Layer
- Business logic encapsulation
- Transaction management
- Customer and policy creation
- Claim processing with validation
- Audit trail creation

### Testing
- Unit tests for validation
- Integration tests with live database
- Connection resilience tests
- Performance measurement
- Automatic test cleanup

### Monitoring
- System metrics (CPU, memory, disk)
- Database performance tracking
- Application health checks
- Alert generation
- Health score calculation

## Architecture Patterns

This lab demonstrates:

- **Clean Architecture:** Separation of concerns with distinct layers
- **Repository Pattern:** Data access abstraction
- **Service Layer:** Business logic encapsulation
- **Dependency Injection:** Testable component design
- **Factory Pattern:** Connection manager instantiation
- **Strategy Pattern:** Error handling and retry strategies

## Common Issues and Solutions

### Connection Issues
```python
# Check Docker container
docker ps
docker logs neo4j

# Restart if needed
docker restart neo4j
```

### Import Errors
```python
# Reinstall packages
pip install --upgrade neo4j pydantic pytest python-dotenv

# Or use requirements.txt
pip install -r requirements.txt
```

### Validation Errors
- Ensure Customer IDs start with 'CUST-'
- Policy numbers start with 'POL-'
- Claim numbers start with 'CLM-'
- Age must be between 18-120
- Dates must be logically consistent

## Next Steps

After completing Lab 11, you're ready for:

**Lab 7: Insurance API Development**
- Build RESTful APIs with FastAPI
- Implement authentication and authorization
- Create interactive API documentation
- Deploy production-ready services
- Scale to 720 nodes and 900 relationships

## Additional Resources

- [Neo4j Python Driver Documentation](https://neo4j.com/docs/python-manual/current/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [pytest Documentation](https://docs.pytest.org/)
- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Support

For issues or questions:
1. Review notebook markdown cells for explanations
2. Check error messages and traceback
3. Verify Docker container is running
4. Confirm environment variables are set correctly
5. Review the main lab README.md for troubleshooting

---

**Lab Status:** ✅ Complete and Ready for Use

**Created:** October 2025
**Last Updated:** October 2025
