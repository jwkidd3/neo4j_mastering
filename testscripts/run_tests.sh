#!/bin/bash
##############################################################################
# Neo4j Mastering Course - Comprehensive Test Runner Script (Unix/Mac/Linux)
#
# This script provides a complete isolated test environment:
# 1. Checks/installs Docker environment
# 2. Creates and starts Neo4j Enterprise container (exact same config as setup)
# 3. Creates temporary Python virtual environment
# 4. Installs all required packages
# 5. Runs the comprehensive test suite for all 17 labs
# 6. Cleans up everything (Python env, Docker container, Docker image, volumes)
##############################################################################

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration - EXACT SAME AS SETUP SCRIPT
NEO4J_VERSION="5.26.9-enterprise"
NEO4J_IMAGE="neo4j:${NEO4J_VERSION}"
NEO4J_CONTAINER="neo4j-test-$$"  # Unique name with PID
NEO4J_PASSWORD="password"
NEO4J_DATABASE="insurance"
APOC_VERSION="5.26.9"
APOC_JAR="apoc-${APOC_VERSION}-core.jar"
APOC_URL="https://github.com/neo4j/apoc/releases/download/${APOC_VERSION}/${APOC_JAR}"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.test_venv"

# Temporary directories for Neo4j volumes
TEMP_DIR="/tmp/neo4j-test-$$"
NEO4J_DATA_DIR="$TEMP_DIR/data"
NEO4J_LOGS_DIR="$TEMP_DIR/logs"
NEO4J_IMPORT_DIR="$TEMP_DIR/import"

# Track what needs cleanup
CREATED_CONTAINER=false
CREATED_VENV=false
PULLED_IMAGE=false
CREATED_TEMP_DIRS=false

# Cleanup function
cleanup() {
    local exit_code=$?

    echo ""
    echo "=============================================================================="
    echo -e "${CYAN}Cleaning up test environment...${NC}"
    echo "=============================================================================="

    # Deactivate Python venv if active
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        deactivate 2>/dev/null || true
    fi

    # Remove Python virtual environment
    if [ -d "$VENV_DIR" ]; then
        echo -e "${BLUE}Removing Python virtual environment...${NC}"
        rm -rf "$VENV_DIR"
        echo -e "${GREEN}✓ Python environment removed${NC}"
    fi

    # Stop and remove Neo4j container
    if [ "$CREATED_CONTAINER" = true ]; then
        echo -e "${BLUE}Stopping Neo4j container...${NC}"
        docker stop "$NEO4J_CONTAINER" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Container stopped${NC}"

        echo -e "${BLUE}Removing Neo4j container...${NC}"
        docker rm "$NEO4J_CONTAINER" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Container removed${NC}"
    fi

    # Remove temporary directories
    if [ "$CREATED_TEMP_DIRS" = true ] && [ -d "$TEMP_DIR" ]; then
        echo -e "${BLUE}Removing temporary Neo4j directories...${NC}"
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}✓ Temporary directories removed${NC}"
    fi

    # Remove Neo4j image if we pulled it
    if [ "$PULLED_IMAGE" = true ]; then
        echo -e "${BLUE}Removing Neo4j image ($NEO4J_IMAGE)...${NC}"
        docker rmi "$NEO4J_IMAGE" >/dev/null 2>&1 || true
        echo -e "${GREEN}✓ Image removed${NC}"
    fi

    echo -e "${GREEN}✓✓✓ Cleanup complete${NC}"
    exit $exit_code
}

# Set trap to cleanup on exit
trap cleanup EXIT INT TERM

echo "=============================================================================="
echo "Neo4j Mastering Course - Comprehensive Test Suite"
echo "=============================================================================="
echo "This script will create an isolated test environment and clean up everything"
echo "when complete (Docker container, image, and Python environment)."
echo "Configuration matches the course setup script exactly."
echo "=============================================================================="
echo ""

# Check if Docker is installed
echo -e "${BLUE}Checking Docker installation...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}✗ Docker daemon is not running${NC}"
    echo "Please start Docker Desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker daemon is running${NC}"

# Check if Python 3 is installed
echo ""
echo -e "${BLUE}Checking Python installation...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 is not installed${NC}"
    echo "Please install Python 3.8 or higher"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo -e "${GREEN}✓ Python $PYTHON_VERSION is installed${NC}"

# Create temporary directories for Neo4j volumes
echo ""
echo -e "${BLUE}Creating temporary directories for Neo4j data...${NC}"
mkdir -p "$NEO4J_DATA_DIR" "$NEO4J_LOGS_DIR" "$NEO4J_IMPORT_DIR"
CREATED_TEMP_DIRS=true
echo -e "${GREEN}✓ Temporary directories created${NC}"

# Check if Neo4j image exists locally
echo ""
echo "=============================================================================="
echo "Setting up Neo4j Docker environment..."
echo "=============================================================================="
echo ""

