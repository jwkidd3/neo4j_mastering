# Lab 12: Production Insurance API Development

**Duration:** 45 minutes
**Database State:** 650 → 720 nodes, 800 → 900 relationships

## Overview

This lab teaches you to build production-ready RESTful APIs using FastAPI with Neo4j integration, implementing secure authentication, comprehensive API documentation, and customer/policy/claims management endpoints.

## Notebook Structure

Work through these notebooks in order:

### 1. API Setup and Configuration (01)
**File:** `01_api_setup_and_configuration.ipynb`
**Topics:**
- Development environment verification
- FastAPI application foundation setup
- Database connection manager implementation
- Pydantic models for data validation
- Global configuration management

### 2. Authentication and Security (02)
**File:** `02_authentication_and_security.ipynb`
**Topics:**
- JWT-based authentication system
- Password hashing with bcrypt
- User authentication functions
- Role-based access control (RBAC)
- Security dependencies and demo users

### 3. Customer Management APIs (03)
**File:** `03_customer_management_apis.ipynb`
**Topics:**
- Customer CRUD operations
- Customer retrieval by ID
- Customer listing with pagination
- Advanced search and filtering
- Email uniqueness validation

### 4. Policy and Claims APIs (04)
**File:** `04_policy_and_claims_apis.ipynb`
**Topics:**
- Policy creation and administration
- Policy retrieval and filtering
- Claims submission with validation
- Claims status tracking
- Coverage limit validation

### 5. Analytics and Deployment (05)
**File:** `05_analytics_and_deployment.ipynb`
**Topics:**
- Health check endpoints
- Customer analytics dashboard
- Policy analytics with status breakdown
- Claims analytics and reporting
- API server startup and testing

## Prerequisites

- Python 3.8+
- Neo4j Enterprise running on localhost:7687
- Completed Lab 7 (Python Driver & Service Architecture)

## Installation

```bash
pip install jupyterlab fastapi uvicorn neo4j pydantic python-jose passlib pytest
jupyter lab
```

## Running the Lab

1. Open Jupyter Lab
2. Navigate to the `lab_12` directory
3. Open notebooks in order (01 through 05)
4. Execute cells sequentially
5. Test APIs using the interactive documentation at http://localhost:8000/docs

## Key Learning Outcomes

- Build production-ready RESTful APIs with FastAPI
- Implement JWT authentication and RBAC
- Create comprehensive API documentation
- Design customer, policy, and claims management endpoints
- Handle API security, error responses, and rate limiting
