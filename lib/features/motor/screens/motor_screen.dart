import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rnd_proj/features/motor/providers/motor_provider.dart';
import 'package:rnd_proj/features/motor/widgets/motor_list_tab.dart';
import 'package:rnd_proj/features/motor/widgets/motor_sewa_form_tab.dart';

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
          MotorListTab(onRentTap: () {
            _tabController.animateTo(1);
          }),
          MotorSewaFormTab(
            onSuccess: () {
              _tabController.animateTo(0);
            },
          ),
        ],
      ),
    );
  }
}
