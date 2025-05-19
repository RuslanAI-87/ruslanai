@echo off
cd /d C:\RuslanAI
echo ===================================================
echo Applying all fixes to cognitive memory system
echo ===================================================

echo Step 1: Installing optimized packages...
call fixed_install_vector_optimizations.bat

echo Step 2: Applying dialog methods patch...
python fixed_patch_hierarchical_memory.py

echo Step 3: Applying background audit patch...
python fixed_patch_background_audit.py

echo Step 4: Testing GPU configuration...
python test_gpu_availability.py

echo ===================================================
echo All fixes have been applied!
echo Now run test_cognitive_memory.bat to verify the system.
echo ===================================================
pause