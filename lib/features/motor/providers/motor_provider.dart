import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/motor_firebase_service.dart';
import 'package:rnd_proj/core/models/motor_model.dart';
import 'package:rnd_proj/core/models/motor_sewa_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final motorServiceProvider = Provider<MotorFirebaseService>((ref) {
  return MotorFirebaseService();
});

final motorStreamProvider = StreamProvider<List<MotorModel>>((ref) {
  final service = ref.watch(motorServiceProvider);
  return service.streamMotor();
});

final availableMotorProvider = StreamProvider<List<MotorModel>>((ref) {
  final service = ref.watch(motorServiceProvider);
  return service.streamAvailableMotor();
});

final motorSewaStreamProvider = StreamProvider<List<MotorSewaModel>>((ref) {
  final service = ref.watch(motorServiceProvider);
  return service.streamMotorSewa();
});

class MotorNotifier extends StateNotifier<AsyncValue<void>> {
  final MotorFirebaseService _service;

  MotorNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> createMotorSewa({
    required String motorId,
    required String tamuId,
    required double hargaPerhari,
    required double total,
    String userId = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.addMotorSewa(MotorSewaModel(
        id: '',
        motorId: motorId,
        tamuId: tamuId,
        tanggal: DateTime.now(),
        pembuatan: DateTime.now(),
        hargaPerhari: hargaPerhari,
        total: total,
        status: AppConstants.statusAktif,
      ));

      await _service.updateMotorStatus(motorId, AppConstants.statusDisewa);
      await _service.addTransaksiKeuangan(jumlah: total, userId: userId);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> returnMotor(String sewaId, String motorId) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateMotorSewaStatus(sewaId, AppConstants.statusSelesai);
      await _service.updateMotorStatus(motorId, AppConstants.statusTersedia);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> autoCheckExpired(List<MotorSewaModel> rentals) async {
    final now = DateTime.now();
    for (final rental in rentals) {
      final days = (rental.hargaPerhari > 0) ? (rental.total / rental.hargaPerhari).round() : 1;
      final tanggalSelesai = rental.tanggal.add(Duration(days: days));
      
      if (rental.status == AppConstants.statusAktif && tanggalSelesai.isBefore(now)) {
        await returnMotor(rental.id, rental.motorId);
      }
    }
  }
}

final motorNotifierProvider =
    StateNotifierProvider<MotorNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(motorServiceProvider);
  return MotorNotifier(service);
});
