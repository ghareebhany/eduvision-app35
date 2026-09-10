import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_palette.dart';
import '../../core/utils/search_utils.dart';
import '../../domain/entities/course.dart';
import '../providers/auth_provider.dart';
import '../providers/courses_provider.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Lessons Screen — تعرض الدروس (الكورسات الفردية) وليس الحزم/الباقات
// ══════════════════════════════════════════════════════════════════════════════
class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});
  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _q = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchWhenReady());
    _scrollCtrl.addListener(_onScroll);
  }

  Future<void> _fetchWhenReady() async {
    for (var i = 0; i < 50; i++) {
      if (ref.read(authProvider) is! AuthInitial) break;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;
    ref.read(coursesProvider.notifier).fetchCourses();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >
        _scrollCtrl.position.maxScrollExtent - 300) {
      ref.read(coursesProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<Course> _apply(List<Course> all) {
    // بحث ذكي: عنوان الدرس + اسم المعلم + الوصف، مع تطبيع الحروف العربية
    // ودعم البحث بعدة كلمات غير متتالية.
    final tokens = searchTokens(_q);
    if (tokens.isEmpty) return all;
    final r = all
        .where((c) => matchesAllTokens(
            tokens, [c.title, c.instructorName, c.description]))
        .toList();
    r.sort((a, b) => _score(tokens, b).compareTo(_score(tokens, a)));
    return r;
  }

  int _score(List<String> tokens, Course c) => relevanceScore(
        tokens: tokens,
        title: c.title,
        instructor: c.instructorName,
        extra: [c.description],
      );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesProvider);
    final filtered = _apply(state.courses);

    final isDark = AppPalette.isDark(context);
    final bg = AppPalette.scaffold(context);
    final surf = AppPalette.surface(context);
    final ink = AppPalette.textPrimary(context);
    final mut = AppPalette.textSecondary(context);
    final line = AppPalette.border(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: RefreshIndicator(
          color: AppTheme.coral500,
          backgroundColor: surf,
          onRefresh: () =>
              ref.read(coursesProvider.notifier).fetchCourses(refresh: true),
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                backgroundColor: bg,
                systemOverlayStyle:
                    isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
                expandedHeight: 0,
                title: Text('الدروس',
                    style: TextStyle(
                        color: ink, fontWeight: FontWeight.w800, fontSize: 18)),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        hintText: 'ابحث باسم الدرس أو المعلم...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: surf,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: line),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (state.isLoading && state.courses.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.builder(
                    itemCount: 6,
                    itemBuilder: (_, __) => _ShimmerCard(surf: surf),
                  ),
                )
              else if (state.error != null && state.courses.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 48, color: mut),
                        const SizedBox(height: 12),
                        Text(state.error!, style: TextStyle(color: mut)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () =>
                              ref.read(coursesProvider.notifier).fetchCourses(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      _q.isNotEmpty ? 'لا نتائج لـ "$_q"' : 'لا توجد دروس متاحة حالياً',
                      style: TextStyle(color: mut),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i >= filtered.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final c = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LessonCard(
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
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Course course;
  final Color surf, ink, mut, line;
  final VoidCallback onTap;
  const _LessonCard({
    required this.course,
    required this.surf,
    required this.ink,
    required this.mut,
    required this.line,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              // الصورة كاملة دون قصّ (contain) فوق خلفية محايدة
              // حواف منحنية خفيفة، وارتفاع يتبع نسبة الصورة (fitWidth):
              // لا يحدث قصّ للصورة ولا تبقى فراغات حولها.
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: course.thumbnail,
                  width: 122,
                  fit: BoxFit.fitWidth,
                  placeholder: (_, __) => Container(
                    width: 122,
                    height: 70,
                    color: AppTheme.mocha100,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 122,
                    height: 70,
                    color: AppTheme.mocha100,
                    child: const Icon(Icons.play_lesson_rounded,
                        color: AppTheme.mocha500),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ink, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(course.instructorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: mut, fontSize: 12.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.menu_book_outlined, size: 14, color: mut),
                        const SizedBox(width: 4),
                        Text('${course.totalLessons} درس',
                            style: TextStyle(color: mut, fontSize: 12)),
                        const SizedBox(width: 12),
                        if (course.isEnrolled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.coral100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('مسجّل',
                                style: TextStyle(
                                    color: AppTheme.coral600,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          )
                        else
                          Text(course.isFree ? 'مجاناً' : course.price,
                              style: const TextStyle(
                                  color: AppTheme.coral500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5)),
                      ],
                    ),
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

class _ShimmerCard extends StatelessWidget {
  final Color surf;
  const _ShimmerCard({required this.surf});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: surf,
        highlightColor: Colors.white.withValues(alpha: 0.5),
        child: Container(
          height: 112,
          decoration: BoxDecoration(
            color: surf,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
        ),
      ),
    );
  }
}
