class AppConfig {
  AppConfig._();

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'eSchool',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Release builds must never point to localhost / emulator loopback.
  /// Checked at startup in debug; asserted in tests.
  static bool get isReleaseUrlSafe {
    final String u = apiBaseUrl.toLowerCase();
    const List<String> banned = <String>[
      'http://10.0.2.2',
      'http://127.0.0.1',
      'http://localhost',
      'http://10.0.3.2',
    ];
    return !banned.any(u.startsWith);
  }

  /// Server origin derived from [apiBaseUrl] (strips a trailing /api/v1),
  /// used to resolve public storage URLs (/storage/...).
  static String get fileBaseUrl {
    const String suffix = '/api/v1';
    if (apiBaseUrl.endsWith(suffix)) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - suffix.length);
    }
    return apiBaseUrl;
  }

  static const String pusherKey = String.fromEnvironment(
    'PUSHER_KEY',
    defaultValue: 'local',
  );

  static const String pusherCluster = String.fromEnvironment(
    'PUSHER_CLUSTER',
    defaultValue: 'ap1',
  );

  static const String pusherHost = String.fromEnvironment(
    'PUSHER_HOST',
    defaultValue: '10.0.2.2',
  );

  static const int pusherPort = int.fromEnvironment(
    'PUSHER_PORT',
    defaultValue: 6001,
  );

  static const bool pusherTls = bool.fromEnvironment(
    'PUSHER_TLS',
    defaultValue: false,
  );
}
