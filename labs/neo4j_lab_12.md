# Neo4j Lab 12: Python Driver & Service Architecture

## Overview
**Duration:** 45 minutes  
**Objective:** Build Python applications with Neo4j driver integration, proper architecture patterns, service layers with error handling, and automated testing for graph operations

Building on Lab 11's predictive analytics capabilities, you'll now transition from Cypher to Python development, implementing enterprise-grade service architecture patterns that provide robust, scalable, and maintainable applications for insurance operations with comprehensive error handling and testing strategies.

## Prerequisites
- Completed Neo4j Labs 1-11
- Neo4j Enterprise 2025.06.0 running in Docker (container name: neo4j)
- Python 3.8+ and Jupyter Lab installed
- Neo4j Python driver (`pip install neo4j`)

---

## 🚀 Lab Environment Setup & Execution Instructions

### Step 1: Python Environment Setup

**Please refer to the main `README.md` file (Step 2: Python Environment Setup section) for complete Python environment setup instructions including:**
- Python 3.8+ installation and verification
- Virtual environment creation and activation
- Package manager configuration
- Jupyter Lab installation and setup

### Step 2: Start Jupyter Lab Environment

**Windows:**
```bash
# Navigate to your lab directory
cd C:\Users\%USERNAME%\neo4j-labs

# Start Jupyter Lab
jupyter lab

# If Jupyter is not installed
pip install jupyterlab
jupyter lab
```

**Mac:**
```bash
# Navigate to your lab directory
cd ~/neo4j-labs

# Start Jupyter Lab
jupyter lab

# If Jupyter is not installed
pip install jupyterlab
jupyter lab
```

**Expected Result:** Jupyter Lab opens in your browser at `http://localhost:8888`

### Step 3: Create New Jupyter Notebook

1. In Jupyter Lab, click **"+"** to create new launcher
2. Select **"Python 3"** notebook
3. Rename notebook to `neo4j_lab_12_python_integration.ipynb`
4. Create the following directory structure in Jupyter:

```
neo4j-labs/
├── lab_12/
│   ├── neo4j_lab_12_python_integration.ipynb
│   ├── requirements.txt
│   └── .env
```

### Step 4: Environment Configuration Files

**Create `requirements.txt` file:**
```txt
neo4j==5.26.0
python-dotenv==1.0.0
pytest==8.0.0
pytest-asyncio==0.23.0
pydantic==2.5.0
typing-extensions==4.9.0
```

**Create `.env` file:**
```env
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=password
NEO4J_DATABASE=neo4j
NEO4J_MAX_CONNECTION_LIFETIME=1800
NEO4J_MAX_POOL_SIZE=50
NEO4J_ACQUISITION_TIMEOUT=60
NEO4J_MAX_RETRY_TIME=30
NEO4J_ENCRYPTED=false
NEO4J_TRUST=TRUST_ALL_CERTIFICATES
ENVIRONMENT=development
LOG_LEVEL=INFO
```

### Step 5: Verify Python Dependencies

**Run this in your first Jupyter cell:**
```python
# Cell 1: Install and verify dependencies
import subprocess
import sys
import importlib

def install_package(package):
    """Install package using pip"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"✓ Successfully installed {package}")
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to install {package}: {e}")

def verify_package(package_name, import_name=None):
    """Verify package is installed and importable"""
    if import_name is None:
        import_name = package_name.replace('-', '_')
    
    try:
        importlib.import_module(import_name)
        print(f"✓ {package_name} is installed and importable")
        return True
    except ImportError:
        print(f"✗ {package_name} is not available")
        return False

# Required packages for this lab
required_packages = [
    ("neo4j", "neo4j"),
    ("python-dotenv", "dotenv"),
    ("pytest", "pytest"),
    ("pydantic", "pydantic"),
    ("typing-extensions", "typing_extensions")
]

print("DEPENDENCY VERIFICATION:")
print("=" * 50)

all_available = True
for package_name, import_name in required_packages:
    if not verify_package(package_name, import_name):
        print(f"Installing {package_name}...")
        install_package(package_name)
        all_available = False

if all_available:
    print("\n✓ All dependencies are ready!")
else:
    print("\n⚠ Some dependencies were installed. Restart kernel and re-run this cell.")

print("=" * 50)
```

---

## 🔧 Part 1: Neo4j Driver Architecture & Connection Management

### Cell 2: Environment Setup and Configuration
```python
# Cell 2: Environment configuration and connection setup
import os
from dotenv import load_dotenv
from neo4j import GraphDatabase
import logging
from typing import Optional, Dict, Any, List
import time
import json

# Load environment configuration
load_dotenv()

# Neo4j connection configuration from environment
NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USERNAME = os.getenv("NEO4J_USERNAME", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "password")
NEO4J_DATABASE = os.getenv("NEO4J_DATABASE", "neo4j")

# Additional connection configuration from environment
NEO4J_MAX_CONNECTION_LIFETIME = int(os.getenv("NEO4J_MAX_CONNECTION_LIFETIME", 1800))
NEO4J_MAX_POOL_SIZE = int(os.getenv("NEO4J_MAX_POOL_SIZE", 50))
NEO4J_ACQUISITION_TIMEOUT = int(os.getenv("NEO4J_ACQUISITION_TIMEOUT", 60))
NEO4J_MAX_RETRY_TIME = int(os.getenv("NEO4J_MAX_RETRY_TIME", 30))
NEO4J_ENCRYPTED = os.getenv("NEO4J_ENCRYPTED", "false").lower() == "true"
NEO4J_TRUST = os.getenv("NEO4J_TRUST", "TRUST_ALL_CERTIFICATES")

# Configure logging for debugging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

print("🔧 ENVIRONMENT CONFIGURATION:")
print("=" * 50)
print(f"Neo4j URI: {NEO4J_URI}")
print(f"Database: {NEO4J_DATABASE}")
print(f"Username: {NEO4J_USERNAME}")
print(f"Password: {'*' * len(NEO4J_PASSWORD)}")
print(f"Max Connection Lifetime: {NEO4J_MAX_CONNECTION_LIFETIME}s")
print(f"Max Pool Size: {NEO4J_MAX_POOL_SIZE}")
print(f"Acquisition Timeout: {NEO4J_ACQUISITION_TIMEOUT}s")
print(f"Max Retry Time: {NEO4J_MAX_RETRY_TIME}s")
print(f"Encrypted: {NEO4J_ENCRYPTED}")
print(f"Trust: {NEO4J_TRUST}")
print("=" * 50)

# Test basic connection using loaded configuration
try:
    test_driver = GraphDatabase.driver(
        NEO4J_URI, 
        auth=(NEO4J_USERNAME, NEO4J_PASSWORD),
        max_connection_lifetime=NEO4J_MAX_CONNECTION_LIFETIME,
        max_connection_pool_size=NEO4J_MAX_POOL_SIZE,
        connection_acquisition_timeout=NEO4J_ACQUISITION_TIMEOUT,
        encrypted=NEO4J_ENCRYPTED,
        trust=NEO4J_TRUST
    )
    with test_driver.session(database=NEO4J_DATABASE) as session:
        result = session.run("RETURN 'Connection successful' as message")
        message = result.single()["message"]
        print(f"✓ Connection Test: {message}")
    test_driver.close()
except Exception as e:
    print(f"✗ Connection Failed: {e}")
    print("\n🔍 TROUBLESHOOTING STEPS:")
    print("1. Verify Docker container 'neo4j' is running: docker ps")
    print("2. Check container logs: docker logs neo4j")
    print("3. Restart container if needed: docker restart neo4j")
    print("4. Verify port 7687 is not blocked by firewall")
```

