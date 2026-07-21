import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_model.dart';

class WordBubble extends StatefulWidget {
  final WordItem item;
  final VoidCallback onTap;
  final bool isHighlighted;
  final double fontSize;

  const WordBubble({
    super.key,
    required this.item,
    required this.onTap,
    this.isHighlighted = false,
    this.fontSize = 24.0,
  });

  @override
  State<WordBubble> createState() => _WordBubbleState();
}

class _WordBubbleState extends State<WordBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    
    // Durasi total animasi lompatan memantul (350ms agar halus dan terasa kenyal)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Menggunakan TweenSequence untuk menciptakan gerakan karet/game yang kenyal:
    // 1. Membesar cepat dari 1.0 ke 1.35 dengan efek elastis (overshoot).
    // 2. Memantul kembali dari 1.35 ke 1.0 dengan efek bounceOut yang memantul lembut.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40, // 40% dari total durasi
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60, // 60% dari total durasi
      ),
    ]).animate(_controller);

    // Reset status warna tap saat animasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isTapped = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Jalankan animasi dari awal (from: 0.0) setiap kali diketuk
    if (mounted) {
      setState(() {
        _isTapped = true;
      });
      _controller.forward(from: 0.0);
    }
    // Suara diputar instan untuk respon ketukan yang responsif
    widget.onTap();
  }

  Color _parseColor(String? colorStr, Color fallback) {
    if (colorStr == null || colorStr.isEmpty) return fallback;
    final lower = colorStr.toLowerCase().trim();
    switch (lower) {
      case 'red':
        return Colors.red.shade700;
      case 'black':
      case 'dark':
        return Colors.grey.shade900;
      case 'purple':
        return Colors.purple.shade600;
      case 'green':
        return Colors.green.shade700;
      case 'blue':
        return Colors.blue.shade700;
      case 'orange':
        return Colors.orange.shade800;
      case 'pink':
        return Colors.pink.shade600;
      case 'teal':
        return Colors.teal.shade700;
    }
    if (lower.startsWith('#')) {
      final hex = lower.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final List<TextSpan> spans = [];
    final syllables = widget.item.syllables;
    final customColors = widget.item.colors;

    for (int i = 0; i < syllables.length; i++) {
      String syllable = syllables[i];
      if (syllable == ' ') {
        spans.add(const TextSpan(text: ' '));
        continue;
      }

      Color charColor;
      if (_isTapped) {
        charColor = Colors.pinkAccent.shade400;
      } else if (customColors != null && i < customColors.length) {
        charColor = _parseColor(customColors[i], Colors.grey.shade900);
      } else {
        // Default alternating: red for first syllable, dark for second
        charColor = (i % 2 == 0) ? Colors.red.shade700 : Colors.grey.shade900;
      }

      spans.add(
        TextSpan(
          text: syllable,
          style: GoogleFonts.fredoka(
            color: charColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            // Highlight kuning stabilo saat sedang dibacakan secara berurutan
            color: widget.isHighlighted ? Colors.yellow.shade200 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: widget.fontSize),
              children: spans,
            ),
          ),
        ),
      ),
    );
  }
}
