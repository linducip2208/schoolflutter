# AGENTS.md — eSchool Flutter App

Satu sistem dengan backend `D:\project laravel\eschool` (repo
`linducip2208/sekolah`). Repo ini: `linducip2208/schoolflutter`, branch
`master`. JANGAN satukan histori git.

## Stack

Flutter stable, `flutter_bloc`, `go_router`, `dio`, `flutter_secure_storage`,
`shared_preferences`, `firebase_messaging` + `flutter_local_notifications`,
`pusher_channels_flutter`, `drift` (SQLite offline), `google_fonts` (Inter).

## Arsitektur

Feature-first: `data/*_repository.dart` + `presentation/pages/`. BLoC hanya
untuk auth & dashboard; sisanya FutureBuilder + repo. JANGAN tambah
arsitektur tanding. Logic di repository, BUKAN widget.

## API & offline

Base URL via `--dart-define=API_BASE_URL` (default dev 10.0.2.2).
`ApiClient` tunggal; `validateStatus` 2xx saja (401 → logout otomatis).
Kontrak: hanya GET+POST; semua path di `api_endpoints.dart` harus ada di
backend (`routes/api.php`).
Offline: `SyncEngine` + drift (`kv_cache`, `mutation_queue`), replay dengan
`Idempotency-Key`. Setelah ubah `lib/core/sync/*.dart`, jalankan codegen.

## Perintah

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze        # harus 0 error
flutter test           # harus hijau
flutter build apk --release --dart-define=API_BASE_URL=...
flutter build appbundle --release --dart-define=API_BASE_URL=...
```

## Konvensi

- Uang IDR = integer rupiah utuh (JANGAN /100).
- Tanggal tampil locale `id_ID`; zona ikut backend (Asia/Jakarta).
- i18n: id/en/ar di `lib/l10n/*.arb`; jangan hardcode string user-facing.
- Setiap screen: loading/empty/error/retry (+ offline bila relevan).
- Font Inter runtime via google_fonts; test hermetic via
  `test/flutter_test_config.dart`.

## Security & git

- Token di secure storage; FCM unregister saat logout.
- Jangan commit keystore (`android/app/*.jks`), `key.properties`,
  `google-services.json`, `GoogleService-Info.plist`, `build/`.
- Commit pesan jelas; jangan push tanpa diminta.
