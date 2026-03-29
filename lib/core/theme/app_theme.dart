import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== 品牌色 =====
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF43B89C);
  static const Color accentColor = Color(0xFFFF6B6B);

  // ===== 标签颜色 =====
  static const Color tagStudy = Color(0xFF4A90D9);
  static const Color tagWork = Color(0xFF7C4DFF);
  static const Color tagEntertain = Color(0xFFFF7043);
  static const Color tagRest = Color(0xFF43A047);
  static const Color tagSocial = Color(0xFFEC407A);
  static const Color tagShopping = Color(0xFFFFB300);
  static const Color tagExercise = Color(0xFF00ACC1);
  static const Color tagOther = Color(0xFF78909C);

  // ===== 语义化状态颜色 =====
  static const Color successColor = Color(0xFF4CAF50);  // 绿色 - 成功/正常
  static const Color warningColor = Color(0xFFFF9800);  // 橙色 - 警告
  static const Color errorColor = Color(0xFFF44336);   // 红色 - 错误/危险
  static const Color infoColor = Color(0xFF2196F3);    // 蓝色 - 信息

  // ===== 浅色主题 =====
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: const Color(0xFFF8F9FF),
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF0F2FF),
      textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: primaryColor.withValues(alpha: 0.08),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: primaryColor.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return const TextStyle(fontSize: 12, color: Color(0xFF94A3B8));
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1D2E),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1A1D2E)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0F2FF),
        selectedColor: primaryColor.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ===== 深色主题 =====
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: const Color(0xFF9D8FFF),
        secondary: const Color(0xFF5ECDB0),
        surface: const Color(0xFF1A1D2E),
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1117),
      textTheme: GoogleFonts.notoSansScTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFE2E8F0),
        displayColor: const Color(0xFFE2E8F0),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1A1D2E),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1A1D2E),
        elevation: 0,
        indicatorColor: const Color(0xFF9D8FFF).withValues(alpha: 0.2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1D2E),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
