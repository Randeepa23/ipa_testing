class LoginState {
  const LoginState({
    required this.isCheckingSession,
    required this.isAuthenticated,
    required this.isSubmitting,
    required this.rememberMe,
    required this.obscurePassword,
    required this.email,
    required this.password,
    required this.errorMessage,
    required this.connectionMessage,
    required this.disabledMessage,
  });

  const LoginState.initial()
    : isCheckingSession = true,
      isAuthenticated = false,
      isSubmitting = false,
      rememberMe = true,
      obscurePassword = true,
      email = '',
      password = '',
      errorMessage = null,
      connectionMessage = null,
      disabledMessage = null;

  final bool isCheckingSession;
  final bool isAuthenticated;
  final bool isSubmitting;
  final bool rememberMe;
  final bool obscurePassword;
  final String email;
  final String password;
  final String? errorMessage;
  final String? connectionMessage;
  final String? disabledMessage;

  LoginState copyWith({
    bool? isCheckingSession,
    bool? isAuthenticated,
    bool? isSubmitting,
    bool? rememberMe,
    bool? obscurePassword,
    String? email,
    String? password,
    String? errorMessage,
    String? connectionMessage,
    String? disabledMessage,
  }) {
    return LoginState(
      isCheckingSession: isCheckingSession ?? this.isCheckingSession,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      rememberMe: rememberMe ?? this.rememberMe,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
      connectionMessage: connectionMessage,
      disabledMessage: disabledMessage,
    );
  }

  bool get hasError =>
      errorMessage != null ||
      connectionMessage != null ||
      disabledMessage != null;
}
