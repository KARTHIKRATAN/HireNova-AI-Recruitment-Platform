import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/glass_card.dart';
import 'assessment_screen.dart';

class CandidateLoginScreen extends StatefulWidget {
  const CandidateLoginScreen({super.key});

  @override
  State<CandidateLoginScreen> createState() => _CandidateLoginScreenState();
}

class _CandidateLoginScreenState extends State<CandidateLoginScreen> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController examIdController = TextEditingController();
  final TextEditingController examPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    examIdController.dispose();
    examPasswordController.dispose();
    super.dispose();
  }

  Future<void> validateAndStartExam() async {
    final candidateName = nameController.text.trim();
    final examId = examIdController.text.trim().toUpperCase();
    final examPassword = examPasswordController.text.trim().toUpperCase();

    if (candidateName.isEmpty || examId.isEmpty || examPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    final assessmentData = await firestoreService.validateExamCredentials(
      examId: examId,
      examPassword: examPassword,
    );

    if (!mounted) {
      return;
    }

    if (assessmentData == null) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid exam ID or password.")),
      );
      return;
    }

    try {
      final candidateId = await firestoreService.saveCandidateLogin(
        candidateName: candidateName,
        assessmentId: examId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AssessmentScreen(
            candidateId: candidateId,
            candidateName: candidateName,
            assessmentId: examId,
            assessmentData: assessmentData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not start exam: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 28),
                Text(
                  "Candidate entry",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  "Use the exam credentials shared by the hiring team.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 26),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.terminal_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        hintText: "Candidate name",
                        controller: nameController,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: "Exam ID",
                        controller: examIdController,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: "Exam password",
                        controller: examPasswordController,
                        obscureText: true,
                        icon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 22),
                      CustomButton(
                        text: "Start Exam",
                        isLoading: isLoading,
                        onPressed: validateAndStartExam,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.security_rounded, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Your login time will be recorded for assessment security.",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      ),
                    ],
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