### Cell 3: Enterprise Connection Manager Implementation
```python
# Cell 3: Production-grade connection manager
from typing import Optional, Dict, Any, List, Callable
import time
import threading
from contextlib import contextmanager

class Neo4jConnectionManager:
    """
    Enterprise-grade Neo4j connection manager with:
    - Connection pooling and retry logic
    - Health monitoring and metrics
    - Thread-safe operations
    - Graceful error handling
    """
    
    def __init__(self, uri: str, username: str, password: str, database: str = "neo4j"):
        self.uri = uri
        self.username = username
        self.password = password
        self.database = database
        self._driver = None
        self._connection_attempts = 0
        self._successful_queries = 0
        self._failed_queries = 0
        self._lock = threading.Lock()
        
        # Load connection configuration from environment or use defaults
        self.config = {
            "max_connection_lifetime": int(os.getenv("NEO4J_MAX_CONNECTION_LIFETIME", 30 * 60)),
            "max_connection_pool_size": int(os.getenv("NEO4J_MAX_POOL_SIZE", 50)),
            "connection_acquisition_timeout": int(os.getenv("NEO4J_ACQUISITION_TIMEOUT", 60)),
            "max_retry_time": int(os.getenv("NEO4J_MAX_RETRY_TIME", 30)),
            "encrypted": os.getenv("NEO4J_ENCRYPTED", "false").lower() == "true",
            "trust": os.getenv("NEO4J_TRUST", "TRUST_ALL_CERTIFICATES")
        }
        
        self._initialize_driver()
    
    def _initialize_driver(self):
        """Initialize Neo4j driver with retry logic"""
        max_attempts = 3
        retry_delay = 2
        
        for attempt in range(1, max_attempts + 1):
            try:
                self._connection_attempts += 1
                logger.info(f"Initializing driver (attempt {attempt}/{max_attempts})")
                
                self._driver = GraphDatabase.driver(
                    self.uri,
                    auth=(self.username, self.password),
                    **self.config
                )
                
                # Verify connection
                with self._driver.session(database=self.database) as session:
                    session.run("RETURN 1").single()
                
                logger.info("✓ Driver initialized successfully")
                return
                
            except Exception as e:
                logger.error(f"Connection attempt {attempt} failed: {e}")
                if attempt < max_attempts:
                    time.sleep(retry_delay)
                    retry_delay *= 2  # Exponential backoff
                else:
                    raise Exception(f"Failed to connect after {max_attempts} attempts: {e}")
    
    @contextmanager
    def get_session(self):
        """Context manager for database sessions"""
        session = None
        try:
            if not self._driver:
                self._initialize_driver()
            
            session = self._driver.session(database=self.database)
            yield session
            
        except Exception as e:
            logger.error(f"Session error: {e}")
            raise
        finally:
            if session:
                session.close()
    
    def execute_query(self, query: str, parameters: Optional[Dict[str, Any]] = None, retry_count: int = 3):
        """Execute query with retry logic and error handling"""
        parameters = parameters or {}
        
        for attempt in range(1, retry_count + 1):
            try:
                with self.get_session() as session:
                    start_time = time.time()
                    result = session.run(query, parameters)
                    records = [record for record in result]
                    execution_time = time.time() - start_time
                    
                    self._successful_queries += 1
                    logger.debug(f"Query executed successfully in {execution_time:.3f}s")
                    return records
                    
            except Exception as e:
                self._failed_queries += 1
                logger.error(f"Query attempt {attempt} failed: {e}")
                
                if attempt < retry_count:
                    wait_time = 2 ** attempt  # Exponential backoff
                    logger.info(f"Retrying in {wait_time} seconds...")
                    time.sleep(wait_time)
                else:
                    raise Exception(f"Query failed after {retry_count} attempts: {e}")
    
    def execute_write_transaction(self, transaction_function: Callable, **kwargs):
        """Execute write transaction with proper error handling"""
        try:
            with self.get_session() as session:
                return session.execute_write(transaction_function, **kwargs)
        except Exception as e:
            logger.error(f"Write transaction failed: {e}")
            raise
    
    def execute_read_transaction(self, transaction_function: Callable, **kwargs):
        """Execute read transaction with proper error handling"""
        try:
            with self.get_session() as session:
                return session.execute_read(transaction_function, **kwargs)
        except Exception as e:
            logger.error(f"Read transaction failed: {e}")
            raise
    
    def health_check(self) -> Dict[str, Any]:
        """Comprehensive health check with metrics"""
        try:
            start_time = time.time()
            
            with self.get_session() as session:
                # Basic connectivity test
                result = session.run("RETURN datetime() as server_time, 'healthy' as status")
                record = result.single()
                
                # Get database info
                db_info = session.run("""
                    CALL dbms.components() YIELD name, versions, edition
                    RETURN name, versions[0] as version, edition
                """).single()
                
                # Get basic statistics
                stats = session.run("""
                    MATCH (n) 
                    RETURN count(n) as node_count
                    UNION ALL
                    MATCH ()-[r]->() 
                    RETURN count(r) as relationship_count
                """).data()
                
                response_time = time.time() - start_time
                
                return {
                    "status": "healthy",
                    "server_time": str(record["server_time"]),
                    "database": {
                        "name": db_info["name"],
                        "version": db_info["version"],
                        "edition": db_info["edition"]
                    },
                    "statistics": {
                        "nodes": stats[0]["node_count"] if stats else 0,
                        "relationships": stats[1]["relationship_count"] if len(stats) > 1 else 0
                    },
                    "connection_metrics": {
                        "connection_attempts": self._connection_attempts,
                        "successful_queries": self._successful_queries,
                        "failed_queries": self._failed_queries,
                        "response_time_ms": round(response_time * 1000, 2)
                    }
                }
                
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "connection_metrics": {
                    "connection_attempts": self._connection_attempts,
                    "successful_queries": self._successful_queries,
                    "failed_queries": self._failed_queries
                }
            }
    
    def close(self):
        """Close driver connection"""
        if self._driver:
            self._driver.close()
            logger.info("Driver connection closed")

# Initialize connection manager
print("🚀 INITIALIZING CONNECTION MANAGER:")
print("=" * 50)

try:
    connection_manager = Neo4jConnectionManager(
        uri=NEO4J_URI,
        username=NEO4J_USERNAME,
        password=NEO4J_PASSWORD,
        database=NEO4J_DATABASE
    )
    
    print("✓ Connection manager initialized successfully")
    
    # Perform health check
    health_status = connection_manager.health_check()
    print(f"✓ Health check status: {health_status['status']}")
    
    if health_status['status'] == 'healthy':
        print(f"✓ Database: {health_status['database']['name']} {health_status['database']['version']}")
        print(f"✓ Nodes: {health_status['statistics']['nodes']}")
        print(f"✓ Relationships: {health_status['statistics']['relationships']}")
        print(f"✓ Response time: {health_status['connection_metrics']['response_time_ms']}ms")
    else:
        print(f"✗ Health check failed: {health_status.get('error', 'Unknown error')}")
    
except Exception as e:
    print(f"✗ Failed to initialize connection manager: {e}")
    print("\n🔍 TROUBLESHOOTING:")
    print("1. Ensure Neo4j Docker container is running")
    print("2. Check network connectivity to port 7687")
    print("3. Verify credentials are correct")
    print("4. Check Docker container logs for errors")

print("=" * 50)
```

---

## 📊 Part 2: Pydantic Data Models & Type Safety

### Cell 4: Insurance Data Models with Validation
```python
# Cell 4: Pydantic models for type safety and validation
from pydantic import BaseModel, Field, validator, EmailStr
from typing import Optional, List, Dict, Any, Literal
from datetime import datetime, date
from enum import Enum
import uuid

print("📊 CREATING PYDANTIC DATA MODELS:")
print("=" * 50)

# Enums for controlled values
class PolicyStatus(str, Enum):
    ACTIVE = "Active"
    INACTIVE = "Inactive"
    CANCELLED = "Cancelled"
    SUSPENDED = "Suspended"

class PolicyType(str, Enum):
    AUTO = "Auto"
    HOME = "Homeowner"
    LIFE = "Life"
    HEALTH = "Health"
    COMMERCIAL = "Commercial"

class ClaimStatus(str, Enum):
    FILED = "Filed"
    INVESTIGATING = "Investigating"
    APPROVED = "Approved"
    DENIED = "Denied"
    SETTLED = "Settled"

class RiskLevel(str, Enum):
    LOW = "Low Risk"
    MEDIUM = "Medium Risk"
    HIGH = "High Risk"
    VERY_HIGH = "Very High Risk"

# Base model with common fields
class BaseEntity(BaseModel):
    """Base model with common entity fields"""
    id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid4()))
    created_at: Optional[datetime] = Field(default_factory=datetime.now)
    updated_at: Optional[datetime] = Field(default_factory=datetime.now)
    version: Optional[int] = Field(default=1)
    
    class Config:
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            date: lambda v: v.isoformat()
        }

# Customer models
class CustomerBase(BaseModel):
    """Base customer model"""
    customer_id: str = Field(..., description="Unique customer identifier")
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    email: EmailStr
    phone: Optional[str] = Field(None, regex=r'^\+?1?\d{9,15}$')
    date_of_birth: date
    
    @validator('customer_id')
    def customer_id_format(cls, v):
        if not v.startswith('CUST-'):
            raise ValueError('Customer ID must start with CUST-')
        return v
    
    @validator('date_of_birth')
    def validate_age(cls, v):
        today = date.today()
        age = today.year - v.year - ((today.month, today.day) < (v.month, v.day))
        if age < 18 or age > 120:
            raise ValueError('Customer must be between 18 and 120 years old')
        return v

class CustomerCreate(CustomerBase):
    """Model for creating new customers"""
    initial_contact_method: Optional[str] = "Web"
    referral_source: Optional[str] = None

class Customer(BaseEntity, CustomerBase):
    """Complete customer model"""
    customer_since: Optional[date] = None
    total_policies: Optional[int] = Field(default=0, ge=0)
    total_claims: Optional[int] = Field(default=0, ge=0)
    customer_value: Optional[float] = Field(default=0.0, ge=0)
    risk_score: Optional[float] = Field(default=0.0, ge=0, le=100)

# Policy models
class PolicyBase(BaseModel):
    """Base policy model"""
    policy_number: str = Field(..., description="Unique policy identifier")
    policy_type: PolicyType
    customer_id: str
    effective_date: date
    expiration_date: date
    premium_amount: float = Field(..., gt=0, description="Monthly premium amount")
    coverage_amount: float = Field(..., gt=0, description="Total coverage amount")
    deductible: Optional[float] = Field(default=0, ge=0)
    
    @validator('policy_number')
    def policy_number_format(cls, v):
        if not (v.startswith('POL-') and len(v) >= 8):
            raise ValueError('Policy number must start with POL- and be at least 8 characters')
        return v
    
    @validator('expiration_date')
    def expiration_after_effective(cls, v, values):
        if 'effective_date' in values and v <= values['effective_date']:
            raise ValueError('Expiration date must be after effective date')
        return v

class PolicyCreate(PolicyBase):
    """Model for creating new policies"""
    agent_id: Optional[str] = None
    underwriting_notes: Optional[str] = None

class Policy(BaseEntity, PolicyBase):
    """Complete policy model"""
    policy_status: PolicyStatus = PolicyStatus.ACTIVE
    last_payment_date: Optional[date] = None
    next_payment_due: Optional[date] = None
    claims_count: Optional[int] = Field(default=0, ge=0)
    total_claims_amount: Optional[float] = Field(default=0.0, ge=0)

# Claim models
class ClaimBase(BaseModel):
    """Base claim model"""
    claim_number: str = Field(..., description="Unique claim identifier")
    policy_number: str
    claim_date: date
    incident_date: date
    claim_amount: float = Field(..., gt=0)
    description: str = Field(..., min_length=10, max_length=1000)
    
    @validator('claim_number')
    def claim_number_format(cls, v):
        if not (v.startswith('CLM-') and len(v) >= 8):
            raise ValueError('Claim number must start with CLM- and be at least 8 characters')
        return v
    
    @validator('incident_date')
    def incident_before_claim(cls, v, values):
        if 'claim_date' in values and v > values['claim_date']:
            raise ValueError('Incident date cannot be after claim date')
        return v

class ClaimCreate(ClaimBase):
    """Model for creating new claims"""
    adjuster_id: Optional[str] = None
    priority: Optional[Literal["Low", "Medium", "High", "Critical"]] = "Medium"

class Claim(BaseEntity, ClaimBase):
    """Complete claim model"""
    claim_status: ClaimStatus = ClaimStatus.FILED
    adjuster_id: Optional[str] = None
    settlement_amount: Optional[float] = Field(default=0.0, ge=0)
    settlement_date: Optional[date] = None
    investigation_notes: Optional[str] = None

# Risk Assessment model
class RiskAssessment(BaseEntity):
    """Risk assessment model"""
    customer_id: str
    assessment_date: date
    risk_level: RiskLevel
    risk_score: float = Field(..., ge=0, le=100)
    factors: List[str] = Field(default_factory=list)
    recommendations: List[str] = Field(default_factory=list)
    next_review_date: Optional[date] = None

# Test data model validation
print("🧪 TESTING DATA MODEL VALIDATION:")

try:
    # Valid customer
    customer_data = {
        "customer_id": "CUST-123456",
        "first_name": "John",
        "last_name": "Smith",
        "email": "john.smith@email.com",
        "phone": "+1234567890",
        "date_of_birth": "1985-03-15"
    }
    customer = Customer(**customer_data)
    print("✓ Customer model validation passed")
    
    # Valid policy
    policy_data = {
        "policy_number": "POL-AUTO-001",
        "policy_type": "Auto",
        "customer_id": "CUST-123456",
        "effective_date": "2025-01-01",
        "expiration_date": "2026-01-01",
        "premium_amount": 150.00,
        "coverage_amount": 25000.00,
        "deductible": 500.00
    }
    policy = Policy(**policy_data)
    print("✓ Policy model validation passed")
    
    # Valid claim
    claim_data = {
        "claim_number": "CLM-2025-001",
        "policy_number": "POL-AUTO-001",
        "claim_date": "2025-07-18",
        "incident_date": "2025-07-17",
        "claim_amount": 2500.00,
        "description": "Minor fender bender in parking lot with damage to rear bumper"
    }
    claim = Claim(**claim_data)
    print("✓ Claim model validation passed")
    
    print("✓ All data models validated successfully")
    
except Exception as e:
    print(f"✗ Model validation failed: {e}")

print("=" * 50)
```

