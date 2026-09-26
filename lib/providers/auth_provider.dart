import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/leaderboard/leaderboard_screen.dart';
import '../presentation/screens/map/map_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/report/report_flow.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/widgets/bottom_nav_bar.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges(),
  );

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: AppRoutes.leaderboard,
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.report,
        builder: (context, state) => const ReportFlowScreen(),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated =
          ref.read(authRepositoryProvider).currentUser != null;
      final location = state.matchedLocation;

      if (!isAuthenticated &&
          location != AppRoutes.login &&
          location != AppRoutes.register &&
          location != AppRoutes.splash) {
        return AppRoutes.login;
      }

      if (isAuthenticated &&
          (location == AppRoutes.login ||
              location == AppRoutes.register ||
              location == AppRoutes.splash)) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
