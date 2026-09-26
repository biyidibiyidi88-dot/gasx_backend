import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/buy_gas_screen.dart';
import '../screens/gas_map_screen.dart';
import '../screens/vendor_inventory_screen.dart';
import '../screens/delivery_workspace_screen.dart';
import '../widgets/main_scaffold.dart';
import '../../domain/providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, _) => notifyListeners());
  }

  String _home(String role) {
    if (role == 'gas_supplier') return '/supplier-inventory';
    if (role == 'delivery_person') return '/delivery-workspace';
    return '/dashboard';
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final user = _ref.read(authStateProvider).user;
    final location = state.matchedLocation;
    final isPublic =
        location == '/login' ||
        location == '/register' ||
        location == '/onboarding' ||
        location == '/landing';
    if (user == null) return isPublic ? null : '/login';

    final role = user.role.toLowerCase();
    if (isPublic) return _home(role);
    if (location == '/settings') return null;
    if (role == 'gas_supplier') {
      return [
            '/supplier-inventory',
            '/supplier-orders',
            '/profile',
          ].any(location.startsWith)
          ? null
          : _home(role);
    }
    if (role == 'delivery_person') {
      return [
            '/delivery-workspace',
            '/map',
            '/profile',
          ].any(location.startsWith)
          ? null
          : _home(role);
    }
    return [
          '/dashboard',
          '/buy-gas',
          '/map',
          '/orders',
          '/notifications',
          '/ai-chat',
          '/profile',
        ].any(location.startsWith)
        ? null
        : _home(role);
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: notifier,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
          ),
          GoRoute(
            path: '/buy-gas',
            builder: (context, state) => const BuyGasScreen(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const GasMapScreen(),
          ),
          GoRoute(
            path: '/ai-chat',
            builder: (context, state) => const AIChatScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const DeliveryWorkspaceScreen(),
          ),
          GoRoute(
            path: '/supplier-inventory',
            builder: (context, state) => const VendorInventoryScreen(),
          ),
          GoRoute(
            path: '/supplier-orders',
            builder: (context, state) => const DeliveryWorkspaceScreen(),
          ),
          GoRoute(
            path: '/delivery-workspace',
            builder: (context, state) => const DeliveryWorkspaceScreen(),
          ),
        ],
      ),
    ],
    redirect: notifier.redirect,
  );
});
