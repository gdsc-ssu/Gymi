import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> _initializePlayer() async {
    if (_player == null) {
      _player = AudioPlayer();
    }
  }

  Future<void> playMusic() async {
    try {
      await _initializePlayer();
      await _player?.setReleaseMode(ReleaseMode.loop);
      await _player?.play(AssetSource('audio/gymiBgm.mp3')); // assets/audio/bgm.mp3
      _isPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        print('오디오 재생 중 오류 발생: $e');
      }
      _isPlaying = false;
    }
  }

  Future<void> stopMusic() async {
    try {
      await _player?.stop();
      _isPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        print('오디오 중지 중 오류 발생: $e');
      }
    }
  }

  Future<void> toggleMusic() async {
    try {
      if (_isPlaying) {
        await stopMusic();
      } else {
        await playMusic();
      }
    } catch (e) {
      if (kDebugMode) {
        print('오디오 토글 중 오류 발생: $e');
      }
    }
  }

  Future<void> dispose() async {
    try {
      await stopMusic();
      await _player?.dispose();
      _player = null;
    } catch (e) {
      if (kDebugMode) {
        print('오디오 서비스 정리 중 오류 발생: $e');
      }
    }
  }
}
