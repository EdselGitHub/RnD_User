import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/room_service_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class RoomServiceFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addRoomService(RoomServiceModel service) async {
    final doc = await _firestore
        .collection(AppConstants.roomServiceCollection)
        .add(service.toFirestore());
    return doc.id;
  }

  Stream<List<RoomServiceModel>> streamRoomService() async* {
    final snapshots = _firestore
        .collection(AppConstants.roomServiceCollection)
        .orderBy('jadwal', descending: true)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<RoomServiceModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(RoomServiceModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Future<void> updateRoomServiceStatus(String id, String status) async {
    await _firestore
        .collection(AppConstants.roomServiceCollection)
        .doc(id)
        .update({'status': status});
  }
}
