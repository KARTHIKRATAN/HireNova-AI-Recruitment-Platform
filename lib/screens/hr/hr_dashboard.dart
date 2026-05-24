import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/dashboard_stat_card.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/glass_card.dart';
import 'analytics_screen.dart';
import 'candidate_management_screen.dart';
import 'cheating_alerts_screen.dart';
import 'create_assessment_screen.dart';
import 'generate_questions_screen.dart';
import 'profile_screen.dart';

class HRDashboard extends StatelessWidget {
  const HRDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hiring cockpit",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "AI assessments, ranking, and risk signals.",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Generate smarter assessments",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Create technical MCQs with Gemini AI.",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CreateAssessmentScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text(
                            "Create Assessment",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<Map<String, dynamic>>(
                  future: firestoreService.getDashboardStats(),
                  builder: (context, snapshot) {
                    final stats = snapshot.data ?? {};

                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.12,
                          ),
                      children: [
                        DashboardStatCard(
                          label: "Candidates",
                          value: "${stats["totalCandidates"] ?? 0}",
                          icon: Icons.groups_rounded,
                          color: AppColors.secondary,
                        ),
                        DashboardStatCard(
                          label: "Active tests",
                          value: "${stats["activeAssessments"] ?? 0}",
                          icon: Icons.pending_actions_rounded,
                          color: AppColors.primary,
                        ),
                        DashboardStatCard(
                          label: "Completed",
                          value: "${stats["completedAssessments"] ?? 0}",
                          icon: Icons.task_alt_rounded,
                          color: AppColors.success,
                        ),
                        DashboardStatCard(
                          label: "Avg score",
                          value:
                              "${((stats["averageScore"] ?? 0) as num).toStringAsFixed(0)}%",
                          icon: Icons.trending_up_rounded,
                          color: AppColors.warning,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                Text(
                  "Workspace",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerateQuestionsScreen(),
                      ),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.psychology_alt_rounded,
                    title: "AI Question Studio",
                    subtitle: "Generate technical MCQs for any role",
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsScreen(),
                      ),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.analytics_rounded,
                    title: "Analytics Dashboard",
                    subtitle: "Rank candidates and inspect score trends",
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheatingAlertsScreen(),
                      ),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.security_rounded,
                    title: "Cheating Alerts",
                    subtitle: "Review app switches and screen-leaving events",
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CandidateManagementScreen(),
                      ),
                    );
                  },
                  child: const FeatureCard(
                    icon: Icons.people_alt_rounded,
                    title: "Candidate Management",
                    subtitle: "Track applicants, attempts, and submissions",
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
