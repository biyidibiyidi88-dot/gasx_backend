import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'presentation/routing/app_router.dart';
import 'domain/providers/auth_provider.dart';
import 'domain/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: GaSXApp()));
}

class GaSXApp extends ConsumerWidget {
  const GaSXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authStateProvider);

    // Keep alert listening alive app-wide so an incoming gas leak can sound
    // even while the user is on a screen other than the dashboard.
    if (authState.user != null) {
      ref.watch(notificationsProvider);
    }

    return MaterialApp.router(
      title: 'GaSX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
