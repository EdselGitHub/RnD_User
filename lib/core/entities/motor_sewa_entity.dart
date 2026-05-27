class MotorSewaEntity {
  final String id;
  final String motorId;
  final String tamuId;
  final DateTime tanggal;
  final DateTime pembuatan;
  final double hargaPerhari;
  final double total;
  final String status;

  const MotorSewaEntity({
    required this.id,
    required this.motorId,
    required this.tamuId,
    required this.tanggal,
    required this.pembuatan,
    required this.hargaPerhari,
    required this.total,
    required this.status,
  });
}
