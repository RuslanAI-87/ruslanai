# Milvus URI Format Fix Tool

This tool helps fix the Milvus URI format in RuslanAI project files and verify the connection to Milvus.

## Usage

1. Open Command Prompt 
2. Navigate to the tools directory:
   ```
   cd C:\RuslanAI\tools
   ```
3. Run the script:
   ```
   fix_milvus_uri.bat
   ```

## What this tool does

1. Checks file paths for incorrect Milvus URI format:
   - `milvus_vector_store.py`
   - `milvus_config.py` 
   - `test_milvus.py`
   - `central_agent/modules/memory/enhanced_memory_system.py`

2. Automatically fixes incorrect URI formats:
   - Changes `connections.connect("default", host=HOST, port=PORT)` to `connections.connect("default", uri=f"http://{HOST}:{PORT}")`
   - Changes `connections.connect(alias="default", host=HOST, port=PORT)` to `connections.connect(alias="default", uri=f"http://{HOST}:{PORT}")`
   - Changes `def __init__(self, uri: str = "localhost:19530", ...)` to `def __init__(self, uri: str = "http://localhost:19530", ...)`

3. Optionally tests connection to Milvus server

4. Optionally runs the cognitive memory tests

## Requirements

- Python 3.6+
- pymilvus (`pip install pymilvus`)
- Docker with Milvus container (for connection testing)