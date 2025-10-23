# Lab 13: Interactive Insurance Web Application

**Duration:** 45 minutes
**Database State:** 720 → 800 nodes, 900 → 1000 relationships

## Overview

This lab teaches you to build interactive web applications with real-time features using FastAPI, WebSockets, and graph visualization. You'll create dashboards for customers, agents, claims adjusters, and executives with live data updates.

## Notebook Structure

Work through these notebooks in order:

### 1. Web App Environment Setup (01)
**File:** `01_web_app_environment_setup.ipynb`
**Topics:**
- Installation of web application dependencies
- Import of required libraries
- Neo4j database connection manager
- Database connectivity verification
- Environment initialization

### 2. FastAPI and WebSocket Setup (02)
**File:** `02_fastapi_and_websocket_setup.ipynb`
**Topics:**
- FastAPI application with template support
- Jinja2 template rendering configuration
- WebSocket connection manager implementation
- Connection/disconnection handling
- Broadcast and personal messaging

### 3. Dashboard Routes and APIs (03)
**File:** `03_dashboard_routes_and_apis.ipynb`
**Topics:**
- Main dashboard routes for all user roles
- Customer portal interface
- Customer overview API with comprehensive data
- Customer graph visualization API for D3.js
- Network data structure for interactive visualizations

### 4. Agent and Claims Dashboards (04)
**File:** `04_agent_and_claims_dashboards.ipynb`
**Topics:**
- Agent dashboard with sales metrics
- Sales pipeline and opportunity analysis
- Customer portfolio management
- Claims adjuster dashboard
- Fraud detection and risk scoring
- Case management and investigation tools

### 5. Real-time Features and Deployment (05)
**File:** `05_realtime_features_and_deployment.ipynb`
**Topics:**
- Executive KPI dashboard
- Business trend analysis
- WebSocket endpoints for real-time updates
- Live notifications (new customers, claims, policies)
- Application server deployment
- WebSocket connection examples

## Prerequisites

- Python 3.8+
- Neo4j Enterprise running on localhost:7687
- Completed Lab 12 (Production Insurance API Development)

## Installation

```bash
pip install jupyterlab fastapi uvicorn jinja2 python-multipart websockets neo4j
jupyter lab
```

## Running the Lab

1. Open Jupyter Lab
2. Navigate to the `lab_13` directory
3. Open notebooks in order (01 through 05)
4. Execute cells sequentially
5. Access web interfaces at:
   - Main app: http://localhost:8001
   - Customer portal: http://localhost:8001/customer
   - Agent dashboard: http://localhost:8001/agent
   - Claims dashboard: http://localhost:8001/claims
   - Executive dashboard: http://localhost:8001/executive

## Key Learning Outcomes

- Build interactive web applications with FastAPI
- Implement WebSocket connections for real-time updates
- Create role-based dashboards (customer, agent, adjuster, executive)
- Generate graph visualizations with D3.js
- Implement fraud detection algorithms
- Deploy full-stack applications with live data
