import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/core/entities/ruangan_entity.dart';
import 'package:rnd_proj/features/reservation/providers/reservation_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:rnd_proj/core/services/storage_service.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/features/payment/screens/payment_screen.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class ReservationScreen extends ConsumerStatefulWidget {
  const ReservationScreen({super.key});

  @override
  ConsumerState<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends ConsumerState<ReservationScreen>
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
    final roomsAsync = ref.watch(ruanganStreamProvider);
    ref.listen(reservasiStreamProvider, (previous, next) {
      if (next.hasValue && roomsAsync.hasValue) {
        ref.read(reservationNotifierProvider.notifier).autoCheckExpired(next.value!, roomsAsync.value!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservasi Kamar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.meeting_room_rounded), text: 'Kamar Tersedia'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Pesan Kamar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AvailableRoomsTab(onBookTap: () {
            _tabController.animateTo(1);
          }),
          const _ReservationFormTab(),
        ],
      ),
    );
  }
}

// =================== AVAILABLE ROOMS TAB ===================

class _AvailableRoomsTab extends ConsumerWidget {
  final VoidCallback onBookTap;

  const _AvailableRoomsTab({required this.onBookTap});

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
        final occupiedRooms =
            rooms.where((r) => r.status != 'tersedia').toList();

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
                        // const SizedBox(height: 2),
                        // Text(
                        //   'dari ${rooms.length} total kamar',
                        //   style: TextStyle(
                        //     color: Colors.white.withValues(alpha: 0.8),
                        //     fontSize: 13,
                        //   ),
                        // ),
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

              // Occupied rooms
              // if (occupiedRooms.isNotEmpty) ...[
              //   const SizedBox(height: 16),
              //   const Row(
              //     children: [
              //       Icon(Icons.do_not_disturb_rounded,
              //           color: AppTheme.warningColor, size: 20),
              //       SizedBox(width: 8),
              //       Text(
              //         'Tidak Tersedia',
              //         style: TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w700,
              //           color: AppTheme.textPrimary,
              //         ),
              //       ),
              //     ],
              //   ),
                // const SizedBox(height: 12),
                // ...occupiedRooms.map((room) => Card(
                //       margin: const EdgeInsets.only(bottom: 12),
                //       child: Padding(
                //         padding: const EdgeInsets.all(16),
                //         child: Row(
                //           children: [
                //             Container(
                //               padding: const EdgeInsets.all(12),
                //               decoration: BoxDecoration(
                //                 color: AppTheme.warningColor
                //                     .withValues(alpha: 0.12),
                //                 borderRadius: BorderRadius.circular(14),
                //               ),
                //               child: const Icon(Icons.king_bed_rounded,
                //                   color: AppTheme.warningColor, size: 28),
                //             ),
                //             const SizedBox(width: 14),
                //             Expanded(
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     room.nama,
                //                     style: const TextStyle(
                //                       fontSize: 16,
                //                       fontWeight: FontWeight.w700,
                //                     ),
                //                   ),
                //                   const SizedBox(height: 4),
                //                   Text(
                //                     '${Helpers.formatCurrency(room.hargaBulanan)} / bulan',
                //                     style: const TextStyle(
                //                       color: AppTheme.textSecondary,
                //                       fontWeight: FontWeight.w600,
                //                       fontSize: 14,
                //                     ),
                //                   ),
                //                   const SizedBox(height: 4),
                //                   StatusBadge(status: room.status),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     )),
              // ],
            ],
          ),
        );
      },
    );
  }
}

// =================== FORM TAB ===================

class _ReservationFormTab extends ConsumerStatefulWidget {
  const _ReservationFormTab();

  @override
  ConsumerState<_ReservationFormTab> createState() =>
      _ReservationFormTabState();
}

