import 'package:admin_app/features/dashboard/widgets/operations_health_panel.dart';
import 'package:admin_app/features/iot_devices/data/iot_devices_repository.dart';
import 'package:admin_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OperationsHealthPanel shows sensor summary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: OperationsHealthPanel(
            iotDevicesRepository: _FakeIotRepo(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Operations'), findsOneWidget);
    expect(find.textContaining('device'), findsOneWidget);
  });
}

class _FakeIotRepo implements IotDevicesRepository {
  @override
  Stream<List<IotDeviceRow>> watchDevices() => Stream.value([
        IotDeviceRow(
          deviceId: 'd1',
          name: 'Sensor A',
          zone: 'Z1',
          isActive: true,
          lastSeenAt: DateTime.now(),
        ),
      ]);
}
