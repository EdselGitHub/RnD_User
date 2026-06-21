import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/services/motor_firebase_service.dart';
import 'package:rnd_proj/core/models/motor_model.dart';
import 'package:rnd_proj/core/models/motor_rental_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final motorServiceProvider = Provider<MotorFirebaseService>((ref) {
  return MotorFirebaseService();
});

final motorStreamProvider = StreamProvider<List<MotorModel>>((ref) async* {
  final service = ref.watch(motorServiceProvider);
  final rentalsAsync = ref.watch(motorSewaStreamProvider);

  await for (final motorsData in service.streamMotor()) {
    //mengambil data motor yang tidak dihapus menggunakan loop
    final List<MotorModel> motorsList = [];
    for (final m in motorsData) {
      if (m.status != 'dihapus') {
        motorsList.add(m);
      }
    }

    final List<MotorModel> finalMotors = [];

    if (rentalsAsync is AsyncData) {
      final rentals = rentalsAsync.value!;
      final now = DateTime.now();
      final today = DateUtils.dateOnly(now);

      //mengecek status rental menggunakan loop 
      for (final motor in motorsList) {
        if (motor.status == 'maintenance') {
          finalMotors.add(motor);
          continue;
        }

        bool isOccupiedNow = false;
        for (final rental in rentals) {
          final rentalStart = DateUtils.dateOnly(rental.tanggal);
          final rentalEnd = DateUtils.dateOnly(rental.tanggalKembali);
          if (rental.status == AppConstants.statusAktif &&
              rental.motorId == motor.id &&
              today.compareTo(rentalStart) >= 0 &&
              today.compareTo(rentalEnd) < 0) {
            isOccupiedNow = true;
            break; // Jika sudah cocok, hentikan pencarian
          }
        }

        finalMotors.add(motor.copyWith(
          status: isOccupiedNow ? AppConstants.statusDisewa : AppConstants.statusTersedia,
        ));
      }
    } else {
      finalMotors.addAll(motorsList);
    }
    yield finalMotors;
  }
});

final availableMotorProvider = Provider<AsyncValue<List<MotorModel>>>((ref) {
  return ref.watch(motorStreamProvider).whenData((motors) {
    final List<MotorModel> list = [];
    for (final m in motors) {
      if (m.status == AppConstants.statusTersedia) {
        list.add(m);
      }
    }
    return list;
  });
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
      await _service.addTransaksiKeuangan(
        jumlah: total,
        userId: userId,
        deskripsi: 'Sewa Motor [$tamuId]',
      );

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
