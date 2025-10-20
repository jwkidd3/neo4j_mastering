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

    # Create Docker container with volumes
    docker run -d \
        --name neo4j \
        -p 7474:7474 -p 7687:7687 \
        -v $HOME/neo4j/data:/data \
        -v $HOME/neo4j/logs:/logs \
        -v $HOME/neo4j/import:/var/lib/neo4j/import \
        --env NEO4J_AUTH=neo4j/password \
        --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
        neo4j:5.26.9-enterprise

    if [ $? -eq 0 ]; then
        echo "✓ Neo4j container created and started successfully!"

        echo ""
        echo "Installing APOC plugin..."
        sleep 5
        docker exec neo4j sh -c "wget -O /var/lib/neo4j/plugins/apoc-5.26.9-core.jar https://github.com/neo4j/apoc/releases/download/5.26.9/apoc-5.26.9-core.jar" &>/dev/null

        if [ $? -eq 0 ]; then
            echo "✓ APOC plugin installed!"
        else
            echo "⚠ APOC plugin installation failed (optional)"
        fi

        echo ""
        echo "Restarting Neo4j to load plugin..."
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
