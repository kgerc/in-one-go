import 'package:flutter/material.dart';

/// ADHD-Friendly Color Palette
/// Based on calm neutrals + single soft accent principle
/// Designed to reduce cognitive load and decision paralysis
class AppColors {
  // ============================================
  // 🎨 BASE PALETTE - Calm Neutral + Soft Accent
  // ============================================

  /// Primary action color - Soft teal (TYLKO dla CTA, recording button, active tab)
  static const Color primary = Color(0xFF4FA3A5); // Soft blue-green teal
  static const Color primaryDark = Color(0xFF3D8385);
  static const Color primaryLight = Color(0xFF6BB3B5);

  /// Legacy secondary (kept for compatibility, use primary instead)
  static const Color secondary = Color(0xFF4FA3A5);
  static const Color secondaryDark = Color(0xFF3D8385);
  static const Color secondaryLight = Color(0xFF6BB3B5);

  /// Single accent color (same as primary - ONE color for decisions)
  static const Color accent = Color(0xFF4FA3A5);
  static const Color accentDark = Color(0xFF3D8385);
  static const Color accentLight = Color(0xFF6BB3B5);

  // ============================================
  // 🌅 LIGHT MODE - Calm & Soothing
  // ============================================

  /// Off-white background (better than pure white, less eye strain)
  static const Color background = Color(0xFFFAFAF7);

  /// Card/surface color (slightly elevated from background)
  static const Color surface = Color(0xFFFFFFFF);

  // ============================================
  // 🌙 DARK MODE - Soft & Comfortable
  // ============================================

  /// Dark background (true black #000000 avoided - too harsh)
  static const Color backgroundDark = Color(0xFF121212);

  /// Dark surface/card (elevated from background)
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ============================================
  // 📝 TEXT COLORS - Readable but Gentle
  // ============================================

  /// Main text - soft charcoal (NOT black, easier on eyes)
  static const Color textPrimary = Color(0xFF2E2E2E);

  /// Secondary text - muted gray
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Tertiary/hint text
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// Text on dark backgrounds
  static const Color textWhite = Color(0xFFEDEDED); // Slightly off-white

  // ============================================
  // ✅ STATUS COLORS - Subtle & Non-Alarming
  // ============================================

  /// Success (soft green, not vibrant)
  static const Color success = Color(0xFF4FA3A5); // Use teal for consistency

  /// Error (muted red, not alarming)
  static const Color error = Color(0xFFD97777); // Softer red

  /// Warning (calm amber)
  static const Color warning = Color(0xFFE8B86D);

  /// Info (uses primary teal)
  static const Color info = Color(0xFF4FA3A5);

  // ============================================
  // 📅 EVENT TYPE COLORS - Calm & Distinguishable
  // ============================================

  /// Meeting - soft teal (primary color)
  static const Color eventMeeting = Color(0xFF4FA3A5);

  /// Appointment - soft sage green
  static const Color eventAppointment = Color(0xFF88B88F);

  /// Reminder - soft lavender
  static const Color eventReminder = Color(0xFF9B9FC4);

  /// Task - soft coral
  static const Color eventTask = Color(0xFFD4A5A5);

  // ============================================
  // 🎯 PRIORITY COLORS - Non-Stressful
  // ============================================

  /// Low priority - light gray
  static const Color priorityLow = Color(0xFF9CA3AF);

  /// Medium priority - primary teal
  static const Color priorityMedium = Color(0xFF4FA3A5);

  /// High priority - soft amber
  static const Color priorityHigh = Color(0xFFE8B86D);

  /// Urgent - muted coral (NOT bright red!)
  static const Color priorityUrgent = Color(0xFFD97777);

  // ============================================
  // 🎨 UI ELEMENTS - Subtle & Clean
  // ============================================

  /// Divider/separator - light gray (subtle)
  static const Color divider = Color(0xFFE6E6E6);

  /// Border color
  static const Color border = Color(0xFFE6E6E6);

  /// Disabled state
  static const Color disabled = Color(0xFFCCCCCC);

  /// Shadow (very subtle)
  static const Color shadow = Color(0x0A000000);

  // ============================================
  // 🌈 GRADIENTS - Calm & Soothing
  // ============================================

  /// Primary gradient (teal)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4FA3A5), Color(0xFF6BB3B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient (same as primary for consistency)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4FA3A5), Color(0xFF6BB3B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
