import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class CheatingAlertsScreen extends StatefulWidget {
  const CheatingAlertsScreen({super.key});

  @override
  State<CheatingAlertsScreen> createState() => _CheatingAlertsScreenState();
}

class _CheatingAlertsScreenState extends State<CheatingAlertsScreen> {
  static bool _hasOpenedBefore = false;
  late final bool _showIntro = !_hasOpenedBefore;

  @override
  void initState() {
    super.initState();
    _hasOpenedBefore = true;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestoreService.cheatingLogsStream(),
            builder: (context, snapshot) {
              final logs = snapshot.data?.docs ?? [];
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              return SingleChildScrollView(
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
                        Text(
                          "Cheating Alerts",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_showIntro) ...[
                      const GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.security_rounded,
                              color: AppColors.accent,
                              size: 36,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Anti-cheating system monitors app switching, minimizing, unauthorized navigation, and malpractice activities.",
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Candidates violating rules will appear here.",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (logs.isEmpty)
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "No malpractice detected",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Candidate exam sessions are clean right now.",
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      )
                    else
                      ...logs.map((doc) {
                        final data = doc.data();
                        final timestamp = data["timestamp"];
                        final role = data["role"]?.toString() ?? "Candidate";
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["candidateName"]?.toString() ??
                                            "Candidate",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$role • ${data["violationType"] ?? "violation"}",
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                      Text(
                                        "Assessment: ${data["assessmentId"] ?? ""}",
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (timestamp is Timestamp)
                                        Text(
                                          _formatTimestamp(timestamp),
                                          style: const TextStyle(
                                            color: AppColors.textGrey,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "$day/$month/${date.year} $hour:$minute";
  }
}
