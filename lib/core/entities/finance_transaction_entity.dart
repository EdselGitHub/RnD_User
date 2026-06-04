class TransaksiKeuanganEntity {
  final String id;
  final String kategori;
  final double jumlah;
  final String tipe;
  final DateTime tanggal;
  final String userId;

  const TransaksiKeuanganEntity({
    required this.id,
    required this.kategori,
    required this.jumlah,
    required this.tipe,
    required this.tanggal,
    this.userId = '',
  });
}
