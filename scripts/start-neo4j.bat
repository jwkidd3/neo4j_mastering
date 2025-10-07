@echo off
echo Starting Neo4j container...

docker start neo4j 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Neo4j container started successfully!
    echo Access Neo4j at: http://localhost:7474
    echo Username: neo4j
    echo Password: password
) else (
    echo Container does not exist, creating new one...
    docker run -d --name neo4j -p 7474:7474 -p 7687:7687 -v %USERPROFILE%/neo4j/data:/data -v %USERPROFILE%/neo4j/logs:/logs -v %USERPROFILE%/neo4j/import:/var/lib/neo4j/import --env NEO4J_AUTH=neo4j/password --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes neo4j:5.26.9-enterprise
    echo Neo4j container created and started successfully!
    echo Installing APOC plugin...
    docker exec neo4j sh -c "sleep 5 && wget -O /var/lib/neo4j/plugins/apoc-5.26.9-core.jar https://github.com/neo4j/apoc/releases/download/5.26.9/apoc-5.26.9-core.jar"
    echo APOC plugin installed!
    echo Restarting Neo4j to load plugin...
    docker restart neo4j
    echo Neo4j restarted successfully!
    echo Access Neo4j at: http://localhost:7474
    echo Username: neo4j
    echo Password: password
)
