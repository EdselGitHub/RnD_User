import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/finance_transacton_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class FinanceFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransaksiKeuanganModel>> streamTransaksi() async* {
    final snapshots = _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .orderBy('tanggal', descending: true)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<TransaksiKeuanganModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(TransaksiKeuanganModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Future<void> addTransaksi(TransaksiKeuanganModel transaksi) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add(transaksi.toFirestore());
  }
}
