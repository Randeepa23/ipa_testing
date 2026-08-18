import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/config/environment.dart';
import 'login_state.dart';

class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState.initial();
  Future<void> bootstrap() async {
    final session = await ref.read(agentApiClientProvider).restoreSession();
    if (session != null) {
      ref.read(agentSessionProvider.notifier).state = session;
      ref.read(agentSocketClientProvider).connect(session.token);
    }
    state = state.copyWith(
      isCheckingSession: false,
      isAuthenticated: session != null,
    );
  }

  void updateEmail(String value) =>
      state = state.copyWith(email: value, errorMessage: null);
  void updatePassword(String value) =>
      state = state.copyWith(password: value, errorMessage: null);
  void toggleRememberMe(bool value) =>
      state = state.copyWith(rememberMe: value);
  void toggleObscurePassword() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);
  Future<void> signOut() async {
    ref.read(agentSocketClientProvider).disconnect();
    await ref.read(agentApiClientProvider).logout();
    ref.read(agentSessionProvider.notifier).state = null;
    state = const LoginState.initial().copyWith(isCheckingSession: false);
  }

  Future<void> signIn() async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final session = await ref
          .read(agentApiClientProvider)
          .login(
            state.email.trim(),
            state.password,
            rememberMe: state.rememberMe,
          );
      ref.read(agentSessionProvider.notifier).state = session;
      ref.read(agentSocketClientProvider).connect(session.token);
      state = state.copyWith(isSubmitting: false, isAuthenticated: true);
    } on DioException catch (e) {
      final isUnavailable =
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.response?.data is Map
            ? '${(e.response!.data as Map)['detail'] ?? 'Sign in failed.'}'
            : isUnavailable
            ? 'Support server is unavailable at ${Environment.apiBaseUrl}. '
                  'Start the backend, then try again.'
            : 'Sign in failed. Please try again.',
      );
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Sign in failed. Please try again.',
      );
    }
  }

  String? validateEmail(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Username is required' : null;
  String? validatePassword(String? value) =>
      (value?.trim().isEmpty ?? true) ? 'Password is required' : null;
}