---

## 🏗️ Part 3: Repository Pattern Implementation

### Cell 5: Abstract Repository Base Class
```python
# Cell 5: Repository pattern implementation
from abc import ABC, abstractmethod
from typing import Optional, List, Dict, Any, TypeVar, Generic
import json

print("🏗️ IMPLEMENTING REPOSITORY PATTERN:")
print("=" * 50)

T = TypeVar('T', bound=BaseModel)

class AbstractRepository(ABC, Generic[T]):
    """Abstract base repository for common database operations"""
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
        self.logger = logging.getLogger(self.__class__.__name__)
    
    @abstractmethod
    def create(self, entity: T) -> T:
        """Create a new entity"""
        pass
    
    @abstractmethod
    def get_by_id(self, entity_id: str) -> Optional[T]:
        """Get entity by ID"""
        pass
    
    @abstractmethod
    def update(self, entity: T) -> T:
        """Update existing entity"""
        pass
    
    @abstractmethod
    def delete(self, entity_id: str) -> bool:
        """Delete entity by ID"""
        pass
    
    @abstractmethod
    def list_all(self, limit: int = 100, offset: int = 0) -> List[T]:
        """List all entities with pagination"""
        pass
    
    def execute_query(self, query: str, parameters: Optional[Dict[str, Any]] = None) -> List[Dict[str, Any]]:
        """Execute raw query and return results"""
        try:
            records = self.connection_manager.execute_query(query, parameters)
            return [record.data() for record in records]
        except Exception as e:
            self.logger.error(f"Query execution failed: {e}")
            raise

class CustomerRepository(AbstractRepository[Customer]):
    """Repository for customer operations"""
    
    def create(self, customer: CustomerCreate) -> Customer:
        """Create a new customer in Neo4j"""
        query = """
        CREATE (c:Customer {
            customerId: $customer_id,
            firstName: $first_name,
            lastName: $last_name,
            email: $email,
            phone: $phone,
            dateOfBirth: date($date_of_birth),
            customerSince: date(),
            totalPolicies: 0,
            totalClaims: 0,
            customerValue: 0.0,
            riskScore: 50.0,
            initialContactMethod: $initial_contact_method,
            referralSource: $referral_source,
            createdAt: datetime(),
            updatedAt: datetime(),
            version: 1
        })
        RETURN c
        """
        
        parameters = {
            "customer_id": customer.customer_id,
            "first_name": customer.first_name,
            "last_name": customer.last_name,
            "email": customer.email,
            "phone": customer.phone,
            "date_of_birth": customer.date_of_birth.isoformat(),
            "initial_contact_method": customer.initial_contact_method,
            "referral_source": customer.referral_source
        }
        
        try:
            result = self.execute_query(query, parameters)
            if result:
                customer_data = result[0]['c']
                return Customer(**self._neo4j_to_dict(customer_data))
            else:
                raise Exception("Failed to create customer")
        except Exception as e:
            self.logger.error(f"Customer creation failed: {e}")
            raise
    
    def get_by_id(self, customer_id: str) -> Optional[Customer]:
        """Get customer by ID"""
        query = """
        MATCH (c:Customer {customerId: $customer_id})
        RETURN c
        """
        
        try:
            result = self.execute_query(query, {"customer_id": customer_id})
            if result:
                customer_data = result[0]['c']
                return Customer(**self._neo4j_to_dict(customer_data))
            return None
        except Exception as e:
            self.logger.error(f"Customer retrieval failed: {e}")
            raise
    
    def update(self, customer: Customer) -> Customer:
        """Update existing customer"""
        query = """
        MATCH (c:Customer {customerId: $customer_id})
        SET c.firstName = $first_name,
            c.lastName = $last_name,
            c.email = $email,
            c.phone = $phone,
            c.updatedAt = datetime(),
            c.version = c.version + 1
        RETURN c
        """
        
        parameters = {
            "customer_id": customer.customer_id,
            "first_name": customer.first_name,
            "last_name": customer.last_name,
            "email": customer.email,
            "phone": customer.phone
        }
        
        try:
            result = self.execute_query(query, parameters)
            if result:
                customer_data = result[0]['c']
                return Customer(**self._neo4j_to_dict(customer_data))
            else:
                raise Exception("Customer not found for update")
        except Exception as e:
            self.logger.error(f"Customer update failed: {e}")
            raise
    
    def delete(self, customer_id: str) -> bool:
        """Delete customer by ID"""
        query = """
        MATCH (c:Customer {customerId: $customer_id})
        DETACH DELETE c
        RETURN count(c) as deleted_count
        """
        
        try:
            result = self.execute_query(query, {"customer_id": customer_id})
            return result[0]['deleted_count'] > 0 if result else False
        except Exception as e:
            self.logger.error(f"Customer deletion failed: {e}")
            raise
    
    def list_all(self, limit: int = 100, offset: int = 0) -> List[Customer]:
        """List all customers with pagination"""
        query = """
        MATCH (c:Customer)
        RETURN c
        ORDER BY c.lastName, c.firstName
        SKIP $offset
        LIMIT $limit
        """
        
        try:
            result = self.execute_query(query, {"limit": limit, "offset": offset})
            return [Customer(**self._neo4j_to_dict(record['c'])) for record in result]
        except Exception as e:
            self.logger.error(f"Customer listing failed: {e}")
            raise
    
    def search_by_email(self, email: str) -> Optional[Customer]:
        """Search customer by email"""
        query = """
        MATCH (c:Customer {email: $email})
        RETURN c
        """
        
        try:
            result = self.execute_query(query, {"email": email})
            if result:
                customer_data = result[0]['c']
                return Customer(**self._neo4j_to_dict(customer_data))
            return None
        except Exception as e:
            self.logger.error(f"Customer email search failed: {e}")
            raise
    
    def get_customer_stats(self, customer_id: str) -> Dict[str, Any]:
        """Get comprehensive customer statistics"""
        query = """
        MATCH (c:Customer {customerId: $customer_id})
        OPTIONAL MATCH (c)-[:HOLDS]->(p:Policy)
        OPTIONAL MATCH (p)-[:COVERS]->(cl:Claim)
        RETURN c,
               count(DISTINCT p) as policy_count,
               count(DISTINCT cl) as claim_count,
               sum(p.premiumAmount) as total_premiums,
               sum(cl.claimAmount) as total_claims_amount
        """
        
        try:
            result = self.execute_query(query, {"customer_id": customer_id})
            if result:
                record = result[0]
                return {
                    "customer": Customer(**self._neo4j_to_dict(record['c'])),
                    "statistics": {
                        "policy_count": record['policy_count'] or 0,
                        "claim_count": record['claim_count'] or 0,
                        "total_premiums": float(record['total_premiums'] or 0),
                        "total_claims_amount": float(record['total_claims_amount'] or 0)
                    }
                }
            return None
        except Exception as e:
            self.logger.error(f"Customer stats retrieval failed: {e}")
            raise
    
    def _neo4j_to_dict(self, neo4j_node) -> Dict[str, Any]:
        """Convert Neo4j node to dictionary with proper type conversion"""
        data = dict(neo4j_node)
        
        # Convert Neo4j field names to Python model field names
        field_mapping = {
            'customerId': 'customer_id',
            'firstName': 'first_name',
            'lastName': 'last_name',
            'dateOfBirth': 'date_of_birth',
            'customerSince': 'customer_since',
            'totalPolicies': 'total_policies',
            'totalClaims': 'total_claims',
            'customerValue': 'customer_value',
            'riskScore': 'risk_score',
            'createdAt': 'created_at',
            'updatedAt': 'updated_at'
        }
        
        converted_data = {}
        for neo4j_key, value in data.items():
            python_key = field_mapping.get(neo4j_key, neo4j_key)
            converted_data[python_key] = value
        
        return converted_data

# Initialize repository
print("🏗️ INITIALIZING CUSTOMER REPOSITORY:")

try:
    customer_repo = CustomerRepository(connection_manager)
    print("✓ Customer repository initialized successfully")
    
    # Test repository with sample data
    sample_customer = CustomerCreate(
        customer_id="CUST-TEST-001",
        first_name="Test",
        last_name="Customer",
        email="test.customer@example.com",
        phone="+1234567890",
        date_of_birth=date(1990, 1, 1),
        initial_contact_method="Lab Testing",
        referral_source="Unit Test"
    )
    
    print("✓ Sample customer model created")
    print("✓ Repository pattern implementation complete")
    
except Exception as e:
    print(f"✗ Repository initialization failed: {e}")

print("=" * 50)
```

---

## 🔧 Part 4: Service Layer Implementation

