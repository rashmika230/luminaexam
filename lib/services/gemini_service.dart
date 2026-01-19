
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/exam_models.dart';

class GeminiService {
  static const String _modelName = 'gemini-3-pro-preview';

  Future<List<MCQQuestion>> generateQuestions({
    required String subject,
    required Medium medium,
    required String topic,
    int count = 5,
  }) async {
    // API key should be passed via --dart-define=API_KEY=xxx
    final apiKey = const String.fromEnvironment('API_KEY');
    if (apiKey.isEmpty) throw Exception("Lumina Engine: API_KEY not found.");

    final model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4,
      ),
      systemInstruction: Content.system('''
        You are a Senior Sri Lankan A/L Examiner. 
        Generate $count MCQs strictly based on the SL National Syllabus.
        Medium: ${medium.name}. Subject: $subject. Topic: $topic.
        Return a JSON array of objects with keys: "question", "options" (5 items), "correctAnswerIndex", "explanation".
      '''),
    );

    final response = await model.generateContent([
      Content.text("Generate $count questions for $subject on $topic.")
    ]);

    final text = response.text;
    if (text == null) return [];

    try {
      final List<dynamic> data = jsonDecode(text);
      return data.map((q) => MCQQuestion.fromJson(q)).toList();
    } catch (e) {
      print("Lumina Engine Parse Error: $e");
      return [];
    }
  }
}
