import '../../domain/entities/instructor.dart';
import 'bundle_model.dart';
import 'course_model.dart';

class InstructorModel extends Instructor {
  const InstructorModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.bio,
    super.courseCount,
    super.bundleCount,
    super.rating,
  });

  factory InstructorModel.fromJson(Map<String, dynamic> json) {
    return InstructorModel(
      id:          _parseInt(json['id']),
      name:        _strip(json['display_name'] as String? ?? ''),
      avatarUrl:   json['avatar_url'] as String? ?? '',
      bio:         _strip(json['bio'] as String? ?? ''),
      courseCount: _parseInt(json['course_count']),
      bundleCount: _parseInt(json['bundle_count']),
      rating:      _parseDouble(json['rating']),
    );
  }

  static String _strip(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').trim();

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class InstructorContentModel extends InstructorContent {
  const InstructorContentModel({
    required super.instructor,
    required super.bundles,
    required super.courses,
  });

  factory InstructorContentModel.fromJson(Map<String, dynamic> json) {
    final rawInstructor = json['instructor'] as Map<String, dynamic>? ?? const {};
    final rawBundles    = json['bundles'] as List<dynamic>? ?? const [];
    final rawCourses    = json['courses'] as List<dynamic>? ?? const [];

    return InstructorContentModel(
      instructor: InstructorModel.fromJson(rawInstructor),
      bundles: rawBundles
          .whereType<Map<String, dynamic>>()
          .map(BundleModel.fromJson)
          .toList(),
      courses: rawCourses
          .whereType<Map<String, dynamic>>()
          .map(CourseModel.fromJson)
          .toList(),
    );
  }
}
