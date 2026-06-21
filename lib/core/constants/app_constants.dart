import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'RnD Dewi Sri Bali';
  static const String appVersion = '1.0.0';

  //firestore collections
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

  //status
  static const String statusTersedia = 'tersedia';
  static const String statusTerisi = 'terisi';
  static const String statusDisewa = 'disewa';
  static const String statusMenunggu = 'menunggu';
  static const String statusSelesai = 'selesai';
  static const String statusAktif = 'aktif';
  static const String statusBatal = 'batal';

  //kategori transaksi
  static const String kategoriKamar = 'kamar';
  static const String kategoriMotor = 'motor';
  static const String kategoriLaundry = 'laundry';
  static const String kategoriMinuman = 'minuman';

  // Low Stock Threshold
  static const int lowStockThreshold = 2;
}

class AppColors {
  AppColors._();

  // Primary - Forest Green
  static const Color primary = Color(0xFF1A6B52);
  static const Color primaryLight = Color(0xFF2D9B75);
  static const Color primaryDark = Color(0xFF0E4D3A);

  // Secondary - Amber
  static const Color secondary = Color(0xFFE8A838);
  static const Color secondaryLight = Color(0xFFF5C563);

  // Accent - Peach/Reddish
  static const Color accent = Color(0xFFE06356);
  static const Color accentLight = Color(0xFFEF8A7E);

  // Background & Surface
  static const Color background = Color(0xFFF8F5F0);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // Divider
  static const Color divider = Color(0xFFE5E7EB);

  // Room Service
  static const Color roomService = Color(0xFF8B5CF6);
  static const Color roomServiceLight = Color(0xFFA78BFA);
}
