import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_model.dart';
import '../services/audio_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;

  // Speaker button bounce animation
  late AnimationController _speakerController;
  late Animation<double> _speakerScale;

  @override
  void initState() {
    super.initState();
    _loadQuizData();

    _speakerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _speakerScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _speakerController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadQuizData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/quiz.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<QuizQuestion> parsedQuestions =
          jsonList.map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>)).toList();

      setState(() {
        _questions = parsedQuestions;
        _isLoading = false;
      });

      // Play the first question audio automatically after short delay
      if (parsedQuestions.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _playCurrentQuestionAudio();
        });
      }
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _speakerController.dispose();
    _audioService.stop();
    super.dispose();
  }

  void _playCurrentQuestionAudio() {
    if (_questions.isEmpty) return;
    _speakerController.forward().then((_) => _speakerController.reverse());
    _audioService.playAsset(_questions[_currentQuestionIndex].audio);
  }

  void _checkAnswer(QuizOption option) {
    if (option.isCorrect) {
      _showResultDialog(isCorrect: true);
    } else {
      _showResultDialog(isCorrect: false);
    }
  }

  void _showResultDialog({required bool isCorrect}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = CurvedAnimation(parent: anim1, curve: Curves.bounceOut);
        
        return ScaleTransition(
          scale: scale,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            backgroundColor: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.shade400 : Colors.red.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.emoji_emotions_rounded : Icons.sentiment_very_dissatisfied_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  isCorrect ? 'HEBAT!' : 'BELAJAR LAGI!',
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Subtitle / Feedback Message
                Text(
                  isCorrect 
                      ? 'Jawaban kamu BENAR! Kamu pintar sekali!' 
                      : 'Ayo coba dengarkan lagi dan pilih jawaban yang benar!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Close dialog
                    if (isCorrect) {
                      _goToNextQuestion();
                    } else {
                      _playCurrentQuestionAudio(); // Play again on incorrect
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      isCorrect ? 'Lanjut' : 'Coba Lagi',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        _playCurrentQuestionAudio();
      });
    } else {
      // Quiz Completed!
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Completion',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = CurvedAnimation(parent: anim1, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: scale,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            backgroundColor: Colors.amber.shade50,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star Icon Badge
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'LUAR BIASA!',
                  style: GoogleFonts.fredoka(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                
                Text(
                  'Kamu telah menyelesaikan semua kuis dengan sangat baik! Keren!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Main Menu Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // dialog
                        Navigator.of(context).pop(); // screen
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade800,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Menu Utama',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Play Again Button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // dialog
                        setState(() {
                          _currentQuestionIndex = 0;
                        });
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _playCurrentQuestionAudio();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade800,
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Ulangi Kuis',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis Seru')),
        body: const Center(
          child: Text('Data kuis kosong atau gagal dimuat.'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.pink.shade50, // Cute pink background for quiz
      body: Stack(
        children: [
          // Header Row
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button (red circle)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    
                    // Center title badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.yellow, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Kuis Seru Tebak Suara',
                            style: GoogleFonts.fredoka(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Progress Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Soal ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Interactive Layout
          Positioned.fill(
            top: 75,
            child: Row(
              children: [
                // Left Side: Instruction & Speaker button
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          question.instruction,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Animated Speaker button
                      GestureDetector(
                        onTap: _playCurrentQuestionAudio,
                        child: ScaleTransition(
                          scale: _speakerScale,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.shade900.withOpacity(0.4),
                                  offset: const Offset(0, 8),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.volume_up_rounded,
                              color: Colors.white,
                              size: 72,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Klik untuk dengarkan suara',
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.pink.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Side: Multiple choice buttons
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: question.options.map((opt) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () => _checkAnswer(opt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.pink.shade100,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.shade200.withOpacity(0.4),
                                    offset: const Offset(0, 6),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  opt.text,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink.shade900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
