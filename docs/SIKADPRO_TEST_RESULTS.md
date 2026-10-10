# Test Results — Bukti Eksekusi (2026-10-10, pass final)

## Flutter (`D:\project flutter\eschool`, master + working tree)

| Perintah | Hasil |
|---|---|
| `flutter pub get` | OK (+geolocator) |
| `dart format --set-exit-if-changed lib test` | Bersih kecuali `lib/main.dart` (pre-existing, tak disentuh) |
| `flutter analyze lib test` | 0 error |
| `flutter test` | 77/77 hijau |

Isi suite (77): auth bloc (login/boot/2FA/logout/session-expiry),
dashboard bloc, sync engine (outbox/backoff/idempotency),
error mapping + rupiah regression (Rp10.000 round-trip + 401/403/422/500),
request hardening (idempotency header + dialog guard),
role routing 21 peran, production config, welcome popup, login/2FA/
splash widget, unwrap, smoke.

## Backend (`D:\project laravel\eschool`, main + working tree)

| Perintah | Hasil |
|---|---|
| kontrak + route wired | 23/23 hijau |
| `TenantIsolationTest` (DB khusus `sikadpro_tenant_iso`, serial, rollback) | 3/3 hijau (directory scope, fee filter kosong, parent 403/404) |

## Live smoke produksi (2026-10-10, read-only + login/logout demo)

Server pulih (`/health/deep` all-ok). Login demo admin@sman1demo.sch.id
200 (role admin, 90 siswa). Hasil:

- 200: dashboard (fees_pending 4500000000 SEN = Rp45jt — bukti
  produksi BELUM pakai ConvertsRupiah), academic-years, holidays,
  fee structures (25000000 SEN = Rp250rb), notices, library, exams,
  events, ekskul, lms. Logout 200 (token dicabut).
- 404: `/directory/*`, `/reports/*`, `/budget/*`, `/letters`
  → patch backend BELUM DI-DEPLOY ke produksi.
- 403: `/super/dashboard` untuk admin → benar (guard bekerja).

KESIMPULAN: aplikasi Flutter HANYA benar bila backend `main`
sudah di-deploy. Tanpa itu: nominal 100x + ~20 layar 404.
JANGAN rilis app sebelum deploy backend. Tanpa migrasi.

## Tidak dijalankan (alasan)

- Mutasi live produksi: dilarang (produksi; smoke hanya baca + login/
  logout akun demo publik).
- `flutter build ipa`: tanpa toolchain macOS.
- Uji perangkat fisik (GPS/kamera): tanpa farm.
- Beban/stress: tanpa staging.

## Kegagalan selama pass (diperbaiki, bukan dihapus)

- `school_admin shares admin home`: ekspektasi kedaluwarsa setelah
  mapping diperbaiki → test diperbarui, implementasi benar.
- Brace mismatch 3 file saat editazu → ditulis ulang bersih, analyze hijau.
