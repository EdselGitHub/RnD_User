import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/drinks/providers/drinks_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/core/models/drink_model.dart';

class DrinksScreen extends ConsumerWidget {
  const DrinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minumanAsync = ref.watch(minumanStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Menu Minuman')),
      body: minumanAsync.when(
        loading: () => const LoadingWidget(message: 'Memuat menu...'),
        error: (e, _) => ErrorDisplayWidget(message: e.toString()),
        data: (drinks) {
          if (drinks.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.local_cafe,
              title: 'Menu Belum Tersedia',
              subtitle: 'Menu minuman sedang dipersiapkan',
            );
          }

          final availableDrinks = drinks.where((d) => d.stok > 0).toList();
          final outOfStock = drinks.where((d) => d.stok <= 0).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
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
                        child: const Icon(Icons.local_cafe_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${availableDrinks.length} Minuman Tersedia',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pilih minuman favorit Anda',
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

                //minuman tersedia
                if (availableDrinks.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.local_cafe_rounded,
                          color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Menu Tersedia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...availableDrinks.map((d) => _DrinkCard(
                        drink: d,
                        onOrder: () => _showOrderDialog(context, ref, d),
                      )),
                ],

                //stok habis
                if (outOfStock.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.remove_shopping_cart_rounded,
                          color: AppColors.textLight, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Stok Habis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...outOfStock.map((d) => _DrinkCard(
                        drink: d,
                        isOutOfStock: true,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOrderDialog(
      BuildContext context, WidgetRef ref, MinumanModel minuman) {
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_cafe,
                  color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Pesan ${minuman.nama}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Harga per item',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  Text(Helpers.formatCurrency(minuman.harga),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Stok tersedia',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                  Text('${minuman.stok}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Pesanan',
                prefixIcon: Icon(Icons.add_shopping_cart_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text) ?? 0;
              if (qty <= 0 || qty > minuman.stok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jumlah tidak valid')),
                );
                return;
              }
              Navigator.pop(ctx);
              final hargaTotal = minuman.harga * qty;
              if (context.mounted) {
                context.push(
                  '/payment',
                  extra: {
                    'totalAmount': hargaTotal.toDouble(),
                    'onPaymentSuccess': () async {
                      final success = await ref
                          .read(drinksNotifierProvider.notifier)
                          .sellDrink(
                            minuman: minuman,
                            qty: qty,
                            userId: ref.read(authStateProvider).valueOrNull?.uid ?? '',
                          );
                      if (success && context.mounted) {
                        Helpers.showSnackBar(
                            context, 'Pesanan berhasil! ☕');
                      }
                    },
                  },
                );
              }
            },
            icon: const Icon(Icons.shopping_cart_checkout_rounded),
            label: const Text('Pesan'),
          ),
        ],
      ),
    );
  }
}

class _DrinkCard extends StatelessWidget {
  final MinumanModel drink;
  final VoidCallback? onOrder;
  final bool isOutOfStock;

  const _DrinkCard({
    required this.drink,
    this.onOrder,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? AppColors.textLight.withValues(alpha: 0.12)
                    : AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_cafe_rounded,
                color: isOutOfStock ? AppColors.textLight : AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(drink.nama,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isOutOfStock
                              ? AppColors.textLight
                              : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    Helpers.formatCurrency(drink.harga),
                    style: TextStyle(
                      color: isOutOfStock
                          ? AppColors.textLight
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOutOfStock
                              ? 'Habis'
                              : 'Stok: ${drink.stok}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isOutOfStock)
              ElevatedButton.icon(
                onPressed: onOrder,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                label: const Text('Pesan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
