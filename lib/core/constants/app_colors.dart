import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF080B12);
  static const Color surface = Color(0xFF111827);
  static const Color cardColor = Color(0xFF151A27);
  static const Color glass = Color(0x14FFFFFF);

  static const Color primary = Color(0xFF7C3AED);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFA3E635);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);

  static const Color textWhite = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGrey = Color(0xFF94A3B8);
  static const Color borderColor = Color(0x22FFFFFF);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient appGradient = LinearGradient(
    colors: [Color(0xFF080B12), Color(0xFF101527), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
