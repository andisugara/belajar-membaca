import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;
  set isMuted(bool value) {
    _isMuted = value;
    if (_isMuted) {
      _player.setVolume(0);
    } else {
      _player.setVolume(1);
    }
  }

  /// Memutar file audio dari folder assets (misal: 'assets/audio/words/ba.mp3')
  Future<void> playAsset(String assetPath) async {
    if (_isMuted) return;
    
    try {
      // Hentikan audio yang sedang berjalan terlebih dahulu
      await _player.stop();
      
      // Bersihkan path jika mengandung prefix assets/ untuk audioplayers
      // Di audioplayers v6+, AssetSource mengharapkan path relatif terhadap folder assets/
      String cleanPath = assetPath;
      if (cleanPath.startsWith('assets/')) {
        cleanPath = cleanPath.substring(7);
      }
      
      debugPrint('Playing audio asset: assets/$cleanPath');
      await _player.play(AssetSource(cleanPath));
    } catch (e) {
      debugPrint('Error playing audio $assetPath: $e');
      // Kita tangkap error secara halus agar aplikasi tidak crash jika asset belum disiapkan oleh user.
    }
  }

  /// Menghentikan audio yang sedang diputar
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// Membuang player dari memori
  void dispose() {
    _player.dispose();
  }
}