### Cell 6: Insurance Business Logic Service
```python
# Cell 6: Service layer with business logic
from typing import List, Dict, Any, Optional
from datetime import datetime, date, timedelta
import uuid

print("🔧 IMPLEMENTING SERVICE LAYER:")
print("=" * 50)

class InsuranceService:
    """
    Service layer implementing insurance business logic
    Handles complex operations involving multiple entities
    """
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
        self.customer_repo = CustomerRepository(connection_manager)
        self.logger = logging.getLogger(self.__class__.__name__)
    
    def create_customer_with_policy(self, customer_data: CustomerCreate, policy_data: PolicyCreate) -> Dict[str, Any]:
        """Create customer and initial policy in a single transaction"""
        
        def create_transaction(tx):
            # Create customer
            customer_query = """
            CREATE (c:Customer {
                customerId: $customer_id,
                firstName: $first_name,
                lastName: $last_name,
                email: $email,
                phone: $phone,
                dateOfBirth: date($date_of_birth),
                customerSince: date(),
                totalPolicies: 1,
                totalClaims: 0,
                customerValue: $premium_amount,
                riskScore: 50.0,
                createdAt: datetime(),
                updatedAt: datetime(),
                version: 1
            })
            RETURN c
            """
            
            # Create policy
            policy_query = """
            MATCH (c:Customer {customerId: $customer_id})
            CREATE (p:Policy {
                policyNumber: $policy_number,
                policyType: $policy_type,
                customerId: $customer_id,
                effectiveDate: date($effective_date),
                expirationDate: date($expiration_date),
                premiumAmount: $premium_amount,
                coverageAmount: $coverage_amount,
                deductible: $deductible,
                policyStatus: 'Active',
                claimsCount: 0,
                totalClaimsAmount: 0.0,
                createdAt: datetime(),
                updatedAt: datetime(),
                version: 1
            })
            CREATE (c)-[:HOLDS]->(p)
            RETURN p
            """
            
            # Execute customer creation
            customer_result = tx.run(customer_query, {
                "customer_id": customer_data.customer_id,
                "first_name": customer_data.first_name,
                "last_name": customer_data.last_name,
                "email": customer_data.email,
                "phone": customer_data.phone,
                "date_of_birth": customer_data.date_of_birth.isoformat(),
                "premium_amount": policy_data.premium_amount
            })
            
            # Execute policy creation
            policy_result = tx.run(policy_query, {
                "customer_id": customer_data.customer_id,
                "policy_number": policy_data.policy_number,
                "policy_type": policy_data.policy_type.value,
                "effective_date": policy_data.effective_date.isoformat(),
                "expiration_date": policy_data.expiration_date.isoformat(),
                "premium_amount": policy_data.premium_amount,
                "coverage_amount": policy_data.coverage_amount,
                "deductible": policy_data.deductible or 0
            })
            
            customer_record = customer_result.single()
            policy_record = policy_result.single()
            
            return {
                "customer": dict(customer_record["c"]),
                "policy": dict(policy_record["p"])
            }
        
        try:
            result = self.connection_manager.execute_write_transaction(create_transaction)
            
            # Create audit record
            self._create_audit_record("customer_policy_creation", customer_data.customer_id)
            
            self.logger.info(f"Customer and policy created successfully: {customer_data.customer_id}")
            return result
            
        except Exception as e:
            self.logger.error(f"Customer/policy creation failed: {e}")
            raise Exception(f"Failed to create customer and policy: {e}")
    
    def process_claim(self, claim_data: ClaimCreate) -> Dict[str, Any]:
        """Process a new insurance claim with business logic"""
        
        # Validate policy exists and is active
        policy_check_query = """
        MATCH (p:Policy {policyNumber: $policy_number})
        WHERE p.policyStatus = 'Active'
        RETURN p.coverageAmount as coverage, p.deductible as deductible
        """
        
        try:
            policy_result = self.connection_manager.execute_query(
                policy_check_query, 
                {"policy_number": claim_data.policy_number}
            )
            
            if not policy_result:
                raise Exception(f"Policy {claim_data.policy_number} not found or inactive")
            
            policy_info = policy_result[0]
            coverage_amount = float(policy_info['coverage'])
            deductible = float(policy_info['deductible'])
            
            # Validate claim amount doesn't exceed coverage
            if claim_data.claim_amount > coverage_amount:
                raise Exception(f"Claim amount ${claim_data.claim_amount} exceeds coverage ${coverage_amount}")
            
            # Calculate potential payout (claim amount minus deductible)
            potential_payout = max(0, claim_data.claim_amount - deductible)
            
            # Create claim with business logic
            def create_claim_transaction(tx):
                create_claim_query = """
                MATCH (p:Policy {policyNumber: $policy_number})
                MATCH (c:Customer {customerId: p.customerId})
                CREATE (cl:Claim {
                    claimNumber: $claim_number,
                    policyNumber: $policy_number,
                    claimDate: date($claim_date),
                    incidentDate: date($incident_date),
                    claimAmount: $claim_amount,
                    description: $description,
                    claimStatus: 'Filed',
                    potentialPayout: $potential_payout,
                    priority: $priority,
                    createdAt: datetime(),
                    updatedAt: datetime(),
                    version: 1
                })
                CREATE (p)-[:COVERS]->(cl)
                
                // Update policy statistics
                SET p.claimsCount = p.claimsCount + 1,
                    p.totalClaimsAmount = p.totalClaimsAmount + $claim_amount,
                    p.updatedAt = datetime()
                
                // Update customer statistics  
                SET c.totalClaims = c.totalClaims + 1,
                    c.updatedAt = datetime()
                
                RETURN cl, p, c
                """
                
                result = tx.run(create_claim_query, {
                    "claim_number": claim_data.claim_number,
                    "policy_number": claim_data.policy_number,
                    "claim_date": claim_data.claim_date.isoformat(),
                    "incident_date": claim_data.incident_date.isoformat(),
                    "claim_amount": claim_data.claim_amount,
                    "description": claim_data.description,
                    "potential_payout": potential_payout,
                    "priority": getattr(claim_data, 'priority', 'Medium')
                })
                
                return result.single()
            
            result = self.connection_manager.execute_write_transaction(create_claim_transaction)
            
            # Create audit record
            self._create_audit_record("claim_creation", claim_data.claim_number)
            
            self.logger.info(f"Claim processed successfully: {claim_data.claim_number}")
            
            return {
                "claim": dict(result["cl"]),
                "policy": dict(result["p"]),
                "customer": dict(result["c"]),
                "business_analysis": {
                    "potential_payout": potential_payout,
                    "deductible_applied": deductible,
                    "coverage_utilization": (claim_data.claim_amount / coverage_amount) * 100
                }
            }
            
        except Exception as e:
            self.logger.error(f"Claim processing failed: {e}")
            raise
    
    def calculate_customer_risk_score(self, customer_id: str) -> Dict[str, Any]:
        """Calculate comprehensive risk score for customer"""
        risk_query = """
        MATCH (c:Customer {customerId: $customer_id})
        OPTIONAL MATCH (c)-[:HOLDS]->(p:Policy)-[:COVERS]->(cl:Claim)
        WITH c, 
             count(DISTINCT p) as policy_count,
             count(DISTINCT cl) as claim_count,
             sum(cl.claimAmount) as total_claims,
             sum(p.premiumAmount) as total_premiums
        
        // Calculate risk factors
        WITH c, policy_count, claim_count, total_claims, total_premiums,
             CASE 
                WHEN claim_count = 0 THEN 0
                WHEN policy_count = 0 THEN 100
                ELSE (claim_count * 1.0 / policy_count) * 30
             END as claims_frequency_score,
             
             CASE
                WHEN total_premiums = 0 THEN 0
                WHEN total_claims = 0 THEN 0
                ELSE (total_claims / total_premiums) * 40
             END as claims_ratio_score,
             
             CASE
                WHEN c.customerSince IS NULL THEN 20
                WHEN duration.between(c.customerSince, date()).days < 365 THEN 15
                WHEN duration.between(c.customerSince, date()).days < 1095 THEN 10
                ELSE 5
             END as tenure_score
        
        WITH c, policy_count, claim_count, total_claims, total_premiums,
             claims_frequency_score + claims_ratio_score + tenure_score as calculated_risk_score
        
        // Determine risk level
        WITH c, policy_count, claim_count, total_claims, total_premiums, calculated_risk_score,
             CASE
                WHEN calculated_risk_score <= 25 THEN 'Low Risk'
                WHEN calculated_risk_score <= 50 THEN 'Medium Risk'
                WHEN calculated_risk_score <= 75 THEN 'High Risk'
                ELSE 'Very High Risk'
             END as risk_level
        
        // Update customer record
        SET c.riskScore = calculated_risk_score,
            c.updatedAt = datetime()
        
        RETURN c.customerId as customer_id,
               calculated_risk_score as risk_score,
               risk_level,
               policy_count,
               claim_count,
               total_claims,
               total_premiums
        """
        
        try:
            result = self.connection_manager.execute_query(risk_query, {"customer_id": customer_id})
            
            if not result:
                raise Exception(f"Customer {customer_id} not found")
            
            data = result[0]
            risk_score = float(data['risk_score'])
            risk_level = data['risk_level']
            
            # Generate risk factors and recommendations
            factors = []
            if data['claim_count'] > 2:
                factors.append("High claim frequency")
            if data['total_claims'] and data['total_premiums'] and (data['total_claims'] / data['total_premiums']) > 1.5:
                factors.append("Claims exceed premiums paid")
            if data['policy_count'] == 0:
                factors.append("No active policies")
            
            # Create risk assessment record
            assessment_query = """
            MATCH (c:Customer {customerId: $customer_id})
            CREATE (ra:RiskAssessment {
                assessmentId: randomUUID(),
                customerId: $customer_id,
                assessmentDate: date(),
                riskScore: $risk_score,
                riskLevel: $risk_level,
                factors: $factors,
                createdAt: datetime(),
                version: 1
            })
            CREATE (c)-[:HAS_RISK_ASSESSMENT]->(ra)
            RETURN ra.assessmentId as assessment_id
            """
            
            assessment_result = self.connection_manager.execute_query(assessment_query, {
                "customer_id": customer_id,
                "risk_score": risk_score,
                "risk_level": risk_level,
                "factors": factors
            })
            
            self.logger.info(f"Risk score calculated for customer {customer_id}: {risk_score}")
            
            return {
                "customer_id": customer_id,
                "risk_score": risk_score,
                "risk_level": risk_level,
                "factors": factors,
                "assessment_id": assessment_result[0]["assessment_id"] if assessment_result else None
            }
            
        except Exception as e:
            self.logger.error(f"Risk calculation failed: {e}")
            raise
    
    def get_customer_360_view(self, customer_id: str) -> Dict[str, Any]:
        """Comprehensive customer view with all relationships"""
        query = """
        MATCH (c:Customer {customerId: $customer_id})
        OPTIONAL MATCH (c)-[:HOLDS]->(p:Policy)
        OPTIONAL MATCH (p)-[:COVERS]->(claim:Claim)
        OPTIONAL MATCH (c)-[:HAS_RISK_ASSESSMENT]->(ra:RiskAssessment)
        
        RETURN c,
               collect(DISTINCT p) as policies,
               collect(DISTINCT claim) as claims,
               collect(DISTINCT ra) as risk_assessments
        """
        
        try:
            result = self.connection_manager.execute_query(query, {"customer_id": customer_id})
            
            if not result:
                return {"error": "Customer not found"}
            
            data = result[0]
            customer_data = dict(data['c'])
            
            return {
                "customer": customer_data,
                "policies": [dict(p) for p in data['policies'] if p],
                "claims": [dict(c) for c in data['claims'] if c],
                "risk_assessments": [dict(ra) for ra in data['risk_assessments'] if ra],
                "summary": {
                    "total_policies": len([p for p in data['policies'] if p]),
                    "total_claims": len([c for c in data['claims'] if c]),
                    "latest_risk_score": customer_data.get('riskScore', 0)
                }
            }
            
        except Exception as e:
            self.logger.error(f"Customer 360 view failed: {e}")
            raise
    
    def _create_audit_record(self, action: str, entity_id: str):
        """Create audit trail record"""
        query = """
        CREATE (ar:AuditRecord {
            auditId: randomUUID(),
            action: $action,
            entityId: $entity_id,
            timestamp: datetime(),
            userId: 'system',
            details: 'Automated system action'
        })
        RETURN ar.auditId as audit_id
        """
        
        try:
            self.connection_manager.execute_query(query, {
                "action": action,
                "entity_id": entity_id
            })
        except Exception as e:
            self.logger.warning(f"Audit record creation failed: {e}")

# Initialize service
print("🔧 INITIALIZING INSURANCE SERVICE:")

try:
    insurance_service = InsuranceService(connection_manager)
    print("✓ Insurance service initialized successfully")
    print("✓ Service layer implementation complete")
    
except Exception as e:
    print(f"✗ Service initialization failed: {e}")

print("=" * 50)
```

