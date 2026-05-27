class AppConstants {
  AppConstants._();

  static const String appName = 'RnD Dewi Sri Bali';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'Users';
  static const String tamuCollection = 'Tamu';
  static const String ruanganCollection = 'Ruangan';
  static const String reservasiCollection = 'Reservasi';
  static const String motorCollection = 'Motor';
  static const String motorSewaCollection = 'Motor_Sewa';
  static const String laundryCollection = 'Laundry';
  static const String roomServiceCollection = 'CleaningRoom';
  static const String minumanCollection = 'Minuman';
  static const String minumanTransaksiCollection = 'Pembelian_Minuman';
  static const String transaksiKeuanganCollection = 'Transaksi_Keuangan';

  // Status
  static const String statusTersedia = 'tersedia';
  static const String statusTerisi = 'terisi';
  static const String statusDisewa = 'disewa';
  static const String statusMenunggu = 'menunggu';
  static const String statusSelesai = 'selesai';
  static const String statusAktif = 'aktif';
  static const String statusBatal = 'batal';

  // Kategori Transaksi
  static const String kategoriKamar = 'kamar';
  static const String kategoriMotor = 'motor';
  static const String kategoriLaundry = 'laundry';
  static const String kategoriMinuman = 'minuman';

  // Low Stock Threshold
  static const int lowStockThreshold = 2;
}
