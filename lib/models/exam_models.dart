
enum PlanType { FREE, PRO, PLUS }
enum Medium { SINHALA, ENGLISH, TAMIL }
enum SubjectStream {
  PHYSICAL_SCIENCE,
  BIOLOGICAL_SCIENCE,
  COMMERCE,
  ARTS,
  ENGINEERING_TECH,
  BIO_SYSTEMS_TECH
}

class MCQQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  MCQQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    return MCQQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String preferredName;
  final String school;
  final PlanType plan;
  final SubjectStream stream;
  final Medium medium;
  int questionsUsed;

  AppUser({
    required this.id,
    required this.fullName,
    required this.preferredName,
    required this.school,
    required this.plan,
    required this.stream,
    required this.medium,
    this.questionsUsed = 0,
  });
}
