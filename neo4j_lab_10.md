# Lab 10: Python Application Development

**Duration:** 80 minutes  
**Objective:** Master Neo4j Python driver integration and build production-ready web applications with enterprise features

## Prerequisites

- Completed Lab 9 successfully with enterprise data model
- Understanding of enterprise architecture patterns and security models
- Familiarity with temporal data modeling and RBAC systems
- Knowledge of Python programming fundamentals

## Learning Outcomes

By the end of this lab, you will:
- Master the official Neo4j Python driver with enterprise connection patterns
- Build REST APIs using FastAPI with Neo4j integration and authentication
- Implement comprehensive data access layers and repository patterns
- Create robust error handling and transaction management systems
- Build unit tests for graph operations and business logic
- Develop interactive web applications with real-time graph data
- Implement security patterns including JWT authentication and authorization
- Create production-ready application architecture with proper separation of concerns

## Part 1: Neo4j Python Driver Mastery (20 minutes)

### Step 1: Set Up Development Environment
```python
# Create a new Jupyter notebook: enterprise_graph_app.ipynb
# Install required packages
import subprocess
import sys

def install_package(package):
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

# Install required packages
packages = [
    'neo4j==5.14.0',
    'fastapi==0.104.1',
    'uvicorn[standard]==0.24.0',
    'python-jose[cryptography]==3.3.0',
    'python-multipart==0.0.6',
    'bcrypt==4.0.1',
    'pytest==7.4.3',
    'requests==2.31.0',
    'pydantic==2.5.0',
    'python-dotenv==1.0.0'
]

for package in packages:
    try:
        install_package(package)
        print(f"✅ Installed {package}")
    except Exception as e:
        print(f"❌ Failed to install {package}: {e}")

print("\n🎉 All packages installed successfully!")
```

### Step 2: Enterprise Connection Manager
```python
import os
from typing import Optional, Dict, Any, List
from neo4j import GraphDatabase, Session, Transaction
from neo4j.exceptions import ServiceUnavailable, TransientError
import logging
from datetime import datetime, timedelta
import time

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Neo4jConnectionManager:
    """Enterprise-grade Neo4j connection manager with pooling and error handling"""
    
    def __init__(self, uri: str, username: str, password: str, database: str = "neo4j"):
        self.uri = uri
        self.username = username
        self.password = password
        self.database = database
        self.driver = None
        self._connect()
    
    def _connect(self):
        """Establish connection to Neo4j with retry logic"""
        max_retries = 3
        retry_delay = 1
        
        for attempt in range(max_retries):
            try:
                self.driver = GraphDatabase.driver(
                    self.uri,
                    auth=(self.username, self.password),
                    database=self.database,
                    max_connection_lifetime=3600,  # 1 hour
                    max_connection_pool_size=50,
                    connection_acquisition_timeout=60
                )
                
                # Verify connectivity
                with self.driver.session() as session:
                    session.run("RETURN 1")
                
                logger.info(f"✅ Connected to Neo4j at {self.uri}")
                return
                
            except ServiceUnavailable as e:
                logger.error(f"❌ Connection attempt {attempt + 1} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay * (2 ** attempt))  # Exponential backoff
                else:
                    raise
    
    def get_session(self) -> Session:
        """Get a new session for database operations"""
        if not self.driver:
            self._connect()
        return self.driver.session(database=self.database)
    
    def execute_read(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Execute read query with automatic retry"""
        with self.get_session() as session:
            return session.execute_read(self._execute_query, query, parameters or {})
    
    def execute_write(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Execute write query with transaction management"""
        with self.get_session() as session:
            return session.execute_write(self._execute_query, query, parameters or {})
    
    def _execute_query(self, tx: Transaction, query: str, parameters: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Execute query within transaction with error handling"""
        try:
            result = tx.run(query, parameters)
            return [record.data() for record in result]
        except TransientError as e:
            logger.warning(f"Transient error, retrying: {e}")
            raise
        except Exception as e:
            logger.error(f"Query execution failed: {e}")
            logger.error(f"Query: {query}")
            logger.error(f"Parameters: {parameters}")
            raise
    
    def close(self):
        """Close the driver connection"""
        if self.driver:
            self.driver.close()
            logger.info("🔌 Neo4j connection closed")

# Initialize connection manager
connection_manager = Neo4jConnectionManager(
    uri="bolt://localhost:7687",
    username="neo4j",
    password="coursepassword",  # Update with your password
    database="neo4j"
)

# Test connection
try:
    result = connection_manager.execute_read("MATCH (u:User) RETURN count(u) AS user_count")
    print(f"✅ Connection successful! Found {result[0]['user_count']} users in database")
except Exception as e:
    print(f"❌ Connection failed: {e}")
```

### Step 3: Enterprise Data Models and DTOs
```python
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

class UserStatus(str, Enum):
    ACTIVE = "Active"
    INACTIVE = "Inactive"
    SUSPENDED = "Suspended"
    PENDING = "Pending"

class DataClassification(str, Enum):
    PUBLIC = "PUBLIC"
    INTERNAL = "INTERNAL"
    CONFIDENTIAL = "CONFIDENTIAL"
    RESTRICTED = "RESTRICTED"

class UserProfileDTO(BaseModel):
    """Data Transfer Object for User Profile"""
    user_id: str = Field(..., description="Unique user identifier")
    tenant_id: str = Field(..., description="Tenant identifier")
    email: EmailStr = Field(..., description="User email address")
    employee_id: Optional[str] = Field(None, description="Employee ID")
    first_name: str = Field(..., min_length=1, max_length=50)
    last_name: str = Field(..., min_length=1, max_length=50)
    display_name: Optional[str] = Field(None, max_length=100)
    job_title: Optional[str] = Field(None, max_length=100)
    department: Optional[str] = Field(None, max_length=50)
    location: Optional[str] = Field(None, max_length=100)
    phone: Optional[str] = Field(None, regex=r'^\+?[1-9]\d{1,14}$')
    status: UserStatus = Field(default=UserStatus.ACTIVE)
    data_classification: DataClassification = Field(default=DataClassification.INTERNAL)
    created_at: Optional[datetime] = None
    last_login_at: Optional[datetime] = None
    
    @validator('display_name', always=True)
    def set_display_name(cls, v, values):
        if not v and 'first_name' in values and 'last_name' in values:
            return f"{values['first_name']} {values['last_name']}"
        return v

class RoleAssignmentDTO(BaseModel):
    """Data Transfer Object for Role Assignment"""
    user_id: str
    role_id: str
    role_name: str
    assigned_at: datetime
    assigned_by: str
    valid_from: datetime
    valid_to: Optional[datetime] = None
    status: str = "Active"

class PermissionDTO(BaseModel):
    """Data Transfer Object for Permission"""
    permission_id: str
    name: str
    description: str
    resource_type: str
    action: str
    scope: str
    risk_level: str

class UserWithRolesDTO(BaseModel):
    """Complete user information with roles and permissions"""
    profile: UserProfileDTO
    roles: List[RoleAssignmentDTO]
    permissions: List[PermissionDTO]
    tenant_name: str
    department_name: Optional[str] = None

print("✅ Data models and DTOs defined successfully")
```

