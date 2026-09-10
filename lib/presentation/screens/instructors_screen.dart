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
//  Instructors Screen — معلمو المنصة
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
    final r = all
        .where((i) => matchesAllTokens(tokens, [i.name, i.bio]))
        .toList();
    r.sort((a, b) => relevanceScore(tokens: tokens, title: b.name, extra: [b.bio])
        .compareTo(relevanceScore(tokens: tokens, title: a.name, extra: [a.bio])));
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
                    sliver: SliverList.builder(
                      itemCount: 6,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Shimmer.fromColors(
                          baseColor: surf,
                          highlightColor:
                              Colors.white.withValues(alpha: 0.5),
                          child: Container(
                            height: 88,
                            decoration: BoxDecoration(
                              color: surf,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLg),
                            ),
                          ),
                        ),
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
                      sliver: SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _InstructorCard(
                            instructor: filtered[i],
                            surf: surf,
                            ink: ink,
                            mut: mut,
                            line: line,
                            onTap: () =>
                                context.push('/instructor/${filtered[i].id}'),
                          ),
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

class _InstructorCard extends StatelessWidget {
  final Instructor instructor;
  final Color surf, ink, mut, line;
  final VoidCallback onTap;
  const _InstructorCard({
    required this.instructor,
    required this.surf,
    required this.ink,
    required this.mut,
    required this.line,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final i = instructor;
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(url: i.avatarUrl, name: i.name, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                    if (i.bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(i.bio,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: mut, fontSize: 12)),
                    ],
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.collections_bookmark_outlined,
                          size: 14, color: mut),
                      const SizedBox(width: 4),
                      Text('${i.bundleCount} باقة',
                          style: TextStyle(color: mut, fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.play_lesson_outlined, size: 14, color: mut),
                      const SizedBox(width: 4),
                      Text('${i.courseCount} درس',
                          style: TextStyle(color: mut, fontSize: 12)),
                    ]),
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

class _Avatar extends StatelessWidget {
  final String url;
  final String name;
  final double size;
  const _Avatar({required this.url, required this.name, this.size = 60});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: AppTheme.mocha100,
      child: Text(
        name.isNotEmpty ? name.characters.first : '؟',
        style: TextStyle(
            color: AppTheme.mocha600,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.38),
      ),
    );

    return ClipOval(
      child: url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            ),
    );
  }
}
