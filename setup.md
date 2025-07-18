# Docker

## Mac  
docker run --name neo4j -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password -e NEO4J_PLUGINS='["apoc","graph-data-science"]' -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes -d neo4j:5.26.9-enterprise

## Windows(powershell)  

docker run --name neo4j-enterprise-lts -p 7474:7474 -p 7687:7687 -v $HOME/neo4j/data:/data -v $HOME/neo4j/logs:/logs -v $HOME/neo4j/import:/var/lib/neo4j/import --env NEO4J_AUTH=neo4j/password --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes neo4j:5.26.9-enterprise

docker exec neo4j-enterprise-lts sh -c "sleep 5 && wget -O /var/lib/neo4j/plugins/apoc-5.26.9-core.jar https://github.com/neo4j/apoc/releases/download/5.26.9/apoc-5.26.9-core.jar"

docker restart neo4j
