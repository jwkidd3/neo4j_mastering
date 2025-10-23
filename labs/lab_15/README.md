# Lab 15: Multi-Line Insurance Platform

**Duration:** 60 minutes
**Database State:** 850 → 950 nodes, 1100 → 1200 relationships

## Overview

This lab expands the insurance platform to support multiple product lines including Life, Commercial, Specialty insurance, Reinsurance networks, and Global operations across multiple countries and currencies.

## Notebook Structure

Work through these notebooks in order:

### 1. Life Insurance Integration (01)
**File:** `01_life_insurance_integration.ipynb`
**Topics:**
- Life insurance product creation (Term Life, Whole Life)
- Customer profiles with underwriting factors
- Term life policies with 20-year coverage
- Whole life policies with cash value accumulation
- Beneficiary management (primary/contingent)
- Portfolio analysis and cash value tracking

**Business Concepts:**
- Term vs. permanent insurance
- Cash value mechanics and surrender values
- Beneficiary structures
- Medical exam requirements

### 2. Commercial Insurance (02)
**File:** `02_commercial_insurance.ipynb`
**Topics:**
- Commercial products (General Liability, Workers Comp, Cyber)
- Business customer profiles with NAICS/SIC codes
- Multi-policy commercial accounts
- Workers compensation with experience modification
- Cyber liability with breach response services

**Business Concepts:**
- NAICS/SIC industry classification
- Multi-line commercial packages
- Workers comp classification codes
- Cyber risk assessment

### 3. Specialty Products (03)
**File:** `03_specialty_products.ipynb`
**Topics:**
- Professional Liability (E&O) with claims-made coverage
- Umbrella Liability for excess coverage
- Coverage tower analysis
- Underlying policy verification

**Business Concepts:**
- Claims-made vs. occurrence coverage
- Retroactive dates and extended reporting
- Umbrella attachment points
- Coverage towers and limit stacking
- Defense costs in addition to limits

### 4. Reinsurance Networks (04)
**File:** `04_reinsurance_networks.ipynb`
**Topics:**
- Reinsurance companies (Munich Re, Swiss Re, Berkshire Hathaway)
- Catastrophe excess of loss treaties
- Quota share treaties with ceding commissions
- Surplus share treaties
- Multi-party syndication
- Treaty performance analysis

**Business Concepts:**
- Reinsurance fundamentals and risk transfer
- Treaty types (Cat XOL, Quota Share, Surplus Share)
- Ceding and profit commissions
- A.M. Best financial strength ratings

### 5. Global Operations (05)
**File:** `05_global_operations.ipynb`
**Topics:**
- UK subsidiary with FCA/PRA regulation and Solvency II
- Canada subsidiary with OSFI regulation and MCCSR
- Multi-currency exchange system (USD, GBP, CAD)
- Currency conversion with bid-ask spreads
- Financial consolidation to USD
- Complete platform verification

**Business Concepts:**
- International insurance regulation
- Solvency II capital requirements (SCR, MCR)
- MCCSR ratio for Canadian insurers
- Multi-currency operations and FX risk
- Global financial consolidation

## Prerequisites

- Python 3.8+
- Neo4j Enterprise running
- Completed Labs 12-14

## Installation

```bash
pip install jupyterlab neo4j pandas numpy
jupyter lab
```

## Running the Lab

1. Open Jupyter Lab
2. Navigate to the `lab_15` directory
3. Open notebooks in order (01 through 05)
4. Execute cells sequentially
5. Review results using pandas DataFrames

## Platform Coverage

- **5 Insurance Lines:** Personal, Life, Commercial, Specialty, Reinsurance
- **3 Countries:** USA, United Kingdom, Canada
- **3 Currencies:** USD, GBP, CAD
- **6 Product Types:** Term Life, Whole Life, General Liability, Workers Comp, Cyber, Professional Liability, Umbrella
- **3 Reinsurance Companies:** Multiple treaty types
- **2 Regulatory Frameworks:** UK Solvency II, Canadian OSFI

## Key Learning Outcomes

- Expand platform to support multiple insurance product lines
- Model life insurance with cash values and beneficiaries
- Create commercial insurance for business customers
- Implement specialty products (Professional Liability, Umbrella)
- Build reinsurance networks with treaty management
- Support global operations with multiple currencies
- Understand international regulatory frameworks
- Perform multi-currency financial consolidation