if docker image inspect "$NEO4J_IMAGE" &> /dev/null; then
    echo -e "${GREEN}✓ Neo4j image already exists locally${NC}"
else
    echo -e "${BLUE}Pulling Neo4j Enterprise image ($NEO4J_IMAGE)...${NC}"
    echo "This may take a few minutes..."
    if docker pull "$NEO4J_IMAGE"; then
        echo -e "${GREEN}✓ Neo4j image pulled successfully${NC}"
        PULLED_IMAGE=true
    else
        echo -e "${RED}✗ Failed to pull Neo4j image${NC}"
        exit 1
    fi
fi

# Create and start Neo4j container - EXACT SAME CONFIG AS SETUP SCRIPT
echo ""
echo -e "${BLUE}Creating Neo4j container ($NEO4J_CONTAINER)...${NC}"
echo "Using identical configuration to course setup script"
if docker run -d \
    --name "$NEO4J_CONTAINER" \
    -p 7474:7474 \
    -p 7687:7687 \
    -v "$NEO4J_DATA_DIR:/data" \
    -v "$NEO4J_LOGS_DIR:/logs" \
    -v "$NEO4J_IMPORT_DIR:/var/lib/neo4j/import" \
    --env NEO4J_AUTH=neo4j/$NEO4J_PASSWORD \
    --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
    "$NEO4J_IMAGE" >/dev/null; then
    echo -e "${GREEN}✓ Neo4j container created and started${NC}"
    CREATED_CONTAINER=true
else
    echo -e "${RED}✗ Failed to create Neo4j container${NC}"
    exit 1
fi

# Install APOC plugin - EXACT SAME METHOD AS SETUP SCRIPT
echo ""
echo -e "${BLUE}Installing APOC plugin ($APOC_JAR)...${NC}"
if docker exec "$NEO4J_CONTAINER" sh -c "sleep 5 && wget -O /var/lib/neo4j/plugins/$APOC_JAR $APOC_URL" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ APOC plugin downloaded${NC}"
else
    echo -e "${RED}✗ Failed to download APOC plugin${NC}"
    exit 1
fi

# Restart Neo4j to load plugin
echo -e "${BLUE}Restarting Neo4j to load APOC plugin...${NC}"
docker restart "$NEO4J_CONTAINER" >/dev/null
echo -e "${GREEN}✓ Neo4j restarted${NC}"

# Wait for Neo4j to be ready after restart
echo -e "${BLUE}Waiting for Neo4j to be ready...${NC}"
TIMEOUT=120
ELAPSED=0
READY=false

while [ $ELAPSED -lt $TIMEOUT ]; do
    if docker exec "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" "RETURN 1" &>/dev/null; then
        READY=true
        break
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    echo -n "."
done

echo ""

if [ "$READY" = false ]; then
    echo -e "${RED}✗ Neo4j failed to start within $TIMEOUT seconds${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Neo4j is ready${NC}"

# Verify APOC is loaded
echo -e "${BLUE}Verifying APOC plugin is loaded...${NC}"
if docker exec "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
    "RETURN apoc.version()" &>/dev/null; then
    echo -e "${GREEN}✓ APOC plugin verified${NC}"
else
    echo -e "${YELLOW}⚠ APOC verification skipped (may not be critical)${NC}"
fi

# Create insurance database
echo -e "${BLUE}Creating insurance database...${NC}"
if docker exec "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
    "CREATE DATABASE $NEO4J_DATABASE IF NOT EXISTS" &>/dev/null; then
    echo -e "${GREEN}✓ Insurance database created${NC}"
else
    echo -e "${YELLOW}⚠ Database may already exist (continuing...)${NC}"
fi

# Wait a bit for database to be ready
sleep 3

# Verify database connection
echo -e "${BLUE}Verifying database connection...${NC}"
if docker exec "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
    -d "$NEO4J_DATABASE" "RETURN 1" &>/dev/null; then
    echo -e "${GREEN}✓ Database connection verified${NC}"
else
    echo -e "${RED}✗ Cannot connect to insurance database${NC}"
    exit 1
fi

# Load lab data for testing
echo ""
echo -e "${BLUE}Loading lab data into database...${NC}"

