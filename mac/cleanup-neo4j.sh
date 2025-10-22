#!/bin/bash
# Neo4j Mastering Course - Complete Cleanup
# Mac/Linux version

echo "============================================================"
echo "Neo4j Mastering Course - Complete Cleanup"
echo "============================================================"
echo ""

echo "[1/4] Stopping and removing Neo4j container..."
docker rm -f neo4j 2>/dev/null

if [ $? -eq 0 ]; then
    echo "  ✓ Container removed successfully!"
else
    echo "  - Container doesn't exist or already removed"
fi

echo ""
echo "[2/4] Removing Neo4j image..."
docker rmi neo4j:5.26.9-enterprise 2>/dev/null

if [ $? -eq 0 ]; then
    echo "  ✓ Image removed successfully!"
else
    echo "  - Image doesn't exist or still in use"
fi

echo ""
echo "[3/4] Removing Docker volumes..."
docker volume rm neo4j_data neo4j_logs neo4j_import 2>/dev/null

if [ $? -eq 0 ]; then
    echo "  ✓ Docker volumes removed!"
else
    echo "  - No Docker volumes found"
fi

echo ""
echo "[4/4] Removing mapped volume directories..."
if [ -d "$HOME/neo4j" ]; then
    echo "  Removing $HOME/neo4j..."
    rm -rf "$HOME/neo4j"

    if [ $? -eq 0 ]; then
        echo "  ✓ Volume directories removed successfully!"
    else
        echo "  ✗ Failed to remove volume directories"
    fi
else
    echo "  - Volume directories don't exist"
fi

echo ""
echo "============================================================"
echo "✅ Cleanup complete!"
echo "============================================================"
echo ""
echo "All Neo4j data, logs, and configuration have been removed."
echo "You can start fresh by running ./start-neo4j.sh"
echo ""
