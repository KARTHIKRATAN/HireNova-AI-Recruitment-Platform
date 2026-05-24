import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/glass_card.dart';
import '../hr/hr_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    final authProvider = context.read<AppAuthProvider>();

    final isLoggedIn = await authProvider.loginHR(
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? "Login failed. Check your details.",
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HRDashboard()),
    );
  }

  Future<void> continueWithGoogle() async {
    final authProvider = context.read<AppAuthProvider>();
    final isLoggedIn = await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Google sign in failed."),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HRDashboard()),
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
                const SizedBox(height: 16),
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(height: 28),
                Text(
                  "Welcome back",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter the hiring cockpit and keep assessments moving.",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 30),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        hintText: "Work email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        icon: Icons.mail_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: "Password",
                        controller: passwordController,
                        obscureText: true,
                        icon: Icons.lock_outline_rounded,
                      ),
                      const SizedBox(height: 22),
                      CustomButton(
                        text: "Login",
                        isLoading: authProvider.isLoading,
                        onPressed: login,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "or",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New to HireNova?",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Create HR account"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const GlassCard(
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "AI questions, coding rounds, analytics, and cheating alerts.",
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
