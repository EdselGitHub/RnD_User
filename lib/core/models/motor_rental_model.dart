import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rnd_proj/core/entities/motor_rent_entity.dart';

class MotorSewaModel extends MotorSewaEntity {
  const MotorSewaModel({
    required super.id,
    required super.motorId,
    required super.tamuId,
    required super.tanggal,
    required super.tanggalKembali,
    required super.pembuatan,
    required super.hargaPerhari,
    required super.total,
    required super.status,
  });

  factory MotorSewaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final tanggal = (data['tanggal'] as Timestamp).toDate();
    final hargaPerhari = (data['harga_perhari'] ?? 150000).toDouble();
    final total = (data['total'] ?? 0).toDouble();

    final motorId = data['motor_id'] is DocumentReference
        ? (data['motor_id'] as DocumentReference).id
        : data['motor_id']?.toString() ?? '';

    final tamuId = data['tamu_id'] is DocumentReference
        ? (data['tamu_id'] as DocumentReference).id
        : data['tamu_id']?.toString() ?? '';

    DateTime tanggalKembali;
    if (data['tanggal_kembali'] is Timestamp) {
      tanggalKembali = (data['tanggal_kembali'] as Timestamp).toDate();
    } else if (data['tanggal_selesai'] is Timestamp) {
      tanggalKembali = (data['tanggal_selesai'] as Timestamp).toDate();
    } else if (data['tanggalSelesai'] is Timestamp) {
      tanggalKembali = (data['tanggalSelesai'] as Timestamp).toDate();
    } else {
      final days = (hargaPerhari > 0) ? (total / hargaPerhari).round() : 1;
      tanggalKembali = tanggal.add(Duration(days: days));
    }

    return MotorSewaModel(
      id: doc.id,
      motorId: motorId,
      tamuId: tamuId,
      tanggal: tanggal,
      tanggalKembali: tanggalKembali,
      pembuatan: (data['pembuatan'] as Timestamp).toDate(),
      hargaPerhari: hargaPerhari,
      total: total,
      status: (data['status'] as String? ?? 'aktif').trim().toLowerCase(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'motor_id': motorId,
      'tamu_id': tamuId,
      'tanggal': Timestamp.fromDate(tanggal),
      'tanggal_kembali': Timestamp.fromDate(tanggalKembali),
      'pembuatan': Timestamp.fromDate(pembuatan),
      'harga_perhari': hargaPerhari,
      'total': total,
      'status': status,
    };
  }

  factory MotorSewaModel.fromEntity(MotorSewaEntity entity) {
    return MotorSewaModel(
      id: entity.id,
      motorId: entity.motorId,
      tamuId: entity.tamuId,
      tanggal: entity.tanggal,
      tanggalKembali: entity.tanggalKembali,
      pembuatan: entity.pembuatan,
      hargaPerhari: entity.hargaPerhari,
      total: entity.total,
      status: entity.status,
    );
  }

  MotorSewaModel copyWith({
    String? id,
    String? motorId,
    String? tamuId,
    DateTime? tanggal,
    DateTime? tanggalKembali,
    DateTime? pembuatan,
    double? hargaPerhari,
    double? total,
    String? status,
  }) {
    return MotorSewaModel(
      id: id ?? this.id,
      motorId: motorId ?? this.motorId,
      tamuId: tamuId ?? this.tamuId,
      tanggal: tanggal ?? this.tanggal,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      pembuatan: pembuatan ?? this.pembuatan,
      hargaPerhari: hargaPerhari ?? this.hargaPerhari,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }
}
