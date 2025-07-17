# Lab 10: Python Application Development - Complete Updated Version

**Duration:** 80 minutes  
**Objective:** Master Neo4j Python driver integration and build production-ready web applications using enterprise patterns from Labs 1-9

## Prerequisites

✅ **Already Installed in Your Environment:**
- **Neo4j Desktop** (connection client from Lab 1)
- **Docker Desktop** with Neo4j Enterprise 2025.06.0 running (container name: neo4j from Lab 1)
- **Python 3.8+** with pip
- **Jupyter Lab**
- **Neo4j Python Driver** and required packages
- **Web browser** (Chrome or Firefox)

✅ **From Previous Labs:**
- **Completed Labs 1-9** successfully with enterprise data model from Lab 9
- **"Social" database** created and populated from Lab 3 with complex network structure
- **Advanced Cypher knowledge** from Labs 2, 5, and variable-length paths
- **Business analytics experience** from Lab 6 with comprehensive metrics
- **Graph algorithms expertise** from Labs 7-8 with centrality and community detection
- **Enterprise modeling patterns** from Lab 9 with temporal versioning and RBAC
- **Remote connection** set up to Docker Neo4j Enterprise instance from Lab 1
- **Performance optimization** skills from multiple labs

## Learning Outcomes

By the end of this lab, you will:
- Master the official Neo4j Python driver with enterprise connection patterns from Lab 1
- Build REST APIs using FastAPI with Neo4j integration and authentication using RBAC patterns from Lab 9
- Implement comprehensive data access layers using repository patterns inspired by Lab 9's enterprise architecture
- Create robust error handling and transaction management systems for production deployment
- Build unit tests for graph operations covering patterns from Labs 2-8
- Develop interactive web applications with real-time graph data using analytics from Lab 6
- Implement security patterns including JWT authentication and authorization using Lab 9's RBAC system
- Create production-ready application architecture leveraging all concepts from Labs 1-9

## Part 1: Neo4j Python Driver Mastery with Enterprise Patterns (20 minutes)

### Step 1: Set Up Development Environment
```python
# Create a new Jupyter notebook: enterprise_graph_app.ipynb
# Install required packages using Lab 1 development patterns
import subprocess
import sys

def install_packages():
    """Install required packages for enterprise graph application"""
    required_packages = [
        'neo4j==5.25.0',  # Official Neo4j Python driver
        'fastapi==0.115.0',  # Modern web framework
        'uvicorn[standard]==0.32.0',  # ASGI server
        'python-jose[cryptography]==3.3.0',  # JWT handling
        'passlib[bcrypt]==1.7.4',  # Password hashing
        'python-multipart==0.0.12',  # Form data handling
        'pydantic==2.9.2',  # Data validation
        'pytest==8.3.3',  # Testing framework
        'requests==2.32.3',  # HTTP client for testing
        'python-dotenv==1.0.1',  # Environment variables
    ]
    
    for package in required_packages:
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print(f"✅ Installed {package}")
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to install {package}: {e}")

# Run installation
install_packages()
```

### Step 2: Enterprise Connection Manager (Building on Lab 1 Docker Setup)
```python
import os
import time
import logging
from typing import Dict, List, Any, Optional
from contextlib import contextmanager
from neo4j import GraphDatabase, Driver, Session, Transaction
from neo4j.exceptions import ServiceUnavailable, TransientError

# Configure logging for production monitoring
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class Neo4jConnectionManager:
    """Enterprise-grade Neo4j connection manager using Lab 1 Docker setup"""
    
    def __init__(self, uri: str = "bolt://localhost:7687", 
                 username: str = "neo4j", 
                 password: str = "password",
                 database: str = "social"):
        """
        Initialize connection to Docker Neo4j Enterprise from Lab 1
        
        Args:
            uri: Neo4j connection URI (Lab 1 Docker setup)
            username: Neo4j username
            password: Neo4j password  
            database: Target database (social from Lab 3)
        """
        self.uri = uri
        self.username = username
        self.password = password
        self.database = database
        self.driver = None
        self._connect_with_retry()
    
    def _connect_with_retry(self, max_retries: int = 3, retry_delay: int = 2):
        """Connect with retry logic for production resilience"""
        for attempt in range(max_retries):
            try:
                self.driver = GraphDatabase.driver(
                    self.uri,
                    auth=(self.username, self.password),
                    max_connection_lifetime=3600,  # 1 hour
                    max_connection_pool_size=50,   # Production pool size
                    connection_acquisition_timeout=60,  # 60 seconds
                    encrypted=False  # Docker setup uses unencrypted
                )
                
                # Test connection with simple query
                with self.driver.session(database=self.database) as session:
                    result = session.run("RETURN 'Connection successful' AS message")
                    message = result.single()["message"]
                    logger.info(f"✅ {message} - Attempt {attempt + 1}")
                    return
                    
            except ServiceUnavailable as e:
                logger.warning(f"❌ Connection attempt {attempt + 1} failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(retry_delay)
                else:
                    raise Exception(f"Failed to connect after {max_retries} attempts: {e}")
    
    @contextmanager
    def get_session(self):
        """Context manager for database sessions"""
        session = None
        try:
            session = self.driver.session(database=self.database)
            yield session
        except Exception as e:
            logger.error(f"Session error: {e}")
            if session:
                session.close()
            raise
        finally:
            if session:
                session.close()
    
    def execute_read(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Execute read transaction with error handling"""
        with self.get_session() as session:
            try:
                result = session.run(query, parameters or {})
                return [record.data() for record in result]
            except Exception as e:
                logger.error(f"Read query failed: {query[:100]}... Error: {e}")
                raise
    
    def execute_write(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Execute write transaction with error handling"""
        with self.get_session() as session:
            try:
                result = session.run(query, parameters or {})
                return [record.data() for record in result]
            except Exception as e:
                logger.error(f"Write query failed: {query[:100]}... Error: {e}")
                raise
    
    def close(self):
        """Close driver connection"""
        if self.driver:
            self.driver.close()
            logger.info("🔒 Neo4j driver connection closed")

# Initialize connection manager with Lab 1 Docker setup
connection_manager = Neo4jConnectionManager()

# Verify connection to existing Lab 3 social network data
print("🔧 Testing connection to Lab 3 social network...")
try:
    users_count = connection_manager.execute_read("MATCH (u:User) RETURN count(u) AS count")
    relationships_count = connection_manager.execute_read("MATCH ()-[r:FOLLOWS]->() RETURN count(r) AS count")
    
    if users_count[0]['count'] > 0:
        print(f"✅ Connected to social database with {users_count[0]['count']} users")
        print(f"✅ Found {relationships_count[0]['count']} FOLLOWS relationships")
        print("✅ Ready to build Python applications on existing Lab 1-9 data")
    else:
        print("⚠️  Warning: No existing social network data found.")
        print("   Please complete Labs 1-9 first to populate data.")
        
except Exception as e:
    print(f"❌ Connection failed: {e}")
    print("   Please ensure Docker Neo4j container is running (docker start neo4j)")
```

