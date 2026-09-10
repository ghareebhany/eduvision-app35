/// أدوات بحث ذكية تدعم العربية.
///
/// المشكلة السابقة: كان البحث `title.contains(query)` فقط، فلم يكن يجد:
///   • اسم المعلم
///   • النتائج عند اختلاف الهمزات (أ/إ/آ/ا) أو التاء المربوطة (ة/ه) أو الألف المقصورة (ى/ي)
///   • النتائج عند وجود تشكيل أو مسافات زائدة
///   • البحث بعدة كلمات غير متتالية (مثل: «فيزياء ثانوية»)
library;

final RegExp _tashkeel = RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640]');
final RegExp _nonWord = RegExp(r'[^\u0600-\u06FF0-9a-z\s]');
final RegExp _spaces = RegExp(r'\s+');

/// يوحّد شكل النص للمقارنة (عربي + إنجليزي + أرقام هندية).
String normalizeText(String input) {
  if (input.isEmpty) return '';
  var s = input.toLowerCase();

  // أرقام عربية/فارسية → لاتينية
  const arabicDigits = '\u0660\u0661\u0662\u0663\u0664\u0665\u0666\u0667\u0668\u0669';
  const persianDigits = '\u06F0\u06F1\u06F2\u06F3\u06F4\u06F5\u06F6\u06F7\u06F8\u06F9';
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    final ai = arabicDigits.indexOf(ch);
    final pi = persianDigits.indexOf(ch);
    if (ai >= 0) {
      buf.write(ai);
    } else if (pi >= 0) {
      buf.write(pi);
    } else {
      buf.write(ch);
    }
  }
  s = buf.toString();

  s = s.replaceAll(_tashkeel, '');
  s = s
      .replaceAll('\u0623', '\u0627') // أ
      .replaceAll('\u0625', '\u0627') // إ
      .replaceAll('\u0622', '\u0627') // آ
      .replaceAll('\u0671', '\u0627')
      .replaceAll('\u0629', '\u0647') // ة → ه
      .replaceAll('\u0649', '\u064a') // ى → ي
      .replaceAll('\u0624', '\u0648')
      .replaceAll('\u0626', '\u064a')
      .replaceAll('\u06A9', '\u0643')
      .replaceAll('\u06CC', '\u064a');

  s = s.replaceAll(_nonWord, ' ');
  s = s.replaceAll(_spaces, ' ').trim();
  return s;
}

/// يقسّم نص البحث إلى كلمات موحّدة.
List<String> searchTokens(String query) {
  final n = normalizeText(query);
  if (n.isEmpty) return const [];
  return n.split(' ').where((t) => t.isNotEmpty).toList();
}

/// يطابق إذا كانت **كل** كلمات البحث موجودة في أي من الحقول.
bool matchesAllTokens(List<String> tokens, Iterable<String?> fields) {
  if (tokens.isEmpty) return true;
  final haystack = fields
      .where((f) => f != null && f.isNotEmpty)
      .map((f) => normalizeText(f!))
      .join(' \u0640 ');
  if (haystack.isEmpty) return false;
  for (final t in tokens) {
    if (!haystack.contains(t)) return false;
  }
  return true;
}

/// درجة ملاءمة بسيطة لترتيب النتائج: العنوان أولاً، ثم المعلم، ثم بقية الحقول.
int relevanceScore({
  required List<String> tokens,
  required String title,
  String? instructor,
  Iterable<String> extra = const [],
}) {
  if (tokens.isEmpty) return 0;
  final nTitle = normalizeText(title);
  final nInstructor = normalizeText(instructor ?? '');
  final nExtra = extra.map(normalizeText).join(' ');
  var score = 0;
  for (final t in tokens) {
    if (nTitle.startsWith(t)) {
      score += 6;
    } else if (nTitle.contains(t)) {
      score += 4;
    }
    if (nInstructor.contains(t)) score += 3;
    if (nExtra.contains(t)) score += 1;
  }
  return score;
}