### Step 4: Repository Pattern Implementation
```python
from abc import ABC, abstractmethod
from typing import Optional, List, Dict, Any

class BaseRepository(ABC):
    """Abstract base repository for common database operations"""
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
    
    @abstractmethod
    def create(self, entity: Dict[str, Any]) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    def get_by_id(self, entity_id: str) -> Optional[Dict[str, Any]]:
        pass
    
    @abstractmethod
    def update(self, entity_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        pass
    
    @abstractmethod
    def delete(self, entity_id: str) -> bool:
        pass

class UserRepository(BaseRepository):
    """Repository for User entity operations"""
    
    def create(self, user_data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new user with enterprise data model"""
        query = """
        MERGE (tenant:Tenant {tenantId: $tenant_id})
        CREATE (user:User {
            userId: $user_id,
            tenantId: $tenant_id,
            email: $email,
            employeeId: $employee_id,
            firstName: $first_name,
            lastName: $last_name,
            displayName: $display_name,
            jobTitle: $job_title,
            department: $department,
            location: $location,
            phone: $phone,
            status: $status,
            dataClassification: $data_classification,
            createdAt: datetime(),
            lastLoginAt: null,
            profileVersion: 1
        })
        CREATE (user)-[:BELONGS_TO {assignedAt: datetime(), status: 'Active'}]->(tenant)
        
        // Create initial profile version
        CREATE (profile:UserProfile {
            userId: $user_id,
            version: 1,
            firstName: $first_name,
            lastName: $last_name,
            jobTitle: $job_title,
            department: $department,
            location: $location,
            phone: $phone,
            validFrom: datetime(),
            validTo: null,
            createdAt: datetime(),
            createdBy: $user_id,
            changeReason: 'Initial profile creation'
        })
        CREATE (user)-[:CURRENT_PROFILE]->(profile)
        CREATE (user)-[:PROFILE_HISTORY]->(profile)
        
        RETURN user, profile, tenant
        """
        
        result = self.connection_manager.execute_write(query, user_data)
        if result:
            return result[0]
        raise Exception("Failed to create user")
    
    def get_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user by ID with current profile"""
        query = """
        MATCH (user:User {userId: $user_id})
        OPTIONAL MATCH (user)-[:CURRENT_PROFILE]->(profile:UserProfile)
        OPTIONAL MATCH (user)-[:BELONGS_TO]->(tenant:Tenant)
        RETURN user, profile, tenant
        """
        
        result = self.connection_manager.execute_read(query, {"user_id": user_id})
        return result[0] if result else None
    
    def get_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email address"""
        query = """
        MATCH (user:User {email: $email})
        OPTIONAL MATCH (user)-[:CURRENT_PROFILE]->(profile:UserProfile)
        OPTIONAL MATCH (user)-[:BELONGS_TO]->(tenant:Tenant)
        RETURN user, profile, tenant
        """
        
        result = self.connection_manager.execute_read(query, {"email": email})
        return result[0] if result else None
    
    def get_user_roles(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all roles assigned to a user"""
        query = """
        MATCH (user:User {userId: $user_id})-[assignment:HAS_ROLE]->(role:Role)
        WHERE assignment.status = 'Active' 
          AND assignment.validFrom <= datetime()
          AND (assignment.validTo IS NULL OR assignment.validTo > datetime())
        RETURN role, assignment
        ORDER BY assignment.assignedAt DESC
        """
        
        return self.connection_manager.execute_read(query, {"user_id": user_id})
    
    def get_user_permissions(self, user_id: str) -> List[Dict[str, Any]]:
        """Get all permissions for a user through their roles"""
        query = """
        MATCH (user:User {userId: $user_id})-[assignment:HAS_ROLE]->(role:Role)
        WHERE assignment.status = 'Active' 
          AND assignment.validFrom <= datetime()
          AND (assignment.validTo IS NULL OR assignment.validTo > datetime())
        
        MATCH (role)-[:HAS_PERMISSION]->(permission:Permission)
        RETURN DISTINCT permission
        ORDER BY permission.resourceType, permission.action
        """
        
        return self.connection_manager.execute_read(query, {"user_id": user_id})
    
    def update(self, user_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        """Update user profile with versioning"""
        # First get current version
        current_user = self.get_by_id(user_id)
        if not current_user:
            raise Exception(f"User {user_id} not found")
        
        current_version = current_user['profile']['version']
        new_version = current_version + 1
        
        query = """
        MATCH (user:User {userId: $user_id})
        MATCH (user)-[current:CURRENT_PROFILE]->(oldProfile:UserProfile)
        
        // Close old profile version
        SET oldProfile.validTo = datetime()
        DELETE current
        
        // Create new profile version
        CREATE (newProfile:UserProfile {
            userId: $user_id,
            version: $new_version,
            firstName: COALESCE($first_name, oldProfile.firstName),
            lastName: COALESCE($last_name, oldProfile.lastName),
            jobTitle: COALESCE($job_title, oldProfile.jobTitle),
            department: COALESCE($department, oldProfile.department),
            location: COALESCE($location, oldProfile.location),
            phone: COALESCE($phone, oldProfile.phone),
            validFrom: datetime(),
            validTo: null,
            createdAt: datetime(),
            createdBy: $updated_by,
            changeReason: $change_reason
        })
        
        CREATE (user)-[:CURRENT_PROFILE]->(newProfile)
        CREATE (user)-[:PROFILE_HISTORY]->(newProfile)
        CREATE (oldProfile)-[:SUPERSEDED_BY]->(newProfile)
        
        // Update user properties that changed
        SET user += $user_updates
        
        RETURN user, newProfile
        """
        
        params = {
            "user_id": user_id,
            "new_version": new_version,
            "updated_by": updates.get("updated_by", "system"),
            "change_reason": updates.get("change_reason", "Profile update"),
            "user_updates": {k: v for k, v in updates.items() 
                           if k in ['email', 'status', 'lastLoginAt']},
            **{k: v for k, v in updates.items() 
               if k in ['first_name', 'last_name', 'job_title', 'department', 'location', 'phone']}
        }
        
        result = self.connection_manager.execute_write(query, params)
        return result[0] if result else None
    
    def delete(self, user_id: str) -> bool:
        """Soft delete user by setting status to Inactive"""
        query = """
        MATCH (user:User {userId: $user_id})
        SET user.status = 'Inactive',
            user.deactivatedAt = datetime()
        RETURN user.status AS status
        """
        
        result = self.connection_manager.execute_write(query, {"user_id": user_id})
        return len(result) > 0 and result[0]['status'] == 'Inactive'
    
    def list_by_tenant(self, tenant_id: str, limit: int = 100) -> List[Dict[str, Any]]:
        """List users by tenant with pagination"""
        query = """
        MATCH (user:User {tenantId: $tenant_id})
        OPTIONAL MATCH (user)-[:CURRENT_PROFILE]->(profile:UserProfile)
        OPTIONAL MATCH (user)-[:BELONGS_TO]->(tenant:Tenant)
        WHERE user.status = 'Active'
        RETURN user, profile, tenant
        ORDER BY user.createdAt DESC
        LIMIT $limit
        """
        
        return self.connection_manager.execute_read(query, {
            "tenant_id": tenant_id, 
            "limit": limit
        })

# Initialize repository
user_repository = UserRepository(connection_manager)
print("✅ User repository initialized successfully")
```

