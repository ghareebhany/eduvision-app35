import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// MainShell — القائمة السفلية بمطابقة التصميم المعتمد:
///  • الوضع الليلي: خلفية كحلية #021C40 والتاب النشط برتقالي #F87625
///  • الوضع الفاتح: خلفية نعناعية #EEFAFA والتاب النشط كورال #FF625A
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _items = <_NavItem>[
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
    _NavItem(Icons.collections_bookmark_outlined,
        Icons.collections_bookmark_rounded, 'الباقات'),
    _NavItem(Icons.play_lesson_outlined, Icons.play_lesson_rounded, 'الدروس'),
    _NavItem(Icons.people_outline_rounded, Icons.people_rounded, 'المعلمون'),
    _NavItem(Icons.school_outlined, Icons.school_rounded, 'دوراتي'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fix: شريط التنقل السفلي يطابق الآن الشريط العلوي بعد تغميقه (barLight)
    // مع ألوان نصوص/أيقونات أعلى تبايناً في الوضع الفاتح.
    final barBg     = isDark ? AppTheme.mocha850 : AppTheme.barLight;
    final activeClr = isDark ? AppTheme.coral500 : AppTheme.coralLight600;
    final idleClr   = isDark ? const Color(0xFF8FA8CC) : AppTheme.onBarLightMuted;
    final borderClr = isDark
        ? AppTheme.mocha600.withValues(alpha: 0.55)
        : const Color(0xFF9FD6D4);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: barBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: borderClr),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppTheme.mocha900 : AppTheme.teal500)
                      .withValues(alpha: isDark ? 0.45 : 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: _items[i],
                        selected: navigationShell.currentIndex == i,
                        activeColor: activeClr,
                        idleColor: idleClr,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          navigationShell.goBranch(
                            i,
                            initialLocation: i == navigationShell.currentIndex,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final Color activeColor;
  final Color idleColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.idleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: AnimatedContainer(
        duration: AppTheme.motionFast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          // التاب النشط: خلفية مملوءة بلون التمييز كما في التصميم
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 20,
              color: selected ? Colors.white : idleColor,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : idleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
