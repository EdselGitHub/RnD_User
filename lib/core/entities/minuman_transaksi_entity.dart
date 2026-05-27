class MinumanTransaksiEntity {
  final String id;
  final String minumanId;
  final int qty;
  final double total;
  final DateTime tanggal;

  const MinumanTransaksiEntity({
    required this.id,
    required this.minumanId,
    required this.qty,
    required this.total,
    required this.tanggal,
  });
}
