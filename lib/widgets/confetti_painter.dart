import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final bool isPlaying;
  const ConfettiWidget({super.key, required this.isPlaying});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        _updateParticles();
      });

    if (widget.isPlaying) {
      _initParticles();
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _initParticles();
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
      setState(() {
        _particles.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles() {
    _particles.clear();
    // Inisialisasi 45 partikel bintang/kertas warna-warni
    for (int i = 0; i < 45; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        size: _random.nextDouble() * 12 + 8,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)].shade400,
        speedY: _random.nextDouble() * 0.015 + 0.008,
        speedX: (_random.nextDouble() - 0.5) * 0.006,
        spinSpeed: (_random.nextDouble() - 0.5) * 0.08,
        angle: _random.nextDouble() * pi * 2,
        isStar: _random.nextBool(),
      ));
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (var p in _particles) {
        p.y += p.speedY;
        p.x += p.speedX;
        p.angle += p.spinSpeed;
        
        // Reset partikel jika keluar dari layar bawah
        if (p.y > 1.0) {
          p.y = -0.1;
          p.x = _random.nextDouble();
        }
        if (p.x < 0.0 || p.x > 1.0) {
          p.speedX = -p.speedX;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ConfettiPainter(_particles),
        ),
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double size;
  Color color;
  double speedY;
  double speedX;
  double spinSpeed;
  double angle;
  bool isStar;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speedY,
    required this.speedX,
    required this.spinSpeed,
    required this.angle,
    required this.isStar,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      if (p.y < -0.1) continue;

      final px = p.x * size.width;
      final py = p.y * size.height;
      
      paint.color = p.color;
      
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.angle);
      
      if (p.isStar) {
        _drawStar(canvas, paint, p.size);
      } else {
        // Gambar kertas konfeti kotak panjang
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
            Radius.circular(p.size * 0.1),
          ),
          paint,
        );
      }
      
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final double innerRadius = size / 2.5;
    final double outerRadius = size;
    final int numPoints = 5;
    final double angleStep = pi / numPoints;
    
    double currentAngle = -pi / 2;
    path.moveTo(outerRadius * cos(currentAngle), outerRadius * sin(currentAngle));
    
    for (int i = 0; i < numPoints * 2; i++) {
      currentAngle += angleStep;
      double r = (i % 2 == 0) ? innerRadius : outerRadius;
      path.lineTo(r * cos(currentAngle), r * sin(currentAngle));
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
