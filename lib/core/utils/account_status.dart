library;

/// حالة حساب المستخدم وفق إضافة Tutor User Approval على المنصة.
enum AccountStatus { active, pending, disabled, unknown }

AccountStatus accountStatusFromString(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'pending':
      return AccountStatus.pending;
    case 'disabled':
    case 'rejected':
      return AccountStatus.disabled;
    case 'active':
      return AccountStatus.active;
    default:
      return AccountStatus.unknown;
  }
}

const String kPendingApprovalMessage =
    'حسابك في انتظار موافقة إدارة الموقع. سنراجع بياناتك، وبعد الموافقة ستتمكّن من تسجيل الدخول واستخدام التطبيق.';

const String kDisabledAccountMessage =
    'هذا الحساب غير مفعل حاليًا. يرجى التواصل مع إدارة الموقع.';

/// أكواد الخطأ القادمة من الخادم (API التطبيق + إضافة المنصة).
const _pendingCodes = <String>[
  'account_pending',
  'tua_pending_account',
  'cufm_pending_account',
];

const _disabledCodes = <String>[
  'account_disabled',
  'tua_disabled_account',
  'cufm_rejected_account',
];

/// عبارات احتياطية لو وصلت الرسالة دون كود (مثلاً HTML من ووردبرس).
bool _hasPendingWording(String text) {
  final t = text.replaceAll('\u064b', '').replaceAll('\u064e', '');
  return (t.contains('انتظار') && t.contains('موافق')) ||
      t.contains('قيد المراجعة') ||
      t.toLowerCase().contains('pending approval') ||
      t.toLowerCase().contains('awaiting approval');
}

bool _hasDisabledWording(String text) =>
    text.contains('غير مفعل') ||
    text.contains('مرفوض') ||
    text.toLowerCase().contains('account disabled');

/// يحدّد حالة الحساب من كود ورسالة خطأ الدخول.
AccountStatus detectAccountStatus({String code = '', String message = ''}) {
  final c = code.trim().toLowerCase();
  if (_pendingCodes.contains(c)) return AccountStatus.pending;
  if (_disabledCodes.contains(c)) return AccountStatus.disabled;
  if (_hasPendingWording(message)) return AccountStatus.pending;
  if (_hasDisabledWording(message)) return AccountStatus.disabled;
  return AccountStatus.unknown;
}

/// هل يجب عرض شاشة/نافذة "بانتظار الموافقة" بدل رسالة خطأ عادية؟
bool isApprovalBlock(AccountStatus s) =>
    s == AccountStatus.pending || s == AccountStatus.disabled;
