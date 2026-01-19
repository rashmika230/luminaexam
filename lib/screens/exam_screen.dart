
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/exam_models.dart';
import '../services/gemini_service.dart';

class ExamScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final Medium medium;

  const ExamScreen({
    super.key, 
    required this.subject, 
    required this.topic, 
    required this.medium
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final GeminiService _gemini = GeminiService();
  List<MCQQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _isLoading = true;
  Map<int, int> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    try {
      final qs = await _gemini.generateQuestions(
        subject: widget.subject,
        medium: widget.medium,
        topic: widget.topic,
      );
      setState(() {
        _questions = qs;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.indigo),
              const SizedBox(height: 20),
              Text(
                "CONSULTING SYLLABUS ENGINE...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ).animate().pulse(),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.subject, style: const TextStyle(fontWeight: FontWeight.w900)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: Colors.indigo.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation(Colors.indigo),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    q.question,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...List.generate(q.options.length, (index) {
                    final isSelected = _userAnswers[_currentIndex] == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => setState(() => _userAnswers[_currentIndex] = index),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.indigo.withOpacity(0.05) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.indigo : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: isSelected ? Colors.indigo : Colors.white,
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  q.options[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.indigo : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fade().slideY(begin: 0.1),
            const SizedBox(height: 32),
            Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentIndex--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text("PREVIOUS"),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _userAnswers[_currentIndex] == null ? null : () {
                      if (_currentIndex < _questions.length - 1) {
                        setState(() => _currentIndex++);
                      } else {
                        // Finish Exam logic
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(_currentIndex == _questions.length - 1 ? "FINISH EXAM" : "NEXT QUESTION"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
