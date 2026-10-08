import 'dart:async' show TimeoutException;
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../storage/app_storage.dart';
import 'notification_handler.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'eschool_default',
    'eSchool Notifications',
    description: 'Default channel untuk notifikasi eSchool',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Never let push setup block app startup: every platform-channel call
    // below can hang without network/Play Services (no Dart-side timeout
    // inside the plugins), so each is individually bounded.
    try {
      await _fcm
          .requestPermission(alert: true, badge: true, sound: true)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Proceed without push permission; app must still start.
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        if (r.payload != null) {
          NotificationHandler.handlePayload(r.payload!);
        }
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) {
      NotificationHandler.handleMessage(m);
    });

    RemoteMessage? initial;
    try {
      initial = await _fcm
          .getInitialMessage()
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      initial = null;
    }
    if (initial != null) {
      NotificationHandler.handleMessage(initial);
    }

    await _refreshToken();
    _fcm.onTokenRefresh.listen((String t) async {
      await AppStorage.saveFcmToken(t);
      await _registerToBackend(t);
    });
  }

  Future<void> _refreshToken() async {
    try {
      // Network call to Firebase; bounded so offline devices still start.
      final String? t = await _fcm
          .getToken()
          .timeout(const Duration(seconds: 20));
      if (t == null) return;
      await AppStorage.saveFcmToken(t);
      await _registerToBackend(t);
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] token error: $e');
    }
  }

  /// Registers the FCM token to the multi-device registry.
  /// Backend: POST /devices/register {token, platform, device_name}.
  Future<void> _registerToBackend(String token) async {
    final String? jwt = await AppStorage.getToken();
    if (jwt == null) return;
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.devicesRegister,
        data: <String, String>{
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'device_name': 'mobile',
        },
      );
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[FCM] register backend error: $e');
    }
  }

  /// Removes this device from the push registry (call on logout).
  /// Best-effort: local state is cleared regardless.
  Future<void> unregisterFromBackend() async {
    final String? fcmToken = AppStorage.getFcmToken();
    if (fcmToken == null || fcmToken.isEmpty) return;
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.devicesUnregister,
        data: <String, String>{'token': fcmToken},
      );
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[FCM] unregister backend error: $e');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage m) async {
    final RemoteNotification? n = m.notification;
    if (n == null) return;

    final String payload = m.data.entries
        .map((MapEntry<String, dynamic> e) => '${e.key}=${e.value}')
        .join('&');

    await _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
