import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/question_model.dart';
import '../../providers/question_generation_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/glass_card.dart';

class GenerateQuestionsScreen extends StatefulWidget {
  final String? assessmentId;

  const GenerateQuestionsScreen({super.key, this.assessmentId});

  @override
  State<GenerateQuestionsScreen> createState() =>
      _GenerateQuestionsScreenState();
}

class _GenerateQuestionsScreenState extends State<GenerateQuestionsScreen> {
  final TextEditingController roleController = TextEditingController();
  late final TextEditingController assessmentIdController;
  String difficulty = "Medium";
  int numberOfQuestions = 10;

  @override
  void initState() {
    super.initState();
    assessmentIdController = TextEditingController(
      text: widget.assessmentId ?? "",
    );
  }

  @override
  void dispose() {
    roleController.dispose();
    assessmentIdController.dispose();
    super.dispose();
  }

  Future<void> generateQuestions() async {
    final role = roleController.text.trim();
    final assessmentId = assessmentIdController.text.trim().toUpperCase();

    if (role.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a job role.")));
      return;
    }

    final provider = context.read<QuestionGenerationProvider>();

    final success = await provider.generateAndSaveQuestions(
      role: role,
      difficulty: difficulty,
      numberOfQuestions: numberOfQuestions,
      assessmentId: assessmentId.isEmpty ? null : assessmentId,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Questions generated and saved."
              : provider.errorMessage ?? "Question generation failed.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionGenerationProvider>();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "AI Question Studio",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              "Generate structured assessment questions",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        hintText: "Job role, e.g. Backend Developer",
                        controller: roleController,
                        icon: Icons.work_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: "Assessment ID to attach questions",
                        controller: assessmentIdController,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: difficulty,
                        decoration: const InputDecoration(
                          labelText: "Difficulty",
                          prefixIcon: Icon(Icons.tune_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Easy", child: Text("Easy")),
                          DropdownMenuItem(
                            value: "Medium",
                            child: Text("Medium"),
                          ),
                          DropdownMenuItem(value: "Hard", child: Text("Hard")),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            difficulty = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Number of questions: $numberOfQuestions",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Slider(
                        value: numberOfQuestions.toDouble(),
                        min: 4,
                        max: 20,
                        divisions: 16,
                        label: numberOfQuestions.toString(),
                        onChanged: (value) {
                          setState(() {
                            numberOfQuestions = value.round();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: "Generate Questions",
                        isLoading: provider.isLoading,
                        onPressed: generateQuestions,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (provider.isLoading) const _GeneratingCard(),
                if (provider.questionSetId != null && !provider.isLoading) ...[
                  GlassCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_done_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Saved question set: ${provider.questionSetId}",
                            style: const TextStyle(color: AppColors.textGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (provider.questions.isNotEmpty && !provider.isLoading)
                  ...provider.questions.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuestionPreviewCard(
                        index: entry.key + 1,
                        question: entry.value,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneratingCard extends StatelessWidget {
  const _GeneratingCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.secondary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your assessment is building shortly....",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  "Generating MCQs plus role-based coding JSON, validating schema, and saving to Firestore.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPreviewCard extends StatelessWidget {
  final int index;
  final QuestionModel question;

  const _QuestionPreviewCard({required this.index, required this.question});

  @override
  Widget build(BuildContext context) {
    final color = question.isCoding ? AppColors.warning : AppColors.secondary;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "${question.type.toUpperCase()} • ${question.difficulty}",
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "#$index",
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          if (question.isCoding) ...[
            const SizedBox(height: 12),
            Text(
              "Expected output: ${question.expectedOutput}",
              style: const TextStyle(color: AppColors.textGrey),
            ),
          ] else if (question.options.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...question.options.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      entry.key == question.correctAnswer
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: entry.key == question.correctAnswer
                          ? AppColors.success
                          : AppColors.textGrey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.value)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
