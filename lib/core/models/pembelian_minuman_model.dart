import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/pembelian_minuman_entity.dart';

class PembelianMinumanModel extends PembelianMinumanEntity {
  const PembelianMinumanModel({
    required super.id,
    required super.minumanId,
    required super.qty,
    required super.total,
    required super.tanggal,
    required super.pembuatan,
  });

  factory PembelianMinumanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PembelianMinumanModel(
      id: doc.id,
      minumanId: data['minuman_id'] ?? '',
      qty: (data['qty'] ?? 0).toInt(),
      total: (data['total'] ?? 0).toDouble(),
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      pembuatan: (data['pembuatan'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'minuman_id': minumanId,
      'qty': qty,
      'total': total,
      'tanggal': Timestamp.fromDate(tanggal),
      'pembuatan': Timestamp.fromDate(pembuatan),
    };
  }

  factory PembelianMinumanModel.fromEntity(PembelianMinumanEntity entity) {
    return PembelianMinumanModel(
      id: entity.id,
      minumanId: entity.minumanId,
      qty: entity.qty,
      total: entity.total,
      tanggal: entity.tanggal,
      pembuatan: entity.pembuatan,
    );
  }

  PembelianMinumanModel copyWith({
    String? id,
    String? minumanId,
    int? qty,
    double? total,
    DateTime? tanggal,
    DateTime? pembuatan,
  }) {
    return PembelianMinumanModel(
      id: id ?? this.id,
      minumanId: minumanId ?? this.minumanId,
      qty: qty ?? this.qty,
      total: total ?? this.total,
      tanggal: tanggal ?? this.tanggal,
      pembuatan: pembuatan ?? this.pembuatan,
    );
  }
}
