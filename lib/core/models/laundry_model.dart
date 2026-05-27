import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/laundry_entity.dart';

class LaundryModel extends LaundryEntity {
  const LaundryModel({
    required super.id,
    required super.tamuId,
    required super.beratKG,
    required super.harga,
    required super.hargaPerKG,
    required super.jenis,
    required super.status,
  });

  factory LaundryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LaundryModel(
      id: doc.id,
      tamuId: data['tamu_id'] ?? '',
      beratKG: (data['beratKG'] ?? 0).toDouble(),
      harga: (data['harga'] ?? 0).toDouble(),
      hargaPerKG: (data['hargaPerKG'] ?? 15000).toDouble(),
      jenis: data['jenis'] ?? 'regular',
      status: data['status'] ?? 'menunggu',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tamu_id': tamuId,
      'beratKG': beratKG,
      'harga': harga,
      'hargaPerKG': hargaPerKG,
      'jenis': jenis,
      'status': status,
    };
  }

  factory LaundryModel.fromEntity(LaundryEntity entity) {
    return LaundryModel(
      id: entity.id,
      tamuId: entity.tamuId,
      beratKG: entity.beratKG,
      harga: entity.harga,
      hargaPerKG: entity.hargaPerKG,
      jenis: entity.jenis,
      status: entity.status,
    );
  }

  LaundryModel copyWith({
    String? id,
    String? tamuId,
    double? beratKG,
    double? harga,
    double? hargaPerKG,
    String? jenis,
    String? status,
  }) {
    return LaundryModel(
      id: id ?? this.id,
      tamuId: tamuId ?? this.tamuId,
      beratKG: beratKG ?? this.beratKG,
      harga: harga ?? this.harga,
      hargaPerKG: hargaPerKG ?? this.hargaPerKG,
      jenis: jenis ?? this.jenis,
      status: status ?? this.status,
    );
  }
}