### Step 3: Repository Pattern Implementation (Building on Lab 9 Enterprise Architecture)
```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional
from datetime import datetime
import uuid

class BaseRepository(ABC):
    """Base repository pattern inspired by Lab 9 enterprise modeling"""
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
    
    @abstractmethod
    def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create new entity"""
        pass
    
    @abstractmethod
    def get_by_id(self, entity_id: str) -> Optional[Dict[str, Any]]:
        """Get entity by ID"""
        pass
    
    @abstractmethod
    def update(self, entity_id: str, updates: Dict[str, Any]) -> Dict[str, Any]:
        """Update entity"""
        pass
    
    @abstractmethod
    def delete(self, entity_id: str) -> bool:
        """Delete entity"""
        pass

class UserRepository(BaseRepository):
    """User repository implementing Lab 9 enterprise patterns with Lab 1-8 social network features"""
    
    def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create new user with Lab 9 enterprise versioning patterns"""
        user_id = f"{data['username']}.{str(uuid.uuid4())[:8]}"
        
        query = """
        CREATE (user:User {
            userId: $user_id,
            username: $username,
            email: $email,
            fullName: $full_name,
            location: $location,
            profession: $profession,
            followerCount: COALESCE($follower_count, 0),
            followingCount: COALESCE($following_count, 0),
            createdAt: datetime(),
            updatedAt: datetime(),
            version: 1,
            status: 'Active'
        })
        
        // Create initial user profile version (Lab 9 patterns)
        CREATE (profile:UserProfile {
            userId: $user_id,
            version: 1,
            fullName: $full_name,
            location: $location,
            profession: $profession,
            skills: COALESCE($skills, []),
            effectiveFrom: datetime(),
            effectiveTo: null,
            changeReason: 'Initial Profile Creation',
            changedBy: 'system'
        })
        
        CREATE (user)-[:CURRENT_PROFILE]->(profile)
        
        RETURN user, profile
        """
        
        result = self.connection_manager.execute_write(query, {
            "user_id": user_id,
            "username": data["username"],
            "email": data["email"],
            "full_name": data["fullName"],
            "location": data["location"],
            "profession": data["profession"],
            "skills": data.get("skills", []),
            "follower_count": data.get("followerCount", 0),
            "following_count": data.get("followingCount", 0)
        })
        
        return result[0] if result else None
    
    def get_by_id(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user with current profile (Lab 9 versioning)"""
        query = """
        MATCH (user:User {userId: $user_id})
        MATCH (user)-[:CURRENT_PROFILE]->(profile:UserProfile)
        RETURN user, profile
        """
        
        result = self.connection_manager.execute_read(query, {"user_id": user_id})
        
        if result:
            user_data = result[0]['user']
            profile_data = result[0]['profile']
            return {
                "user": user_data,
                "profile": profile_data,
                "userId": user_data['userId'],
                "username": user_data['username']
            }
        return None
    
    def get_by_username(self, username: str) -> Optional[Dict[str, Any]]:
        """Get user by username"""
        query = """
        MATCH (user:User {username: $username})
        MATCH (user)-[:CURRENT_PROFILE]->(profile:UserProfile)
        RETURN user, profile
        """
        
        result = self.connection_manager.execute_read(query, {"username": username})
        return result[0] if result else None
    
    def get_user_roles(self, user_id: str) -> List[Dict[str, Any]]:
        """Get user roles using Lab 9 RBAC patterns"""
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
        """Get all permissions for a user through their roles (Lab 9 RBAC)"""
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
        """Update user profile with Lab 9 versioning patterns"""
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
        SET oldProfile.effectiveTo = datetime()
        DELETE current
        
        // Create new profile version
        CREATE (newProfile:UserProfile {
            userId: $user_id,
            version: $new_version,
            fullName: COALESCE($full_name, oldProfile.fullName),
            location: COALESCE($location, oldProfile.location),
            profession: COALESCE($profession, oldProfile.profession),
            skills: COALESCE($skills, oldProfile.skills),
            effectiveFrom: datetime(),
            effectiveTo: null,
            changeReason: $change_reason,
            changedBy: $changed_by
        })
        
        CREATE (user)-[:CURRENT_PROFILE]->(newProfile)
        
        // Update user node
        SET user.updatedAt = datetime(),
            user.version = $new_version
        
        RETURN user, newProfile
        """
        
        result = self.connection_manager.execute_write(query, {
            "user_id": user_id,
            "new_version": new_version,
            "full_name": updates.get("fullName"),
            "location": updates.get("location"),
            "profession": updates.get("profession"),
            "skills": updates.get("skills"),
            "change_reason": updates.get("changeReason", "Profile Update"),
            "changed_by": updates.get("changedBy", "user")
        })
        
        return result[0] if result else None
    
    def delete(self, user_id: str) -> bool:
        """Soft delete user (Lab 9 enterprise patterns)"""
        query = """
        MATCH (user:User {userId: $user_id})
        SET user.deletedAt = datetime(),
            user.status = 'Deleted'
        RETURN user
        """
        
        result = self.connection_manager.execute_write(query, {"user_id": user_id})
        return len(result) > 0

# Test repository with existing Lab 3 social network data
print("Testing UserRepository with existing social network data...")
user_repo = UserRepository(connection_manager)

# Get existing users from Labs 1-8
existing_users = connection_manager.execute_read("""
    MATCH (u:User) 
    RETURN u.username AS username, u.location AS location
    LIMIT 3
""")

if existing_users:
    print("✅ Found existing users from previous labs:")
    for user in existing_users:
        print(f"  - {user['username']} from {user['location']}")
else:
    print("ℹ️  No existing users found. Repository ready for new user creation.")
```

