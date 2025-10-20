#!/bin/bash
# Neo4j Mastering Course - Cleanup Neo4j Container
# Mac/Linux version

echo "Removing Neo4j container..."
docker rm -f neo4j 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Neo4j container removed!"
else
    echo "⚠ Neo4j container doesn't exist"
fi

echo ""
echo "Removing Neo4j image..."
docker rmi neo4j:5.26.9-enterprise 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ Neo4j image removed!"
else
    echo "⚠ Neo4j image not found or still in use"
fi

echo ""
echo "Cleanup complete!"
