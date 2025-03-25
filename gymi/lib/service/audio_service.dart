import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playMusic() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player
        .play(AssetSource('audio/gymiBgm.mp3')); // assets/audio/bgm.mp3
    _isPlaying = true;
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> toggleMusic() async {
    if (_isPlaying) {
      await stopMusic();
    } else {
      await playMusic();
    }
  }
}
