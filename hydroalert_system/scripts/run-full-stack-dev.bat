@echo off
setlocal EnableDelayedExpansion

REM Full local dev: Dart Frog HTTP API (8080) + admin web (Chrome, 8081).
REM Mirrors launch profile "admin_app: Chrome + local API (localhost:8080)".
REM
REM Dart compile-time defines (override by setting env vars before running):
REM   HYDRO_ENV                      (default: dev)
REM   HYDROADMIN_API_BASE_URL        (default: http://localhost:8080)
REM   HYDROADMIN_GOOGLE_MAPS_API_KEY (defaults below if unset; set to empty string for mock map)
REM
REM Extra flutter args (e.g. more --dart-define=KEY=value):
REM   run-full-stack-dev.bat --dart-define=CUSTOM_FLAG=1

if not defined HYDRO_ENV (
  set "HYDRO_ENV=dev"
)
if not defined HYDROADMIN_API_BASE_URL (
  set "HYDROADMIN_API_BASE_URL=http://localhost:8080"
)

REM Default Maps key for local dev only if unset (same as .vscode/launch.json); prefer env or User secrets for CI.
if not defined HYDROADMIN_GOOGLE_MAPS_API_KEY (
  set "HYDROADMIN_GOOGLE_MAPS_API_KEY=AIzaSyAnK7Btq9NJQYjiWS0C0BkrfdYYjoPJZ-M"
)

set "SCRIPT_DIR=%~dp0"
set "API_DIR=%SCRIPT_DIR%..\backend\api"
set "ADMIN_DIR=%SCRIPT_DIR%..\apps\admin_app"
set "MAPS_ARG=--dart-define=HYDROADMIN_GOOGLE_MAPS_API_KEY=!HYDROADMIN_GOOGLE_MAPS_API_KEY!"

echo [HydroAlert] Dart defines: HYDRO_ENV=!HYDRO_ENV!  API=!HYDROADMIN_API_BASE_URL!
if "!HYDROADMIN_GOOGLE_MAPS_API_KEY!"=="" (
  echo [HydroAlert] Google Maps: empty key — situation map uses mock PNG
) else (
  echo [HydroAlert] Google Maps: HYDROADMIN_GOOGLE_MAPS_API_KEY dart-define will be passed
)

echo [HydroAlert] Starting Dart Frog API: http://localhost:8080
start "HydroAlert Dart Frog" cmd /k "cd /d %API_DIR% && dart_frog dev"

echo [HydroAlert] Waiting a few seconds for the API to start...
timeout /t 4 /nobreak >nul

cd /d "%ADMIN_DIR%" || exit /b 1
echo [HydroAlert] Starting admin app: Chrome, http://localhost:8081

set "FLUTTER_DEFINES=--dart-define=HYDRO_ENV=!HYDRO_ENV! --dart-define=HYDROADMIN_API_BASE_URL=!HYDROADMIN_API_BASE_URL!"
if not "!HYDROADMIN_GOOGLE_MAPS_API_KEY!"=="" (
  set "FLUTTER_DEFINES=!FLUTTER_DEFINES! !MAPS_ARG!"
)

flutter run -d chrome --web-port=8081 !FLUTTER_DEFINES! %*

endlocal
exit /b 0
