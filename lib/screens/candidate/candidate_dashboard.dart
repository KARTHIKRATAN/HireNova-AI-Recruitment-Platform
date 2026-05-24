import 'package:flutter/material.dart';

import '../../widgets/feature_card.dart';
import 'assessment_screen.dart';
import 'coding_screen.dart';

class CandidateDashboard extends StatelessWidget {
  const CandidateDashboard({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Candidate Dashboard"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              Text(
                "Welcome Candidate 🚀",

                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 10),

              Text(
                "Attend AI-powered assessments",

                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),

              const SizedBox(height: 40),

              GestureDetector(

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                      const AssessmentScreen(),
                    ),
                  );
                },

                child: const FeatureCard(
                  icon: Icons.quiz,
                  title: "Technical Assessment",
                  subtitle:
                  "Attend MCQ technical round",
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(

                onTap: () {

                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) =>
                      const CodingScreen(),
                    ),
                  );
                },

                child: const FeatureCard(
                  icon: Icons.code,
                  title: "Coding Round",
                  subtitle:
                  "Solve programming challenges",
                ),
              ),

              const SizedBox(height: 20),

              const FeatureCard(
                icon: Icons.workspace_premium,
                title: "Skill Insights",
                subtitle:
                "View your technical performance",
              ),
            ],
          ),
        ),
      ),
    );
  }
}