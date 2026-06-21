import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';
import 'package:rnd_proj/core/utils/helpers.dart';
import 'package:rnd_proj/features/room_services/providers/room_service_provider.dart';
import 'package:rnd_proj/features/reservation/providers/reservation_provider.dart';
import 'package:rnd_proj/widgets/shared_widgets.dart';

class RoomServiceScreen extends ConsumerStatefulWidget {
  const RoomServiceScreen({super.key});

  @override
  ConsumerState<RoomServiceScreen> createState() => _RoomServiceScreenState();
}

class _RoomServiceScreenState extends ConsumerState<RoomServiceScreen>
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
        title: const Text('Room Service'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.cleaning_services_rounded), text: 'Status'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'Minta Layanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RoomServiceStatusTab(onRequestTap: () {
            _tabController.animateTo(1);
          }),
          const _RoomServiceRequestTab(),
        ],
      ),
    );
  }
}

// =================== STATUS TAB ===================

class _RoomServiceStatusTab extends ConsumerWidget {
  final VoidCallback onRequestTap;

  const _RoomServiceStatusTab({required this.onRequestTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(roomServiceStreamProvider);
    final roomsAsync = ref.watch(ruanganStreamProvider);
    final rooms = roomsAsync.valueOrNull ?? [];

    return serviceAsync.when(
      loading: () => const LoadingWidget(message: 'Memuat status...'),
      error: (e, _) => ErrorDisplayWidget(message: e.toString()),
      data: (list) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.roomService, AppColors.roomServiceLight],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roomService.withValues(alpha: 0.3),
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
                      child: const Icon(Icons.cleaning_services_rounded,
                          color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Room Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Minta pembersihan kamar kapan saja',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //quick request button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: onRequestTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.roomService,
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Minta Room Service Sekarang'),
                ),
              ),

              const SizedBox(height: 24),

              //request history
              const Text(
                'Permintaan Pembersihan Kamar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (list.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cleaning_services_outlined,
                          size: 40, color: AppColors.textLight),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada permintaan Room Service',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ...list.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                AppColors.roomService.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.cleaning_services,
                              color: AppColors.roomService),
                        ),
                        title: Builder(
                          builder: (_) {
                            final room = rooms.where((r) => r.id == s.roomId).toList();
                            final roomName = room.isNotEmpty ? room.first.nama : s.roomId;
                            return Text('Cleaning Room $roomName',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15));
                          },
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Jadwal: ${Helpers.formatDateTime(s.jadwal)}',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dibuat: ${Helpers.formatDateTime(s.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                            ),
                          ],
                        ),
                        trailing: StatusBadge(status: s.status),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}

// =================== REQUEST TAB ===================

class _RoomServiceRequestTab extends ConsumerStatefulWidget {
  const _RoomServiceRequestTab();

  @override
  ConsumerState<_RoomServiceRequestTab> createState() =>
      _RoomServiceRequestTabState();
}

class _RoomServiceRequestTabState
    extends ConsumerState<_RoomServiceRequestTab> {
  String? _selectedRoomId;
  DateTime _jadwal = DateTime.now().add(const Duration(hours: 1));

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _jadwal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_jadwal),
      );
      if (time != null) {
        setState(() {
          _jadwal = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedRoomId == null) {
      Helpers.showSnackBar(context, 'Pilih kamar Anda terlebih dahulu',
          isError: true);
      return;
    }
    final success =
        await ref.read(roomServiceNotifierProvider.notifier).addRoomService(
              roomId: _selectedRoomId!,
              jadwal: _jadwal,
            );
    if (success && mounted) {
      Helpers.showSnackBar(
          context, 'Permintaan room service berhasil! Kami segera datang 🧹');
      setState(() => _selectedRoomId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(ruanganStreamProvider);
    final formState = ref.watch(roomServiceNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          const InfoBanner(
            message: 'Pilih kamar Anda dan jadwal pembersihan yang diinginkan',
            icon: Icons.info_outline_rounded,
            color: AppColors.roomService,
          ),
          const SizedBox(height: 20),

          const Text('Minta Room Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          roomsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (allRooms) {
              final rooms = allRooms.where((r) => r.status != 'dihapus').toList();
              return DropdownButtonFormField<String>(
                initialValue: _selectedRoomId,
                decoration: const InputDecoration(
                  labelText: 'Kamar Saya',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                items: rooms.map((r) {
                  return DropdownMenuItem(
                      value: r.id, child: Text(r.nama));
                }).toList(),
                onChanged: (v) => setState(() => _selectedRoomId = v),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Jadwal Pembersihan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule,
                      color: AppColors.roomService),
                  const SizedBox(width: 12),
                  Text(Helpers.formatDateTime(_jadwal),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_rounded,
                      color: AppColors.textLight, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: formState is AsyncLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roomService,
              ),
              icon: const Icon(Icons.send_rounded),
              label: const Text('Kirim Permintaan'),
            ),
          ),
        ],
      ),
    );
  }
}
