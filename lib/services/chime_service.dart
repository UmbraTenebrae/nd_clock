import 'package:audioplayers/audioplayers.dart';

/// Plays the event chime. Uses a single shared player so rapid back-to-back
/// triggers don't pile up — each call stops the previous playback first.
class ChimeService {
  ChimeService._();

  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('chime.mp3'));
    } catch (_) {
      // Audio playback failures should never crash the UI or block work.
    }
  }
}
