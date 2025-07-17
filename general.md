
# Python ENV

## 1. Navigate to your project directory (replace with your actual path)
cd /path/to/your/project

## 2. Create the virtual environment
python -m venv .venv

## 3. Activate the virtual environment
### On Linux/macOS:
source .venv/bin/activate
### On Windows (Command Prompt):  
 .venv\Scripts\activate.bat
### On Windows (PowerShell):  
 Set-ExecutionPolicy Unrestricted -Force
 .venv\Scripts\Activate.ps1

## 4. Install Jupyter and ipykernel (and your project libraries)
pip install notebook ipykernel  
pip install neo4j pandas numpy matplotlib # Example libraries, add what you need

## 5. Register the virtual environment as a Jupyter Kernel
python -m ipykernel install --user --name=MyNeo4jProjectEnv --display-name "Python 3 (Neo4j Project)"

## 6. Launch Jupyter Notebook (ensure virtual environment is active)
jupyter lab

## 7. Deactivate the virtual environment (when done working)
deactivate



# Docker

## Mac  
docker run --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password -e NEO4J_PLUGINS='["apoc","graph-data-science"]' -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes -d neo4j:enterprise

## Windows(powershell)  
docker run --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes -d neo4j:5.15-enterprise  

docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/apoc.jar https://github.com/neo4j/apoc/releases/download/5.15.0/apoc-5.15.0-core.jar"  

docker restart neo4j  


# Complete setup in one command
docker run --name neo4j \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -e NEO4J_dbms_memory_heap_initial__size=1G \
  -e NEO4J_dbms_memory_heap_max__size=2G \
  -e NEO4J_dbms_memory_pagecache_size=1G \
  -e NEO4J_PLUGINS='["apoc", "graph-data-science"]' \
  -v neo4j_data:/data \
  -v neo4j_logs:/logs \
  -d neo4j:5.22-enterprise && \
docker exec neo4j sh -c "sleep 30 && wget -O /var/lib/neo4j/plugins/apoc-5.22.0-core.jar https://github.com/neo4j/apoc/releases/download/5.22.0/apoc-5.22.0-core.jar" && \
docker restart neo4j
