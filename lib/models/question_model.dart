class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String difficulty;
  final String type;
  final List<String> languages;
  final String expectedOutput;
  final List<String> acceptedKeywords;
  final int marks;

  QuestionModel({
    this.id = "",
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.difficulty = "Medium",
    this.type = "mcq",
    this.languages = const [],
    this.expectedOutput = "",
    this.acceptedKeywords = const [],
    this.marks = 5,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json["questionId"]?.toString() ?? json["id"]?.toString() ?? "",
      question: json["question"]?.toString() ?? "",
      options: (json["options"] as List<dynamic>? ?? [])
          .map((option) => option.toString())
          .toList(),
      correctAnswer: _parseCorrectAnswer(json["correctAnswer"]),
      difficulty: json["difficulty"]?.toString() ?? "Medium",
      type: json["type"]?.toString() ?? "mcq",
      languages: (json["languages"] as List<dynamic>? ?? [])
          .map((language) => language.toString())
          .toList(),
      expectedOutput: json["expectedOutput"]?.toString() ?? "",
      acceptedKeywords: (json["acceptedKeywords"] as List<dynamic>? ?? [])
          .map((keyword) => keyword.toString())
          .toList(),
      marks: _parseCorrectAnswer(json["marks"]) <= 0
          ? 5
          : _parseCorrectAnswer(json["marks"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "question": question,
      "options": options,
      "correctAnswer": correctAnswer,
      "difficulty": difficulty,
      "type": type,
      if (languages.isNotEmpty) "languages": languages,
      if (expectedOutput.isNotEmpty) "expectedOutput": expectedOutput,
      if (acceptedKeywords.isNotEmpty) "acceptedKeywords": acceptedKeywords,
      if (isCoding) "marks": marks,
    };
  }

  bool get isMcq => type.toLowerCase().contains("mcq");

  bool get isCoding => type.toLowerCase() == "coding";

  static int _parseCorrectAnswer(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? "") ?? -1;
  }
}