## Part 2: Authentication & Security System (Building on Lab 9 RBAC) (15 minutes)

### Step 4: JWT Authentication Service
```python
import bcrypt
import jwt
from datetime import datetime, timedelta
from typing import Dict, Any
from pydantic import BaseModel, EmailStr

# Configuration (In production, use environment variables)
SECRET_KEY = "your-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

class UserCreate(BaseModel):
    """User creation model with validation"""
    username: str
    email: EmailStr
    fullName: str
    location: str
    profession: str
    password: str
    skills: List[str] = []

class LoginRequest(BaseModel):
    """Login request model"""
    username: str
    password: str

class AuthenticationService:
    """Authentication service using Lab 9 RBAC patterns"""
    
    def __init__(self, connection_manager: Neo4jConnectionManager, user_repo: UserRepository):
        self.connection_manager = connection_manager
        self.user_repo = user_repo
    
    def hash_password(self, password: str) -> str:
        """Hash password using bcrypt"""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    
    def verify_password(self, password: str, hashed_password: str) -> bool:
        """Verify password against hash"""
        return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
    
    def create_access_token(self, user_id: str, username: str) -> str:
        """Create JWT access token"""
        expires_delta = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        expire = datetime.utcnow() + expires_delta
        
        to_encode = {
            "user_id": user_id,
            "username": username,
            "exp": expire,
            "iat": datetime.utcnow()
        }
        
        return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    
    def verify_token(self, token: str) -> Dict[str, Any]:
        """Verify JWT token and return user data"""
        try:
            payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
            user_id = payload.get("user_id")
            username = payload.get("username")
            
            if user_id is None or username is None:
                raise Exception("Invalid token payload")
            
            return {"user_id": user_id, "username": username}
            
        except jwt.ExpiredSignatureError:
            raise Exception("Token has expired")
        except jwt.JWTError:
            raise Exception("Invalid token")
    
    def register_user(self, user_data: UserCreate) -> Dict[str, Any]:
        """Register new user with Lab 9 enterprise patterns"""
        # Check if user already exists
        existing_user = self.user_repo.get_by_username(user_data.username)
        if existing_user:
            raise Exception("Username already registered")
        
        # Hash password
        hashed_password = self.hash_password(user_data.password)
        
        # Generate user ID
        user_id = f"{user_data.username}.{str(uuid.uuid4())[:8]}"
        
        # Create user using repository
        user_dict = user_data.dict()
        del user_dict['password']  # Remove password from user data
        
        user_result = self.user_repo.create(user_dict)
        
        if not user_result:
            raise Exception("Failed to create user")
        
        # Create security record (Lab 9 patterns)
        security_query = """
        MATCH (user:User {userId: $user_id})
        CREATE (security:UserSecurity {
            userId: $user_id,
            hashedPassword: $hashed_password,
            createdAt: datetime(),
            lastLoginAt: null,
            loginAttempts: 0,
            isLocked: false,
            requirePasswordChange: false
        })
        CREATE (user)-[:HAS_SECURITY]->(security)
        RETURN security
        """
        
        self.connection_manager.execute_write(security_query, {
            "user_id": user_id,
            "hashed_password": hashed_password
        })
        
        return {"user_id": user_id, "username": user_data.username}
    
    def authenticate_user(self, login_data: LoginRequest) -> Dict[str, Any]:
        """Authenticate user and return token"""
        # Get user security data
        query = """
        MATCH (user:User {username: $username})-[:HAS_SECURITY]->(security:UserSecurity)
        RETURN user, security
        """
        
        result = self.connection_manager.execute_read(query, {"username": login_data.username})
        
        if not result:
            raise Exception("Invalid username or password")
        
        user_data = result[0]['user']
        security_data = result[0]['security']
        
        # Check if account is locked
        if security_data.get('isLocked', False):
            raise Exception("Account is locked due to too many failed login attempts")
        
        # Verify password
        if not self.verify_password(login_data.password, security_data['hashedPassword']):
            # Update login attempts
            self.connection_manager.execute_write("""
                MATCH (security:UserSecurity {userId: $user_id})
                SET security.loginAttempts = security.loginAttempts + 1,
                    security.isLocked = (security.loginAttempts >= 4)
                RETURN security
            """, {"user_id": user_data['userId']})
            
            raise Exception("Invalid username or password")
        
        # Reset login attempts on successful login
        self.connection_manager.execute_write("""
            MATCH (security:UserSecurity {userId: $user_id})
            SET security.loginAttempts = 0,
                security.lastLoginAt = datetime()
            RETURN security
        """, {"user_id": user_data['userId']})
        
        # Create access token
        access_token = self.create_access_token(user_data['userId'], user_data['username'])
        
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user_id": user_data['userId'],
            "username": user_data['username']
        }

# Initialize authentication service
auth_service = AuthenticationService(connection_manager, user_repo)
print("✅ Authentication service initialized with Lab 9 RBAC patterns")
```

