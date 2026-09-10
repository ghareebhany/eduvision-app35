import 'package:flutter/material.dart';
import 'app_theme.dart';

/// ══════════════════════════════════════════════════════════════════════════════
///  AppPalette — لوحة ألوان EduVision الموحّدة
///  محدّثة على التصميم المعتمد:
///   • الوضع الليلي: كحلي عميق #001B41 + أزرق #026ECD + برتقالي #F87625
///   • الوضع الفاتح: نعناعي #F2FBFA + تركوازي #198E98 + كورال #FF625A
///
///  ملاحظة: الثوابت الخمسة (sage/peach/coral/plum/mocha) محفوظة للتوافق،
///  ويُفضّل استخدام الدوال الواعية بالثيم (coralOf / plumOf / mochaOf ...).
/// ══════════════════════════════════════════════════════════════════════════════
abstract class AppPalette {
  AppPalette._();

  // ── Core five (قيم الوضع الليلي كأساس) ────────────────────────────────────
  static const Color sage  = Color(0xFF8FA8CC);
  static const Color peach = Color(0xFFFFB37A);
  static const Color coral = AppTheme.coral500;      // #F87625
  static const Color plum  = AppTheme.mocha500;      // #026ECD
  static const Color mocha = AppTheme.mocha900;      // #001130

  // ── ألوان الوضع الفاتح ────────────────────────────────────────────────────
  static const Color coralOnLight = AppTheme.coralLight500; // #FF625A
  static const Color plumOnLight  = AppTheme.teal500;       // #198E98
  static const Color mochaOnLight = AppTheme.teal50;        // #F2FBFA
  static const Color sageOnLight  = AppTheme.teal200;       // #BDEBE0

  // ── Derived / helpers ─────────────────────────────────────────────────────
  static const Color sageLight  = AppTheme.teal100;  // #D7F6F5
  static const Color coralLight = Color(0x1FF87625); // coral @ 12%
  static const Color mochaLight = Color(0x14001B41); // navy @ 8%
  static const Color successGreen      = AppTheme.tealDark;
  static const Color successGreenLight = Color(0x1F23AB96);

  // ── Gradients (ليلي) ──────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [AppTheme.mocha900, AppTheme.mocha700],
  );

  static const LinearGradient headerGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
    colors: [AppTheme.teal50, AppTheme.teal100],
  );

  // مطابقة لأزرار AppTheme.button() حتى لا يظهر زرّان بلونين مختلفين
  // في نفس الشاشة.
  static const LinearGradient btnGradient = AppTheme.buttonGradient;

  static const LinearGradient btnGradientLight = AppTheme.buttonGradientLight;

  static const LinearGradient progressGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end:   Alignment.centerRight,
    colors: [AppTheme.coral500, AppTheme.mocha500],
  );

  static const LinearGradient progressGradientLight = LinearGradient(
    begin: Alignment.centerLeft,
    end:   Alignment.centerRight,
    colors: [AppTheme.coralLight500, AppTheme.teal500],
  );

  // ── Thumbnail gradients (course cards) ────────────────────────────────────
  static const List<List<Color>> thumbGradients = [
    [AppTheme.mocha500, AppTheme.mocha600],
    [AppTheme.coral500, AppTheme.coral600],
    [AppTheme.tealDark, AppTheme.teal600],
    [AppTheme.violet500, AppTheme.violet600],
    [AppTheme.mocha700, AppTheme.mocha800],
    [AppTheme.teal400, AppTheme.teal500],
  ];

  static const List<List<Color>> thumbGradientsLight = [
    [AppTheme.teal500, AppTheme.teal600],
    [AppTheme.coralLight500, AppTheme.coralLight600],
    [AppTheme.teal400, AppTheme.teal500],
    [AppTheme.slateCard, Color(0xFF5B6874)],
    [AppTheme.teal600, AppTheme.teal700],
    [AppTheme.coralLight300, AppTheme.coralLight500],
  ];

  // ── Theme-aware resolvers ─────────────────────────────────────────────────
  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// اللون المميّز حسب الوضع (برتقالي / كورال).
  static Color coralOf(BuildContext c) => isDark(c) ? coral : coralOnLight;

  /// اللون الأساسي حسب الوضع (أزرق / تركوازي).
  static Color plumOf(BuildContext c) => isDark(c) ? plum : plumOnLight;

  /// لون الهيدر/الخلفية العميقة حسب الوضع.
  static Color mochaOf(BuildContext c) => isDark(c) ? mocha : AppTheme.teal50;

  static LinearGradient header(BuildContext c) =>
      isDark(c) ? headerGradient : headerGradientLight;

  static LinearGradient btn(BuildContext c) =>
      isDark(c) ? btnGradient : btnGradientLight;

  static LinearGradient progress(BuildContext c) =>
      isDark(c) ? progressGradient : progressGradientLight;

  static List<List<Color>> thumbs(BuildContext c) =>
      isDark(c) ? thumbGradients : thumbGradientsLight;

  static Color scaffold(BuildContext c) =>
      Theme.of(c).scaffoldBackgroundColor;

  static Color surface(BuildContext c) => Theme.of(c).colorScheme.surface;

  static Color surfaceAlt(BuildContext c) =>
      Theme.of(c).colorScheme.surfaceContainerHighest;

  static Color textPrimary(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface;

  static Color textSecondary(BuildContext c) =>
      Theme.of(c).colorScheme.onSurface.withValues(alpha: 0.6);

  static Color border(BuildContext c) =>
      Theme.of(c).colorScheme.outlineVariant;

  /// لون النص فوق الهيدر (أبيض في الليلي، غامق في الفاتح).
  // Fix: في الوضع الفاتح كانت نصوص الهيدر بلون textDark/textMuted فوق سطح
  // فاتح جداً فبدت باهتة. الآن تستخدم ألوان onBarLight الأعلى تبايناً.
  static Color onHeader(BuildContext c) =>
      isDark(c) ? Colors.white : AppTheme.onBarLight;

  static Color onHeaderMuted(BuildContext c) => isDark(c)
      ? Colors.white.withValues(alpha: 0.65)
      : AppTheme.onBarLightMuted;
}
