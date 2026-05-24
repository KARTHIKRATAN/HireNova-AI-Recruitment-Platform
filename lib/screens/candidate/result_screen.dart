import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';
import 'candidate_login_screen.dart';

class ResultScreen extends StatelessWidget {
  final String candidateName;
  final int mcqScore;
  final int mcqTotal;
  final int codingScore;
  final int codingTotal;

  const ResultScreen({
    super.key,
    this.candidateName = "Candidate",
    this.mcqScore = 0,
    this.mcqTotal = 0,
    this.codingScore = 0,
    this.codingTotal = 0,
  });

  @override
  Widget build(BuildContext context) {
    final totalScore = mcqScore + codingScore;
    final totalMarks = mcqTotal + codingTotal;
    final percentage = totalMarks == 0 ? 0 : (totalScore / totalMarks) * 100;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 38),
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  "Assessment Completed",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  candidateName,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        "${percentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "$totalScore / $totalMarks total marks",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _ScoreTile(
                              title: "MCQ",
                              value: "$mcqScore / $mcqTotal",
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ScoreTile(
                              title: "Coding",
                              value: "$codingScore / $codingTotal",
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GlassCard(
                  child: Text(
                    "Exam completed successfully.\nYour responses have been submitted.\nHR will notify you regarding further process.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textGrey),
                  ),
                ),
                const SizedBox(height: 22),
                CustomButton(
                  text: "Done",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CandidateLoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ScoreTile({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
