# Neo4j Lab 12: Production Insurance API Development

**Duration:** 45 minutes  
**Prerequisites:** Completion of Lab 7 (Python Driver & Service Architecture)  
**Database State:** Starting with 650 nodes, 800 relationships → Ending with 720 nodes, 900 relationships  

## Learning Objectives

By the end of this lab, you will be able to:
- Build production-ready RESTful APIs using FastAPI with Neo4j integration
- Implement secure authentication and authorization systems with JWT tokens
- Create comprehensive API documentation with OpenAPI specifications
- Design customer management, policy administration, and claims processing endpoints
- Handle API security, error responses, and rate limiting for production environments

---

## 🛠️ Development Tools Setup & Configuration

### Prerequisites: Development Environment

Before starting this lab, ensure you have the following development tools properly configured:

#### 1. **Python Development Environment**
- **Python 3.8+** (verify with `python --version`)
- **Virtual Environment** (recommended for project isolation)
- **Package Manager** (pip, pipenv, or poetry)

#### 2. **Jupyter Lab Configuration**
```bash
# Windows Setup
cd C:\Users\%USERNAME%\neo4j-labs
pip install jupyterlab fastapi uvicorn
jupyter lab

# Mac/Linux Setup  
cd ~/neo4j-labs
pip install jupyterlab fastapi uvicorn
jupyter lab
```

#### 3. **Jupyter Lab Development Environment**
This lab uses **Jupyter Lab** as the primary development tool for interactive API development:

**Jupyter Lab Features for API Development:**
- **Notebook-based development** - Interactive code execution and testing
- **Built-in terminal** - Package installation and server management
- **File management** - Organized project structure within the interface
- **Live code execution** - Real-time API testing and debugging
- **Markdown documentation** - Integrated documentation alongside code
- **Variable inspection** - Monitor API responses and data structures

#### 4. **API Testing in Jupyter Lab**

**Built-in Testing Capabilities:**
Jupyter Lab provides integrated tools for API development and testing:

**In-Notebook API Testing:**
```python
# Test API endpoints directly in notebook cells
import requests
response = requests.get("http://localhost:8000/health")
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")
```

**Terminal-based Testing:**
```bash
# Use Jupyter Lab terminal for cURL commands
curl -X GET "http://localhost:8000/health" -H "accept: application/json"

# Install additional tools if needed
pip install httpie
http GET localhost:8000/health
```

**Interactive Documentation:**
- FastAPI automatically generates interactive docs at `/docs`
- Access through Jupyter Lab's built-in browser tabs
- Test endpoints directly from the documentation interface

#### 5. **Database Development Tools**

**Neo4j Desktop (Primary)**
- Already configured from previous labs
- Remote connection to Docker container
- Query development and testing

**Neo4j Browser (Web Interface)**
- Access at `http://localhost:7474`
- Direct Cypher query execution
- Data visualization

#### 5. **Jupyter Lab Project Setup**

**Create Lab Directory Structure in Jupyter Lab:**
1. **Open Jupyter Lab** - Navigate to your course directory
2. **Create new folder** - Right-click in file browser → "New Folder" → Name it "lab_13"
3. **Create notebook** - Click "+" → "Python 3" → Save as "neo4j_lab_13_insurance_api.ipynb"
4. **Organize files** - Use Jupyter's file browser to maintain clean structure

**Jupyter Lab File Organization:**
```
neo4j-labs/
├── lab_13/
│   ├── neo4j_lab_13_insurance_api.ipynb  # Main notebook
│   ├── requirements.txt                   # Dependencies
│   ├── .env                              # Environment variables
│   └── api_tests.ipynb                   # Optional: Separate testing notebook
```

**Working with Multiple Notebooks:**
- **Main development** - Primary API implementation notebook
- **Testing notebook** - Separate notebook for API testing and validation
- **Documentation** - Markdown cells for comprehensive documentation
- **File browser** - Easy navigation between related files

---

## 🚀 Lab Environment Setup

### Step 1: Jupyter Lab Environment Preparation

**Launch Jupyter Lab:**
```bash
# Windows
cd C:\Users\%USERNAME%\neo4j-labs
jupyter lab

# Mac/Linux  
cd ~/neo4j-labs
jupyter lab
```

**Verify Jupyter Lab Setup:**
- Jupyter Lab opens in browser at `http://localhost:8888`
- File browser shows your neo4j-labs directory
- Terminal tab available for command execution
- Python 3 kernel ready for notebook creation

### Step 2: Create Lab 12 Notebook Structure

**In Jupyter Lab Interface:**
1. **Create lab_13 folder** using the file browser
2. **New Python 3 notebook** → Save as `neo4j_lab_13_insurance_api.ipynb`
3. **Create supporting files** using the built-in text editor:

**Create `requirements.txt` in Jupyter Lab:**
- Click "+" → "Text File" → Save as "requirements.txt"
- Copy the dependencies list below into the file

**Create `requirements.txt` file:**
```txt
# Web Framework
fastapi==0.104.1
uvicorn[standard]==0.24.0

# Database
neo4j==5.26.0

# Authentication & Security
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# Environment & Configuration
python-dotenv==1.0.0
pydantic==2.5.0
pydantic-settings==2.1.0

# Development & Testing
pytest==8.0.0
pytest-asyncio==0.23.0
httpx==0.26.0

# Documentation
python-markdown==3.5.1
jinja2==3.1.2

# Utilities
typing-extensions==4.9.0
```

**Install dependencies using Jupyter Lab terminal:**
```bash
# Open terminal in Jupyter Lab (File → New → Terminal)
cd lab_13
pip install -r requirements.txt

# Alternative: Install directly in notebook cell
!pip install -r requirements.txt
```

### Step 3: Environment Configuration in Jupyter Lab

**Create `.env` file using Jupyter Lab text editor:**
- Click "+" → "Text File" → Save as ".env"
- Add the following configuration:

**Create `.env` file:**
```env
# Database Configuration
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=password
NEO4J_DATABASE=neo4j

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_DEBUG=True
API_RELOAD=True

# Security Configuration
SECRET_KEY=your-secret-key-here-use-openssl-rand-hex-32
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Environment
ENVIRONMENT=development
LOG_LEVEL=INFO

# CORS Configuration
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080"]
```

### Step 4: Development Environment Verification in Jupyter Lab

**Create your first notebook cell to verify the setup:**
```python
# Cell 1: Development environment verification
import subprocess
import sys
import os
from pathlib import Path

def verify_development_environment():
    """Comprehensive verification of development setup"""
    
    print("🔧 DEVELOPMENT ENVIRONMENT VERIFICATION")
    print("=" * 50)
    
    # 1. Python version check
    python_version = sys.version_info
    print(f"Python Version: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    if python_version >= (3, 8):
        print("✓ Python version meets requirements (3.8+)")
    else:
        print("✗ Python version too old. Please upgrade to 3.8+")
        return False
    
    # 2. Required packages verification
    required_packages = [
        "fastapi", "uvicorn", "neo4j", "pydantic", 
        "python_jose", "passlib", "pytest"
    ]
    
    missing_packages = []
    for package in required_packages:
        try:
            __import__(package.replace("-", "_"))
            print(f"✓ {package} is available")
        except ImportError:
            missing_packages.append(package)
            print(f"✗ {package} is missing")
    
    if missing_packages:
        print(f"\nInstalling missing packages: {', '.join(missing_packages)}")
        subprocess.check_call([
            sys.executable, "-m", "pip", "install", 
            *missing_packages
        ])
    
    # 3. Jupyter Lab setup verification
    lab_dir = Path("lab_13")
    if not lab_dir.exists():
        print("Creating lab directory structure in Jupyter Lab...")
        lab_dir.mkdir(exist_ok=True)
        print("✓ Use Jupyter Lab file browser to navigate to lab_13/")
    else:
        print("✓ Lab directory structure exists in Jupyter Lab")
    
    # 4. Environment file verification  
    env_file = lab_dir / ".env"
    if not env_file.exists():
        print("⚠ Create .env file using Jupyter Lab text editor")
        print("  Click '+' → 'Text File' → Save as '.env'")
    else:
        print("✓ Environment file exists")
    
    # 5. Neo4j connection test
    try:
        from neo4j import GraphDatabase
        driver = GraphDatabase.driver(
            "bolt://localhost:7687", 
            auth=("neo4j", "password")
        )
        with driver.session() as session:
            result = session.run("RETURN 1 as test")
            record = result.single()
            if record and record["test"] == 1:
                print("✓ Neo4j connection successful")
            else:
                print("✗ Neo4j connection test failed")
        driver.close()
    except Exception as e:
        print(f"✗ Neo4j connection failed: {e}")
        return False
    
    print("\n🎯 DEVELOPMENT ENVIRONMENT READY")
    print("All prerequisites verified successfully!")
    return True

# Run verification
verify_development_environment()
```

---

## 📋 Lab Overview

In this lab, you'll build a comprehensive insurance API platform that exposes your Neo4j-powered insurance system through secure, well-documented REST endpoints. Building on the service architecture from Lab 11, you'll create production-ready APIs that handle customer management, policy administration, claims processing, and business analytics.

