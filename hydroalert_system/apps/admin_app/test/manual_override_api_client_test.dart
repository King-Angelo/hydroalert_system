import 'package:admin_app/features/alerts/data/manual_override_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ManualOverrideApiClient', () {
    test('propagates ClientException on network failure', () async {
      final mock = MockClient((request) async {
        throw http.ClientException('connection refused', request.url);
      });
      final client = ManualOverrideApiClient(
        baseUrl: 'http://localhost:8080',
        getIdToken: () async => 'test-token',
        httpClient: mock,
      );
      addTearDown(client.close);

      expect(
        () => client.sendManualOverride(
          severity: 'Watch',
          message: 'test',
          targetZone: 'Zone-A',
        ),
        throwsA(isA<http.ClientException>()),
      );
    });

    test('throws StateError when no ID token', () async {
      final mock = MockClient((_) async => http.Response('', 500));
      final client = ManualOverrideApiClient(
        baseUrl: 'http://localhost:8080',
        getIdToken: () async => null,
        httpClient: mock,
      );
      addTearDown(client.close);

      expect(
        () => client.sendManualOverride(
          severity: 'Watch',
          message: 'test',
          targetZone: 'Zone-A',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('invokes onUnauthorized on 401 before throwing', () async {
      var signedOut = false;
      final mock = MockClient(
        (_) async => http.Response(
          '{"message":"unauthorized"}',
          401,
          headers: {'content-type': 'application/json'},
        ),
      );
      final client = ManualOverrideApiClient(
        baseUrl: 'http://localhost:8080',
        getIdToken: () async => 'token',
        onUnauthorized: () async {
          signedOut = true;
        },
        httpClient: mock,
      );
      addTearDown(client.close);

      await expectLater(
        client.sendManualOverride(
          severity: 'Watch',
          message: 'test',
          targetZone: 'Zone-A',
        ),
        throwsA(isA<ManualOverrideApiException>()),
      );
      expect(signedOut, isTrue);
    });

    test('ManualOverrideApiException on HTTP error', () async {
      final mock = MockClient(
        (_) async => http.Response(
          '{"error":"forbidden","message":"nope"}',
          403,
          headers: {'content-type': 'application/json'},
        ),
      );
      final client = ManualOverrideApiClient(
        baseUrl: 'http://localhost:8080',
        getIdToken: () async => 'token',
        httpClient: mock,
      );
      addTearDown(client.close);

      expect(
        () => client.sendManualOverride(
          severity: 'Watch',
          message: 'test',
          targetZone: 'Zone-A',
        ),
        throwsA(isA<ManualOverrideApiException>()),
      );
    });
  });
}
