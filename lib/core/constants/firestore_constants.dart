/// Field name constants for Firestore documents
class FirestoreFields {
  FirestoreFields._();

  // Common
  static const String id = 'id';
  static const String status = 'status';
  static const String createdAt = 'created_at';

  // Users
  static const String name = 'name';
  static const String email = 'email';

  // Tamu
  static const String nama = 'nama';
  static const String noHp = 'no_hp';

  // Ruangan
  static const String harga = 'harga';

  // Reservasi
  static const String tamuId = 'tamu_id';
  static const String roomId = 'room_id';
  static const String checkin = 'checkin';
  static const String checkout = 'checkout';
  static const String total = 'total';

  // Motor
  static const String motorId = 'motor_id';
  static const String tanggal = 'tanggal';

  // Laundry
  static const String jenis = 'jenis';

  // Room Service
  static const String jadwal = 'jadwal';

  // Minuman
  static const String stok = 'stok';

  // Minuman Transaksi
  static const String minumanId = 'minuman_id';
  static const String qty = 'qty';

  // Transaksi Keuangan
  static const String kategori = 'kategori';
  static const String jumlah = 'jumlah';
  static const String tipe = 'tipe';
}
