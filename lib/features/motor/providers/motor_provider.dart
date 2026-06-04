import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/motor_firebase_service.dart';
import 'package:rnd_proj/core/models/motor_model.dart';
import 'package:rnd_proj/core/models/motor_sewa_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final motorServiceProvider = Provider<MotorFirebaseService>((ref) {
  return MotorFirebaseService();
});

final motorStreamProvider = StreamProvider<List<MotorModel>>((ref) async* {
  final service = ref.watch(motorServiceProvider);
  final rentalsAsync = ref.watch(motorSewaStreamProvider);

  await for (final motorsData in service.streamMotor()) {
    var motors = motorsData.where((m) => m.status != 'dihapus').toList();

    if (rentalsAsync is AsyncData) {
      final rentals = rentalsAsync.value!;
      final now = DateTime.now();

      motors = motors.map((motor) {
        if (motor.status == 'maintenance') return motor;

        bool isOccupiedNow = rentals.any((rental) {
          if (rental.status != AppConstants.statusAktif) return false;
          if (rental.motorId != motor.id) return false;

          return now.compareTo(rental.tanggal) >= 0 &&
              now.compareTo(rental.tanggalKembali) < 0;
        });

        return motor.copyWith(
          status: isOccupiedNow ? AppConstants.statusDisewa : AppConstants.statusTersedia,
        );
      }).toList();
    }
    yield motors;
  }
});

final availableMotorProvider = Provider<AsyncValue<List<MotorModel>>>((ref) {
  return ref.watch(motorStreamProvider).whenData(
        (motors) => motors.where((m) => m.status == AppConstants.statusTersedia).toList(),
      );
});

final motorSewaStreamProvider = StreamProvider<List<MotorSewaModel>>((ref) {
  final service = ref.watch(motorServiceProvider);
  return service.streamMotorSewa();
});

class MotorNotifier extends AsyncNotifier<void> {
  MotorFirebaseService get _service => ref.read(motorServiceProvider);

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<bool> createMotorSewa({
    required String motorId,
    required String tamuId,
    required double hargaPerhari,
    required double total,
    required DateTime tanggal,
    required DateTime tanggalKembali,
    String userId = '',
  }) async {
    state = const AsyncLoading();
    try {
      await _service.addMotorSewa(MotorSewaModel(
        id: '',
        motorId: motorId,
        tamuId: tamuId,
        tanggal: tanggal,
        tanggalKembali: tanggalKembali,
        pembuatan: DateTime.now(),
        hargaPerhari: hargaPerhari,
        total: total,
        status: AppConstants.statusAktif,
      ));

      await _service.updateMotorStatus(motorId, AppConstants.statusDisewa);
      await _service.addTransaksiKeuangan(jumlah: total, userId: userId);

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> returnMotor(String sewaId, String motorId) async {
    state = const AsyncLoading();
    try {
      await _service.updateMotorSewaStatus(sewaId, AppConstants.statusSelesai);
      await _service.updateMotorStatus(motorId, AppConstants.statusTersedia);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> autoCheckExpired(List<MotorSewaModel> rentals) async {
    final now = DateTime.now();
    for (final rental in rentals) {
      if (rental.status == AppConstants.statusAktif &&
          rental.tanggalKembali.isBefore(now)) {
        await returnMotor(rental.id, rental.motorId);
      }
    }
  }
}

final motorNotifierProvider =
    AsyncNotifierProvider<MotorNotifier, void>(() {
  return MotorNotifier();
});
