import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );

    // Navigasi ke HomeScreen setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Colors.blue.shade300,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Awan-awan lucu di background
            Positioned(
              top: 50,
              left: 80,
              child: Opacity(
                opacity: 0.6,
                child: Icon(Icons.cloud, size: 80, color: Colors.white.withOpacity(0.8)),
              ),
            ),
            Positioned(
              bottom: 80,
              right: 120,
              child: Opacity(
                opacity: 0.6,
                child: Icon(Icons.cloud, size: 100, color: Colors.white.withOpacity(0.8)),
              ),
            ),
            
            // Konten Tengah
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            offset: const Offset(0, 10),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Text(
                        'Yuk Membaca!',
                        style: GoogleFonts.fredoka(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                          shadows: [
                            Shadow(
                              color: Colors.yellow.shade100,
                              offset: const Offset(2, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Progress Bar Lucu
                  SizedBox(
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        minHeight: 12,
                        backgroundColor: Colors.white30,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Memuat permainan...',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
