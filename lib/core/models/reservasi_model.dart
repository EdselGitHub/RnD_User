import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/reservasi_entity.dart';

class ReservasiModel extends ReservasiEntity {
  const ReservasiModel({
    required super.id,
    required super.tamuId,
    required super.roomId,
    required super.checkin,
    required super.checkout,
    required super.total,
    required super.status,
    required super.createdAt,
  });

  factory ReservasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReservasiModel(
      id: doc.id,
      tamuId: data['tamu_id'] ?? '',
      roomId: data['room_id'] is DocumentReference
          ? (data['room_id'] as DocumentReference).id
          : data['room_id']?.toString() ?? '',
      checkin: (data['checkin'] as Timestamp).toDate(),
      checkout: (data['checkout'] as Timestamp).toDate(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'aktif',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tamu_id': tamuId,
      'room_id': roomId,
      'checkin': Timestamp.fromDate(checkin),
      'checkout': Timestamp.fromDate(checkout),
      'total': total,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory ReservasiModel.fromEntity(ReservasiEntity entity) {
    return ReservasiModel(
      id: entity.id,
      tamuId: entity.tamuId,
      roomId: entity.roomId,
      checkin: entity.checkin,
      checkout: entity.checkout,
      total: entity.total,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}
