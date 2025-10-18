# Neo4j Clustering and Replication Guide

## 🎯 **Overview**

Neo4j Enterprise Edition provides several approaches to clustering and replication for high availability, scalability, and fault tolerance. This guide covers the different clustering architectures, configuration patterns, and operational best practices.

---

## 🏗️ **Clustering Architectures**

### **1. Causal Clustering (Neo4j 3.1+)**
The recommended clustering approach for production environments.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Core Server   │    │   Core Server   │    │   Core Server   │
│   (Leader)      │◄──►│   (Follower)    │◄──►│   (Follower)    │
│   Read/Write    │    │   Read Only     │    │   Read Only     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Read Replica   │    │  Read Replica   │    │  Read Replica   │
│   (Read Only)   │    │   (Read Only)   │    │   (Read Only)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Core Components:**
- **Core Servers**: Form consensus cluster (3, 5, or 7 nodes recommended)
- **Read Replicas**: Scale read operations (unlimited number)
- **Leader Election**: Automatic failover using Raft consensus protocol

### **2. Fabric (Neo4j 4.0+)**
For federating multiple databases and sharding strategies.

```
┌─────────────────────────────────────────────────────────────┐
│                    Fabric Gateway                           │
│                (Query Routing Layer)                        │
└─────────────────────────────────────────────────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Database A    │    │   Database B    │    │   Database C    │
│  (US-West)      │    │  (US-East)      │    │  (Europe)       │
│  Causal Cluster │    │  Causal Cluster │    │  Causal Cluster │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## ⚙️ **Causal Clustering Configuration**

### **Core Server Configuration**

```bash
# neo4j.conf for Core Server
dbms.mode=CORE

# Cluster settings
causal_clustering.minimum_core_cluster_size_at_formation=3
causal_clustering.minimum_core_cluster_size_at_runtime=3
causal_clustering.initial_discovery_members=core1:5000,core2:5000,core3:5000

# Network settings
causal_clustering.discovery_listen_address=0.0.0.0:5000
causal_clustering.transaction_listen_address=0.0.0.0:6000
causal_clustering.raft_listen_address=0.0.0.0:7000

# Memory configuration
dbms.memory.heap.initial_size=4G
dbms.memory.heap.max_size=4G
dbms.memory.pagecache.size=2G

# Enable authentication
dbms.security.auth_enabled=true
dbms.security.procedures.unrestricted=gds.*,apoc.*
```

### **Read Replica Configuration**

```bash
# neo4j.conf for Read Replica
dbms.mode=READ_REPLICA

# Cluster connection
causal_clustering.initial_discovery_members=core1:5000,core2:5000,core3:5000

# Network settings
causal_clustering.discovery_listen_address=0.0.0.0:5000
causal_clustering.transaction_listen_address=0.0.0.0:6000

# Read replica specific settings
causal_clustering.read_replica_refresh_rate=1s
causal_clustering.read_replica_time_to_live=300s

# Memory configuration (can be smaller than core servers)
dbms.memory.heap.initial_size=2G
dbms.memory.heap.max_size=2G
dbms.memory.pagecache.size=1G
```

### **Docker Compose Setup**

```yaml
version: '3.8'

