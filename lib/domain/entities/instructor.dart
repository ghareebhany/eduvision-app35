import 'package:equatable/equatable.dart';

import 'bundle.dart';
import 'course.dart';

/// معلم في المنصة (مع إحصاءات مختصرة).
class Instructor extends Equatable {
  final int    id;
  final String name;
  final String avatarUrl;
  final String bio;
  final int    courseCount;
  final int    bundleCount;
  final double rating;

  const Instructor({
    required this.id,
    required this.name,
    this.avatarUrl   = '',
    this.bio         = '',
    this.courseCount = 0,
    this.bundleCount = 0,
    this.rating      = 0,
  });

  @override
  List<Object?> get props => [id, name, courseCount, bundleCount];
}

/// محتوى معلم: كتلة الباقات + كتلة الدروس.
class InstructorContent extends Equatable {
  final Instructor    instructor;
  final List<Bundle>  bundles;
  final List<Course>  courses;

  const InstructorContent({
    required this.instructor,
    required this.bundles,
    required this.courses,
  });

  @override
  List<Object?> get props => [instructor, bundles.length, courses.length];
}