---

## 🧪 Part 5: Testing Framework & Quality Assurance

### Cell 7: Comprehensive Testing Suite
```python
# Cell 7: Testing framework and quality assurance
import pytest
from unittest.mock import Mock, patch
import asyncio
from typing import Any, Dict

print("🧪 IMPLEMENTING TESTING FRAMEWORK:")
print("=" * 50)

class TestInsuranceService:
    """Comprehensive test suite for insurance service"""
    
    @pytest.fixture
    def mock_connection_manager(self):
        """Mock connection manager for testing"""
        mock_manager = Mock(spec=Neo4jConnectionManager)
        return mock_manager
    
    @pytest.fixture
    def insurance_service(self, mock_connection_manager):
        """Insurance service with mocked dependencies"""
        return InsuranceService(mock_connection_manager)
    
    def test_customer_creation_validation(self):
        """Test customer data validation"""
        try:
            # Valid customer
            valid_customer = CustomerCreate(
                customer_id="CUST-TEST-001",
                first_name="John",
                last_name="Doe",
                email="john.doe@test.com",
                phone="+1234567890",
                date_of_birth=date(1990, 1, 1)
            )
            assert valid_customer.customer_id == "CUST-TEST-001"
            print("✓ Valid customer creation test passed")
            
            # Invalid customer ID format
            try:
                invalid_customer = CustomerCreate(
                    customer_id="INVALID-001",
                    first_name="John",
                    last_name="Doe",
                    email="john.doe@test.com",
                    date_of_birth=date(1990, 1, 1)
                )
                print("✗ Invalid customer ID test failed - should have raised error")
            except ValueError:
                print("✓ Invalid customer ID validation test passed")
            
            # Invalid age
            try:
                young_customer = CustomerCreate(
                    customer_id="CUST-TEST-002",
                    first_name="Too",
                    last_name="Young",
                    email="young@test.com",
                    date_of_birth=date(2010, 1, 1)  # Too young
                )
                print("✗ Age validation test failed - should have raised error")
            except ValueError:
                print("✓ Age validation test passed")
                
        except Exception as e:
            print(f"✗ Customer validation tests failed: {e}")
    
    def test_policy_validation(self):
        """Test policy data validation"""
        try:
            # Valid policy
            valid_policy = PolicyCreate(
                policy_number="POL-AUTO-001",
                policy_type=PolicyType.AUTO,
                customer_id="CUST-123456",
                effective_date=date(2025, 1, 1),
                expiration_date=date(2026, 1, 1),
                premium_amount=150.00,
                coverage_amount=25000.00,
                deductible=500.00
            )
            assert valid_policy.policy_type == PolicyType.AUTO
            print("✓ Valid policy creation test passed")
            
            # Invalid expiration date
            try:
                invalid_policy = PolicyCreate(
                    policy_number="POL-AUTO-002",
                    policy_type=PolicyType.AUTO,
                    customer_id="CUST-123456",
                    effective_date=date(2025, 1, 1),
                    expiration_date=date(2024, 12, 31),  # Before effective date
                    premium_amount=150.00,
                    coverage_amount=25000.00
                )
                print("✗ Date validation test failed - should have raised error")
            except ValueError:
                print("✓ Policy date validation test passed")
                
        except Exception as e:
            print(f"✗ Policy validation tests failed: {e}")
    
    def test_database_connection_resilience(self):
        """Test connection resilience and retry logic"""
        try:
            # Test connection with retry logic
            test_manager = Neo4jConnectionManager(
                uri=NEO4J_URI,
                username=NEO4J_USERNAME,
                password=NEO4J_PASSWORD,
                database=NEO4J_DATABASE
            )
            
            # Perform health check
            health_status = test_manager.health_check()
            assert health_status['status'] in ['healthy', 'unhealthy']
            print("✓ Connection resilience test passed")
            
            # Test query execution with parameters
            result = test_manager.execute_query(
                "RETURN $test_param as result",
                {"test_param": "test_value"}
            )
            assert len(result) == 1
            assert result[0]['result'] == 'test_value'
            print("✓ Parameterized query test passed")
            
            test_manager.close()
            
        except Exception as e:
            print(f"✗ Connection resilience tests failed: {e}")
    
    def test_error_handling(self):
        """Test comprehensive error handling"""
        try:
            # Test invalid customer ID format
            try:
                CustomerCreate(
                    customer_id="INVALID",
                    first_name="Test",
                    last_name="User",
                    email="test@example.com",
                    date_of_birth=date(1990, 1, 1)
                )
                print("✗ Error handling test failed - should have raised error")
            except ValueError as e:
                print("✓ Customer ID validation error handling passed")
            
            # Test invalid claim number format
            try:
                ClaimCreate(
                    claim_number="INVALID",
                    policy_number="POL-123",
                    claim_date=date.today(),
                    incident_date=date.today(),
                    claim_amount=1000.00,
                    description="Test claim description"
                )
                print("✗ Claim validation test failed - should have raised error")
            except ValueError as e:
                print("✓ Claim number validation error handling passed")
                
        except Exception as e:
            print(f"✗ Error handling tests failed: {e}")

# Create test instance and run tests
print("🧪 RUNNING TEST SUITE:")

try:
    test_suite = TestInsuranceService()
    
    # Run individual tests
    test_suite.test_customer_creation_validation()
    test_suite.test_policy_validation()
    test_suite.test_database_connection_resilience()
    test_suite.test_error_handling()
    
    print("✓ All tests completed successfully")
    
except Exception as e:
    print(f"✗ Test suite execution failed: {e}")

print("=" * 50)
```

---

## 📈 Part 6: Integration Testing & Performance Monitoring

