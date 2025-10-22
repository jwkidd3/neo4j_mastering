@echo off
echo ============================================================
echo Neo4j Mastering Course - Complete Cleanup
echo ============================================================
echo.

echo [1/4] Stopping and removing Neo4j container...
docker rm -f neo4j 2>nul
if %ERRORLEVEL% EQU 0 (
    echo   * Container removed successfully!
) else (
    echo   - Container doesn't exist or already removed
)

echo.
echo [2/4] Removing Neo4j image...
docker rmi neo4j:5.26.9-enterprise 2>nul
if %ERRORLEVEL% EQU 0 (
    echo   * Image removed successfully!
) else (
    echo   - Image doesn't exist or still in use
)

echo.
echo [3/4] Removing Docker volumes...
docker volume rm neo4j_data neo4j_logs neo4j_import 2>nul
if %ERRORLEVEL% EQU 0 (
    echo   * Docker volumes removed!
) else (
    echo   - No Docker volumes found
)

echo.
echo [4/4] Removing mapped volume directories...
if exist "%USERPROFILE%\neo4j" (
    echo   Removing %USERPROFILE%\neo4j...
    rmdir /s /q "%USERPROFILE%\neo4j"
    if %ERRORLEVEL% EQU 0 (
        echo   * Volume directories removed successfully!
    ) else (
        echo   ! Failed to remove volume directories
    )
) else (
    echo   - Volume directories don't exist
)

echo.
echo ============================================================
echo Cleanup complete!
echo ============================================================
echo.
echo All Neo4j data, logs, and configuration have been removed.
echo You can start fresh by running start-neo4j.bat
echo.
