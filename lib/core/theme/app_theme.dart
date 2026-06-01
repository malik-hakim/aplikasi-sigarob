import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Warna Semantik Alert Level ────────────────────────────────────────────────
class AlertColors {
  static const aman     = Color(0xFF10B981); // emerald
  static const amanBg   = Color(0xFFECFDF5);
  static const info     = Color(0xFF2196F3); // blue
  static const infoBg   = Color(0xFFEFF6FF);
  static const waspada  = Color(0xFFF59E0B); // amber
  static const waspadaBg= Color(0xFFFFFBEB);
  static const siaga    = Color(0xFFF97316); // orange
  static const siagaBg  = Color(0xFFFFF7ED);
  static const evakuasi = Color(0xFFEF4444); // red
  static const evakuasiBg = Color(0xFFFEF2F2);

  static Color forLevel(String? level) {
    switch ((level ?? '').toUpperCase()) {
      case 'AMAN':     return aman;
      case 'INFO':     return info;
      case 'WASPADA':  return waspada;
      case 'SIAGA':    return siaga;
      case 'EVAKUASI': return evakuasi;
      default:         return info;
    }
  }

  static Color bgForLevel(String? level) {
    switch ((level ?? '').toUpperCase()) {
      case 'AMAN':     return amanBg;
      case 'INFO':     return infoBg;
      case 'WASPADA':  return waspadaBg;
      case 'SIAGA':    return siagaBg;
      case 'EVAKUASI': return evakuasiBg;
      default:         return infoBg;
    }
  }

  static String labelForLevel(String? level) {
    switch ((level ?? '').toUpperCase()) {
      case 'AMAN':     return 'AMAN';
      case 'INFO':     return 'INFO';
      case 'WASPADA':  return 'WASPADA';
      case 'SIAGA':    return 'SIAGA';
      case 'EVAKUASI': return 'EVAKUASI';
      default:         return 'INFO';
    }
  }

  static IconData iconForLevel(String? level) {
    switch ((level ?? '').toUpperCase()) {
      case 'AMAN':     return Icons.shield_outlined;
      case 'INFO':     return Icons.info_outline;
      case 'WASPADA':  return Icons.warning_amber_outlined;
      case 'SIAGA':    return Icons.shield_outlined;
      case 'EVAKUASI': return Icons.crisis_alert;
      default:         return Icons.info_outline;
    }
  }
}

// ── Palette Utama ─────────────────────────────────────────────────────────────
class AppColors {
  // Primary brand
  static const primary     = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1565C0);
  static const primaryLight= Color(0xFFBBDEFB);

  // Background
  static const bgPage      = Color(0xFFF0F2F5);
  static const bgCard      = Color(0xFFFFFFFF);
  static const bgSidebar   = Color(0xFF1A2035);

  // Text
  static const textMain    = Color(0xFF1A2035);
  static const textSub     = Color(0xFF6B7280);
  static const textMuted   = Color(0xFF9CA3AF);

  // Border
  static const border      = Color(0xFFE5E9F0);

  // Semantic
  static const success     = Color(0xFF10B981);
  static const successBg   = Color(0xFFECFDF5);
  static const warning     = Color(0xFFF59E0B);
  static const warningBg   = Color(0xFFFFFBEB);
  static const danger      = Color(0xFFEF4444);
  static const dangerBg    = Color(0xFFFEF2F2);
  static const info        = Color(0xFF2196F3);
  static const infoBg      = Color(0xFFEFF6FF);
}

// ── Theme ─────────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.bgCard,
        onSurface: AppColors.textMain,
      ),
      scaffoldBackgroundColor: AppColors.bgPage,
    );

    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).copyWith(
        bodyLarge:    GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontSize: 14),
        bodyMedium:   GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontSize: 13),
        bodySmall:    GoogleFonts.plusJakartaSans(color: AppColors.textSub,  fontSize: 12),
        labelSmall:   GoogleFonts.plusJakartaSans(color: AppColors.textMuted,fontSize: 11),
        titleLarge:   GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium:  GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall:   GoogleFonts.plusJakartaSans(color: AppColors.textMain, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

// ── Text Styles Helper ────────────────────────────────────────────────────────
class AppText {
  static TextStyle mono({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color ?? AppColors.textMain);

  static TextStyle label({double size = 11, Color? color}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size, fontWeight: FontWeight.w600,
      letterSpacing: 0.5, color: color ?? AppColors.textSub,
    );
}
