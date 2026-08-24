@echo off
setlocal

rem HA Instinct - build Instinct 2 PRG
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

echo Building HA Instinct for Instinct 2...

"%SDK_BIN%\monkeyc.bat" ^
  -f "%SRC%monkey.jungle" ^
  -d instinct2 ^
  -o "%OUT%\HA-Instinct-instinct2.prg" ^
  -y "%KEY%" ^
  -w

if errorlevel 1 (
  echo.
  echo BUILD FAILED.
  pause
  exit /b 1
)

echo.
echo BUILD OK:
echo %OUT%\HA-Instinct-instinct2.prg
pause
