import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rnd_proj/firebase_options.dart';
import 'package:rnd_proj/core/theme/app_theme.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/features/auth/screens/login_screen.dart';
import 'package:rnd_proj/features/dashboard/screens/home_screen.dart';
import 'package:rnd_proj/features/reservation/screens/reservation_screen.dart';
import 'package:rnd_proj/features/motor/screens/motor_screen.dart';
import 'package:rnd_proj/features/laundry/screens/laundry_screen.dart';
import 'package:rnd_proj/features/room_services/screens/room_service_screen.dart';
import 'package:rnd_proj/features/drinks/screens/drinks_screen.dart';
import 'package:rnd_proj/features/history/order_history_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Tracks whether Firebase was successfully initialized
bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init failed: $e');
    debugPrint('Running in offline/demo mode.');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If Firebase is not initialized, show LoginScreen
    // (it will show error on login attempt which is fine)
    Widget homeWidget;

    if (!firebaseInitialized) {
      homeWidget = const LoginScreen();
    } else {
      final authState = ref.watch(authStateProvider);
      homeWidget = authState.when(
        data: (user) {
          if (user != null) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        ),
        error: (_, __) => const LoginScreen(),
      );
    }

    return MaterialApp(
      title: 'RnD Dewi Sri Bali',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: homeWidget,
      routes: {
        '/reservation': (context) => const ReservationScreen(),
        '/motor': (context) => const MotorScreen(),
        '/laundry': (context) => const LaundryScreen(),
        '/room-service': (context) => const RoomServiceScreen(),
        '/drinks': (context) => const DrinksScreen(),
        '/history': (context) => const OrderHistoryScreen(),
      },
    );
  }
}