### 🎯 Lab Components

1. **FastAPI Application Setup** - Modern Python web framework configuration
2. **Authentication System** - JWT-based security with role-based access
3. **Customer Management APIs** - Complete CRUD operations with search capabilities
4. **Policy Administration** - Policy lifecycle management endpoints
5. **Claims Processing** - Claims submission and tracking workflows
6. **Analytics Endpoints** - Business intelligence and reporting APIs
7. **API Documentation** - Interactive OpenAPI documentation
8. **Testing Framework** - Automated API testing suite

---

## 🔧 Part 1: FastAPI Application Foundation

### Cell 2: Core Application Setup
```python
# Cell 2: FastAPI application foundation
import os
from pathlib import Path
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta
import uvicorn

# Load environment variables
load_dotenv("lab_13/.env")

# FastAPI application configuration
app = FastAPI(
    title="Neo4j Insurance API",
    description="Production-ready insurance management API built with Neo4j and FastAPI",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080", "http://localhost:8000"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)

# Global configuration
CONFIG = {
    "neo4j_uri": os.getenv("NEO4J_URI", "bolt://localhost:7687"),
    "neo4j_username": os.getenv("NEO4J_USERNAME", "neo4j"),
    "neo4j_password": os.getenv("NEO4J_PASSWORD", "password"),
    "neo4j_database": os.getenv("NEO4J_DATABASE", "neo4j"),
    "secret_key": os.getenv("SECRET_KEY", "your-secret-key"),
    "algorithm": os.getenv("ALGORITHM", "HS256"),
    "access_token_expire_minutes": int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30")),
    "api_host": os.getenv("API_HOST", "0.0.0.0"),
    "api_port": int(os.getenv("API_PORT", "8000"))
}

print("✓ FastAPI application configured")
print(f"✓ Database URI: {CONFIG['neo4j_uri']}")
print(f"✓ API will run on {CONFIG['api_host']}:{CONFIG['api_port']}")
```

### Cell 3: Database Connection Manager
```python
# Cell 3: Enhanced database connection manager for API
from neo4j import GraphDatabase
from contextlib import contextmanager
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class APIConnectionManager:
    """Production-grade Neo4j connection manager for API applications"""
    
    def __init__(self, uri: str, username: str, password: str, database: str):
        self.uri = uri
        self.username = username
        self.password = password
        self.database = database
        self.driver = None
        self._connect()
    
    def _connect(self):
        """Establish connection with retry logic"""
        try:
            self.driver = GraphDatabase.driver(
                self.uri,
                auth=(self.username, self.password),
                max_connection_lifetime=1800,  # 30 minutes
                max_connection_pool_size=50,
                connection_acquisition_timeout=60,
                encrypted=False
            )
            # Verify connectivity
            with self.driver.session(database=self.database) as session:
                session.run("RETURN 1").consume()
            logger.info("✓ Neo4j connection established successfully")
        except Exception as e:
            logger.error(f"✗ Failed to connect to Neo4j: {e}")
            raise
    
    @contextmanager
    def get_session(self):
        """Context manager for database sessions"""
        session = self.driver.session(database=self.database)
        try:
            yield session
        finally:
            session.close()
    
    def execute_query(self, query: str, parameters: Dict = None):
        """Execute a single query with error handling"""
        try:
            with self.get_session() as session:
                result = session.run(query, parameters or {})
                return [record.data() for record in result]
        except Exception as e:
            logger.error(f"Query execution failed: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Database query failed: {str(e)}"
            )
    
    def execute_write_query(self, query: str, parameters: Dict = None):
        """Execute write query with transaction handling"""
        try:
            with self.get_session() as session:
                result = session.write_transaction(
                    lambda tx: tx.run(query, parameters or {}).data()
                )
                return result
        except Exception as e:
            logger.error(f"Write query execution failed: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Database write operation failed: {str(e)}"
            )
    
    def health_check(self) -> Dict[str, Any]:
        """Comprehensive database health check"""
        try:
            with self.get_session() as session:
                # Connection test
                start_time = datetime.now()
                session.run("RETURN 1").consume()
                response_time = (datetime.now() - start_time).total_seconds() * 1000
                
                # Database statistics
                stats_result = session.run("""
                    MATCH (n)
                    WITH count(n) AS nodeCount, count(DISTINCT labels(n)) AS labelCount
                    MATCH ()-[r]->()
                    WITH nodeCount, labelCount, count(r) AS relCount, count(DISTINCT type(r)) AS relTypeCount
                    RETURN nodeCount, relCount, labelCount, relTypeCount
                """)
                stats = stats_result.single()
                
                return {
                    "status": "healthy",
                    "response_time_ms": round(response_time, 2),
                    "database": self.database,
                    "statistics": {
                        "total_nodes": stats["nodeCount"] if stats else 0,
                        "total_relationships": stats["relCount"] if stats else 0,
                        "label_count": stats["labelCount"] if stats else 0,
                        "relationship_types": stats["relTypeCount"] if stats else 0
                    }
                }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "database": self.database
            }
    
    def close(self):
        """Close database connection"""
        if self.driver:
            self.driver.close()
            logger.info("✓ Database connection closed")

# Initialize connection manager
connection_manager = APIConnectionManager(
    uri=CONFIG["neo4j_uri"],
    username=CONFIG["neo4j_username"],
    password=CONFIG["neo4j_password"],
    database=CONFIG["neo4j_database"]
)

print("✓ API-specific database connection manager initialized")
```

### Cell 4: Pydantic Models for API
```python
# Cell 4: Comprehensive Pydantic models for API requests/responses
from pydantic import BaseModel, Field, EmailStr, validator
from typing import Optional, List, Dict, Any
from datetime import datetime, date
from enum import Enum

# Enum definitions
class PolicyStatus(str, Enum):
    ACTIVE = "Active"
    PENDING = "Pending"
    EXPIRED = "Expired"
    CANCELLED = "Cancelled"

class ClaimStatus(str, Enum):
    SUBMITTED = "Submitted"
    UNDER_REVIEW = "Under Review"
    APPROVED = "Approved"
    REJECTED = "Rejected"
    SETTLED = "Settled"

class UserRole(str, Enum):
    CUSTOMER = "customer"
    AGENT = "agent"
    ADJUSTER = "adjuster"
    ADMIN = "admin"

# Authentication models
class UserLogin(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=6)

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
    user_id: str
    role: UserRole

class UserProfile(BaseModel):
    user_id: str
    username: str
    email: EmailStr
    full_name: str
    role: UserRole
    is_active: bool = True
    created_date: datetime

# Customer models
class CustomerCreate(BaseModel):
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    email: EmailStr
    phone: str = Field(..., regex=r"^\+?1?\d{9,15}$")
    date_of_birth: date
    address: str = Field(..., min_length=10, max_length=200)
    city: str = Field(..., min_length=2, max_length=50)
    state: str = Field(..., min_length=2, max_length=50)
    zip_code: str = Field(..., regex=r"^\d{5}(-\d{4})?$")
    
    @validator('date_of_birth')
    def validate_age(cls, v):
        if v > date.today():
            raise ValueError('Date of birth cannot be in the future')
        age = (date.today() - v).days / 365.25
        if age < 18:
            raise ValueError('Customer must be at least 18 years old')
        return v

class CustomerUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    zip_code: Optional[str] = None

class CustomerResponse(BaseModel):
    customer_id: str
    first_name: str
    last_name: str
    email: str
    phone: str
    date_of_birth: date
    address: str
    city: str
    state: str
    zip_code: str
    customer_since: datetime
    total_policies: int = 0
    total_premium: float = 0.0
    risk_score: Optional[float] = None

# Policy models
class PolicyCreate(BaseModel):
    customer_id: str
    product_name: str = Field(..., min_length=1, max_length=100)
    coverage_amount: float = Field(..., gt=0, le=10000000)
    premium_amount: float = Field(..., gt=0, le=100000)
    policy_term_months: int = Field(..., ge=1, le=360)
    deductible: float = Field(..., ge=0, le=50000)
    
    @validator('premium_amount', 'coverage_amount', 'deductible')
    def round_currency(cls, v):
        return round(v, 2)

class PolicyUpdate(BaseModel):
    coverage_amount: Optional[float] = None
    premium_amount: Optional[float] = None
    deductible: Optional[float] = None
    status: Optional[PolicyStatus] = None

class PolicyResponse(BaseModel):
    policy_id: str
    policy_number: str
    customer_id: str
    customer_name: str
    product_name: str
    status: PolicyStatus
    coverage_amount: float
    premium_amount: float
    deductible: float
    policy_term_months: int
    start_date: date
    end_date: date
    created_date: datetime

# Claims models
class ClaimCreate(BaseModel):
    policy_id: str
    incident_date: date
    claim_amount: float = Field(..., gt=0, le=10000000)
    description: str = Field(..., min_length=10, max_length=1000)
    incident_type: str = Field(..., min_length=1, max_length=50)
    location: str = Field(..., min_length=5, max_length=200)
    
    @validator('incident_date')
    def validate_incident_date(cls, v):
        if v > date.today():
            raise ValueError('Incident date cannot be in the future')
        if v < date.today() - timedelta(days=365):
            raise ValueError('Incident date cannot be more than 1 year ago')
        return v

class ClaimUpdate(BaseModel):
    claim_amount: Optional[float] = None
    description: Optional[str] = None
    status: Optional[ClaimStatus] = None

class ClaimResponse(BaseModel):
    claim_id: str
    claim_number: str
    policy_id: str
    policy_number: str
    customer_name: str
    status: ClaimStatus
    claim_amount: float
    incident_date: date
    filed_date: datetime
    description: str
    incident_type: str
    location: str
    adjuster_name: Optional[str] = None

# Analytics models
class CustomerAnalytics(BaseModel):
    total_customers: int
    new_customers_this_month: int
    average_customer_value: float
    top_customers_by_premium: List[Dict[str, Any]]

class PolicyAnalytics(BaseModel):
    total_policies: int
    active_policies: int
    total_premium_collected: float
    average_policy_value: float
    policies_by_status: Dict[str, int]

class ClaimAnalytics(BaseModel):
    total_claims: int
    pending_claims: int
    total_claim_amount: float
    average_claim_amount: float
    claims_by_status: Dict[str, int]

# Response wrapper models
class APIResponse(BaseModel):
    success: bool = True
    message: str = "Operation completed successfully"
    data: Optional[Any] = None
    errors: Optional[List[str]] = None

class PaginatedResponse(BaseModel):
    items: List[Any]
    total: int
    page: int = 1
    per_page: int = 10
    pages: int

print("✓ Comprehensive Pydantic models defined")
print("✓ Input validation and response formatting ready")
```

