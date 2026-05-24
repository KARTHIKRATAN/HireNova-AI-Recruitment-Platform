import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/local_coding_service.dart';
import '../../models/coding_question_model.dart';
import '../../widgets/custom_button.dart';
import 'malpractice_screen.dart';
import 'result_screen.dart';

class CodingScreen extends StatefulWidget {
  final String? candidateId;
  final String? candidateName;
  final String? assessmentId;
  final Map<String, dynamic>? assessmentData;
  final int mcqScore;
  final int mcqTotal;

  const CodingScreen({
    super.key,
    this.candidateId,
    this.candidateName,
    this.assessmentId,
    this.assessmentData,
    this.mcqScore = 0,
    this.mcqTotal = 0,
  });

  @override
  State<CodingScreen> createState() => _CodingScreenState();
}

class _CodingScreenState extends State<CodingScreen>
    with WidgetsBindingObserver {
  final FirestoreService firestoreService = FirestoreService();
  final LocalCodingService localCodingService = LocalCodingService();
  final TextEditingController codeController = TextEditingController();

  late final Future<List<CodingQuestionModel>> codingQuestionsFuture;
  List<CodingQuestionModel> loadedCodingQuestions = [];

  int currentCodingQuestion = 0;
  int secondsRemaining = 900;
  Timer? timer;
  String selectedLanguage = "Dart";
  String output = "Output Console:\n\nRun your code to validate locally.";
  final Map<String, int> questionScores = {};
  bool malpracticeTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    codingQuestionsFuture = loadCodingQuestions();
    codeController.text = _starterCode(selectedLanguage);
    startTimer();
  }

  Future<List<CodingQuestionModel>> loadCodingQuestions() async {
    if (widget.assessmentId != null) {
      final questions = await firestoreService.getAssessmentQuestions(
        widget.assessmentId!,
      );
      final geminiCodingQuestions = questions
          .where((question) => question.isCoding)
          .map(CodingQuestionModel.fromQuestionModel)
          .toList();

      if (geminiCodingQuestions.isNotEmpty) {
        return geminiCodingQuestions;
      }
    }

    return localCodingService.getQuestionsForRole(
      widget.assessmentData?["jobRole"]?.toString() ?? "",
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      stopForMalpractice(state.name);
    }
  }

  Future<void> stopForMalpractice(String violationType) async {
    if (malpracticeTriggered) {
      return;
    }

    malpracticeTriggered = true;
    timer?.cancel();

    await firestoreService.saveCheatingLog(
      candidateName: widget.candidateName ?? "Candidate",
      role: widget.assessmentData?["jobRole"]?.toString() ?? "Unknown",
      assessmentId: widget.assessmentId ?? "Unknown",
      violationType: violationType,
    );

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MalpracticeScreen(violationType: violationType),
      ),
      (route) => false,
    );
  }

  String _starterCode(String language) {
    switch (language) {
      case "Python":
        return "def solution():\n    pass\n";
      case "Java":
        return "class Main {\n  public static void main(String[] args) {\n  }\n}\n";
      case "C++":
        return "#include <iostream>\nusing namespace std;\n\nint main() {\n  return 0;\n}\n";
      case "JavaScript":
        return "function solution() {\n}\n";
      default:
        return "void main() {\n}\n";
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
        submitFinalResult();
      }
    });
  }

  Future<void> runLocalValidation(CodingQuestionModel question) async {
    final result = localCodingService.evaluate(
      question: question,
      code: codeController.text,
    );

    questionScores[question.id] = result.score;

    if (widget.candidateId != null && widget.assessmentId != null) {
      await firestoreService.saveCodingSubmission(
        candidateId: widget.candidateId!,
        assessmentId: widget.assessmentId!,
        questionId: question.id,
        questionTitle: question.title,
        language: selectedLanguage,
        code: codeController.text,
        score: result.score,
        passed: result.passed,
        output: result.output,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      output =
          "Output Console:\n\n${result.output}\n\n${result.feedback}\nScore: ${result.score}/${question.marks}";
    });
  }

  Future<void> submitFinalResult() async {
    final codingTotal = loadedCodingQuestions.fold<int>(
      0,
      (total, question) => total + question.marks,
    );
    final codingScore = questionScores.values.fold<int>(
      0,
      (total, score) => total + score,
    );

    if (widget.candidateId != null &&
        widget.candidateName != null &&
        widget.assessmentId != null) {
      await firestoreService.saveAssessmentResult(
        candidateId: widget.candidateId!,
        candidateName: widget.candidateName!,
        assessmentId: widget.assessmentId!,
        mcqScore: widget.mcqScore,
        mcqTotal: widget.mcqTotal,
        codingScore: codingScore,
        codingTotal: codingTotal,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          candidateName: widget.candidateName ?? "Candidate",
          mcqScore: widget.mcqScore,
          mcqTotal: widget.mcqTotal,
          codingScore: codingScore,
          codingTotal: codingTotal,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coding Round"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                "$minutes:${seconds.toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CodingQuestionModel>>(
        future: codingQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          loadedCodingQuestions = snapshot.data ?? [];

          if (loadedCodingQuestions.isEmpty) {
            return const Center(child: Text("No coding questions found."));
          }

          final safeIndex = currentCodingQuestion.clamp(
            0,
            loadedCodingQuestions.length - 1,
          );
          final currentQuestion = loadedCodingQuestions[safeIndex];
          if (!currentQuestion.languages.contains(selectedLanguage)) {
            selectedLanguage = currentQuestion.languages.first;
          }

          return _buildCodingRound(currentQuestion, safeIndex);
        },
      ),
    );
  }

  Widget _buildCodingRound(CodingQuestionModel currentQuestion, int safeIndex) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (safeIndex + 1) / loadedCodingQuestions.length,
          ),
          const SizedBox(height: 16),
          Text(
            "Coding Question ${safeIndex + 1} / ${loadedCodingQuestions.length}",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentQuestion.description,
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Programming Language",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  underline: const SizedBox(),
                  items: currentQuestion.languages
                      .map(
                        (language) => DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedLanguage = value;
                      codeController.text = _starterCode(value);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: codeController,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              output,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => runLocalValidation(currentQuestion),
                  child: const Text("Run Code"),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: CustomButton(
                  text: safeIndex == loadedCodingQuestions.length - 1
                      ? "Submit"
                      : "Next",
                  onPressed: () {
                    if (safeIndex < loadedCodingQuestions.length - 1) {
                      setState(() {
                        currentCodingQuestion = safeIndex + 1;
                        codeController.text = _starterCode(selectedLanguage);
                        output =
                            "Output Console:\n\nRun your code to validate locally.";
                      });
                    } else {
                      submitFinalResult();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
