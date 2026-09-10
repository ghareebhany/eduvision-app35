import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/search_utils.dart';
import '../../domain/entities/instructor.dart';
import '../providers/instructors_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  Instructors Screen — معلمو المنصة على شكل بطاقات (Grid)
// ═══════════════════════════════════════════════════════════════════════════
class InstructorsScreen extends ConsumerStatefulWidget {
  const InstructorsScreen({super.key});

  @override
  ConsumerState<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends ConsumerState<InstructorsScreen> {
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Instructor> _apply(List<Instructor> all) {
    final tokens = searchTokens(_q);
    if (tokens.isEmpty) return all;
    final r =
        all.where((i) => matchesAllTokens(tokens, [i.name, i.bio])).toList();
    r.sort((a, b) =>
        relevanceScore(tokens: tokens, title: b.name, extra: [b.bio]).compareTo(
            relevanceScore(tokens: tokens, title: a.name, extra: [a.bio])));
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final async  = ref.watch(instructorsListProvider);
    final isDark = AppPalette.isDark(context);
    final bg     = AppPalette.scaffold(context);
    final surf   = AppPalette.surface(context);
    final ink    = AppPalette.textPrimary(context);
    final mut    = AppPalette.textSecondary(context);
    final line   = AppPalette.border(context);

    const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.74,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bg,
        body: RefreshIndicator(
          color: AppTheme.coral500,
          backgroundColor: surf,
          onRefresh: () async => ref.invalidate(instructorsListProvider),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                snap: true,
                backgroundColor: bg,
                systemOverlayStyle: isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                expandedHeight: 0,
                title: Text('المعلمون',
                    style: TextStyle(
                        color: ink, fontWeight: FontWeight.w800, fontSize: 18)),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن معلم...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _q.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _q = '');
                                },
                              ),
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
              ...async.when(
                loading: () => [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: gridDelegate,
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => Shimmer.fromColors(
                          baseColor: surf,
                          highlightColor: Colors.white.withValues(alpha: 0.5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: surf,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        childCount: 6,
                      ),
                    ),
                  ),
                ],
                error: (e, _) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded, size: 48, color: mut),
                          const SizedBox(height: 12),
                          Text(e.toString().replaceAll('Exception: ', ''),
                              style: TextStyle(color: mut)),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () =>
                                ref.invalidate(instructorsListProvider),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                data: (list) {
                  final filtered = _apply(list);
                  if (filtered.isEmpty) {
                    return [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            _q.isNotEmpty
                                ? 'لا نتائج لـ "$_q"'
                                : 'لا يوجد معلمون حالياً',
                            style: TextStyle(color: mut),
                          ),
                        ),
                      ),
                    ];
                  }
                  return [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      sliver: SliverGrid(
                        gridDelegate: gridDelegate,
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _InstructorCard(
                            instructor: filtered[i],
                            surf: surf,
                            ink: ink,
                            mut: mut,
                            line: line,
                            isDark: isDark,
                            onTap: () =>
                                context.push('/instructor/${filtered[i].id}'),
                          ),
                          childCount: filtered.length,
                        ),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── بطاقة معلم ────────────────────────────────────────────────────
class _InstructorCard extends StatefulWidget {
  final Instructor instructor;
  final Color surf, ink, mut, line;
  final bool isDark;
  final VoidCallback onTap;
  const _InstructorCard({
    required this.instructor,
    required this.surf,
    required this.ink,
    required this.mut,
    required this.line,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_InstructorCard> createState() => _InstructorCardState();
}

class _InstructorCardState extends State<_InstructorCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final i = widget.instructor;
    final pad = widget.isDark ? AppTheme.mocha800 : AppTheme.mocha50;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: widget.surf,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: widget.isDark ? 0.35 : 0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // صورة المعلم كاملة دون قصّ
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: pad,
                  child: i.avatarUrl.isEmpty
                      ? _InitialFallback(name: i.name)
                      : CachedNetworkImage(
                          imageUrl: i.avatarUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                              _InitialFallback(name: i.name),
                          errorWidget: (_, __, ___) =>
                              _InitialFallback(name: i.name),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: widget.ink,
                              height: 1.3)),
                      const Spacer(),
                      Row(children: [
                        Icon(Icons.collections_bookmark_outlined,
                            size: 12.5, color: AppTheme.coral500),
                        const SizedBox(width: 3),
                        Text('${i.bundleCount}',
                            style: TextStyle(
                                color: widget.mut,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Icon(Icons.play_lesson_outlined,
                            size: 12.5, color: AppTheme.coral500),
                        const SizedBox(width: 3),
                        Text('${i.courseCount}',
                            style: TextStyle(
                                color: widget.mut,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Icon(Icons.chevron_left_rounded,
                            size: 18, color: widget.mut),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  final String name;
  const _InitialFallback({required this.name});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name.characters.first : '؟',
          style: const TextStyle(
              color: AppTheme.mocha600,
              fontWeight: FontWeight.w800,
              fontSize: 40),
        ),
      );
}
