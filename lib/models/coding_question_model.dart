import 'question_model.dart';

class CodingQuestionModel {
  final String id;
  final String title;
  final String description;
  final List<String> languages;
  final String expectedOutput;
  final List<String> acceptedKeywords;
  final int marks;

  const CodingQuestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.languages,
    required this.expectedOutput,
    required this.acceptedKeywords,
    this.marks = 5,
  });

  factory CodingQuestionModel.fromQuestionModel(QuestionModel question) {
    return CodingQuestionModel(
      id: question.id.isEmpty
          ? question.question.hashCode.toString()
          : question.id,
      title: _buildTitle(question.question),
      description: question.question,
      languages: question.languages.isEmpty
          ? const ["Dart", "Python", "JavaScript", "Java", "C++"]
          : question.languages,
      expectedOutput: question.expectedOutput.isEmpty
          ? "Expected output not provided"
          : question.expectedOutput,
      acceptedKeywords: question.acceptedKeywords.isEmpty
          ? _fallbackKeywords(question.question)
          : question.acceptedKeywords,
      marks: question.marks,
    );
  }

  static String _buildTitle(String question) {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return "Coding Challenge";
    }

    final firstSentence = trimmed.split(RegExp(r"[.?\n]")).first.trim();
    if (firstSentence.length <= 52) {
      return firstSentence;
    }

    return "${firstSentence.substring(0, 49)}...";
  }

  static List<String> _fallbackKeywords(String question) {
    return question
        .split(RegExp(r"[^A-Za-z0-9_]+"))
        .where((word) => word.length > 4)
        .take(3)
        .toList();
  }
}
