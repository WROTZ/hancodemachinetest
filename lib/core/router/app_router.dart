
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/phone_otp_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/services/service_listing_screen.dart'; // Corrected import
import '../../features/bookings/bookings_screen.dart'; // Added bookings screen
import '../../features/cart/cart_screen.dart';
import '../../features/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/phone';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/phone', builder: (context, state) => const PhoneOtpScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/services', builder: (context, state) => const ServiceListingScreen()), // Corrected class name
      GoRoute(path: '/bookings', builder: (context, state) => const BookingsScreen()), // Added route
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
});
