@echo off
setlocal enabledelayedexpansion

echo =======================================================
echo Milvus URI Format Fix Tool
echo =======================================================

:: Get project root directory (one level up from tools)
cd /d "%~dp0.."
set "RUSLANAI_DIR=%CD%"

echo [INFO] Using project directory: %RUSLANAI_DIR%

:: Create fix_uri.py in the tools directory
echo import os, re, sys, logging > "%~dp0fix_uri.py"
echo logging.basicConfig(level=logging.INFO, format="%%%(asctime)s - %%%(levelname)s - %%%(message)s") >> "%~dp0fix_uri.py"
echo logger = logging.getLogger(__name__) >> "%~dp0fix_uri.py"
echo. >> "%~dp0fix_uri.py"
echo def check_uri_format(file_path): >> "%~dp0fix_uri.py"
echo     """Check the URI format in a file and output information about required fixes.""" >> "%~dp0fix_uri.py"
echo     if not os.path.exists(file_path): >> "%~dp0fix_uri.py"
echo         logger.error(f"File not found: {file_path}") >> "%~dp0fix_uri.py"
echo         return False >> "%~dp0fix_uri.py"
echo     with open(file_path, 'r', encoding='utf-8') as f: >> "%~dp0fix_uri.py"
echo         content = f.read() >> "%~dp0fix_uri.py"
echo     patterns = [ >> "%~dp0fix_uri.py"
echo         r'connect\(["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)', >> "%~dp0fix_uri.py"
echo         r'connect\(alias\s*=\s*["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)', >> "%~dp0fix_uri.py"
echo         r'def\s+__init__\([^,]+,\s*uri\s*:\s*str\s*=\s*["\']([^h][^t][^t][^p][^:][^/][^/][^:]+):(\d+)["\']' >> "%~dp0fix_uri.py"
echo     ] >> "%~dp0fix_uri.py"
echo     needs_fix = False >> "%~dp0fix_uri.py"
echo     for pattern in patterns: >> "%~dp0fix_uri.py"
echo         if re.search(pattern, content): >> "%~dp0fix_uri.py"
echo             needs_fix = True >> "%~dp0fix_uri.py"
echo             logger.info(f"Found incorrect URI format in {file_path}") >> "%~dp0fix_uri.py"
echo     correct_patterns = [ >> "%~dp0fix_uri.py"
echo         r'connect\(["\']default["\'],\s*uri\s*=\s*f?["\']http://[^"\']+["\']', >> "%~dp0fix_uri.py"
echo         r'connect\(alias\s*=\s*["\']default["\'],\s*uri\s*=\s*f?["\']http://[^"\']+["\']', >> "%~dp0fix_uri.py"
echo         r'def\s+__init__\([^,]+,\s*uri\s*:\s*str\s*=\s*["\']http://[^"\']+["\']' >> "%~dp0fix_uri.py"
echo     ] >> "%~dp0fix_uri.py"
echo     for pattern in correct_patterns: >> "%~dp0fix_uri.py"
echo         if re.search(pattern, content): >> "%~dp0fix_uri.py"
echo             logger.info(f"File already has correct URI format: {file_path}") >> "%~dp0fix_uri.py"
echo             return False >> "%~dp0fix_uri.py"
echo     return needs_fix >> "%~dp0fix_uri.py"
echo. >> "%~dp0fix_uri.py"
echo def fix_uri_format(file_path): >> "%~dp0fix_uri.py"
echo     """Fix Milvus URI format in file.""" >> "%~dp0fix_uri.py"
echo     if not os.path.exists(file_path): >> "%~dp0fix_uri.py"
echo         logger.error(f"File not found: {file_path}") >> "%~dp0fix_uri.py"
echo         return False >> "%~dp0fix_uri.py"
echo     with open(file_path, 'r', encoding='utf-8') as f: >> "%~dp0fix_uri.py"
echo         content = f.read() >> "%~dp0fix_uri.py"
echo     original_content = content >> "%~dp0fix_uri.py"
echo     patterns = [ >> "%~dp0fix_uri.py"
echo         (r'connect\(["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)', >> "%~dp0fix_uri.py"
echo          r'connect("default", uri=f"http://{\1}:{\2}")'), >> "%~dp0fix_uri.py"
echo         (r'connect\(alias\s*=\s*["\']default["\'],\s*host\s*=\s*([^,]+),\s*port\s*=\s*([^)]+)\)', >> "%~dp0fix_uri.py"
echo          r'connect(alias="default", uri=f"http://{\1}:{\2}")'), >> "%~dp0fix_uri.py"
echo         (r'def\s+__init__\([^,]+,\s*uri\s*:\s*str\s*=\s*["\']([^h][^t][^t][^p][^:][^/][^/][^:]+):(\d+)["\']', >> "%~dp0fix_uri.py"
echo          r'def __init__(self, uri: str = "http://\1:\2"') >> "%~dp0fix_uri.py"
echo     ] >> "%~dp0fix_uri.py"
echo     for pattern, replacement in patterns: >> "%~dp0fix_uri.py"
echo         content = re.sub(pattern, replacement, content) >> "%~dp0fix_uri.py"
echo     if content != original_content: >> "%~dp0fix_uri.py"
echo         logger.info(f"Fixing URI format in {file_path}") >> "%~dp0fix_uri.py"
echo         with open(file_path, 'w', encoding='utf-8') as f: >> "%~dp0fix_uri.py"
echo             f.write(content) >> "%~dp0fix_uri.py"
echo         logger.info(f"Fixed URI format in {file_path}") >> "%~dp0fix_uri.py"
echo         return True >> "%~dp0fix_uri.py"
echo     else: >> "%~dp0fix_uri.py"
echo         logger.info(f"No changes needed for {file_path}") >> "%~dp0fix_uri.py"
echo         return False >> "%~dp0fix_uri.py"
echo. >> "%~dp0fix_uri.py"
echo base_dir = r'%RUSLANAI_DIR%' >> "%~dp0fix_uri.py"
echo files_to_check = [ >> "%~dp0fix_uri.py"
echo     os.path.join(base_dir, "milvus_vector_store.py"), >> "%~dp0fix_uri.py"
echo     os.path.join(base_dir, "milvus_config.py"), >> "%~dp0fix_uri.py"
echo     os.path.join(base_dir, "test_milvus.py"), >> "%~dp0fix_uri.py"
echo     os.path.join(base_dir, "central_agent", "modules", "memory", "enhanced_memory_system.py") >> "%~dp0fix_uri.py"
echo ] >> "%~dp0fix_uri.py"
echo. >> "%~dp0fix_uri.py"
echo # Check files first >> "%~dp0fix_uri.py"
echo files_need_fix = [] >> "%~dp0fix_uri.py"
echo for file_path in files_to_check: >> "%~dp0fix_uri.py"
echo     if check_uri_format(file_path): >> "%~dp0fix_uri.py"
echo         files_need_fix.append(file_path) >> "%~dp0fix_uri.py"
echo. >> "%~dp0fix_uri.py"
echo if files_need_fix: >> "%~dp0fix_uri.py"
echo     logger.info(f"Found {len(files_need_fix)} files that need URI format fixes:") >> "%~dp0fix_uri.py"
echo     for file_path in files_need_fix: >> "%~dp0fix_uri.py"
echo         logger.info(f"  - {file_path}") >> "%~dp0fix_uri.py"
echo     logger.info("\nApplying fixes...") >> "%~dp0fix_uri.py"
echo     # Fix files >> "%~dp0fix_uri.py"
echo     files_fixed = 0 >> "%~dp0fix_uri.py"
echo     for file_path in files_need_fix: >> "%~dp0fix_uri.py"
echo         if fix_uri_format(file_path): >> "%~dp0fix_uri.py"
echo             files_fixed += 1 >> "%~dp0fix_uri.py"
echo     logger.info(f"\nFixed {files_fixed} files") >> "%~dp0fix_uri.py"
echo else: >> "%~dp0fix_uri.py"
echo     logger.info("\nAll files already have correct Milvus URI format") >> "%~dp0fix_uri.py"

