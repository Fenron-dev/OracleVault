// Datei: lib/core/theme.dart
//
// ZWECK: App-Theme — exakt nach den Wireframe-Farbvariablen definiert.
//        Kein fromSeed, sondern explizites ColorScheme damit die Mockup-Farben
//        1:1 erhalten bleiben.
//
// CSS-VARIABLEN → FLUTTER-TOKEN-MAPPING:
//   --bg-primary       → surface
//   --bg-secondary     → surfaceContainerLow  (Sidebar, Detail-Bg, etc.)
//   --border           → outline / outlineVariant
//   --text-primary     → onSurface
//   --text-secondary   → onSurfaceVariant
//   --text-tertiary    → surfaceContainerHighest (genutzt via .withAlpha)
//   --accent-bg        → primaryContainer
//   --accent-text      → primary
//   --accent-border    → secondary (wird als Akzent-Border genutzt)
//   --warning-bg       → tertiaryContainer
//   --warning-text     → onTertiaryContainer
//   --warning-border   → tertiary
//
// ABHÄNGIGKEITEN: Flutter
// PHASE: 0 – angepasst Phase 1 (exakte Mockup-Farben).

import 'package:flutter/material.dart';

abstract class AppTheme {
  // ── Spacing-Skala ──────────────────────────────────────────────────────────
  // Niemals Zwischenwerte.
  static const double sp4 = 4;
  static const double sp8 = 8;
  static const double sp12 = 12;
  static const double sp16 = 16;
  static const double sp24 = 24;
  static const double sp32 = 32;

  // ── Maximale Inhaltsbreite (Desktop) ──────────────────────────────────────
  static const double maxContentWidth = 1080.0;

  // ── Panel-Breiten ──────────────────────────────────────────────────────────
  static const double sidebarWidth = 200.0;
  static const double detailWidth = 280.0;

  // ── Helle Palette (aus wireframe CSS-Variablen) ────────────────────────────
  static const Color _lightBgPrimary   = Color(0xFFFFFFFF);
  static const Color _lightBgSecondary = Color(0xFFF7F6F4);
  static const Color _lightBorder      = Color(0xFFE4E1DB);
  static const Color _lightTextPrimary = Color(0xFF1F1E1B);
  static const Color _lightTextSecond  = Color(0xFF5C5A55);
  static const Color _lightTextTertiary= Color(0xFF8F8B83);
  static const Color _lightAccentBg    = Color(0xFFDDEEEA);
  static const Color _lightAccentText  = Color(0xFF0F5A4A);
  static const Color _lightAccentBorder= Color(0xFF1F7A65);
  static const Color _lightWarnBg      = Color(0xFFFFF4DA);
  static const Color _lightWarnText    = Color(0xFF8A5A0F);
  static const Color _lightWarnBorder  = Color(0xFFD9B870);
  // _lightSuccessBg / _lightSuccessText — reserviert für Phase 6 (Inbox-Status).

  // ── Dunkle Palette ─────────────────────────────────────────────────────────
  static const Color _darkBgPrimary    = Color(0xFF1A1817);
  static const Color _darkBgSecondary  = Color(0xFF232220);
  static const Color _darkBorder       = Color(0xFF3A3835);
  static const Color _darkTextPrimary  = Color(0xFFF0EFED);
  static const Color _darkTextSecond   = Color(0xFFB5B2AB);
  static const Color _darkTextTertiary = Color(0xFF807C74);
  static const Color _darkAccentBg     = Color(0xFF1A3E37);
  static const Color _darkAccentText   = Color(0xFF6FB8A5);
  static const Color _darkAccentBorder = Color(0xFF2D6B5E);
  static const Color _darkWarnBg       = Color(0xFF3E3315);
  static const Color _darkWarnText     = Color(0xFFD9B870);
  static const Color _darkWarnBorder   = Color(0xFF6B5530);

