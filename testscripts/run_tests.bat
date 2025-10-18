@echo off
REM ##############################################################################
REM Neo4j Mastering Course - Comprehensive Test Runner Script (Windows)
REM
REM This script provides a complete isolated test environment:
REM 1. Checks/installs Docker environment
REM 2. Creates and starts Neo4j Enterprise container (exact same config as setup)
REM 3. Creates temporary Python virtual environment
REM 4. Installs all required packages
REM 5. Runs the comprehensive test suite for all 17 labs
REM 6. Cleans up everything (Python env, Docker container, Docker image, volumes)
REM ##############################################################################

setlocal enabledelayedexpansion

REM Configuration - EXACT SAME AS SETUP SCRIPT
set NEO4J_VERSION=5.26.9-enterprise
set NEO4J_IMAGE=neo4j:!NEO4J_VERSION!
set NEO4J_CONTAINER=neo4j-test-%RANDOM%
set NEO4J_PASSWORD=password
set NEO4J_DATABASE=insurance
set APOC_VERSION=5.26.9
set APOC_JAR=apoc-!APOC_VERSION!-core.jar
set APOC_URL=https://github.com/neo4j/apoc/releases/download/!APOC_VERSION!/!APOC_JAR!

REM Script directory
set SCRIPT_DIR=%~dp0
set VENV_DIR=%SCRIPT_DIR%.test_venv

REM Temporary directories for Neo4j volumes
set TEMP_BASE=%TEMP%\neo4j-test-%RANDOM%
set NEO4J_DATA_DIR=%TEMP_BASE%\data
set NEO4J_LOGS_DIR=%TEMP_BASE%\logs
set NEO4J_IMPORT_DIR=%TEMP_BASE%\import

REM Track what needs cleanup
set CREATED_CONTAINER=false
set CREATED_VENV=false
set PULLED_IMAGE=false
set CREATED_TEMP_DIRS=false

echo ==============================================================================
echo Neo4j Mastering Course - Comprehensive Test Suite
echo ==============================================================================
echo This script will create an isolated test environment and clean up everything
echo when complete (Docker container, image, and Python environment).
echo Configuration matches the course setup script exactly.
echo ==============================================================================
echo.

