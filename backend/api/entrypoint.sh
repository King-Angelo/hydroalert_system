#!/bin/sh
# If FIREBASE_SERVICE_ACCOUNT_JSON env var is set, write to file for Firebase Admin SDK
if [ -n "$FIREBASE_SERVICE_ACCOUNT_JSON" ]; then
  echo "$FIREBASE_SERVICE_ACCOUNT_JSON" > /tmp/sa.json
  export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
fi
exec /app/server
