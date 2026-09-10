import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/account_status.dart';

/// نافذة "حسابك في انتظار موافقة إدارة الموقع"
/// مطابقة لرسالة إضافة Tutor User Approval على المنصة.
Future<void> showApprovalDialog(
  BuildContext context, {
  required AccountStatus status,
  String? message,
  String? title,
}) {
  final disabled = status == AccountStatus.disabled;

  final headline = title ??
      (disabled
          ? 'لم تتم الموافقة على الحساب'
          : 'حسابك في انتظار موافقة إدارة الموقع');

  final body = (message == null || message.trim().isEmpty)
      ? (disabled ? kDisabledAccountMessage : kPendingApprovalMessage)
      : message.trim();

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final accent = disabled ? AppTheme.error : AppTheme.coral500;

      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          contentPadding: const EdgeInsets.fromLTRB(22, 24, 22, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  disabled
                      ? Icons.block_rounded
                      : Icons.hourglass_top_rounded,
                  color: accent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              if (!disabled)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'تم استلام طلب التسجيل بنجاح',
                    style: TextStyle(
                      color: accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Text(
                headline,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.75),
              ),
              if (!disabled) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'لا تنشئ حسابًا جديدًا بالبيانات نفسها؛ طلبك مسجل بالفعل، وستصلك رسالة على بريدك عند تفعيل الحساب.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.7),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    },
  );
}
