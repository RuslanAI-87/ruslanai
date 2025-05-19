@echo off
cd /d C:\RuslanAI
echo ===================================================
echo Cognitive Memory System Fixes and Optimization
echo ===================================================

echo Step 1: Install optimized vector storage components...
call install_vector_optimizations.bat

echo Step 2: Fix _background_audit method...
call patch_background_audit.bat

echo Step 3: Add dialog methods to HierarchicalMemory...
call patch_hierarchical_memory.bat

echo Step 4: Test GPU availability...
python test_gpu_availability.py

echo Step 5: Run cognitive memory system tests...
call test_cognitive_memory.bat

echo ===================================================
echo All fixes and tests completed!
echo If you still encounter issues, contact support.
echo ===================================================
pause