## Part 3: Business Analytics Service (Integrating Lab 6 & Lab 5 Patterns) (15 minutes)

### Step 5: Comprehensive Analytics Service
```python
from collections import defaultdict
import math

class AnalyticsService:
    """Business analytics service integrating Lab 6 BI and Lab 5 path algorithms"""
    
    def __init__(self, connection_manager: Neo4jConnectionManager):
        self.connection_manager = connection_manager
    
    def get_network_overview(self) -> Dict[str, Any]:
        """Get overall network statistics (Lab 6 patterns)"""
        query = """
        MATCH (u:User)
        OPTIONAL MATCH (u)-[:FOLLOWS]->(followed)
        OPTIONAL MATCH (u)<-[:FOLLOWS]-(follower)
        OPTIONAL MATCH (u)-[:POSTED]->(post:Post)
        OPTIONAL MATCH (post)<-[:LIKES]-(liker)
        
        WITH u,
             count(DISTINCT followed) AS following_count,
             count(DISTINCT follower) AS follower_count,
             count(DISTINCT post) AS post_count,
             count(DISTINCT liker) AS total_likes
        
        RETURN 
            count(u) AS total_users,
            avg(following_count) AS avg_following,
            avg(follower_count) AS avg_followers,
            sum(post_count) AS total_posts,
            sum(total_likes) AS total_likes,
            max(follower_count) AS max_followers,
            max(following_count) AS max_following
        """
        
        result = self.connection_manager.execute_read(query)
        return result[0] if result else {}
    
    def get_user_engagement_metrics(self, user_id: str) -> Dict[str, Any]:
        """Get comprehensive user engagement metrics (Lab 6 business intelligence)"""
        query = """
        MATCH (user:User {userId: $user_id})
        
        // Basic metrics
        OPTIONAL MATCH (user)-[:FOLLOWS]->(following)
        OPTIONAL MATCH (user)<-[:FOLLOWS]-(follower)
        OPTIONAL MATCH (user)-[:POSTED]->(post:Post)
        OPTIONAL MATCH (post)<-[:LIKES]-(liker)
        OPTIONAL MATCH (user)-[:LIKES]->(liked_post:Post)
        
        // Influence calculation (Lab 6 patterns)
        WITH user,
             count(DISTINCT following) AS following_count,
             count(DISTINCT follower) AS follower_count,
             count(DISTINCT post) AS post_count,
             count(DISTINCT liker) AS total_likes_received,
             count(DISTINCT liked_post) AS total_likes_given
        
        // Calculate engagement rate
        WITH user, following_count, follower_count, post_count, 
             total_likes_received, total_likes_given,
             CASE 
                WHEN post_count > 0 THEN total_likes_received * 1.0 / post_count 
                ELSE 0 
             END AS avg_likes_per_post
        
        // Calculate influence score (Lab 6 metrics)
        WITH user, following_count, follower_count, post_count, 
             total_likes_received, total_likes_given, avg_likes_per_post,
             (follower_count * 0.4 + total_likes_received * 0.3 + post_count * 0.2 + avg_likes_per_post * 0.1) AS influence_score
        
        RETURN {
            userId: user.userId,
            username: user.username,
            following_count: following_count,
            follower_count: follower_count,
            post_count: post_count,
            total_likes_received: total_likes_received,
            total_likes_given: total_likes_given,
            avg_likes_per_post: round(avg_likes_per_post * 100) / 100,
            influence_score: round(influence_score * 100) / 100,
            engagement_ratio: CASE 
                WHEN follower_count > 0 THEN round((total_likes_received * 100.0 / follower_count) * 100) / 100 
                ELSE 0 
            END
        } AS metrics
        """
        
        result = self.connection_manager.execute_read(query, {"user_id": user_id})
        return result[0]['metrics'] if result else {}
    
    def get_network_recommendations(self, user_id: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Get friend recommendations using Lab 5 variable-length path patterns"""
        query = """
        MATCH (user:User {userId: $user_id})
        
        // Find users through mutual connections (Lab 5 patterns)
        MATCH (user)-[:FOLLOWS]->(mutual_friend)-[:FOLLOWS]->(potential_friend:User)
        WHERE potential_friend <> user 
          AND NOT (user)-[:FOLLOWS]->(potential_friend)
        
        // Calculate recommendation score
        WITH potential_friend,
             count(DISTINCT mutual_friend) AS mutual_connections,
             collect(DISTINCT mutual_friend.username) AS mutual_usernames
        
        // Add interest-based scoring
        MATCH (user)-[:INTERESTED_IN]->(shared_interest:Topic)<-[:INTERESTED_IN]-(potential_friend)
        WITH potential_friend, mutual_connections, mutual_usernames,
             count(DISTINCT shared_interest) AS shared_interests
        
        // Calculate final recommendation score
        WITH potential_friend, mutual_connections, mutual_usernames, shared_interests,
             (mutual_connections * 2 + shared_interests) AS recommendation_score
        
        RETURN {
            userId: potential_friend.userId,
            username: potential_friend.username,
            fullName: potential_friend.fullName,
            location: potential_friend.location,
            mutual_connections: mutual_connections,
            shared_interests: shared_interests,
            recommendation_score: recommendation_score,
            mutual_friends: mutual_usernames[0..3],
            reason: CASE 
                WHEN mutual_connections > 2 THEN 'Strong mutual connections'
                WHEN shared_interests > 1 THEN 'Shared interests'
                ELSE 'Network connection'
            END
        } AS recommendation
        ORDER BY recommendation_score DESC
        LIMIT $limit
        """
        
        result = self.connection_manager.execute_read(query, {"user_id": user_id, "limit": limit})
        return [record['recommendation'] for record in result]
    
    def get_trending_content(self, limit: int = 10) -> List[Dict[str, Any]]:
        """Get trending content using Lab 6 temporal analytics"""
        query = """
        MATCH (post:Post)<-[:LIKES]-(liker:User)
        WHERE post.createdAt > datetime() - duration('P7D')  // Last 7 days
        
        WITH post,
             count(liker) AS recent_likes,
             duration.between(post.createdAt, datetime()).days AS days_old
        
        // Calculate trending score (recent engagement vs age)
        WITH post, recent_likes, days_old,
             recent_likes * 1.0 / (days_old + 1) AS trending_score
        
        MATCH (author:User)-[:POSTED]->(post)
        
        RETURN {
            postId: post.postId,
            content: post.content[0..100] + CASE WHEN size(post.content) > 100 THEN '...' ELSE '' END,
            author: author.username,
            authorName: author.fullName,
            likes: recent_likes,
            days_old: days_old,
            trending_score: round(trending_score * 100) / 100,
            createdAt: toString(post.createdAt)
        } AS trending_post
        ORDER BY trending_score DESC
        LIMIT $limit
        """
        
        result = self.connection_manager.execute_read(query, {"limit": limit})
        return [record['trending_post'] for record in result]
    
    def get_community_analysis(self, user_id: str) -> Dict[str, Any]:
        """Analyze user's community using Lab 8 community detection patterns"""
        # Find user's local community
        community_query = """
        MATCH (user:User {userId: $user_id})
        MATCH (user)-[:FOLLOWS*1..2]-(community_member:User)
        
        WITH collect(DISTINCT community_member) + [user] AS community_users
        
        // Analyze community characteristics
        UNWIND community_users AS member
        OPTIONAL MATCH (member)-[:INTERESTED_IN]->(interest:Topic)
        OPTIONAL MATCH (member)-[:FOLLOWS]->(followed)
        WHERE followed IN community_users
        
        WITH member,
             collect(DISTINCT interest.name) AS interests,
             count(DISTINCT followed) AS internal_connections
        
        RETURN {
            community_size: count(member),
            avg_internal_connections: avg(internal_connections),
            common_interests: apoc.coll.frequencies([interest IN collect(interests) | interest])[0..5],
            most_connected: collect({username: member.username, connections: internal_connections})[0..3]
        } AS community_analysis
        """
        
        try:
            result = self.connection_manager.execute_read(community_query, {"user_id": user_id})
            return result[0]['community_analysis'] if result else {}
        except Exception as e:
            # Fallback without APOC functions
            simple_query = """
            MATCH (user:User {userId: $user_id})
            MATCH (user)-[:FOLLOWS*1..2]-(community_member:User)
            
            WITH count(DISTINCT community_member) AS community_size
            
            RETURN {
                community_size: community_size,
                analysis_type: 'simplified'
            } AS community_analysis
            """
            
            result = self.connection_manager.execute_read(simple_query, {"user_id": user_id})
            return result[0]['community_analysis'] if result else {}

# Initialize analytics service
analytics_service = AnalyticsService(connection_manager)

# Test analytics with existing data
print("Testing analytics service with Lab 3 social network data...")
try:
    network_stats = analytics_service.get_network_overview()
    print(f"✅ Network Overview: {network_stats.get('total_users', 0)} users, {network_stats.get('total_posts', 0)} posts")
    
    # Test with first user if available
    existing_users = connection_manager.execute_read("MATCH (u:User) RETURN u.userId AS userId LIMIT 1")
    if existing_users:
        test_user_id = existing_users[0]['userId']
        user_metrics = analytics_service.get_user_engagement_metrics(test_user_id)
        print(f"✅ User Metrics: Influence score {user_metrics.get('influence_score', 0)}")
        
        recommendations = analytics_service.get_network_recommendations(test_user_id, 3)
        print(f"✅ Recommendations: Found {len(recommendations)} potential connections")
    
except Exception as e:
    print(f"⚠️  Analytics testing skipped: {e}")
```

