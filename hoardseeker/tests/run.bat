@echo off
REM Hoardseeker test runner wrapper (cmd / PowerShell).
REM
REM Run with: tests\run.bat   (from inside the hoardseeker\ directory)
REM
REM See tests\run.sh for the rationale (handles the first-run --import
REM requirement so test_runner.gd can resolve cross-class typed exports).

REM Move to the directory containing project.godot regardless of cwd.
pushd "%~dp0\.."

echo ================================================================
echo  Importing project (builds class registry)...
echo ================================================================
godot --headless --import >nul 2>&1
echo.

echo ================================================================
echo  Running headless tests...
echo ================================================================
godot --headless --script tests/test_runner.gd
set EXIT_CODE=%ERRORLEVEL%

popd
exit /b %EXIT_CODE%