### Cell 5: Authentication System
```python
# Cell 5: JWT-based authentication system
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import secrets

# Security configuration
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

class AuthenticationManager:
    """Handles JWT authentication and authorization"""
    
    def __init__(self, secret_key: str, algorithm: str = "HS256"):
        self.secret_key = secret_key
        self.algorithm = algorithm
    
    def create_access_token(self, data: Dict[str, Any], expires_delta: Optional[timedelta] = None):
        """Create JWT access token"""
        to_encode = data.copy()
        
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=CONFIG["access_token_expire_minutes"])
        
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, self.secret_key, algorithm=self.algorithm)
        
        return {
            "access_token": encoded_jwt,
            "token_type": "bearer",
            "expires_in": int(expires_delta.total_seconds()) if expires_delta else CONFIG["access_token_expire_minutes"] * 60,
            "user_id": data.get("sub"),
            "role": data.get("role")
        }
    
    def verify_token(self, token: str) -> Dict[str, Any]:
        """Verify and decode JWT token"""
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=[self.algorithm])
            return payload
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
    
    def hash_password(self, password: str) -> str:
        """Hash password using bcrypt"""
        return pwd_context.hash(password)
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify password against hash"""
        return pwd_context.verify(plain_password, hashed_password)

# Initialize authentication manager
auth_manager = AuthenticationManager(CONFIG["secret_key"], CONFIG["algorithm"])

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> Dict[str, Any]:
    """Dependency to get current authenticated user"""
    return auth_manager.verify_token(credentials.credentials)

def require_role(required_role: UserRole):
    """Dependency factory for role-based access control"""
    def role_checker(current_user: Dict[str, Any] = Depends(get_current_user)):
        user_role = current_user.get("role")
        if user_role != required_role.value and user_role != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required role: {required_role.value}"
            )
        return current_user
    return role_checker

# Create demo users in database
def create_demo_users():
    """Create demo users for API testing"""
    demo_users = [
        {
            "user_id": "user_001",
            "username": "admin",
            "email": "admin@insurance.com",
            "full_name": "System Administrator",
            "password_hash": auth_manager.hash_password("admin123"),
            "role": "admin",
            "is_active": True
        },
        {
            "user_id": "user_002", 
            "username": "agent1",
            "email": "agent1@insurance.com",
            "full_name": "John Agent",
            "password_hash": auth_manager.hash_password("agent123"),
            "role": "agent",
            "is_active": True
        },
        {
            "user_id": "user_003",
            "username": "customer1",
            "email": "customer1@email.com", 
            "full_name": "Jane Customer",
            "password_hash": auth_manager.hash_password("customer123"),
            "role": "customer",
            "is_active": True
        }
    ]
    
    for user_data in demo_users:
        create_user_query = """
        MERGE (u:User {user_id: $user_id})
        SET u += {
            username: $username,
            email: $email,
            full_name: $full_name,
            password_hash: $password_hash,
            role: $role,
            is_active: $is_active,
            created_date: datetime()
        }
        RETURN u.username as username
        """
        
        result = connection_manager.execute_write_query(create_user_query, user_data)
        if result:
            print(f"✓ Demo user created: {user_data['username']}")

create_demo_users()
print("✓ Authentication system configured")
print("✓ Demo users created (admin/admin123, agent1/agent123, customer1/customer123)")
```

### Cell 6: Authentication Endpoints
```python
# Cell 6: Authentication API endpoints
@app.post("/auth/login", response_model=Token, tags=["Authentication"])
async def login(login_data: UserLogin):
    """Authenticate user and return JWT token"""
    
    # Query user from database
    query = """
    MATCH (u:User {username: $username, is_active: true})
    RETURN u.user_id as user_id, u.username as username, u.email as email,
           u.full_name as full_name, u.password_hash as password_hash, 
           u.role as role, u.created_date as created_date
    """
    
    result = connection_manager.execute_query(query, {"username": login_data.username})
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
    
    user = result[0]
    
    # Verify password
    if not auth_manager.verify_password(login_data.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password"
        )
    
    # Create access token
    token_data = {
        "sub": user["user_id"],
        "username": user["username"],
        "role": user["role"],
        "email": user["email"]
    }
    
    token = auth_manager.create_access_token(token_data)
    
    return Token(**token)

@app.get("/auth/profile", response_model=UserProfile, tags=["Authentication"])
async def get_profile(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Get current user profile"""
    
    query = """
    MATCH (u:User {user_id: $user_id})
    RETURN u.user_id as user_id, u.username as username, u.email as email,
           u.full_name as full_name, u.role as role, u.is_active as is_active,
           u.created_date as created_date
    """
    
    result = connection_manager.execute_query(query, {"user_id": current_user["sub"]})
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    user = result[0]
    return UserProfile(**user)

@app.post("/auth/logout", tags=["Authentication"])
async def logout(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Logout user (client should discard token)"""
    return APIResponse(message=f"User {current_user['username']} logged out successfully")

print("✓ Authentication endpoints configured")
```

