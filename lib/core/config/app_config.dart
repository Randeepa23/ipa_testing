import 'environment.dart';

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.websocketUrl,
    required this.useFontFallback,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: Environment.apiBaseUrl,
      websocketUrl: Environment.websocketUrl,
      useFontFallback: Environment.useFontFallback,
    );
  }

  final String apiBaseUrl;
  final String websocketUrl;
  final bool useFontFallback;
}
