import 'package:equatable/equatable.dart';

/// معلومات كورس مختصرة داخل الحزمة
class BundleCourse extends Equatable {
  final int    id;
  final String title;
  final String thumbnail;
  final bool   isEnrolled;
  final bool   isFree; // الدورة مجانية => تُفتح دون كود

  const BundleCourse({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.isEnrolled,
    this.isFree = false,
  });

  /// يمكن فتح المحتوى مباشرةً إذا كان مجانياً أو مشترَكاً فيه
  bool get canOpen => isEnrolled || isFree;

  @override
  List<Object?> get props => [id, isEnrolled, isFree];
}

/// حزمة دورات (Bundle)
class Bundle extends Equatable {
  final int              id;
  final String           title;
  final String           description;
  final String           thumbnail;
  final int              courseCount;
  final List<BundleCourse> courses;
  final bool             isEnrolled; // true إذا كان مسجّلاً في أي كورس من الحزمة
  final String           permalink;

  /// أسماء معلمي الباقة — تُستخدم في البحث وفي عرض البطاقة.
  final List<String>     instructors;
  final List<int>        instructorIds;

  const Bundle({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.courseCount,
    required this.courses,
    required this.isEnrolled,
    required this.permalink,
    this.instructors   = const [],
    this.instructorIds = const [],
  });

  /// اسم المعلم الأول (أو نص فارغ).
  String get primaryInstructor =>
      instructors.isNotEmpty ? instructors.first : '';

  @override
  List<Object?> get props => [id, isEnrolled];
}
