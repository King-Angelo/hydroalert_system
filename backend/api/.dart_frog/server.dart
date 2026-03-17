// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/index.dart' as index;
import '../routes/health.dart' as health;
import '../routes/v1/users/update-role.dart' as v1_users_update_role;
import '../routes/v1/users/soft-delete.dart' as v1_users_soft_delete;
import '../routes/v1/users/set-active-state.dart' as v1_users_set_active_state;
import '../routes/v1/shelters/update-status.dart' as v1_shelters_update_status;
import '../routes/v1/shelters/update-occupancy.dart' as v1_shelters_update_occupancy;
import '../routes/v1/shelters/update-capacity.dart' as v1_shelters_update_capacity;
import '../routes/v1/shelters/soft-delete.dart' as v1_shelters_soft_delete;
import '../routes/v1/reports/review.dart' as v1_reports_review;
import '../routes/v1/alerts/manual-override.dart' as v1_alerts_manual_override;

import '../routes/v1/_middleware.dart' as v1_middleware;

void main() async {
  final address = InternetAddress.tryParse('') ?? InternetAddress.anyIPv6;
  final port = int.tryParse(Platform.environment['PORT'] ?? '8080') ?? 8080;
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return serve(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..mount('/', (context) => buildHandler()(context))
    ..mount('/v1/users', (context) => buildV1UsersHandler()(context))
    ..mount('/v1/shelters', (context) => buildV1SheltersHandler()(context))
    ..mount('/v1/reports', (context) => buildV1ReportsHandler()(context))
    ..mount('/v1/alerts', (context) => buildV1AlertsHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/health', (context) => health.onRequest(context,))..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildV1UsersHandler() {
  final pipeline = const Pipeline().addMiddleware(v1_middleware.middleware);
  final router = Router()
    ..all('/set-active-state', (context) => v1_users_set_active_state.onRequest(context,))..all('/soft-delete', (context) => v1_users_soft_delete.onRequest(context,))..all('/update-role', (context) => v1_users_update_role.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildV1SheltersHandler() {
  final pipeline = const Pipeline().addMiddleware(v1_middleware.middleware);
  final router = Router()
    ..all('/soft-delete', (context) => v1_shelters_soft_delete.onRequest(context,))..all('/update-capacity', (context) => v1_shelters_update_capacity.onRequest(context,))..all('/update-occupancy', (context) => v1_shelters_update_occupancy.onRequest(context,))..all('/update-status', (context) => v1_shelters_update_status.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildV1ReportsHandler() {
  final pipeline = const Pipeline().addMiddleware(v1_middleware.middleware);
  final router = Router()
    ..all('/review', (context) => v1_reports_review.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildV1AlertsHandler() {
  final pipeline = const Pipeline().addMiddleware(v1_middleware.middleware);
  final router = Router()
    ..all('/manual-override', (context) => v1_alerts_manual_override.onRequest(context,));
  return pipeline.addHandler(router);
}

