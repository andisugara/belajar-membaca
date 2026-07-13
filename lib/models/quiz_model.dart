class QuizQuestion {
  final String id;
  final String instruction;
  final String audio;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.instruction,
    required this.audio,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      instruction: json['instruction'] as String,
      audio: json['audio'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizOption {
  final String text;
  final bool isCorrect;

  QuizOption({
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool,
    );
  }
}
