# Run admin web against local Dart Frog API (default port 8080).
# Start the API first: cd backend/api && dart_frog dev
Set-Location $PSScriptRoot\..\apps\admin_app
flutter run -d chrome `
  --dart-define=HYDRO_ENV=dev `
  --dart-define=HYDROADMIN_API_BASE_URL=http://localhost:8080
