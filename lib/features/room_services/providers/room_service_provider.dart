import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/services/room_service_firebase_service.dart';
import 'package:rnd_proj/core/services/notification_service.dart';
import 'package:rnd_proj/core/models/room_service_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final roomServiceServiceProvider = Provider<RoomServiceFirebaseService>((ref) {
  return RoomServiceFirebaseService();
});

final roomServiceStreamProvider = StreamProvider<List<RoomServiceModel>>((ref) {
  final service = ref.watch(roomServiceServiceProvider);
  return service.streamRoomService();
});

class RoomServiceNotifier extends AsyncNotifier<void> {
  RoomServiceFirebaseService get _service => ref.read(roomServiceServiceProvider);

  @override
  FutureOr<void> build() {
    return null;
  }

  Future<bool> addRoomService({
    required String roomId,
    required DateTime jadwal,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.addRoomService(RoomServiceModel(
        id: '',
        roomId: roomId,
        jadwal: jadwal,
        status: AppConstants.statusMenunggu,
        createdAt: DateTime.now(),
      ));

      //mengirim notifikasi lokal
      try {
        await NotificationService().showNotification(
          title: 'Jadwal Room Service Baru',
          body: 'Room service dijadwalkan untuk kamar $roomId',
        );
      } catch (_) {
        //notifikasi bisa mungkin error
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> markAsComplete(String id) async {
    state = const AsyncLoading();
    try {
      await _service.updateRoomServiceStatus(id, AppConstants.statusSelesai);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final roomServiceNotifierProvider =
    AsyncNotifierProvider<RoomServiceNotifier, void>(() {
  return RoomServiceNotifier();
});
