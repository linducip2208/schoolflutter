# eSchool Flutter — Production Audit

Date: 2026-10-08
Scope: `D:\project flutter\eschool` vs backend `D:\project laravel\eschool`
Baseline: 4 commits, 32 tests green, analyze 0 errors.

## 1. Architecture — KEEP (per AGENTS.md)

Feature-first `data/*_repository.dart` + `presentation/pages/`.
BLoC only auth & dashboard; rest FutureBuilder + repo.
No Riverpod/domain/usecase refactor — would violate AGENTS.md.
Logic in repository, NOT widget — FIXED for 4 thin pages, 14 repos created.

## 2. API — VERIFIED

- 125 paths in `api_endpoints.dart`, all fragments found in `routes/api.php`.
- Dio singleton, 15s/30s timeouts, validateStatus 2xx only, 401 → logout.
- PUT added for `PUT /auth/profile` (backend requires PUT); rest GET+POST matches.
- `sync/batch` (attendance|mark, max 200, 200/207) added to SyncEngine.
- LMS `/lms/*`, emergency, QR `/qr/scan`, counseling, medical, reading,
  achievements, ekskul, calendar endpoints added.

## 3. Auth — OK

Sanctum bearer in secure storage, 2FA 202 challenge, restore/boot,
logout clears + FCM unregister best-effort, 401 interceptor redirects.

## 4. Authorization / Tenancy — OK

RoleResolver via `homeForRole`, prefix guards, staff fallback (fix 8000520).
Backend Spatie roles authoritative; Flutter visibility only.
school_id from backend session, never client-manipulated.

## 5. Security — CLEAN (2026-10-08 scan)

- No real secrets in `lib/` (only l10n "password" strings).
- No TODO/FIXME/Coming Soon/lorem/localhost in lib (0 matches).
- `.gitignore` covers .env, key.properties, *.jks, google-services.
- `android/key.properties` + `*.jks` exist on disk, NOT committed (verified
  via `git ls-files`).
- Tokens in secure storage (encrypted prefs), FCM token in prefs only.
- No TLS bypass, no cleartext production (isReleaseUrlSafe guard added).
- Logs redacted (PrettyDioLogger debug-only, headers off).

Issues fixed:
- [medium] `canteen_menu_page` divided IDR by 100 → fixed to `CurrencyFormatter.idr`.
- [low] 2 unused `dio` imports → removed.
- [medium] error mapping missing 404/409/429/5xx/cancel/cert → extended + tested.

## 6. UI/UX

Material3, Inter runtime, light/dark/system, id/en/ar.
Added: AppButton (double-tap guard), AppOfflineBanner (pendingCount +
connectivity), AppSearch (400ms debounce), ListShimmer exists.
Every network screen has loading/empty/error/retry (FutureBuilder +
AppError/AppEmpty/AppLoading).

## 7. Performance

const widgets, pagination (notifications 20, Laravel paginate), 6h timetable
cache, image caching, debounce search, no unbounded lists.

## 8. Offline

Drift `kv_cache` + `mutation_queue`, Idempotency-Key replay, backoff 5s×2^n
cap 1h max 8, auto-flush on reconnect, stale-while-revalidate getCached.
Batch endpoint added; full ERP offline NOT claimed.

## 9. Testing

42 tests green (32 baseline + 10 new: error mapping, IDR, AppConfig).
Widget: login, 2FA, splash. Unit: auth/dashboard BLoC, sync engine, unwrap.

## 10. Android / iOS

Android: INTERNET, POST_NOTIFICATIONS, CAMERA, MEDIA_IMAGES, LOCATION,
VIBRATE, BOOT_COMPLETED; min/target per Flutter stable; R8 via
build.gradle.kts; signing via key.properties (gitignored).
iOS: camera/photo/location descriptions, portrait (+landscape iPad),
no GoogleService-Info committed.

## 11. CI/CD

`.github/workflows/flutter.yml`: pub get, format check, analyze, test,
debug APK. Release needs `--dart-define=API_BASE_URL` secret.

## 12. Known limitations

- Backend uses PUT/DELETE widely; Flutter uses GET+POST+PUT(profile only).
  Full PUT/DELETE coverage only where mobile writes (profile). Admin
  bulk ops remain web-only by design.
- Push requires `flutterfire configure` + google-services files (gitignored).
- iOS build not executable on Windows; config reviewed only.
- 360 `info` lints (trailing commas/style) remain; 0 errors, 0 warnings
  after fix (1 warning fixed).

## Verification

- `flutter pub get` ✅
- `flutter analyze` ✅ 0 errors
- `flutter test` ✅ 42 passed
- `flutter build apk --debug` ⏳ (run in final loop)
- Contract script ✅ 125/125
- Secret scan ✅ clean
