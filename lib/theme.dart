import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _bgLight = Color(0xFFF3F1EA);
  static const _bgDark = Color(0xFF121A1C);

  static final light = _build(
    const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2F7F6F),
      onPrimary: Colors.white,
      secondary: Color(0xFFB8954A),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFFBF9F4),
      onSurface: Color(0xFF23302D),
      outline: Color(0xFF7A8783),
    ),
    _bgLight,
  );

  static final dark = _build(
    const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF7CCBB5),
      onPrimary: Color(0xFF0B2B24),
      secondary: Color(0xFFD9B66C),
      onSecondary: Color(0xFF2B2108),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF1B2628),
      onSurface: Color(0xFFE6EDEA),
      outline: Color(0xFF8FA39E),
    ),
    _bgDark,
  );

  static ThemeData _build(ColorScheme cs, Color bg) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
    );
    return base.copyWith(
      textTheme: GoogleFonts.cairoTextTheme(base.textTheme)
          .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: cs.onSurface,
        titleTextStyle: GoogleFonts.cairo(
            fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withOpacity(.18),
        labelTextStyle: WidgetStatePropertyAll(
            GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