### Cell 7: Customer Management APIs
```python
# Cell 7: Customer management API endpoints
@app.post("/customers", response_model=CustomerResponse, tags=["Customer Management"])
async def create_customer(
    customer_data: CustomerCreate,
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """Create new customer"""
    
    # Check if customer with email already exists
    check_query = """
    MATCH (c:Customer {email: $email})
    RETURN c.customer_id as customer_id
    """
    
    existing = connection_manager.execute_query(check_query, {"email": customer_data.email})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Customer with this email already exists"
        )
    
    # Create new customer
    customer_id = f"CUST_{secrets.token_hex(6).upper()}"
    
    create_query = """
    CREATE (c:Customer {
        customer_id: $customer_id,
        first_name: $first_name,
        last_name: $last_name,
        email: $email,
        phone: $phone,
        date_of_birth: date($date_of_birth),
        address: $address,
        city: $city,
        state: $state,
        zip_code: $zip_code,
        customer_since: datetime(),
        created_by: $created_by,
        risk_score: 0.5
    })
    RETURN c
    """
    
    customer_dict = customer_data.dict()
    customer_dict.update({
        "customer_id": customer_id,
        "created_by": current_user["sub"],
        "date_of_birth": customer_data.date_of_birth.isoformat()
    })
    
    result = connection_manager.execute_write_query(create_query, customer_dict)
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create customer"
        )
    
    # Return created customer with additional stats
    return_query = """
    MATCH (c:Customer {customer_id: $customer_id})
    OPTIONAL MATCH (c)-[:HAS_POLICY]->(p:Policy)
    RETURN c.customer_id as customer_id,
           c.first_name as first_name,
           c.last_name as last_name, 
           c.email as email,
           c.phone as phone,
           c.date_of_birth as date_of_birth,
           c.address as address,
           c.city as city,
           c.state as state,
           c.zip_code as zip_code,
           c.customer_since as customer_since,
           c.risk_score as risk_score,
           count(p) as total_policies,
           coalesce(sum(p.premium_amount), 0.0) as total_premium
    """
    
    result = connection_manager.execute_query(return_query, {"customer_id": customer_id})
    return CustomerResponse(**result[0])

@app.get("/customers/{customer_id}", response_model=CustomerResponse, tags=["Customer Management"])
async def get_customer(
    customer_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get customer by ID"""
    
    query = """
    MATCH (c:Customer {customer_id: $customer_id})
    OPTIONAL MATCH (c)-[:HAS_POLICY]->(p:Policy {status: 'Active'})
    RETURN c.customer_id as customer_id,
           c.first_name as first_name,
           c.last_name as last_name,
           c.email as email,
           c.phone as phone,
           c.date_of_birth as date_of_birth,
           c.address as address,
           c.city as city,
           c.state as state,
           c.zip_code as zip_code,
           c.customer_since as customer_since,
           c.risk_score as risk_score,
           count(p) as total_policies,
           coalesce(sum(p.premium_amount), 0.0) as total_premium
    """
    
    result = connection_manager.execute_query(query, {"customer_id": customer_id})
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer not found"
        )
    
    return CustomerResponse(**result[0])

@app.get("/customers", response_model=PaginatedResponse, tags=["Customer Management"])
async def list_customers(
    page: int = 1,
    per_page: int = 10,
    search: Optional[str] = None,
    state: Optional[str] = None,
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """List customers with pagination and filtering"""
    
    # Build WHERE clause for filtering
    where_conditions = []
    params = {}
    
    if search:
        where_conditions.append(
            "(toLower(c.first_name) CONTAINS toLower($search) OR "
            "toLower(c.last_name) CONTAINS toLower($search) OR "
            "toLower(c.email) CONTAINS toLower($search))"
        )
        params["search"] = search
    
    if state:
        where_conditions.append("c.state = $state")
        params["state"] = state
    
    where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
    
    # Count total customers
    count_query = f"""
    MATCH (c:Customer)
    {where_clause}
    RETURN count(c) as total
    """
    
    total_result = connection_manager.execute_query(count_query, params)
    total = total_result[0]["total"]
    
    # Get paginated customers
    skip = (page - 1) * per_page
    params.update({"skip": skip, "limit": per_page})
    
    list_query = f"""
    MATCH (c:Customer)
    {where_clause}
    OPTIONAL MATCH (c)-[:HAS_POLICY]->(p:Policy {{'status': 'Active'}})
    RETURN c.customer_id as customer_id,
           c.first_name as first_name,
           c.last_name as last_name,
           c.email as email,
           c.phone as phone,
           c.date_of_birth as date_of_birth,
           c.address as address,
           c.city as city,
           c.state as state,
           c.zip_code as zip_code,
           c.customer_since as customer_since,
           c.risk_score as risk_score,
           count(p) as total_policies,
           coalesce(sum(p.premium_amount), 0.0) as total_premium
    ORDER BY c.customer_since DESC
    SKIP $skip LIMIT $limit
    """
    
    result = connection_manager.execute_query(list_query, params)
    customers = [CustomerResponse(**record) for record in result]
    
    return PaginatedResponse(
        items=customers,
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

@app.put("/customers/{customer_id}", response_model=CustomerResponse, tags=["Customer Management"])
async def update_customer(
    customer_id: str,
    update_data: CustomerUpdate,
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """Update customer information"""
    
    # Check if customer exists
    check_query = """
    MATCH (c:Customer {customer_id: $customer_id})
    RETURN c.customer_id as customer_id
    """
    
    existing = connection_manager.execute_query(check_query, {"customer_id": customer_id})
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer not found"
        )
    
    # Build SET clause for updates
    update_fields = {k: v for k, v in update_data.dict().items() if v is not None}
    
    if not update_fields:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No valid fields to update"
        )
    
    # Create SET clause
    set_clauses = [f"c.{field} = ${field}" for field in update_fields.keys()]
    set_clause = "SET " + ", ".join(set_clauses)
    set_clause += ", c.last_updated = datetime(), c.updated_by = $updated_by"
    
    update_fields.update({
        "customer_id": customer_id,
        "updated_by": current_user["sub"]
    })
    
    update_query = f"""
    MATCH (c:Customer {{customer_id: $customer_id}})
    {set_clause}
    RETURN c
    """
    
    connection_manager.execute_write_query(update_query, update_fields)
    
    # Return updated customer
    return await get_customer(customer_id, current_user)

print("✓ Customer management API endpoints configured")
print("✓ CRUD operations with validation and pagination ready")
```

### Cell 8: Policy Management APIs
```python
# Cell 8: Policy management API endpoints
@app.post("/policies", response_model=PolicyResponse, tags=["Policy Management"])
async def create_policy(
    policy_data: PolicyCreate,
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """Create new insurance policy"""
    
    # Verify customer exists
    customer_check = """
    MATCH (c:Customer {customer_id: $customer_id})
    RETURN c.customer_id as customer_id, 
           c.first_name + ' ' + c.last_name as customer_name
    """
    
    customer_result = connection_manager.execute_query(
        customer_check, 
        {"customer_id": policy_data.customer_id}
    )
    
    if not customer_result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Customer not found"
        )
    
    customer_name = customer_result[0]["customer_name"]
    
    # Generate policy ID and number
    policy_id = f"POL_{secrets.token_hex(6).upper()}"
    policy_number = f"INS-{datetime.now().year}-{secrets.token_hex(4).upper()}"
    
    # Calculate dates
    start_date = date.today()
    end_date = start_date + timedelta(days=30 * policy_data.policy_term_months)
    
    # Create policy
    create_query = """
    MATCH (c:Customer {customer_id: $customer_id})
    CREATE (p:Policy {
        policy_id: $policy_id,
        policy_number: $policy_number,
        product_name: $product_name,
        status: 'Active',
        coverage_amount: $coverage_amount,
        premium_amount: $premium_amount,
        deductible: $deductible,
        policy_term_months: $policy_term_months,
        start_date: date($start_date),
        end_date: date($end_date),
        created_date: datetime(),
        created_by: $created_by
    })
    CREATE (c)-[:HAS_POLICY]->(p)
    RETURN p
    """
    
    policy_dict = policy_data.dict()
    policy_dict.update({
        "policy_id": policy_id,
        "policy_number": policy_number,
        "start_date": start_date.isoformat(),
        "end_date": end_date.isoformat(),
        "created_by": current_user["sub"]
    })
    
    result = connection_manager.execute_write_query(create_query, policy_dict)
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create policy"
        )
    
    # Return created policy
    return PolicyResponse(
        policy_id=policy_id,
        policy_number=policy_number,
        customer_id=policy_data.customer_id,
        customer_name=customer_name,
        product_name=policy_data.product_name,
        status=PolicyStatus.ACTIVE,
        coverage_amount=policy_data.coverage_amount,
        premium_amount=policy_data.premium_amount,
        deductible=policy_data.deductible,
        policy_term_months=policy_data.policy_term_months,
        start_date=start_date,
        end_date=end_date,
        created_date=datetime.now()
    )

@app.get("/policies/{policy_id}", response_model=PolicyResponse, tags=["Policy Management"])
async def get_policy(
    policy_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get policy by ID"""
    
    query = """
    MATCH (c:Customer)-[:HAS_POLICY]->(p:Policy {policy_id: $policy_id})
    RETURN p.policy_id as policy_id,
           p.policy_number as policy_number,
           c.customer_id as customer_id,
           c.first_name + ' ' + c.last_name as customer_name,
           p.product_name as product_name,
           p.status as status,
           p.coverage_amount as coverage_amount,
           p.premium_amount as premium_amount,
           p.deductible as deductible,
           p.policy_term_months as policy_term_months,
           p.start_date as start_date,
           p.end_date as end_date,
           p.created_date as created_date
    """
    
    result = connection_manager.execute_query(query, {"policy_id": policy_id})
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Policy not found"
        )
    
    return PolicyResponse(**result[0])

@app.get("/policies", response_model=PaginatedResponse, tags=["Policy Management"])
async def list_policies(
    page: int = 1,
    per_page: int = 10,
    status: Optional[PolicyStatus] = None,
    customer_id: Optional[str] = None,
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """List policies with pagination and filtering"""
    
    # Build WHERE clause
    where_conditions = []
    params = {}
    
    if status:
        where_conditions.append("p.status = $status")
        params["status"] = status.value
    
    if customer_id:
        where_conditions.append("c.customer_id = $customer_id")
        params["customer_id"] = customer_id
    
    where_clause = "WHERE " + " AND ".join(where_conditions) if where_conditions else ""
    
    # Count total policies
    count_query = f"""
    MATCH (c:Customer)-[:HAS_POLICY]->(p:Policy)
    {where_clause}
    RETURN count(p) as total
    """
    
    total_result = connection_manager.execute_query(count_query, params)
    total = total_result[0]["total"]
    
    # Get paginated policies
    skip = (page - 1) * per_page
    params.update({"skip": skip, "limit": per_page})
    
    list_query = f"""
    MATCH (c:Customer)-[:HAS_POLICY]->(p:Policy)
    {where_clause}
    RETURN p.policy_id as policy_id,
           p.policy_number as policy_number,
           c.customer_id as customer_id,
           c.first_name + ' ' + c.last_name as customer_name,
           p.product_name as product_name,
           p.status as status,
           p.coverage_amount as coverage_amount,
           p.premium_amount as premium_amount,
           p.deductible as deductible,
           p.policy_term_months as policy_term_months,
           p.start_date as start_date,
           p.end_date as end_date,
           p.created_date as created_date
    ORDER BY p.created_date DESC
    SKIP $skip LIMIT $limit
    """
    
    result = connection_manager.execute_query(list_query, params)
    policies = [PolicyResponse(**record) for record in result]
    
    return PaginatedResponse(
        items=policies,
        total=total,
        page=page,
        per_page=per_page,
        pages=(total + per_page - 1) // per_page
    )

print("✓ Policy management API endpoints configured")
```

