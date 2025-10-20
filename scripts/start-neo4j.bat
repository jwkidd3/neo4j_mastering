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
    docker run -d --name neo4j -p 7474:7474 -p 7687:7687 -v %USERPROFILE%/neo4j/data:/data -v %USERPROFILE%/neo4j/logs:/logs -v %USERPROFILE%/neo4j/import:/var/lib/neo4j/import --env NEO4J_AUTH=neo4j/password --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes --env NEO4J_dbms_memory_heap_max__size=2G --env NEO4J_dbms_memory_transaction_total_max=2G --env NEO4J_dbms_security_procedures_unrestricted=apoc.*,gds.* neo4j:5.26.9-enterprise
    echo Neo4j container created and started successfully!

    echo Installing plugins...
    timeout /t 5 /nobreak >nul

    echo   - Installing APOC plugin...
    docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/apoc-5.26.9-core.jar https://github.com/neo4j/apoc/releases/download/5.26.9/apoc-5.26.9-core.jar" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo     * APOC plugin installed!
    ) else (
        echo     ! APOC plugin installation failed (optional)
    )

    echo   - Installing GDS plugin...
    docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/neo4j-graph-data-science-2.13.4.jar https://github.com/neo4j/graph-data-science/releases/download/2.13.4/neo4j-graph-data-science-2.13.4.jar" >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo     * GDS plugin installed!
    ) else (
        echo     ! GDS plugin installation failed (optional, alternatives in Lab 7)
    )

    echo.
    echo Restarting Neo4j to load plugins...
    docker restart neo4j >nul 2>&1
    echo Neo4j restarted successfully!

    echo Access Neo4j at: http://localhost:7474
    echo Username: neo4j
    echo Password: password
)
