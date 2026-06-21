import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/models/motor_model.dart';
import 'package:rnd_proj/core/models/motor_rental_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class MotorFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MotorModel>> streamMotor() async* {
    final snapshots = _firestore
        .collection(AppConstants.motorCollection)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<MotorModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(MotorModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Stream<List<MotorModel>> streamAvailableMotor() async* {
    final snapshots = _firestore
        .collection(AppConstants.motorCollection)
        .where('status', isEqualTo: AppConstants.statusTersedia)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<MotorModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(MotorModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Future<void> updateMotorStatus(String motorId, String status) async {
    await _firestore
        .collection(AppConstants.motorCollection)
        .doc(motorId)
        .update({'status': status});
  }

  Future<String> addMotorSewa(MotorSewaModel sewa) async {
    final doc = await _firestore
        .collection(AppConstants.motorSewaCollection)
        .add(sewa.toFirestore());
    return doc.id;
  }

  Stream<List<MotorSewaModel>> streamMotorSewa() async* {
    final snapshots = _firestore
        .collection(AppConstants.motorSewaCollection)
        .orderBy('tanggal', descending: true)
        .snapshots();
    await for (final snapshot in snapshots) {
      final List<MotorSewaModel> list = [];
      for (final doc in snapshot.docs) {
        list.add(MotorSewaModel.fromFirestore(doc));
      }
      yield list;
    }
  }

  Future<void> updateMotorSewaStatus(String id, String status) async {
    await _firestore
        .collection(AppConstants.motorSewaCollection)
        .doc(id)
        .update({'status': status});
  }

  Future<void> addTransaksiKeuangan({
    required double jumlah,
    String userId = '',
    String deskripsi = 'Penyewaan Motor',
  }) async {
    await _firestore
        .collection(AppConstants.transaksiKeuanganCollection)
        .add({
      'kategori': AppConstants.kategoriMotor,
      'jumlah': jumlah,
      'tipe': 'income',
      'tanggal': Timestamp.now(),
      'user_id': userId,
      'deskripsi': deskripsi,
    });
  }
}
