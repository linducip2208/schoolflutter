import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  static SharedPreferences? _prefs;

  /// In-memory mirrors: secure-storage I/O can hang indefinitely on devices
  /// with a broken keystore (no timeout inside the plugin). The mirrors keep
  /// the session usable for the app lifetime when that happens.
  static String? _memToken;
  static String? _memUser;
  static String? _memSchool;

  static const Duration _secureTimeout = Duration(seconds: 10);

  static const String _kToken = 'auth_token';
  static const String _kUser = 'auth_user';
  static const String _kSchool = 'auth_school';
  static const String _kFcmToken = 'fcm_token';
  static const String _kLocale = 'locale';
  static const String _kThemeMode = 'theme_mode';
  static const String _kFirstLaunchSeen = 'first_launch_popup_seen';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Auth (secure, with timeout + in-memory fallback).
  // Every secure read/write is bounded: a hanging keystore must never
  // freeze API calls (interceptors await these on every request).
  static Future<String?> getToken() async {
    if (_memToken != null) return _memToken;
    try {
      final String? v = await _secure.read(key: _kToken).timeout(
            _secureTimeout,
          );
      if (v != null) _memToken = v;
      return v;
    } on TimeoutException {
      return _memToken;
    } catch (_) {
      return _memToken;
    }
  }

  static Future<void> saveToken(String token) async {
    _memToken = token;
    try {
      await _secure.write(key: _kToken, value: token).timeout(_secureTimeout);
    } catch (_) {
      // best effort — memory mirror keeps the session alive.
    }
  }

  static Future<void> deleteToken() async {
    _memToken = null;
    try {
      await _secure.delete(key: _kToken).timeout(_secureTimeout);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> getUser() async {
    if (_memUser != null) {
      return json.decode(_memUser!) as Map<String, dynamic>;
    }
    try {
      final String? raw =
          await _secure.read(key: _kUser).timeout(_secureTimeout);
      if (raw == null) return null;
      _memUser = raw;
      return json.decode(raw) as Map<String, dynamic>;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final String raw = json.encode(user);
    _memUser = raw;
    try {
      await _secure.write(key: _kUser, value: raw).timeout(_secureTimeout);
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> getSchool() async {
    if (_memSchool != null) {
      return json.decode(_memSchool!) as Map<String, dynamic>;
    }
    try {
      final String? raw =
          await _secure.read(key: _kSchool).timeout(_secureTimeout);
      if (raw == null) return null;
      _memSchool = raw;
      return json.decode(raw) as Map<String, dynamic>;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSchool(Map<String, dynamic> school) async {
    final String raw = json.encode(school);
    _memSchool = raw;
    try {
      await _secure.write(key: _kSchool, value: raw).timeout(_secureTimeout);
    } catch (_) {}
  }

  static Future<void> clearAuth() async {
    _memToken = null;
    _memUser = null;
    _memSchool = null;
    try {
      await Future.wait(<Future<void>>[
        _secure.delete(key: _kToken),
        _secure.delete(key: _kUser),
        _secure.delete(key: _kSchool),
      ]).timeout(_secureTimeout);
    } catch (_) {}
  }

  // ── Misc (prefs)
  static String? getLocale() => _prefs?.getString(_kLocale);
  static Future<void> setLocale(String code) async =>
      _prefs?.setString(_kLocale, code);

  static String? getThemeMode() => _prefs?.getString(_kThemeMode);
  static Future<void> setThemeMode(String mode) async =>
      _prefs?.setString(_kThemeMode, mode);

  static String? getFcmToken() => _prefs?.getString(_kFcmToken);
  static Future<void> saveFcmToken(String token) async =>
      _prefs?.setString(_kFcmToken, token);

  // ── First-launch welcome popup (install-local state, NOT auth state).
  // Shown once per device install; never on login/logout/token refresh.
  static bool getFirstLaunchSeen() =>
      _prefs?.getBool(_kFirstLaunchSeen) ?? false;
  static Future<void> setFirstLaunchSeen() async =>
      _prefs?.setBool(_kFirstLaunchSeen, true);
}
