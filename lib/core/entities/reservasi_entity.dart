class ReservasiEntity {
  final String id;
  final String tamuId;
  final String roomId;
  final DateTime checkin;
  final DateTime checkout;
  final double total;
  final String status;
  final DateTime createdAt;

  const ReservasiEntity({
    required this.id,
    required this.tamuId,
    required this.roomId,
    required this.checkin,
    required this.checkout,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}
