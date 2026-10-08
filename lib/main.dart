import 'dart:async' show unawaited;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/bloc_observer.dart';
import 'core/api/api_client.dart';
import 'core/notifications/fcm_service.dart';
import 'core/storage/app_storage.dart';
import 'core/sync/app_database.dart';
import 'core/sync/stores.dart';
import 'core/sync/sync_engine.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Data-only messages are NOT shown by the OS — display them manually
  // so background notifications behave like foreground ones.
  final RemoteNotification? n = message.notification;
  final String title = n?.title ?? message.data['title']?.toString() ?? '';
  final String body = n?.body ?? message.data['body']?.toString() ?? '';
  if (title.isEmpty && body.isEmpty) return;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'eschool_default',
    'eSchool Notifications',
    importance: Importance.high,
  );
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final String payload = message.data.entries
      .map((MapEntry<String, dynamic> e) => '${e.key}=${e.value}')
      .join('&');
  await plugin.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'eschool_default',
        'eSchool Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: payload,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await initializeDateFormatting('id_ID');
  await AppStorage.init();
  ApiClient.init();

  // Offline-first: drift-backed outbox + read cache, auto-flush on reconnect.
  try {
    final AppDatabase db = AppDatabase();
    SyncEngine.instance.configure(
      mutations: DriftMutationStore(db),
      kv: DriftKvStore(db),
    );
    unawaited(SyncEngine.instance.start());
  } catch (_) {
    // Storage unavailable — app still runs online-only (in-memory stores).
  }

  // Firebase must NEVER block first frame: on devices without Play
  // Services / network, plugin calls can hang with no internal timeout.
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 15));
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    await FcmService.instance
        .init()
        .timeout(const Duration(seconds: 45));
  } catch (_) {
    // Firebase not configured / unreachable — app runs without push.
  }

  Bloc.observer = const AppBlocObserver();

  runApp(
    MultiRepositoryProvider(
      providers: <RepositoryProvider<Object>>[
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>(
            create: (BuildContext ctx) => AuthBloc(ctx.read<AuthRepository>())
              ..add(const AuthBootRequested()),
          ),
        ],
        child: const EschoolApp(),
      ),
    ),
  );
}