:: Run the Python script to check and fix URI format
echo [INFO] Running URI format check and fix...
python "%~dp0fix_uri.py"

:: Clean up
echo [INFO] Cleaning up...
del "%~dp0fix_uri.py"

:: Test connection to Milvus
echo.
echo [INFO] Do you want to test connection to Milvus? (y/n)
set /p test_connection="> "

if /i "%test_connection%" == "y" (
    echo [INFO] Creating test script...
    echo import socket, time, sys, logging > "%~dp0test_milvus.py"
    echo logging.basicConfig(level=logging.INFO, format="%%%(asctime)s - %%%(levelname)s - %%%(message)s") >> "%~dp0test_milvus.py"
    echo logger = logging.getLogger(__name__) >> "%~dp0test_milvus.py"
    echo. >> "%~dp0test_milvus.py"
    echo def check_port_open(host="localhost", port=19530, timeout=2): >> "%~dp0test_milvus.py"
    echo     """Check if a port is open on the specified host.""" >> "%~dp0test_milvus.py"
    echo     sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) >> "%~dp0test_milvus.py"
    echo     sock.settimeout(timeout) >> "%~dp0test_milvus.py"
    echo     try: >> "%~dp0test_milvus.py"
    echo         result = sock.connect_ex((host, port)) >> "%~dp0test_milvus.py"
    echo         sock.close() >> "%~dp0test_milvus.py"
    echo         return result == 0 >> "%~dp0test_milvus.py"
    echo     except Exception as e: >> "%~dp0test_milvus.py"
    echo         logger.error(f"Error checking port: {e}") >> "%~dp0test_milvus.py"
    echo         return False >> "%~dp0test_milvus.py"
    echo. >> "%~dp0test_milvus.py"
    echo # Check if Milvus port is open >> "%~dp0test_milvus.py"
    echo if not check_port_open(port=19530): >> "%~dp0test_milvus.py"
    echo     logger.error("Milvus port (19530) is not open. Make sure Milvus server is running.") >> "%~dp0test_milvus.py"
    echo     logger.info("You can start Milvus with: docker run -d --name milvus_standalone -p 19530:19530 -p 9091:9091 milvusdb/milvus:v2.2.11") >> "%~dp0test_milvus.py"
    echo     sys.exit(1) >> "%~dp0test_milvus.py"
    echo. >> "%~dp0test_milvus.py"
    echo # Test connection with proper URI format >> "%~dp0test_milvus.py"
    echo try: >> "%~dp0test_milvus.py"
    echo     from pymilvus import connections, utility >> "%~dp0test_milvus.py"
    echo     logger.info("Testing connection to Milvus...") >> "%~dp0test_milvus.py"
    echo     uri = "http://localhost:19530" >> "%~dp0test_milvus.py"
    echo     logger.info(f"Connecting with URI: {uri}") >> "%~dp0test_milvus.py"
    echo     connections.connect("default", uri=uri, timeout=10.0) >> "%~dp0test_milvus.py"
    echo     logger.info("Successfully connected to Milvus!") >> "%~dp0test_milvus.py"
    echo     has_collection = utility.has_collection("test_collection") >> "%~dp0test_milvus.py" 
    echo     logger.info(f"Milvus response: test_collection {'exists' if has_collection else 'does not exist'}") >> "%~dp0test_milvus.py"
    echo     connections.disconnect("default") >> "%~dp0test_milvus.py"
    echo     logger.info("Successfully disconnected from Milvus") >> "%~dp0test_milvus.py"
    echo     logger.info("TEST PASSED") >> "%~dp0test_milvus.py"
    echo except ImportError: >> "%~dp0test_milvus.py"
    echo     logger.error("pymilvus not installed. Install with: pip install pymilvus") >> "%~dp0test_milvus.py"
    echo     sys.exit(1) >> "%~dp0test_milvus.py"
    echo except Exception as e: >> "%~dp0test_milvus.py"
    echo     logger.error(f"Error connecting to Milvus: {e}") >> "%~dp0test_milvus.py"
    echo     sys.exit(1) >> "%~dp0test_milvus.py"
    
    echo [INFO] Running connection test...
    python "%~dp0test_milvus.py"
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