REM Check if Docker is installed
echo [94mChecking Docker installation...[0m
docker --version >nul 2>&1
if errorlevel 1 (
    echo [91m× Docker is not installed[0m
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo [92m√ Docker is installed[0m

REM Check if Docker daemon is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [91m× Docker daemon is not running[0m
    echo Please start Docker Desktop
    pause
    exit /b 1
)
echo [92m√ Docker daemon is running[0m

REM Check if Python is installed
echo.
echo [94mChecking Python installation...[0m
python --version >nul 2>&1
if errorlevel 1 (
    echo [91m× Python is not installed[0m
    echo Please install Python 3.8 or higher
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo [92m√ Python !PYTHON_VERSION! is installed[0m

REM Create temporary directories for Neo4j volumes
echo.
echo [94mCreating temporary directories for Neo4j data...[0m
mkdir "!NEO4J_DATA_DIR!" "!NEO4J_LOGS_DIR!" "!NEO4J_IMPORT_DIR!" 2>nul
set CREATED_TEMP_DIRS=true
echo [92m√ Temporary directories created[0m

REM Set up Neo4j Docker environment
echo.
echo ==============================================================================
echo Setting up Neo4j Docker environment...
echo ==============================================================================
echo.

REM Check if Neo4j image exists locally
docker image inspect !NEO4J_IMAGE! >nul 2>&1
if errorlevel 1 (
    echo [94mPulling Neo4j Enterprise image (!NEO4J_IMAGE!)...[0m
    echo This may take a few minutes...
    docker pull !NEO4J_IMAGE!
    if errorlevel 1 (
        echo [91m× Failed to pull Neo4j image[0m
        pause
        goto cleanup
    )
    echo [92m√ Neo4j image pulled successfully[0m
    set PULLED_IMAGE=true
) else (
    echo [92m√ Neo4j image already exists locally[0m
)

REM Create and start Neo4j container - EXACT SAME CONFIG AS SETUP SCRIPT
echo.
echo [94mCreating Neo4j container (!NEO4J_CONTAINER!)...[0m
echo Using identical configuration to course setup script
docker run -d ^
    --name !NEO4J_CONTAINER! ^
    -p 7474:7474 ^
    -p 7687:7687 ^
    -v "!NEO4J_DATA_DIR!:/data" ^
    -v "!NEO4J_LOGS_DIR!:/logs" ^
    -v "!NEO4J_IMPORT_DIR!:/var/lib/neo4j/import" ^
    --env NEO4J_AUTH=neo4j/!NEO4J_PASSWORD! ^
    --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes ^
    !NEO4J_IMAGE! >nul 2>&1

if errorlevel 1 (
    echo [91m× Failed to create Neo4j container[0m
    pause
    goto cleanup
)
echo [92m√ Neo4j container created and started[0m
set CREATED_CONTAINER=true

REM Install APOC plugin - EXACT SAME METHOD AS SETUP SCRIPT
echo.
echo [94mInstalling APOC plugin (!APOC_JAR!)...[0m
docker exec !NEO4J_CONTAINER! sh -c "sleep 5 && wget -O /var/lib/neo4j/plugins/!APOC_JAR! !APOC_URL!" >nul 2>&1
if errorlevel 1 (
    echo [91m× Failed to download APOC plugin[0m
    pause
    goto cleanup
)
echo [92m√ APOC plugin downloaded[0m

REM Restart Neo4j to load plugin
echo [94mRestarting Neo4j to load APOC plugin...[0m
docker restart !NEO4J_CONTAINER! >nul 2>&1
echo [92m√ Neo4j restarted[0m

REM Wait for Neo4j to be ready after restart
echo [94mWaiting for Neo4j to be ready...[0m
set TIMEOUT=120
set ELAPSED=0
set READY=false

:wait_loop
if !ELAPSED! geq !TIMEOUT! goto wait_timeout

docker exec !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! "RETURN 1" >nul 2>&1
if not errorlevel 1 (
    set READY=true
    goto wait_done
)

timeout /t 2 /nobreak >nul
set /a ELAPSED=!ELAPSED!+2
echo|set /p=.
goto wait_loop

:wait_timeout
echo.
echo [91m× Neo4j failed to start within !TIMEOUT! seconds[0m
pause
goto cleanup

:wait_done
echo.
echo [92m√ Neo4j is ready[0m

REM Verify APOC is loaded
echo [94mVerifying APOC plugin is loaded...[0m
docker exec !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! "RETURN apoc.version()" >nul 2>&1
if errorlevel 1 (
    echo [93m⚠ APOC verification skipped (may not be critical)[0m
) else (
    echo [92m√ APOC plugin verified[0m
)

REM Create insurance database
echo [94mCreating insurance database...[0m
docker exec !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! "CREATE DATABASE !NEO4J_DATABASE! IF NOT EXISTS" >nul 2>&1
if errorlevel 1 (
    echo [93m⚠ Database may already exist (continuing...)[0m
) else (
    echo [92m√ Insurance database created[0m
)

REM Wait for database to be ready
timeout /t 3 /nobreak >nul

REM Verify database connection
echo [94mVerifying database connection...[0m
docker exec !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! -d !NEO4J_DATABASE! "RETURN 1" >nul 2>&1
if errorlevel 1 (
    echo [91m× Cannot connect to insurance database[0m
    pause
    goto cleanup
)
echo [92m√ Database connection verified[0m

REM Load lab data for testing
echo.
echo [94mLoading lab data into database...[0m

REM Load labs 1-8 sequentially (each builds on the previous)
echo Loading foundation data (Labs 1-8)...
for /L %%i in (1,1,8) do (
    set LAB_NUM=0%%i
    set LAB_NUM=!LAB_NUM:~-2!
    set DATA_FILE=%SCRIPT_DIR%..\data\lab_!LAB_NUM!_data_reload.cypher

    if not exist "!DATA_FILE!" (
        echo [91m× Lab !LAB_NUM! data file not found: !DATA_FILE![0m
        pause
        goto cleanup
    )

    echo|set /p="  Loading Lab !LAB_NUM!... "
    set ERROR_LOG=%TEMP%\neo4j_error_!RANDOM!.txt
    docker exec -i !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! -d !NEO4J_DATABASE! < "!DATA_FILE!" >nul 2>"!ERROR_LOG!"
    if errorlevel 1 (
        echo [91m× Failed[0m
        echo [91m× Failed to load Lab !LAB_NUM! foundation data[0m
        echo.
        echo [93mError details:[0m
        type "!ERROR_LOG!"
        del "!ERROR_LOG!" 2>nul
        pause
        goto cleanup
    )
    del "!ERROR_LOG!" 2>nul
    echo [92m√[0m
)
echo [92m√ Labs 1-8 foundation loaded successfully[0m

REM Then load Lab 17 advanced features (Labs 9-17)
set DATA_FILE_17=%SCRIPT_DIR%..\data\lab_17_data_reload.cypher
if exist "!DATA_FILE_17!" (
    echo Loading Lab 17 advanced features (Labs 9-17)...
    set ERROR_LOG=%TEMP%\neo4j_lab17_error_!RANDOM!.txt
    docker exec -i !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! -d !NEO4J_DATABASE! < "!DATA_FILE_17!" >nul 2>"!ERROR_LOG!"
    if errorlevel 1 (
        echo [91m× Failed to load Lab 17 advanced features[0m
        echo.
        echo [93mError details:[0m
        type "!ERROR_LOG!"
        del "!ERROR_LOG!" 2>nul
        pause
        goto cleanup
    )
    del "!ERROR_LOG!" 2>nul
    echo [92m√ Lab 17 advanced features loaded[0m

    REM Verify complete data was loaded
    for /f "tokens=*" %%a in ('docker exec !NEO4J_CONTAINER! cypher-shell -u neo4j -p !NEO4J_PASSWORD! -d !NEO4J_DATABASE! --format plain "MATCH (n) RETURN count(n) as count" 2^>nul ^| findstr /r "[0-9]"') do set NODE_COUNT=%%a
    echo [92m√ Complete database loaded with !NODE_COUNT! nodes[0m
) else (
    echo [91m× Lab 17 data file not found: !DATA_FILE_17![0m
    pause
    goto cleanup
)

REM Set up Python environment
echo.
echo ==============================================================================
echo Setting up Python test environment...
echo ==============================================================================
echo.

REM Create virtual environment
echo [94mCreating Python virtual environment...[0m
python -m venv "!VENV_DIR!"
if errorlevel 1 (
    echo [91m× Failed to create virtual environment[0m
    pause
    goto cleanup
)
echo [92m√ Virtual environment created[0m
set CREATED_VENV=true

REM Activate virtual environment
echo [94mActivating virtual environment...[0m
call "!VENV_DIR!\Scripts\activate.bat"
if errorlevel 1 (
    echo [91m× Failed to activate virtual environment[0m
    pause
    goto cleanup
)
echo [92m√ Virtual environment activated[0m

REM Upgrade pip
echo [94mUpgrading pip...[0m
python -m pip install --quiet --upgrade pip
if errorlevel 1 (
    echo [91m× Failed to upgrade pip[0m
    pause
    goto cleanup
)
echo [92m√ pip upgraded[0m

REM Install requirements
echo [94mInstalling test dependencies...[0m
if not exist "%SCRIPT_DIR%requirements.txt" (
    echo [91m× requirements.txt not found[0m
    pause
    goto cleanup
)

python -m pip install --quiet -r "%SCRIPT_DIR%requirements.txt"
if errorlevel 1 (
    echo [91m× Failed to install dependencies[0m
    pause
    goto cleanup
)
echo [92m√ Dependencies installed successfully[0m

REM Verify Neo4j connection from Python
echo.
echo [94mVerifying Python → Neo4j connection...[0m
python -c "from neo4j import GraphDatabase; driver = GraphDatabase.driver('neo4j://localhost:7687', auth=('neo4j', '!NEO4J_PASSWORD!')); driver.verify_connectivity(); driver.close()" 2>nul
if errorlevel 1 (
    echo [91m× Cannot connect to Neo4j from Python[0m
    pause
    goto cleanup
)
echo [92m√ Python → Neo4j connection successful[0m

REM Run tests
echo.
echo ==============================================================================
echo Running test suite...
echo ==============================================================================
echo.

cd /d "%SCRIPT_DIR%"

python test_runner.py %*
set TEST_RESULT=!errorlevel!

REM Deactivate virtual environment
call deactivate 2>nul

echo.
if !TEST_RESULT! equ 0 (
    echo [92m╔═══════════════════════════════════════════════════════════════════════╗[0m
    echo [92m║                                                                       ║[0m
    echo [92m║            ✓✓✓ TEST SUITE COMPLETED SUCCESSFULLY ✓✓✓                 ║[0m
    echo [92m║                                                                       ║[0m
    echo [92m╚═══════════════════════════════════════════════════════════════════════╝[0m
) else (
    echo [91m╔═══════════════════════════════════════════════════════════════════════╗[0m
    echo [91m║                                                                       ║[0m
    echo [91m║                    ✗✗✗ TEST SUITE FAILED ✗✗✗                         ║[0m
    echo [91m║                                                                       ║[0m
    echo [91m╚═══════════════════════════════════════════════════════════════════════╝[0m
)

:cleanup
echo.
echo ==============================================================================
echo [96mCleaning up test environment...[0m
echo ==============================================================================

REM Remove Python virtual environment
if exist "!VENV_DIR!" (
    echo [94mRemoving Python virtual environment...[0m
    rmdir /s /q "!VENV_DIR!"
    echo [92m√ Python environment removed[0m
)

REM Stop and remove Neo4j container
if "!CREATED_CONTAINER!"=="true" (
    echo [94mStopping Neo4j container...[0m
    docker stop !NEO4J_CONTAINER! >nul 2>&1
    echo [92m√ Container stopped[0m

    echo [94mRemoving Neo4j container...[0m
    docker rm !NEO4J_CONTAINER! >nul 2>&1
    echo [92m√ Container removed[0m
)

REM Remove temporary directories
if "!CREATED_TEMP_DIRS!"=="true" (
    if exist "!TEMP_BASE!" (
        echo [94mRemoving temporary Neo4j directories...[0m
        rmdir /s /q "!TEMP_BASE!"
        echo [92m√ Temporary directories removed[0m
    )
)

REM Remove Neo4j image if we pulled it
if "!PULLED_IMAGE!"=="true" (
    echo [94mRemoving Neo4j image (!NEO4J_IMAGE!)...[0m
    docker rmi !NEO4J_IMAGE! >nul 2>&1
    echo [92m√ Image removed[0m
)

echo [92m✓✓✓ Cleanup complete[0m
echo.

if !TEST_RESULT! equ 0 (
    exit /b 0
) else (
    pause
    exit /b 1
)
