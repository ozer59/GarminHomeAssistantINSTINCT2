@echo off
setlocal

rem HA Instinct - export an IQ package for Connect IQ Developer Dashboard/Beta.
rem Requires Garmin Connect IQ SDK and developer_key.der at project root.

set /p SDK_ROOT=<"%APPDATA%\Garmin\ConnectIQ\current-sdk.cfg"
if "%SDK_ROOT%"=="" (
  echo ERROR: Garmin Connect IQ SDK not found.
  pause
  exit /b 1
)

set SDK_BIN=%SDK_ROOT%\bin
set SRC=%~dp0
set OUT=%SRC%bin
set KEY=%SRC%developer_key.der

if not exist "%OUT%" mkdir "%OUT%"
if not exist "%KEY%" (
  echo ERROR: developer_key.der is missing in the project folder.
  pause
  exit /b 1
)

echo Exporting HA Instinct Connect IQ package...

"%SDK_BIN%\monkeyc.bat" ^
  -f "%SRC%monkey.jungle" ^
  -o "%OUT%\HA-Instinct.iq" ^
  -y "%KEY%" ^
  -e ^
  -w

if errorlevel 1 (
  echo.
  echo EXPORT FAILED.
  pause
  exit /b 1
)

echo.
echo EXPORT OK:
echo %OUT%\HA-Instinct.iq
pause
