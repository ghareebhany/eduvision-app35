/// مرجع مختصر لكورس، يُرفَق مع كل عنصر في قسم "كل ما يخصّك"
/// حتى تستطيع البطاقات عرض اسم الكورس والانتقال إليه.
class CourseRef {
  final int id;
  final String title;
  const CourseRef(this.id, this.title);
}

/// عنصر في قسم "كل ما يخصّك" مرفقًا معه الكورس الذي ينتمي إليه.
class HubEntry<T> {
  final CourseRef course;
  final T item;
  const HubEntry(this.course, this.item);
}
