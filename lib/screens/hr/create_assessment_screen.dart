import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/glass_card.dart';
import 'generate_questions_screen.dart';

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key});

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController roleController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  String difficulty = "Medium";
  String examId = "";
  String examPassword = "";
  String candidateInviteCode = "";
  bool isSaving = false;

  @override
  void dispose() {
    roleController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  String _buildCode(String prefix, int length) {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    final random = Random.secure();
    final body = List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();

    return "$prefix-$body";
  }

  Future<void> generateExamCredentials() async {
    final role = roleController.text.trim();
    final skills = skillsController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (role.isEmpty || skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter job role and skills.")),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login again to create an exam.")),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final generatedExamId = _buildCode("HN", 6);
    final generatedPassword = _buildCode("PASS", 6);
    final generatedInviteCode = _buildCode("INV", 6);

    try {
      await firestoreService.saveAssessmentInvite(
        assessmentId: generatedExamId,
        examPassword: generatedPassword,
        candidateInviteCode: generatedInviteCode,
        jobRole: role,
        skills: skills,
        difficulty: difficulty,
        hrUid: currentUser.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        examId = generatedExamId;
        examPassword = generatedPassword;
        candidateInviteCode = generatedInviteCode;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exam credentials saved to Firestore.")),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not create assessment: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        "Create Assessment",
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
                      const Text(
                        "Exam invite setup",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Generate secure credentials candidates can use to enter the assessment.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        hintText: "Job role, e.g. Flutter Developer",
                        controller: roleController,
                        icon: Icons.work_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: "Skills, e.g. Flutter, Firebase, APIs",
                        controller: skillsController,
                        icon: Icons.psychology_alt_outlined,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: difficulty,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.tune_rounded),
                          labelText: "Difficulty",
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
                      const SizedBox(height: 22),
                      CustomButton(
                        text: "Generate & Save Credentials",
                        isLoading: isSaving,
                        onPressed: generateExamCredentials,
                      ),
                    ],
                  ),
                ),
                if (examId.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Candidate invite",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _CredentialTile(title: "Exam ID", value: examId),
                        const SizedBox(height: 12),
                        _CredentialTile(
                          title: "Exam Password",
                          value: examPassword,
                        ),
                        const SizedBox(height: 12),
                        _CredentialTile(
                          title: "Invite Code",
                          value: candidateInviteCode,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Share the exam ID and password with candidates. The invite code is stored for HR tracking.",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 18),
                        CustomButton(
                          text: "Generate Questions for This Exam",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenerateQuestionsScreen(
                                  assessmentId: examId,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CredentialTile extends StatelessWidget {
  final String title;
  final String value;

  const _CredentialTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          SelectableText(
            value,
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
