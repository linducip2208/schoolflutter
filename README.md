# eSchool — Flutter Mobile App

Aplikasi mobile multi-role (Student, Parent, Teacher, Admin, Staff, Librarian) untuk eSchool.

## Quick Start

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Codegen (drift local DB) — wajib setelah mengubah lib/core/sync/*.dart
dart run build_runner build --delete-conflicting-outputs

# 3. Setup Firebase (sekali per environment)
dart pub global activate flutterfire_cli
flutterfire configure --project=sikadpro-saas

# 4. Run di emulator
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=PUSHER_KEY=local \
  --dart-define=PUSHER_HOST=10.0.2.2 \
  --dart-define=PUSHER_PORT=6001
```

## Release Signing (Android)

```bash
# Sekali per mesin build: generate keystore (JANGAN commit file ini)
keytool -genkeypair -v -keystore android/app/eschool-release.jks \
  -alias eschool -keyalg RSA -keysize 2048 -validity 10000

# Isi android/key.properties (gitignored, lihat android/key.properties.example
# jika tersedia — JANGAN commit password asli):
# storePassword=...
# keyPassword=...
# keyAlias=eschool
# storeFile=eschool-release.jks
```

Tanpa `key.properties`, build release otomatis memakai debug keys (cocok untuk
dev/CI, TIDAK untuk Play Store).

## Build Production

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.sikadpro.app/api/v1 \
  --dart-define=PUSHER_KEY=PROD_KEY \
  --dart-define=PUSHER_HOST=ws.sikadpro.app

flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.sikadpro.app/api/v1

# iOS — hanya di macOS dengan Xcode:
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://api.sikadpro.app/api/v1
```

## Offline-First & Sync

- Local DB: **drift (SQLite)** — `lib/core/sync/app_database.dart`
- Outbox: `mutation_queue` (durable, survives restart) + `kv_cache` (GET cache)
- Engine: `SyncEngine` — auto-flush saat koneksi kembali (connectivity_plus),
  exponential backoff (5s→1h, maks 8x), dead-letter + `retryFailed()`
- Idempotency: setiap replay mengirim header `Idempotency-Key`; backend
  dedup via `idempotency_key` (payments, chat send) atau upsert natural
  (attendance, assignment submission)
- Terintegrasi: attendance (tandai + histori), timetable (cache 6 jam),
  assignment submit, chat send
- Indikator: `SyncEngine.instance.pendingCount` (ValueNotifier<int>)

## Push Notification (FCM)

- Registrasi: `POST /devices/register {token, platform, device_name}`
- Unregister otomatis saat logout (`POST /devices/unregister`)
- Foreground: flutter_local_notifications; background/data-only: handler di
  `main.dart`; tap → deep link per `type` (lihat `NotificationHandler`)

## Arsitektur

- **Pattern:** Feature-First (data / presentation), BLoC untuk auth & dashboard
- **State:** flutter_bloc 9.x
- **Routing:** go_router 16.x dengan role-based redirect
- **HTTP:** Dio + auth/error interceptors (validate 2xx; 401 → logout)
- **Storage:** flutter_secure_storage (token/user/sekolah), SharedPreferences
  (locale/theme/fcm), drift/SQLite (cache + outbox)
- **Push:** Firebase Messaging + flutter_local_notifications
- **Real-time:** Pusher Channels (chat, broadcast)
- **Font:** Inter via google_fonts (runtime, cached); fallback sistem bila
  offline pada install pertama
- **i18n:** Bahasa Indonesia (default), English, Arabic (RTL)

## Folder Structure

```
lib/
  main.dart              ← Firebase/FCM bg handler, SyncEngine wiring
  app/                   ← App root, router, theme
  core/
    api/                 ← Dio client, endpoints, interceptors
    sync/                ← drift DB, stores, SyncEngine (offline-first)
    notifications/       ← FCM service + deep-link handler
    storage/             ← secure storage + prefs
  features/              ← Feature modules (auth, dashboard, attendance, ...)
  shells/                ← Role-based bottom nav shells (5 roles)
  l10n/                  ← Translations (id, en, ar)
test/
  core/sync_engine_test.dart  ← outbox/backoff/idempotency/cache (6 test)
  features/                   ← bloc tests
  widgets/                    ← widget tests
```

## Backend API

Backend Laravel 13 (PHP 8.3) dengan endpoint `/api/v1/*`, auth Laravel
Sanctum (Bearer token).Timezone user-facing default `Asia/Jakarta`.
Lihat `docs/` di repo backend untuk referensi lengkap.
