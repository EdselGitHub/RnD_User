import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/room_service_entity.dart';

class RoomServiceModel extends RoomServiceEntity {
  const RoomServiceModel({
    required super.id,
    required super.roomId,
    required super.jadwal,
    required super.status,
    required super.createdAt,
  });

  factory RoomServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RoomServiceModel(
      id: doc.id,
      roomId: data['room_id'] is DocumentReference
          ? (data['room_id'] as DocumentReference).id
          : data['room_id']?.toString() ?? '',
      jadwal: (data['jadwal'] as Timestamp).toDate(),
      status: data['status'] ?? 'menunggu',
      createdAt: data.containsKey('created_at') 
          ? (data['created_at'] as Timestamp).toDate()
          : (data['jadwal'] as Timestamp).toDate(), //fallback untuk data lama
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'room_id': roomId,
      'jadwal': Timestamp.fromDate(jadwal),
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory RoomServiceModel.fromEntity(RoomServiceEntity entity) {
    return RoomServiceModel(
      id: entity.id,
      roomId: entity.roomId,
      jadwal: entity.jadwal,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}
