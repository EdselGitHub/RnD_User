///field name contant firestore
class FirestoreFields {
  FirestoreFields._();

  //common
  static const String id = 'id';
  static const String status = 'status';
  static const String createdAt = 'created_at';

  //user
  static const String name = 'name';
  static const String email = 'email';

  //tamu
  static const String nama = 'nama';
  static const String noHp = 'no_hp';

  //ruangan
  static const String harga = 'harga';

  //reservasi
  static const String tamuId = 'tamu_id';
  static const String roomId = 'room_id';
  static const String checkin = 'checkin';
  static const String checkout = 'checkout';
  static const String total = 'total';

  //motor
  static const String motorId = 'motor_id';
  static const String tanggal = 'tanggal';

  //laundry
  static const String jenis = 'jenis';

  //room Service
  static const String jadwal = 'jadwal';

  //minuman
  static const String stok = 'stok';

  //minuman Transaksi
  static const String minumanId = 'minuman_id';
  static const String qty = 'qty';

  //transaksi Keuangan
  static const String kategori = 'kategori';
  static const String jumlah = 'jumlah';
  static const String tipe = 'tipe';
}