class _ReservationFormTabState extends ConsumerState<_ReservationFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();

  XFile? _idCardImage;
  final _imagePicker = ImagePicker();
  bool _isUploading = false;

  String? _selectedRoomId;
  RuanganEntity? _selectedRoom;
  String _tipePesanan = 'bulanan';
  DateTime _checkin = DateUtils.dateOnly(DateTime.now());
  late DateTime _checkout = DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 30));

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source);
    if (picked != null) {
      setState(() => _idCardImage = picked);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill user name if available
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
    _hpCtrl.dispose();
    super.dispose();
  }

  double get _total {
    if (_selectedRoom == null) return 0;
    
    final cIn = DateUtils.dateOnly(_checkin);
    final cOut = DateUtils.dateOnly(_checkout);
    int days = cOut.difference(cIn).inDays;
    if (days <= 0) days = 1;

    double totalPrice = 0;
    int remainingNights = days;

    if (_selectedRoom!.hargaBulanan > 0 && remainingNights >= 30) {
      final months = remainingNights ~/ 30;
      totalPrice += months * _selectedRoom!.hargaBulanan;
      remainingNights %= 30;
    }

    if (_selectedRoom!.hargaMingguan > 0 && remainingNights >= 7) {
      final weeks = remainingNights ~/ 7;
      totalPrice += weeks * _selectedRoom!.hargaMingguan;
      remainingNights %= 7;
    }

    totalPrice += remainingNights * _selectedRoom!.harga;

    return totalPrice;
  }

  Future<void> _pickDate(bool isCheckin) async {
    final now = DateUtils.dateOnly(DateTime.now());
    final d = await showDatePicker(
      context: context,
      initialDate: isCheckin ? _checkin : _checkout,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (d != null) {
      setState(() {
        if (isCheckin) {
          _checkin = d;
          if (_tipePesanan == 'bulanan') {
            _checkout = _checkin.add(const Duration(days: 30));
          } else if (_tipePesanan == 'mingguan') {
            _checkout = _checkin.add(const Duration(days: 7));
          } else if (_checkout.isBefore(_checkin)) {
            _checkout = _checkin.add(const Duration(days: 1));
          }
        } else {
          _checkout = d;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null) {
      Helpers.showSnackBar(context, 'Pilih kamar terlebih dahulu', isError: true);
      return;
    }
    if (_idCardImage == null) {
      Helpers.showSnackBar(context, 'Mohon lampirkan foto KTP/Kartu Identitas', isError: true);
      return;
    }

    // Validate overlaps
    final reservationsAsync = ref.read(reservasiStreamProvider);
    if (reservationsAsync.hasValue) {
      final activeRes = reservationsAsync.value!
          .where((r) => r.status == AppConstants.statusAktif && r.roomId == _selectedRoomId)
          .toList();
      for (final res in activeRes) {
        // If the new checkin is strictly before existing checkout, AND new checkout is strictly after existing checkin
        if (_checkin.isBefore(res.checkout) && _checkout.isAfter(res.checkin)) {
          Helpers.showSnackBar(context, 'Kamar sudah dipesan pada rentang tanggal tersebut', isError: true);
          return;
        }
      }
    }

    setState(() => _isUploading = true);

    String? imageUrl = await StorageService.uploadKartuIdentitas(_idCardImage!);

    if (imageUrl == null) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Gagal upload foto. Silakan coba lagi.', isError: true);
        setState(() => _isUploading = false);
      }
      return;
    }

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            totalAmount: _total,
            onPaymentSuccess: () async {
              final ok = await ref
                  .read(reservationNotifierProvider.notifier)
                  .createReservation(
                    namaTamu: _namaCtrl.text.trim(),
                    noHp: _hpCtrl.text.trim(),
                    kartuIdentitas: imageUrl,
                    roomId: _selectedRoomId!,
                    checkin: _checkin,
                    checkout: _checkout,
                    totalHarga: _total,
                    userId: ref.read(authStateProvider).valueOrNull?.uid ?? '',
                  );
              if (ok && mounted) {
                Helpers.showSnackBar(context, 'Reservasi berhasil! Selamat menginap 🎉');
                _namaCtrl.clear();
                _hpCtrl.clear();
                setState(() {
                  _idCardImage = null;
                  _isUploading = false;
                  _selectedRoomId = null;
                  _selectedRoom = null;
                });
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(availableRoomsProvider);
    final formState = ref.watch(reservationNotifierProvider);

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
                      'Isi data diri Anda untuk melakukan reservasi kamar',
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

            const Text('Data Tamu',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _hpCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. HP',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('Foto KTP/Kartu Identitas', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _showImagePickerOptions,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: _idCardImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_idCardImage!.path), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: AppTheme.primaryColor, size: 32),
                              SizedBox(height: 8),
                              Text('Ketuk untuk upload foto KTP', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Pilih Kamar',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            roomsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(children: [
                      Icon(Icons.warning_amber,
                          color: AppTheme.warningColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Maaf, semua kamar sedang terisi. Silakan coba lagi nanti.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ]),
                  );
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedRoomId,
                  decoration: const InputDecoration(
                    labelText: 'Kamar Tersedia',
                    prefixIcon: Icon(Icons.meeting_room_outlined),
                  ),
                  items: rooms
                      .map((r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(
                                '${r.nama} - ${Helpers.formatCurrency(r.hargaBulanan)}/bulan'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedRoomId = v;
                      _selectedRoom = rooms.firstWhere((r) => r.id == v);
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Tipe Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Bulanan', style: TextStyle(fontSize: 14)),
                    value: 'bulanan',
                    groupValue: _tipePesanan,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _tipePesanan = v;
                          _checkout = _checkin.add(const Duration(days: 30));
                        });
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Mingguan', style: TextStyle(fontSize: 14)),
                    value: 'mingguan',
                    groupValue: _tipePesanan,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _tipePesanan = v;
                          _checkout = _checkin.add(const Duration(days: 7));
                        });
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Harian', style: TextStyle(fontSize: 14)),
                    value: 'harian',
                    groupValue: _tipePesanan,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          _tipePesanan = v;
                          _checkout = _checkin.add(const Duration(days: 1));
                        });
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Date pickers
            Row(children: [
              Expanded(
                child: _DateCard(
                  label: 'Check-in',
                  date: _checkin,
                  onTap: () => _pickDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateCard(
                  label: 'Check-out',
                  date: _checkout,
                  onTap: () => _pickDate(false),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A6B52), Color(0xFF2D9B75)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Biaya',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12)),
                      SizedBox(height: 2),
                      Text('Total',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(Helpers.formatCurrency(_total),
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
                onPressed:
                    formState is AsyncLoading || _isUploading ? null : _submit,
                icon: formState is AsyncLoading || _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.book_online_rounded),
                label: const Text('Pesan Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateCard({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.calendar_today,
                  size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 6),
              Text(Helpers.formatDate(date),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ],
        ),
      ),
    );
  }
}