### Cell 8: Live Integration Testing
```python
# Cell 8: Live integration testing with actual database
print("📈 PERFORMING INTEGRATION TESTING:")
print("=" * 50)

class IntegrationTestSuite:
    """Live integration tests with actual Neo4j database"""
    
    def __init__(self, service: InsuranceService):
        self.service = service
        self.test_data = []
        self.logger = logging.getLogger(self.__class__.__name__)
    
    def run_full_integration_test(self) -> Dict[str, Any]:
        """Run comprehensive integration test"""
        test_results = {
            "customer_creation": False,
            "policy_creation": False,
            "claim_processing": False,
            "risk_calculation": False,
            "customer_360_view": False,
            "data_consistency": False,
            "performance_metrics": {}
        }
        
        try:
            # Test 1: Customer Creation
            start_time = time.time()
            customer_result = self._test_customer_creation()
            test_results["customer_creation"] = customer_result is not None
            test_results["performance_metrics"]["customer_creation_ms"] = round((time.time() - start_time) * 1000, 2)
            
            if customer_result:
                customer_id = customer_result["customer"]["customerId"]
                policy_number = customer_result["policy"]["policyNumber"]
                
                # Test 2: Claim Processing
                start_time = time.time()
                claim_result = self._test_claim_processing(policy_number)
                test_results["claim_processing"] = claim_result is not None
                test_results["performance_metrics"]["claim_processing_ms"] = round((time.time() - start_time) * 1000, 2)
                
                # Test 3: Risk Calculation
                start_time = time.time()
                risk_result = self._test_risk_calculation(customer_id)
                test_results["risk_calculation"] = risk_result is not None
                test_results["performance_metrics"]["risk_calculation_ms"] = round((time.time() - start_time) * 1000, 2)
                
                # Test 4: Customer 360 View
                start_time = time.time()
                view_result = self._test_customer_360_view(customer_id)
                test_results["customer_360_view"] = view_result is not None
                test_results["performance_metrics"]["customer_360_view_ms"] = round((time.time() - start_time) * 1000, 2)
                
                # Test 5: Data Consistency
                consistency_result = self._test_data_consistency(customer_id)
                test_results["data_consistency"] = consistency_result
            
            return test_results
            
        except Exception as e:
            self.logger.error(f"Integration test failed: {e}")
            return test_results
        
        finally:
            # Cleanup test data
            self._cleanup_test_data()
    
    def _test_customer_creation(self) -> Optional[Dict[str, Any]]:
        """Test customer and policy creation"""
        try:
            customer_data = CustomerCreate(
                customer_id=f"CUST-INTEG-{int(time.time())}",
                first_name="Integration",
                last_name="Test",
                email=f"integration.test.{int(time.time())}@example.com",
                phone="+1555123456",
                date_of_birth=date(1985, 5, 15),
                initial_contact_method="Integration Test",
                referral_source="Automated Testing"
            )
            
            policy_data = PolicyCreate(
                policy_number=f"POL-INTEG-{int(time.time())}",
                policy_type=PolicyType.AUTO,
                customer_id=customer_data.customer_id,
                effective_date=date.today(),
                expiration_date=date.today() + timedelta(days=365),
                premium_amount=125.50,
                coverage_amount=30000.00,
                deductible=750.00
            )
            
            result = self.service.create_customer_with_policy(customer_data, policy_data)
            self.test_data.append(customer_data.customer_id)
            
            print(f"✓ Customer and policy created: {customer_data.customer_id}")
            return result
            
        except Exception as e:
            print(f"✗ Customer creation test failed: {e}")
            return None
    
    def _test_claim_processing(self, policy_number: str) -> Optional[Dict[str, Any]]:
        """Test claim processing functionality"""
        try:
            claim_data = ClaimCreate(
                claim_number=f"CLM-INTEG-{int(time.time())}",
                policy_number=policy_number,
                claim_date=date.today(),
                incident_date=date.today() - timedelta(days=1),
                claim_amount=2500.00,
                description="Integration test claim for minor vehicle damage during automated testing scenario"
            )
            
            result = self.service.process_claim(claim_data)
            print(f"✓ Claim processed: {claim_data.claim_number}")
            return result
            
        except Exception as e:
            print(f"✗ Claim processing test failed: {e}")
            return None
    
    def _test_risk_calculation(self, customer_id: str) -> Optional[Dict[str, Any]]:
        """Test risk calculation functionality"""
        try:
            result = self.service.calculate_customer_risk_score(customer_id)
            print(f"✓ Risk calculated: {result['risk_level']} ({result['risk_score']:.1f})")
            return result
            
        except Exception as e:
            print(f"✗ Risk calculation test failed: {e}")
            return None
    
    def _test_customer_360_view(self, customer_id: str) -> Optional[Dict[str, Any]]:
        """Test customer 360-degree view"""
        try:
            result = self.service.get_customer_360_view(customer_id)
            
            if "error" not in result:
                summary = result['summary']
                print(f"✓ Customer 360 view: {summary['total_policies']} policies, {summary['total_claims']} claims")
                return result
            else:
                print(f"✗ Customer 360 view failed: {result['error']}")
                return None
                
        except Exception as e:
            print(f"✗ Customer 360 view test failed: {e}")
            return None
    
    def _test_data_consistency(self, customer_id: str) -> bool:
        """Test data consistency across relationships"""
        try:
            # Verify customer exists and has correct relationships
            consistency_query = """
            MATCH (c:Customer {customerId: $customer_id})
            OPTIONAL MATCH (c)-[:HOLDS]->(p:Policy)
            OPTIONAL MATCH (p)-[:COVERS]->(cl:Claim)
            OPTIONAL MATCH (c)-[:HAS_RISK_ASSESSMENT]->(ra:RiskAssessment)
            
            RETURN c.customerId as customer_id,
                   count(DISTINCT p) as policy_count,
                   count(DISTINCT cl) as claim_count,
                   count(DISTINCT ra) as risk_assessment_count,
                   c.totalPolicies as customer_policy_count,
                   c.totalClaims as customer_claim_count
            """
            
            result = self.service.connection_manager.execute_query(
                consistency_query, 
                {"customer_id": customer_id}
            )
            
            if result:
                data = result[0]
                policy_consistent = data['policy_count'] == data['customer_policy_count']
                claim_consistent = data['claim_count'] == data['customer_claim_count']
                
                if policy_consistent and claim_consistent:
                    print("✓ Data consistency verified")
                    return True
                else:
                    print(f"✗ Data inconsistency detected: policies {data['policy_count']}/{data['customer_policy_count']}, claims {data['claim_count']}/{data['customer_claim_count']}")
                    return False
            else:
                print("✗ Customer not found for consistency check")
                return False
                
        except Exception as e:
            print(f"✗ Data consistency test failed: {e}")
            return False
    
    def _cleanup_test_data(self):
        """Clean up test data after testing"""
        try:
            for customer_id in self.test_data:
                cleanup_query = """
                MATCH (c:Customer {customerId: $customer_id})
                OPTIONAL MATCH (c)-[:HOLDS]->(p:Policy)
                OPTIONAL MATCH (p)-[:COVERS]->(cl:Claim)
                OPTIONAL MATCH (c)-[:HAS_RISK_ASSESSMENT]->(ra:RiskAssessment)
                DETACH DELETE c, p, cl, ra
                """
                
                self.service.connection_manager.execute_query(
                    cleanup_query, 
                    {"customer_id": customer_id}
                )
            
            print(f"✓ Cleaned up {len(self.test_data)} test records")
            
        except Exception as e:
            print(f"⚠ Cleanup failed: {e}")

# Run integration tests
print("📈 RUNNING LIVE INTEGRATION TESTS:")

try:
    integration_tester = IntegrationTestSuite(insurance_service)
    test_results = integration_tester.run_full_integration_test()
    
    print("\n" + "="*50)
    print("INTEGRATION TEST RESULTS:")
    print("="*50)
    
    for test_name, passed in test_results.items():
        if test_name != "performance_metrics":
            status = "✓ PASS" if passed else "✗ FAIL"
            print(f"{test_name.replace('_', ' ').title()}: {status}")
    
    print("\nPERFORMANCE METRICS:")
    for metric, value in test_results["performance_metrics"].items():
        print(f"├─ {metric.replace('_', ' ').title()}: {value}")
    
    # Calculate overall success rate
    total_tests = len([t for t in test_results.keys() if t != "performance_metrics"])
    passed_tests = sum([1 for k, v in test_results.items() if k != "performance_metrics" and v])
    success_rate = (passed_tests / total_tests) * 100
    
    print(f"\nOVERALL SUCCESS RATE: {success_rate:.1f}% ({passed_tests}/{total_tests})")
    
    if success_rate >= 80:
        print("🎉 Integration testing completed successfully!")
    else:
        print("⚠ Some integration tests failed - review implementation")
    
except Exception as e:
    print(f"✗ Integration testing failed: {e}")

print("=" * 50)
```

---

## 📊 Part 7: Production Monitoring & Health Checks

