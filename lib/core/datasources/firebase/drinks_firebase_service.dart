import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/minuman_model.dart';
import 'package:rnd_proj/core/models/minuman_transaksi_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class DrinksFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MinumanModel>> streamMinuman() {
    return _firestore
        .collection(AppConstants.minumanCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MinumanModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateStock(String minumanId, int newStock) async {
    await _firestore
        .collection(AppConstants.minumanCollection)
        .doc(minumanId)
        .update({'stok': newStock});
  }

  Future<String> addMinumanTransaksi(MinumanTransaksiModel transaksi) async {
    final doc = await _firestore
        .collection(AppConstants.minumanTransaksiCollection)
        .add(transaksi.toFirestore());
    return doc.id;
  }

  Stream<List<MinumanTransaksiModel>> streamMinumanTransaksi() {
    return _firestore
        .collection(AppConstants.minumanTransaksiCollection)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MinumanTransaksiModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addTransaksiKeuangan({
    required double jumlah,
    String userId = '',
  }) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add({
      'kategori': AppConstants.kategoriMinuman,
      'jumlah': jumlah,
      'tipe': 'income',
      'tanggal': Timestamp.now(),
      'user_id': userId,
    });
  }
}
