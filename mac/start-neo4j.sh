#!/bin/bash
# Neo4j Mastering Course - Start Neo4j Container
# Mac/Linux version

echo "Starting Neo4j container..."

# Try to start existing container
docker start neo4j &>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Neo4j container started successfully!"
    echo ""
    echo "Access Neo4j at: http://localhost:7474"
    echo "Username: neo4j"
    echo "Password: password"
else
    echo "Container does not exist, creating new one..."

    # Create Docker container with volumes and optimized settings
    docker run -d \
        --name neo4j \
        -p 7474:7474 -p 7687:7687 \
        -v $HOME/neo4j/data:/data \
        -v $HOME/neo4j/logs:/logs \
        -v $HOME/neo4j/import:/var/lib/neo4j/import \
        --env NEO4J_AUTH=neo4j/password \
        --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
        --env NEO4J_dbms_memory_heap_max__size=4G \
        --env NEO4J_dbms_memory_transaction_total_max=4G \
        --env NEO4J_dbms_security_procedures_unrestricted=apoc.*,gds.* \
        neo4j:5.26.9-enterprise

    if [ $? -eq 0 ]; then
        echo "✓ Neo4j container created and started successfully!"

        echo ""
        echo "Installing plugins..."
        sleep 5

        echo "  - Installing APOC plugin..."
        docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/apoc-5.26.9-core.jar https://github.com/neo4j/apoc/releases/download/5.26.9/apoc-5.26.9-core.jar" &>/dev/null

        if [ $? -eq 0 ]; then
            echo "    ✓ APOC plugin installed!"
        else
            echo "    ⚠ APOC plugin installation failed (optional)"
        fi

        echo "  - Installing GDS plugin..."
        docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/neo4j-graph-data-science-2.13.4.jar https://github.com/neo4j/graph-data-science/releases/download/2.13.4/neo4j-graph-data-science-2.13.4.jar" &>/dev/null

        if [ $? -eq 0 ]; then
            echo "    ✓ GDS plugin installed!"
        else
            echo "    ⚠ GDS plugin installation failed (optional, alternatives in Lab 7)"
        fi

        echo ""
        echo "Restarting Neo4j to load plugins..."
        docker restart neo4j &>/dev/null
        echo "✓ Neo4j restarted successfully!"

        echo ""
        echo "Access Neo4j at: http://localhost:7474"
        echo "Username: neo4j"
        echo "Password: password"
    else
        echo "✗ Failed to create Neo4j container"
        exit 1
    fi
fi

echo ""
echo "Waiting for Neo4j to be ready..."
sleep 10
echo "✓ Neo4j should be ready now!"