## Part 2: FastAPI Web Application Development (25 minutes)

### Step 5: Authentication and Security System
```python
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from jose import JWTError, jwt
from datetime import datetime, timedelta
import bcrypt
from typing import Optional

# Security configuration
SECRET_KEY = "your-super-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

security = HTTPBearer()

class AuthenticationService:
    """Service for handling authentication and authorization"""
    
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository
    
    def hash_password(self, password: str) -> str:
        """Hash a password using bcrypt"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    def verify_password(self, password: str, hashed_password: str) -> bool:
        """Verify a password against its hash"""
        return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
    
    def create_access_token(self, user_id: str, tenant_id: str) -> str:
        """Create a JWT access token"""
        to_encode = {
            "sub": user_id,
            "tenant_id": tenant_id,
            "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        }
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    
    def verify_token(self, token: str) -> Dict[str, Any]:
        """Verify and decode a JWT token"""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id: str = payload.get("sub")
            tenant_id: str = payload.get("tenant_id")
            
            if user_id is None or tenant_id is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token payload"
                )
            
            return {"user_id": user_id, "tenant_id": tenant_id}
            
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )
    
    def get_current_user(self, credentials: HTTPAuthorizationCredentials = Depends(security)) -> Dict[str, Any]:
        """Get current user from JWT token"""
        token_data = self.verify_token(credentials.credentials)
        user = self.user_repository.get_by_id(token_data["user_id"])
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        
        return user
    
    def check_permission(self, user_id: str, resource_type: str, action: str) -> bool:
        """Check if user has specific permission"""
        permissions = self.user_repository.get_user_permissions(user_id)
        
        for perm_data in permissions:
            permission = perm_data['permission']
            if (permission['resourceType'] == resource_type and 
                permission['action'] == action) or permission['action'] == '*':
                return True
        
        return False

# Initialize authentication service
auth_service = AuthenticationService(user_repository)

# Initialize FastAPI app
app = FastAPI(
    title="Enterprise Graph API",
    description="Production-ready API for enterprise graph database",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],  # Frontend URLs
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

print("✅ Authentication service and FastAPI app initialized")
```

