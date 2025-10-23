# Lab 13 Environment Setup Guide

## Quick Start

### Step 1: Create Virtual Environment

**Windows:**
```bash
cd C:\Users\%USERNAME%\neo4j_mastering\labs\lab_13
python -m venv venv
venv\Scripts\activate
```

**Mac/Linux:**
```bash
cd ~/neo4j_mastering/labs/lab_13
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
# Edit .env with your settings
```

### Step 4: Launch Jupyter Lab

```bash
jupyter lab
```

### Step 5: Work Through Notebooks

Execute notebooks in order:
1. `01_web_app_environment_setup.ipynb`
2. `02_fastapi_and_websocket_setup.ipynb`
3. `03_dashboard_routes_and_apis.ipynb`
4. `04_agent_and_claims_dashboards.ipynb`
5. `05_realtime_features_and_deployment.ipynb`

## Accessing the Web Application

After starting the server (in notebook 05):
- **Main App**: http://localhost:8001
- **Customer Portal**: http://localhost:8001/customer
- **Agent Dashboard**: http://localhost:8001/agent
- **Claims Dashboard**: http://localhost:8001/claims
- **Executive Dashboard**: http://localhost:8001/executive

## Prerequisites

- Completed Lab 12
- Neo4j running with insurance data loaded
- Python 3.8+
