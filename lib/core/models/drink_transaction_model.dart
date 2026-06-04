import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/drink_transaction_entity.dart';

class MinumanTransaksiModel extends MinumanTransaksiEntity {
  const MinumanTransaksiModel({
    required super.id,
    required super.minumanId,
    required super.qty,
    required super.total,
    required super.tanggal,
  });

  factory MinumanTransaksiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MinumanTransaksiModel(
      id: doc.id,
      minumanId: data['minuman_id'] ?? '',
      qty: (data['qty'] ?? 0).toInt(),
      total: (data['total'] ?? 0).toDouble(),
      tanggal: (data['tanggal'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'minuman_id': minumanId,
      'qty': qty,
      'total': total,
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }

  factory MinumanTransaksiModel.fromEntity(MinumanTransaksiEntity entity) {
    return MinumanTransaksiModel(
      id: entity.id,
      minumanId: entity.minumanId,
      qty: entity.qty,
      total: entity.total,
      tanggal: entity.tanggal,
    );
  }

  MinumanTransaksiModel copyWith({
    String? id,
    String? minumanId,
    int? qty,
    double? total,
    DateTime? tanggal,
  }) {
    return MinumanTransaksiModel(
      id: id ?? this.id,
      minumanId: minumanId ?? this.minumanId,
      qty: qty ?? this.qty,
      total: total ?? this.total,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