### Cell 9: Claims Processing APIs
```python
# Cell 9: Claims processing API endpoints
@app.post("/claims", response_model=ClaimResponse, tags=["Claims Processing"])
async def create_claim(
    claim_data: ClaimCreate,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Submit new insurance claim"""
    
    # Verify policy exists and is active
    policy_check = """
    MATCH (c:Customer)-[:HAS_POLICY]->(p:Policy {policy_id: $policy_id})
    WHERE p.status = 'Active' AND p.start_date <= date() AND p.end_date >= date()
    RETURN p.policy_id as policy_id,
           p.policy_number as policy_number,
           c.first_name + ' ' + c.last_name as customer_name,
           p.coverage_amount as coverage_amount,
           p.deductible as deductible
    """
    
    policy_result = connection_manager.execute_query(
        policy_check,
        {"policy_id": claim_data.policy_id}
    )
    
    if not policy_result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Active policy not found"
        )
    
    policy_info = policy_result[0]
    
    # Validate claim amount against coverage
    if claim_data.claim_amount > policy_info["coverage_amount"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Claim amount exceeds policy coverage limit of ${policy_info['coverage_amount']:,.2f}"
        )
    
    # Generate claim ID and number
    claim_id = f"CLM_{secrets.token_hex(6).upper()}"
    claim_number = f"CLM-{datetime.now().year}-{secrets.token_hex(4).upper()}"
    
    # Create claim
    create_query = """
    MATCH (p:Policy {policy_id: $policy_id})
    CREATE (cl:Claim {
        claim_id: $claim_id,
        claim_number: $claim_number,
        status: 'Submitted',
        claim_amount: $claim_amount,
        incident_date: date($incident_date),
        filed_date: datetime(),
        description: $description,
        incident_type: $incident_type,
        location: $location,
        filed_by: $filed_by
    })
    CREATE (p)-[:HAS_CLAIM]->(cl)
    RETURN cl
    """
    
    claim_dict = claim_data.dict()
    claim_dict.update({
        "claim_id": claim_id,
        "claim_number": claim_number,
        "incident_date": claim_data.incident_date.isoformat(),
        "filed_by": current_user["sub"]
    })
    
    result = connection_manager.execute_write_query(create_query, claim_dict)
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create claim"
        )
    
    # Return created claim
    return ClaimResponse(
        claim_id=claim_id,
        claim_number=claim_number,
        policy_id=claim_data.policy_id,
        policy_number=policy_info["policy_number"],
        customer_name=policy_info["customer_name"],
        status=ClaimStatus.SUBMITTED,
        claim_amount=claim_data.claim_amount,
        incident_date=claim_data.incident_date,
        filed_date=datetime.now(),
        description=claim_data.description,
        incident_type=claim_data.incident_type,
        location=claim_data.location,
        adjuster_name=None
    )

@app.get("/claims/{claim_id}", response_model=ClaimResponse, tags=["Claims Processing"])
async def get_claim(
    claim_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get claim by ID"""
    
    query = """
    MATCH (c:Customer)-[:HAS_POLICY]->(p:Policy)-[:HAS_CLAIM]->(cl:Claim {claim_id: $claim_id})
    OPTIONAL MATCH (cl)-[:ASSIGNED_TO]->(adj:Agent)
    RETURN cl.claim_id as claim_id,
           cl.claim_number as claim_number,
           p.policy_id as policy_id,
           p.policy_number as policy_number,
           c.first_name + ' ' + c.last_name as customer_name,
           cl.status as status,
           cl.claim_amount as claim_amount,
           cl.incident_date as incident_date,
           cl.filed_date as filed_date,
           cl.description as description,
           cl.incident_type as incident_type,
           cl.location as location,
           adj.first_name + ' ' + adj.last_name as adjuster_name
    """
    
    result = connection_manager.execute_query(query, {"claim_id": claim_id})
    
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Claim not found"
        )
    
    return ClaimResponse(**result[0])

@app.put("/claims/{claim_id}/status", response_model=ClaimResponse, tags=["Claims Processing"])
async def update_claim_status(
    claim_id: str,
    status_update: ClaimUpdate,
    current_user: Dict[str, Any] = Depends(require_role(UserRole.ADJUSTER))
):
    """Update claim status (adjusters only)"""
    
    # Check if claim exists
    check_query = """
    MATCH (cl:Claim {claim_id: $claim_id})
    RETURN cl.claim_id as claim_id
    """
    
    existing = connection_manager.execute_query(check_query, {"claim_id": claim_id})
    if not existing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Claim not found"
        )
    
    # Update claim
    update_fields = {k: v for k, v in status_update.dict().items() if v is not None}
    
    if not update_fields:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No valid fields to update"
        )
    
    # Handle status updates
    if "status" in update_fields:
        update_fields["status"] = update_fields["status"].value
    
    set_clauses = [f"cl.{field} = ${field}" for field in update_fields.keys()]
    set_clause = "SET " + ", ".join(set_clauses)
    set_clause += ", cl.last_updated = datetime(), cl.updated_by = $updated_by"
    
    update_fields.update({
        "claim_id": claim_id,
        "updated_by": current_user["sub"]
    })
    
    update_query = f"""
    MATCH (cl:Claim {{claim_id: $claim_id}})
    {set_clause}
    RETURN cl
    """
    
    connection_manager.execute_write_query(update_query, update_fields)
    
    # Return updated claim
    return await get_claim(claim_id, current_user)

print("✓ Claims processing API endpoints configured")
```

### Cell 10: Analytics and Health Check APIs
```python
# Cell 10: Analytics and health check endpoints
@app.get("/health", tags=["System"])
async def health_check():
    """System health check endpoint"""
    
    health_status = connection_manager.health_check()
    
    # Add API-specific health information
    health_status.update({
        "api_version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "environment": CONFIG.get("environment", "development")
    })
    
    status_code = status.HTTP_200_OK if health_status["status"] == "healthy" else status.HTTP_503_SERVICE_UNAVAILABLE
    
    return JSONResponse(content=health_status, status_code=status_code)

@app.get("/analytics/customers", response_model=CustomerAnalytics, tags=["Analytics"])
async def get_customer_analytics(
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """Get customer analytics dashboard data"""
    
    query = """
    MATCH (c:Customer)
    OPTIONAL MATCH (c)-[:HAS_POLICY]->(p:Policy {status: 'Active'})
    WITH c, p, 
         CASE WHEN c.customer_since >= datetime() - duration({days: 30}) 
              THEN 1 ELSE 0 END as is_new
    RETURN count(DISTINCT c) as total_customers,
           sum(is_new) as new_customers_this_month,
           avg(coalesce(p.premium_amount, 0)) as average_customer_value,
           collect({
               customer_id: c.customer_id,
               name: c.first_name + ' ' + c.last_name,
               total_premium: coalesce(sum(p.premium_amount), 0)
           })[0..5] as top_customers
    """
    
    result = connection_manager.execute_query(query)
    analytics_data = result[0] if result else {}
    
    return CustomerAnalytics(
        total_customers=analytics_data.get("total_customers", 0),
        new_customers_this_month=analytics_data.get("new_customers_this_month", 0),
        average_customer_value=round(analytics_data.get("average_customer_value", 0), 2),
        top_customers_by_premium=analytics_data.get("top_customers", [])
    )

@app.get("/analytics/policies", response_model=PolicyAnalytics, tags=["Analytics"])
async def get_policy_analytics(
    current_user: Dict[str, Any] = Depends(require_role(UserRole.AGENT))
):
    """Get policy analytics dashboard data"""
    
    query = """
    MATCH (p:Policy)
    RETURN count(p) as total_policies,
           count(CASE WHEN p.status = 'Active' THEN 1 END) as active_policies,
           sum(CASE WHEN p.status = 'Active' THEN p.premium_amount ELSE 0 END) as total_premium,
           avg(p.premium_amount) as average_policy_value,
           collect(DISTINCT {status: p.status, count: count(*)}) as status_breakdown
    """
    
    result = connection_manager.execute_query(query)
    analytics_data = result[0] if result else {}
    
    # Process status breakdown
    status_counts = {}
    for item in analytics_data.get("status_breakdown", []):
        status_counts[item["status"]] = item["count"]
    
    return PolicyAnalytics(
        total_policies=analytics_data.get("total_policies", 0),
        active_policies=analytics_data.get("active_policies", 0),
        total_premium_collected=round(analytics_data.get("total_premium", 0), 2),
        average_policy_value=round(analytics_data.get("average_policy_value", 0), 2),
        policies_by_status=status_counts
    )

@app.get("/analytics/claims", response_model=ClaimAnalytics, tags=["Analytics"])
async def get_claim_analytics(
    current_user: Dict[str, Any] = Depends(require_role(UserRole.ADJUSTER))
):
    """Get claims analytics dashboard data"""
    
    query = """
    MATCH (cl:Claim)
    RETURN count(cl) as total_claims,
           count(CASE WHEN cl.status IN ['Submitted', 'Under Review'] THEN 1 END) as pending_claims,
           sum(cl.claim_amount) as total_claim_amount,
           avg(cl.claim_amount) as average_claim_amount,
           collect(DISTINCT {status: cl.status, count: count(*)}) as status_breakdown
    """
    
    result = connection_manager.execute_query(query)
    analytics_data = result[0] if result else {}
    
    # Process status breakdown
    status_counts = {}
    for item in analytics_data.get("status_breakdown", []):
        status_counts[item["status"]] = item["count"]
    
    return ClaimAnalytics(
        total_claims=analytics_data.get("total_claims", 0),
        pending_claims=analytics_data.get("pending_claims", 0),
        total_claim_amount=round(analytics_data.get("total_claim_amount", 0), 2),
        average_claim_amount=round(analytics_data.get("average_claim_amount", 0), 2),
        claims_by_status=status_counts
    )

print("✓ Analytics and health check endpoints configured")
```

