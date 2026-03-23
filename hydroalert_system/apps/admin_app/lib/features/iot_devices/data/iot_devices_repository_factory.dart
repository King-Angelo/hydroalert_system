import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_iot_devices_repository.dart';
import 'iot_devices_repository.dart';
import 'mock_iot_devices_repository.dart';

class IotDevicesRepositoryFactory {
  static IotDevicesRepository create({required bool firebaseReady}) {
    if (firebaseReady) {
      return FirestoreIotDevicesRepository(firestore: FirebaseFirestore.instance);
    }
    return const MockIotDevicesRepository();
  }
}