services:
  neo4j-core1:
    image: neo4j:5.22-enterprise
    hostname: core1
    container_name: neo4j-core1
    ports:
      - "7474:7474"
      - "7687:7687"
    environment:
      - NEO4J_AUTH=neo4j/password
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_dbms_mode=CORE
      - NEO4J_causal__clustering_minimum__core__cluster__size__at__formation=3
      - NEO4J_causal__clustering_minimum__core__cluster__size__at__runtime=3
      - NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000
      - NEO4J_causal__clustering_discovery__listen__address=0.0.0.0:5000
      - NEO4J_causal__clustering_transaction__listen__address=0.0.0.0:6000
      - NEO4J_causal__clustering_raft__listen__address=0.0.0.0:7000
    volumes:
      - neo4j-core1-data:/data
      - neo4j-core1-logs:/logs
    networks:
      - neo4j-network

  neo4j-core2:
    image: neo4j:5.22-enterprise
    hostname: core2
    container_name: neo4j-core2
    ports:
      - "7475:7474"
      - "7688:7687"
    environment:
      - NEO4J_AUTH=neo4j/password
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_dbms_mode=CORE
      - NEO4J_causal__clustering_minimum__core__cluster__size__at__formation=3
      - NEO4J_causal__clustering_minimum__core__cluster__size__at__runtime=3
      - NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000
      - NEO4J_causal__clustering_discovery__listen__address=0.0.0.0:5000
      - NEO4J_causal__clustering_transaction__listen__address=0.0.0.0:6000
      - NEO4J_causal__clustering_raft__listen__address=0.0.0.0:7000
    volumes:
      - neo4j-core2-data:/data
      - neo4j-core2-logs:/logs
    networks:
      - neo4j-network

  neo4j-core3:
    image: neo4j:5.22-enterprise
    hostname: core3
    container_name: neo4j-core3
    ports:
      - "7476:7474"
      - "7689:7687"
    environment:
      - NEO4J_AUTH=neo4j/password
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_dbms_mode=CORE
      - NEO4J_causal__clustering_minimum__core__cluster__size__at__formation=3
      - NEO4J_causal__clustering_minimum__core__cluster__size__at__runtime=3
      - NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000
      - NEO4J_causal__clustering_discovery__listen__address=0.0.0.0:5000
      - NEO4J_causal__clustering_transaction__listen__address=0.0.0.0:6000
      - NEO4J_causal__clustering_raft__listen__address=0.0.0.0:7000
    volumes:
      - neo4j-core3-data:/data
      - neo4j-core3-logs:/logs
    networks:
      - neo4j-network

  neo4j-replica1:
    image: neo4j:5.22-enterprise
    hostname: replica1
    container_name: neo4j-replica1
    ports:
      - "7477:7474"
      - "7690:7687"
    environment:
      - NEO4J_AUTH=neo4j/password
      - NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
      - NEO4J_dbms_mode=READ_REPLICA
      - NEO4J_causal__clustering_initial__discovery__members=core1:5000,core2:5000,core3:5000
      - NEO4J_causal__clustering_discovery__listen__address=0.0.0.0:5000
      - NEO4J_causal__clustering_transaction__listen__address=0.0.0.0:6000
    volumes:
      - neo4j-replica1-data:/data
      - neo4j-replica1-logs:/logs
    networks:
      - neo4j-network
    depends_on:
      - neo4j-core1
      - neo4j-core2
      - neo4j-core3

volumes:
  neo4j-core1-data:
  neo4j-core1-logs:
  neo4j-core2-data:
  neo4j-core2-logs:
  neo4j-core3-data:
  neo4j-core3-logs:
  neo4j-replica1-data:
  neo4j-replica1-logs:

networks:
  neo4j-network:
    driver: bridge
```

---

## 🔧 **Application Integration Patterns**

### **Driver Configuration for Clustering**

```python
from neo4j import GraphDatabase, RoutingControl

class ClusteredNeo4jConnection:
    def __init__(self, cluster_uri, auth):
        self.driver = GraphDatabase.driver(
            cluster_uri,
            auth=auth,
            # Connection pool settings
            max_connection_lifetime=30 * 60,  # 30 minutes
            max_connection_pool_size=50,
            connection_acquisition_timeout=60,
            # Clustering settings
            routing_context={"region": "us-west-1"},
            # Security settings
            encrypted=True,
            trust=TRUST_SYSTEM_CA_SIGNED_CERTIFICATES
        )
    
    def read_query(self, query, parameters=None):
        """Execute read query on read replica"""
        with self.driver.session(
            default_access_mode=ACCESS_MODE_READ,
            database="neo4j"
        ) as session:
            return session.run(query, parameters).data()
    
    def write_query(self, query, parameters=None):
        """Execute write query on core leader"""
        with self.driver.session(
            default_access_mode=ACCESS_MODE_WRITE,
            database="neo4j"
        ) as session:
            return session.run(query, parameters).data()
    
    def write_transaction(self, tx_function, *args, **kwargs):
        """Execute write transaction with retry logic"""
        with self.driver.session(
            default_access_mode=ACCESS_MODE_WRITE,
            database="neo4j"
        ) as session:
            return session.execute_write(tx_function, *args, **kwargs)
    
    def read_transaction(self, tx_function, *args, **kwargs):
        """Execute read transaction on read replica"""
        with self.driver.session(
            default_access_mode=ACCESS_MODE_READ,
            database="neo4j"
        ) as session:
            return session.execute_read(tx_function, *args, **kwargs)
    
    def close(self):
        self.driver.close()

