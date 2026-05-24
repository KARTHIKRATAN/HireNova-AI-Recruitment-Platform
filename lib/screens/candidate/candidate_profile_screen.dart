import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Candidate Profile")),

      body: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 55,

              backgroundImage: NetworkImage("https://i.pravatar.cc/300"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Alex Johnson",

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text("alex@gmail.com", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Text(
                "Flutter Developer Candidate",

                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 50),

            buildTile(
              icon: Icons.quiz,
              title: "Assessments Attended",
              value: "12",
            ),

            const SizedBox(height: 20),

            buildTile(
              icon: Icons.workspace_premium,
              title: "Average Score",
              value: "88%",
            ),

            const SizedBox(height: 20),

            buildTile(icon: Icons.code, title: "Coding Accuracy", value: "91%"),
          ],
        ),
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.cardColor,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),

          const SizedBox(width: 20),

          Expanded(
            child: Text(
              title,

              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          Text(
            value,

            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