  // ── Öffentliche Farbzugriffe (für Widgets die keine ColorScheme brauchen) ──
  static Color accentBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkAccentBg
          : _lightAccentBg;
  static Color accentText(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkAccentText
          : _lightAccentText;
  static Color accentBorder(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkAccentBorder
          : _lightAccentBorder;
  static Color bgSecondary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkBgSecondary
          : _lightBgSecondary;
  static Color border(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkBorder
          : _lightBorder;
  static Color textTertiary(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkTextTertiary
          : _lightTextTertiary;
  static Color warnBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkWarnBg
          : _lightWarnBg;
  static Color warnText(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkWarnText
          : _lightWarnText;
  static Color warnBorder(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? _darkWarnBorder
          : _lightWarnBorder;

  // ── ThemeData ──────────────────────────────────────────────────────────────

  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        surface: _lightBgPrimary,
        surfaceContainerLow: _lightBgSecondary,
        onSurface: _lightTextPrimary,
        onSurfaceVariant: _lightTextSecond,
        outline: _lightBorder,
        outlineVariant: _lightBorder,
        primary: _lightAccentText,
        onPrimary: _lightBgPrimary,
        primaryContainer: _lightAccentBg,
        onPrimaryContainer: _lightAccentText,
        secondary: _lightAccentBorder,
        onSecondary: _lightBgPrimary,
        secondaryContainer: _lightAccentBg,
        onSecondaryContainer: _lightAccentText,
        tertiary: _lightWarnBorder,
        onTertiary: _lightBgPrimary,
        tertiaryContainer: _lightWarnBg,
        onTertiaryContainer: _lightWarnText,
        error: const Color(0xFFB00020),
        onError: _lightBgPrimary,
      );

  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        surface: _darkBgPrimary,
        surfaceContainerLow: _darkBgSecondary,
        onSurface: _darkTextPrimary,
        onSurfaceVariant: _darkTextSecond,
        outline: _darkBorder,
        outlineVariant: _darkBorder,
        primary: _darkAccentText,
        onPrimary: _darkBgPrimary,
        primaryContainer: _darkAccentBg,
        onPrimaryContainer: _darkAccentText,
        secondary: _darkAccentBorder,
        onSecondary: _darkBgPrimary,
        secondaryContainer: _darkAccentBg,
        onSecondaryContainer: _darkAccentText,
        tertiary: _darkWarnBorder,
        onTertiary: _darkBgPrimary,
        tertiaryContainer: _darkWarnBg,
        onTertiaryContainer: _darkWarnText,
        error: const Color(0xFFCF6679),
        onError: _darkBgPrimary,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color surface,
    required Color surfaceContainerLow,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color outlineVariant,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color tertiary,
    required Color onTertiary,
    required Color tertiaryContainer,
    required Color onTertiaryContainer,
    required Color error,
    required Color onError,
  }) {
    final cs = ColorScheme(
      brightness: brightness,
      surface: surface,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainerLow,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: tertiaryContainer,
      onErrorContainer: onTertiaryContainer,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: surface,
      // Kein standardmäßiger AppBar-Schatten.
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        toolbarHeight: 44,
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      // Kompakte Dichte für Desktop-Tabellen-Listen.
      visualDensity: VisualDensity.compact,
      listTileTheme: ListTileThemeData(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        minLeadingWidth: 16,
        iconColor: onSurfaceVariant,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: sp12, vertical: sp8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: primary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerLow,
        selectedColor: primaryContainer,
        labelStyle: TextStyle(fontSize: 11, color: onSurfaceVariant),
        padding: const EdgeInsets.symmetric(horizontal: sp4, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: outline),
        ),
      ),
      textTheme: TextTheme(
        // Basis: 13px wie im Mockup.
        bodyMedium: TextStyle(fontSize: 13, color: onSurface),
        bodySmall: TextStyle(fontSize: 11, color: onSurfaceVariant),
        labelSmall: TextStyle(
            fontSize: 10, color: onSurfaceVariant, letterSpacing: 0),
        titleSmall: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500, color: onSurface),
        titleMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
        headlineSmall: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: onSurface),
      ),
    );
  }
}
