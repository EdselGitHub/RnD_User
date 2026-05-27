import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/tamu_model.dart';
import 'package:rnd_proj/core/models/ruangan_model.dart';
import 'package:rnd_proj/core/models/reservasi_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class ReservationFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =================== TAMU ===================

  Future<String> addTamu(TamuModel tamu) async {
    final doc =
        await _firestore.collection(AppConstants.tamuCollection).add(tamu.toFirestore());
    return doc.id;
  }

  Stream<List<TamuModel>> streamTamu() {
    return _firestore
        .collection(AppConstants.tamuCollection)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TamuModel.fromFirestore(doc)).toList());
  }

  // =================== RUANGAN ===================

  Stream<List<RuanganModel>> streamRuangan() {
    return _firestore
        .collection(AppConstants.ruanganCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RuanganModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<RuanganModel>> streamAvailableRooms() {
    return _firestore
        .collection(AppConstants.ruanganCollection)
        .where('status', isEqualTo: AppConstants.statusTersedia)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RuanganModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateRoomStatus(String roomId, String status) async {
    await _firestore
        .collection(AppConstants.ruanganCollection)
        .doc(roomId)
        .update({'status': status});
  }

  // =================== RESERVASI ===================

  Future<String> addReservasi(ReservasiModel reservasi) async {
    final doc = await _firestore
        .collection(AppConstants.reservasiCollection)
        .add(reservasi.toFirestore());
    return doc.id;
  }

  Stream<List<ReservasiModel>> streamReservasi() {
    return _firestore
        .collection(AppConstants.reservasiCollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservasiModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateReservasiStatus(String id, String status) async {
    await _firestore
        .collection(AppConstants.reservasiCollection)
        .doc(id)
        .update({'status': status});
  }

  // =================== TRANSAKSI KEUANGAN ===================

  Future<void> addTransaksiKeuangan({
    required String kategori,
    required double jumlah,
    required String tipe,
    String userId = '',
  }) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add({
      'kategori': kategori,
      'jumlah': jumlah,
      'tipe': tipe,
      'tanggal': Timestamp.now(),
      'user_id': userId,
    });
  }
}
