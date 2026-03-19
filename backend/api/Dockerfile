# HydroAlert API - Render deployment
# Build stage
FROM dart:stable AS build

WORKDIR /app

RUN dart pub global activate dart_frog_cli
ENV PATH="${PATH}:/root/.pub-cache/bin"

COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart pub get --offline
RUN dart_frog build

WORKDIR /app/build
RUN dart pub get
RUN dart compile exe bin/server.dart -o server

# Run stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app/build/server /app/server
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENV PORT=8080
CMD ["/entrypoint.sh"]
