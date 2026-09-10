import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/error_widget.dart';
import '../../domain/entities/bundle.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/instructor.dart';
import '../providers/instructors_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Instructor Screen — هيدر المعلم + كتلة الباقات + كتلة الدروس
// ═══════════════════════════════════════════════════════════════════════════
class InstructorScreen extends ConsumerWidget {
  final int instructorId;
  const InstructorScreen({super.key, required this.instructorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(instructorContentProvider(instructorId));
    final bg    = AppPalette.scaffold(context);
    final surf  = AppPalette.surface(context);
    final ink   = AppPalette.textPrimary(context);
    final mut   = AppPalette.textSecondary(context);
    final line  = AppPalette.border(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('ملف المعلم')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: e.toString().replaceAll('Exception: ', ''),
          onRetry: () =>
              ref.invalidate(instructorContentProvider(instructorId)),
        ),
        data: (content) {
          final i = content.instructor;
          return RefreshIndicator(
            color: AppTheme.coral500,
            backgroundColor: surf,
            onRefresh: () async =>
                ref.invalidate(instructorContentProvider(instructorId)),
            child: ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                // صورة المعلم في الأعلى بعرض الصفحة الكامل ودون قصّ
                _Header(
                  instructor: i,
                  ink: ink,
                  mut: mut,
                  isDark: AppPalette.isDark(context),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                // ── كتلة الباقات ─────────────────────────────────────
                _SectionTitle(
                  icon: Icons.collections_bookmark_rounded,
                  title: 'باقات المعلم',
                  count: content.bundles.length,
                  ink: ink,
                  mut: mut,
                ),
                const SizedBox(height: 10),
                if (content.bundles.isEmpty)
                  _EmptyBlock(text: 'لا توجد باقات لهذا المعلم', mut: mut, line: line)
                else
                  ...content.bundles.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BundleRow(
                          bundle: b,
                          surf: surf,
                          ink: ink,
                          mut: mut,
                          line: line,
                          onTap: () => context.push('/bundle/${b.id}'),
                        ),
                      )),

                const SizedBox(height: 24),

                // ── كتلة الدروس ──────────────────────────────────────
                _SectionTitle(
                  icon: Icons.play_lesson_rounded,
                  title: 'دروس المعلم',
                  count: content.courses.length,
                  ink: ink,
                  mut: mut,
                ),
                const SizedBox(height: 10),
                if (content.courses.isEmpty)
                  _EmptyBlock(text: 'لا توجد دروس لهذا المعلم', mut: mut, line: line)
                else
                  ...content.courses.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CourseRow(
                          course: c,
                          surf: surf,
                          ink: ink,
                          mut: mut,
                          line: line,
                          onTap: () => (c.isEnrolled || c.isFree)
                              ? context.push('/course/${c.id}')
                              : context.push('/redeem-code', extra: {
                                  'bundle_id': 0,
                                  'bundle_title': '',
                                  'content_type': 'course',
                                  'course_id': c.id,
                                  'course_title': c.title,
                                }),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final Instructor instructor;
  final Color ink, mut;
  final bool isDark;
  const _Header({
    required this.instructor,
    required this.ink,
    required this.mut,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final i = instructor;
    final pad = isDark ? AppTheme.mocha800 : AppTheme.mocha50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الصورة بعرض الشاشة بالكامل مع إظهارها كاملة (contain)
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            width: double.infinity,
            color: pad,
            child: i.avatarUrl.isEmpty
                ? _InitialBig(name: i.name)
                : CachedNetworkImage(
                    imageUrl: i.avatarUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (_, __) => _InitialBig(name: i.name),
                    errorWidget: (_, __, ___) => _InitialBig(name: i.name),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(i.name,
                  style: TextStyle(
                      color: ink, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(children: [
                _Stat(
                    icon: Icons.collections_bookmark_outlined,
                    label: '${i.bundleCount} باقة',
                    mut: mut),
                const SizedBox(width: 14),
                _Stat(
                    icon: Icons.play_lesson_outlined,
                    label: '${i.courseCount} درس',
                    mut: mut),
              ]),
              if (i.bio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(i.bio,
                    style: TextStyle(color: mut, fontSize: 13.5, height: 1.7)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InitialBig extends StatelessWidget {
  final String name;
  const _InitialBig({required this.name});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name.characters.first : '؟',
          style: const TextStyle(
              color: AppTheme.mocha600,
              fontWeight: FontWeight.w800,
              fontSize: 64),
        ),
      );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color mut;
  const _Stat({required this.icon, required this.label, required this.mut});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: mut),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: mut, fontSize: 12.5)),
        ],
      );
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color ink, mut;
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.count,
    required this.ink,
    required this.mut,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.coral500),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: ink, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text('($count)', style: TextStyle(color: mut, fontSize: 13)),
        ],
      );
}

class _EmptyBlock extends StatelessWidget {
  final String text;
  final Color mut, line;
  const _EmptyBlock({required this.text, required this.mut, required this.line});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: line),
        ),
        child: Text(text, style: TextStyle(color: mut, fontSize: 13)),
      );
}

// ── صف باقة — الصورة كاملة (contain) دون قصّ ────────────────────────
class _BundleRow extends StatelessWidget {
  final Bundle bundle;
  final Color surf, ink, mut, line;
  final VoidCallback onTap;
  const _BundleRow({
    required this.bundle,
    required this.surf,
    required this.ink,
    required this.mut,
    required this.line,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = bundle;
    return Material(
      color: surf,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: line),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _Thumb(url: b.thumbnail, icon: Icons.collections_bookmark_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5)),
                    const SizedBox(height: 6),
                    Text('${b.courseCount} درس داخل الباقة',
                        style: TextStyle(color: mut, fontSize: 12)),
                    if (b.isEnrolled) ...[
                      const SizedBox(height: 6),
                      const _EnrolledBadge(),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: mut),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course;
  final Color surf, ink, mut, line;
  final VoidCallback onTap;
  const _CourseRow({
    required this.course,
    required this.surf,
    required this.ink,
    required this.mut,
    required this.line,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = course;
    return Material(
      color: surf,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: line),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _Thumb(url: c.thumbnail, icon: Icons.play_lesson_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5)),
                    const SizedBox(height: 6),
                    Text('${c.totalLessons} درس',
                        style: TextStyle(color: mut, fontSize: 12)),
                    const SizedBox(height: 6),
                    if (c.isEnrolled)
                      const _EnrolledBadge()
                    else
                      Text(c.isFree ? 'مجاناً' : c.price,
                          style: const TextStyle(
                              color: AppTheme.coral500,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5)),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: mut),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrolledBadge extends StatelessWidget {
  const _EnrolledBadge();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.coral100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text('مسجّل',
            style: TextStyle(
                color: AppTheme.coral600,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}

/// مصغّرة تعرض الصورة **كاملة** (BoxFit.contain) فوق خلفية محايدة.
class _Thumb extends StatelessWidget {
  final String url;
  final IconData icon;
  const _Thumb({required this.url, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = AppPalette.isDark(context);
    final pad = isDark ? AppTheme.mocha800 : AppTheme.mocha50;
    final fallback = Container(
      width: 104,
      height: 78,
      color: pad,
      child: Icon(icon, color: AppTheme.mocha500),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 104,
        height: 78,
        color: pad,
        child: url.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}
