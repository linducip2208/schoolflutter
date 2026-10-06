class AppConfig {
  AppConfig._();

  static const String appName = 'eSchool';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

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