# Usage example
cluster = ClusteredNeo4jConnection(
    "neo4j://core1:7687,core2:7687,core3:7687",
    ("neo4j", "password")
)

# Read operations go to read replicas
users = cluster.read_query("""
    MATCH (u:User) 
    RETURN u.name, u.email 
    ORDER BY u.created_at DESC 
    LIMIT 100
""")

# Write operations go to core leader
def create_user_tx(tx, name, email):
    return tx.run("""
        CREATE (u:User {
            name: $name, 
            email: $email, 
            created_at: datetime()
        })
        RETURN u
    """, name=name, email=email).single()

new_user = cluster.write_transaction(create_user_tx, "Alice", "alice@example.com")
```

### **Load Balancer Configuration**

```nginx
# nginx.conf for Neo4j cluster load balancing
upstream neo4j_read {
    server replica1:7687 weight=3;
    server replica2:7687 weight=3;
    server core1:7687 weight=1;    # Fallback for reads
    server core2:7687 weight=1;
    server core3:7687 weight=1;
}

upstream neo4j_write {
    server core1:7687;
    server core2:7687 backup;
    server core3:7687 backup;
}

server {
    listen 7687;
    proxy_pass neo4j_read;
    proxy_timeout 300s;
    proxy_connect_timeout 10s;
}

server {
    listen 7688;
    proxy_pass neo4j_write;
    proxy_timeout 300s;
    proxy_connect_timeout 10s;
}
```

---

## 📊 **Monitoring and Health Checks**

### **Cluster Status Monitoring**

```python
import time
import requests
from neo4j import GraphDatabase

class ClusterMonitor:
    def __init__(self, cluster_endpoints, auth):
        self.endpoints = cluster_endpoints
        self.auth = auth
        
    def check_cluster_health(self):
        """Monitor cluster health and status"""
        health_status = {}
        
        for endpoint in self.endpoints:
            try:
                # Check HTTP health endpoint
                response = requests.get(f"http://{endpoint}:7474/db/manage/server/core/available")
                health_status[endpoint] = {
                    'http_available': response.status_code == 200,
                    'role': self.get_server_role(endpoint),
                    'last_check': time.time()
                }
            except Exception as e:
                health_status[endpoint] = {
                    'http_available': False,
                    'error': str(e),
                    'last_check': time.time()
                }
        
        return health_status
    
    def get_server_role(self, endpoint):
        """Determine server role (leader, follower, read_replica)"""
        try:
            driver = GraphDatabase.driver(f"bolt://{endpoint}:7687", auth=self.auth)
            with driver.session() as session:
                result = session.run("CALL dbms.cluster.role()")
                role = result.single()['role']
                driver.close()
                return role
        except Exception:
            return 'unknown'
    
    def get_cluster_topology(self):
        """Get detailed cluster topology information"""
        try:
            # Connect to any available server
            driver = GraphDatabase.driver(
                f"bolt://{self.endpoints[0]}:7687", 
                auth=self.auth
            )
            
            with driver.session() as session:
                # Get cluster overview
                overview = session.run("CALL dbms.cluster.overview()").data()
                
                # Get routing table
                routing = session.run("CALL dbms.cluster.routing.getRoutingTable({})").data()
                
            driver.close()
            
            return {
                'overview': overview,
                'routing': routing,
                'timestamp': time.time()
            }
        except Exception as e:
            return {'error': str(e), 'timestamp': time.time()}

