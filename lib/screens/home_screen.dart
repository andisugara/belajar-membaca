import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import 'music_guide_screen.dart';
import 'practice_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _navigateToReading({String? startChapterId, int? startPageIndex}) {
    _showTypeSelectionModal(startChapterId: startChapterId, startPageIndex: startPageIndex);
  }

  void _showTypeSelectionModal({String? startChapterId, int? startPageIndex}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pilih Panduan Belajar',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih kategori untuk mendengarkan lagu panduan',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 1. KONSONAN Option
                  _buildTypeCard(
                    title: '1. Konsonan',
                    subtitle: 'Panduan membaca abjad konsonan',
                    icon: Icons.music_note_rounded,
                    color: Colors.orange.shade500,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MusicGuideScreen(
                            type: ReadingType.konsonan,
                            initialChapterId: startChapterId,
                            initialPageIndex: startPageIndex,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // 2. SENGAU Option
                  _buildTypeCard(
                    title: '2. Sengau',
                    subtitle: 'Panduan membaca abjad sengau',
                    icon: Icons.graphic_eq_rounded,
                    color: Colors.purple.shade400,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MusicGuideScreen(
                            type: ReadingType.sengau,
                            initialChapterId: startChapterId,
                            initialPageIndex: startPageIndex,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.4), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToPractice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PracticeScreen(),
      ),
    );
  }

  void _navigateToQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const QuizScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade200,
              Colors.lightBlue.shade400,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background Hills & Clouds
            Positioned(
              bottom: -40,
              left: -50,
              right: -50,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: const BorderRadius.vertical(top: Radius.elliptical(500, 100)),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: 100,
              right: -100,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  borderRadius: const BorderRadius.vertical(top: Radius.elliptical(600, 120)),
                ),
              ),
            ),
            
            // Floating Clouds
            const FloatingCloud(top: 30, size: 70, opacity: 0.8, duration: Duration(seconds: 40)),
            const FloatingCloud(top: 80, size: 100, opacity: 0.6, duration: Duration(seconds: 60)),
            const FloatingCloud(top: 50, size: 60, opacity: 0.7, duration: Duration(seconds: 30)),

            // Main Content Area
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Title Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // Spacer to balance layout
                        Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Belajar Membaca Anak',
                                style: GoogleFonts.fredoka(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue.shade900.withOpacity(0.5),
                                      offset: const Offset(0, 4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Reset progress button or settings button
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                          tooltip: 'Reset Progress Membaca',
                          onPressed: () async {
                            await ProgressService.clearProgress();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Progress belajar telah di-reset!')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Menu Buttons Row
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 1. MEMBACA
                              _buildMenuCard(
                                title: 'Membaca',
                                subtitle: 'Belajar dengan suara',
                                color: Colors.orange,
                                icon: Icons.volume_up_rounded,
                                onTap: () => _navigateToReading(),
                              ),
                              const SizedBox(width: 20),
                              
                              // 2. LATIHAN
                              _buildMenuCard(
                                title: 'Latihan',
                                subtitle: 'Membaca mandiri',
                                color: Colors.teal,
                                icon: Icons.auto_stories_rounded,
                                onTap: _navigateToPractice,
                              ),
                              const SizedBox(width: 20),
                              
                              // 3. KUIS SERU
                              _buildMenuCard(
                                title: 'Kuis Seru',
                                subtitle: 'Uji kemampuan',
                                color: Colors.pink,
                                icon: Icons.emoji_events_rounded,
                                onTap: _navigateToQuiz,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Wave accent on top right
              Positioned(
                top: -30,
                right: -30,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: color.withOpacity(0.15),
                ),
              ),
              
              // Card contents
              Padding(
                padding: const EdgeInsets.all(20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: color,
                        child: Icon(icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: GoogleFonts.fredoka(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingCloud extends StatefulWidget {
  final double top;
  final double size;
  final double opacity;
  final Duration duration;

  const FloatingCloud({
    super.key,
    required this.top,
    required this.size,
    required this.opacity,
    required this.duration,
  });

  @override
  State<FloatingCloud> createState() => _FloatingCloudState();
}

class _FloatingCloudState extends State<FloatingCloud> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1.2, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double left = screenWidth * ((_animation.value + 1) / 2) - widget.size;
        return Positioned(
          top: widget.top,
          left: left,
          child: Opacity(
            opacity: widget.opacity,
            child: Icon(
              Icons.cloud,
              size: widget.size,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
