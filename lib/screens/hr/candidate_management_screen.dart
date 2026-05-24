import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../widgets/app_background.dart';
import '../../widgets/glass_card.dart';

class CandidateManagementScreen extends StatefulWidget {
  const CandidateManagementScreen({super.key});

  @override
  State<CandidateManagementScreen> createState() =>
      _CandidateManagementScreenState();
}

class _CandidateManagementScreenState extends State<CandidateManagementScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController searchController = TextEditingController();
  String query = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestoreService.cheatingLogsStream(),
            builder: (context, cheatingSnapshot) {
              final cheatingKeys =
                  cheatingSnapshot.data?.docs.map((doc) {
                    final data = doc.data();
                    return _candidateKey(
                      data["candidateName"]?.toString() ?? "",
                      data["assessmentId"]?.toString() ?? "",
                    );
                  }).toSet() ??
                  <String>{};

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestoreService.candidatesStream(),
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final candidates = (snapshot.data?.docs ?? []).where((doc) {
                    final data = doc.data();
                    final name = data["candidateName"]?.toString() ?? "";
                    final assessmentId = data["assessmentId"]?.toString() ?? "";
                    final status = data["status"]?.toString() ?? "started";
                    final searchable = "$name $assessmentId $status"
                        .toLowerCase();
                    return searchable.contains(query.toLowerCase());
                  }).toList();

                  final completedCount = candidates
                      .where((doc) => doc.data()["status"] == "completed")
                      .length;
                  final cheatingCount = candidates.where((doc) {
                    final data = doc.data();
                    return cheatingKeys.contains(
                      _candidateKey(
                        data["candidateName"]?.toString() ?? "",
                        data["assessmentId"]?.toString() ?? "",
                      ),
                    );
                  }).length;

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
                            Expanded(
                              child: Text(
                                "Candidates",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricPill(
                                label: "Applicants",
                                value: "${candidates.length}",
                                icon: Icons.groups_rounded,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricPill(
                                label: "Completed",
                                value: "$completedCount",
                                icon: Icons.task_alt_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricPill(
                                label: "Alerts",
                                value: "$cheatingCount",
                                icon: Icons.warning_rounded,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: "Search by name, exam, or status",
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (candidates.isEmpty)
                          const GlassCard(
                            child: Text(
                              "No candidates found yet.",
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                          )
                        else
                          ...candidates.map((doc) {
                            final data = doc.data();
                            final completedAt = data["completedAt"];
                            final loginTime = data["loginTime"];
                            final name =
                                data["candidateName"]?.toString() ??
                                "Candidate";
                            final assessmentId =
                                data["assessmentId"]?.toString() ?? "";
                            final hasCheated = cheatingKeys.contains(
                              _candidateKey(name, assessmentId),
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        _StatusBadge(
                                          status:
                                              data["status"]?.toString() ??
                                              "started",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _InfoChip(
                                          icon: Icons.badge_rounded,
                                          label: "Exam $assessmentId",
                                        ),
                                        _InfoChip(
                                          icon: Icons.scoreboard_rounded,
                                          label:
                                              "${data["totalScore"] ?? 0}/${data["totalMarks"] ?? 0} marks",
                                        ),
                                        _InfoChip(
                                          icon: hasCheated
                                              ? Icons.warning_amber_rounded
                                              : Icons.verified_rounded,
                                          label: hasCheated
                                              ? "Malpractice flagged"
                                              : "No alerts",
                                          color: hasCheated
                                              ? AppColors.error
                                              : AppColors.success,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (completedAt is Timestamp)
                                      Text(
                                        "Submitted: ${_formatTimestamp(completedAt)}",
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 12,
                                        ),
                                      )
                                    else if (loginTime is Timestamp)
                                      Text(
                                        "Started: ${_formatTimestamp(loginTime)}",
                                        style: const TextStyle(
                                          color: AppColors.textGrey,
                                          fontSize: 12,
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
              );
            },
          ),
        ),
      ),
    );
  }

  String _candidateKey(String name, String assessmentId) {
    return "${name.trim().toLowerCase()}::$assessmentId";
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

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color == AppColors.textGrey ? null : color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == "completed";
    final color = isCompleted ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}
