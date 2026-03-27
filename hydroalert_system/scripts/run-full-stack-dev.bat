@echo off
setlocal EnableDelayedExpansion

REM Full local dev: Dart Frog HTTP API (8080) + admin web (Chrome, 8081).
REM Matches VS Code launch profile "admin_app: Chrome + local API (localhost:8080)".
REM
REM Optional: set HYDROADMIN_GOOGLE_MAPS_API_KEY in the environment before running
REM to avoid hardcoding; if unset, the SET line below is used (same as launch.json).
if not defined HYDROADMIN_GOOGLE_MAPS_API_KEY (
  set "HYDROADMIN_GOOGLE_MAPS_API_KEY=AIzaSyAnK7Btq9NJQYjiWS0C0BkrfdYYjoPJZ-M"
)

set "SCRIPT_DIR=%~dp0"
set "API_DIR=%SCRIPT_DIR%..\backend\api"
set "ADMIN_DIR=%SCRIPT_DIR%..\apps\admin_app"

echo [HydroAlert] Starting Dart Frog API: http://localhost:8080
start "HydroAlert Dart Frog" cmd /k "cd /d %API_DIR% && dart_frog dev"

echo [HydroAlert] Waiting a few seconds for the API to start...
timeout /t 4 /nobreak >nul

cd /d "%ADMIN_DIR%" || exit /b 1
echo [HydroAlert] Starting admin app: Chrome, http://localhost:8081
flutter run -d chrome ^
  --web-port=8081 ^
  --dart-define=HYDRO_ENV=dev ^
  --dart-define=HYDROADMIN_API_BASE_URL=http://localhost:8080 ^
  --dart-define=HYDROADMIN_GOOGLE_MAPS_API_KEY=!HYDROADMIN_GOOGLE_MAPS_API_KEY!

endlocal
exit /b 0
