import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firestore_shelter_logistics_repository.dart';
import 'mock_shelter_logistics_repository.dart';
import 'shelter_logistics_repository.dart';

class ShelterLogisticsRepositoryFactory {
  static ShelterLogisticsRepository create({required bool firebaseReady}) {
    if (firebaseReady && Firebase.apps.isNotEmpty) {
      return FirestoreShelterLogisticsRepository(
        firestore: FirebaseFirestore.instance,
      );
    }

    return const MockShelterLogisticsRepository();
  }
}
