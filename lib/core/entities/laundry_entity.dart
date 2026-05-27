class LaundryEntity {
  final String id;
  final String tamuId;
  final double beratKG;
  final double harga;
  final double hargaPerKG;
  final String jenis;
  final String status;

  const LaundryEntity({
    required this.id,
    required this.tamuId,
    required this.beratKG,
    required this.harga,
    required this.hargaPerKG,
    required this.jenis,
    required this.status,
  });
}
