# Lab 14: Production Deployment

**Duration:** 45 minutes
**Database State:** 800 → 850 nodes, 1000 → 1100 relationships

## Overview

This lab teaches enterprise-grade production deployment with security hardening, monitoring, backup automation, Docker containerization, and CI/CD pipeline creation for Neo4j applications.

## Notebook Structure

Work through these notebooks in order:

### 1. Production Infrastructure Setup (01)
**File:** `01_production_infrastructure_setup.ipynb`
**Topics:**
- Environment configuration (Dev, Staging, Production)
- Production dependency installation
- ProductionConfig class for multi-environment management
- Configuration validation
- Infrastructure setup best practices

### 2. Security and Authentication (02)
**File:** `02_security_and_authentication.ipynb`
**Topics:**
- SecurityManager with encryption and password hashing
- PBKDF2 password hashing (100,000 iterations)
- JWT token generation and verification
- UserAuthenticationSystem with RBAC
- Rate limiting and failed login tracking
- Default user creation for 4 roles

### 3. Monitoring and Logging (03)
**File:** `03_monitoring_and_logging.ipynb`
**Topics:**
- ProductionMonitoringSystem with Prometheus metrics
- System metrics collection (CPU, memory, disk)
- Neo4j database metrics monitoring
- Health report generation with alerts
- ProductionLoggingSystem with audit trails
- Security event logging

### 4. Backup and Disaster Recovery (04)
**File:** `04_backup_and_disaster_recovery.ipynb`
**Topics:**
- BackupAutomationSystem class
- Database backup creation
- Security configuration backup
- Backup restoration procedures
- Automated scheduling (daily at 02:00 UTC)
- Retention policy (30 days)
- Disaster recovery plan (RTO: 15 min, RPO: 5 min)

### 5. CI/CD and Container Deployment (05)
**File:** `05_cicd_and_container_deployment.ipynb`
**Topics:**
- DockerDeploymentManager class
- Container configurations (Neo4j, App, Nginx, Prometheus)
- Docker Compose file generation
- CI/CD pipeline with 4 stages (Build, Security, Test, Deploy)
- Production database setup
- Deployment verification

## Prerequisites

- Python 3.8+
- Neo4j Enterprise running
- Docker and Docker Compose installed
- Completed Lab 13 (Interactive Insurance Web Application)

## Installation

```bash
pip install jupyterlab docker pyyaml cryptography prometheus-client psutil pytest
jupyter lab
```

## Running the Lab

1. Open Jupyter Lab
2. Navigate to the `lab_14` directory
3. Open notebooks in order (01 through 05)
4. Execute cells sequentially
5. Review generated files:
   - `docker-compose.yml` - Container orchestration
   - `.gitlab-ci.yml` - CI/CD pipeline
   - Backup files in designated directories

## Key Learning Outcomes

- Configure production infrastructure for multiple environments
- Implement enterprise security with encryption and RBAC
- Set up monitoring with Prometheus metrics
- Create automated backup and disaster recovery systems
- Build Docker containers and orchestration
- Design CI/CD pipelines for continuous deployment
- Verify production readiness
