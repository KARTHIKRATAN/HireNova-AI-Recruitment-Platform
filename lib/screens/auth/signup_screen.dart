import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/glass_card.dart';
import '../hr/hr_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController companyController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    companyController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final companyName = companyController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        companyName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final authProvider = context.read<AppAuthProvider>();

    final isCreated = await authProvider.signUpHR(
      name: name,
      email: email,
      password: password,
      companyName: companyName,
    );

    if (!mounted) {
      return;
    }

    if (!isCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? "Signup failed. Please try again.",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Successfully signed up. Please login.")),
    );

    Navigator.pop(context);
  }

  Future<void> continueWithGoogle() async {
    final authProvider = context.read<AppAuthProvider>();
    final isLoggedIn = await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLoggedIn
              ? "Google sign in successful."
              : authProvider.errorMessage ?? "Google sign in failed.",
        ),
      ),
    );

    if (!isLoggedIn) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HRDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();

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
                const SizedBox(height: 24),
                Text(
                  "Create your hiring workspace",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  "Set up your HR account and start generating assessments.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.business_center_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomTextField(
                        hintText: "Full name",
                        controller: nameController,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: "Work email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: "Password",
                        controller: passwordController,
                        obscureText: true,
                        icon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        hintText: "Company name",
                        controller: companyController,
                        icon: Icons.apartment_rounded,
                      ),
                      const SizedBox(height: 22),
                      CustomButton(
                        text: "Create Account",
                        isLoading: authProvider.isLoading,
                        onPressed: createAccount,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: authProvider.isGoogleLoading
                              ? null
                              : continueWithGoogle,
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            color: AppColors.secondary,
                            size: 32,
                          ),
                          label: Text(
                            authProvider.isGoogleLoading
                                ? "Connecting..."
                                : "Continue with Google",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    "Profile photo upload can be connected to Firebase Storage next.",
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textGrey),
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
