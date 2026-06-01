import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rnd_proj/features/auth/providers/auth_provider.dart';
import 'package:rnd_proj/features/auth/screens/login_screen.dart';
import 'package:rnd_proj/features/auth/screens/register_screen.dart';
import 'package:rnd_proj/features/dashboard/screens/home_screen.dart';
import 'package:rnd_proj/features/dashboard/screens/room_type_detail_screen.dart';
import 'package:rnd_proj/features/reservation/screens/reservation_screen.dart';
import 'package:rnd_proj/features/motor/screens/motor_screen.dart';
import 'package:rnd_proj/features/laundry/screens/laundry_screen.dart';
import 'package:rnd_proj/features/room_services/screens/room_service_screen.dart';
import 'package:rnd_proj/features/drinks/screens/drinks_screen.dart';
import 'package:rnd_proj/features/history/order_history_screen.dart';
import 'package:rnd_proj/features/payment/screens/payment_screen.dart';
import 'package:rnd_proj/features/dashboard/models/room_type_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) {
        return null;
      }

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;
      final location = state.uri.toString();

      if (!isLoggedIn) {
        if (location != '/login' && location != '/register') {
          return '/login';
        }
      } else {
        if (location == '/login' || location == '/register') {
          return '/';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reservation',
        builder: (context, state) => const ReservationScreen(),
      ),
      GoRoute(
        path: '/motor',
        builder: (context, state) => const MotorScreen(),
      ),
      GoRoute(
        path: '/laundry',
        builder: (context, state) => const LaundryScreen(),
      ),
      GoRoute(
        path: '/room-service',
        builder: (context, state) => const RoomServiceScreen(),
      ),
      GoRoute(
        path: '/drinks',
        builder: (context, state) => const DrinksScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentScreen(
            totalAmount: extra['totalAmount'] as double,
            onPaymentSuccess: extra['onPaymentSuccess'] as FutureOr<void> Function(),
          );
        },
      ),
      GoRoute(
        path: '/room-type-detail',
        builder: (context, state) {
          final roomType = state.extra as RoomTypeModel;
          return RoomTypeDetailScreen(roomType: roomType);
        },
      ),
    ],
  );
});
