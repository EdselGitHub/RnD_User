import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/laundry_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class LaundryFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addLaundry(LaundryModel laundry) async {
    final doc = await _firestore
        .collection(AppConstants.laundryCollection)
        .add(laundry.toFirestore());
    return doc.id;
  }

  Stream<List<LaundryModel>> streamLaundry() async* {
    final snapshots = _firestore
        .collection(AppConstants.laundryCollection)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<LaundryModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(LaundryModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Future<void> updateLaundryStatus(String id, String status) async {
    await _firestore
        .collection(AppConstants.laundryCollection)
        .doc(id)
        .update({'status': status});
  }

  Future<void> addTransaksiKeuangan({
    required double jumlah,
    String userId = '',
    String deskripsi = 'Layanan Laundry',
  }) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add({
      'kategori': AppConstants.kategoriLaundry,
      'jumlah': jumlah,
      'tipe': 'income',
      'tanggal': Timestamp.now(),
      'user_id': userId,
      'deskripsi': deskripsi,
    });
  }
}
