# Lab 15 Environment Setup Guide

## Quick Start

### Step 1: Create Virtual Environment

**Windows:**
```bash
cd C:\Users\%USERNAME%\neo4j_mastering\labs\lab_15
python -m venv venv
venv\Scripts\activate
```

**Mac/Linux:**
```bash
cd ~/neo4j_mastering/labs/lab_15
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
1. `01_life_insurance_integration.ipynb`
2. `02_commercial_insurance.ipynb`
3. `03_specialty_products.ipynb`
4. `04_reinsurance_networks.ipynb`
5. `05_global_operations.ipynb`

## What You'll Build

This lab expands the insurance platform to include:

### Product Lines
- **Life Insurance**: Term Life, Whole Life with cash values
- **Commercial Insurance**: General Liability, Workers Comp, Cyber
- **Specialty**: Professional Liability, Umbrella Coverage
- **Reinsurance**: Catastrophe, Quota Share, Surplus treaties

### Global Operations
- **Countries**: USA, United Kingdom, Canada
- **Currencies**: USD, GBP, CAD with exchange rates
- **Regulators**: FCA/PRA (UK), OSFI (Canada)
- **Compliance**: Solvency II, MCCSR

## Prerequisites

- Completed Labs 12, 13, and 14
- Neo4j running with insurance data from previous labs
- Python 3.8+
- Pandas and NumPy for data analysis

## Verification

```python
# Test setup
from neo4j import GraphDatabase
import pandas as pd
import numpy as np

print("✅ All packages installed")

# Test Neo4j connection
driver = GraphDatabase.driver(
    "bolt://localhost:7687",
    auth=("neo4j", "password")
)
driver.verify_connectivity()
print("✅ Neo4j connection successful")
driver.close()
```

## Business Concepts Covered

- Life insurance underwriting and cash value mechanics
- Commercial multi-line insurance for businesses
- Claims-made vs. occurrence coverage
- Reinsurance risk transfer and treaty structures
- International regulatory compliance
- Multi-currency operations and FX risk
