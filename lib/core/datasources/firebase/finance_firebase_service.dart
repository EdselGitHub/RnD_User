import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/finance_transacton_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class FinanceFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<TransaksiKeuanganModel>> streamTransaksi() {
    return _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransaksiKeuanganModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addTransaksi(TransaksiKeuanganModel transaksi) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add(transaksi.toFirestore());
  }
}
