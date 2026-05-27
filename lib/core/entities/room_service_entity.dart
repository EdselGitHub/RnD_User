class RoomServiceEntity {
  final String id;
  final String roomId;
  final DateTime jadwal;
  final String status;
  final DateTime createdAt;

  const RoomServiceEntity({
    required this.id,
    required this.roomId,
    required this.jadwal,
    required this.status,
    required this.createdAt,
  });
}
