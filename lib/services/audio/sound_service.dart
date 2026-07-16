import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays UI sound effects; failures are silent by design — sound is
/// atmosphere, never a blocker.
class SoundService {
  final _player = AudioPlayer();

  Future<void> playShake() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/shake.wav'));
    } catch (e) {
      debugPrint('SoundService: $e');
    }
  }

  /// The clack of the moon blocks (筊杯) landing.
  Future<void> playCast() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/jiaobei.wav'));
    } catch (e) {
      debugPrint('SoundService: $e');
    }
  }

  void dispose() => _player.dispose();
}
