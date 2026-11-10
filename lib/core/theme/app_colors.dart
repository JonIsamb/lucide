import 'package:flutter/material.dart';

/// The Lucide palette. Every color is named by its role, not its hue, so
/// widgets never hard-code hex values. The greens, the background and the
/// text color are those of the brand (app icon and splash screen).
///
/// Text pairs checked for the 4.5:1 contrast ratio (WCAG AA):
/// ink, muted, rise, fall and primary on background and surface; white on
/// primary and ink.
abstract final class AppColors {
  /// Emerald dark (brand): main buttons, active tab, filled star, sort
  /// button, links. Also the icon and splash screen background.
  static const primary = Color(0xFF047857);

  /// Logo fallback, light tints, active tab indicator.
  static const lightGreen = Color(0xFFD7F5E8);

  /// Mist (brand): the app background.
  static const background = Color(0xFFF2F5F3);
  static const surface = Color(0xFFFFFFFF);

  /// Main text (brand ink, a very dark green).
  static const ink = Color(0xFF13221C);

  /// Secondary text (subtitles, labels).
  static const muted = Color(0xFF6B605A);
  static const divider = Color(0xFFE6E0DA);

  /// Price went up (vert sapin).
  static const rise = Color(0xFF1D5A43);

  /// Price went down, and alerts (corail).
  static const fall = Color(0xFFB23A24);

  /// Light backgrounds behind rise and fall text (game result banners).
  /// rise on riseTint and fall on fallTint keep the 4.5:1 ratio.
  static const riseTint = Color(0xFFDDF0E7);
  static const fallTint = Color(0xFFFDE8E3);

  /// Background of the last simulation card on the home screen. White text
  /// on it keeps the 4.5:1 ratio.
  static const simulationCard = Color(0xFF047857);

  /// Bar of the last simulation card (on simulationCard): what the costs
  /// took, and what is left.
  static const costSegment = Color(0xFF0B5E46);
  static const remainSegment = Color(0xFF6EE7B7);

  /// Background of the "Teste ton intuition" shortcut, and its text.
  static const gameTint = Color(0xFFECE8FB);
  static const gameInk = Color(0xFF4B3A9E);

  /// Grey used by loading skeletons.
  static const skeleton = Color(0xFFECE7E2);
}