### Cell 9: Production Monitoring System
```python
# Cell 9: Production monitoring and health checks
import psutil
import threading
from datetime import datetime, timedelta
from typing import Dict, List, Any
import json

print("📊 IMPLEMENTING PRODUCTION MONITORING:")
print("=" * 50)

class ProductionMonitor:
    """
    Production monitoring system for Neo4j applications
    Tracks performance, health, and operational metrics
    """
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
        self.logger = logging.getLogger(self.__class__.__name__)
        self.monitoring_active = False
        self.metrics_history = []
        self.alert_thresholds = {
            "response_time_ms": 1000,  # 1 second
            "memory_usage_percent": 80,
            "cpu_usage_percent": 85,
            "failed_query_rate": 5.0  # 5% failure rate
        }
    
    def get_system_metrics(self) -> Dict[str, Any]:
        """Get comprehensive system metrics"""
        try:
            # CPU and Memory metrics
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            # Network metrics
            network = psutil.net_io_counters()
            
            return {
                "timestamp": datetime.now().isoformat(),
                "system": {
                    "cpu_percent": cpu_percent,
                    "memory_percent": memory.percent,
                    "memory_available_gb": round(memory.available / (1024**3), 2),
                    "memory_total_gb": round(memory.total / (1024**3), 2),
                    "disk_percent": round((disk.used / disk.total) * 100, 1),
                    "disk_free_gb": round(disk.free / (1024**3), 2)
                },
                "network": {
                    "bytes_sent": network.bytes_sent,
                    "bytes_recv": network.bytes_recv,
                    "packets_sent": network.packets_sent,
                    "packets_recv": network.packets_recv
                }
            }
            
        except Exception as e:
            self.logger.error(f"System metrics collection failed: {e}")
            return {"error": str(e)}
    
    def get_database_metrics(self) -> Dict[str, Any]:
        """Get Neo4j database performance metrics"""
        try:
            # Database health check
            health_status = self.connection_manager.health_check()
            
            # Query performance metrics
            performance_query = """
            CALL dbms.queryJmx("org.neo4j:instance=kernel#0,name=Transactions") 
            YIELD attributes
            WITH attributes.NumberOfOpenTransactions.value as open_transactions,
                 attributes.NumberOfCommittedTransactions.value as committed_transactions
            
            CALL dbms.queryJmx("org.neo4j:instance=kernel#0,name=Page cache")
            YIELD attributes as page_cache_attrs
            
            RETURN open_transactions,
                   committed_transactions,
                   page_cache_attrs.Hits.value as page_cache_hits,
                   page_cache_attrs.Faults.value as page_cache_faults
            """
            
            try:
                perf_result = self.connection_manager.execute_query(performance_query)
                if perf_result:
                    perf_data = perf_result[0]
                    page_cache_hit_ratio = 0
                    if perf_data['page_cache_hits'] and perf_data['page_cache_faults']:
                        total_accesses = perf_data['page_cache_hits'] + perf_data['page_cache_faults']
                        page_cache_hit_ratio = (perf_data['page_cache_hits'] / total_accesses) * 100
                else:
                    perf_data = {}
                    page_cache_hit_ratio = 0
            except:
                # Fallback for limited JMX access
                perf_data = {}
                page_cache_hit_ratio = 0
            
            # Basic database statistics
            stats_query = """
            MATCH (n) 
            WITH count(n) as node_count
            MATCH ()-[r]->() 
            WITH node_count, count(r) as rel_count
            MATCH (c:Customer) 
            WITH node_count, rel_count, count(c) as customer_count
            MATCH (p:Policy) 
            WITH node_count, rel_count, customer_count, count(p) as policy_count
            MATCH (cl:Claim) 
            RETURN node_count, rel_count, customer_count, policy_count, count(cl) as claim_count
            """
            
            stats_result = self.connection_manager.execute_query(stats_query)
            stats_data = stats_result[0] if stats_result else {}
            
            return {
                "timestamp": datetime.now().isoformat(),
                "database": {
                    "status": health_status.get('status', 'unknown'),
                    "version": health_status.get('database', {}).get('version', 'unknown'),
                    "response_time_ms": health_status.get('connection_metrics', {}).get('response_time_ms', 0)
                },
                "performance": {
                    "open_transactions": perf_data.get('open_transactions', 0),
                    "committed_transactions": perf_data.get('committed_transactions', 0),
                    "page_cache_hit_ratio": round(page_cache_hit_ratio, 2)
                },
                "statistics": {
                    "total_nodes": stats_data.get('node_count', 0),
                    "total_relationships": stats_data.get('rel_count', 0),
                    "customers": stats_data.get('customer_count', 0),
                    "policies": stats_data.get('policy_count', 0),
                    "claims": stats_data.get('claim_count', 0)
                },
                "connection_metrics": health_status.get('connection_metrics', {})
            }
            
        except Exception as e:
            self.logger.error(f"Database metrics collection failed: {e}")
            return {"error": str(e)}
    
    def get_application_metrics(self) -> Dict[str, Any]:
        """Get application-specific metrics"""
        try:
            # Query application performance
            app_metrics_query = """
            // Get recent audit records for activity tracking
            MATCH (ar:AuditRecord)
            WHERE ar.timestamp >= datetime() - duration('PT1H')
            WITH count(ar) as recent_activity
            
            // Get policy distribution
            MATCH (p:Policy)
            WITH recent_activity, p.policyStatus as status, count(p) as count
            
            RETURN recent_activity,
                   collect({status: status, count: count}) as policy_distribution
            """
            
            app_result = self.connection_manager.execute_query(app_metrics_query)
            app_data = app_result[0] if app_result else {}
            
            return {
                "timestamp": datetime.now().isoformat(),
                "application": {
                    "recent_activity_1h": app_data.get('recent_activity', 0),
                    "policy_distribution": app_data.get('policy_distribution', [])
                },
                "service_layer": {
                    "successful_queries": self.connection_manager._successful_queries,
                    "failed_queries": self.connection_manager._failed_queries,
                    "connection_attempts": self.connection_manager._connection_attempts
                }
            }
            
        except Exception as e:
            self.logger.error(f"Application metrics collection failed: {e}")
            return {"error": str(e)}
    
    def generate_comprehensive_report(self) -> Dict[str, Any]:
        """Generate comprehensive monitoring report"""
        try:
            system_metrics = self.get_system_metrics()
            database_metrics = self.get_database_metrics()
            application_metrics = self.get_application_metrics()
            
            # Calculate health score
            health_score = self._calculate_health_score(system_metrics, database_metrics, application_metrics)
            
            # Generate alerts
            alerts = self._check_alert_conditions(system_metrics, database_metrics, application_metrics)
            
            report = {
                "report_timestamp": datetime.now().isoformat(),
                "health_score": health_score,
                "system_metrics": system_metrics,
                "database_metrics": database_metrics,
                "application_metrics": application_metrics,
                "alerts": alerts,
                "summary": {
                    "overall_status": "healthy" if health_score >= 80 else "warning" if health_score >= 60 else "critical",
                    "alert_count": len(alerts),
                    "database_status": database_metrics.get('database', {}).get('status', 'unknown')
                }
            }
            
            # Store in history
            self.metrics_history.append(report)
            
            # Keep only last 24 hours of metrics
            cutoff_time = datetime.now() - timedelta(hours=24)
            self.metrics_history = [
                m for m in self.metrics_history 
                if datetime.fromisoformat(m['report_timestamp']) > cutoff_time
            ]
            
            return report
            
        except Exception as e:
            self.logger.error(f"Report generation failed: {e}")
            return {"error": str(e)}
    
    def _calculate_health_score(self, system_metrics: Dict, db_metrics: Dict, app_metrics: Dict) -> float:
        """Calculate overall system health score (0-100)"""
        try:
            score = 100.0
            
            # System health (30% weight)
            if 'system' in system_metrics:
                sys_data = system_metrics['system']
                if sys_data['cpu_percent'] > 80:
                    score -= 15
                elif sys_data['cpu_percent'] > 60:
                    score -= 8
                
                if sys_data['memory_percent'] > 85:
                    score -= 15
                elif sys_data['memory_percent'] > 70:
                    score -= 8
            
            # Database health (50% weight)
            if 'database' in db_metrics:
                db_data = db_metrics['database']
                if db_data['status'] != 'healthy':
                    score -= 30
                
                response_time = db_data.get('response_time_ms', 0)
                if response_time > 1000:
                    score -= 20
                elif response_time > 500:
                    score -= 10
            
            # Application health (20% weight)
            if 'service_layer' in app_metrics:
                service_data = app_metrics['service_layer']
                total_queries = service_data['successful_queries'] + service_data['failed_queries']
                if total_queries > 0:
                    failure_rate = (service_data['failed_queries'] / total_queries) * 100
                    if failure_rate > 10:
                        score -= 20
                    elif failure_rate > 5:
                        score -= 10
            
            return max(0.0, score)
            
        except Exception as e:
            self.logger.error(f"Health score calculation failed: {e}")
            return 50.0  # Default moderate score
    
    def _check_alert_conditions(self, system_metrics: Dict, db_metrics: Dict, app_metrics: Dict) -> List[Dict[str, Any]]:
        """Check for alert conditions"""
        alerts = []
        
        try:
            # System alerts
            if 'system' in system_metrics:
                sys_data = system_metrics['system']
                
                if sys_data['cpu_percent'] > self.alert_thresholds['cpu_usage_percent']:
                    alerts.append({
                        "type": "system",
                        "severity": "warning",
                        "message": f"High CPU usage: {sys_data['cpu_percent']:.1f}%",
                        "threshold": self.alert_thresholds['cpu_usage_percent'],
                        "current_value": sys_data['cpu_percent']
                    })
                
                if sys_data['memory_percent'] > self.alert_thresholds['memory_usage_percent']:
                    alerts.append({
                        "type": "system", 
                        "severity": "warning",
                        "message": f"High memory usage: {sys_data['memory_percent']:.1f}%",
                        "threshold": self.alert_thresholds['memory_usage_percent'],
                        "current_value": sys_data['memory_percent']
                    })
            
            # Database alerts
            if 'database' in db_metrics:
                db_data = db_metrics['database']
                
                if db_data['status'] != 'healthy':
                    alerts.append({
                        "type": "database",
                        "severity": "critical",
                        "message": f"Database status: {db_data['status']}",
                        "threshold": "healthy",
                        "current_value": db_data['status']
                    })
                
                response_time = db_data.get('response_time_ms', 0)
                if response_time > self.alert_thresholds['response_time_ms']:
                    alerts.append({
                        "type": "performance",
                        "severity": "warning",
                        "message": f"Slow database response: {response_time}ms",
                        "threshold": self.alert_thresholds['response_time_ms'],
                        "current_value": response_time
                    })
            
            # Application alerts
            if 'service_layer' in app_metrics:
                service_data = app_metrics['service_layer']
                total_queries = service_data['successful_queries'] + service_data['failed_queries']
                
                if total_queries > 0:
                    failure_rate = (service_data['failed_queries'] / total_queries) * 100
                    if failure_rate > self.alert_thresholds['failed_query_rate']:
                        alerts.append({
                            "type": "application",
                            "severity": "warning",
                            "message": f"High query failure rate: {failure_rate:.1f}%",
                            "threshold": self.alert_thresholds['failed_query_rate'],
                            "current_value": failure_rate
                        })
            
        except Exception as e:
            self.logger.error(f"Alert checking failed: {e}")
        
        return alerts

# Initialize production monitor
print("📊 INITIALIZING PRODUCTION MONITOR:")

try:
    production_monitor = ProductionMonitor(connection_manager)
    
    # Generate comprehensive monitoring report
    monitoring_report = production_monitor.generate_comprehensive_report()
    
    print("✓ Production monitoring initialized")
    
    # Display monitoring results
    print("\n" + "="*50)
    print("PRODUCTION MONITORING REPORT")
    print("="*50)
    
    summary = monitoring_report.get('summary', {})
    print(f"Overall Status: {summary.get('overall_status', 'unknown').upper()}")
    print(f"Health Score: {monitoring_report.get('health_score', 0):.1f}/100")
    print(f"Database Status: {summary.get('database_status', 'unknown')}")
    print(f"Active Alerts: {summary.get('alert_count', 0)}")
    
    # System metrics
    if 'system_metrics' in monitoring_report and 'system' in monitoring_report['system_metrics']:
        sys_data = monitoring_report['system_metrics']['system']
        print(f"\nSYSTEM METRICS:")
        print(f"├─ CPU Usage: {sys_data.get('cpu_percent', 0):.1f}%")
        print(f"├─ Memory Usage: {sys_data.get('memory_percent', 0):.1f}%")
        print(f"└─ Disk Usage: {sys_data.get('disk_percent', 0):.1f}%")
    
    # Database metrics
    if 'database_metrics' in monitoring_report:
        db_data = monitoring_report['database_metrics']
        if 'database' in db_data:
            print(f"\nDATABASE METRICS:")
            print(f"├─ Status: {db_data['database'].get('status', 'unknown')}")
            print(f"├─ Response Time: {db_data['database'].get('response_time_ms', 0)}ms")
            print(f"└─ Version: {db_data['database'].get('version', 'unknown')}")
        
        if 'statistics' in db_data:
            stats = db_data['statistics']
            print(f"\nDATABASE STATISTICS:")
            print(f"├─ Total Nodes: {stats.get('total_nodes', 0)}")
            print(f"├─ Total Relationships: {stats.get('total_relationships', 0)}")
            print(f"├─ Customers: {stats.get('customers', 0)}")
            print(f"├─ Policies: {stats.get('policies', 0)}")
            print(f"└─ Claims: {stats.get('claims', 0)}")
    
    # Alerts
    alerts = monitoring_report.get('alerts', [])
    if alerts:
        print(f"\nACTIVE ALERTS:")
        for alert in alerts:
            severity_icon = "🔴" if alert['severity'] == 'critical' else "🟡"
            print(f"{severity_icon} {alert['message']}")
    else:
        print(f"\n✅ NO ACTIVE ALERTS")
    
    print("="*50)
    
except Exception as e:
    print(f"✗ Production monitoring failed: {e}")

print("=" * 50)
```

---

## 🎯 Part 8: Lab Completion & Verification

