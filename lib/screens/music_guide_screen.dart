import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reading_screen.dart';

enum ReadingType {
  konsonan,
  sengau,
}

class MusicGuideScreen extends StatefulWidget {
  final ReadingType type;
  final String? initialChapterId;
  final int? initialPageIndex;

  const MusicGuideScreen({
    super.key,
    required this.type,
    this.initialChapterId,
    this.initialPageIndex,
  });

  @override
  State<MusicGuideScreen> createState() => _MusicGuideScreenState();
}

class _MusicGuideScreenState extends State<MusicGuideScreen> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _waveController;

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<void>? _completeSubscription;

  String get _title {
    switch (widget.type) {
      case ReadingType.konsonan:
        return 'Konsonan';
      case ReadingType.sengau:
        return 'Sengau';
    }
  }

  String get _audioAssetPath {
    switch (widget.type) {
      case ReadingType.konsonan:
        return 'audio/music/konsonan.MP3';
      case ReadingType.sengau:
        return 'audio/music/sengau.MP3';
    }
  }

  Color get _themeColor {
    switch (widget.type) {
      case ReadingType.konsonan:
        return Colors.orange.shade500;
      case ReadingType.sengau:
        return Colors.purple.shade400;
    }
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _listenAudioPlayer();
  }

  void _listenAudioPlayer() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          if (state == PlayerState.playing) {
            _waveController.repeat(reverse: true);
          } else {
            _waveController.stop();
          }
        });
      }
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.completed;
          _position = Duration.zero;
          _waveController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    try {
      await _audioPlayer.play(AssetSource(_audioAssetPath));
    } catch (e) {
      try {
        final fallbackPath = _audioAssetPath.replaceAll('.MP3', '.mp3');
        await _audioPlayer.play(AssetSource(fallbackPath));
      } catch (e2) {
        debugPrint('Audio asset error: $e2');
      }
    }
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
      _playerState = PlayerState.stopped;
    });
  }

  Future<void> _restart() async {
    await _audioPlayer.stop();
    await _play();
  }

  void _navigateToReadingScreen() async {
    await _audioPlayer.stop();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ReadingScreen(
          type: widget.type,
          initialChapterId: widget.initialChapterId,
          initialPageIndex: widget.initialPageIndex,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade100,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                // Top Header Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await _audioPlayer.stop();
                        if (mounted) Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.2),
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Panduan Membaca & Menyanyi',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.blue.shade900.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Main Compact Player Card (Zero Scroll Required)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade900.withOpacity(0.15),
                          offset: const Offset(0, 6),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 4),
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: _themeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _themeColor, width: 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.music_note_rounded, color: _themeColor, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tipe: $_title',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _themeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Musical Note Graphic Circle (Animated Glow)
                            AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                final blurRadius = isPlaying ? 8.0 + (_waveController.value * 12.0) : 8.0;
                                final spreadRadius = isPlaying ? _waveController.value * 4.0 : 0.0;
                                return Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        _themeColor.withOpacity(0.9),
                                        _themeColor,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _themeColor.withOpacity(isPlaying ? 0.6 : 0.35),
                                        offset: const Offset(0, 4),
                                        blurRadius: blurRadius,
                                        spreadRadius: spreadRadius,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Status Subtitle
                            Text(
                              isPlaying
                                  ? 'Mendengarkan Lagunya...'
                                  : (_playerState == PlayerState.paused ? 'Lagu Di-pause' : 'Tekan Play Untuk Memutar Panduan'),
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Audio Slider & Duration
                            if (_duration > Duration.zero)
                              SizedBox(
                                width: 260,
                                child: Column(
                                  children: [
                                    SliderTheme(
                                      data: SliderThemeData(
                                        trackHeight: 4,
                                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      ),
                                      child: Slider(
                                        activeColor: _themeColor,
                                        inactiveColor: _themeColor.withOpacity(0.2),
                                        min: 0.0,
                                        max: _duration.inMilliseconds.toDouble(),
                                        value: _position.inMilliseconds.toDouble().clamp(0.0, _duration.inMilliseconds.toDouble()),
                                        onChanged: (value) async {
                                          final seekPosition = Duration(milliseconds: value.toInt());
                                          await _audioPlayer.seek(seekPosition);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(_position),
                                            style: GoogleFonts.fredoka(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                          Text(
                                            _formatDuration(_duration),
                                            style: GoogleFonts.fredoka(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 10),

                            // Audio Controls Row (Play, Pause, Stop, Restart)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 1. PLAY / PAUSE
                                _buildControlButton(
                                  icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  label: isPlaying ? 'Pause' : 'Play',
                                  color: isPlaying ? Colors.amber.shade700 : Colors.green.shade600,
                                  onTap: isPlaying ? _pause : _play,
                                  isPrimary: true,
                                ),
                                const SizedBox(width: 16),

                                // 2. STOP
                                _buildControlButton(
                                  icon: Icons.stop_rounded,
                                  label: 'Stop',
                                  color: Colors.red.shade500,
                                  onTap: _stop,
                                ),
                                const SizedBox(width: 16),

                                // 3. RESTART
                                _buildControlButton(
                                  icon: Icons.replay_rounded,
                                  label: 'Restart',
                                  color: Colors.blue.shade500,
                                  onTap: _restart,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bottom Action Button ("Mulai Membaca")
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _navigateToReadingScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.orange.shade900.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Membaca',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final double size = isPrimary ? 54 : 46;
    final double iconSize = isPrimary ? 30 : 22;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.fredoka(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
