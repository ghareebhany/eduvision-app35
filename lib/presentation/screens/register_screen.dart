import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  شاشة إنشاء حساب جديد
//  تُرسل البيانات إلى: POST /app/v1/register  (hany-app-api)
//  وليس /wp/v2/users الذي يشترط صلاحية Administrator
// ══════════════════════════════════════════════════════════════════════════════

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ────────────────────────────────────────────────────────────
  final _firstNameCtrl   = TextEditingController();
  final _lastNameCtrl    = TextEditingController();
  final _usernameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();
  final _studentPhoneCtrl = TextEditingController();
  final _parentPhoneCtrl  = TextEditingController();
  final _schoolCtrl       = TextEditingController();

  // ── Dropdown selections ────────────────────────────────────────────────────
  String? _selectedGrade;
  String? _selectedAttendance;
  String? _selectedEducationSystem;
  String? _selectedEducationTrack;

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;

  // ── بيانات الـ dropdowns — متزامنة مع Custom User Fields Manager (CUFM) ───
  static const List<String> _grades = [
    'الأول الإعدادي',
    'الثاني الإعدادي',
    'الثالث الإعدادي',
    'الأول الثانوي',
    'الثاني الثانوي',
    'الثالث الثانوي',
  ];

  // الحقول الشرطية (نظام التعليم/المسار) تظهر فقط لهذين الصفين
  static const List<String> _gradesRequiringTrack = [
    'الثاني الثانوي',
    'الثالث الثانوي',
  ];

  static const List<String> _attendanceTypes = ['سنتر', 'اون لاين'];

  static const List<String> _educationSystems = ['نظام بكالوريا', 'نظام قديم'];

  static const Map<String, List<String>> _educationTracks = {
    'نظام بكالوريا': [
      'مسار الطب وعلوم الحياة',
      'مسار الهندسة وعلوم الحاسب',
      'مسار الأعمال',
      'مسار الاداب والفنون',
    ],
    'نظام قديم': [
      'أدبي',
      'علمي علوم',
      'علمي رياضة',
    ],
  };

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _studentPhoneCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  bool get _requiresTrackFields =>
      _gradesRequiringTrack.contains(_selectedGrade);

  // ── إرسال النموذج إلى /app/v1/register ────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من الـ dropdowns الأساسية
    if (_selectedGrade == null || _selectedAttendance == null) {
      _showError('يرجى اختيار الصف الدراسي ونوع الحضور');
      return;
    }
    // الحقول الشرطية (تظهر فقط لطلاب الصف الثاني/الثالث الثانوي)
    if (_requiresTrackFields &&
        (_selectedEducationSystem == null || _selectedEducationTrack == null)) {
      _showError('يرجى اختيار النظام التعليمي والمسار');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await DioClient.instance.dio.post(
        ApiConstants.registerEndpoint, // /app/v1/register
        data: {
          'first_name'       : _firstNameCtrl.text.trim(),
          'last_name'        : _lastNameCtrl.text.trim(),
          'username'         : _usernameCtrl.text.trim(),
          'email'            : _emailCtrl.text.trim(),
          'password'         : _passwordCtrl.text,
          'student_phone'    : _studentPhoneCtrl.text.trim(),
          'parent_phone'     : _parentPhoneCtrl.text.trim(),
          'school_name'      : _schoolCtrl.text.trim(),
          'grade_level'      : _selectedGrade,
          'attendance_type'  : _selectedAttendance,
          if (_requiresTrackFields) ...{
            'education_system' : _selectedEducationSystem,
            'education_track'  : _selectedEducationTrack,
          },
        },
        options: Options(extra: {'skipAuth': true}),
      );

      final msg = response.data?['message'] as String? ?? 'تم إنشاء الحساب بنجاح';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Color(0xFF23AB96)),
        );
        context.go('/login');
      }
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg  = (body is Map ? body['message'] : null) as String?
                ?? 'فشل إنشاء الحساب، يرجى المحاولة مرة أخرى';
      _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── الاسم الأول والأخير ────────────────────────────────────
                _sectionTitle('البيانات الأساسية'),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _firstNameCtrl, 'الاسم الأول', Icons.person_outline,
                        validator: (v) => v!.trim().isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        _lastNameCtrl, 'الاسم الأخير', Icons.person_outline,
                        validator: (v) => v!.trim().isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── اسم المستخدم ───────────────────────────────────────────
                _field(
                  _usernameCtrl, 'اسم المستخدم', Icons.account_circle_outlined,
                  textDirection: TextDirection.ltr,
                  validator: (v) {
                    if (v!.trim().isEmpty) return 'اسم المستخدم مطلوب';
                    if (v.trim().length < 4) return 'يجب أن يكون 4 أحرف على الأقل';
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                      return 'أحرف إنجليزية وأرقام و _ فقط';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── البريد الإلكتروني ──────────────────────────────────────
                _field(
                  _emailCtrl, 'البريد الإلكتروني', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  validator: (v) => !v!.contains('@') ? 'بريد إلكتروني غير صحيح' : null,
                ),
                const SizedBox(height: 14),

                // ── كلمة المرور ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _passwordField(
                        _passwordCtrl, 'كلمة المرور', _obscurePassword,
                        () => setState(() => _obscurePassword = !_obscurePassword),
                        validator: (v) => v!.length < 8
                            ? 'يجب أن تكون 8 أحرف على الأقل'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _passwordField(
                        _confirmCtrl, 'تأكيد كلمة المرور', _obscureConfirm,
                        () => setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => v != _passwordCtrl.text
                            ? 'كلمتا المرور غير متطابقتين'
                            : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 8),

                // ── الحقول المخصصة ─────────────────────────────────────────
                _sectionTitle('بيانات الطالب'),

                // هواتف
                Row(
                  children: [
                    Expanded(
                      child: _phoneField(
                        _studentPhoneCtrl, 'رقم تليفون الطالب',
                        Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _phoneField(
                        _parentPhoneCtrl, 'رقم تليفون ولي الأمر',
                        Icons.phone_in_talk_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // المدرسة
                _field(
                  _schoolCtrl, 'اسم المدرسة', Icons.school_outlined,
                  validator: (v) => v!.trim().isEmpty ? 'اسم المدرسة مطلوب' : null,
                ),
                const SizedBox(height: 14),

                // الصف الدراسي
                _dropdown(
                  label: 'الصف الدراسي',
                  icon: Icons.class_outlined,
                  value: _selectedGrade,
                  items: _grades,
                  onChanged: (v) => setState(() {
                    _selectedGrade = v;
                    // إعادة ضبط الحقول الشرطية عند تغيير الصف
                    if (!_requiresTrackFields) {
                      _selectedEducationSystem = null;
                      _selectedEducationTrack = null;
                    }
                  }),
                ),
                const SizedBox(height: 14),

                // نوع الحضور
                _dropdown(
                  label: 'نوع الحضور',
                  icon: Icons.event_seat_outlined,
                  value: _selectedAttendance,
                  items: _attendanceTypes,
                  onChanged: (v) => setState(() => _selectedAttendance = v),
                ),

                // ── حقول شرطية: تظهر فقط لطلاب الثاني/الثالث الثانوي ────────
                if (_requiresTrackFields) ...[
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'النظام التعليمي',
                    icon: Icons.account_balance_outlined,
                    value: _selectedEducationSystem,
                    items: _educationSystems,
                    onChanged: (v) => setState(() {
                      _selectedEducationSystem = v;
                      _selectedEducationTrack = null; // المسار يعتمد على النظام
                    }),
                  ),
                  const SizedBox(height: 14),
                  _dropdown(
                    label: 'المسار / الشعبة',
                    icon: Icons.alt_route_outlined,
                    value: _selectedEducationTrack,
                    items: _selectedEducationSystem == null
                        ? const []
                        : _educationTracks[_selectedEducationSystem]!,
                    onChanged: _selectedEducationSystem == null
                        ? null
                        : (v) => setState(() => _selectedEducationTrack = v),
                  ),
                ],

                const SizedBox(height: 32),

                // ── زر الإرسال ─────────────────────────────────────────────
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('إنشاء الحساب',
                          style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),

                // ── رابط تسجيل الدخول ──────────────────────────────────────
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('لديك حساب بالفعل؟ سجّل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets المساعدة ────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    TextDirection textDirection = TextDirection.rtl,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textDirection: textDirection,
      decoration: _decor(label, icon),
      validator: validator,
    );
  }

  Widget _phoneField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _decor(label, icon).copyWith(hintText: '01xxxxxxxx'),
      validator: (v) {
        final clean = v?.trim() ?? '';
        if (clean.isEmpty) return 'مطلوب';
        if (!RegExp(r'^01[0-9]{9}$').hasMatch(clean)) {
          return 'رقم غير صحيح (01xxxxxxxx)';
        }
        return null;
      },
    );
  }

  Widget _passwordField(
    TextEditingController ctrl,
    String label,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      decoration: _decor(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: toggle,
        ),
      ),
      validator: validator,
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    String Function(String)? displayLabel,
  }) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _decor(label, icon),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  displayLabel != null ? displayLabel(item) : item,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'يرجى الاختيار' : null,
      dropdownColor: cs.surface,
    );
  }

  InputDecoration _decor(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
    );
  }
}
