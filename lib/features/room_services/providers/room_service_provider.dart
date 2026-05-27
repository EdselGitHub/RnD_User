import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/datasources/firebase/room_service_firebase_service.dart';
import 'package:rnd_proj/core/datasources/firebase/notification_service.dart';
import 'package:rnd_proj/core/models/room_service_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

final roomServiceServiceProvider = Provider<RoomServiceFirebaseService>((ref) {
  return RoomServiceFirebaseService();
});

final roomServiceStreamProvider = StreamProvider<List<RoomServiceModel>>((ref) {
  final service = ref.watch(roomServiceServiceProvider);
  return service.streamRoomService();
});

class RoomServiceNotifier extends StateNotifier<AsyncValue<void>> {
  final RoomServiceFirebaseService _service;

  RoomServiceNotifier(this._service) : super(const AsyncValue.data(null));

  Future<bool> addRoomService({
    required String roomId,
    required DateTime jadwal,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.addRoomService(RoomServiceModel(
        id: '',
        roomId: roomId,
        jadwal: jadwal,
        status: AppConstants.statusMenunggu,
        createdAt: DateTime.now(),
      ));

      // Send local notification
      try {
        await NotificationService().showNotification(
          title: 'Jadwal Room Service Baru',
          body: 'Room service dijadwalkan untuk kamar $roomId',
        );
      } catch (_) {
        // Notification might fail on some devices, don't block the operation
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> markAsComplete(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateRoomServiceStatus(id, AppConstants.statusSelesai);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final roomServiceNotifierProvider =
    StateNotifierProvider<RoomServiceNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(roomServiceServiceProvider);
  return RoomServiceNotifier(service);
});