### Step 6: API Endpoints for User Management
```python
from fastapi import Query, Path, Body
from pydantic import BaseModel

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int = ACCESS_TOKEN_EXPIRE_MINUTES * 60

class UserCreateRequest(BaseModel):
    tenant_id: str
    email: EmailStr
    employee_id: Optional[str] = None
    first_name: str
    last_name: str
    job_title: Optional[str] = None
    department: Optional[str] = None
    location: Optional[str] = None
    phone: Optional[str] = None
    initial_password: str

class UserUpdateRequest(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    job_title: Optional[str] = None
    department: Optional[str] = None
    location: Optional[str] = None
    phone: Optional[str] = None
    change_reason: Optional[str] = "User profile update"

@app.post("/auth/login", response_model=TokenResponse)
async def login(request: LoginRequest):
    """Authenticate user and return access token"""
    # In production, store hashed passwords in the database
    # For demo, we'll simulate authentication
    user = user_repository.get_by_email(request.email)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # In production, verify against stored password hash
    # For demo, any password works
    user_data = user['user']
    token = auth_service.create_access_token(
        user_id=user_data['userId'],
        tenant_id=user_data['tenantId']
    )
    
    # Update last login time
    user_repository.connection_manager.execute_write(
        "MATCH (u:User {userId: $user_id}) SET u.lastLoginAt = datetime()",
        {"user_id": user_data['userId']}
    )
    
    return TokenResponse(access_token=token)

@app.get("/users/me", response_model=UserWithRolesDTO)
async def get_current_user_profile(current_user: Dict = Depends(auth_service.get_current_user)):
    """Get current user's complete profile"""
    user_data = current_user['user']
    profile_data = current_user['profile']
    tenant_data = current_user['tenant']
    
    # Get roles and permissions
    roles = user_repository.get_user_roles(user_data['userId'])
    permissions = user_repository.get_user_permissions(user_data['userId'])
    
    # Convert to DTOs
    profile = UserProfileDTO(
        user_id=user_data['userId'],
        tenant_id=user_data['tenantId'],
        email=user_data['email'],
        employee_id=user_data.get('employeeId'),
        first_name=profile_data['firstName'],
        last_name=profile_data['lastName'],
        display_name=user_data.get('displayName'),
        job_title=profile_data.get('jobTitle'),
        department=profile_data.get('department'),
        location=profile_data.get('location'),
        phone=profile_data.get('phone'),
        status=user_data['status'],
        data_classification=user_data.get('dataClassification', 'INTERNAL'),
        created_at=user_data.get('createdAt'),
        last_login_at=user_data.get('lastLoginAt')
    )
    
    role_dtos = [
        RoleAssignmentDTO(
            user_id=user_data['userId'],
            role_id=role_data['role']['roleId'],
            role_name=role_data['role']['name'],
            assigned_at=role_data['assignment']['assignedAt'],
            assigned_by=role_data['assignment']['assignedBy'],
            valid_from=role_data['assignment']['validFrom'],
            valid_to=role_data['assignment'].get('validTo'),
            status=role_data['assignment']['status']
        )
        for role_data in roles
    ]
    
    permission_dtos = [
        PermissionDTO(
            permission_id=perm_data['permission']['permissionId'],
            name=perm_data['permission']['name'],
            description=perm_data['permission']['description'],
            resource_type=perm_data['permission']['resourceType'],
            action=perm_data['permission']['action'],
            scope=perm_data['permission']['scope'],
            risk_level=perm_data['permission']['riskLevel']
        )
        for perm_data in permissions
    ]
    
    return UserWithRolesDTO(
        profile=profile,
        roles=role_dtos,
        permissions=permission_dtos,
        tenant_name=tenant_data['name'],
        department_name=profile_data.get('department')
    )

@app.post("/users", response_model=UserProfileDTO)
async def create_user(
    request: UserCreateRequest,
    current_user: Dict = Depends(auth_service.get_current_user)
):
    """Create a new user (requires admin privileges)"""
    current_user_id = current_user['user']['userId']
    
    # Check permissions
    if not auth_service.check_permission(current_user_id, "User", "CREATE"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to create users"
        )
    
    # Generate unique user ID
    user_id = f"{request.first_name.lower()}.{request.last_name.lower()}.{int(datetime.now().timestamp())}"
    
    user_data = {
        "user_id": user_id,
        "tenant_id": request.tenant_id,
        "email": request.email,
        "employee_id": request.employee_id,
        "first_name": request.first_name,
        "last_name": request.last_name,
        "display_name": f"{request.first_name} {request.last_name}",
        "job_title": request.job_title,
        "department": request.department,
        "location": request.location,
        "phone": request.phone,
        "status": "Active",
        "data_classification": "INTERNAL"
    }
    
    try:
        result = user_repository.create(user_data)
        created_user = result['user']
        created_profile = result['profile']
        
        return UserProfileDTO(
            user_id=created_user['userId'],
            tenant_id=created_user['tenantId'],
            email=created_user['email'],
            employee_id=created_user.get('employeeId'),
            first_name=created_profile['firstName'],
            last_name=created_profile['lastName'],
            display_name=created_user.get('displayName'),
            job_title=created_profile.get('jobTitle'),
            department=created_profile.get('department'),
            location=created_profile.get('location'),
            phone=created_profile.get('phone'),
            status=created_user['status'],
            data_classification=created_user.get('dataClassification', 'INTERNAL'),
            created_at=created_user.get('createdAt')
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create user: {str(e)}"
        )

@app.put("/users/{user_id}", response_model=UserProfileDTO)
async def update_user(
    user_id: str = Path(..., description="User ID to update"),
    request: UserUpdateRequest = Body(...),
    current_user: Dict = Depends(auth_service.get_current_user)
):
    """Update user profile with versioning"""
    current_user_id = current_user['user']['userId']
    
    # Check permissions (can update own profile or needs admin privileges)
    if (user_id != current_user_id and 
        not auth_service.check_permission(current_user_id, "User", "UPDATE")):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to update this user"
        )
    
    # Prepare update data
    updates = {k: v for k, v in request.dict().items() if v is not None}
    updates["updated_by"] = current_user_id
    
    try:
        result = user_repository.update(user_id, updates)
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        updated_user = result['user']
        updated_profile = result['newProfile']
        
        return UserProfileDTO(
            user_id=updated_user['userId'],
            tenant_id=updated_user['tenantId'],
            email=updated_user['email'],
            employee_id=updated_user.get('employeeId'),
            first_name=updated_profile['firstName'],
            last_name=updated_profile['lastName'],
            display_name=updated_user.get('displayName'),
            job_title=updated_profile.get('jobTitle'),
            department=updated_profile.get('department'),
            location=updated_profile.get('location'),
            phone=updated_profile.get('phone'),
            status=updated_user['status'],
            data_classification=updated_user.get('dataClassification', 'INTERNAL'),
            created_at=updated_user.get('createdAt')
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update user: {str(e)}"
        )

@app.get("/users", response_model=List[UserProfileDTO])
async def list_users(
    tenant_id: Optional[str] = Query(None, description="Filter by tenant ID"),
    limit: int = Query(100, ge=1, le=1000, description="Number of users to return"),
    current_user: Dict = Depends(auth_service.get_current_user)
):
    """List users with optional tenant filtering"""
    current_user_data = current_user['user']
    current_user_id = current_user_data['userId']
    
    # Check permissions
    if not auth_service.check_permission(current_user_id, "User", "READ"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to list users"
        )
    
    # Use current user's tenant if not specified and not admin
    if not tenant_id:
        tenant_id = current_user_data['tenantId']
    
    try:
        users = user_repository.list_by_tenant(tenant_id, limit)
        
        return [
            UserProfileDTO(
                user_id=user_data['user']['userId'],
                tenant_id=user_data['user']['tenantId'],
                email=user_data['user']['email'],
                employee_id=user_data['user'].get('employeeId'),
                first_name=user_data['profile']['firstName'],
                last_name=user_data['profile']['lastName'],
                display_name=user_data['user'].get('displayName'),
                job_title=user_data['profile'].get('jobTitle'),
                department=user_data['profile'].get('department'),
                location=user_data['profile'].get('location'),
                phone=user_data['profile'].get('phone'),
                status=user_data['user']['status'],
                data_classification=user_data['user'].get('dataClassification', 'INTERNAL'),
                created_at=user_data['user'].get('createdAt'),
                last_login_at=user_data['user'].get('lastLoginAt')
            )
            for user_data in users
        ]
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve users: {str(e)}"
        )

print("✅ API endpoints defined successfully")
```

