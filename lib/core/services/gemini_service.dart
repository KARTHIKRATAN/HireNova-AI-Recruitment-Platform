import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/question_model.dart';
import '../constants/api_keys.dart';

class GeminiService {
  static const String _model = "gemini-2.5-flash";
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models";

  Future<List<QuestionModel>> generateQuestions({
    required String role,
    required String difficulty,
    required int numberOfQuestions,
  }) async {
    final uri = Uri.parse("$_baseUrl/$_model:generateContent");

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": ApiKeys.geminiApiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": _buildPrompt(role, difficulty, numberOfQuestions)},
            ],
          },
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topP": 0.9,
          "maxOutputTokens": 4096,
          "responseMimeType": "application/json",
          "responseSchema": {
            "type": "ARRAY",
            "items": {
              "type": "OBJECT",
              "properties": {
                "question": {"type": "STRING"},
                "options": {
                  "type": "ARRAY",
                  "items": {"type": "STRING"},
                },
                "correctAnswer": {"type": "INTEGER"},
                "difficulty": {"type": "STRING"},
                "type": {"type": "STRING"},
                "languages": {
                  "type": "ARRAY",
                  "items": {"type": "STRING"},
                },
                "expectedOutput": {"type": "STRING"},
                "acceptedKeywords": {
                  "type": "ARRAY",
                  "items": {"type": "STRING"},
                },
                "marks": {"type": "INTEGER"},
              },
              "required": [
                "question",
                "options",
                "correctAnswer",
                "difficulty",
                "type",
              ],
            },
          },
        },
      }),
    );

    debugPrint("Gemini status: ${response.statusCode}");

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Gemini API failed: ${response.body}");
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = decoded["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

    if (text == null || text.toString().trim().isEmpty) {
      throw Exception("Gemini returned an empty response.");
    }

    final parsedJson = jsonDecode(_extractJson(text.toString()));

    if (parsedJson is! List) {
      throw Exception("Gemini response was not a valid JSON list.");
    }

    final questions = parsedJson
        .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
        .where((question) {
          if (question.question.trim().isEmpty) {
            return false;
          }

          if (question.isCoding) {
            return question.expectedOutput.trim().isNotEmpty &&
                question.acceptedKeywords.isNotEmpty;
          }

          return question.options.length == 4 &&
              question.correctAnswer >= 0 &&
              question.correctAnswer < 4;
        })
        .map(
          (question) => question.isCoding
              ? QuestionModel(
                  id: question.id,
                  question: question.question,
                  options: const [],
                  correctAnswer: -1,
                  difficulty: question.difficulty,
                  type: "coding",
                  languages: question.languages,
                  expectedOutput: question.expectedOutput,
                  acceptedKeywords: question.acceptedKeywords,
                  marks: question.marks,
                )
              : QuestionModel(
                  id: question.id,
                  question: question.question,
                  options: question.options,
                  correctAnswer: question.correctAnswer,
                  difficulty: question.difficulty,
                  type: "mcq",
                ),
        )
        .toList();

    if (questions.isEmpty) {
      throw Exception("Gemini did not generate valid assessment questions.");
    }

    return questions;
  }

  String _buildPrompt(String role, String difficulty, int numberOfQuestions) {
    final codingCount = numberOfQuestions >= 6 ? 2 : 1;
    final mcqCount = numberOfQuestions - codingCount;

    return """
You are an expert AI technical interviewer for HireNova AI.

Generate exactly $numberOfQuestions unique assessment questions:
- $mcqCount technical MCQ/theory questions
- $codingCount practical coding questions

Role: $role
Difficulty: $difficulty

Rules:
- MCQ items must have exactly 4 options and type "mcq".
- MCQ correctAnswer must be a zero-based integer index from 0 to 3.
- Coding items must use type "coding", options [], correctAnswer -1, and include expectedOutput, acceptedKeywords, languages, and marks.
- Coding questions must be role-specific, real-world, and non-repetitive.
- Difficulty must affect complexity.
- Use industry-style coding scenarios for the selected role.
- Return ONLY clean JSON. No markdown, explanation, comments, or extra text.

JSON schema:
[
  {
    "question": "string",
    "options": ["string", "string", "string", "string"],
    "correctAnswer": 0,
    "difficulty": "$difficulty",
    "type": "mcq"
  },
  {
    "question": "string coding prompt",
    "options": [],
    "correctAnswer": -1,
    "difficulty": "$difficulty",
    "type": "coding",
    "languages": ["Dart", "Python", "JavaScript"],
    "expectedOutput": "string",
    "acceptedKeywords": ["string", "string", "string"],
    "marks": 5
  }
]
""";
  }

  String _extractJson(String value) {
    final trimmed = value.trim();

    if (trimmed.startsWith("[") && trimmed.endsWith("]")) {
      return trimmed;
    }

    final start = trimmed.indexOf("[");
    final end = trimmed.lastIndexOf("]");

    if (start == -1 || end == -1 || end <= start) {
      throw Exception("Could not parse Gemini JSON response.");
    }

    return trimmed.substring(start, end + 1);
  }
}