# Usage
monitor = ClusterMonitor(['core1', 'core2', 'core3', 'replica1'], ('neo4j', 'password'))
health = monitor.check_cluster_health()
topology = monitor.get_cluster_topology()

print("Cluster Health:", health)
print("Cluster Topology:", topology)
```

### **Prometheus Metrics Integration**

```yaml
# prometheus.yml configuration for Neo4j monitoring
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'neo4j-cluster'
    static_configs:
      - targets: 
        - 'core1:2004'
        - 'core2:2004' 
        - 'core3:2004'
        - 'replica1:2004'
    scrape_interval: 10s
    metrics_path: /metrics
    params:
      format: ['prometheus']
```

```bash
# Enable metrics in neo4j.conf
metrics.enabled=true
metrics.prometheus.enabled=true
metrics.prometheus.endpoint=0.0.0.0:2004
```

### **Grafana Dashboard Configuration**

```json
{
  "dashboard": {
    "title": "Neo4j Cluster Monitoring",
    "panels": [
      {
        "title": "Cluster Status",
        "type": "stat",
        "targets": [
          {
            "expr": "neo4j_cluster_core_is_leader",
            "legendFormat": "{{instance}} Leader"
          }
        ]
      },
      {
        "title": "Transaction Throughput",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(neo4j_transaction_committed_total[5m])",
            "legendFormat": "{{instance}} Commits/sec"
          }
        ]
      },
      {
        "title": "Query Performance",
        "type": "graph", 
        "targets": [
          {
            "expr": "histogram_quantile(0.95, neo4j_cypher_query_execution_latency_seconds)",
            "legendFormat": "{{instance}} 95th percentile"
          }
        ]
      }
    ]
  }
}
```

---

## 🚀 **Scaling Strategies**

### **Horizontal Read Scaling**

```python
class ReadScalingStrategy:
    def __init__(self, core_servers, read_replicas):
        self.core_servers = core_servers
        self.read_replicas = read_replicas
        self.read_connections = []
        
        # Create dedicated read connections
        for replica in read_replicas:
            driver = GraphDatabase.driver(f"bolt://{replica}:7687")
            self.read_connections.append(driver)
    
    def distribute_read_load(self, queries):
        """Distribute read queries across read replicas"""
        results = []
        
        for i, query in enumerate(queries):
            # Round-robin distribution
            replica_index = i % len(self.read_connections)
            driver = self.read_connections[replica_index]
            
            with driver.session() as session:
                result = session.run(query).data()
                results.append(result)
        
        return results
    
    def add_read_replica(self, replica_endpoint):
        """Dynamically add new read replica"""
        driver = GraphDatabase.driver(f"bolt://{replica_endpoint}:7687")
        self.read_connections.append(driver)
        self.read_replicas.append(replica_endpoint)
```

### **Geographic Distribution**

```python
class GeographicClusterManager:
    def __init__(self):
        self.regions = {
            'us-west': {
                'cores': ['us-west-core1', 'us-west-core2', 'us-west-core3'],
                'replicas': ['us-west-replica1', 'us-west-replica2']
            },
            'us-east': {
                'cores': ['us-east-core1', 'us-east-core2', 'us-east-core3'],
                'replicas': ['us-east-replica1', 'us-east-replica2']
            },
            'europe': {
                'replicas': ['eu-replica1', 'eu-replica2', 'eu-replica3']
            }
        }
    
    def get_nearest_cluster(self, user_location):
        """Route users to nearest cluster for better latency"""
        if user_location.startswith('us-west'):
            return self.regions['us-west']
        elif user_location.startswith('us-east'):
            return self.regions['us-east']
        elif user_location.startswith('eu'):
            return self.regions['europe']
        else:
            # Default to us-west
            return self.regions['us-west']
