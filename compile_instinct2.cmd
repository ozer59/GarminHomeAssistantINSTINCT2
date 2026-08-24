@echo off
setlocal

rem GarminHomeAssistantINSTINCT2 - build Instinct 2 PRG
rem Requires Garmin Connect IQ SDK installed and an existing developer_key.der

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
  echo Generate it once with the Monkey C VS Code extension or OpenSSL.
  pause
  exit /b 1
)

echo Building GarminHomeAssistant for Instinct 2...

"%SDK_BIN%\monkeyc.bat" ^
  -f "%SRC%monkey.jungle" ^
  -d instinct2 ^
  -o "%OUT%\HomeAssistant-instinct2.prg" ^
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
echo %OUT%\HomeAssistant-instinct2.prg
pause
