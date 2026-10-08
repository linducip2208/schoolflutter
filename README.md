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
# Keystore release sudah dibuat lokal di android/app/eschool-release.jks
# + android/key.properties (KEDUANYA gitignored — JANGAN commit).
# BACKUP kedua file tersebut di tempat aman: jika hilang, update Play Store
# dengan package yang sama TIDAK MUNGKIN dilakukan (keystore tak tergantikan).
# Untuk dalamnya lihat SHA-256:
keytool -list -v -keystore android/app/eschool-release.jks
```

Regenerasi hanya bila keystore hilang (akan mengubah signature!):

```bash
keytool -genkeypair -v -keystore android/app/eschool-release.jks \
  -alias eschool -keyalg RSA -keysize 2048 -validity 10000
```

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
  --dart-define=API_BASE_URL=https://eschool.whitelabel.co.id/api/v1 \
  --dart-define=APP_ENV=production

flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://eschool.whitelabel.co.id/api/v1 \
  --dart-define=APP_ENV=production

# iOS — hanya di macOS dengan Xcode:
flutter build ipa --release \
  --dart-define=API_BASE_URL=https://eschool.whitelabel.co.id/api/v1 \
  --dart-define=APP_ENV=production
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

- Status: file config Firebase saat ini **placeholder**
  (`lib/firebase_options.dart`, `android/app/google-services.json`,
  `ios/Runner/GoogleService-Info.plist` — ketiganya gitignored).
  Aplikasi tetap jalan tanpa push (init dibungkus try/catch).
- Aktivasi (butuh login Google pemilik project Firebase):

```bash
firebase login --reauth
flutterfire configure --project=sikadpro-saas
```

  File placeholder otomatis tertimpa yang asli. Jangan commit file asli.

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

## First Launch & Support

- Popup "Selamat Datang di eSchool" muncul **sekali** per install
  (`first_launch_popup_seen` di SharedPreferences; tidak muncul ulang saat
  login/logout/refresh). Implementasi: `lib/core/widgets/welcome_popup.dart`.
- Kontak WhatsApp terpusat di `lib/core/config/app_contact.dart`:
  081296052010 → 6281296052010 → `https://wa.me/6281296052010`.
  Jangan hardcode nomor di widget.
- Settings → Tentang eSchool → Hubungi Kami memakai config yang sama
  (`lib/features/profile/presentation/pages/about_page.dart`, route `/about`).

## Testing

```bash
flutter analyze
flutter test
flutter test --coverage
flutter test test/core/welcome_popup_test.dart  # 12 popup tests
```

## Docs

- `docs/PRODUCTION_AUDIT.md` — audit sebelumnya (85/100)
- `docs/API_FEATURE_MATRIX.md` — matriks endpoint × role × offline
- `docs/FINAL_AUDIT.md` — audit final enterprise
- `docs/FINAL_SCORE.md` — skor final 93/100 + daftar P0–P3
