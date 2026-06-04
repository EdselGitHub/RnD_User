import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/motor/providers/motor_provider.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';
import 'package:go_router/go_router.dart';

class MotorSewaFormTab extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  const MotorSewaFormTab({super.key, required this.onSuccess});

  @override
  ConsumerState<MotorSewaFormTab> createState() => _MotorSewaFormTabState();
}

class _MotorSewaFormTabState extends ConsumerState<MotorSewaFormTab> {
  String? _selectedMotorId;
  double _motorPrice = 0;
  final _namaCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      final userName = authState.valueOrNull?.name;
      if (userName != null && _namaCtrl.text.isEmpty) {
        _namaCtrl.text = userName;
      }
    });
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? now : (_startDate ?? now).add(const Duration(days: 1)),
      firstDate: isStart ? now : (_startDate ?? now),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedMotorId == null) {
      Helpers.showSnackBar(context, 'Pilih motor terlebih dahulu',
          isError: true);
      return;
    }
    if (_namaCtrl.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Nama penyewa wajib diisi', isError: true);
      return;
    }
    if (_startDate == null || _endDate == null) {
      Helpers.showSnackBar(context, 'Pilih tanggal sewa dan kembali', isError: true);
      return;
    }

    final days = _endDate!.difference(_startDate!).inDays;
    if (days <= 0) {
      Helpers.showSnackBar(context, 'Tanggal kembali harus setelah tanggal sewa', isError: true);
      return;
    }

    final rentalsAsync = ref.read(motorSewaStreamProvider);
    final rentals = rentalsAsync.valueOrNull ?? [];
    
    final isOverlap = rentals.any((res) {
      if (res.motorId != _selectedMotorId || res.status != AppConstants.statusAktif) return false;

      final start1 = DateUtils.dateOnly(_startDate!);
      final end1 = DateUtils.dateOnly(_endDate!);
      final start2 = DateUtils.dateOnly(res.tanggal);
      final end2 = DateUtils.dateOnly(res.tanggalKembali);

      return start1.isBefore(end2) && end1.isAfter(start2);
    });

    if (isOverlap) {
      Helpers.showSnackBar(context, 'Motor sudah disewa pada tanggal tersebut. Silakan pilih tanggal lain.', isError: true);
      return;
    }

    final selectedMotorId = _selectedMotorId!;
    final tamuId = _namaCtrl.text.trim();
    final hargaPerhari = _motorPrice;
    final total = days * _motorPrice;
    final startDate = _startDate;
    final endDate = _endDate;
    final userId = ref.read(authStateProvider).valueOrNull?.uid ?? '';

    if (mounted) {
      context.push(
        '/payment',
        extra: {
          'totalAmount': total,
          'onPaymentSuccess': () async {
            final success =
                await ref.read(motorNotifierProvider.notifier).createMotorSewa(
                      motorId: selectedMotorId,
                      tamuId: tamuId,
                      hargaPerhari: hargaPerhari,
                      total: total,
                      tanggal: startDate!,
                      tanggalKembali: endDate!,
                      userId: userId,
                     );
            if (success && mounted) {
              Helpers.showSnackBar(context, 'Sewa motor berhasil! Selamat jalan 🏍️');
              setState(() {
                _selectedMotorId = null;
                _motorPrice = 0;
                _startDate = null;
                _endDate = null;
              });
              widget.onSuccess();
            }
          },
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final motorsAsync = ref.watch(availableMotorProvider);
    final formState = ref.watch(motorNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          const InfoBanner(
            message: 'Pilih motor yang tersedia dan isi data diri untuk menyewa',
            icon: Icons.info_outline_rounded,
            color: AppTheme.infoColor,
          ),
          const SizedBox(height: 20),

          const Text('Tanggal Sewa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateBtn('Tanggal Sewa',
                    _startDate != null ? DateFormat('dd MMM yyyy', 'id_ID').format(_startDate!) : 'Pilih',
                    () => _pickDate(true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateBtn('Tanggal Kembali',
                    _endDate != null ? DateFormat('dd MMM yyyy', 'id_ID').format(_endDate!) : 'Pilih',
                    () => _pickDate(false)),
              ),
            ],
          ),
          if (_startDate != null && _endDate != null && _endDate!.difference(_startDate!).inDays > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('${_endDate!.difference(_startDate!).inDays} hari',
                  style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),

          const SizedBox(height: 20),
          const Text('Nama Penyewa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextFormField(
            controller: _namaCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Pilih Motor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          motorsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (motors) {
              if (motors.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(children: [
                    Icon(Icons.warning_amber, color: AppTheme.warningColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Maaf, semua motor sedang disewa. Silakan coba lagi nanti.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ]),
                );
              }
              final isValidSelection = _selectedMotorId != null &&
                  motors.any((m) => m.id == _selectedMotorId);

              return DropdownButtonFormField<String>(
                value: isValidSelection ? _selectedMotorId : null,
                decoration: const InputDecoration(
                  labelText: 'Motor Tersedia',
                  prefixIcon: Icon(Icons.two_wheeler),
                ),
                items: motors.map((m) {
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text(
                        '${m.nama} - ${Helpers.formatCurrency(m.harga)}/hari'),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedMotorId = v;
                    _motorPrice = motors.firstWhere((m) => m.id == v).harga;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 20),
          if (_motorPrice > 0 && _startDate != null && _endDate != null && _endDate!.difference(_startDate!).inDays > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE8A838), Color(0xFFF5C563)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Harga Sewa',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12)),
                      SizedBox(height: 2),
                      Text('Perhitungan Otomatis',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(Helpers.formatCurrency(_motorPrice * _endDate!.difference(_startDate!).inDays),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: formState is AsyncLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
              ),
              icon: const Icon(Icons.directions_bike_rounded),
              label: const Text('Sewa Sekarang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBtn(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppTheme.secondaryColor),
                const SizedBox(width: 6),
                Flexible(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
