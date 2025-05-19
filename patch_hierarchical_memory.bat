@echo off
cd /d C:\RuslanAI
echo Patching HierarchicalMemory with dialog methods...

python patch_hierarchical_memory.py

echo.
echo Patch completed.
echo Now run test_cognitive_memory.bat to test the implementation.
pause