import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_ds.dart';

class ForgotPasswordState {
  final bool isLoading;
  final bool success;
  final String? message;
  final String? error;
  const ForgotPasswordState({
    this.isLoading = false,
    this.success = false,
    this.message,
    this.error,
  });
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordState());

  Future<void> submit(String usernameOrEmail) async {
    state = const ForgotPasswordState(isLoading: true);
    try {
      final msg =
          await AuthRemoteDataSource.instance.forgotPassword(usernameOrEmail);
      state = ForgotPasswordState(success: true, message: msg);
    } on Failure catch (f) {
      state = ForgotPasswordState(error: f.message);
    } catch (_) {
      state = const ForgotPasswordState(error: 'حدث خطأ غير متوقع، حاول مرة أخرى');
    }
  }

  void reset() => state = const ForgotPasswordState();
}

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(),
);
