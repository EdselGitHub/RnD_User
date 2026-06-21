import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/room_entity.dart';

class RuanganModel extends RuanganEntity {
  const RuanganModel({
    required super.id,
    required super.nama,
    required super.harga,
    required super.hargaMingguan,
    required super.hargaBulanan,
    required super.status,
  });

  factory RuanganModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawStatus = data['status'] as String? ?? 'tersedia';
    return RuanganModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      harga: (data['harga'] ?? 0).toDouble(),
      hargaMingguan: (data['harga_mingguan'] ?? 0).toDouble(),
      hargaBulanan: (data['harga_bulanan'] ?? 0).toDouble(),
      status: rawStatus.trim().toLowerCase(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'harga': harga,
      'harga_mingguan': hargaMingguan,
      'harga_bulanan': hargaBulanan,
      'status': status,
    };
  }

  factory RuanganModel.fromEntity(RuanganEntity entity) {
    return RuanganModel(
      id: entity.id,
      nama: entity.nama,
      harga: entity.harga,
      hargaMingguan: entity.hargaMingguan,
      hargaBulanan: entity.hargaBulanan,
      status: entity.status,
    );
  }

  RuanganModel copyWith({
    String? id,
    String? nama,
    double? harga,
    double? hargaMingguan,
    double? hargaBulanan,
    String? status,
  }) {
    return RuanganModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      hargaMingguan: hargaMingguan ?? this.hargaMingguan,
      hargaBulanan: hargaBulanan ?? this.hargaBulanan,
      status: status ?? this.status,
    );
  }
}
