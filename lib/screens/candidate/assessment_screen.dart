import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../models/question_model.dart';
import '../../widgets/custom_button.dart';
import 'coding_screen.dart';
import 'malpractice_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final String? candidateId;
  final String? candidateName;
  final String? assessmentId;
  final Map<String, dynamic>? assessmentData;

  const AssessmentScreen({
    super.key,
    this.candidateId,
    this.candidateName,
    this.assessmentId,
    this.assessmentData,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen>
    with WidgetsBindingObserver {
  final FirestoreService firestoreService = FirestoreService();

  late final Future<List<QuestionModel>> questionsFuture;

  int currentQuestionIndex = 0;
  int selectedOption = -1;
  int secondsRemaining = 600;
  Timer? timer;
  final Map<String, int> selectedAnswers = {};
  List<QuestionModel> loadedMcqQuestions = [];
  bool malpracticeTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    questionsFuture = widget.assessmentId == null
        ? Future.value([])
        : firestoreService.getAssessmentQuestions(widget.assessmentId!);

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
        navigateToCodingRound();
      }
    });
  }

  void navigateToCodingRound() {
    final mcqScore = loadedMcqQuestions.where((question) {
      return selectedAnswers[question.id] == question.correctAnswer;
    }).length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CodingScreen(
          candidateId: widget.candidateId,
          candidateName: widget.candidateName,
          assessmentId: widget.assessmentId,
          assessmentData: widget.assessmentData,
          mcqScore: mcqScore,
          mcqTotal: loadedMcqQuestions.length,
        ),
      ),
    );
  }

  void navigateToCodingRoundWithScore(List<QuestionModel> mcqQuestions) {
    final mcqScore = mcqQuestions.where((question) {
      return selectedAnswers[question.id] == question.correctAnswer;
    }).length;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CodingScreen(
          candidateId: widget.candidateId,
          candidateName: widget.candidateName,
          assessmentId: widget.assessmentId,
          assessmentData: widget.assessmentData,
          mcqScore: mcqScore,
          mcqTotal: mcqQuestions.length,
        ),
      ),
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.assessmentData?["jobRole"] ?? "AI Technical Assessment",
        ),
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
      body: FutureBuilder<List<QuestionModel>>(
        future: questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline_rounded,
              title: "Could not load questions",
              message: snapshot.error.toString(),
            );
          }

          final allQuestions = snapshot.data ?? [];
          final mcqQuestions = allQuestions
              .where((question) => question.isMcq)
              .toList();
          loadedMcqQuestions = mcqQuestions;

          if (allQuestions.isEmpty) {
            return const _MessageState(
              icon: Icons.quiz_outlined,
              title: "No questions found",
              message:
                  "Ask HR to generate questions for this assessment first.",
            );
          }

          if (mcqQuestions.isEmpty) {
            return _CodingOnlyState(onStartCoding: navigateToCodingRound);
          }

          final safeIndex = currentQuestionIndex.clamp(
            0,
            mcqQuestions.length - 1,
          );
          final currentQuestion = mcqQuestions[safeIndex];
          selectedOption = selectedAnswers[currentQuestion.id] ?? -1;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (safeIndex + 1) / mcqQuestions.length,
                ),
                if (widget.candidateName != null ||
                    widget.assessmentId != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    [
                      if (widget.candidateName != null) widget.candidateName!,
                      if (widget.assessmentId != null) widget.assessmentId!,
                    ].join(" • "),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                Text(
                  "Question ${safeIndex + 1} / ${mcqQuestions.length}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedOption == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = index;
                            selectedAnswers[currentQuestion.id] = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppColors.secondary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  currentQuestion.options[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: safeIndex == 0
                            ? null
                            : () {
                                setState(() {
                                  currentQuestionIndex--;
                                });
                              },
                        child: const Text("Previous"),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomButton(
                        text: safeIndex == mcqQuestions.length - 1
                            ? "Coding Round"
                            : "Next",
                        onPressed: () {
                          if (safeIndex < mcqQuestions.length - 1) {
                            setState(() {
                              currentQuestionIndex++;
                              selectedOption = -1;
                            });
                          } else {
                            navigateToCodingRoundWithScore(mcqQuestions);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CodingOnlyState extends StatelessWidget {
  final VoidCallback onStartCoding;

  const _CodingOnlyState({required this.onStartCoding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.code_rounded,
              size: 56,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            const Text(
              "Only coding questions found",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "This assessment starts directly with the coding round.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            CustomButton(text: "Start Coding", onPressed: onStartCoding),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
