import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/failures.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';
import 'dio_helpers.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource._();
  static final AuthRemoteDataSource instance = AuthRemoteDataSource._();

  Dio get _dio => DioClient.instance.dio;

  /// تسجيل الدخول مع معالجة تلقائية لمشكلة "تجاوز حد الجلسات النشطة" (Tutor LMS)
  Future<UserModel> login(String username, String password) async {
    try {
      return await _doLogin(username, password);
    } on ServerFailure catch (e) {
      final isSessionLimit = _isSessionLimitError(e.message, e.statusCode);
      if (isSessionLimit) {
        await _clearSessionsAndRetry(username, password);
        return await _doLogin(username, password);
      }
      rethrow;
    }
  }

  Future<UserModel> _doLogin(String username, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {'username': username, 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          extra: {'skipAuth': true},
        ),
      );
      final body = res.data as Map<String, dynamic>? ?? {};

      final msg    = body['message'] as String? ?? '';
      final code   = body['code']    as String? ?? '';
      final status = (body['data'] as Map?)?['status'] as int? ?? 0;

      if (_isSessionLimitError(msg, status) || _isSessionLimitError(code, status)) {
        throw ServerFailure(msg.isNotEmpty ? msg : 'session_limit', statusCode: 403);
      }
      if (body.containsKey('code') && !body.containsKey('token')) {
        throw ServerFailure(
          _humanizeLoginError(code, msg),
          statusCode: status > 0 ? status : 401,
        );
      }
      if (body['token'] == null) {
        throw const ServerFailure('لم يتم إرسال رمز المصادقة من الخادم');
      }
      return UserModel.fromLoginJson(body);
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map) {
        final msg    = respData['message'] as String? ?? '';
        final code   = respData['code']    as String? ?? '';
        final status = e.response?.statusCode ?? 0;
        if (_isSessionLimitError(msg, status)) throw ServerFailure(msg, statusCode: 403);
        if (msg.isNotEmpty) {
          throw ServerFailure(_humanizeLoginError(code, msg), statusCode: status);
        }
      }
      return handleDioError(e);
    }
  }

  Future<void> _clearSessionsAndRetry(String username, String password) async {
    try {
      await _dio.post(
        ApiConstants.clearSessionsEndpoint,
        data: {'username': username, 'password': password},
        options: Options(extra: {'skipAuth': true}),
      );
      await Future<void>.delayed(const Duration(milliseconds: 800));
    } catch (_) {}
  }

  bool _isSessionLimitError(String msg, int? statusCode) {
    if (msg.isEmpty) return false;
    final lower = msg.toLowerCase();
    return lower.contains('exceeded') ||
        lower.contains('active session') ||
        lower.contains('active login') ||
        lower.contains('session limit') ||
        lower.contains('تجاوزت') ||
        lower.contains('الحد الأقصى') ||
        lower.contains('جلسات') ||
        msg.contains('tutor_active_session') ||
        msg.contains('session_limit');
  }

  /// يحوّل رسائل أخطاء الدخول (التي قد تأتي بصيغة HTML خام من ووردبريس/JWT)
  /// إلى رسالة عربية نظيفة ومفهومة للمستخدم بدل عرض وسوم HTML.
  String _humanizeLoginError(String code, String rawMsg) {
    final c = code.toLowerCase();
    if (c.contains('incorrect_password')) {
      return 'كلمة المرور غير صحيحة';
    }
    if (c.contains('invalid_username') || c.contains('invalid_email')) {
      return 'اسم المستخدم أو البريد الإلكتروني غير صحيح';
    }
    if (c.contains('empty_username') || c.contains('empty_password')) {
      return 'يرجى إدخال اسم المستخدم وكلمة المرور';
    }
    // إزالة وسوم HTML والكيانات الشائعة من الرسالة الخام.
    var msg = rawMsg
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // إزالة بادئة "Error:" / "خطأ:" الشائعة.
    msg = msg.replaceFirst(
      RegExp(r'^(error|خطأ)\s*[:：]\s*', caseSensitive: false),
      '',
    );
    return msg.isNotEmpty ? msg : 'تعذّر تسجيل الدخول، تحقق من بياناتك';
  }

  /// إرسال طلب استرجاع كلمة المرور (يرسل رابط/كود إعادة التعيين للبريد المسجَّل)
  Future<String> forgotPassword(String usernameOrEmail) async {
    try {
      final res = await _dio.post(
        ApiConstants.forgotPasswordEndpoint,
        data: {'user_login': usernameOrEmail},
        options: Options(
          contentType: Headers.jsonContentType,
          extra: {'skipAuth': true},
        ),
      );
      final body = res.data;
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
      return 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني';
    } on DioException catch (e) {
      final respData = e.response?.data;
      if (respData is Map && respData['message'] is String) {
        throw ServerFailure(
          respData['message'] as String,
          statusCode: e.response?.statusCode ?? 0,
        );
      }
      return handleDioError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // fetchNonce() حُذفت بالكامل — السبب الجذري للمشكلة
  // ══════════════════════════════════════════════════════════════════════════
  //
  // المشكلة: الـ /nonce endpoint يُستجاب له من cache الخادم
  // (LiteSpeed / WP Rocket / Redis وغيرها) بنفس القيمة لجميع المستخدمين.
  //
  // النتيجة:
  //   - hany2 تسجيل دخول → يحصل على nonce = "b51bdf85d8"
  //   - الخادم يُخزّن هذه الاستجابة في cache (مرتبطة بـ URL فقط، لا بالمستخدم)
  //   - hany55 تسجيل دخول → يحصل على نفس "b51bdf85d8" من الـ cache
  //   - كل طلبات hany55 تحمل X-WP-Nonce مرتبط بـ hany2
  //   - WordPress يحل هوية hany55 على أنه hany2 → يُعيد بيانات hany2
  //
  // الحل الصحيح:
  //   التطبيق المحمول لا يحتاج X-WP-Nonce أصلاً.
  //   الـ Nonce مخصص للمتصفح (cookie-based auth).
  //   JWT Bearer token كافٍ تماماً للتطبيق المحمول.
  //   انظر: auth_repo_impl.dart و dio_client.dart للتغييرات المرتبطة.
}
