import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/reservation/providers/reservation_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class AvailableRoomsTab extends ConsumerWidget {
  final VoidCallback onBookTap;

  const AvailableRoomsTab({super.key, required this.onBookTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruanganAsync = ref.watch(ruanganStreamProvider);

    return ruanganAsync.when(
      loading: () => const LoadingWidget(message: 'Memuat daftar kamar...'),
      error: (e, _) => ErrorDisplayWidget(message: e.toString()),
      data: (rooms) {
        if (rooms.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.hotel_outlined,
            title: 'Belum Ada Data Kamar',
            subtitle: 'Kamar belum tersedia saat ini',
          );
        }

        final availableRooms =
            rooms.where((r) => r.status == 'tersedia').toList();

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
                    colors: [Color(0xFF1A6B52), Color(0xFF2D9B75)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A6B52).withValues(alpha: 0.3),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.hotel_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${availableRooms.length} Kamar Tersedia',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Available rooms
              if (availableRooms.isNotEmpty) ...[
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppTheme.successColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tersedia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...availableRooms.map((room) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.king_bed_rounded,
                                  color: AppTheme.successColor, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${Helpers.formatCurrency(room.hargaBulanan)} / bulan',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
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
                              onPressed: onBookTap,
                              icon: const Icon(Icons.book_online_rounded,
                                  size: 18),
                              label: const Text('Pesan'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ],
                        ),
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
