import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/finance_transaction_entity.dart';

class TransaksiKeuanganModel extends TransaksiKeuanganEntity {
  const TransaksiKeuanganModel({
    required super.id,
    required super.kategori,
    required super.jumlah,
    required super.tipe,
    required super.tanggal,
    super.userId = '',
  });

  factory TransaksiKeuanganModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransaksiKeuanganModel(
      id: doc.id,
      kategori: data['kategori'] ?? '',
      jumlah: (data['jumlah'] ?? 0).toDouble(),
      tipe: data['tipe'] ?? 'income',
      tanggal: (data['tanggal'] as Timestamp).toDate(),
      userId: data['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'kategori': kategori,
      'jumlah': jumlah,
      'tipe': tipe,
      'tanggal': Timestamp.fromDate(tanggal),
      'user_id': userId,
    };
  }

  factory TransaksiKeuanganModel.fromEntity(TransaksiKeuanganEntity entity) {
    return TransaksiKeuanganModel(
      id: entity.id,
      kategori: entity.kategori,
      jumlah: entity.jumlah,
      tipe: entity.tipe,
      tanggal: entity.tanggal,
      userId: entity.userId,
    );
  }
}
