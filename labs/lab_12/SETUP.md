# Lab 12 Environment Setup Guide

## Quick Start

### Step 1: Create Virtual Environment

**Windows:**
```bash
# Navigate to lab directory
cd C:\Users\%USERNAME%\neo4j_mastering\labs\lab_12

# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate
```

**Mac/Linux:**
```bash
# Navigate to lab directory
cd ~/neo4j_mastering/labs/lab_12

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate
```

### Step 2: Install Dependencies

```bash
# Upgrade pip
pip install --upgrade pip

# Install all requirements
pip install -r requirements.txt
```

### Step 3: Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit .env file with your Neo4j credentials
# (Use notepad, vim, nano, or any text editor)
```

**Required .env values:**
- `NEO4J_URI`: Your Neo4j connection string (default: bolt://localhost:7687)
- `NEO4J_USERNAME`: Your Neo4j username (default: neo4j)
- `NEO4J_PASSWORD`: Your Neo4j password
- `JWT_SECRET_KEY`: Generate a secure secret key for JWT tokens

**Generate a secure JWT secret key:**
```python
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Step 4: Launch Jupyter Lab

```bash
jupyter lab
```

This will open Jupyter Lab in your browser at http://localhost:8888

### Step 5: Work Through Notebooks

Open and execute notebooks in order:
1. `01_api_setup_and_configuration.ipynb`
2. `02_authentication_and_security.ipynb`
3. `03_customer_management_apis.ipynb`
4. `04_policy_and_claims_apis.ipynb`
5. `05_analytics_and_deployment.ipynb`

## Verification

Test your setup:

```python
# In a Jupyter notebook cell or Python shell:
from neo4j import GraphDatabase
import fastapi
import uvicorn

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

## Troubleshooting

### Import Errors
If you get import errors, ensure your virtual environment is activated:
```bash
# You should see (venv) in your command prompt
# If not, activate it again:
source venv/bin/activate  # Mac/Linux
venv\Scripts\activate     # Windows
```

### Neo4j Connection Errors
- Ensure Neo4j is running: `docker ps` should show neo4j container
- Check connection details in .env match your Neo4j setup
- Verify you can connect using Neo4j Browser at http://localhost:7474

### Port Conflicts
If port 8000 is already in use, change `API_PORT` in .env file

## Deactivating Virtual Environment

When you're done:
```bash
deactivate
```
