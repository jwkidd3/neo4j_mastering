@echo off
echo Removing Neo4j container...
docker rm -f neo4j

echo Removing Neo4j image...
docker rmi neo4j:5.26.9-enterprise

echo Cleanup complete!
