import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsState {
  final bool audioAlarmEnabled;
  final bool pushNotificationsEnabled;
  final bool emailAlertsEnabled;
  final bool smsAlertsEnabled;
  final double lowLevelWarningThreshold;

  const SettingsState({
    required this.audioAlarmEnabled,
    required this.pushNotificationsEnabled,
    required this.emailAlertsEnabled,
    required this.smsAlertsEnabled,
    required this.lowLevelWarningThreshold,
  });

  SettingsState copyWith({
    bool? audioAlarmEnabled,
    bool? pushNotificationsEnabled,
    bool? emailAlertsEnabled,
    bool? smsAlertsEnabled,
    double? lowLevelWarningThreshold,
  }) {
    return SettingsState(
      audioAlarmEnabled: audioAlarmEnabled ?? this.audioAlarmEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailAlertsEnabled: emailAlertsEnabled ?? this.emailAlertsEnabled,
      smsAlertsEnabled: smsAlertsEnabled ?? this.smsAlertsEnabled,
      lowLevelWarningThreshold: lowLevelWarningThreshold ?? this.lowLevelWarningThreshold,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final _storage = const FlutterSecureStorage();

  SettingsNotifier()
      : super(const SettingsState(
          audioAlarmEnabled: true,
          pushNotificationsEnabled: true,
          emailAlertsEnabled: false,
          smsAlertsEnabled: true,
          lowLevelWarningThreshold: 20.0,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final audioEnabledStr = await _storage.read(key: 'audioAlarmEnabled') ?? 'true';
      final pushEnabledStr = await _storage.read(key: 'pushNotificationsEnabled') ?? 'true';
      final emailEnabledStr = await _storage.read(key: 'emailAlertsEnabled') ?? 'false';
      final smsEnabledStr = await _storage.read(key: 'smsAlertsEnabled') ?? 'true';
      final lowLevelStr = await _storage.read(key: 'lowLevelWarningThreshold') ?? '20.0';

      state = SettingsState(
        audioAlarmEnabled: audioEnabledStr == 'true',
        pushNotificationsEnabled: pushEnabledStr == 'true',
        emailAlertsEnabled: emailEnabledStr == 'true',
        smsAlertsEnabled: smsEnabledStr == 'true',
        lowLevelWarningThreshold: double.tryParse(lowLevelStr) ?? 20.0,
      );
    } catch (_) {
      // Ignore read errors, stay with defaults
    }
  }

  Future<void> setAudioAlarmEnabled(bool value) async {
    state = state.copyWith(audioAlarmEnabled: value);
    await _storage.write(key: 'audioAlarmEnabled', value: value.toString());
  }

  Future<void> setPushNotificationsEnabled(bool value) async {
    state = state.copyWith(pushNotificationsEnabled: value);
    await _storage.write(key: 'pushNotificationsEnabled', value: value.toString());
  }

  Future<void> setEmailAlertsEnabled(bool value) async {
    state = state.copyWith(emailAlertsEnabled: value);
    await _storage.write(key: 'emailAlertsEnabled', value: value.toString());
  }

  Future<void> setSmsAlertsEnabled(bool value) async {
    state = state.copyWith(smsAlertsEnabled: value);
    await _storage.write(key: 'smsAlertsEnabled', value: value.toString());
  }

  Future<void> setLowLevelWarningThreshold(double value) async {
    state = state.copyWith(lowLevelWarningThreshold: value);
    await _storage.write(key: 'lowLevelWarningThreshold', value: value.toString());
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
