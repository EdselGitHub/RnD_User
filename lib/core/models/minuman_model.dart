import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/minuman_entity.dart';

class MinumanModel extends MinumanEntity {
  const MinumanModel({
    required super.id,
    required super.nama,
    required super.harga,
    required super.stok,
  });

  factory MinumanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MinumanModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: (data['harga'] ?? 0).toDouble(),
      stok: (data['stok'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'harga': harga,
      'stok': stok,
    };
  }

  factory MinumanModel.fromEntity(MinumanEntity entity) {
    return MinumanModel(
      id: entity.id,
      nama: entity.nama,
      harga: entity.harga,
      stok: entity.stok,
    );
  }

  MinumanModel copyWith({
    String? id,
    String? nama,
    double? harga,
    int? stok,
  }) {
    return MinumanModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
    );
  }
}
