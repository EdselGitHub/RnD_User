import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/reservation_firebase_service.dart';
import 'package:rnd_proj/core/models/tamu_model.dart';
import 'package:rnd_proj/core/models/ruangan_model.dart';
import 'package:rnd_proj/core/models/reservasi_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final reservationServiceProvider = Provider<ReservationFirebaseService>((ref) {
  return ReservationFirebaseService();
});

final ruanganStreamProvider = StreamProvider<List<RuanganModel>>((ref) async* {
  final service = ref.watch(reservationServiceProvider);
  final reservationsAsync = ref.watch(reservasiStreamProvider);

  await for (final roomsData in service.streamRuangan()) {
    var rooms = roomsData.where((r) => r.status != 'dihapus').toList();

    if (reservationsAsync is AsyncData) {
      final reservations = reservationsAsync.value!;
      final now = DateTime.now();

      rooms = rooms.map((room) {
        if (room.status == 'maintenance') return room;

        bool isOccupiedNow = reservations.any((res) {
          if (res.status != AppConstants.statusAktif) return false;
          if (res.roomId != room.id) return false;
          return now.compareTo(res.checkin) >= 0 && now.compareTo(res.checkout) < 0;
        });

        String finalStatus = AppConstants.statusTersedia;
        if (isOccupiedNow || room.status == 'tidak tersedia' || room.status == AppConstants.statusTerisi) {
          finalStatus = AppConstants.statusTerisi;
        }

        return room.copyWith(
          status: finalStatus,
        );
      }).toList();
    }
    yield rooms;
  }
});

final availableRoomsProvider = Provider<AsyncValue<List<RuanganModel>>>((ref) {
  return ref.watch(ruanganStreamProvider).whenData(
        (rooms) => rooms.where((r) => r.status == AppConstants.statusTersedia).toList(),
      );
});

final reservasiStreamProvider = StreamProvider<List<ReservasiModel>>((ref) {
  final service = ref.watch(reservationServiceProvider);
  return service.streamReservasi();
});

final tamuStreamProvider = StreamProvider<List<TamuModel>>((ref) {
  final service = ref.watch(reservationServiceProvider);
  return service.streamTamu();
});

class ReservationNotifier extends StateNotifier<AsyncValue<void>> {
  final ReservationFirebaseService _service;

  ReservationNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> createReservation({
    required String namaTamu,
    required String noHp,
    required String kartuIdentitas,
    required String roomId,
    required DateTime checkin,
    required DateTime checkout,
    required double totalHarga,
    String userId = '',
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Save tamu
      final tamuId = await _service.addTamu(TamuModel(
        id: '',
        nama: namaTamu,
        noHp: noHp,
        kartuIdentitas: kartuIdentitas,
      ));

      // 2. Save reservasi
      await _service.addReservasi(ReservasiModel(
        id: '',
        tamuId: tamuId,
        roomId: roomId,
        checkin: checkin,
        checkout: checkout,
        total: totalHarga,
        status: AppConstants.statusAktif,
        createdAt: DateTime.now(),
      ));

      // 3. Update room status ONLY if checkin is today or past
      final now = DateTime.now();
      if (checkin.isBefore(now) || (checkin.year == now.year && checkin.month == now.month && checkin.day == now.day)) {
        await _service.updateRoomStatus(roomId, AppConstants.statusTerisi);
      }

      // 4. Insert transaksi keuangan
      await _service.addTransaksiKeuangan(
        kategori: AppConstants.kategoriKamar,
        jumlah: totalHarga,
        tipe: 'income',
        userId: userId,
        kartuIdentitas: kartuIdentitas,
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> checkoutReservation(String reservasiId, String roomId) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateReservasiStatus(reservasiId, AppConstants.statusSelesai);
      await _service.updateRoomStatus(roomId, AppConstants.statusTersedia);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> autoCheckExpired(List<ReservasiModel> reservations, List<RuanganModel> rooms) async {
    final now = DateTime.now();
    for (final res in reservations) {
      if (res.status == AppConstants.statusAktif) {
        if (res.checkout.isBefore(now)) {
          await checkoutReservation(res.id, res.roomId);
        } else if (res.checkin.isBefore(now) || (res.checkin.year == now.year && res.checkin.month == now.month && res.checkin.day == now.day)) {
          try {
            final room = rooms.firstWhere((r) => r.id == res.roomId);
            if (room.status == AppConstants.statusTersedia) {
              await _service.updateRoomStatus(res.roomId, AppConstants.statusTerisi);
            }
          } catch (_) {}
        }
      }
    }
  }
}

final reservationNotifierProvider =
    StateNotifierProvider<ReservationNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(reservationServiceProvider);
  return ReservationNotifier(service);
});
