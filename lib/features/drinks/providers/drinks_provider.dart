import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/drinks_firebase_service.dart';
import 'package:rnd_proj/core/datasources/firebase/notification_service.dart';
import 'package:rnd_proj/core/models/drink_model.dart';
import 'package:rnd_proj/core/models/drink_transaction_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final drinksServiceProvider = Provider<DrinksFirebaseService>((ref) {
  return DrinksFirebaseService();
});

final minumanStreamProvider = StreamProvider<List<MinumanModel>>((ref) {
  final service = ref.watch(drinksServiceProvider);
  return service.streamMinuman();
});

final minumanTransaksiStreamProvider =
    StreamProvider<List<MinumanTransaksiModel>>((ref) {
  final service = ref.watch(drinksServiceProvider);
  return service.streamMinumanTransaksi();
});

class DrinksNotifier extends AsyncNotifier<void> {
  DrinksFirebaseService get _service => ref.read(drinksServiceProvider);

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<bool> sellDrink({
    required MinumanModel minuman,
    required int qty,
    String userId = '',
  }) async {
    state = const AsyncLoading();
    try {
      final total = minuman.harga * qty;
      final newStock = minuman.stok - qty;

      // 1. Reduce stock
      await _service.updateStock(minuman.id, newStock);

      // 2. Save transaksi minuman
      await _service.addMinumanTransaksi(MinumanTransaksiModel(
        id: '',
        minumanId: minuman.id,
        qty: qty,
        total: total,
        tanggal: DateTime.now(),
      ));

      // 3. Insert transaksi keuangan
      await _service.addTransaksiKeuangan(jumlah: total, userId: userId);

      // 4. Check low stock and notify
      if (newStock < AppConstants.lowStockThreshold) {
        try {
          await NotificationService().showNotification(
            title: 'Stok Rendah! ⚠️',
            body: 'Stok ${minuman.nama} tinggal $newStock. Segera restok!',
          );
        } catch (_) {
          // Notification might fail
        }
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final drinksNotifierProvider =
    AsyncNotifierProvider<DrinksNotifier, void>(() {
  return DrinksNotifier();
});
