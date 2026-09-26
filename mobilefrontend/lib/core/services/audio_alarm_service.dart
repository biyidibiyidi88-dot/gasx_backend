import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioAlarmService {
  static final AudioAlarmService _instance = AudioAlarmService._internal();
  static AudioAlarmService get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  AudioAlarmService._internal() {
    _init();
  }

  void _init() {
    if (_initialized) return;
    try {
      _player.setReleaseMode(ReleaseMode.release);
      _initialized = true;
    } catch (e) {
      debugPrint('AudioAlarmService initialization error: $e');
    }
  }

  Future<void> playAlarm() async {
    try {
      debugPrint('AudioAlarmService: Playing assets/sound/alarm.mp3');
      // For audioplayers ^6.0.0, asset path is relative to the assets/ directory.
      // So assets/sound/alarm.mp3 is loaded via AssetSource('sound/alarm.mp3').
      await _player.play(AssetSource('sound/alarm.mp3'));
    } catch (e) {
      debugPrint('AudioAlarmService play error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('AudioAlarmService stop error: $e');
    }
  }
}
