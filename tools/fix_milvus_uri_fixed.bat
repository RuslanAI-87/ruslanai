@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo Milvus URI Format Fix Tool
echo =======================================================

:: Get project root directory (one level up from tools)
cd /d "%~dp0.."
set "RUSLANAI_DIR=%CD%"

echo [INFO] Using project directory: %RUSLANAI_DIR%

:: Create Python script directly
(
echo import os, re, sys, logging
echo logging.basicConfig(level=logging.INFO, format='%%(asctime)s - %%(levelname)s - %%(message)s'^)
echo logger = logging.getLogger(__name__^)
echo.
echo def check_uri_format(file_path^):
echo     """Check the URI format in a file and output information about required fixes."""
echo     if not os.path.exists(file_path^):
echo         logger.error(f"File not found: {file_path}"^)
echo         return False
echo     with open(file_path, 'r', encoding='utf-8'^) as f:
echo         content = f.read(^)
echo     patterns = [
echo         r'connect\(["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)',
echo         r'connect\(alias\s*=\s*["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)',
echo         r'def\s+__init__\([^,]+,\s*uri\s*:\s*str\s*=\s*["\']([^h][^t][^t][^p][^:][^/][^/][^:]+):(\d+)["\']'
echo     ]
echo     needs_fix = False
echo     for pattern in patterns:
echo         if re.search(pattern, content^):
echo             needs_fix = True
echo             logger.info(f"Found incorrect URI format in {file_path}"^)
echo     correct_patterns = [
echo         r'connect\(["\']default["\'],\s*uri\s*=\s*f?["\']http://[^"\']+["\']',
echo         r'connect\(alias\s*=\s*["\']default["\'],\s*uri\s*=\s*f?["\']http://[^"\']+["\']',
echo         r'def\s+__init__\([^,]+,\s*uri\s*:\s*str\s*=\s*["\']http://[^"\']+["\']'
echo     ]
echo     for pattern in correct_patterns:
echo         if re.search(pattern, content^):
echo             logger.info(f"File already has correct URI format: {file_path}"^)
echo             return False
echo     return needs_fix
echo.
echo def fix_uri_format(file_path^):
echo     """Fix Milvus URI format in file."""
echo     if not os.path.exists(file_path^):
echo         logger.error(f"File not found: {file_path}"^)
echo         return False
echo     with open(file_path, 'r', encoding='utf-8'^) as f:
echo         content = f.read(^)
echo     original_content = content
echo     patterns = [
echo         (r'connect\(["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)',
echo          r'connect("default", uri=f"http://{\1}:{\2}"^)'^),
echo         (r'connect\(alias\s*=\s*["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)',
echo          r'connect(alias="default", uri=f"http://{\1}:{\2}"^)'^),
echo         (r'def\s+__init__\([^,]+,\s*uri\s*:\s*str\s*=\s*["\']([^h][^t][^t][^p][^:][^/][^/][^:]+):(\d+)["\']',
echo          r'def __init__(self, uri: str = "http://\1:\2"'^)
echo     ]
echo     for pattern, replacement in patterns:
echo         content = re.sub(pattern, replacement, content^)
echo     if content != original_content:
echo         logger.info(f"Fixing URI format in {file_path}"^)
echo         with open(file_path, 'w', encoding='utf-8'^) as f:
echo             f.write(content^)
echo         logger.info(f"Fixed URI format in {file_path}"^)
echo         return True
echo     else:
echo         logger.info(f"No changes needed for {file_path}"^)
echo         return False
echo.
echo base_dir = r'%RUSLANAI_DIR%'
echo files_to_check = [
echo     os.path.join(base_dir, "milvus_vector_store.py"^),
echo     os.path.join(base_dir, "milvus_config.py"^),
echo     os.path.join(base_dir, "test_milvus.py"^),
echo     os.path.join(base_dir, "central_agent", "modules", "memory", "enhanced_memory_system.py"^)
echo ]
echo.
echo # Check files first
echo files_need_fix = []
echo for file_path in files_to_check:
echo     if check_uri_format(file_path^):
echo         files_need_fix.append(file_path^)
echo.
echo if files_need_fix:
echo     logger.info(f"Found {len(files_need_fix^)} files that need URI format fixes:"^)
echo     for file_path in files_need_fix:
echo         logger.info(f"  - {file_path}"^)
echo     logger.info("\nApplying fixes..."^)
echo     # Fix files
echo     files_fixed = 0
echo     for file_path in files_need_fix:
echo         if fix_uri_format(file_path^):
echo             files_fixed += 1
echo     logger.info(f"\nFixed {files_fixed} files"^)
echo else:
echo     logger.info("\nAll files already have correct Milvus URI format"^)
) > "%~dp0fix_uri.py"

