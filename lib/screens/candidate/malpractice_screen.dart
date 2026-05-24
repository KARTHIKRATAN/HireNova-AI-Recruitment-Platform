import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/app_background.dart';
import '../../widgets/custom_button.dart';
import '../auth/role_selection_screen.dart';

class MalpracticeScreen extends StatefulWidget {
  final String violationType;

  const MalpracticeScreen({super.key, required this.violationType});

  @override
  State<MalpracticeScreen> createState() => _MalpracticeScreenState();
}

class _MalpracticeScreenState extends State<MalpracticeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.94,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: const Icon(
                          Icons.gpp_bad_rounded,
                          color: AppColors.error,
                          size: 58,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      "Exam stopped",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Exam has been stopped due to malpractice detection.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Violation: ${widget.violationType}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 28),
                    CustomButton(
                      text: "Back to Home",
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoleSelectionScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