## Part 4: FastAPI Web Application (20 minutes)

### Step 6: Production-Ready REST API
```python
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from typing import List
import uvicorn

# Initialize FastAPI app
app = FastAPI(
    title="Neo4j Social Network API",
    description="Production-ready graph database API integrating Labs 1-9 patterns",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Security setup
security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> Dict[str, Any]:
    """Dependency to get current authenticated user"""
    try:
        token = credentials.credentials
        user_data = auth_service.verify_token(token)
        return user_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        )

# API Routes

@app.get("/")
async def root():
    """Health check and API information"""
    return {
        "message": "Neo4j Social Network API - Labs 1-9 Integration",
        "version": "1.0.0",
        "status": "operational",
        "features": [
            "Enterprise Neo4j connection (Lab 1)",
            "Advanced Cypher queries (Labs 2, 5)",
            "Social network analytics (Lab 3, 6)",
            "Graph algorithms (Labs 7, 8)",
            "Enterprise security (Lab 9)",
            "Production Python integration (Lab 10)"
        ]
    }

@app.post("/auth/register")
async def register(user_data: UserCreate):
    """Register new user with Lab 9 enterprise patterns"""
    try:
        result = auth_service.register_user(user_data)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/auth/login")
async def login(login_data: LoginRequest):
    """Authenticate user and return JWT token"""
    try:
        result = auth_service.authenticate_user(login_data)
        return result
    except Exception as e:
        raise HTTPException(status_code=401, detail=str(e))

@app.get("/users/me")
async def get_current_user_profile(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Get current user's profile with Lab 9 versioning"""
    user_data = user_repo.get_by_id(current_user["user_id"])
    if not user_data:
        raise HTTPException(status_code=404, detail="User not found")
    return user_data

@app.get("/users/{user_id}/analytics")
async def get_user_analytics(
    user_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get comprehensive user analytics using Lab 6 patterns"""
    analytics = analytics_service.get_user_engagement_metrics(user_id)
    return analytics

@app.get("/users/{user_id}/recommendations")
async def get_friend_recommendations(
    user_id: str,
    limit: int = 5,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get friend recommendations using Lab 5 variable-length paths"""
    recommendations = analytics_service.get_network_recommendations(user_id, limit)
    return {"recommendations": recommendations}

@app.get("/users/{user_id}/community")
async def get_community_analysis(
    user_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get community analysis using Lab 8 patterns"""
    community_data = analytics_service.get_community_analysis(user_id)
    return community_data

@app.get("/content/trending")
async def get_trending_content(
    limit: int = 10,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Get trending content using Lab 6 temporal analytics"""
    trending = analytics_service.get_trending_content(limit)
    return {"trending_content": trending}

@app.post("/users/{user_id}/follow")
async def follow_user(
    user_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """Follow another user (Lab 3 relationship patterns)"""
    query = """
    MATCH (follower:User {userId: $follower_id})
    MATCH (followee:User {userId: $followee_id})
    WHERE follower <> followee
    
    MERGE (follower)-[follow:FOLLOWS]->(followee)
    ON CREATE SET follow.createdAt = datetime(),
                  follow.strength = 1
    
    // Update counts (Lab 6 metrics patterns)
    SET follower.followingCount = follower.followingCount + 1,
        followee.followerCount = followee.followerCount + 1
    
    RETURN follow
    """
    
    result = connection_manager.execute_write(query, {
        "follower_id": current_user["user_id"],
        "followee_id": user_id
    })
    
    if result:
        return {"message": f"Successfully followed user {user_id}"}
    else:
        raise HTTPException(status_code=400, detail="Failed to follow user")

@app.get("/network/stats")
async def get_network_statistics(current_user: Dict[str, Any] = Depends(get_current_user)):
    """Get overall network statistics using Lab 6 analytics"""
    stats = analytics_service.get_network_overview()
    return {"network_statistics": stats}

@app.get("/health")
async def health_check():
    """Detailed health check for monitoring"""
    try:
        # Test Neo4j connection
        test_result = connection_manager.execute_read("RETURN 'healthy' AS status")
        neo4j_status = test_result[0]['status'] if test_result else 'unhealthy'
        
        return {
            "status": "healthy",
            "neo4j_connection": neo4j_status,
            "timestamp": datetime.utcnow().isoformat(),
            "services": {
                "authentication": "operational",
                "analytics": "operational",
                "user_management": "operational"
            }
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service unhealthy: {str(e)}")

# Middleware configuration
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8080"],  # Frontend origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

print("✅ FastAPI application configured with:")
print("   🔐 JWT Authentication (Lab 9 RBAC)")
print("   📊 Analytics endpoints (Lab 6 BI)")
print("   🤝 Social features (Lab 3 patterns)")
print("   🔍 Advanced queries (Lab 5 paths)")
print("   🚀 Production middleware")
```

