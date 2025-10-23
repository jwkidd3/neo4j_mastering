# Lab 11 Environment Setup Guide

## Quick Start

### Step 1: Create Virtual Environment

**Windows:**
```bash
cd C:\Users\%USERNAME%\neo4j_mastering\labs\lab_11
python -m venv venv
venv\Scripts\activate
```

**Mac/Linux:**
```bash
cd ~/neo4j_mastering/labs/lab_11
python3 -m venv venv
source venv/bin/activate
```

### Step 2: Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 3: Configure Environment

```bash
cp .env.example .env
# Edit .env with your Neo4j credentials
```

### Step 4: Launch Jupyter Lab

```bash
jupyter lab
```

### Step 5: Work Through Notebooks

Execute notebooks in order:
1. `01_python_driver_setup_and_basics.ipynb`
2. `02_pydantic_models_and_validation.ipynb`
3. `03_repository_and_service_layer.ipynb`
4. `04_testing_and_integration.ipynb`
5. `05_monitoring_and_production.ipynb`

## Prerequisites

- Completed Labs 1-10
- Neo4j Enterprise running on localhost:7687
- Python 3.8+
- Basic understanding of object-oriented programming
- Familiarity with design patterns (Repository, Service Layer)

## What You'll Learn

### Architecture Patterns
- **Repository Pattern** - Data access abstraction
- **Service Layer** - Business logic separation
- **Dependency Injection** - Loose coupling
- **Factory Pattern** - Object creation
- **Strategy Pattern** - Algorithm selection

### Production Skills
- Connection pooling and management
- Transaction handling and rollback
- Error handling and retry logic
- Health checks and monitoring
- Comprehensive testing strategies
- Performance optimization

## Verification

Test your setup:

```python
# In a Jupyter notebook cell:
from neo4j import GraphDatabase
from pydantic import BaseModel
import pytest

print("✅ All dependencies installed successfully")

# Test Neo4j connection
driver = GraphDatabase.driver(
    "bolt://localhost:7687",
    auth=("neo4j", "password")
)
driver.verify_connectivity()
print("✅ Neo4j connection successful")
driver.close()
```

## Common Issues

### Connection Errors
- Ensure Neo4j is running: `docker ps`
- Check credentials in .env file
- Verify Neo4j is accessible at http://localhost:7474

### Import Errors
Make sure virtual environment is activated:
```bash
# You should see (venv) in your command prompt
# If not, activate again:
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows
```

### Test Failures
If integration tests fail:
- Ensure database has sample data from previous labs
- Check database is not read-only
- Verify user has write permissions

## Optional: Type Checking and Code Quality

```bash
# Type checking with mypy
mypy lab_11/*.py

# Code formatting with black
black lab_11/*.py

# Linting with pylint
pylint lab_11/*.py
```

## Deactivating Virtual Environment

When you're done:
```bash
deactivate
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│         Application Layer               │
│  (Notebooks, CLI, API Endpoints)        │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Service Layer                   │
│  (Business Logic, Validation)           │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Repository Layer                  │
│  (Data Access, CRUD Operations)         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Connection Manager                 │
│  (Pool, Health Checks, Retry)           │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Neo4j Database                  │
└─────────────────────────────────────────┘
```

## Next Steps

After completing this lab, you'll be ready for:
- **Lab 12**: Production Insurance API Development
- **Lab 13**: Interactive Insurance Web Application
- **Lab 14**: Production Deployment
- **Lab 15**: Multi-Line Insurance Platform
