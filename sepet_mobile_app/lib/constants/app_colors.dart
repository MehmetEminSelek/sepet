import 'package:flutter/material.dart';

/// Modern uygulama renkleri ve tasarım sistemi
class AppColors {
  // Ana renkler - Gelişmiş gradyanlar
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryBlueDark = Color(0xFF4F46E5);
  static const Color primaryBlueLight = Color(0xFF818CF8);

  // Secondary renkler
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryTeal = Color(0xFF06B6D4);
  static const Color secondaryEmerald = Color(0xFF10B981);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundSecondary = Color(0xFFF1F5F9);
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundDarkSecondary = Color(0xFF1E293B);
  static const Color cardBackgroundDark = Color(0xFF334155);
  static const Color surfaceColorDark = Color(0xFF1E293B);

  // Metin renkleri - Light theme
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textLight = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Metin renkleri - Dark theme
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textLightDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Durum renkleri - Modernize edildi
  static const Color successGreen = Color(0xFF22C55E);
  static const Color successGreenLight = Color(0xFFDCFCE7);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningOrangeLight = Color(0xFFFEF3C7);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedLight = Color(0xFFFEE2E2);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueLight = Color(0xFFDEF7FF);

  // Çizgi ve border renkleri
  static const Color dividerColor = Color(0xFFE2E8F0);
  static const Color dividerColorDark = Color(0xFF475569);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  static const Color shadowColor = Colors.black12;
  static const Color shadowColorDark = Colors.black26;

  // Gradient'lar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryTeal, secondaryEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [secondaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // İstatistik kartları için modern renkler
  static const Color statCardBlue = Color(0xFFEFF6FF);
  static const Color statCardBlueDark = Color(0xFF1E3A8A);
  static const Color statCardGreen = Color(0xFFECFDF5);
  static const Color statCardGreenDark = Color(0xFF14532D);
  static const Color statCardOrange = Color(0xFFFFF7ED);
  static const Color statCardOrangeDark = Color(0xFF9A3412);
  static const Color statCardPurple = Color(0xFFFAF5FF);
  static const Color statCardPurpleDark = Color(0xFF581C87);

  // Modern pastel renk paleti (sepetler için)
  static const Color modernPink = Color(0xFFFDF2F8);
  static const Color modernBlue = Color(0xFFEFF6FF);
  static const Color modernTeal = Color(0xFFF0FDFA);
  static const Color modernYellow = Color(0xFFFFFBEB);
  static const Color modernGreen = Color(0xFFECFDF5);
  static const Color modernPurple = Color(0xFFFAF5FF);
  static const Color modernOrange = Color(0xFFFFF7ED);
  static const Color modernIndigo = Color(0xFFEEF2FF);
  static const Color modernRose = Color(0xFFFFF1F2);
  static const Color modernEmerald = Color(0xFFECFDF5);

  // Modern sepet renk paleti
  static const List<Color> modernSepetColors = [
    modernPink,
    modernBlue,
    modernTeal,
    modernYellow,
    modernGreen,
    modernPurple,
    modernOrange,
    modernIndigo,
    modernRose,
    modernEmerald,
  ];

  // Gradient sepet renkleri
  static const List<LinearGradient> sepetGradients = [
    roseGradient,
    primaryGradient,
    tealGradient,
    orangeGradient,
    emeraldGradient,
    purpleGradient,
  ];

  // Shimmer loading colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
  static const Color shimmerBaseDark = Color(0xFF374151);
  static const Color shimmerHighlightDark = Color(0xFF4B5563);
}
