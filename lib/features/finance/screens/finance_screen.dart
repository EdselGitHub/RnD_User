import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/finance/providers/finance_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaksiAsync = ref.watch(financeStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Keuangan')),
      body: transaksiAsync.when(
        loading: () => const LoadingWidget(message: 'Memuat laporan...'),
        error: (e, _) => ErrorDisplayWidget(message: e.toString()),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.account_balance_wallet,
              title: 'Belum Ada Transaksi',
              subtitle: 'Transaksi akan muncul otomatis dari aktivitas',
            );
          }

          double totalIncome = 0;
          for (final t in list) {
            totalIncome += t.jumlah;
          }

          return Column(
            children: [
              // Total card
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
                    const Text('Total Pendapatan',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatCurrency(totalIncome),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${list.length} transaksi',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // Transaction list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final t = list[i];
                    IconData icon;
                    Color color;
                    switch (t.kategori) {
                      case 'kamar':
                        icon = Icons.hotel;
                        color = AppTheme.primaryColor;
                        break;
                      case 'motor':
                        icon = Icons.two_wheeler;
                        color = AppTheme.secondaryColor;
                        break;
                      case 'laundry':
                        icon = Icons.local_laundry_service;
                        color = AppTheme.infoColor;
                        break;
                      case 'minuman':
                        icon = Icons.local_drink;
                        color = AppTheme.accentColor;
                        break;
                      default:
                        icon = Icons.receipt;
                        color = AppTheme.textSecondary;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        title: Text(
                          t.kategori.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          Helpers.formatDateTime(t.tanggal),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          '+${Helpers.formatCurrency(t.jumlah)}',
                          style: const TextStyle(
                            color: AppTheme.successColor,
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
