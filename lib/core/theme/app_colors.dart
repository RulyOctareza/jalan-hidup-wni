import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primarySoft = Color(0xFF66BB6A);
  static const Color gold = Color(0xFFFFC107);
  static const Color goldDeep = Color(0xFFFFA000);
  static const Color red = Color(0xFFD32F2F);
  static const Color cream = Color(0xFFFFF8E1);
  static const Color creamDeep = Color(0xFFFFECB3);
  static const Color blue = Color(0xFF1565C0);
  static const Color textDark = Color(0xFF1B1B1B);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF3F0E8);

  static List<BoxShadow> softShadow({Color? color}) => [
        BoxShadow(
          color: (color ?? primaryDark).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 14,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
}
