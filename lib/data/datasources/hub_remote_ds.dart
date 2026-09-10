import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/entities/hub.dart';
import '../../domain/entities/qna.dart';
import '../../domain/entities/quiz_attempt.dart';
import '../../domain/entities/review.dart';
import '../models/assignment_model.dart';
import '../models/qna_model.dart';
import '../models/quiz_attempt_model.dart';
import '../models/review_model.dart';
import 'dio_helpers.dart';

/// مصدر بيانات قسم "كل ما يخصّك".
///
/// يجلب كل عناصر المستخدم عبر جميع الكورسات بطلب واحد لكل نوع من
/// المنافذ التجميعية في الخادم (/app/v1/my/*)، بدل تجميعها في التطبيق
/// عبر طلب منفصل لكل كورس — مما يقلّل الحِمل على الخادم ويُسرّع الفتح.
class HubRemoteDataSource {
  HubRemoteDataSource._();
  static final HubRemoteDataSource instance = HubRemoteDataSource._();

  Dio get _dio => DioClient.instance.dio;

  Object? _unwrap(Object? body) {
    if (body is Map<String, dynamic>) {
      if (body['success'] == true && body.containsKey('data')) return body['data'];
      if (body['status'] == 'success' && body.containsKey('data')) return body['data'];
    }
    return body;
  }

  List<Map<String, dynamic>> _items(Object? raw) {
    if (raw == null) return const [];
    final list = raw is List ? raw : [raw];
    return list.whereType<Map<String, dynamic>>().toList();
  }

  CourseRef _course(Map<String, dynamic> json) {
    final c = json['course'];
    if (c is Map) {
      return CourseRef(
        (c['id'] as num?)?.toInt() ?? (json['course_id'] as num?)?.toInt() ?? 0,
        (c['title'] ?? '').toString(),
      );
    }
    return CourseRef((json['course_id'] as num?)?.toInt() ?? 0, '');
  }

  Future<List<HubEntry<QuizAttempt>>> getMyQuizAttempts() async {
    try {
      final res = await _dio.get(ApiConstants.myQuizAttemptsEndpoint);
      return _items(_unwrap(res.data))
          .map((e) => HubEntry<QuizAttempt>(_course(e), QuizAttemptModel.fromJson(e)))
          .toList();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<List<HubEntry<QnaItem>>> getMyQuestions() async {
    try {
      final res = await _dio.get(ApiConstants.myQuestionsEndpoint);
      return _items(_unwrap(res.data))
          .map((e) => HubEntry<QnaItem>(_course(e), QnaModel.fromJson(e)))
          .toList();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<List<HubEntry<Assignment>>> getMyAssignments() async {
    try {
      final res = await _dio.get(ApiConstants.myAssignmentsEndpoint);
      return _items(_unwrap(res.data))
          .map((e) => HubEntry<Assignment>(_course(e), AssignmentModel.fromJson(e)))
          .toList();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  Future<List<HubEntry<Review>>> getMyReviews() async {
    try {
      final res = await _dio.get(ApiConstants.myReviewsEndpoint);
      return _items(_unwrap(res.data))
          .map((e) => HubEntry<Review>(_course(e), ReviewModel.fromJson(e)))
          .toList();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
