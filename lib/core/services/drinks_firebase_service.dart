import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/drink_model.dart';
import 'package:rnd_proj/core/models/drink_transaction_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class DrinksFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MinumanModel>> streamMinuman() async* {
    final snapshots = _firestore
        .collection(AppConstants.minumanCollection)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<MinumanModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(MinumanModel.fromFirestore(doc));
      }
      yield list;
    }
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

  Stream<List<MinumanTransaksiModel>> streamMinumanTransaksi() async* {
    final snapshots = _firestore
        .collection(AppConstants.minumanTransaksiCollection)
        .orderBy('tanggal', descending: true)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<MinumanTransaksiModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(MinumanTransaksiModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Future<void> addTransaksiKeuangan({
    required double jumlah,
    String userId = '',
    String deskripsi = 'Pembelian Minuman',
  }) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add({
      'kategori': AppConstants.kategoriMinuman,
      'jumlah': jumlah,
      'tipe': 'income',
      'tanggal': Timestamp.now(),
      'user_id': userId,
      'deskripsi': deskripsi,
    });
  }
}
