import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'candidate_dashboard.dart';

class EnterExamScreen extends StatefulWidget {
  const EnterExamScreen({super.key});

  @override
  State<EnterExamScreen> createState() =>
      _EnterExamScreenState();
}

class _EnterExamScreenState
    extends State<EnterExamScreen> {

  final TextEditingController examIdController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Exam Verification"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 30),

            Text(
              "Enter Exam Credentials 🔐",

              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 15),

            Text(
              "Enter Exam ID and password provided by HR",

              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),

            const SizedBox(height: 50),

            CustomTextField(
              hintText: "Exam ID",
              controller: examIdController,
            ),

            const SizedBox(height: 20),

            CustomTextField(
              hintText: "Exam Password",
              controller: passwordController,
              obscureText: true,
            ),

            const SizedBox(height: 40),

            CustomButton(

              text: "Start Exam",

              onPressed: () {

                Navigator.pushReplacement(
                  context,

                  MaterialPageRoute(
                    builder: (context) =>
                    const CandidateDashboard(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}