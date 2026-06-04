import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/guest_entity.dart';

class TamuModel extends TamuEntity {
  const TamuModel({
    required super.id,
    required super.nama,
    required super.noHp,
    required super.kartuIdentitas,
  });

  factory TamuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TamuModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      noHp: data['no_hp'] ?? '',
      kartuIdentitas: data['kartu_identitas'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'no_hp': noHp,
      'kartu_identitas': kartuIdentitas,
    };
  }

  factory TamuModel.fromEntity(TamuEntity entity) {
    return TamuModel(
      id: entity.id,
      nama: entity.nama,
      noHp: entity.noHp,
      kartuIdentitas: entity.kartuIdentitas,
    );
  }

  TamuModel copyWith({
    String? id,
    String? nama,
    String? noHp,
    String? kartuIdentitas,
  }) {
    return TamuModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      noHp: noHp ?? this.noHp,
      kartuIdentitas: kartuIdentitas ?? this.kartuIdentitas,
    );
  }
}