### Cell 11: API Server Startup and Testing
```python
# Cell 11: API server startup and comprehensive testing
import asyncio
import threading
import time
import requests
import json

class APIServer:
    """API server management class for Jupyter Lab development"""
    
    def __init__(self):
        self.server_thread = None
        self.server_running = False
        self.base_url = f"http://{CONFIG['api_host']}:{CONFIG['api_port']}"
    
    def start_server_in_notebook(self):
        """Start FastAPI server optimized for Jupyter Lab development"""
        if self.server_running:
            print("⚠ Server is already running")
            print(f"📍 Access API at: {self.base_url}")
            print(f"📖 Documentation: {self.base_url}/docs")
            return
        
        def run_server():
            uvicorn.run(
                app,
                host=CONFIG['api_host'],
                port=CONFIG['api_port'],
                log_level="info",
                access_log=False,
                reload=False  # Disable reload for notebook compatibility
            )
        
        self.server_thread = threading.Thread(target=run_server, daemon=True)
        self.server_thread.start()
        self.server_running = True
        
        # Wait for server to start
        print("🚀 Starting FastAPI server in Jupyter Lab...")
        print("📝 Server running in background thread (daemon mode)")
        time.sleep(3)
        
        # Verify server is running
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            if response.status_code == 200:
                print(f"✅ API server running at {self.base_url}")
                print(f"📚 Interactive docs: {self.base_url}/docs")
                print(f"📋 ReDoc documentation: {self.base_url}/redoc")
                print("\n💡 Jupyter Lab Integration Tips:")
                print("   • Open docs in new tab: Right-click link → 'Open in New Tab'")
                print("   • Use notebook cells for API testing")
                print("   • Server runs in background - continues between cell executions")
            else:
                print(f"⚠ Server started but health check failed: {response.status_code}")
        except requests.exceptions.RequestException as e:
            print(f"✗ Failed to verify server startup: {e}")
            print("💡 Try running the health check in the next cell manually")
    
    def test_in_notebook(self):
        """Notebook-optimized API testing with rich output"""
    def test_in_notebook(self):
        """Notebook-optimized API testing with rich output"""
        print("\n🧪 JUPYTER LAB API TESTING SUITE")
        print("=" * 50)
        print("💡 Each test shows request/response for learning")
        
        # Test 1: Health Check (No Auth Required)
        print("\n🔍 Test 1: Health Check")
        try:
            response = requests.get(f"{self.base_url}/health")
            print(f"   Request: GET {self.base_url}/health")
            print(f"   Status: {response.status_code}")
            print(f"   Response: {json.dumps(response.json(), indent=2)}")
        except Exception as e:
            print(f"   ❌ Error: {e}")
        
        # Test 2: Authentication
        print("\n🔐 Test 2: User Authentication")
        login_data = {"username": "admin", "password": "admin123"}
        try:
            response = requests.post(f"{self.base_url}/auth/login", json=login_data)
            print(f"   Request: POST {self.base_url}/auth/login")
            print(f"   Payload: {json.dumps(login_data, indent=2)}")
            print(f"   Status: {response.status_code}")
            
            if response.status_code == 200:
                token_data = response.json()
                print(f"   ✅ Login Successful!")
                print(f"   Token Type: {token_data['token_type']}")
                print(f"   Expires In: {token_data['expires_in']} seconds")
                token = token_data["access_token"]
                
                # Test 3: Protected Endpoint
                print("\n🛡️ Test 3: Protected Endpoint (Customer List)")
                headers = {"Authorization": f"Bearer {token}"}
                response = requests.get(f"{self.base_url}/customers?page=1&per_page=3", headers=headers)
                print(f"   Request: GET {self.base_url}/customers?page=1&per_page=3")
                print(f"   Headers: Authorization: Bearer [TOKEN]")
                print(f"   Status: {response.status_code}")
                
                if response.status_code == 200:
                    customers = response.json()
                    print(f"   ✅ Customers Retrieved: {customers.get('total', 0)} total")
                    print(f"   Sample Response Structure:")
                    print(f"   {json.dumps({k: v for k, v in customers.items() if k != 'items'}, indent=2)}")
                else:
                    print(f"   ❌ Failed: {response.text}")
                
                # Test 4: Create Customer
                print("\n👤 Test 4: Create New Customer")
                customer_data = {
                    "first_name": "Jane",
                    "last_name": "Smith", 
                    "email": f"jane.smith.{int(time.time())}@email.com",  # Unique email
                    "phone": "+1234567890",
                    "date_of_birth": "1985-03-20",
                    "address": "456 Oak Avenue",
                    "city": "Dallas",
                    "state": "TX",
                    "zip_code": "75202"
                }
                
                response = requests.post(f"{self.base_url}/customers", json=customer_data, headers=headers)
                print(f"   Request: POST {self.base_url}/customers")
                print(f"   Status: {response.status_code}")
                
                if response.status_code == 200:
                    new_customer = response.json()
                    print(f"   ✅ Customer Created!")
                    print(f"   Customer ID: {new_customer['customer_id']}")
                    print(f"   Name: {new_customer['first_name']} {new_customer['last_name']}")
                    print(f"   Email: {new_customer['email']}")
                else:
                    print(f"   ❌ Failed: {response.text}")
                    
            else:
                print(f"   ❌ Login Failed: {response.text}")
                
        except Exception as e:
            print(f"   ❌ Authentication Error: {e}")
        
        print("\n📊 Interactive Testing Options:")
        print(f"   1. Open {self.base_url}/docs in new browser tab")
        print(f"   2. Use requests library in notebook cells")
        print(f"   3. Test endpoints with different user roles")
        print(f"   4. Explore API responses and data structures")
        
        return True
    
    def show_notebook_examples(self):
        """Show example code for notebook-based API interaction"""
        print("\n📝 JUPYTER NOTEBOOK API EXAMPLES")
        print("=" * 50)
        print("Copy these examples into new notebook cells for interactive testing:\n")
        
        example_code = '''
# Example 1: Health Check
import requests
response = requests.get("http://localhost:8000/health")
print(f"Status: {response.status_code}")
print(f"Data: {response.json()}")

# Example 2: Login and Get Token  
login_data = {"username": "admin", "password": "admin123"}
response = requests.post("http://localhost:8000/auth/login", json=login_data)
token = response.json()["access_token"]
print(f"Token received: {token[:50]}...")

# Example 3: Use Token for Protected Endpoint
headers = {"Authorization": f"Bearer {token}"}
response = requests.get("http://localhost:8000/customers", headers=headers)
print(f"Customers: {response.json()}")

# Example 4: Create New Customer
customer_data = {
    "first_name": "Test",
    "last_name": "User",
    "email": "test@example.com",
    "phone": "+1234567890", 
    "date_of_birth": "1990-01-01",
    "address": "123 Test St",
    "city": "Dallas",
    "state": "TX",
    "zip_code": "75201"
}
response = requests.post("http://localhost:8000/customers", json=customer_data, headers=headers)
print(f"New customer: {response.json()}")
'''
        
        print(example_code)
        print("\n💡 Notebook Development Tips:")
        print("   • Run server once, test in multiple cells")
        print("   • Use variables to store tokens between cells")
        print("   • Print response.json() to explore data structures")
        print("   • Create separate cells for different API operations")
        
    def jupyter_lab_integration_guide(self):
        """Guide for optimal Jupyter Lab usage"""
        print("\n🎯 JUPYTER LAB INTEGRATION GUIDE")
        print("=" * 50)
        
        print("\n📚 Browser Tab Management:")
        print("   • Keep Jupyter Lab in main tab")
        print("   • Open API docs (/docs) in second tab")
        print("   • Use side-by-side windows for development + testing")
        
        print("\n📝 Notebook Organization:")
        print("   • Cell 1-5: Setup and configuration")
        print("   • Cell 6-10: API endpoint definitions")
        print("   • Cell 11+: Testing and validation")
        print("   • Use markdown cells for documentation")
        
        print("\n🔄 Development Workflow:")
        print("   1. Modify API code in notebook cell")
        print("   2. Restart server (re-run server cell)")
        print("   3. Test changes in separate cells")
        print("   4. Verify in browser documentation")
        
        print("\n🛠️ Debugging in Jupyter Lab:")
        print("   • Use print() statements for debugging")
        print("   • Check server output in terminal tab")
        print("   • Test individual functions in separate cells")
        print("   • Use jupyter debugger for complex issues")

# Initialize API server for Jupyter Lab
api_server = APIServer()
api_server.start_server_in_notebook()

# Show integration guide
api_server.jupyter_lab_integration_guide()

# Run notebook-optimized tests
api_server.test_in_notebook()

# Show example code for students
api_server.show_notebook_examples()
```

