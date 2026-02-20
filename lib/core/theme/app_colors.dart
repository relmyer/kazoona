import 'package:flutter/material.dart';

class AppColors {
  // ─── Background ───────────────────────────────────────────
  static const Color bgDark    = Color(0xFF0C0C0C);
  static const Color bgCard    = Color(0xFF1C1C1C);
  static const Color bgSurface = Color(0xFF262626);
  static const Color bgBorder  = Color(0xFF333333);

  // ─── Primary (coral) ──────────────────────────────────────
  static const Color primary      = Color(0xFFFF6060);
  static const Color primaryDark  = Color(0xFFCC3333);
  static const Color primaryLight = Color(0xFFFF8888);

  // ─── Scratch gold ─────────────────────────────────────────
  static const Color scratchGold      = Color(0xFFF5A623);
  static const Color scratchGoldLight = Color(0xFFFFCC55);

  // ─── Text ─────────────────────────────────────────────────
  static const Color white     = Color(0xFFFFFFFF);
  static const Color grey      = Color(0xFF7A7A7A);
  static const Color greyLight = Color(0xFFAAAAAA);
  static const Color greyDark  = Color(0xFF333333);

  // ─── Card accent colors ───────────────────────────────────
  static const Color cardOrange = Color(0xFFFF8C42);
  static const Color cardGold   = Color(0xFFFFB800);
  static const Color cardGreen  = Color(0xFF3DB87B);
  static const Color cardBlue   = Color(0xFF4E9FED);
  static const Color cardPurple = Color(0xFF9B51E0);
  static const Color cardPink   = Color(0xFFE05CB0);
  static const Color cardRed    = Color(0xFFE05252);

  // ─── Utility ──────────────────────────────────────────────
  static const Color success = Color(0xFF3DB87B);
  static const Color error   = Color(0xFFFF4444);

  // ─── Gradients ────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFFFF6060),
    Color(0xFFFF9060),
  ];
  static const List<Color> scratchGradient = [
    Color(0xFFF5A623),
    Color(0xFFFFCC55),
  ];
  static const List<Color> bgGradient = [
    Color(0xFF0C0C0C),
    Color(0xFF1C1C1C),
  ];
  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFF5A623),
    Color(0xFFFF8C00),
  ];
}
