class PembelianMinumanEntity {
  final String id;
  final String minumanId;
  final int qty;
  final double total;
  final DateTime tanggal;
  final DateTime pembuatan;

  const PembelianMinumanEntity({
    required this.id,
    required this.minumanId,
    required this.qty,
    required this.total,
    required this.tanggal,
    required this.pembuatan,
  });
}