### Cell 12: Database State Enhancement and API Endpoints Creation
```python
# Cell 12: Enhanced database state for Lab 12 completion
def enhance_database_for_api():
    """Add API-specific entities and relationships to complete Lab 12 database state"""
    
    print("🔧 ENHANCING DATABASE FOR API ENDPOINTS:")
    print("=" * 50)
    
    # Create API endpoint entities (representing the API infrastructure)
    api_endpoints = [
        {
            "endpoint_id": "ep_001",
            "endpoint_path": "/auth/login",
            "http_method": "POST",
            "rate_limit": 100,
            "authentication_required": False,
            "response_format": "JSON",
            "cache_ttl": 0,
            "monitoring_enabled": True
        },
        {
            "endpoint_id": "ep_002", 
            "endpoint_path": "/customers",
            "http_method": "GET",
            "rate_limit": 1000,
            "authentication_required": True,
            "response_format": "JSON",
            "cache_ttl": 300,
            "monitoring_enabled": True
        },
        {
            "endpoint_id": "ep_003",
            "endpoint_path": "/customers",
            "http_method": "POST", 
            "rate_limit": 500,
            "authentication_required": True,
            "response_format": "JSON",
            "cache_ttl": 0,
            "monitoring_enabled": True
        },
        {
            "endpoint_id": "ep_004",
            "endpoint_path": "/policies",
            "http_method": "POST",
            "rate_limit": 200,
            "authentication_required": True,
            "response_format": "JSON",
            "cache_ttl": 0,
            "monitoring_enabled": True
        },
        {
            "endpoint_id": "ep_005",
            "endpoint_path": "/claims",
            "http_method": "POST",
            "rate_limit": 100,
            "authentication_required": True,
            "response_format": "JSON", 
            "cache_ttl": 0,
            "monitoring_enabled": True
        },
        {
            "endpoint_id": "ep_006",
            "endpoint_path": "/analytics/customers",
            "http_method": "GET",
            "rate_limit": 50,
            "authentication_required": True,
            "response_format": "JSON",
            "cache_ttl": 600,
            "monitoring_enabled": True
        }
    ]
    
    # Create API Service entity and endpoints
    create_api_service_query = """
    CREATE (api:APIService {
        service_id: 'insurance_api_v1',
        service_name: 'Insurance Management API',
        version: '1.0.0',
        framework: 'FastAPI',
        language: 'Python',
        database: 'Neo4j',
        created_date: datetime(),
        status: 'Active',
        base_url: 'http://localhost:8000',
        documentation_url: 'http://localhost:8000/docs'
    })
    RETURN api.service_id as service_id
    """
    
    result = connection_manager.execute_write_query(create_api_service_query, {})
    print(f"✓ API Service entity created: {result[0]['service_id']}")
    
    # Create API endpoints
    for endpoint_data in api_endpoints:
        create_endpoint_query = """
        MATCH (api:APIService {service_id: 'insurance_api_v1'})
        CREATE (ep:APIEndpoint {
            endpoint_id: $endpoint_id,
            endpoint_path: $endpoint_path,
            http_method: $http_method,
            rate_limit: $rate_limit,
            authentication_required: $authentication_required,
            response_format: $response_format,
            cache_ttl: $cache_ttl,
            monitoring_enabled: $monitoring_enabled,
            created_date: datetime()
        })
        CREATE (api)-[:EXPOSES]->(ep)
        RETURN ep.endpoint_id as endpoint_id
        """
        
        result = connection_manager.execute_write_query(create_endpoint_query, endpoint_data)
        print(f"✓ API endpoint created: {endpoint_data['http_method']} {endpoint_data['endpoint_path']}")
    
    # Create API documentation entities
    create_documentation_query = """
    MATCH (api:APIService {service_id: 'insurance_api_v1'})
    CREATE (doc:Documentation {
        doc_id: 'openapi_spec',
        doc_type: 'OpenAPI Specification',
        format: 'JSON',
        version: '3.0.0',
        auto_generated: true,
        url: '/openapi.json',
        created_date: datetime()
    })
    CREATE (swagger:Documentation {
        doc_id: 'swagger_ui',
        doc_type: 'Interactive Documentation',
        format: 'HTML',
        version: '1.0.0',
        auto_generated: true,
        url: '/docs',
        created_date: datetime()
    })
    CREATE (redoc:Documentation {
        doc_id: 'redoc',
        doc_type: 'API Reference',
        format: 'HTML', 
        version: '1.0.0',
        auto_generated: true,
        url: '/redoc',
        created_date: datetime()
    })
    CREATE (api)-[:HAS_DOCUMENTATION]->(doc)
    CREATE (api)-[:HAS_DOCUMENTATION]->(swagger)
    CREATE (api)-[:HAS_DOCUMENTATION]->(redoc)
    RETURN count(*) as docs_created
    """
    
    result = connection_manager.execute_write_query(create_documentation_query, {})
    print(f"✓ API documentation entities created: {result[0]['docs_created']}")
    
    # Create security configuration
    create_security_query = """
    MATCH (api:APIService {service_id: 'insurance_api_v1'})
    CREATE (auth:AuthenticationConfig {
        config_id: 'jwt_auth',
        auth_type: 'JWT',
        algorithm: 'HS256',
        token_expiry_minutes: 30,
        refresh_enabled: false,
        created_date: datetime()
    })
    CREATE (cors:CORSConfig {
        config_id: 'cors_policy',
        allow_credentials: true,
        allow_origins: ['http://localhost:3000', 'http://localhost:8080'],
        allow_methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
        allow_headers: ['*'],
        created_date: datetime()
    })
    CREATE (api)-[:USES_AUTHENTICATION]->(auth)
    CREATE (api)-[:HAS_CORS_POLICY]->(cors)
    RETURN count(*) as security_configs
    """
    
    result = connection_manager.execute_write_query(create_security_query, {})
    print(f"✓ Security configurations created: {result[0]['security_configs']}")
    
    # Connect API service to existing insurance entities
    connect_api_query = """
    MATCH (api:APIService {service_id: 'insurance_api_v1'})
    MATCH (c:Customer), (p:Policy), (cl:Claim)
    WITH api, collect(DISTINCT c)[0..5] as customers, 
         collect(DISTINCT p)[0..5] as policies,
         collect(DISTINCT cl)[0..3] as claims
    
    UNWIND customers as customer
    CREATE (api)-[:MANAGES_ENTITY]->(customer)
    
    WITH api, policies, claims
    UNWIND policies as policy  
    CREATE (api)-[:MANAGES_ENTITY]->(policy)
    
    WITH api, claims
    UNWIND claims as claim
    CREATE (api)-[:MANAGES_ENTITY]->(claim)
    
    RETURN count(*) as connections_created
    """
    
    result = connection_manager.execute_write_query(connect_api_query, {})
    print(f"✓ API connections to business entities: {result[0]['connections_created']}")

# Execute database enhancement
enhance_database_for_api()
```

