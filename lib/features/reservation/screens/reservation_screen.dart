import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/features/reservation/providers/reservation_provider.dart';
import 'package:rnd_proj/features/reservation/widgets/available_rooms_tab.dart';
import 'package:rnd_proj/features/reservation/widgets/reservation_form_tab.dart';

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
          AvailableRoomsTab(onBookTap: () {
            _tabController.animateTo(1);
          }),
          const ReservationFormTab(),
        ],
      ),
    );
  }
}