### Step 7: Advanced Graph Analytics Endpoints
```python
class NetworkMetricsDTO(BaseModel):
    """Network analysis metrics"""
    total_users: int
    active_users: int
    total_departments: int
    avg_team_size: float
    connectivity_score: float
    most_connected_users: List[Dict[str, Any]]

class OrgChartDTO(BaseModel):
    """Organizational chart data"""
    user_id: str
    name: str
    job_title: str
    department: str
    level: int
    reports_to: Optional[str] = None
    direct_reports: List[str] = []

@app.get("/analytics/network-metrics", response_model=NetworkMetricsDTO)
async def get_network_metrics(
    tenant_id: Optional[str] = Query(None),
    current_user: Dict = Depends(auth_service.get_current_user)
):
    """Get network analysis metrics for the organization"""
    current_user_data = current_user['user']
    current_user_id = current_user_data['userId']
    
    # Check permissions
    if not auth_service.check_permission(current_user_id, "Analytics", "READ"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view analytics"
        )
    
    # Use current user's tenant if not specified
    if not tenant_id:
        tenant_id = current_user_data['tenantId']
    
    try:
        # Get basic metrics
        basic_metrics_query = """
        MATCH (u:User {tenantId: $tenant_id})
        OPTIONAL MATCH (u)-[:MEMBER_OF]->(d:Department)
        WITH count(DISTINCT u) AS total_users,
             count(CASE WHEN u.status = 'Active' THEN 1 END) AS active_users,
             count(DISTINCT d) AS total_departments
        RETURN total_users, active_users, total_departments
        """
        
        basic_result = connection_manager.execute_read(basic_metrics_query, {"tenant_id": tenant_id})
        basic_metrics = basic_result[0]
        
        # Get department sizes for average calculation
        dept_size_query = """
        MATCH (d:Department)<-[:MEMBER_OF]-(u:User {tenantId: $tenant_id})
        WHERE u.status = 'Active'
        RETURN d.name AS department, count(u) AS size
        """
        
        dept_sizes = connection_manager.execute_read(dept_size_query, {"tenant_id": tenant_id})
        avg_team_size = sum(dept['size'] for dept in dept_sizes) / len(dept_sizes) if dept_sizes else 0
        
        # Calculate connectivity (reporting relationships)
        connectivity_query = """
        MATCH (u1:User {tenantId: $tenant_id})-[:REPORTS_TO]->(u2:User {tenantId: $tenant_id})
        WITH count(*) AS connections
        MATCH (u:User {tenantId: $tenant_id})
        WITH connections, count(u) AS total_users
        RETURN CASE WHEN total_users > 1 
               THEN toFloat(connections) / (total_users * (total_users - 1) / 2)
               ELSE 0.0 END AS connectivity_score
        """
        
        connectivity_result = connection_manager.execute_read(connectivity_query, {"tenant_id": tenant_id})
        connectivity_score = connectivity_result[0]['connectivity_score'] if connectivity_result else 0.0
        
        # Get most connected users (by direct reports)
        connected_users_query = """
        MATCH (manager:User {tenantId: $tenant_id})<-[:REPORTS_TO]-(report:User)
        WHERE manager.status = 'Active'
        WITH manager, count(report) AS direct_reports
        ORDER BY direct_reports DESC
        LIMIT 5
        RETURN manager.userId AS user_id,
               manager.displayName AS name,
               manager.jobTitle AS job_title,
               direct_reports
        """
        
        connected_users = connection_manager.execute_read(connected_users_query, {"tenant_id": tenant_id})
        
        return NetworkMetricsDTO(
            total_users=basic_metrics['total_users'],
            active_users=basic_metrics['active_users'],
            total_departments=basic_metrics['total_departments'],
            avg_team_size=round(avg_team_size, 2),
            connectivity_score=round(connectivity_score, 3),
            most_connected_users=connected_users
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve network metrics: {str(e)}"
        )

@app.get("/analytics/org-chart", response_model=List[OrgChartDTO])
async def get_organizational_chart(
    tenant_id: Optional[str] = Query(None),
    current_user: Dict = Depends(auth_service.get_current_user)
):
    """Get organizational chart structure"""
    current_user_data = current_user['user']
    current_user_id = current_user_data['userId']
    
    # Check permissions
    if not auth_service.check_permission(current_user_id, "Analytics", "READ"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view organizational chart"
        )
    
    # Use current user's tenant if not specified
    if not tenant_id:
        tenant_id = current_user_data['tenantId']
    
    try:
        org_chart_query = """
        MATCH (u:User {tenantId: $tenant_id})
        WHERE u.status = 'Active'
        OPTIONAL MATCH (u)-[:REPORTS_TO]->(manager:User)
        OPTIONAL MATCH (u)<-[:REPORTS_TO]-(report:User)
        OPTIONAL MATCH (u)-[:CURRENT_PROFILE]->(profile:UserProfile)
        
        WITH u, manager, collect(DISTINCT report.userId) AS direct_reports, profile
        
        // Calculate organizational level
        OPTIONAL MATCH path = (u)-[:REPORTS_TO*]->(top:User)
        WHERE NOT (top)-[:REPORTS_TO]->()
        WITH u, manager, direct_reports, profile, 
             CASE WHEN path IS NULL THEN 0 ELSE length(path) END AS level_from_top
        
        RETURN u.userId AS user_id,
               u.displayName AS name,
               profile.jobTitle AS job_title,
               profile.department AS department,
               level_from_top,
               manager.userId AS reports_to,
               direct_reports
        ORDER BY level_from_top, profile.department, u.displayName
        """
        
        result = connection_manager.execute_read(org_chart_query, {"tenant_id": tenant_id})
        
        return [
            OrgChartDTO(
                user_id=row['user_id'],
                name=row['name'],
                job_title=row['job_title'] or "Unknown Title",
                department=row['department'] or "Unknown Department",
                level=row['level_from_top'],
                reports_to=row['reports_to'],
                direct_reports=row['direct_reports']
            )
            for row in result
        ]
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve organizational chart: {str(e)}"
        )

print("✅ Analytics endpoints defined successfully")
```

## Part 3: Testing and Quality Assurance (20 minutes)

