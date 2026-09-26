import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/providers/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authStateProvider).user?.role ?? 'client';
    final isSupplier = role == 'gas_supplier';
    final isDriver = role == 'delivery_person';
    final items = isSupplier
        ? const [
            _NavItem(
              Icons.inventory_2_outlined,
              Icons.inventory_2,
              'INVENTORY',
              '/supplier-inventory',
            ),
            _NavItem(
              Icons.receipt_long_outlined,
              Icons.receipt_long,
              'ORDERS',
              '/supplier-orders',
            ),
            _NavItem(Icons.person_outline, Icons.person, 'PROFILE', '/profile'),
          ]
        : isDriver
        ? const [
            _NavItem(
              Icons.local_shipping_outlined,
              Icons.local_shipping,
              'JOBS',
              '/delivery-workspace',
            ),
            _NavItem(Icons.map_outlined, Icons.map, 'MAP', '/map'),
            _NavItem(Icons.person_outline, Icons.person, 'PROFILE', '/profile'),
          ]
        : const [
            _NavItem(
              Icons.dashboard_outlined,
              Icons.dashboard,
              'DASHBOARD',
              '/dashboard',
            ),
            _NavItem(
              Icons.shopping_cart_outlined,
              Icons.shopping_cart,
              'BUY',
              '/buy-gas',
            ),
            _NavItem(Icons.map_outlined, Icons.map, 'MAP', '/map'),
            _NavItem(
              Icons.receipt_long_outlined,
              Icons.receipt_long,
              'ORDERS',
              '/orders',
            ),
            _NavItem(
              Icons.notifications_outlined,
              Icons.notifications,
              'ALERTS',
              '/notifications',
            ),
            _NavItem(Icons.person_outline, Icons.person, 'PROFILE', '/profile'),
          ];
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = items.indexWhere(
      (item) => location.startsWith(item.path),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex < 0 ? 0 : selectedIndex,
          backgroundColor: AppTheme.primaryBg,
          selectedItemColor: AppTheme.accentTeal,
          unselectedItemColor: Colors.white24,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            if (index == items.length) {
              _confirmLogout(context, ref);
              return;
            }
            context.go(items[index].path);
          },
          items: [
            for (final item in items)
              BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.logout_outlined),
              activeIcon: Icon(Icons.logout),
              label: 'LOG OUT',
              tooltip: 'Log out',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.primaryBg,
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppTheme.criticalRed),
            ),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;

    await ref.read(authStateProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.activeIcon, this.label, this.path);
}
