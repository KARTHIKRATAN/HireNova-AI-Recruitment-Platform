import '../../models/coding_question_model.dart';

class CodingEvaluationResult {
  final bool passed;
  final int score;
  final String output;
  final String feedback;

  const CodingEvaluationResult({
    required this.passed,
    required this.score,
    required this.output,
    required this.feedback,
  });
}

class LocalCodingService {
  List<CodingQuestionModel> getQuestionsForRole(String role) {
    final normalizedRole = role.toLowerCase();

    if (normalizedRole.contains("data") ||
        normalizedRole.contains("python") ||
        normalizedRole.contains("scientist")) {
      return dataScienceQuestions;
    }

    return flutterDeveloperQuestions;
  }

  CodingEvaluationResult evaluate({
    required CodingQuestionModel question,
    required String code,
  }) {
    final normalizedCode = code.toLowerCase();
    final matchedKeywords = question.acceptedKeywords
        .where((keyword) => normalizedCode.contains(keyword.toLowerCase()))
        .length;
    final passed = matchedKeywords >= question.acceptedKeywords.length;

    return CodingEvaluationResult(
      passed: passed,
      score: passed ? question.marks : 0,
      output: passed
          ? question.expectedOutput
          : "Validation failed. Expected output: ${question.expectedOutput}",
      feedback: passed
          ? "Passed local validation."
          : "Code did not match the expected local logic.",
    );
  }

  static const List<CodingQuestionModel> flutterDeveloperQuestions = [
    CodingQuestionModel(
      id: "flutter_reverse_string",
      title: "Reverse String",
      description:
          "Write a function that reverses the string 'HireNova' and prints the result.",
      languages: ["Dart", "JavaScript", "Python", "Java", "C++"],
      expectedOutput: "avoNeriH",
      acceptedKeywords: ["reverse", "HireNova"],
    ),
    CodingQuestionModel(
      id: "flutter_fibonacci",
      title: "Fibonacci",
      description: "Print the first 6 Fibonacci numbers separated by spaces.",
      languages: ["Dart", "JavaScript", "Python", "Java", "C++"],
      expectedOutput: "0 1 1 2 3 5",
      acceptedKeywords: ["0", "1", "2", "3", "5"],
    ),
    CodingQuestionModel(
      id: "flutter_api_logic",
      title: "API Response Mapping",
      description:
          "Create logic that maps an API response list into candidate names and prints 'Mapped'.",
      languages: ["Dart", "JavaScript", "Python"],
      expectedOutput: "Mapped",
      acceptedKeywords: ["map", "candidate", "Mapped"],
    ),
  ];

  static const List<CodingQuestionModel> dataScienceQuestions = [
    CodingQuestionModel(
      id: "ds_array_filter",
      title: "Filter Even Numbers",
      description:
          "Filter even numbers from [1, 2, 3, 4, 5, 6] and print [2, 4, 6].",
      languages: ["Python", "JavaScript", "Dart"],
      expectedOutput: "[2, 4, 6]",
      acceptedKeywords: ["filter", "2", "4", "6"],
    ),
    CodingQuestionModel(
      id: "ds_missing_values",
      title: "Data Preprocessing",
      description: "Replace null values in a list with 0 and print 'Cleaned'.",
      languages: ["Python", "JavaScript", "Dart"],
      expectedOutput: "Cleaned",
      acceptedKeywords: ["null", "0", "Cleaned"],
    ),
    CodingQuestionModel(
      id: "ds_average",
      title: "Calculate Average",
      description: "Calculate the average of [10, 20, 30] and print 20.",
      languages: ["Python", "JavaScript", "Dart"],
      expectedOutput: "20",
      acceptedKeywords: ["10", "20", "30", "/"],
    ),
  ];
}
