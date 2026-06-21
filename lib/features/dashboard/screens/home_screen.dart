import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/core/models/room_type_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userName = authState.isLoading ? '...' : (authState.valueOrNull?.name ?? 'Tamu');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //premium app barr
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.villa_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RnD Dewi Sri',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'Bali Guesthouse',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                ref.read(authNotifierProvider.notifier).signOut();
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Selamat Datang, $userName! 🌴',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nikmati pengalaman menginap nyaman di Bali',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //quick Info Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primaryLight.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Butuh bantuan?',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Hubungi resepsionis kami kapan saja di nomor berikut 081995567139',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //pemanggil quick menu grid realtime testing
          // const SliverToBoxAdapter(
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          //     child: _QuickMenuGrid(),
          //   ),
          // ),

          // Room Types Carousel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'Tipe Kamar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: roomTypesData.length,
                    itemBuilder: (context, index) {
                      final room = roomTypesData[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/room-type-detail', extra: room);
                        },
                        child: Container(
                          width: 300,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                  child: Image.asset(
                                    room.image,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  ),
                                )
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        room.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        room.subtitle,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          //menu grid
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan Kami',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih layanan yang Anda butuhkan',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.1,
                    children: [
                      _MenuCard(
                        icon: Icons.hotel_rounded,
                        title: 'Reservasi\nKamar',
                        subtitle: 'Pesan kamar',
                        gradient: const [AppColors.primary, AppColors.primaryLight],
                        onTap: () => context.push('/reservation'),
                      ),
                      _MenuCard(
                        icon: Icons.two_wheeler_rounded,
                        title: 'Sewa\nMotor',
                        subtitle: 'Jelajahi Bali',
                        gradient: const [AppColors.secondary, AppColors.secondaryLight],
                        onTap: () => context.push('/motor'),
                      ),
                      _MenuCard(
                        icon: Icons.local_laundry_service_rounded,
                        title: 'Laundry',
                        subtitle: 'Layanan cuci',
                        gradient: const [AppColors.info, AppColors.infoLight],
                        onTap: () => context.push('/laundry'),
                      ),
                      _MenuCard(
                        icon: Icons.cleaning_services_rounded,
                        title: 'Room\nService',
                        subtitle: 'Bersihkan kamar',
                        gradient: const [AppColors.roomService, AppColors.roomServiceLight],
                        onTap: () => context.push('/room-service'),
                      ),
                      _MenuCard(
                        icon: Icons.local_cafe_rounded,
                        title: 'Pesan\nMinuman',
                        subtitle: 'Menu minuman',
                        gradient: const [AppColors.accent, AppColors.accentLight],
                        onTap: () => context.push('/drinks'),
                      ),
                      _MenuCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Riwayat\nPesanan',
                        subtitle: 'Lihat transaksi',
                        gradient: const [AppColors.success, AppColors.successLight],
                        onTap: () => context.push('/history'),
                      ),
                      // _MenuCard(
                      //   icon: Icons.speed_rounded,
                      //   title: 'Realtime\nTest',
                      //   subtitle: 'Uji sinkronisasi',
                      //   gradient: const [Color(0xFFF43F5E), Color(0xFFFB7185)],
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const RealtimeTestScreen(),
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // fetch testing
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final stopwatch = Stopwatch()..start();
      //     try {
      //       await FirebaseFirestore.instance.collection('performance_test').get();
      //       stopwatch.stop();
      //       final msg = '✅ Waktu Fetch: ${stopwatch.elapsedMilliseconds} ms';
      //       debugPrint(msg);
      //       if (context.mounted) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text(msg),
      //             backgroundColor: AppTheme.successColor,
      //           ),
      //         );
      //       }
      //     } catch (e) {
      //       final msg = '❌ Error saat fetch: $e';
      //       debugPrint(msg);
      //       if (context.mounted) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text(msg),
      //             backgroundColor: AppTheme.errorColor,
      //           ),
      //         );
      //       }
      //     }
      //   },
      //   backgroundColor: AppTheme.primaryColor,
      //   tooltip: 'Test Firebase Fetch Performance',
      //   child: const Icon(Icons.speed, color: Colors.white),
      // ),

      // insert testing
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     final stopwatch = Stopwatch()..start();
      //     try {
      //       await FirebaseFirestore.instance.collection('performance_test').add({
      //         'test_data': 'Hello Firebase',
      //         'created_at': FieldValue.serverTimestamp(),
      //       });
      //       stopwatch.stop();
      //       final msg = '✅ Waktu Insert: ${stopwatch.elapsedMilliseconds} ms';
      //       debugPrint(msg);
      //       if (context.mounted) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text(msg),
      //             backgroundColor: AppTheme.successColor,
      //           ),
      //         );
      //       }
      //     } catch (e) {
      //       final msg = '❌ Error saat insert: $e';
      //       debugPrint(msg);
      //       if (context.mounted) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text(msg),
      //             backgroundColor: AppTheme.errorColor,
      //           ),
      //         );
      //       }
      //     }
      //   },
      //   backgroundColor: AppTheme.primaryColor,
      //   tooltip: 'Test Firebase Insert Performance',
      //   child: const Icon(Icons.speed, color: Colors.white),
      // ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: gradient.first.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



//Untuk relatime testing
// class _QuickMenuGrid extends ConsumerWidget {
//   final bool isUser;
//   const _QuickMenuGrid({this.isUser = false});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final items = [
//       ('Realtime\nTest', Icons.speed_rounded, const Color(0xFFF43F5E), () {
//         Navigator.push(context, MaterialPageRoute(builder: (context) => const RealtimeUserTestScreen()));
//       }),
//     ];
//     return GridView.count(
//       crossAxisCount: 4,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       children: items.map((item) {
//         return InkWell(
//           onTap: item.$4,
//           borderRadius: BorderRadius.circular(12.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 52,
//                 height: 52,
//                 decoration: BoxDecoration(
//                   color: item.$3.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Icon(item.$2, color: item.$3, size: 26),
//               ),
//               const SizedBox(height: 6),
//               Text(item.$1,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
