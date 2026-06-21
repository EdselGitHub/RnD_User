import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/services/reservation_firebase_service.dart';
import 'package:rnd_proj/core/models/guest_model.dart';
import 'package:rnd_proj/core/models/room_model.dart';
import 'package:rnd_proj/core/models/reservation_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final reservationServiceProvider = Provider<ReservationFirebaseService>((ref) {
  return ReservationFirebaseService();
});

final ruanganStreamProvider = StreamProvider<List<RuanganModel>>((ref) async* {
  final service = ref.watch(reservationServiceProvider);
  final reservationsAsync = ref.watch(reservasiStreamProvider);

  await for (final roomsData in service.streamRuangan()) {
    //mengambil data ruangan yang tidak dihapus menggunakan loop
    final List<RuanganModel> roomsList = [];
    for (final r in roomsData) {
      if (r.status != 'dihapus') {
        roomsList.add(r);
      }
    }

    final List<RuanganModel> finalRooms = [];

    if (reservationsAsync is AsyncData) {
      final reservations = reservationsAsync.value!;
      final now = DateTime.now();

      //mengecek status okupansi menggunakan loop
      for (final room in roomsList) {
        if (room.status == 'maintenance') {
          finalRooms.add(room);
          continue;
        }

        bool isOccupiedNow = false;
        for (final res in reservations) {
          if (res.status == AppConstants.statusAktif &&
              res.roomId == room.id &&
              now.compareTo(res.checkin) >= 0 &&
              now.compareTo(res.checkout) < 0) {
            isOccupiedNow = true;
            break; // Jika sudah cocok, hentikan pencarian
          }
        }

        //agar kamar di app user tersedia meskipun menginput data lama di app admin / staff
        String finalStatus = isOccupiedNow ? AppConstants.statusTerisi : AppConstants.statusTersedia;

        finalRooms.add(room.copyWith(
          status: finalStatus,
        ));
      }
    } else {
      finalRooms.addAll(roomsList);
    }
    yield finalRooms;
  }
});

final availableRoomsProvider = Provider<AsyncValue<List<RuanganModel>>>((ref) {
  return ref.watch(ruanganStreamProvider).whenData((rooms) {
    final List<RuanganModel> list = [];
    for (final r in rooms) {
      if (r.status == AppConstants.statusTersedia) {
        list.add(r);
      }
    }
    return list;
  });
});

final reservasiStreamProvider = StreamProvider<List<ReservasiModel>>((ref) {
  final service = ref.watch(reservationServiceProvider);
  return service.streamReservasi();
});

final tamuStreamProvider = StreamProvider<List<TamuModel>>((ref) {
  final service = ref.watch(reservationServiceProvider);
  return service.streamTamu();
});

class ReservationNotifier extends AsyncNotifier<void> {
  ReservationFirebaseService get _service => ref.read(reservationServiceProvider);

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<bool> createReservation({
    required String namaTamu,
    required String noHp,
    required String kartuIdentitas,
    required String roomId,
    required String roomName,
    required DateTime checkin,
    required DateTime checkout,
    required double totalHarga,
    String userId = '',
  }) async {
    state = const AsyncLoading();
    try {
      //save tamu
      final tamuId = await _service.addTamu(TamuModel(
        id: '',
        nama: namaTamu,
        noHp: noHp,
        kartuIdentitas: kartuIdentitas,
      ));

      //simapan reservation
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

      //update status ruangan kalo checkin hari ini atau sebelumnya
      final now = DateTime.now();
      if (checkin.isBefore(now) || (checkin.year == now.year && checkin.month == now.month && checkin.day == now.day)) {
        await _service.updateRoomStatus(roomId, AppConstants.statusTerisi);
      }

      //insert transaksi keuangan
      await _service.addTransaksiKeuangan(
        kategori: AppConstants.kategoriKamar,
        deskripsi: 'Penjualan kamar $roomName',
        jumlah: totalHarga,
        tipe: 'income',
        userId: userId,
        kartuIdentitas: kartuIdentitas,
      );

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> checkoutReservation(String reservasiId, String roomId) async {
    state = const AsyncLoading();
    try {
      await _service.updateReservasiStatus(reservasiId, AppConstants.statusSelesai);
      await _service.updateRoomStatus(roomId, AppConstants.statusTersedia);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
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
    AsyncNotifierProvider<ReservationNotifier, void>(() {
  return ReservationNotifier();
});
