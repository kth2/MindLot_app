import 'package:flutter/material.dart';

/// Temple-inspired palette: vermilion lacquer, incense gold, rice paper,
/// and deep night-shrine tones for dark mode.
abstract final class AppColors {
  // Brand
  static const vermilion = Color(0xFFB3402A); // 朱紅 — temple pillars
  static const vermilionDeep = Color(0xFF8E2F1E);
  static const gold = Color(0xFFC9A227); // 香金 — incense gold
  static const goldSoft = Color(0xFFE3C978);

  // Light (rice paper day)
  static const paper = Color(0xFFF7F1E3); // 宣紙
  static const paperCard = Color(0xFFFFFBF0);
  static const ink = Color(0xFF2B2320); // 墨
  static const inkSoft = Color(0xFF6B5D52);

  // Dark (night shrine)
  static const lacquerNight = Color(0xFF171210); // 夜殿
  static const lacquerCard = Color(0xFF241C18);
  static const candleText = Color(0xFFF0E6D2);
  static const candleTextSoft = Color(0xFFB3A48C);

  // Fortune levels (籤等) — handles both the coarse 上籤/中籤/下籤 scheme and
  // finer grades (上上/上吉/中吉/中平/下下) used by other lot sets.
  static const levelGreat = Color(0xFFB3402A); // 上籤/上上/上吉
  static const levelGood = Color(0xFFC9A227); // 中吉
  static const levelNeutral = Color(0xFF7D8A6A); // 中籤/中平
  static const levelCaution = Color(0xFF5C6B8A); // 下籤/下下

  static Color levelColor(String level) {
    if (level.startsWith('上')) return levelGreat;
    if (level == '中吉') return levelGood;
    if (level.startsWith('中')) return levelNeutral;
    if (level.startsWith('下')) return levelCaution;
    return levelNeutral;
  }
}