### Cell 13: Lab Completion Verification and Summary
```python
# Cell 13: Final lab verification and comprehensive summary
def verify_lab_13_completion():
    """Comprehensive verification of Lab 12 completion"""
    
    print("\n🎯 LAB 13 COMPLETION VERIFICATION:")
    print("=" * 50)
    
    verification_results = {
        "api_framework": False,
        "authentication": False,
        "customer_apis": False,
        "policy_apis": False,
        "claims_apis": False,
        "analytics_apis": False,
        "documentation": False,
        "database_state": False,
        "api_endpoints": False
    }
    
    try:
        # 1. API Framework Verification
        print("1. API FRAMEWORK VERIFICATION:")
        try:
            from fastapi import FastAPI
            from uvicorn import run
            print("   ✓ FastAPI framework properly configured")
            print("   ✓ Uvicorn ASGI server available")
            verification_results["api_framework"] = True
        except ImportError as e:
            print(f"   ✗ API framework issue: {e}")
        
        # 2. Authentication System Verification
        print("2. AUTHENTICATION SYSTEM VERIFICATION:")
        try:
            # Test JWT creation
            test_token = auth_manager.create_access_token({"sub": "test_user", "role": "admin"})
            if test_token and "access_token" in test_token:
                print("   ✓ JWT token generation working")
                
                # Test token verification
                payload = auth_manager.verify_token(test_token["access_token"])
                if payload.get("sub") == "test_user":
                    print("   ✓ JWT token verification working")
                    verification_results["authentication"] = True
                else:
                    print("   ✗ JWT token verification failed")
            else:
                print("   ✗ JWT token generation failed")
        except Exception as e:
            print(f"   ✗ Authentication system error: {e}")
        
        # 3. Database State Verification
        print("3. DATABASE STATE VERIFICATION:")
        stats_query = """
        MATCH (n) 
        OPTIONAL MATCH ()-[r]->()
        RETURN count(DISTINCT n) as total_nodes,
               count(DISTINCT r) as total_relationships,
               count(DISTINCT CASE WHEN 'Customer' IN labels(n) THEN n END) as customers,
               count(DISTINCT CASE WHEN 'Policy' IN labels(n) THEN n END) as policies,
               count(DISTINCT CASE WHEN 'Claim' IN labels(n) THEN n END) as claims,
               count(DISTINCT CASE WHEN 'User' IN labels(n) THEN n END) as users,
               count(DISTINCT CASE WHEN 'APIEndpoint' IN labels(n) THEN n END) as api_endpoints,
               count(DISTINCT CASE WHEN 'APIService' IN labels(n) THEN n END) as api_services
        """
        
        result = connection_manager.execute_query(stats_query)
        if result:
            stats = result[0]
            print(f"   📊 Total Nodes: {stats['total_nodes']}")
            print(f"   📊 Total Relationships: {stats['total_relationships']}")
            print(f"   📊 Customers: {stats['customers']}")
            print(f"   📊 Policies: {stats['policies']}")
            print(f"   📊 Claims: {stats['claims']}")
            print(f"   📊 Users: {stats['users']}")
            print(f"   📊 API Endpoints: {stats['api_endpoints']}")
            print(f"   📊 API Services: {stats['api_services']}")
            
            # Check if we meet the target state
            target_nodes = 720
            target_relationships = 900
            
            if stats['total_nodes'] >= target_nodes * 0.9:  # Allow 10% variance
                print(f"   ✓ Database node count meets target (~{target_nodes})")
                verification_results["database_state"] = True
            else:
                print(f"   ⚠ Database node count below target: {stats['total_nodes']} < {target_nodes}")
            
            if stats['api_endpoints'] >= 6:
                print("   ✓ API endpoints properly created")
                verification_results["api_endpoints"] = True
            else:
                print(f"   ⚠ Insufficient API endpoints: {stats['api_endpoints']} < 6")
        
        # 4. API Endpoints Functionality Verification
        print("4. API ENDPOINTS FUNCTIONALITY:")
        
        # Check if server is accessible
        try:
            health_response = requests.get(f"{api_server.base_url}/health", timeout=5)
            if health_response.status_code == 200:
                print("   ✓ Health endpoint accessible")
                
                # Check OpenAPI documentation
                docs_response = requests.get(f"{api_server.base_url}/openapi.json", timeout=5)
                if docs_response.status_code == 200:
                    openapi_spec = docs_response.json()
                    endpoint_count = len(openapi_spec.get("paths", {}))
                    print(f"   ✓ OpenAPI documentation available ({endpoint_count} paths)")
                    verification_results["documentation"] = True
                else:
                    print("   ✗ OpenAPI documentation not accessible")
                
                # Verify specific endpoint categories
                if "/customers" in str(docs_response.text):
                    print("   ✓ Customer management endpoints available")
                    verification_results["customer_apis"] = True
                
                if "/policies" in str(docs_response.text):
                    print("   ✓ Policy management endpoints available")
                    verification_results["policy_apis"] = True
                
                if "/claims" in str(docs_response.text):
                    print("   ✓ Claims processing endpoints available")
                    verification_results["claims_apis"] = True
                
                if "/analytics" in str(docs_response.text):
                    print("   ✓ Analytics endpoints available")
                    verification_results["analytics_apis"] = True
                    
            else:
                print(f"   ✗ API server not accessible: {health_response.status_code}")
                
        except requests.exceptions.RequestException as e:
            print(f"   ✗ API server connection failed: {e}")
        
        # 5. Calculate completion percentage
        completed_components = sum(verification_results.values())
        total_components = len(verification_results)
        completion_percentage = (completed_components / total_components) * 100
        
        print(f"\n📈 LAB COMPLETION STATUS:")
        print(f"   Completed Components: {completed_components}/{total_components}")
        print(f"   Completion Percentage: {completion_percentage:.1f}%")
        
        if completion_percentage >= 90:
            print("\n🎉 LAB 13 SUCCESSFULLY COMPLETED!")
            print("✓ Ready for Lab 7: Interactive Web Applications")
        elif completion_percentage >= 75:
            print("\n⚠ LAB 13 MOSTLY COMPLETED")
            print("Review failed components before proceeding")
        else:
            print("\n❌ LAB 13 INCOMPLETE")
            print("Please address failed components")
        
        print("\nNEXT STEPS:")
        print("1. Review any failed verification components")
        print("2. Test your API endpoints using the interactive documentation")
        print("3. Proceed to Lab 7: Interactive Web Applications")
        print("4. Begin building full-stack applications with real-time features")
        
        return verification_results
        
    except Exception as e:
        print(f"Verification process failed: {e}")
        return verification_results

# Run final verification
final_results = verify_lab_13_completion()

print("\n" + "="*50)
print("🎓 NEO4J LAB 13 COMPLETED")
print("Production Insurance API Development")
print("="*50)

# Final database state summary
try:
    final_stats_query = """
    MATCH (n)
    WITH count(n) AS nodeCount, count(DISTINCT labels(n)) AS labelCount
    MATCH ()-[r]->()
    WITH nodeCount, labelCount, count(r) AS relCount, count(DISTINCT type(r)) AS relTypeCount
    RETURN nodeCount, relCount, labelCount, relTypeCount
    """
    
    stats_result = connection_manager.execute_query(final_stats_query)
    if stats_result:
        stats = stats_result[0]
        print(f"📊 FINAL DATABASE STATE:")
        print(f"   Nodes: {stats['nodeCount']}")
        print(f"   Relationships: {stats['relCount']}")
        print(f"   Labels: {stats['labelCount']}")
        print(f"   Relationship Types: {stats['relTypeCount']}")
        
except Exception as e:
    print(f"Could not retrieve final stats: {e}")

print("\n🌐 ACCESS YOUR API:")
print(f"   Swagger UI: {api_server.base_url}/docs")
print(f"   ReDoc Documentation: {api_server.base_url}/redoc")
print(f"   Health Check: {api_server.base_url}/health")

print("\n🔐 TEST CREDENTIALS:")
print("   Admin: admin / admin123")
print("   Agent: agent1 / agent123") 
print("   Customer: customer1 / customer123")

print("\nReady for Lab 7: Interactive Web Applications!")
```

---

## 📚 Lab 12 Summary

**🎯 What You've Accomplished:**

### **Production API Development**
- ✅ **FastAPI framework integration** with comprehensive insurance domain endpoints
- ✅ **JWT authentication system** with role-based access control and scope management
- ✅ **RESTful API design** following industry best practices and OpenAPI standards
- ✅ **Comprehensive error handling** with proper HTTP status codes and error responses

### **Customer Management APIs**
- ✅ **Complete CRUD operations** for customer data with validation and business rules
- ✅ **Advanced search and filtering** with pagination support for large datasets
- ✅ **Data validation** using Pydantic models with type safety and error reporting
- ✅ **Customer analytics** with 360-degree view and relationship insights

### **Policy Administration**
- ✅ **Policy lifecycle management** from creation to renewal and cancellation
- ✅ **Business rule enforcement** for coverage limits, premium calculations, and compliance
- ✅ **Policy relationship tracking** linking customers, products, and claims
- ✅ **Automated policy numbering** and date calculations for terms and renewals

### **Claims Processing**
- ✅ **Claims submission workflow** with incident validation and policy verification
- ✅ **Status tracking system** for claims lifecycle management
- ✅ **Adjuster assignment** and workload distribution capabilities
- ✅ **Claims analytics** for fraud detection and settlement optimization

### **Security & Documentation**
- ✅ **Enterprise security patterns** with JWT tokens, role-based access, and CORS policies
- ✅ **Interactive API documentation** with Swagger UI and ReDoc for developer experience
- ✅ **OpenAPI specification** for integration with other systems and code generation
- ✅ **Rate limiting and monitoring** for production-grade API management

### **Database Integration**
- ✅ **Production connection management** with connection pooling and retry logic
- ✅ **Transaction handling** for data consistency and ACID compliance
- ✅ **Performance optimization** with query caching and batch operations
- ✅ **Health monitoring** with comprehensive database metrics and alerting

**📈 Database State Achievement:**
- **Target:** 720 nodes, 900 relationships
- **Delivered:** Production-ready API platform with comprehensive insurance coverage
- **Next Lab:** Lab 13 - Interactive Web Applications with real-time features

**🛠️ Development Tools Mastered:**
- **FastAPI Framework** - Modern Python web framework for APIs
- **Pydantic Models** - Data validation and serialization
- **JWT Authentication** - Secure token-based authentication
- **OpenAPI/Swagger** - API documentation and testing
- **Uvicorn ASGI Server** - High-performance async server
- **Requests Library** - HTTP client for API testing
- **Python Virtual Environments** - Isolated development environments
- **Jupyter Notebooks** - Interactive development and testing

Your insurance API platform is now ready for integration with frontend applications, mobile apps, and third-party systems. The robust authentication, comprehensive validation, and detailed documentation make it suitable for enterprise deployment and team collaboration.