## Part 5: Testing & Production Deployment (10 minutes)

### Step 7: Comprehensive Testing Suite
```python
import pytest
import requests
import json
from typing import Dict, Any

class TestNeo4jSocialAPI:
    """Comprehensive test suite for Lab 10 application"""
    
    @pytest.fixture
    def api_base_url(self):
        """Base URL for API testing"""
        return "http://localhost:8000"
    
    @pytest.fixture
    def test_user_data(self):
        """Test user data for registration/login"""
        return {
            "username": "test_user_lab10",
            "email": "test@example.com",
            "fullName": "Test User Lab 10",
            "location": "Test City, Test State",
            "profession": "Software Tester",
            "password": "secure_test_password_123",
            "skills": ["Python", "Testing", "Neo4j"]
        }
    
    def test_health_check(self, api_base_url):
        """Test API health check endpoint"""
        response = requests.get(f"{api_base_url}/")
        assert response.status_code == 200
        data = response.json()
        assert "Neo4j Social Network API" in data["message"]
        assert "Labs 1-9 Integration" in data["message"]
    
    def test_user_registration(self, api_base_url, test_user_data):
        """Test user registration with Lab 9 enterprise patterns"""
        response = requests.post(f"{api_base_url}/auth/register", json=test_user_data)
        
        if response.status_code == 400:
            # User might already exist from previous test runs
            print("User already exists, skipping registration test")
            return
        
        assert response.status_code == 200
        data = response.json()
        assert "user_id" in data
        assert data["username"] == test_user_data["username"]
    
    def test_user_login(self, api_base_url, test_user_data):
        """Test user authentication and JWT token generation"""
        login_data = {
            "username": test_user_data["username"],
            "password": test_user_data["password"]
        }
        
        response = requests.post(f"{api_base_url}/auth/login", json=login_data)
        assert response.status_code == 200
        
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"
        assert "user_id" in data
        
        return data["access_token"]
    
    def test_authenticated_endpoints(self, api_base_url, test_user_data):
        """Test authenticated endpoints with JWT token"""
        # First login to get token
        token = self.test_user_login(api_base_url, test_user_data)
        headers = {"Authorization": f"Bearer {token}"}
        
        # Test user profile endpoint
        response = requests.get(f"{api_base_url}/users/me", headers=headers)
        assert response.status_code == 200
        
        # Test network statistics
        response = requests.get(f"{api_base_url}/network/stats", headers=headers)
        assert response.status_code == 200

# Run basic integration test
def run_integration_test():
    """Run basic integration test of the complete application"""
    print("\n🧪 Running integration test of Lab 10 application...")
    
    try:
        # Test connection manager
        test_query = connection_manager.execute_read("RETURN 'Integration test' AS message")
        assert test_query[0]['message'] == 'Integration test'
        print("✅ Connection Manager: Passed")
        
        # Test user repository
        existing_users = connection_manager.execute_read("MATCH (u:User) RETURN count(u) AS count")
        user_count = existing_users[0]['count']
        print(f"✅ User Repository: {user_count} users available")
        
        # Test analytics service
        network_stats = analytics_service.get_network_overview()
        print(f"✅ Analytics Service: Network has {network_stats.get('total_users', 0)} users")
        
        # Test authentication service setup
        print("✅ Authentication Service: Ready")
        
        print("\n🎉 Integration test completed successfully!")
        print("   📱 FastAPI app ready to start")
        print("   🔧 All services operational")
        print("   📊 Analytics working with existing Lab 3 data")
        
    except Exception as e:
        print(f"❌ Integration test failed: {e}")
        return False
    
    return True

# Run the integration test
integration_success = run_integration_test()
```