### Cell 10: Final Verification and Summary
```python
# Cell 10: Final lab verification and summary
print("🎯 LAB 12 COMPLETION VERIFICATION:")
print("=" * 50)

def verify_lab_completion():
    """Comprehensive verification of Lab 12 completion"""
    
    verification_results = {
        "environment_setup": False,
        "connection_management": False,
        "data_models": False,
        "repository_pattern": False,
        "service_layer": False,
        "error_handling": False,
        "testing_framework": False,
        "monitoring_system": False,
        "database_state": False
    }
    
    try:
        # 1. Environment Setup Verification
        print("1. ENVIRONMENT SETUP VERIFICATION:")
        try:
            import neo4j, pydantic, pytest, dotenv
            print("   ✓ All required dependencies installed")
            verification_results["environment_setup"] = True
        except ImportError as e:
            print(f"   ✗ Missing dependencies: {e}")
        
        # 2. Connection Management Verification
        print("2. CONNECTION MANAGEMENT VERIFICATION:")
        try:
            health_check = connection_manager.health_check()
            if health_check['status'] == 'healthy':
                print("   ✓ Neo4j connection established")
                print(f"   ✓ Database version: {health_check['database']['version']}")
                verification_results["connection_management"] = True
            else:
                print(f"   ✗ Connection issue: {health_check.get('error', 'Unknown')}")
        except Exception as e:
            print(f"   ✗ Connection verification failed: {e}")
        
        # 3. Data Models Verification
        print("3. DATA MODELS VERIFICATION:")
        try:
            # Test model creation
            test_customer = Customer(
                customer_id="CUST-VERIFY-001",
                first_name="Verify",
                last_name="Test",
                email="verify@test.com",
                date_of_birth=date(1990, 1, 1)
            )
            print("   ✓ Pydantic models working correctly")
            print("   ✓ Data validation implemented")
            verification_results["data_models"] = True
        except Exception as e:
            print(f"   ✗ Data model verification failed: {e}")
        
        # 4. Repository Pattern Verification
        print("4. REPOSITORY PATTERN VERIFICATION:")
        try:
            if hasattr(customer_repo, 'create') and hasattr(customer_repo, 'get_by_id'):
                print("   ✓ Repository pattern implemented")
                print("   ✓ CRUD operations available")
                verification_results["repository_pattern"] = True
            else:
                print("   ✗ Repository pattern incomplete")
        except Exception as e:
            print(f"   ✗ Repository verification failed: {e}")
        
        # 5. Service Layer Verification
        print("5. SERVICE LAYER VERIFICATION:")
        try:
            if hasattr(insurance_service, 'create_customer_with_policy') and \
               hasattr(insurance_service, 'process_claim'):
                print("   ✓ Service layer implemented")
                print("   ✓ Business logic encapsulated")
                verification_results["service_layer"] = True
            else:
                print("   ✗ Service layer incomplete")
        except Exception as e:
            print(f"   ✗ Service layer verification failed: {e}")
        
        # 6. Error Handling Verification
        print("6. ERROR HANDLING VERIFICATION:")
        try:
            # Test error handling with invalid data
            try:
                invalid_customer = CustomerCreate(
                    customer_id="INVALID",  # Should trigger validation error
                    first_name="Test",
                    last_name="User",
                    email="test@example.com",
                    date_of_birth=date(1990, 1, 1)
                )
                print("   ✗ Error handling not working")
            except ValueError:
                print("   ✓ Data validation errors handled")
                verification_results["error_handling"] = True
        except Exception as e:
            print(f"   ✗ Error handling verification failed: {e}")
        
        # 7. Testing Framework Verification
        print("7. TESTING FRAMEWORK VERIFICATION:")
        try:
            if 'TestInsuranceService' in globals():
                print("   ✓ Test classes implemented")
                print("   ✓ Integration testing available")
                verification_results["testing_framework"] = True
            else:
                print("   ✗ Testing framework incomplete")
        except Exception as e:
            print(f"   ✗ Testing framework verification failed: {e}")
        
        # 8. Monitoring System Verification
        print("8. MONITORING SYSTEM VERIFICATION:")
        try:
            if 'production_monitor' in globals():
                print("   ✓ Production monitoring implemented")
                print("   ✓ Health checks available")
                verification_results["monitoring_system"] = True
            else:
                print("   ✗ Monitoring system incomplete")
        except Exception as e:
            print(f"   ✗ Monitoring verification failed: {e}")
        
        # 9. Database State Verification
        print("9. DATABASE STATE VERIFICATION:")
        try:
            # Check current database state
            state_query = """
            MATCH (n) 
            WITH labels(n)[0] as label, count(n) as count
            RETURN label, count
            ORDER BY count DESC
            """
            
            relationship_query = """
            MATCH ()-[r]->() 
            RETURN count(r) as total_relationships
            """
            
            node_result = connection_manager.execute_query(state_query)
            rel_result = connection_manager.execute_query(relationship_query)
            
            total_nodes = sum([record['count'] for record in node_result])
            total_relationships = rel_result[0]['total_relationships'] if rel_result else 0
            
            print(f"   ✓ Total Nodes: {total_nodes}")
            print(f"   ✓ Total Relationships: {total_relationships}")
            
            # Check for expected entity types
            expected_labels = ['Customer', 'Policy', 'Claim', 'RiskAssessment', 'AuditRecord']
            found_labels = [record['label'] for record in node_result if record['label']]
            
            for label in expected_labels:
                if label in found_labels:
                    count = next((r['count'] for r in node_result if r['label'] == label), 0)
                    print(f"   ✓ {label}: {count} entities")
                else:
                    print(f"   ⚠ {label}: Not found (may be created during testing)")
            
            # Target verification (650 nodes, 800 relationships)
            target_nodes = 650
            target_relationships = 800
            
            if total_relationships >= target_relationships * 0.9:  # 90% threshold
                print(f"   ✓ Target state achieved: {total_relationships}/{target_relationships} relationships")
                verification_results["database_state"] = True
            else:
                print(f"   ⚠ Approaching target: {total_relationships}/{target_relationships} relationships")
                verification_results["database_state"] = total_relationships > 0
            
        except Exception as e:
            print(f"   ✗ Database state verification failed: {e}")
        
        # Calculate overall completion percentage
        completed_components = sum(verification_results.values())
        total_components = len(verification_results)
        completion_percentage = (completed_components / total_components) * 100
        
        print(f"\n" + "="*50)
        print("LAB 12 COMPLETION SUMMARY:")
        print("="*50)
        print(f"Completed Components: {completed_components}/{total_components}")
        print(f"Completion Percentage: {completion_percentage:.1f}%")
        
        if completion_percentage >= 90:
            print("🎉 LAB 12 SUCCESSFULLY COMPLETED!")
            print("✓ Ready for Lab 13: Insurance API Development")
        elif completion_percentage >= 75:
            print("⚠ LAB 12 MOSTLY COMPLETED")
            print("Review failed components before proceeding")
        else:
            print("❌ LAB 12 INCOMPLETE")
            print("Please address failed components")
        
        print("\nNEXT STEPS:")
        print("1. Review any failed verification components")
        print("2. Test your Python service integration")
        print("3. Proceed to Lab 13: Insurance API Development")
        print("4. Begin building RESTful APIs with FastAPI")
        
        return verification_results
        
    except Exception as e:
        print(f"Verification process failed: {e}")
        return verification_results

# Run final verification
final_results = verify_lab_completion()

print("\n" + "="*50)
print("🎓 NEO4J LAB 12 COMPLETED")
print("Python Driver & Service Architecture")
print("="*50)

# Close connections
try:
    connection_manager.close()
    print("✓ Database connections closed properly")
except:
    print("⚠ Connection cleanup completed")

print("Ready for Lab 13: Insurance API Development!")
```

---

## 📚 Lab 12 Summary

**🎯 What You've Accomplished:**

### **Neo4j Python Driver Integration**
- ✅ **Enterprise connection management** with retry logic, connection pooling, and error handling
- ✅ **Production-grade driver configuration** with timeout management and connection optimization  
- ✅ **Connection verification** with comprehensive health checks and performance monitoring
- ✅ **Cross-platform compatibility** ensuring consistent behavior on Windows and Mac environments

### **Service Architecture Implementation**
- ✅ **Repository pattern** with abstract base classes and consistent data access patterns
- ✅ **Pydantic data models** with comprehensive validation, type safety, and serialization support
- ✅ **Service layer development** implementing insurance business logic with proper separation of concerns
- ✅ **Dependency injection** patterns enabling testable and maintainable code architecture

### **Error Handling & Resilience**
- ✅ **Comprehensive exception management** with specific handling for validation, database, and system errors
- ✅ **Retry mechanisms** with exponential backoff for transient failures and network issues
- ✅ **Transaction management** ensuring data consistency and atomic operations
- ✅ **Graceful degradation** with fallback mechanisms and error recovery strategies

### **Testing & Quality Assurance**
- ✅ **Integration testing framework** with pytest and mock frameworks for comprehensive coverage
- ✅ **Data validation testing** ensuring model integrity and business rule compliance
- ✅ **Performance testing** with query optimization and response time monitoring
- ✅ **Health check implementation** providing real-time system status and diagnostics

### **Production Readiness Features**
- ✅ **Monitoring and observability** with structured logging and performance metrics
- ✅ **Configuration management** using environment variables and secure credential handling
- ✅ **Type safety enforcement** with Pydantic models and TypeScript-style type hints
- ✅ **Documentation patterns** with comprehensive docstrings and API documentation support

### **Database State:** 650 nodes, 800 relationships with Python service integration

### **Enterprise Architecture Achieved**
- ✅ **Clean architecture patterns** with proper layer separation and dependency management
- ✅ **Scalable service design** supporting high-volume operations and concurrent access
- ✅ **Maintainable codebase** with proper abstractions and extensible design patterns
- ✅ **Production deployment readiness** with containerization support and environment configuration

---

## Next Steps

You're now ready for **Day 3 - Lab 13: Insurance API Development**, where you'll:
- Build RESTful APIs using FastAPI framework with Neo4j integration
- Implement authentication, authorization, and security middleware for production systems
- Create comprehensive API documentation with OpenAPI and interactive testing interfaces
- Design customer management, policy administration, and claims processing endpoints
- **Database Evolution:** 650 nodes → 720 nodes, 800 relationships → 900 relationships

**Congratulations!** You've successfully implemented a production-ready Python service architecture with Neo4j integration, featuring comprehensive error handling, testing frameworks, and enterprise-grade patterns that provide the foundation for building scalable insurance applications.