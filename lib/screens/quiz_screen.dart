import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quiz_model.dart';
import '../services/audio_service.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/confetti_painter.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;

  // Animasi speaker
  late AnimationController _speakerController;
  late Animation<double> _speakerScale;

  // Animasi idle wobble speaker (berdenyut lembut terus menerus)
  late AnimationController _wobbleController;
  late Animation<double> _wobbleScale;

  @override
  void initState() {
    super.initState();
    _loadQuizData();

    // Animasi klik speaker (bounce mengecil cepat)
    _speakerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _speakerScale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _speakerController, curve: Curves.easeInOut),
    );

    // Animasi idle berdenyut
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _wobbleScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOutSine),
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

      // Putar audio pertama otomatis
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
    _wobbleController.dispose();
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
    AnimatedDialog.show(
      context: context,
      child: QuizResultDialogContent(
        isCorrect: isCorrect,
        onTapNext: () {
          Navigator.of(context).pop(); // Close dialog
          if (isCorrect) {
            _goToNextQuestion();
          } else {
            _playCurrentQuestionAudio(); // Play again on incorrect
          }
        },
      ),
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
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    AnimatedDialog.show(
      context: context,
      child: QuizCompletionDialogContent(
        onTapMainMenu: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // exit quiz screen
        },
        onTapReplay: () {
          Navigator.of(context).pop(); // close dialog
          setState(() {
            _currentQuestionIndex = 0;
          });
          Future.delayed(const Duration(milliseconds: 500), () {
            _playCurrentQuestionAudio();
          });
        },
      ),
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
        body: Center(
          child: Text(
            'Data kuis kosong atau gagal dimuat.',
            style: GoogleFonts.fredoka(fontSize: 20),
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    
                    // Center title badge
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade600,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.yellow, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Kuis Tebak Suara',
                              style: GoogleFonts.fredoka(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Progress Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_currentQuestionIndex + 1}/${_questions.length}',
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Interactive Layout (Orientation Sensitive)
          Positioned.fill(
            top: 70,
            child: SafeArea(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  final isLandscape = orientation == Orientation.landscape;

                  if (isLandscape) {
                    // Landscape: 2 Column Layout (Left: Speaker/Instruction, Right: Choices)
                    return Row(
                      children: [
                        // Left Column (Speaker & Instruction)
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    question.instruction,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.fredoka(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink.shade900,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildSpeakerButton(size: 100),
                                const SizedBox(height: 6),
                                Text(
                                  'Dengarkan suaranya',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.pink.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Column (Choices)
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 32.0, left: 12.0),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: question.options.map((opt) {
                                    return _buildOptionButton(opt, fontSize: 22, verticalPadding: 10);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Portrait: 1 Column Vertical Layout (Compact to prevent overflow)
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            question.instruction,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink.shade900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(child: _buildSpeakerButton(size: 85)),
                          const SizedBox(height: 4),
                          Text(
                            'Klik untuk dengarkan suara',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.pink.shade700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ...question.options.map((opt) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: _buildOptionButton(opt, fontSize: 20, verticalPadding: 8),
                            );
                          }),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerButton({required double size}) {
    return GestureDetector(
      onTap: _playCurrentQuestionAudio,
      child: ScaleTransition(
        scale: _speakerScale, // Animasi klik
        child: ScaleTransition(
          scale: _wobbleScale, // Animasi idle wobble
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.shade900.withOpacity(0.4),
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.volume_up_rounded,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(QuizOption opt, {required double fontSize, required double verticalPadding}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () => _checkAnswer(opt),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.pink.shade100,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.shade200.withOpacity(0.4),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              opt.text,
              style: GoogleFonts.fredoka(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dialog Konten Hasil Jawaban (Benar/Salah) - Anti Overflow & Konfeti Bintang
class QuizResultDialogContent extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onTapNext;

  const QuizResultDialogContent({
    super.key,
    required this.isCorrect,
    required this.onTapNext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCorrect ? Colors.green.shade300 : Colors.red.shade300,
            width: 3,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Konfeti hanya jika benar
            if (isCorrect)
              const ConfettiWidget(isPlaying: true),
              
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.shade400 : Colors.red.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.emoji_emotions_rounded : Icons.sentiment_very_dissatisfied_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Title
                Text(
                  isCorrect ? 'HEBAT!' : 'BELAJAR LAGI!',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                
                // Subtitle
                Text(
                  isCorrect 
                      ? 'Jawaban kamu BENAR! Kamu pintar sekali!' 
                      : 'Ayo coba dengarkan lagi dan pilih jawaban yang benar!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    color: isCorrect ? Colors.green.shade900 : Colors.red.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Action Button
                GestureDetector(
                  onTap: onTapNext,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green.shade500 : Colors.red.shade500,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      isCorrect ? 'Lanjut' : 'Coba Lagi',
                      style: GoogleFonts.fredoka(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog Konten Penyelesaian Kuis
class QuizCompletionDialogContent extends StatelessWidget {
  final VoidCallback onTapMainMenu;
  final VoidCallback onTapReplay;

  const QuizCompletionDialogContent({
    super.key,
    required this.onTapMainMenu,
    required this.onTapReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber.shade300,
            width: 3,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const ConfettiWidget(isPlaying: true),
            
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                // Star Badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 10),
                
                Text(
                  'LUAR BIASA!',
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 6),
                
                Text(
                  'Kamu telah menyelesaikan semua kuis dengan sangat baik! Keren!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: onTapMainMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade400,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade800,
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Menu Utama',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onTapReplay,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade800,
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          'Ulangi Kuis',
                          style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