### Step 8: Unit Tests for Repository Layer
```python
import pytest
from unittest.mock import Mock, patch
import uuid

class TestUserRepository:
    """Unit tests for UserRepository"""
    
    def setup_method(self):
        """Set up test fixtures"""
        self.mock_connection_manager = Mock()
        self.user_repository = UserRepository(self.mock_connection_manager)
        
        # Sample user data
        self.sample_user_data = {
            "user_id": "test.user.123",
            "tenant_id": "test-tenant",
            "email": "test.user@example.com",
            "first_name": "Test",
            "last_name": "User",
            "job_title": "Software Engineer",
            "department": "Engineering",
            "status": "Active",
            "data_classification": "INTERNAL"
        }
    
    def test_create_user_success(self):
        """Test successful user creation"""
        # Mock successful database response
        expected_result = [{
            "user": self.sample_user_data,
            "profile": {"version": 1, **self.sample_user_data},
            "tenant": {"tenantId": "test-tenant", "name": "Test Tenant"}
        }]
        self.mock_connection_manager.execute_write.return_value = expected_result
        
        # Execute
        result = self.user_repository.create(self.sample_user_data)
        
        # Verify
        assert result == expected_result[0]
        self.mock_connection_manager.execute_write.assert_called_once()
    
    def test_create_user_failure(self):
        """Test user creation failure"""
        # Mock database failure
        self.mock_connection_manager.execute_write.return_value = []
        
        # Execute and verify exception
        with pytest.raises(Exception, match="Failed to create user"):
            self.user_repository.create(self.sample_user_data)
    
    def test_get_user_by_id_found(self):
        """Test retrieving existing user"""
        # Mock database response
        expected_result = [{
            "user": self.sample_user_data,
            "profile": {"version": 1, **self.sample_user_data},
            "tenant": {"tenantId": "test-tenant", "name": "Test Tenant"}
        }]
        self.mock_connection_manager.execute_read.return_value = expected_result
        
        # Execute
        result = self.user_repository.get_by_id("test.user.123")
        
        # Verify
        assert result == expected_result[0]
        self.mock_connection_manager.execute_read.assert_called_once()
    
    def test_get_user_by_id_not_found(self):
        """Test retrieving non-existent user"""
        # Mock empty database response
        self.mock_connection_manager.execute_read.return_value = []
        
        # Execute
        result = self.user_repository.get_by_id("nonexistent.user")
        
        # Verify
        assert result is None
    
    def test_update_user_success(self):
        """Test successful user update with versioning"""
        # Mock current user retrieval
        current_user = {
            "user": self.sample_user_data,
            "profile": {"version": 1, **self.sample_user_data}
        }
        
        # Mock update result
        updated_result = [{
            "user": {**self.sample_user_data, "status": "Active"},
            "newProfile": {"version": 2, "job_title": "Senior Software Engineer"}
        }]
        
        # Setup mocks
        with patch.object(self.user_repository, 'get_by_id', return_value=current_user):
            self.mock_connection_manager.execute_write.return_value = updated_result
            
            # Execute
            result = self.user_repository.update("test.user.123", {
                "job_title": "Senior Software Engineer",
                "updated_by": "admin",
                "change_reason": "Promotion"
            })
            
            # Verify
            assert result == updated_result[0]
            self.mock_connection_manager.execute_write.assert_called_once()

# Run tests
def run_repository_tests():
    """Run repository unit tests"""
    test_instance = TestUserRepository()
    test_methods = [method for method in dir(test_instance) if method.startswith('test_')]
    
    passed = 0
    failed = 0
    
    for test_method in test_methods:
        try:
            test_instance.setup_method()
            getattr(test_instance, test_method)()
            print(f"✅ {test_method} - PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ {test_method} - FAILED: {e}")
            failed += 1
    
    print(f"\n📊 Test Results: {passed} passed, {failed} failed")
    return failed == 0

# Run the tests
print("🧪 Running repository unit tests...")
run_repository_tests()
```

### Step 9: Integration Tests for API Endpoints
```python
from fastapi.testclient import TestClient
import json

# Create test client
client = TestClient(app)

class TestAPIEndpoints:
    """Integration tests for API endpoints"""
    
    def setup_method(self):
        """Set up test data"""
        self.test_user_email = "alice.johnson@techcorp.com"
        self.test_password = "testpassword123"
        self.access_token = None
    
    def test_login_success(self):
        """Test successful login"""
        response = client.post("/auth/login", json={
            "email": self.test_user_email,
            "password": self.test_password
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        
        # Store token for subsequent tests
        self.access_token = data["access_token"]
        return self.access_token
    
    def test_login_invalid_credentials(self):
        """Test login with invalid credentials"""
        response = client.post("/auth/login", json={
            "email": "nonexistent@example.com",
            "password": "wrongpassword"
        })
        
        assert response.status_code == 401
    
    def test_get_current_user_profile(self):
        """Test retrieving current user profile"""
        # First login to get token
        token = self.test_login_success()
        
        # Get user profile
        response = client.get("/users/me", headers={
            "Authorization": f"Bearer {token}"
        })
        
        assert response.status_code == 200
        data = response.json()
        assert "profile" in data
        assert "roles" in data
        assert "permissions" in data
        assert data["profile"]["email"] == self.test_user_email
    
    def test_get_current_user_unauthorized(self):
        """Test accessing protected endpoint without token"""
        response = client.get("/users/me")
        assert response.status_code == 403  # No token provided
    
    def test_list_users_with_auth(self):
        """Test listing users with proper authentication"""
        # Login first
        token = self.test_login_success()
        
        # List users
        response = client.get("/users", headers={
            "Authorization": f"Bearer {token}"
        })
        
        # Should succeed if user has proper permissions
        assert response.status_code in [200, 403]  # 403 if insufficient permissions
    
    def test_network_metrics_with_auth(self):
        """Test analytics endpoint with authentication"""
        # Login first
        token = self.test_login_success()
        
        # Get network metrics
        response = client.get("/analytics/network-metrics", headers={
            "Authorization": f"Bearer {token}"
        })
        
        # Should succeed if user has analytics permissions
        assert response.status_code in [200, 403]

# Run integration tests
def run_integration_tests():
    """Run API integration tests"""
    test_instance = TestAPIEndpoints()
    test_methods = [method for method in dir(test_instance) if method.startswith('test_')]
    
    passed = 0
    failed = 0
    
    for test_method in test_methods:
        try:
            test_instance.setup_method()
            getattr(test_instance, test_method)()
            print(f"✅ {test_method} - PASSED")
            passed += 1
        except Exception as e:
            print(f"❌ {test_method} - FAILED: {e}")
            failed += 1
    
    print(f"\n📊 Integration Test Results: {passed} passed, {failed} failed")
    return failed == 0

# Run the integration tests
print("🧪 Running API integration tests...")
run_integration_tests()
```

