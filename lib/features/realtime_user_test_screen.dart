// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class RealtimeUserTestScreen extends StatefulWidget {
//   const RealtimeUserTestScreen({super.key});

//   @override
//   State<RealtimeUserTestScreen> createState() => _RealtimeUserTestScreenState();
// }

// class _RealtimeUserTestScreenState extends State<RealtimeUserTestScreen> {
//   final _firestore = FirebaseFirestore.instance;
//   String _status = 'Menunggu Ping dari Admin...';
//   int _pongCount = 0;

//   @override
//   void initState() {
//     super.initState();

//     // User memantau jika ada kiriman 'ping' dari Admin
//     _firestore
//         .collection('realtime_test')
//         .doc('two_devices')
//         .snapshots()
//         .listen((snapshot) async {
//       if (snapshot.exists) {
//         final data = snapshot.data();
//         // Jika mendeteksi status 'ping' dari Admin
//         if (data != null && data['status'] == 'ping') {
//           final timestamp = data['timestamp'];
          
//           setState(() {
//             _status = 'Ping diterima! Membalas...';
//           });

//           // Balas secara otomatis dengan mengubah status menjadi 'pong'
//           await _firestore
//               .collection('realtime_test')
//               .doc('two_devices')
//               .set({
//                 'status': 'pong',
//                 'timestamp': timestamp,
//               });

//           setState(() {
//             _pongCount++;
//             _status = 'Membalas Ping ($_pongCount kali)';
//           });
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Uji Latensi 2 Perangkat (User)')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.phonelink_setup_rounded,
//               size: 80,
//               color: Colors.blue,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               _status,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'Biarkan halaman ini tetap terbuka di HP User.',
//               style: TextStyle(color: Colors.grey, fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
