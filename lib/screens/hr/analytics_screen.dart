import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestoreService.resultsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                );
              }

              final results = snapshot.data?.docs ?? [];
              final average = _averageScore(results);

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
                          "Hiring Analytics",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: "Completed",
                            value: "${results.length}",
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: "Avg Score",
                            value: "${average.toStringAsFixed(0)}%",
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Candidate Ranking",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (results.isEmpty)
                      const GlassCard(
                        child: Text(
                          "No candidate results yet. Completed assessments will appear here.",
                          style: TextStyle(color: AppColors.textGrey),
                        ),
                      )
                    else
                      ...results.asMap().entries.map((entry) {
                        final data = entry.value.data();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.18,
                                  ),
                                  child: Text("#${entry.key + 1}"),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["candidateName"]?.toString() ??
                                            "Candidate",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        data["assessmentId"]?.toString() ?? "",
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${((data["percentage"] ?? 0) as num).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
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

  double _averageScore(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) {
      return 0;
    }

    final total = docs.fold<double>(
      0,
      (runningTotal, doc) =>
          runningTotal + ((doc.data()["percentage"] ?? 0) as num).toDouble(),
    );

    return total / docs.length;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
