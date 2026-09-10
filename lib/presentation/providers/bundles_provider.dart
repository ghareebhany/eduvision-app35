import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/bundle.dart';
import '../../data/models/bundle_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class BundlesState {
  final List<Bundle> bundles;
  final bool         isLoading;
  final String?      error;

  /// وقت آخر جلب ناجح من الخادم. تُستخدم لتحديد إن كانت الحالة قديمة (stale).
  final DateTime?    lastFetchedAt;

  /// true عندما تحتوي الحالة على تحديث تفاؤلي (markEnrolled) لم يُثبِته الخادم بعد.
  final bool         hasOptimisticEnrollment;

  const BundlesState({
    this.bundles                 = const [],
    this.isLoading               = false,
    this.error,
    this.lastFetchedAt,
    this.hasOptimisticEnrollment = false,
  });

  BundlesState copyWith({
    List<Bundle>? bundles,
    bool?         isLoading,
    String?       error,
    DateTime?     lastFetchedAt,
    bool?         hasOptimisticEnrollment,
  }) => BundlesState(
    bundles:                 bundles                 ?? this.bundles,
    isLoading:               isLoading               ?? this.isLoading,
    error:                   error,
    lastFetchedAt:           lastFetchedAt           ?? this.lastFetchedAt,
    hasOptimisticEnrollment: hasOptimisticEnrollment ?? this.hasOptimisticEnrollment,
  );

  /// حالة التسجيل بيانات متغيّرة على الخادم (قد تُلغى من لوحة التحكم في أي وقت)،
  /// لذلك نعتبرها قديمة بعد فترة قصيرة ونعيد الجلب.
  bool isStale({Duration maxAge = const Duration(seconds: 60)}) {
    if (lastFetchedAt == null) return true;
    return DateTime.now().difference(lastFetchedAt!) > maxAge;
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class BundlesNotifier extends StateNotifier<BundlesState> {
  BundlesNotifier() : super(const BundlesState());

  /// آخر قائمة مؤكَّدة من الخادم — تُستخدم للرجوع عند فشل تثبيت التحديث التفاؤلي.
  List<Bundle>? _serverSnapshot;

  /// يجلب الحزم من الخادم.
  ///
  /// [refresh] = true يتجاوز حارس التزامن ويطلب تجاوز أي كاش وسيط.
  /// يُرجع true عند نجاح الجلب، و false عند الفشل، حتى يتمكن المُنادي
  /// من التراجع عن أي تحديث تفاؤلي.
  Future<bool> fetch({bool refresh = false}) async {
    // BUG FIX: كان refresh مُعطّلاً تماماً، وكان الحارس يُسقط طلبات التحديث صامتاً.
    if (state.isLoading && !refresh) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await DioClient.instance.dio.get(
        ApiConstants.bundlesEndpoint,
        options: Options(
          extra: {'refresh': refresh},
          headers: refresh
              ? {'Cache-Control': 'no-cache', 'Pragma': 'no-cache'}
              : null,
        ),
      );
      final data = response.data as Map<String, dynamic>;
      final raw  = (data['data']?['bundles'] ?? data['bundles']) as List<dynamic>? ?? [];
      final list = raw
          .map((b) => BundleModel.fromJson(b as Map<String, dynamic>))
          .toList();

      // الخادم هو المصدر الوحيد للحقيقة في حالة التسجيل.
      _serverSnapshot = List<Bundle>.from(list);
      state = BundlesState(
        bundles:                 list,
        isLoading:               false,
        lastFetchedAt:           DateTime.now(),
        hasOptimisticEnrollment: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'تعذّر تحميل الحزم، تحقق من اتصالك',
      );
      return false;
    }
  }

  /// تحديث تفاؤلي مؤقت بعد استخدام كود بنجاح.
  /// يجب أن يتبعه دائماً fetch(refresh: true)، وإن فشل يُنادى revertOptimistic().
  void markEnrolled(int bundleId, List<int> enrolledCourseIds) {
    _serverSnapshot ??= List<Bundle>.from(state.bundles);

    final updated = state.bundles.map((b) {
      if (b.id != bundleId) return b;
      final updatedCourses = b.courses.map((c) {
        if (enrolledCourseIds.contains(c.id)) {
          return BundleCourseModel(
            id: c.id, title: c.title,
            thumbnail: c.thumbnail, isEnrolled: true,
            isFree: c.isFree, // كان يُفقَد ويعود false دائماً
          );
        }
        return c;
      }).toList();
      return BundleModel(
        id: b.id, title: b.title, description: b.description,
        thumbnail: b.thumbnail, courseCount: b.courseCount,
        courses: updatedCourses, isEnrolled: true,
        permalink: b.permalink,
      );
    }).toList();

    state = state.copyWith(
      bundles: updated,
      hasOptimisticEnrollment: true,
    );
  }

  /// يتراجع عن التحديث التفاؤلي عند فشل تثبيته من الخادم،
  /// حتى لا تبقى شارة «مسجّل» ظاهرة بلا سند من الخادم.
  void revertOptimistic() {
    if (!state.hasOptimisticEnrollment) return;
    final snapshot = _serverSnapshot;
    if (snapshot == null) return;
    state = state.copyWith(
      bundles: List<Bundle>.from(snapshot),
      hasOptimisticEnrollment: false,
    );
  }

  /// يُعلِّم الحالة كقديمة لإجبار إعادة الجلب عند ظهور الشاشة مرة أخرى.
  void markStale() {
    state = state.copyWith(lastFetchedAt: DateTime.fromMillisecondsSinceEpoch(0));
  }

  /// إعادة الجلب فقط إذا كانت الحالة قديمة أو تحتوي تحديثاً تفاؤلياً غير مؤكد.
  Future<void> refreshIfStale({
    Duration maxAge = const Duration(seconds: 60),
  }) async {
    if (state.isLoading) return;
    if (state.isStale(maxAge: maxAge) || state.hasOptimisticEnrollment) {
      await fetch(refresh: true);
    }
  }

  /// تُنادى عند تسجيل الخروج حتى لا تُورَّث حالة تسجيل مستخدم لآخر.
  void reset() {
    _serverSnapshot = null;
    state = const BundlesState();
  }
}

final bundlesProvider =
    StateNotifierProvider<BundlesNotifier, BundlesState>(
  (_) => BundlesNotifier(),
);
