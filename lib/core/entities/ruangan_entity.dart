class RuanganEntity {
  final String id;
  final String nama;
  final double harga;
  final double hargaMingguan;
  final double hargaBulanan;
  final String status;

  const RuanganEntity({
    required this.id,
    required this.nama,
    required this.harga,
    required this.hargaMingguan,
    required this.hargaBulanan,
    required this.status,
  });
}
