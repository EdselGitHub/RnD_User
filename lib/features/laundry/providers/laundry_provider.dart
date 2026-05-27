import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/laundry_firebase_service.dart';
import 'package:rnd_proj/core/models/laundry_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final laundryServiceProvider = Provider<LaundryFirebaseService>((ref) {
  return LaundryFirebaseService();
});

final laundryStreamProvider = StreamProvider<List<LaundryModel>>((ref) {
  final service = ref.watch(laundryServiceProvider);
  return service.streamLaundry();
});

class LaundryNotifier extends StateNotifier<AsyncValue<void>> {
  final LaundryFirebaseService _service;

  LaundryNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> addLaundry({
    required String tamuId,
    required String jenis,
    required double beratKG,
    required double hargaPerKG,
    required double harga,
    String userId = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.addLaundry(LaundryModel(
        id: '',
        tamuId: tamuId,
        beratKG: beratKG,
        harga: harga,
        hargaPerKG: hargaPerKG,
        jenis: jenis,
        status: AppConstants.statusMenunggu,
      ));

      await _service.addTransaksiKeuangan(jumlah: harga, userId: userId);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateLaundryStatus(id, status);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final laundryNotifierProvider =
    StateNotifierProvider<LaundryNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(laundryServiceProvider);
  return LaundryNotifier(service);
});
