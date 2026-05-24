import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;

  final bool obscureText;

  final TextEditingController controller;

  final IconData? icon;

  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.textGrey
              : AppColors.textDark.withValues(alpha: 0.45),
        ),
        prefixIcon: icon == null
            ? null
            : Icon(
                icon,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.86),
      ),
    );
  }
}
