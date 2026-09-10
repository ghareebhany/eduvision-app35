import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hub_remote_ds.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/hub.dart';
import '../../domain/entities/qna.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/review.dart';
import 'auth_provider.dart';

// إعادة تصدير كيانات الـ hub حتى تبقى الشاشات تستوردها من هنا كما هي.
export '../../domain/entities/hub.dart';

// ─────────────────────────────────────────────────────────────────────────
// قسم "كل ما يخصّك"
//
// إصلاح الأداء + البيانات القديمة:
//  • سابقًا: كل provider يجلب قائمة كورسات المستخدم ثم يُطلق طلبًا لكل كورس
//    (1 + N طلب HTTP) ويُجمّع النتائج في التطبيق → حِمل دفعي على الخادم.
//  • سابقًا: كانت providerات غير autoDispose → تُخزَّن النتائج طوال الجلسة،
//    فلا تظهر الإضافات الجديدة إلا بعد تسجيل خروج/دخول.
//
//  • الآن: طلب واحد فقط لكل نوع إلى منفذ تجميعي في الخادم (/app/v1/my/*)،
//    وكل الـ providerات autoDispose → تُعاد الجلبة عند كل دخول للشاشة،
//    إضافةً إلى إبطال الكاش بعد أي نشر/تسليم/تقييم من داخل التطبيق.
// ─────────────────────────────────────────────────────────────────────────

final myQuizAttemptsProvider =
    FutureProvider.autoDispose<List<HubEntry<QuizAttempt>>>((ref) async {
  if (ref.watch(authProvider) is! AuthAuthenticated) {
    throw Exception('يرجى تسجيل الدخول أولاً');
  }
  return HubRemoteDataSource.instance.getMyQuizAttempts();
});

final myQuestionsProvider =
    FutureProvider.autoDispose<List<HubEntry<QnaItem>>>((ref) async {
  if (ref.watch(authProvider) is! AuthAuthenticated) {
    throw Exception('يرجى تسجيل الدخول أولاً');
  }
  return HubRemoteDataSource.instance.getMyQuestions();
});

final myAssignmentsProvider =
    FutureProvider.autoDispose<List<HubEntry<Assignment>>>((ref) async {
  if (ref.watch(authProvider) is! AuthAuthenticated) {
    throw Exception('يرجى تسجيل الدخول أولاً');
  }
  return HubRemoteDataSource.instance.getMyAssignments();
});

final myReviewsProvider =
    FutureProvider.autoDispose<List<HubEntry<Review>>>((ref) async {
  if (ref.watch(authProvider) is! AuthAuthenticated) {
    throw Exception('يرجى تسجيل الدخول أولاً');
  }
  return HubRemoteDataSource.instance.getMyReviews();
});
