# Production API — eSchool

Canonical source: `lib/core/config/app_config.dart`
(`prodApiBaseUrl`, `websiteUrl`, `apiDocsUrl`).

| Environment | API base | Notes |
|---|---|---|
| Production | `https://eschool.whitelabel.co.id/api/v1` | `--dart-define=API_BASE_URL=…` + `APP_ENV=production` |
| Dev (Android emulator) | `http://10.0.2.2:8000/api/v1` | default dart-define |
| Dev (iOS simulator) | `http://127.0.0.1:8000/api/v1` | `devApiBaseUrlIos` |
| Website | `https://eschool.whitelabel.co.id` | About → Website |
| API docs | `https://eschool.whitelabel.co.id/api-docs` | "Sikad Pro API Documentation" |

Builds:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://eschool.whitelabel.co.id/api/v1 \
  --dart-define=APP_ENV=production

flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://eschool.whitelabel.co.id/api/v1 \
  --dart-define=APP_ENV=production
```

## Live health check (2026-10-08, read-only GET)

- `GET /api/v1/health` → 200 `{"status":"ok","time":"…+07:00"}`
  (HTTPS+TLS OK, envelope `{status,time}`, Asia/Jakarta).
- `GET /api-docs` → 200 "Sikad Pro API Documentation".
- `GET /api/v1/auth/me` (no token) → 500. Expected 401 (route is
  `auth:sanctum` + `school.access` + `subscription.active`); the 500
  suggests the school/subscription middleware throws on guest instead of
  returning 401. Logged as backend observation P2 — Flutter maps it to a
  friendly ServerException, login flow unaffected. No destructive request
  was sent; no production data created.

## Contract notes

- 125 Flutter paths verified against `routes/api.php` (script, 2026-10-08).
- Auth: Sanctum bearer, 2FA 202-challenge, 401 → clear + login redirect.
- Errors mapped: 200/201/202/204/400/401/403/404/409/422/429/
  500/502/503/504 → typed AppException, 422 field errors preserved.
- Pagination: Laravel `paginate()` (`data/total/per_page`).
- Money: IDR integer whole rupiah. Timezone: Asia/Jakarta.
- No legacy hosts remain in code/config (`api.sikadpro.app`,
  `sikadpro.whitelabel.co.id` removed; Firebase project id
  `sikadpro-saas` and Android applicationId unchanged by design).
