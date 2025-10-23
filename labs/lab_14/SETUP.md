# Lab 14 Environment Setup Guide

## Quick Start

### Step 1: Create Virtual Environment

**Windows:**
```bash
cd C:\Users\%USERNAME%\neo4j_mastering\labs\lab_14
python -m venv venv
venv\Scripts\activate
```

**Mac/Linux:**
```bash
cd ~/neo4j_mastering/labs/lab_14
python3 -m venv venv
source venv/bin/activate
```

### Step 2: Install Dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

**Note:** Some dependencies are optional:
- `prometheus-client` - For monitoring (recommended)
- `psutil` - For system metrics (recommended)
- `docker` - For container management (required for deployment)

### Step 3: Install Docker (if not already installed)

**Windows/Mac:**
- Download and install Docker Desktop from https://www.docker.com/products/docker-desktop

**Linux:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Step 4: Configure Environment

```bash
cp .env.example .env
# Edit .env with your settings
```

**Important:** Update production passwords and encryption keys with secure values!

### Step 5: Launch Jupyter Lab

```bash
jupyter lab
```

### Step 6: Work Through Notebooks

Execute notebooks in order:
1. `01_production_infrastructure_setup.ipynb`
2. `02_security_and_authentication.ipynb`
3. `03_monitoring_and_logging.ipynb`
4. `04_backup_and_disaster_recovery.ipynb`
5. `05_cicd_and_container_deployment.ipynb`

## Generated Files

This lab will create several files:
- `docker-compose.yml` - Container orchestration
- `.gitlab-ci.yml` - CI/CD pipeline
- Backup files in designated directory
- Configuration files for various services

## Prerequisites

- Completed Labs 12 and 13
- Docker installed and running
- Neo4j running
- Python 3.8+
- Minimum 4GB RAM available for containers

## Verification

```bash
# Verify Docker is running
docker --version
docker ps

# Verify Python packages
python -c "import cryptography, docker, prometheus_client, psutil; print('✅ All packages installed')"
```
