import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.appGradient
            : const LinearGradient(
                colors: [
                  AppColors.lightBackground,
                  Color(0xFFEFF6FF),
                  Color(0xFFF5F3FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: child,
    );
  }
}
