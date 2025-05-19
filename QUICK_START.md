# RuslanAI Memory System - Test Environment Quick Start

## Prerequisites

Ensure you have the following installed:
- Python 3.6+ with pip

## Simplest Method - All-in-One Script

For the easiest experience, run the all-in-one test script that guides you through the entire process:

```
scripts\test_memory_system.bat
```

This interactive script will:
1. Check and install dependencies
2. Set up the test environment
3. Generate test data
4. Run benchmarks
5. Show results

## Manual Step-by-Step Process

### Step 1: Check and Install Dependencies

Run the dependency check script first:

```
scripts\check_python_deps.bat
```

This will check for and help install all required Python packages, including:
- numpy
- pandas
- matplotlib
- sentence-transformers
- chromadb
- scikit-learn
- tqdm
- psutil
- torch
- pytest

### Step 2: Set Up the Test Environment

Run the setup script to create an isolated test environment:

```
scripts\setup_test_environment.bat
```

This script will:
1. Create all necessary directories
2. Copy memory files and vector store data
3. Copy the source code of the memory system
4. Initialize the test environment

### Step 3: Generate Test Data

Generate test data for benchmarks:

```
python memory_test_environment.py --generate small
```

Available data sizes:
- `small` - 1,000 records (quick testing)
- `medium` - 10,000 records
- `large` - 100,000 records (comprehensive testing)

### Step 4: Run Benchmarks

Run specific benchmarks:

```
python memory_test_environment.py --run --scenarios performance
```

Or use the interactive script to select tests:

```
scripts\run_memory_benchmarks.bat
```

Available benchmark scenarios:
- `performance` - Measures speed of memory operations
- `relevance` - Evaluates search accuracy and completeness
- `context_restoration` - Tests dialog context recovery
- `all` - Runs all benchmarks

### Step 5: View Results

Results are saved in:
```
C:\RuslanAI\test_environment\benchmarks\results\
```

Two types of files are generated:
- JSON files with detailed metrics
- HTML reports with tables and charts

## Troubleshooting

If you encounter any issues:

1. **Python not found**
   - Ensure Python is in your PATH environment variable
   - Verify with `python --version` in a command prompt

2. **Import errors**
   - Run `scripts\check_python_deps.bat` to install missing packages
   - Make sure pip is up to date with `python -m pip install --upgrade pip`

3. **File not found errors**
   - Ensure you're running scripts from the RuslanAI root directory
   - Check that all paths in .bat files match your installation

4. **Permission errors**
   - Run Command Prompt or PowerShell as Administrator
   - Ensure antivirus software isn't blocking file creation

5. **Encoding problems in Windows console**
   - The scripts use UTF-8 encoding (code page 65001)
   - If you see garbled text, try running in PowerShell instead of CMD

## Additional Information

For detailed documentation, refer to:
```
C:\RuslanAI\MEMORY_TEST_ENVIRONMENT.md
```