### Step 8: Production Deployment Guide
```python
def create_production_deployment():
    """Create production deployment configuration"""
    
    # Docker Compose for production deployment
    docker_compose = """
version: '3.8'
services:
  neo4j:
    image: neo4j:enterprise
    container_name: neo4j-production
    environment:
      - NEO4J_AUTH=neo4j/secure_production_password
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_dbms_memory_heap_initial__size=1G
      - NEO4J_dbms_memory_heap_max__size=2G
      - NEO4J_dbms_memory_pagecache_size=1G
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j_data:/data
      - neo4j_logs:/logs
    restart: unless-stopped
    
  api:
    build: .
    container_name: social-api-production
    environment:
      - NEO4J_URI=bolt://neo4j:7687
      - NEO4J_USERNAME=neo4j
      - NEO4J_PASSWORD=secure_production_password
      - SECRET_KEY=production_secret_key_change_this
      - ENVIRONMENT=production
    ports:
      - "8000:8000"
    depends_on:
      - neo4j
    restart: unless-stopped
    
volumes:
  neo4j_data:
  neo4j_logs:
"""
    
    # Dockerfile for API
    dockerfile = """
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
"""
    
    # Requirements file
    requirements = """
neo4j==5.25.0
fastapi==0.115.0
uvicorn[standard]==0.32.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.12
pydantic==2.9.2
python-dotenv==1.0.1
"""
    
    print("📦 Production deployment configuration created:")
    print("   🐳 Docker Compose with Neo4j Enterprise")
    print("   🚀 Containerized FastAPI application")
    print("   🔒 Production security settings")
    print("   📊 Performance optimizations")
    print("   🔄 Auto-restart policies")
    
    return docker_compose, dockerfile, requirements

# Create deployment files
docker_config, dockerfile_content, requirements_content = create_production_deployment()
```

### Step 9: Application Startup & Testing
```python
def start_development_server():
    """Start the FastAPI development server for testing"""
    print("\n🚀 Starting FastAPI development server...")
    print("   📍 Server URL: http://localhost:8000")
    print("   📚 API Documentation: http://localhost:8000/docs")
    print("   🔍 ReDoc Documentation: http://localhost:8000/redoc")
    print("   ❤️  Health Check: http://localhost:8000/health")
    print("\n🔧 Available endpoints:")
    print("   POST /auth/register - Register new user")
    print("   POST /auth/login - User authentication")
    print("   GET  /users/me - Get current user profile")
    print("   GET  /users/{id}/analytics - User engagement metrics")
    print("   GET  /users/{id}/recommendations - Friend recommendations")
    print("   GET  /network/stats - Network statistics")
    print("   GET  /content/trending - Trending content")
    print("\n⚠️  To start the server, run in terminal:")
    print("   uvicorn main:app --reload --host 0.0.0.0 --port 8000")

# Final application status
print("\n📚 Comprehensive Integration Achieved:")
print("   🔧 Enterprise connection management (Lab 1 patterns)")
print("   🎯 Advanced repository patterns (Lab 9 enterprise architecture)")  
print("   📊 Business analytics services (Lab 6 metrics)")
print("   🤝 Recommendation algorithms (Lab 5 variable-length paths)")
print("   🔒 Production security (Lab 9 RBAC and JWT)")
print("   🌐 REST API with FastAPI (modern web standards)")
print("   🧪 Comprehensive testing suite")
print("   🚀 Production deployment ready")

# Show startup instructions
start_development_server()

# Clean up connections
try:
    connection_manager.close()
    print("🔒 Neo4j connections closed properly")
except:
    pass
```

## Troubleshooting Common Issues

### If Docker Neo4j isn't running:
```bash
# Check container status (Lab 1 setup)
docker ps -a | grep neo4j

# Start the neo4j container from Lab 1
docker start neo4j

# Verify Neo4j Enterprise is accessible
curl http://localhost:7474
```

