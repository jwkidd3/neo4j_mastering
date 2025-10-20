#!/bin/bash
# Neo4j Mastering Course - Stop Neo4j Container
# Mac/Linux version

echo "Stopping Neo4j container..."
docker stop neo4j

if [ $? -eq 0 ]; then
    echo "✓ Neo4j container stopped!"
else
    echo "⚠ Neo4j container not running or doesn't exist"
fi