```

---

## 🛡️ **High Availability and Disaster Recovery**

### **Automatic Failover Configuration**

```bash
# neo4j.conf settings for robust failover
causal_clustering.minimum_core_cluster_size_at_runtime=3
causal_clustering.leader_election_timeout=7s
causal_clustering.leader_heartbeat_timeout=60s
causal_clustering.catchup_timeout=600s

# Network fault tolerance
causal_clustering.discovery_listen_address=0.0.0.0:5000
causal_clustering.discovery_advertised_address=$(hostname):5000
causal_clustering.transaction_advertised_address=$(hostname):6000
causal_clustering.raft_advertised_address=$(hostname):7000

# Backup configuration
dbms.backup.enabled=true
dbms.backup.listen_address=0.0.0.0:6362
```

### **Backup and Recovery Procedures**

```bash
#!/bin/bash
# backup-cluster.sh

BACKUP_DIR="/backups/neo4j"
DATE=$(date +%Y%m%d_%H%M%S)
CLUSTER_ENDPOINT="core1:7687"

# Full backup
neo4j-admin database backup \
    --from=bolt://$CLUSTER_ENDPOINT \
    --database=neo4j \
    --to-path=$BACKUP_DIR/full_$DATE \
    --verbose

# Incremental backup (if previous full backup exists)
if [ -d "$BACKUP_DIR/full_$LAST_FULL" ]; then
    neo4j-admin database backup \
        --from=bolt://$CLUSTER_ENDPOINT \
        --database=neo4j \
        --to-path=$BACKUP_DIR/incremental_$DATE \
        --from-path=$BACKUP_DIR/full_$LAST_FULL \
        --verbose
fi

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -type d -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $BACKUP_DIR/full_$DATE"
```

### **Recovery Procedures**

```bash
#!/bin/bash
# restore-cluster.sh

BACKUP_PATH="/backups/neo4j/full_20241217_140000"
NEO4J_HOME="/var/lib/neo4j"

# Stop Neo4j service
systemctl stop neo4j

# Clear existing data
rm -rf $NEO4J_HOME/data/databases/neo4j
rm -rf $NEO4J_HOME/data/transactions/neo4j

# Restore from backup
neo4j-admin database restore \
    --from-path=$BACKUP_PATH \
    --database=neo4j \
    --overwrite-destination

# Set proper ownership
chown -R neo4j:neo4j $NEO4J_HOME/data

# Start Neo4j service
systemctl start neo4j

echo "Recovery completed from backup: $BACKUP_PATH"
```

---

## 📈 **Performance Optimization**

### **Memory Configuration for Clusters**

```bash
# Core Server Memory Configuration (32GB RAM)
dbms.memory.heap.initial_size=8G
dbms.memory.heap.max_size=8G
dbms.memory.pagecache.size=16G

# Additional JVM settings
dbms.jvm.additional=-XX:+UseG1GC
dbms.jvm.additional=-XX:+UnlockExperimentalVMOptions
dbms.jvm.additional=-XX:+UseTransparentHugePages
dbms.jvm.additional=-XX:G1HeapRegionSize=32m

# Read Replica Memory Configuration (16GB RAM)
dbms.memory.heap.initial_size=4G
dbms.memory.heap.max_size=4G
dbms.memory.pagecache.size=8G
```

### **Index Strategy for Clusters**

```cypher
-- Create indexes on leader (automatically replicated)
CREATE INDEX user_email IF NOT EXISTS FOR (u:User) ON (u.email);
CREATE INDEX post_timestamp IF NOT EXISTS FOR (p:Post) ON (p.timestamp);
CREATE INDEX transaction_amount IF NOT EXISTS FOR ()-[t:TRANSACTION]-() ON (t.amount);

-- Composite indexes for complex queries
CREATE INDEX user_location_status IF NOT EXISTS FOR (u:User) ON (u.location, u.status);

