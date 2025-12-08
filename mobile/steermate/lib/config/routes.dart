import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/main_shell.dart';
import '../screens/trip/pre_trip_screen.dart';
import '../screens/trip/live_trip_screen.dart';
import '../screens/trip/end_trip_screen.dart';
import '../screens/history/trips_list_screen.dart';
import '../screens/history/trip_detail_screen.dart';
import '../screens/analytics/safety_score_screen.dart';
import '../screens/analytics/insights_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/general_settings_screen.dart';
import '../screens/settings/alerts_settings_screen.dart';
import '../screens/settings/permissions_screen.dart';
import '../screens/settings/privacy_settings_screen.dart';
import '../screens/settings/account_settings_screen.dart';
import '../screens/support/help_center_screen.dart';
import '../screens/support/contact_support_screen.dart';
import '../screens/support/about_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      if (isLoggedIn && isLoggingIn && state.matchedLocation != '/') {
        return '/home';
      }
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
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
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/trips',
            builder: (context, state) => const TripsListScreen(),
            routes: [
              GoRoute(
                path: ':tripId',
                builder: (context, state) {
                  final tripId = int.parse(state.pathParameters['tripId']!);
                  return TripDetailScreen(tripId: tripId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const SafetyScoreScreen(),
            routes: [
              GoRoute(
                path: 'insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'general',
                builder: (context, state) => const GeneralSettingsScreen(),
              ),
              GoRoute(
                path: 'alerts',
                builder: (context, state) => const AlertsSettingsScreen(),
              ),
              GoRoute(
                path: 'permissions',
                builder: (context, state) => const PermissionsScreen(),
              ),
              GoRoute(
                path: 'privacy',
                builder: (context, state) => const PrivacySettingsScreen(),
              ),
              GoRoute(
                path: 'account',
                builder: (context, state) => const AccountSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Trip Session Routes (outside shell for fullscreen experience)
      GoRoute(
        path: '/pre-trip',
        builder: (context, state) => const PreTripScreen(),
      ),
      GoRoute(
        path: '/live-trip',
        builder: (context, state) => const LiveTripScreen(),
      ),
      GoRoute(
        path: '/end-trip',
        builder: (context, state) => const EndTripScreen(),
      ),
      
      // Support Routes
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactSupportScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
