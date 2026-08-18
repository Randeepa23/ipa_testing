import 'package:flutter/foundation.dart';

class Environment {
  const Environment._();

  static const _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const _configuredWebsocketUrl = String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: '',
  );

  /// Android emulators expose the development computer at 10.0.2.2. On
  /// desktop and web, localhost is the correct development address.
  static String get apiBaseUrl => _configuredApiBaseUrl.isNotEmpty
      ? _configuredApiBaseUrl
      : _localDevelopmentUrl;

  static String get websocketUrl => _configuredWebsocketUrl.isNotEmpty
      ? _configuredWebsocketUrl
      : _localDevelopmentUrl;

  static String get _localDevelopmentUrl =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:5005'
      : 'http://127.0.0.1:5005';

  static const useFontFallback = bool.fromEnvironment(
    'USE_FONT_FALLBACK',
    defaultValue: true,
  );
}
