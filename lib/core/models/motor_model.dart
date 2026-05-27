import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/motor_entity.dart';

class MotorModel extends MotorEntity {
  const MotorModel({
    required super.id,
    required super.nama,
    required super.harga,
    required super.status,
  });

  factory MotorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MotorModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: (data['harga'] ?? 0).toDouble(),
      status: data['status'] ?? 'tersedia',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'harga': harga,
      'status': status,
    };
  }

  factory MotorModel.fromEntity(MotorEntity entity) {
    return MotorModel(
      id: entity.id,
      nama: entity.nama,
      harga: entity.harga,
      status: entity.status,
    );
  }

  MotorModel copyWith({
    String? id,
    String? nama,
    double? harga,
    String? status,
  }) {
    return MotorModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      status: status ?? this.status,
    );
  }
}
