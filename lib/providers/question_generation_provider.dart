import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/services/firestore_service.dart';
import '../core/services/gemini_service.dart';
import '../models/question_model.dart';

class QuestionGenerationProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  String? errorMessage;
  String? questionSetId;
  List<QuestionModel> questions = [];

  Future<bool> generateAndSaveQuestions({
    required String role,
    required String difficulty,
    required int numberOfQuestions,
    String? assessmentId,
  }) async {
    _setLoading(true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("Please login again before generating questions.");
      }

      final generatedQuestions = await _geminiService.generateQuestions(
        role: role,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
      );

      final savedSetId = await _firestoreService.saveGeneratedQuestions(
        role: role,
        difficulty: difficulty,
        createdBy: currentUser.uid,
        questions: generatedQuestions,
        assessmentId: assessmentId,
      );

      questions = generatedQuestions;
      questionSetId = savedSetId;
      _setLoading(false);
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  void clear() {
    errorMessage = null;
    questionSetId = null;
    questions = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      errorMessage = null;
    }
    notifyListeners();
  }
}
