import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/motor/providers/motor_provider.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class MotorScreen extends ConsumerStatefulWidget {
  const MotorScreen({super.key});

  @override
  ConsumerState<MotorScreen> createState() => _MotorScreenState();
}

class _MotorScreenState extends ConsumerState<MotorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(motorSewaStreamProvider, (previous, next) {
      if (next.hasValue) {
        ref.read(motorNotifierProvider.notifier).autoCheckExpired(next.value!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sewa Motor'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.two_wheeler_rounded), text: 'Motor Tersedia'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Sewa Motor'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MotorListTab(onRentTap: () {
            _tabController.animateTo(1);
          }),
          const _MotorSewaFormTab(),
        ],
      ),
    );
  }
}

// =================== MOTOR LIST TAB ===================

class _MotorListTab extends ConsumerWidget {
  final VoidCallback onRentTap;

  const _MotorListTab({required this.onRentTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motorsAsync = ref.watch(motorStreamProvider);

    return motorsAsync.when(
      loading: () => const LoadingWidget(message: 'Memuat daftar motor...'),
      error: (e, _) => ErrorDisplayWidget(message: e.toString()),
      data: (motors) {
        if (motors.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.two_wheeler,
            title: 'Belum Ada Motor',
            subtitle: 'Motor belum tersedia saat ini',
          );
        }

        final available =
            motors.where((m) => m.status == 'tersedia').toList();
        final rented =
            motors.where((m) => m.status != 'tersedia' && m.status != 'dihapus').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8A838), Color(0xFFF5C563)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8A838).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.two_wheeler_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${available.length} Motor Tersedia',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Jelajahi Bali dengan kendaraan roda dua',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Available motors
              if (available.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppTheme.successColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tersedia untuk Disewa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...available.map((motor) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.two_wheeler_rounded,
                                  color: AppTheme.secondaryColor, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    motor.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${Helpers.formatCurrency(motor.harga)} / hari',
                                    style: const TextStyle(
                                      color: AppTheme.secondaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const StatusBadge(status: 'tersedia'),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: onRentTap,
                              icon: const Icon(Icons.directions_bike_rounded,
                                  size: 18),
                              label: const Text('Sewa'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.secondaryColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],

              // Rented motors
              if (rented.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.do_not_disturb_rounded,
                        color: AppTheme.warningColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Sedang Disewa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...rented.map((motor) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.two_wheeler_rounded,
                              color: AppTheme.warningColor, size: 28),
                        ),
                        title: Text(motor.nama,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${Helpers.formatCurrency(motor.harga)} / hari'),
                        trailing: StatusBadge(status: motor.status),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

// =================== SEWA FORM TAB ===================

class _MotorSewaFormTab extends ConsumerStatefulWidget {
  const _MotorSewaFormTab();

  @override
  ConsumerState<_MotorSewaFormTab> createState() => _MotorSewaFormTabState();
}

class _MotorSewaFormTabState extends ConsumerState<_MotorSewaFormTab> {
  String? _selectedMotorId;
  double _motorPrice = 0;
  final _namaCtrl = TextEditingController();

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
    final success =
        await ref.read(motorNotifierProvider.notifier).createMotorSewa(
              motorId: _selectedMotorId!,
              tamuId: _namaCtrl.text.trim(),
              hargaPerhari: _motorPrice,
              total: _motorPrice,
              userId: ref.read(authStateProvider).valueOrNull?.uid ?? '',
            );
    if (success && mounted) {
      Helpers.showSnackBar(context, 'Sewa motor berhasil! Selamat jalan 🏍️');
      setState(() {
        _selectedMotorId = null;
        _motorPrice = 0;
      });
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.infoColor.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppTheme.infoColor, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pilih motor yang tersedia dan isi data diri untuk menyewa',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.infoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
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
              return DropdownButtonFormField<String>(
                initialValue: _selectedMotorId,
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
          if (_motorPrice > 0)
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
                      Text('Harga Sewa',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12)),
                      SizedBox(height: 2),
                      Text('Per Hari',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(Helpers.formatCurrency(_motorPrice),
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
}
