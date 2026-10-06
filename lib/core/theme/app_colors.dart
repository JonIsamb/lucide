import 'package:flutter/material.dart';

/// The Lucide palette. Every color is named by its role, not its hue, so
/// widgets never hard-code hex values.
///
/// Text pairs checked for the 4.5:1 contrast ratio (WCAG AA):
/// ink, muted, rise and fall on background and surface; white on primary
/// and ink; primary on sand.
abstract final class AppColors {
  /// Bordeaux: main buttons, active tab, filled star, sort button, links.
  static const primary = Color(0xFF7A1A33);

  /// Logo fallback, light tints, active tab indicator.
  static const sand = Color(0xFFE8DCC8);

  static const background = Color(0xFFF5F3F1);
  static const surface = Color(0xFFFFFFFF);

  /// Main text.
  static const ink = Color(0xFF1F1A17);

  /// Secondary text (subtitles, labels).
  static const muted = Color(0xFF6B605A);
  static const divider = Color(0xFFE6E0DA);

  /// Price went up (vert sapin).
  static const rise = Color(0xFF1D5A43);

  /// Price went down, and alerts (corail).
  static const fall = Color(0xFFB23A24);

  /// Grey used by loading skeletons.
  static const skeleton = Color(0xFFECE7E2);
}
