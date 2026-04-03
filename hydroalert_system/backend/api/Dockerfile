# HydroAlert API — Render deployment
#
# Build context MUST be the monorepo root `hydroalert_system/` (the directory that
# contains both `packages/` and `backend/api/`), because pubspec uses:
#   shared_models: path: ../../packages/shared_models
#
# On Render (github.com/King-Angelo/hydroalert_system):
#   Root Directory: hydroalert_system
#   Dockerfile Path: backend/api/Dockerfile
# If your Git root already contains backend/ + packages/ at top level, Root Directory: . (empty)

FROM dart:stable AS build

WORKDIR /app

RUN dart pub global activate dart_frog_cli
ENV PATH="${PATH}:/root/.pub-cache/bin"

# Context = hydroalert_system/
COPY packages/shared_models /app/packages/shared_models
COPY backend/api /app/backend/api

WORKDIR /app/backend/api
RUN dart pub get
RUN dart_frog build

WORKDIR /app/backend/api/build
RUN dart pub get
RUN dart compile exe bin/server.dart -o server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/backend/api/build/server /app/server
COPY --from=build /app/backend/api/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENV PORT=8080
CMD ["/entrypoint.sh"]
