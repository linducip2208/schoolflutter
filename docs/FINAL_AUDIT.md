# eSchool Flutter — FINAL AUDIT (Enterprise Production)

Date: 2026-10-08 · HEAD: 18158f8 → this finalization
Backend: Laravel 13 `D:\project laravel\eschool` (source of truth)

## Architecture
Feature-first `data/*_repository.dart` + `presentation/pages/`, BLoC auth &
dashboard only (per AGENTS.md). No new competing architecture. 28 repos
(logic in repo, never in widget). Single Dio ApiClient, 401→logout, 2xx only.
Secure storage (token/user/school), prefs (locale/theme/FCM/first-launch).

## Security
- No secrets in lib (scan clean, only l10n "password" strings).
- No key.properties/*.jks/google-services/.env committed.
- Token never logged (PrettyDioLogger debug-only, headers off), never in
  crash/analytics (no such SDK wired), no screenshots of secrets.
- No TLS bypass, `isReleaseUrlSafe` guard, PUT profile matches backend.
- Android exported=false default (Flutter), deep links via go_router only,
  file downloads via authorized `/uploads/file`, avatar 400px validated.
- Logout clears secure auth + FCM unregister best-effort.

## API Contract (125 + 12 new l10n, verified vs routes/api.php)
Flutter handles 200/201/202(2FA)/204/400/401/403/404/409/422/429/
500/502/503/504 → typed AppException, 422 field errors, no raw
DioException/SQL/Laravel trace to user. Pagination via Laravel paginate
`data/total/per_page`. IDR integer whole rupiah (test-locked, canteen /100
bug fixed).

## Offline & Sync
Drift kv_cache + mutation_queue, Idempotency-Key minted pre-attempt and
reused on retry (stable key, never regenerated per retry), flush replays,
4xx dead-letter, 5xx backoff 5s×2^n cap 1h max 8, auto-flush reconnect +
boot, app-kill recovery via drift, `sync/batch` (200 max) added.
Covered: ONLINE/OFFLINE/→/APP KILL/RESTART/401-while-offline/double-tap
(double-tap guard + AppButton)/duplicate POST (idempotency)/500/409/422.

## Testing
54 tests green: sync engine (7), auth BLoC (9), dashboard BLoC (3),
error mapping + IDR + AppConfig (10), welcome popup (12), login/2FA/
splash/smoke widgets. Coverage via `flutter test --coverage`.

## Android / iOS
Android: applicationId `com.sikadpro`, label
eSchool, perms minimal + camera/media/location/notification, R8, desugar,
signing via gitignored key.properties. iOS: camera/photo/location
descriptions, portrait (+iPad landscape), no committed plist.

## UX / Accessibility
Material3, Inter runtime, light/dark/system, id/en/ar (no hardcoded UI
strings; 12 welcome/about keys added). Every network screen:
loading/empty/error/retry (+offline banner). Search 400ms debounce,
pagination everywhere. Popup: semantics, 48px targets, text-scale 2.0
tested, 320×568 tested, dark/light tested.

## First Launch & WhatsApp
`SupportContact` single source: 081296052010 → 6281296052010 →
`https://wa.me/6281296052010?text=<encoded>`. Popup once per install
(`first_launch_popup_seen` in prefs, never on login/logout/refresh),
dismiss = seen, premium Material3 dialog (rounded 28, maxWidth 420,
SafeArea, scrollable). Settings → Tentang eSchool → Hubungi Kami reuses
same config. WA failure → friendly AppError, never crash.

## Known Limitations
- No live staging backend test in this loop (contract static-verified).
- Release AAB/APK signing needs CI secrets; iOS release needs macOS.
- Granular Spatie perms: Flutter guards UX only (Laravel authoritative).
- 360+ style `info` lints remain (0 errors target met).