-- Full-text indexes for search
CREATE FULLTEXT INDEX user_search IF NOT EXISTS FOR (u:User) ON EACH [u.name, u.bio];
```

---

## 🔍 **Troubleshooting Common Issues**

### **Split Brain Prevention**

```python
def check_cluster_quorum():
    """Ensure cluster has proper quorum to prevent split brain"""
    
    monitor = ClusterMonitor(['core1', 'core2', 'core3'], ('neo4j', 'password'))
    topology = monitor.get_cluster_topology()
    
    if 'overview' in topology:
        core_servers = [
            server for server in topology['overview'] 
            if server['role'] in ['leader', 'follower']
        ]
        
        active_cores = [
            server for server in core_servers 
            if server['health'] == 'available'
        ]
        
        if len(active_cores) < 2:  # Less than majority
            print("WARNING: Cluster does not have quorum!")
            print(f"Active cores: {len(active_cores)}")
            print(f"Required for quorum: 2")
            return False
    
    return True
```

### **Network Partition Handling**

```bash
# Monitor network connectivity between cluster members
check_network_connectivity() {
    CORE_SERVERS=("core1" "core2" "core3")
    
    for server1 in "${CORE_SERVERS[@]}"; do
        for server2 in "${CORE_SERVERS[@]}"; do
            if [ "$server1" != "$server2" ]; then
                if ! ping -c 1 -W 1 "$server2" > /dev/null 2>&1; then
                    echo "WARNING: $server1 cannot reach $server2"
                fi
            fi
        done
    done
}

# Check Raft connectivity
check_raft_connectivity() {
    for server in core1 core2 core3; do
        if ! nc -z "$server" 7000; then
            echo "ERROR: Cannot connect to Raft port on $server"
        fi
    done
}
```

---

## 📚 **Best Practices Summary**

### **Cluster Sizing Guidelines**

| Use Case | Core Servers | Read Replicas | Total Nodes |
|----------|--------------|---------------|-------------|
| **Small Production** | 3 | 2-3 | 5-6 |
| **Medium Production** | 3 | 5-10 | 8-13 |
| **Large Production** | 5 | 10-20 | 15-25 |
| **Global Distribution** | 3-5 per region | 3-5 per region | 20-50+ |

### **Configuration Best Practices**

1. **Always use odd number of core servers** (3, 5, 7) for proper consensus
2. **Size core servers identically** for consistent performance
3. **Use read replicas for scaling** read-heavy workloads
4. **Configure proper network timeouts** for your environment
5. **Monitor cluster health continuously** with automated alerting
6. **Test failover scenarios regularly** in staging environments
7. **Keep backup and recovery procedures** well-documented and tested

### **Security Considerations**

```bash
# Enable encryption between cluster members
causal_clustering.ssl_policy=cluster
dbms.ssl.policy.cluster.enabled=true
dbms.ssl.policy.cluster.client_auth=REQUIRE

# Network access control
dbms.connectors.default_listen_address=0.0.0.0
dbms.connectors.default_advertised_address=$(hostname)

# Authentication and authorization
dbms.security.auth_enabled=true
dbms.security.ldap.authentication_enabled=true
dbms.security.procedures.whitelist=apoc.*,gds.*
```

---

## 🎯 **Key Takeaways**

1. **Causal Clustering** is the recommended approach for production high availability
2. **Read Replicas** provide unlimited horizontal scaling for read operations
3. **Proper monitoring** is essential for maintaining cluster health
4. **Network configuration** is critical for cluster stability
5. **Backup and recovery** procedures must be tested regularly
6. **Performance tuning** should account for cluster-specific considerations

Neo4j's clustering capabilities provide enterprise-grade scalability and reliability when properly configured and monitored.

---

## 📖 **Additional Resources**

- [Neo4j Clustering Documentation](https://neo4j.com/docs/operations-manual/current/clustering/)
- [Causal Clustering Best Practices](https://neo4j.com/docs/operations-manual/current/clustering/causal-clustering/)
- [Neo4j Monitoring Guide](https://neo4j.com/docs/operations-manual/current/monitoring/)
- [Backup and Recovery](https://neo4j.com/docs/operations-manual/current/backup-restore/)
- [Performance Tuning](https://neo4j.com/docs/operations-manual/current/performance/)