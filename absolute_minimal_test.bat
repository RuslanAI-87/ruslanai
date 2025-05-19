@echo off
echo This is a minimal test script
echo Directory: %CD%
echo PATH: %PATH%
echo.
echo Testing node availability...
where node
echo.
echo Testing Node.js version...
node --version
echo.
echo Testing JavaScript execution...
node -e "console.log('Simple JavaScript test works')"
echo.
echo If you see this message, basic Node.js is working.
echo.
pause