# Load labs 1-8 sequentially (each builds on the previous)
echo "Loading foundation data (Labs 1-8)..."
for LAB_NUM in $(seq -f "%02g" 1 8); do
    DATA_FILE="$SCRIPT_DIR/../data/lab_${LAB_NUM}_data_reload.cypher"
    if [ ! -f "$DATA_FILE" ]; then
        echo -e "${RED}✗ Lab ${LAB_NUM} data file not found: $DATA_FILE${NC}"
        exit 1
    fi

    echo -n "  Loading Lab ${LAB_NUM}... "
    ERROR_LOG=$(mktemp)
    if docker exec -i "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
        -d "$NEO4J_DATABASE" < "$DATA_FILE" 2>"$ERROR_LOG"; then
        echo -e "${GREEN}✓${NC}"
        rm -f "$ERROR_LOG"
    else
        echo -e "${RED}✗ Failed${NC}"
        echo -e "${RED}✗ Failed to load Lab ${LAB_NUM} foundation data${NC}"
        echo ""
        echo -e "${YELLOW}Error details:${NC}"
        tail -30 "$ERROR_LOG"
        rm -f "$ERROR_LOG"
        exit 1
    fi
done
echo -e "${GREEN}✓ Labs 1-8 foundation loaded successfully${NC}"

# Then load Lab 17 advanced features (Labs 9-17)
DATA_FILE_17="$SCRIPT_DIR/../data/lab_17_data_reload.cypher"
if [ -f "$DATA_FILE_17" ]; then
    echo "Loading Lab 17 advanced features (Labs 9-17)..."
    ERROR_LOG=$(mktemp)
    if docker exec -i "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
        -d "$NEO4J_DATABASE" < "$DATA_FILE_17" 2>"$ERROR_LOG"; then
        echo -e "${GREEN}✓ Lab 17 advanced features loaded${NC}"
        rm -f "$ERROR_LOG"

        # Verify complete data was loaded
        NODE_COUNT=$(docker exec "$NEO4J_CONTAINER" cypher-shell -u neo4j -p "$NEO4J_PASSWORD" \
            -d "$NEO4J_DATABASE" --format plain "MATCH (n) RETURN count(n) as count" 2>/dev/null | grep -oE '[0-9]+' | head -1)
        echo -e "${GREEN}✓ Complete database loaded with $NODE_COUNT nodes${NC}"
    else
        echo -e "${RED}✗ Failed to load Lab 17 advanced features${NC}"
        echo ""
        echo -e "${YELLOW}Error details:${NC}"
        tail -30 "$ERROR_LOG"
        rm -f "$ERROR_LOG"
        exit 1
    fi
else
    echo -e "${RED}✗ Lab 17 data file not found: $DATA_FILE_17${NC}"
    exit 1
fi

# Set up Python environment
echo ""
echo "=============================================================================="
echo "Setting up Python test environment..."
echo "=============================================================================="
echo ""

# Create virtual environment
echo -e "${BLUE}Creating Python virtual environment...${NC}"
if python3 -m venv "$VENV_DIR"; then
    echo -e "${GREEN}✓ Virtual environment created${NC}"
    CREATED_VENV=true
else
    echo -e "${RED}✗ Failed to create virtual environment${NC}"
    exit 1
fi

# Activate virtual environment
echo -e "${BLUE}Activating virtual environment...${NC}"
source "$VENV_DIR/bin/activate"
echo -e "${GREEN}✓ Virtual environment activated${NC}"

# Upgrade pip
echo -e "${BLUE}Upgrading pip...${NC}"
pip install --quiet --upgrade pip
echo -e "${GREEN}✓ pip upgraded${NC}"

# Install requirements
echo -e "${BLUE}Installing test dependencies...${NC}"
if [ -f "$SCRIPT_DIR/requirements.txt" ]; then
    if pip install --quiet -r "$SCRIPT_DIR/requirements.txt"; then
        echo -e "${GREEN}✓ Dependencies installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install dependencies${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ requirements.txt not found${NC}"
    exit 1
fi

# Verify Neo4j connection from Python
echo ""
echo -e "${BLUE}Verifying Python → Neo4j connection...${NC}"
if python -c "from neo4j import GraphDatabase; driver = GraphDatabase.driver('neo4j://localhost:7687', auth=('neo4j', '$NEO4J_PASSWORD')); driver.verify_connectivity(); driver.close()" 2>/dev/null; then
    echo -e "${GREEN}✓ Python → Neo4j connection successful${NC}"
else
    echo -e "${RED}✗ Cannot connect to Neo4j from Python${NC}"
    exit 1
fi

# Run tests
echo ""
echo "=============================================================================="
echo "Running test suite..."
echo "=============================================================================="
echo ""

cd "$SCRIPT_DIR"

if python test_runner.py "$@"; then
    TEST_RESULT=0
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                       ║${NC}"
    echo -e "${GREEN}║            ✓✓✓ TEST SUITE COMPLETED SUCCESSFULLY ✓✓✓                 ║${NC}"
    echo -e "${GREEN}║                                                                       ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
else
    TEST_RESULT=1
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                                       ║${NC}"
    echo -e "${RED}║                    ✗✗✗ TEST SUITE FAILED ✗✗✗                         ║${NC}"
    echo -e "${RED}║                                                                       ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
fi

# Cleanup will happen automatically via trap
exit $TEST_RESULT