### Step 10: Load Testing and Performance Validation
```python
import asyncio
import aiohttp
import time
from typing import List
import statistics

class LoadTester:
    """Simple load testing utility for API endpoints"""
    
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.session = None
    
    async def setup_session(self):
        """Initialize HTTP session"""
        self.session = aiohttp.ClientSession()
    
    async def cleanup_session(self):
        """Cleanup HTTP session"""
        if self.session:
            await self.session.close()
    
    async def login_and_get_token(self) -> str:
        """Login and return access token"""
        async with self.session.post(f"{self.base_url}/auth/login", json={
            "email": "alice.johnson@techcorp.com",
            "password": "testpassword"
        }) as response:
            if response.status == 200:
                data = await response.json()
                return data["access_token"]
            else:
                raise Exception(f"Login failed: {response.status}")
    
    async def make_authenticated_request(self, endpoint: str, token: str) -> dict:
        """Make authenticated request and return timing data"""
        start_time = time.time()
        
        headers = {"Authorization": f"Bearer {token}"}
        async with self.session.get(f"{self.base_url}{endpoint}", headers=headers) as response:
            end_time = time.time()
            
            return {
                "endpoint": endpoint,
                "status": response.status,
                "response_time": end_time - start_time,
                "success": response.status == 200
            }
    
    async def run_load_test(self, endpoint: str, concurrent_requests: int = 10, total_requests: int = 100):
        """Run load test on specific endpoint"""
        await self.setup_session()
        
        try:
            # Get authentication token
            token = await self.login_and_get_token()
            
            print(f"🚀 Starting load test: {endpoint}")
            print(f"   Concurrent requests: {concurrent_requests}")
            print(f"   Total requests: {total_requests}")
            
            # Create semaphore to limit concurrent requests
            semaphore = asyncio.Semaphore(concurrent_requests)
            
            async def limited_request():
                async with semaphore:
                    return await self.make_authenticated_request(endpoint, token)
            
            # Execute all requests
            start_time = time.time()
            tasks = [limited_request() for _ in range(total_requests)]
            results = await asyncio.gather(*tasks, return_exceptions=True)
            end_time = time.time()
            
            # Process results
            successful_results = [r for r in results if isinstance(r, dict) and r["success"]]
            failed_results = [r for r in results if isinstance(r, dict) and not r["success"]]
            error_results = [r for r in results if isinstance(r, Exception)]
            
            # Calculate statistics
            if successful_results:
                response_times = [r["response_time"] for r in successful_results]
                
                stats = {
                    "total_requests": total_requests,
                    "successful_requests": len(successful_results),
                    "failed_requests": len(failed_results),
                    "error_requests": len(error_results),
                    "success_rate": len(successful_results) / total_requests * 100,
                    "total_time": end_time - start_time,
                    "requests_per_second": total_requests / (end_time - start_time),
                    "avg_response_time": statistics.mean(response_times),
                    "min_response_time": min(response_times),
                    "max_response_time": max(response_times),
                    "p95_response_time": statistics.quantiles(response_times, n=20)[18] if len(response_times) > 1 else response_times[0]
                }
                
                # Print results
                print(f"\n📊 Load Test Results for {endpoint}:")
                print(f"   Total Requests: {stats['total_requests']}")
                print(f"   Successful: {stats['successful_requests']} ({stats['success_rate']:.1f}%)")
                print(f"   Failed: {stats['failed_requests']}")
                print(f"   Errors: {stats['error_requests']}")
                print(f"   Requests/Second: {stats['requests_per_second']:.2f}")
                print(f"   Avg Response Time: {stats['avg_response_time']:.3f}s")
                print(f"   Min Response Time: {stats['min_response_time']:.3f}s")
                print(f"   Max Response Time: {stats['max_response_time']:.3f}s")
                print(f"   95th Percentile: {stats['p95_response_time']:.3f}s")
                
                return stats
            else:
                print("❌ No successful requests in load test")
                return None
                
        finally:
            await self.cleanup_session()

# Performance testing function
async def run_performance_tests():
    """Run performance tests on key endpoints"""
    load_tester = LoadTester()
    
    # Test scenarios
    test_scenarios = [
        {
            "endpoint": "/users/me",
            "concurrent": 5,
            "total": 50,
            "description": "User profile retrieval"
        },
        {
            "endpoint": "/users",
            "concurrent": 3,
            "total": 30,
            "description": "User listing"
        },
        {
            "endpoint": "/analytics/network-metrics",
            "concurrent": 2,
            "total": 20,
            "description": "Network analytics"
        }
    ]
    
    results = []
    for scenario in test_scenarios:
        print(f"\n🎯 Testing: {scenario['description']}")
        stats = await load_tester.run_load_test(
            scenario["endpoint"],
            scenario["concurrent"],
            scenario["total"]
        )
        if stats:
            results.append({**scenario, "stats": stats})
    
    # Summary
    print(f"\n🏁 Performance Test Summary:")
    for result in results:
        stats = result["stats"]
        print(f"   {result['description']}: {stats['requests_per_second']:.2f} req/s, "
              f"{stats['avg_response_time']:.3f}s avg")
    
    return results

# Note: This is an async function, so we can't run it directly in Jupyter
# Instead, we'll create a synchronous wrapper
def run_sync_performance_tests():
    """Synchronous wrapper for performance tests"""
    try:
        import nest_asyncio
        nest_asyncio.apply()
        return asyncio.run(run_performance_tests())
    except ImportError:
        print("⚠️ nest_asyncio not available. Run load tests separately.")
        return None
    except Exception as e:
        print(f"⚠️ Performance tests skipped: {e}")
        return None

print("🧪 Performance testing utilities ready")
```

## Part 4: Production Deployment Preparation (15 minutes)

