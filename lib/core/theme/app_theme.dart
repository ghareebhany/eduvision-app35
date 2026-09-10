import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════════════════
  // Brand Palette — مستخرجة من تصميم الشاشات المعتمد (Dark / Light)
  //
  //  الوضع الليلي (Deep Navy + Orange):
  //  #001130  خلفية عميقة (Splash / أعلى الصفحة)
  //  #001B41  خلفية التطبيق الأساسية
  //  #021C40  خلفية القائمة السفلية
  //  #026ECD  الأزرق الأساسي (بطاقات، أيقونات)
  //  #F87625  البرتقالي (التاب النشط، CTAs)
  //  #5248C9  بنفسجي (بطاقة بنك الأسئلة)
  //  #23AB96  تركوازي (بطاقة تقييماتي)
  //
  //  الوضع الفاتح (Mint / Teal + Coral):
  //  #F2FBFA  خلفية التطبيق
  //  #EEFAFA  خلفية القائمة السفلية
  //  #D7F6F5  خلفيات الشرائح (chips / stats)
  //  #BDEBE0  الحدود
  //  #198E98  التركوازي الأساسي
  //  #5ECBDB  تركوازي فاتح
  //  #FF625A  الكورال (التاب النشط، CTAs)
  // ══════════════════════════════════════════════════════════════════════════

  // ── Navy / Blue (أساسي في الوضع الليلي) ───────────────────────────────────
  // تخفيف الوضع الليلي: رُفعت درجات الكحلي خطوة واحدة لتقليل "ثقل" الشاشة
  // مع الحفاظ على نفس نسب التباين بين الطبقات (خلفية < سطح < كارت < حد).
  static const Color mocha900     = Color(0xFF052046); // أعمق — splash bg (كان 001130)
  // Fix: كانت 021C40 قريبة جداً من خلفية الشاشة (001B41) فالكروت والقوائم
  // كانت تندمج بالخلفية بلا أي فرق واضح — تم رفعها لإحداث تباين حقيقي
  static const Color mocha850     = Color(0xFF17406F); // بطاقات/أسطح مرفوعة (dark)
  static const Color mocha800     = Color(0xFF072A57); // scaffold (dark) — كان 001B41
  static const Color mocha700     = Color(0xFF24518F); // أسطح أعلى (chips/surfaceAlt) + هيدر السبلاش/تسجيل الدخول
  static const Color mocha600     = Color(0xFF3F6BAE); // حدود واضحة (outline) — كانت شبه غير مرئية
  static const Color mocha500     = Color(0xFF026ECD); // royal blue ✦ (primary)
  static const Color mocha400     = Color(0xFF4A8FE0);
  static const Color mocha300     = Color(0xFF355E96); // فواصل/حدود خفيفة (outlineVariant) — تباين أقوى
  static const Color mocha200     = Color(0xFFA9C8F0); // borders فاتحة
  static const Color mocha100     = Color(0xFFE3EEFB); // light containers
  static const Color mocha50      = Color(0xFFF3F8FE);
  static const Color softPeach    = Color(0xFFFFB37A);

  // ── Orange / Coral ────────────────────────────────────────────────────────
  static const Color coral600     = Color(0xFFDC642B); // برتقالي غامق (dark)
  static const Color coral500     = Color(0xFFF87625); // برتقالي ✦ (dark accent)
  static const Color coral400     = Color(0xFFFF9A5C);
  static const Color coral200     = Color(0xFFFFC7AE);
  static const Color coral100     = Color(0xFFFFE8DC);
  static const Color coral50      = Color(0xFFFFF5F0);

  // كورال الوضع الفاتح (التاب النشط والأزرار في التصميم الفاتح)
  static const Color coralLight600 = Color(0xFFE84F47);
  static const Color coralLight500 = Color(0xFFFF625A); // ✦ light accent
  static const Color coralLight300 = Color(0xFFFFBEB7);
  static const Color coralLight100 = Color(0xFFFFE6E4);

  static const Color peach500     = Color(0xFFFFB37A);
  static const Color peach400     = Color(0xFFFFC79A);
  static const Color peach200     = Color(0xFFFFE0C2);
  static const Color peach100     = Color(0xFFFFF2E4);

  // ── Teal / Mint (أساسي في الوضع الفاتح) ───────────────────────────────────
  static const Color teal700      = Color(0xFF0E6C74);
  static const Color teal600      = Color(0xFF157C86);
  static const Color teal500      = Color(0xFF198E98); // teal-primary ✦
  static const Color teal400      = Color(0xFF5ECBDB); // تركوازي فاتح
  static const Color teal200      = Color(0xFFBDEBE0); // borders
  static const Color teal100      = Color(0xFFD7F6F5); // chips / stats
  static const Color teal80       = Color(0xFFEEFAFA); // أسطح فاتحة جداً
  // Fix: الشريطان العلوي/السفلي في الوضع الفاتح كانا بلون teal80 شديد الفتوح
  // فاندمجا مع الخلفية وضاع وضوح النصوص والأيقونات.
  // barLight أغمق درجةً مع بقاء الطابع النعناعي.
  static const Color barLight     = Color(0xFFC7E8E4); // top bar + bottom nav (light)
  static const Color onBarLight   = Color(0xFF0B3538); // نصوص فوق barLight
  static const Color onBarLightMuted = Color(0xFF3E6468); // أيقونات غير نشطة
  static const Color teal50       = Color(0xFFF2FBFA); // scaffold (light)
  static const Color tealDark     = Color(0xFF23AB96); // بطاقة تقييماتي (dark)

  // ── Accents إضافية للبطاقات ───────────────────────────────────────────────
  static const Color violet500    = Color(0xFF5248C9); // بنك الأسئلة (dark)
  static const Color violet600    = Color(0xFF3E36A8);
  static const Color slateCard    = Color(0xFF77828E); // بنك الأسئلة (light)

  // ── Neutral — Slate ───────────────────────────────────────────────────────
  static const Color sage500      = Color(0xFF8A93A6);
  static const Color sage400      = Color(0xFFA6AEBD);
  static const Color sage300      = Color(0xFFC7DFE0);
  static const Color sage200      = Color(0xFFBDEBE0);
  static const Color sage100      = Color(0xFFEAF7F6);
  static const Color sage50       = Color(0xFFF2FBFA);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textDark     = Color(0xFF0E2B2E);
  static const Color textMid      = Color(0xFF35595E);
  static const Color textMuted    = Color(0xFF5C7A80);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF23AB96);
  static const Color successLight = Color(0xFFD7F6F5);
  static const Color warning      = Color(0xFFDC642B);
  static const Color warningLight = Color(0xFFFFE8DC);
  static const Color error        = Color(0xFFE84F47);
  static const Color errorLight   = Color(0xFFFFE6E4);

  // ── Backward-compat aliases (لا تكسر الشاشات القديمة) ─────────────────────
  static const Color navy900      = mocha900;
  static const Color navy800      = mocha800;
  static const Color navy700      = mocha700;
  static const Color navy600      = mocha500;
  static const Color navy500      = mocha600;
  static const Color navy400      = mocha400;
  static const Color navy200      = mocha200;
  static const Color navy100      = mocha100;
  static const Color navy50       = mocha50;
  static const Color sky500       = coral500;
  static const Color sky400       = coral400;
  static const Color sky300       = coral200;
  static const Color sky100       = coral100;
  static const Color sky50        = coral50;
  static const Color slate900     = textDark;
  static const Color slate700     = textMid;
  static const Color slate500     = textMuted;
  static const Color slate300     = sage500;
  static const Color slate200     = sage300;
  static const Color slate100     = sage100;
  static const Color slate50      = sage50;

  // ── Theme-aware helpers ───────────────────────────────────────────────────
  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  /// اللون المميّز (accent) حسب الوضع: برتقالي في الليلي، كورال في الفاتح.
  static Color accent(BuildContext c) =>
      isDark(c) ? coral500 : coralLight500;

  /// اللون الأساسي حسب الوضع: أزرق في الليلي، تركوازي في الفاتح.
  static Color brand(BuildContext c) => isDark(c) ? mocha500 : teal500;

  // ════════════════════════════════════════════════════════════════════════
  //  Design Tokens
  // ════════════════════════════════════════════════════════════════════════

  static const double space2  = 2;
  static const double space4  = 4;
  static const double space8  = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  static const double radiusSm   = 12;
  static const double radiusMd   = 16;
  static const double radiusLg   = 20;
  static const double radiusXl   = 28;
  static const double radiusPill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(radiusXl));

  static List<BoxShadow> get shadowSm => [
        BoxShadow(color: mocha900.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
      ];
  static List<BoxShadow> get shadowMd => [
        BoxShadow(color: mocha900.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
        BoxShadow(color: mocha900.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
      ];
  static List<BoxShadow> get shadowLg => [
        BoxShadow(color: mocha900.withValues(alpha: 0.10), blurRadius: 28, offset: const Offset(0, 12)),
        BoxShadow(color: mocha900.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4)),
      ];
  static List<BoxShadow> coloredShadow(Color c, {double alpha = 0.35}) => [
        BoxShadow(color: c.withValues(alpha: alpha), blurRadius: 20, offset: const Offset(0, 10)),
      ];

  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMed  = Duration(milliseconds: 280);
  static const Duration motionSlow = Duration(milliseconds: 450);
  static const Curve    easeOutExpo = Curves.easeOutCubic;

  // ── Premium TextTheme: Tajawal للعناوين + Cairo للنصوص ──
  static TextTheme get _cairoTextTheme {
    final base = GoogleFonts.cairoTextTheme();
    return base.copyWith(
      displayLarge:   GoogleFonts.tajawal(textStyle: base.displayLarge,   fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5),
      displayMedium:  GoogleFonts.tajawal(textStyle: base.displayMedium,  fontWeight: FontWeight.w800, height: 1.18, letterSpacing: -0.5),
      displaySmall:   GoogleFonts.tajawal(textStyle: base.displaySmall,   fontWeight: FontWeight.w700, height: 1.20),
      headlineLarge:  GoogleFonts.tajawal(textStyle: base.headlineLarge,  fontWeight: FontWeight.w700, height: 1.20),
      headlineMedium: GoogleFonts.tajawal(textStyle: base.headlineMedium, fontWeight: FontWeight.w700, height: 1.25),
      headlineSmall:  GoogleFonts.tajawal(textStyle: base.headlineSmall,  fontWeight: FontWeight.w700, height: 1.30),
      titleLarge:     GoogleFonts.tajawal(textStyle: base.titleLarge,     fontWeight: FontWeight.w700, height: 1.30),
      titleMedium:    GoogleFonts.cairo(textStyle: base.titleMedium,      fontWeight: FontWeight.w600, height: 1.40, letterSpacing: 0.1),
      titleSmall:     GoogleFonts.cairo(textStyle: base.titleSmall,       fontWeight: FontWeight.w600, height: 1.40),
      bodyLarge:      GoogleFonts.cairo(textStyle: base.bodyLarge,        height: 1.60, letterSpacing: 0.1),
      bodyMedium:     GoogleFonts.cairo(textStyle: base.bodyMedium,       height: 1.60, letterSpacing: 0.1),
      bodySmall:      GoogleFonts.cairo(textStyle: base.bodySmall,        height: 1.50),
      labelLarge:     GoogleFonts.cairo(textStyle: base.labelLarge,       fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium:    GoogleFonts.cairo(textStyle: base.labelMedium,      fontWeight: FontWeight.w600),
      labelSmall:     GoogleFonts.cairo(textStyle: base.labelSmall,       fontWeight: FontWeight.w600),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Light Theme — Mint/Teal + Coral
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData light() {
    const lightBg     = teal50;   // #F2FBFA
    const lightCard   = Colors.white;
    const lightBorder = teal200;  // #BDEBE0
    const lightText   = textDark;
    const lightMuted  = textMuted;

    final cs = ColorScheme(
      brightness:               Brightness.light,
      primary:                  teal500,
      onPrimary:                Colors.white,
      primaryContainer:         teal100,
      onPrimaryContainer:       teal700,
      secondary:                coralLight500,
      onSecondary:              Colors.white,
      secondaryContainer:       coralLight100,
      onSecondaryContainer:     coralLight600,
      tertiary:                 teal400,
      onTertiary:               Colors.white,
      tertiaryContainer:        teal100,
      onTertiaryContainer:      teal700,
      error:                    error,
      onError:                  Colors.white,
      errorContainer:           errorLight,
      onErrorContainer:         const Color(0xFF7F1D1D),
      surface:                  lightCard,
      onSurface:                lightText,
      surfaceContainerHighest:  teal100,
      outline:                  teal400,
      outlineVariant:           lightBorder,
      shadow:                   Colors.black,
      scrim:                    Colors.black,
      inverseSurface:           mocha800,
      onInverseSurface:         sage50,
      inversePrimary:           teal200,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: lightBg,
      textTheme: _cairoTextTheme.apply(
          bodyColor: lightText, displayColor: lightText),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        // الشريط العلوي في الوضع الفاتح يطابق شريط التنقل السفلي (#C7E8E4)
        backgroundColor: barLight,
        foregroundColor: onBarLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
            fontSize: 19, fontWeight: FontWeight.w800, color: onBarLight, letterSpacing: 0.2),
        iconTheme: IconThemeData(color: onBarLight),
        actionsIconTheme: IconThemeData(color: onBarLight),
        shadowColor: Colors.black12,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: lightCard,
        shadowColor: teal500.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      // Fix: أزرار الوضع الفاتح كانت كورالًا صارخًا؛ صارت تركوازيًا عميقًا
      // متماشيًا مع نعناعيات الثيم ومطابقًا لتدرّج buttonGradientLight.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnLight,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: btnLight.withValues(alpha: 0.40),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: btnLight,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: btnLight.withValues(alpha: 0.40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: teal500,
          side: const BorderSide(color: teal500, width: 1.5),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coralLight500,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: teal100,
        hintStyle: GoogleFonts.cairo(color: lightMuted, fontSize: 14),
        labelStyle: GoogleFonts.cairo(color: lightMuted, fontSize: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: lightBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: lightBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: teal500, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: barLight,
        selectedItemColor: coralLight600,
        unselectedItemColor: onBarLightMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: barLight,
        indicatorColor: coralLight600,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: onBarLightMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
                color: coralLight600, fontSize: 11, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.cairo(color: textMuted, fontSize: 11);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: teal100,
        selectedColor: teal200,
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: mocha800,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: teal500,
        linearTrackColor: teal200,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: teal600,
        unselectedLabelColor: lightMuted,
        indicatorColor: coralLight500,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
        dividerColor: lightBorder,
      ),
      iconTheme: const IconThemeData(color: teal600),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Dark Theme — Deep Navy + Orange
  // ══════════════════════════════════════════════════════════════════════════
  static ThemeData dark() {
    const darkBg       = mocha800; // #001B41
    const darkSurface  = mocha850; // #143968 — كروت/أسطح مرفوعة بوضوح عن الخلفية
    const darkCard     = mocha700; // #1D4884 — أعلى قليلاً من darkSurface
    const darkBorder   = mocha600; // #3F6BAE — حد واضح فعلياً
    const darkText     = Color(0xFFF2F6FC);
    const darkMuted    = Color(0xFF8FA8CC);

    final cs = ColorScheme(
      brightness:               Brightness.dark,
      primary:                  mocha500,
      onPrimary:                Colors.white,
      primaryContainer:         mocha600,
      onPrimaryContainer:       mocha200,
      secondary:                coral500,
      onSecondary:              Colors.white,
      secondaryContainer:       coral600,
      onSecondaryContainer:     coral100,
      tertiary:                 tealDark,
      onTertiary:               mocha900,
      tertiaryContainer:        darkCard,
      onTertiaryContainer:      darkText,
      error:                    const Color(0xFFFF7B72),
      onError:                  darkBg,
      errorContainer:           const Color(0xFF4A1515),
      onErrorContainer:         const Color(0xFFFCA5A5),
      surface:                  darkSurface,
      onSurface:                darkText,
      surfaceContainerHighest:  darkCard,
      outline:                  darkBorder,
      outlineVariant:           mocha300,
      shadow:                   Colors.black,
      scrim:                    Colors.black,
      inverseSurface:           teal50,
      onInverseSurface:         lightTextForInverse,
      inversePrimary:           teal500,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: darkBg,
      textTheme: _cairoTextTheme.apply(
          bodyColor: darkText, displayColor: darkText),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: mocha900,
        foregroundColor: darkText,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: darkText),
        titleTextStyle: TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold, color: darkText),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      // Fix: أزرار الوضع الغامق موحّدة الآن مع تدرّج buttonGradient (كورال محروق).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnDark,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: coral500.withValues(alpha: 0.45),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: btnDark,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          minimumSize: const Size(64, 52),
          elevation: 3,
          shadowColor: coral500.withValues(alpha: 0.45),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: coral500,
          side: const BorderSide(color: coral500, width: 1.5),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coral500,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 14),
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: GoogleFonts.cairo(color: darkMuted, fontSize: 14),
        labelStyle: GoogleFonts.cairo(color: darkMuted, fontSize: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: darkBorder),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: coral500, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: mocha850,
        selectedItemColor: coral500,
        unselectedItemColor: darkMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: mocha850,
        indicatorColor: coral500,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: darkMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.cairo(
                color: coral500, fontSize: 11, fontWeight: FontWeight.bold);
          }
          return GoogleFonts.cairo(color: darkMuted, fontSize: 11);
        }),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: mocha300,
        selectedColor: mocha600,
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: darkText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: darkBorder.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.cairo(color: darkText, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: coral500,
        linearTrackColor: mocha600,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: coral500,
        unselectedLabelColor: darkMuted,
        indicatorColor: coral500,
        labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
        dividerColor: darkBorder,
      ),
      iconTheme: const IconThemeData(color: darkText),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: mocha850,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static const Color lightTextForInverse = textDark;

  // ══════════════════════════════════════════════════════════════════════════
  // Gradient Helpers
  // ══════════════════════════════════════════════════════════════════════════

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mocha900, mocha800, mocha500],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient headerGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    // Fix: كان التدرّج فاتحاً جداً [teal50 → teal200] فبدا الهيدر مندمجاً
    // مع الخلفية والنصوص فوقه باهتة. صار أغمق درجةً ومطابقاً لـ barLight.
    colors: [barLight, Color(0xFFB4E0DC), Color(0xFF9FD6D4)],
    stops: [0.0, 0.55, 1.0],
  );

  static LinearGradient header(BuildContext c) =>
      isDark(c) ? headerGradient : headerGradientLight;

  // ── أزرار الإجراء الرئيسية ───────────────────────────────────────────────
  // Fix: كان التدرّج القديم [coral500 → mocha500] يخلط برتقالي وأزرق في زرٍّ
  // واحد فيبدو متضارباً. البديل تدرّج داخل عائلة لونية واحدة لكل ثيم:
  //  • الغامق: كهرماني ← كورال محروق (دافئ وأنيق على الكحلي)
  //  • الفاتح: تركوازي عميق (متماشٍ مع نعناعيات الثيم الفاتح)
  /// لون الزر الرئيسي المفرد (غير المتدرّج) في الوضع الغامق/الفاتح.
  static const Color btnDark = Color(0xFFEF5B2B);
  static const Color btnLight = Color(0xFF16948B);

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFFFFA24D), btnDark],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  static const LinearGradient buttonGradientLight = LinearGradient(
    colors: [Color(0xFF23C0AE), Color(0xFF0E6C74)],
    // مركز التدرّج يوافق btnLight لتطابق الأزرار المتدرّجة والمسطّحة.
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  /// تدرّج زر الإجراء الرئيسي حسب الثيم الحالي.
  static LinearGradient button(BuildContext c) =>
      isDark(c) ? buttonGradient : buttonGradientLight;

  /// لون هالة/ظِل الزر الرئيسي حسب الثيم (يُستخدم مع boxShadow).
  static Color buttonGlow(BuildContext c) =>
      isDark(c) ? const Color(0xFFEF5B2B) : const Color(0xFF16948B);

  /// خلفية شاشات الدخول/التسجيل — كحلي عميق يتدرّج إلى مائي مخملي.
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF06224A), Color(0xFF0B3A63), Color(0xFF115C6E)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [coral400, coral600],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient ctaGradientLight = LinearGradient(
    colors: [coralLight500, coralLight600],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static LinearGradient cta(BuildContext c) =>
      isDark(c) ? ctaGradient : ctaGradientLight;

  static const LinearGradient peachGlow = LinearGradient(
    colors: [peach500, coral400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardSheen(bool isDark) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [mocha700, mocha800]
            : [Colors.white, teal50],
      );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [coral500, mocha500],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  static const LinearGradient progressGradientLight = LinearGradient(
    colors: [coralLight500, teal500],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  static LinearGradient progress(BuildContext c) =>
      isDark(c) ? progressGradient : progressGradientLight;

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mocha900, mocha800, mocha700],
    stops: [0.0, 0.5, 1.0],
  );

  // بطاقات الأقسام (مطابقة لبطاقات الشاشة الرئيسية في التصميم)
  static const List<List<Color>> categoryGradients = [
    [mocha500, mocha600],          // default — أزرق
    [coral500, coral600],          // برتقالي
    [tealDark, teal600],           // تركوازي
    [violet500, violet600],        // بنفسجي
    [mocha700, mocha800],          // كحلي
    [teal400, teal500],            // تركوازي فاتح
  ];

  // ── بطاقات الإحصاءات: أربع درجات متمايزة لا تتكرّر داخل الثيم الواحد ──
  //  الترتيب المعتمد في التصميم: أزرق/تركوازي — برتقالي/كورال — أخضر — بنفسجي/رمادي
  static const List<List<Color>> statGradients = [
    [mocha500, Color(0xFF0A4F9E)],  // أزرق ملكي
    [coral500, coral600],           // برتقالي
    [tealDark, teal600],            // أخضر تركوازي
    [violet500, violet600],         // بنفسجي
  ];

  static const List<List<Color>> statGradientsLight = [
    [teal500, teal700],                    // تركوازي
    [coralLight500, coralLight600],        // كورال
    [Color(0xFF3E7BD6), Color(0xFF2B5FB0)],// أزرق
    [slateCard, Color(0xFF5B6874)],        // رمادي أردوازي
  ];

  /// تدرّج بطاقة الإحصاء رقم [i] حسب الثيم الحالي (يلتفّ تلقائياً).
  static List<Color> statGradient(BuildContext c, int i) {
    final list = isDark(c) ? statGradients : statGradientsLight;
    return list[i % list.length];
  }

  static const List<List<Color>> categoryGradientsLight = [
    [teal500, teal600],
    [coralLight500, coralLight600],
    [teal400, teal500],
    [slateCard, Color(0xFF5B6874)],
    [teal600, teal700],
    [Color(0xFFFFBEB7), coralLight500],
  ];
}
