import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/motor/providers/motor_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class MotorListTab extends ConsumerWidget {
  final VoidCallback onRentTap;

  const MotorListTab({super.key, required this.onRentTap});

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