:: Run the Python script to check and fix URI format
echo [INFO] Running URI format check and fix...
python "%~dp0fix_uri.py"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to check/fix URI format.
    del "%~dp0fix_uri.py"
    exit /b 1
)

:: Clean up
echo [INFO] Cleaning up...
del "%~dp0fix_uri.py"

:: Test connection to Milvus
echo.
echo [INFO] Do you want to test connection to Milvus? (y/n)
set /p test_connection="> "

if /i "%test_connection%" == "y" (
    echo [INFO] Creating test script...
    (
    echo import socket, time, sys, logging
    echo logging.basicConfig(level=logging.INFO, format='%%(asctime)s - %%(levelname)s - %%(message)s'^)
    echo logger = logging.getLogger(__name__^)
    echo.
    echo def check_port_open(host="localhost", port=19530, timeout=2^):
    echo     """Check if a port is open on the specified host."""
    echo     sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM^)
    echo     sock.settimeout(timeout^)
    echo     try:
    echo         result = sock.connect_ex((host, port^)^)
    echo         sock.close(^)
    echo         return result == 0
    echo     except Exception as e:
    echo         logger.error(f"Error checking port: {e}"^)
    echo         return False
    echo.
    echo # Check if Milvus port is open
    echo if not check_port_open(port=19530^):
    echo     logger.error("Milvus port (19530^) is not open. Make sure Milvus server is running."^)
    echo     logger.info("You can start Milvus with: docker run -d --name milvus_standalone -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.2.11"^)
    echo     sys.exit(1^)
    echo.
    echo # Test connection with proper URI format
    echo try:
    echo     from pymilvus import connections, utility
    echo     logger.info("Testing connection to Milvus..."^)
    echo     uri = "http://localhost:19530"
    echo     logger.info(f"Connecting with URI: {uri}"^)
    echo     connections.connect("default", uri=uri, timeout=10.0^)
    echo     logger.info("Successfully connected to Milvus!"^)
    echo     has_collection = utility.has_collection("test_collection"^)
    echo     logger.info(f"Milvus response: test_collection {'exists' if has_collection else 'does not exist'}"^)
    echo     connections.disconnect("default"^)
    echo     logger.info("Successfully disconnected from Milvus"^)
    echo     logger.info("TEST PASSED"^)
    echo except ImportError:
    echo     logger.error("pymilvus not installed. Install with: pip install pymilvus"^)
    echo     sys.exit(1^)
    echo except Exception as e:
    echo     logger.error(f"Error connecting to Milvus: {e}"^)
    echo     sys.exit(1^)
    ) > "%~dp0test_milvus.py"
    
    echo [INFO] Running connection test...
    python "%~dp0test_milvus.py"
    if %errorlevel% neq 0 (
        echo [ERROR] Milvus connection test failed.
        del "%~dp0test_milvus.py"
        exit /b 1
    )
    del "%~dp0test_milvus.py"
)

echo.
echo [INFO] Do you want to run the cognitive memory test? (y/n)
set /p run_test="> "

if /i "%run_test%" == "y" (
    cd %RUSLANAI_DIR%
    echo [INFO] Running test_cognitive_memory.py...
    python test_cognitive_memory.py
)

echo.
echo [INFO] Process completed successfully.
echo =======================================================

endlocal