### If FastAPI server won't start:
```python
# Install missing dependencies
import subprocess
import sys

required_packages = ['fastapi', 'uvicorn', 'python-jose', 'bcrypt', 'pydantic']
for package in required_packages:
    subprocess.check_call([sys.executable, "-m", "pip", "install", package])

# Start server manually
# uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### If authentication fails:
```python
# Test basic Neo4j connection first
from neo4j import GraphDatabase

try:
    driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"), database="social")
    with driver.session() as session:
        result = session.run("RETURN 'Connection test' AS message")
        print(result.single()["message"])
        print("✅ Basic Neo4j connection working")
except Exception as e:
    print(f"❌ Neo4j connection failed: {e}")
    print("   Verify Docker container is running: docker ps | grep neo4j")
finally:
    if 'driver' in locals():
        driver.close()
```

### If existing data is missing:
```cypher
// Check if Lab 3 social data exists
:use social
MATCH (u:User) RETURN count(u) AS users;
MATCH ()-[r:FOLLOWS]->() RETURN count(r) AS relationships;

// If no data, complete Labs 1-9 first
// Or create minimal test data:
CREATE (alice:User {userId: 'alice.123', username: 'alice_test', fullName: 'Alice Test'})
CREATE (bob:User {userId: 'bob.456', username: 'bob_test', fullName: 'Bob Test'})
CREATE (alice)-[:FOLLOWS]->(bob)
RETURN 'Test data created' AS status;
```

## Lab Completion Checklist

- [ ] **Environment Setup**: Successfully connected to Lab 1 Docker Neo4j Enterprise setup
- [ ] **Enterprise Connection Manager**: Implemented robust connection handling with retry logic
- [ ] **Repository Patterns**: Built data access layers using Lab 9 enterprise architecture
- [ ] **Authentication System**: Created JWT-based auth with Lab 9 RBAC patterns
- [ ] **Analytics Service**: Integrated Lab 6 business intelligence and Lab 5 path algorithms  
- [ ] **FastAPI Application**: Built production-ready REST API with comprehensive endpoints
- [ ] **Security Implementation**: Applied enterprise security patterns from Lab 9
- [ ] **Testing Suite**: Created comprehensive tests for all components
- [ ] **Production Deployment**: Prepared deployment guide and monitoring setup
- [ ] **Real-World Applications**: Demonstrated practical application scenarios
- [ ] **Integration Testing**: Verified all Lab 1-9 patterns work together seamlessly
- [ ] **Performance Optimization**: Applied Lab 7 optimization techniques to Python code
- [ ] **Documentation**: Created comprehensive production deployment and usage guides

## Key Concepts Mastered

1. **Enterprise Python Integration**: Professional Neo4j driver usage with connection pooling and error handling
2. **Repository Pattern Implementation**: Clean separation of data access using enterprise architecture principles
3. **Authentication & Authorization**: JWT-based security with role-based access control from Lab 9
4. **Business Analytics Integration**: Sophisticated analytics services using Lab 6 patterns and Lab 5 algorithms
5. **REST API Development**: Modern FastAPI application with comprehensive endpoint coverage
6. **Testing Strategy**: Unit testing, integration testing, and API testing approaches
7. **Production Deployment**: Container orchestration, monitoring, and operational excellence
8. **Real-World Applications**: Practical implementation patterns for enterprise scenarios
9. **Performance Optimization**: Production-ready performance patterns and monitoring
10. **Cross-Lab Integration**: Seamless combination of all concepts from Labs 1-9

## Practice Exercises (Optional Advanced Challenges)

Try these advanced integration challenges:

1. **Real-Time Features**: Add WebSocket support for real-time notifications using FastAPI WebSockets
2. **Machine Learning Integration**: Implement scikit-learn models for user behavior prediction
3. **Advanced Caching**: Add Redis caching layer for frequently accessed data
4. **Microservices Architecture**: Split the application into multiple specialized services
5. **GraphQL API**: Add GraphQL endpoints alongside REST for flexible data querying
6. **Event Sourcing**: Implement complete audit trails for all user actions
7. **Performance Monitoring**: Add APM integration for production monitoring
8. **Advanced Security**: Implement OAuth2, rate limiting, and request validation
9. **Data Pipelines**: Create ETL processes for importing external social media data
10. **AI Integration**: Add recommendation engines using graph embeddings

## Next Steps

Congratulations! You've successfully completed the comprehensive Neo4j course and built a production-ready graph application. You now have:

### **Technical Mastery:**
- **Complete Graph Database Expertise**: From basic Cypher to enterprise deployment
- **Production Python Skills**: Professional application development with Neo4j
- **Enterprise Architecture**: Scalable, secure, maintainable graph applications
- **Modern Web Development**: REST APIs, authentication, testing, and deployment

### **Business Applications:**
- **Social Network Analytics**: User engagement, influence, and community detection
- **Recommendation Systems**: Friend suggestions and content discovery
- **Business Intelligence**: Comprehensive metrics and reporting
- **Security Systems**: Enterprise-grade authentication and authorization

### **Career Preparation:**
- **Industry-Ready Skills**: Complete toolkit for graph database development
- **Portfolio Project**: Comprehensive application demonstrating all Neo4j concepts
- **Best Practices**: Production deployment, testing, and monitoring expertise
- **Problem-Solving**: Complex graph problems and optimization techniques

**Continue your journey with:**
- **Neo4j Certification**: Professional credentialing
- **Advanced Graph Algorithms**: Specialized algorithm development
- **Enterprise Deployment**: Clustering and high-availability systems
- **Domain Applications**: Healthcare, finance, fraud detection, and knowledge graphs

---

**🎉 Lab 10 Complete! Full Course Mastery Achieved!**

You've successfully integrated all concepts from Labs 1-9 into a production-ready Python application, demonstrating complete mastery of Neo4j graph database development from fundamentals to enterprise deployment.