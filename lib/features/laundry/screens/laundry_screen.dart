import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/laundry/providers/laundry_provider.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class LaundryScreen extends ConsumerStatefulWidget {
  const LaundryScreen({super.key});

  @override
  ConsumerState<LaundryScreen> createState() => _LaundryScreenState();
}

class _LaundryScreenState extends ConsumerState<LaundryScreen>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Laundry'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline_rounded), text: 'Info Layanan'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Pesan Laundry'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LaundryInfoTab(onOrderTap: () {
            _tabController.animateTo(1);
          }),
          const _LaundryFormTab(),
        ],
      ),
    );
  }
}

// =================== INFO TAB ===================

class _LaundryInfoTab extends ConsumerWidget {
  final VoidCallback onOrderTap;

  const _LaundryInfoTab({required this.onOrderTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.local_laundry_service_rounded,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Layanan Laundry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Biarkan kami yang mengurus pakaian kotor Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Price info
          const Text(
            'Informasi Harga',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          _InfoItem(
            icon: Icons.scale_rounded,
            title: 'Harga per KG',
            value: Helpers.formatCurrency(15000),
            color: AppTheme.infoColor,
          ),
          _InfoItem(
            icon: Icons.timer_rounded,
            title: 'Estimasi Waktu',
            value: '1 - 2 Hari Kerja',
            color: AppTheme.secondaryColor,
          ),
          const _InfoItem(
            icon: Icons.dry_cleaning_rounded,
            title: 'Layanan Tersedia',
            value: 'Regular & Express',
            color: AppTheme.primaryColor,
          ),

          const SizedBox(height: 24),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onOrderTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.infoColor,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Pesan Laundry Sekarang'),
            ),
          ),


        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================== FORM TAB ===================

class _LaundryFormTab extends ConsumerStatefulWidget {
  const _LaundryFormTab();

  @override
  ConsumerState<_LaundryFormTab> createState() => _LaundryFormTabState();
}

class _LaundryFormTabState extends ConsumerState<_LaundryFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nomorKamarCtrl = TextEditingController();
  final double _hargaPerKG = 15000;
  String _selectedJenis = 'Regular';

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
    _nomorKamarCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaCtrl.text.trim();
    final nomorKamar = _nomorKamarCtrl.text.trim();
    final tamuLabel = 'Laundry [$nomorKamar] - $nama';
    const double harga = 0;

    final success = await ref
        .read(laundryNotifierProvider.notifier)
        .addLaundry(
          tamuId: tamuLabel,
          jenis: _selectedJenis,
          beratKG: 0,
          hargaPerKG: _hargaPerKG,
          harga: harga,
          userId: ref.read(authStateProvider).valueOrNull?.uid ?? '',
        );
    if (success && mounted) {
      Helpers.showSnackBar(
          context, 'Permintaan laundry berhasil dikirim! 👕');
      _nomorKamarCtrl.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(laundryNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
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
                      'Pilih jenis layanan, isi nama dan nomor kamar Anda',
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

            const Text('Pesan Layanan Laundry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Jenis layanan dropdown
            DropdownButtonFormField<String>(
              value: _selectedJenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Layanan',
                prefixIcon: Icon(Icons.dry_cleaning_rounded),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'Regular', child: Text('Regular')),
                DropdownMenuItem(
                    value: 'Express', child: Text('Express')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedJenis = v);
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama Anda',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nama wajib diisi';
                return null;
              },
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _nomorKamarCtrl,
              decoration: const InputDecoration(
                labelText: 'Nomor Kamar',
                hintText: 'Masukkan nomor kamar',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nomor kamar wajib diisi';
                return null;
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: formState is AsyncLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.infoColor,
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Kirim Pesanan Laundry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
