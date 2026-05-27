import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/finance/providers/finance_provider.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksiAsync = ref.watch(financeStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: transaksiAsync.when(
        loading: () => const LoadingWidget(message: 'Memuat riwayat...'),
        error: (e, _) => ErrorDisplayWidget(message: e.toString()),
        data: (allList) {
          final currentUid = ref.watch(authStateProvider).valueOrNull?.uid ?? '';
          final list = allList.where((t) => t.userId == currentUid).toList();

          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Belum Ada Riwayat',
              subtitle: 'Pesanan Anda akan muncul di sini',
            );
          }


          return Column(
            children: [
              // Total spending card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 12),
                    const Text('Jumlah Transaksi',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(
                      '${list.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Section title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded,
                        color: AppTheme.textSecondary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Semua Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Transaction list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final t = list[i];
                    IconData icon;
                    Color color;
                    String label;
                    switch (t.kategori) {
                      case 'kamar':
                        icon = Icons.hotel_rounded;
                        color = AppTheme.primaryColor;
                        label = 'Reservasi Kamar';
                        break;
                      case 'motor':
                        icon = Icons.two_wheeler_rounded;
                        color = AppTheme.secondaryColor;
                        label = 'Sewa Motor';
                        break;
                      case 'laundry':
                        icon = Icons.local_laundry_service_rounded;
                        color = AppTheme.infoColor;
                        label = 'Laundry';
                        break;
                      case 'minuman':
                        icon = Icons.local_cafe_rounded;
                        color = AppTheme.accentColor;
                        label = 'Minuman';
                        break;
                      default:
                        icon = Icons.receipt_rounded;
                        color = AppTheme.textSecondary;
                        label = t.kategori.toUpperCase();
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        title: Text(
                          label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.schedule,
                                    size: 12, color: AppTheme.textLight),
                                const SizedBox(width: 4),
                                Text(
                                  Helpers.formatDateTime(t.tanggal),
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Text(
                          Helpers.formatCurrency(t.jumlah),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
