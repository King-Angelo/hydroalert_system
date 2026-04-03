import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/api/admin_authenticated_http_client.dart';
import 'firestore_shelter_logistics_repository.dart';
import 'mock_shelter_logistics_repository.dart';
import 'shelter_logistics_repository.dart';

class ShelterLogisticsRepositoryFactory {
  static ShelterLogisticsRepository create({
    required bool firebaseReady,
    AdminAuthenticatedHttpClient? privilegedApi,
  }) {
    if (firebaseReady && Firebase.apps.isNotEmpty) {
      return FirestoreShelterLogisticsRepository(
        firestore: FirebaseFirestore.instance,
        privilegedApi: privilegedApi,
      );
    }

    return const MockShelterLogisticsRepository();
  }
}
