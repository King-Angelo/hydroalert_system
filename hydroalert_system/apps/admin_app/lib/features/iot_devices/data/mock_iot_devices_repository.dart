import 'iot_devices_repository.dart';

class MockIotDevicesRepository implements IotDevicesRepository {
  const MockIotDevicesRepository();

  @override
  Stream<List<IotDeviceRow>> watchDevices() async* {
    yield const [
      IotDeviceRow(
        deviceId: 'mock-device-01',
        name: 'Mock bridge sensor',
        zone: 'Zone A',
        isActive: true,
        waterLevelCm: [12.5, 11.0, 10.2],
        firmwareVersion: '0.0.0-mock',
      ),
    ];
  }
}
