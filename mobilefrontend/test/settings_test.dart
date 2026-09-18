import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gas_monitor_flutter/domain/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock platform channel for FlutterSecureStorage to prevent MissingPluginException
  setUp(() {
    const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      // Mock returns null representing empty storage/default values
      return null;
    });
  });

  group('SettingsNotifier Tests', () {
    test('initial state has default values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = container.read(settingsProvider);
      
      expect(settings.audioAlarmEnabled, isTrue);
      expect(settings.pushNotificationsEnabled, isTrue);
      expect(settings.emailAlertsEnabled, isFalse);
      expect(settings.smsAlertsEnabled, isTrue);
      expect(settings.lowLevelWarningThreshold, 20.0);
    });

    test('updating fields modifies the state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);

      // Disable audio alarm
      await notifier.setAudioAlarmEnabled(false);
      var state = container.read(settingsProvider);
      expect(state.audioAlarmEnabled, isFalse);

      // Update threshold
      await notifier.setLowLevelWarningThreshold(12.5);
      state = container.read(settingsProvider);
      expect(state.lowLevelWarningThreshold, 12.5);
    });
  });
}

