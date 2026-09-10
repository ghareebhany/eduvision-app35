import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/instructor_model.dart';
import '../../domain/entities/instructor.dart';

// ── فك تغليف استجابة الإضافة: { success, data: {...} } ─────────────────────
Object? _unwrap(Object? body) {
  if (body is Map<String, dynamic>) {
    if (body['status'] == 'success' && body.containsKey('data')) return body['data'];
    if (body['success'] == true && body.containsKey('data')) return body['data'];
  }
  return body;
}

/// قائمة معلمي المنصة.
final instructorsListProvider =
    FutureProvider<List<Instructor>>((ref) async {
  try {
    final res = await DioClient.instance.dio.get(ApiConstants.instructorsEndpoint);
    final raw = _unwrap(res.data);

    List<dynamic> list;
    if (raw is Map<String, dynamic>) {
      list = raw['instructors'] as List<dynamic>? ?? const [];
    } else if (raw is List) {
      list = raw;
    } else {
      list = const [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(InstructorModel.fromJson)
        .where((i) => i.id > 0)
        .toList();
  } on DioException catch (e) {
    throw Exception(e.message ?? 'تعذّر تحميل قائمة المعلمين');
  }
});

/// محتوى معلم واحد: الباقات + الدروس.
final instructorContentProvider =
    FutureProvider.family<InstructorContent, int>((ref, id) async {
  try {
    final res = await DioClient.instance.dio
        .get(ApiConstants.instructorContentEndpoint(id));
    final raw = _unwrap(res.data);
    if (raw is! Map<String, dynamic>) {
      throw Exception('استجابة غير صالحة من الخادم');
    }
    return InstructorContentModel.fromJson(raw);
  } on DioException catch (e) {
    throw Exception(e.message ?? 'تعذّر تحميل بيانات المعلم');
  }
});
