import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: EduVisionApp()));
}

class EduVisionApp extends ConsumerWidget {
  const EduVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ايديو فيجن',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        // Fix: كان يُضبط statusBarIconBrightness مرة واحدة فقط عند
        // الإقلاع (Brightness.light دائماً، أي أيقونات بيضاء) ولا يتغيّر
        // بعدها، لذلك كانت شريحة الحالة تبدو "غامقة" في الوضع الفاتح على
        // معظم الشاشات (26 من 28 شاشة لا تضبط الـ overlay بنفسها).
        // الآن يُحسَب حسب السطوع الفعلي للثيم الحالي على مستوى التطبيق
        // كله، وتبقى كل شاشة قادرة على تخصيصه محلياً فوقه عند الحاجة.
        final brightness = themeMode == ThemeMode.system
            ? MediaQuery.platformBrightnessOf(context)
            : (themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
        final isDark = brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor:
                isDark ? AppTheme.mocha850 : AppTheme.barLight,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
      routerConfig: router,
    );
  }
}
