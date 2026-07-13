import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_model.dart';

class WordBubble extends StatefulWidget {
  final WordItem item;
  final VoidCallback onTap;

  const WordBubble({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<WordBubble> createState() => _WordBubbleState();
}

class _WordBubbleState extends State<WordBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Generate text spans with alternating colors for syllables
    final List<TextSpan> spans = [];
    final syllables = widget.item.syllables;

    // Use a cute color palette for syllables: Deep Blue/Black vs Soft Blue/Gray
    final color1 = Colors.blue.shade900;
    final color2 = Colors.orange.shade800;

    for (int i = 0; i < syllables.length; i++) {
      String syllable = syllables[i];
      // Jika spasi, jangan diwarnai tebal
      if (syllable == ' ') {
        spans.add(const TextSpan(text: ' '));
        continue;
      }
      
      spans.add(
        TextSpan(
          text: syllable,
          style: GoogleFonts.fredoka(
            color: i % 2 == 0 ? color1 : color2,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.blue.shade100,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.4),
                offset: const Offset(0, 6),
                blurRadius: 0, // Solid shadow for game-like feel
              ),
            ],
          ),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 32),
              children: spans,
            ),
          ),
        ),
      ),
    );
  }
}
