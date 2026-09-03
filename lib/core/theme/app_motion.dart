import 'package:flutter/material.dart';

/// Shared motion tokens for consistent, intentional animation.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 220);
  static const Duration normal = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration dramatic = Duration(milliseconds: 900);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve softBounce = Curves.easeOutBack;
  static const Curve spring = Curves.elasticOut;

  static Duration stagger(int index, {int stepMs = 55}) =>
      Duration(milliseconds: stepMs * index);
}
