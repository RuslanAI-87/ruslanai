# RuslanAI Memory System Alternative Test

## Overview

This alternative test script provides a simplified way to benchmark the memory system's basic operations even when there are issues with Python package installations. It's designed as a fallback solution when the main test suite encounters dependency problems.

## Key Features

- Uses only basic Python packages that are likely to be already installed
- Creates a minimal test environment structure
- Runs basic performance benchmarks for file I/O operations
- Generates simple performance metrics without complex dependencies
- Works even when sentence-transformers and other ML packages fail to import

## How to Use

### Option 1: Run the Batch Script

1. Double-click the `scripts\run_alternative_test.bat` file
2. Follow the menu prompts to:
   - Set up the test environment
   - Run performance benchmarks 
   - View results
   - Clean up temporary files

### Option 2: Run the Python Script Directly

```
python scripts\alternative_test.py
```

## Understanding the Results

The alternative test measures three basic operations:

1. **Write** - How quickly the system can create new memory files
2. **Read** - How quickly the system can retrieve memory records
3. **Search** - How quickly the system can find records matching specific criteria

Results are saved as JSON files in the `test_environment\benchmarks\results` directory.

## Limitations

Since this is a simplified test, it doesn't include:

- Vector embeddings or semantic search
- ChromaDB vector store operations
- Memory relevance testing
- Context restoration testing

These features require specific Python packages that might not be properly imported in your environment.

## Troubleshooting Python Package Issues

The main memory system test script is encountering issues with Python packages that are installed but can't be imported. This typically happens due to:

1. **Permission Issues** - Python can't access certain directories
2. **Path Problems** - Python is looking for packages in the wrong locations
3. **Environment Conflicts** - Multiple Python installations interfering with each other

To resolve these issues:

1. Try running the main script as administrator
2. Consider creating a fresh Python virtual environment
3. Manually install packages with admin privileges
4. Check if your antivirus is blocking Python package operations

## Next Steps

For a complete analysis of the memory system, we recommend resolving the package import issues. However, this alternative test provides valuable basic metrics in the meantime.

If you need further assistance, please reach out to the development team.