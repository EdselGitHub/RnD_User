import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/finance_firebase_service.dart';
import 'package:rnd_proj/core/models/transaksi_keuangan_model.dart';

final financeServiceProvider = Provider<FinanceFirebaseService>((ref) {
  return FinanceFirebaseService();
});

final financeStreamProvider =
    StreamProvider<List<TransaksiKeuanganModel>>((ref) {
  final service = ref.watch(financeServiceProvider);
  return service.streamTransaksi();
});
