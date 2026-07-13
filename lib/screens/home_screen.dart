import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/progress_service.dart';
import 'reading_screen.dart';
import 'practice_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _lastProgress;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressService.getProgress();
    if (mounted) {
      setState(() {
        _lastProgress = progress;
      });
    }
  }

  void _navigateToReading({String? startChapterId, int? startPageIndex}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingScreen(
          initialChapterId: startChapterId,
          initialPageIndex: startPageIndex,
        ),
      ),
    ).then((_) => _loadProgress()); // Refresh progress when returning
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
            
            // Clouds
            Positioned(
              top: 30,
              left: 40,
              child: Icon(Icons.cloud, size: 60, color: Colors.white.withOpacity(0.9)),
            ),
            Positioned(
              top: 50,
              right: 80,
              child: Icon(Icons.cloud, size: 80, color: Colors.white.withOpacity(0.8)),
            ),

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
                            _loadProgress();
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
                    
                    // Resume Progress Banner (if exists)
                    if (_lastProgress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () {
                            _navigateToReading(
                              startChapterId: _lastProgress!['chapterId'] as String,
                              startPageIndex: _lastProgress!['pageIndex'] as int,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.yellow.shade800, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 4),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Colors.orange.shade800),
                                const SizedBox(width: 8),
                                Text(
                                  'Lanjutkan Belajar Terakhir Anda',
                                  style: GoogleFonts.fredoka(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