### Step 11: Configuration Management and Environment Setup
```python
import os
from pathlib import Path
from typing import Optional
from pydantic import BaseSettings, Field

class Settings(BaseSettings):
    """Application configuration with environment variable support"""
    
    # Database configuration
    neo4j_uri: str = Field(default="bolt://localhost:7687", env="NEO4J_URI")
    neo4j_username: str = Field(default="neo4j", env="NEO4J_USERNAME") 
    neo4j_password: str = Field(default="coursepassword", env="NEO4J_PASSWORD")
    neo4j_database: str = Field(default="neo4j", env="NEO4J_DATABASE")
    
    # Security configuration
    secret_key: str = Field(default="dev-secret-key-change-in-production", env="SECRET_KEY")
    algorithm: str = Field(default="HS256", env="JWT_ALGORITHM")
    access_token_expire_minutes: int = Field(default=30, env="ACCESS_TOKEN_EXPIRE_MINUTES")
    
    # Application configuration
    app_name: str = Field(default="Enterprise Graph API", env="APP_NAME")
    app_version: str = Field(default="1.0.0", env="APP_VERSION")
    debug: bool = Field(default=True, env="DEBUG")
    
    # CORS configuration
    allowed_origins: list = Field(default=["http://localhost:3000", "http://localhost:8080"], env="ALLOWED_ORIGINS")
    
    # Logging configuration
    log_level: str = Field(default="INFO", env="LOG_LEVEL")
    log_format: str = Field(default="%(asctime)s - %(name)s - %(levelname)s - %(message)s", env="LOG_FORMAT")
    
    # Performance configuration
    max_connection_pool_size: int = Field(default=50, env="MAX_CONNECTION_POOL_SIZE")
    connection_timeout: int = Field(default=60, env="CONNECTION_TIMEOUT")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

# Initialize settings
settings = Settings()

# Create environment file template
def create_env_template():
    """Create .env template file for production deployment"""
    env_template = """# Neo4j Database Configuration
NEO4J_URI=bolt://localhost:7687
NEO4J_USERNAME=neo4j
NEO4J_PASSWORD=your-secure-password
NEO4J_DATABASE=neo4j

# Security Configuration (CHANGE IN PRODUCTION!)
SECRET_KEY=your-super-secret-key-min-32-characters
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Application Configuration
APP_NAME=Enterprise Graph API
APP_VERSION=1.0.0
DEBUG=false

# CORS Configuration
ALLOWED_ORIGINS=["https://yourdomain.com","https://app.yourdomain.com"]

# Logging Configuration
LOG_LEVEL=INFO

# Performance Configuration
MAX_CONNECTION_POOL_SIZE=50
CONNECTION_TIMEOUT=60
"""
    
    with open(".env.template", "w") as f:
        f.write(env_template)
    
    print("✅ Created .env.template file")
    print("   Copy to .env and update values for your environment")

create_env_template()

# Enhanced logging configuration
import logging.config

def setup_logging():
    """Configure application logging"""
    logging_config = {
        'version': 1,
        'disable_existing_loggers': False,
        'formatters': {
            'standard': {
                'format': settings.log_format
            },
            'detailed': {
                'format': '%(asctime)s - %(name)s - %(levelname)s - %(module)s - %(funcName)s - %(message)s'
            }
        },
        'handlers': {
            'console': {
                'level': settings.log_level,
                'class': 'logging.StreamHandler',
                'formatter': 'standard'
            },
            'file': {
                'level': 'INFO',
                'class': 'logging.FileHandler',
                'filename': 'app.log',
                'formatter': 'detailed',
                'encoding': 'utf-8'
            }
        },
        'loggers': {
            '': {  # Root logger
                'handlers': ['console', 'file'],
                'level': settings.log_level,
                'propagate': False
            },
            'neo4j': {
                'handlers': ['console', 'file'],
                'level': 'WARNING',
                'propagate': False
            }
        }
    }
    
    logging.config.dictConfig(logging_config)
    logger = logging.getLogger(__name__)
    logger.info(f"Logging configured with level: {settings.log_level}")

setup_logging()
print("✅ Logging configuration completed")
```

### Step 12: Health Checks and Monitoring
```python
from datetime import datetime
import psutil
import asyncio

class HealthChecker:
    """Health check service for monitoring application status"""
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
        self.start_time = datetime.now()
    
    async def check_database_health(self) -> dict:
        """Check Neo4j database connectivity and performance"""
        try:
            start_time = time.time()
            
            # Test basic connectivity
            result = self.connection_manager.execute_read("RETURN 1 AS test")
            
            # Test query performance
            perf_result = self.connection_manager.execute_read("""
                MATCH (u:User) 
                RETURN count(u) AS user_count
                LIMIT 1
            """)
            
            end_time = time.time()
            response_time = end_time - start_time
            
            return {
                "status": "healthy",
                "response_time_ms": round(response_time * 1000, 2),
                "user_count": perf_result[0]['user_count'] if perf_result else 0,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def check_system_resources(self) -> dict:
        """Check system resource utilization"""
        try:
            cpu_percent = psutil.cpu_percent(interval=1)
            memory = psutil.virtual_memory()
            disk = psutil.disk_usage('/')
            
            return {
                "status": "healthy",
                "cpu_usage_percent": cpu_percent,
                "memory_usage_percent": memory.percent,
                "memory_available_gb": round(memory.available / (1024**3), 2),
                "disk_usage_percent": disk.percent,
                "disk_free_gb": round(disk.free / (1024**3), 2),
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e),
                "timestamp": datetime.now().isoformat()
            }
    
    def get_application_info(self) -> dict:
        """Get application runtime information"""
        uptime = datetime.now() - self.start_time
        
        return {
            "app_name": settings.app_name,
            "app_version": settings.app_version,
            "uptime_seconds": int(uptime.total_seconds()),
            "start_time": self.start_time.isoformat(),
            "debug_mode": settings.debug,
            "timestamp": datetime.now().isoformat()
        }

# Initialize health checker
health_checker = HealthChecker(connection_manager)

# Add health check endpoints to FastAPI app
@app.get("/health")
async def health_check():
    """Basic health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/health/detailed")
async def detailed_health_check():
    """Detailed health check with database and system metrics"""
    database_health = await asyncio.get_event_loop().run_in_executor(
        None, health_checker.check_database_health
    )
    system_health = health_checker.check_system_resources()
    app_info = health_checker.get_application_info()
    
    overall_status = "healthy"
    if (database_health["status"] == "unhealthy" or 
        system_health["status"] == "unhealthy"):
        overall_status = "unhealthy"
    
    return {
        "status": overall_status,
        "database": database_health,
        "system": system_health,
        "application": app_info,
        "timestamp": datetime.now().isoformat()
    }

@app.get("/metrics")
async def get_metrics(current_user: Dict = Depends(auth_service.get_current_user)):
    """Get application metrics (requires authentication)"""
    current_user_id = current_user['user']['userId']
    
    # Check permissions
    if not auth_service.check_permission(current_user_id, "Analytics", "READ"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Insufficient permissions to view metrics"
        )
    
    # Get database metrics
    db_metrics_query = """
    MATCH (u:User) 
    WITH count(u) AS total_users
    MATCH (u:User {status: 'Active'}) 
    WITH total_users, count(u) AS active_users
    MATCH ()-[r:FOLLOWS]->() 
    WITH total_users, active_users, count(r) AS total_relationships
    MATCH (t:Tenant) 
    RETURN total_users, active_users, total_relationships, count(t) AS total_tenants
    """
    
    db_metrics = connection_manager.execute_read(db_metrics_query)
    metrics_data = db_metrics[0] if db_metrics else {}
    
    return {
        "database_metrics": metrics_data,
        "system_metrics": health_checker.check_system_resources(),
        "application_info": health_checker.get_application_info(),
        "timestamp": datetime.now().isoformat()
    }

print("✅ Health check and monitoring endpoints configured")
        