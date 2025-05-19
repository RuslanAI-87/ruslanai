@echo off
cd /d C:\RuslanAI
echo Patching _background_audit method with batch_size parameter...

python patch_background_audit.py

echo.
echo Patch completed.
echo Now run patch_hierarchical_memory.bat to complete all patches.
pause