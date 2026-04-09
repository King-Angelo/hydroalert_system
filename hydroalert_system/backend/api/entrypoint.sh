#!/bin/sh
# Write service account JSON to a file for Firebase Admin SDK.
#
# Prefer FIREBASE_SERVICE_ACCOUNT_JSON_B64 (base64 of the raw .json file) on Render —
# multiline paste into FIREBASE_SERVICE_ACCOUNT_JSON often breaks JSON (literal newlines
# inside "private_key" → FormatException: Control character in string).
#
# Generate:  base64 -w0 < service-account.json   (GNU/Linux; macOS: base64 -i service-account.json | tr -d '\n')
# Or minify: jq -c . service-account.json  and paste that single line into FIREBASE_SERVICE_ACCOUNT_JSON.

if [ -n "$FIREBASE_SERVICE_ACCOUNT_JSON_B64" ]; then
  if ! printf '%s' "$FIREBASE_SERVICE_ACCOUNT_JSON_B64" | base64 -d > /tmp/sa.json 2>/dev/null; then
    echo "entrypoint: FIREBASE_SERVICE_ACCOUNT_JSON_B64 is not valid base64" >&2
    exit 1
  fi
  export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
elif [ -n "$FIREBASE_SERVICE_ACCOUNT_JSON" ]; then
  printf '%s' "$FIREBASE_SERVICE_ACCOUNT_JSON" > /tmp/sa.json
  export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
fi
exec /app/server
