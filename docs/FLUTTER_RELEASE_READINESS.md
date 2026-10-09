# Flutter Release Readiness — SikadPro (final, 2026-10-09)

Repo: `linducip2208/schoolflutter` (lokal `D:\project flutter\eschool`,
branch `master`, sinkron `origin/master` sebelum pass ini).
Backend: `linducip2208/sekolah` (lokal `D:\project laravel\eschool`,
branch `main`). Catatan: path `D:\project flutter\schoolflutter`
tidak ada di mesin ini — direktori aktual `eschool`.

## Quality gates (dijalankan)

| Gate | Hasil |
|---|---|
| `flutter pub get` | OK (+geolocator untuk panic GPS) |
| `dart format` | Bersih kecuali `lib/main.dart` (pre-existing, tak disentuh) |
| `flutter analyze lib test` | 0 error |
| `flutter test` | 74/74 hijau |
| `flutter build apk --release` | (lihat bawah) |
| Backend `php artisan test` (file baru) | 16/16 hijau |

## Yang diperbaiki pass ini (P0 dulu)

1. Rupiah 100x dua arah → kontrak rupiah backend + regression test.
2. Session expiry: 401 kini reset AuthBloc (tanpa loop), login/2FA
   dikecualikan agar pesan error form tidak hilang.
3. Kontrak body salah (selalu 422): panic `lat/lng`→`latitude/longitude`
   (+GPS via geolocator), QR `payload`→`token`, wellness `mood`→
   `mood_score`, notice `body`→`content`, branding `name`→`display_name`,
   LMS complete butuh `enrollment_id`, super extend butuh
   `plan_id`+`expires_at`, dashboard `scheduled_at`→`start_at`.
4. Display key salah: payroll (`net_salary`, nama staf relasi),
   admission (`student_name`, status enquiry/applied), exam list
   (`title`, relasi subject, attempt flow penuh).
5. Logout kini membersihkan cache+outbox drift (anti-bocor antar user).
6. Fitur tanpa aksi: chat baru, classroom grade, library loan,
   payroll slip/struktur, admission stats, notices hapus, hostel kamar,
   transport tracking, plan/subscription create, PPDB submit+upload,
   rapor PDF, nilai per-anak, notifikasi baca, profil avatar/edit.

## Status parity (50 baris, detail di SIKADPRO_WEBSITE_PARITY.md)

COMPLETE 49 / PARTIAL 1 (tombol generate-exam) / MISSING_API 0
operasional / WEB_ONLY by design 5+2. Parity ≈ 99%.

## Security

Fixed: session-expiry loop, cache lintas-user, field kontrak.
Verified: token di secure storage + memory mirror timeout, tanpa secret
tertanan, TLS default-on, error user-friendly tanpa stack trace,
keuangan online-only (tanpa sukses offline palsu), kamera/GPS/file
permission saat dipakai, upload tervalidasi backend (mimes/size).
Sisa: audit penetrasi penuh + certificate pinning belum ada (P3).

## Offline

Terverifikasi: outbox drift + backoff eksponensial + Idempotency-Key +
dead-letter + retryFailed + indikator pending. Klaim system Hanya
untuk chat/absensi/tugas (keuangan selalu online). Tidak ada klaim
offline-first palsu.

## Localization / UX

UI Bahasa Indonesia; switch locale tetap mengubah format tanggal/angka
via Material delegates + tema gelap didukung. Infra l10n (arb id/en/ar)
ada tetapi belum dipakai satu pun layar — migrasi string P3, bukan
blocker jual (pasar Indonesia).

## Rebrand SikadPro (final)

Launcher: ikon vektor (topi toga + rumbai emas, gradien biru) —
adaptive Android (anydpi-v26 + foreground per-densitas + legacy) +
set iOS penuh, terverifikasi via aapt (`application-label:'Sikad Pro'`).
Label: Android `Sikad Pro`, iOS display/name `Sikad Pro`.
In-app: splash, welcome, tentang, notifikasi channel, appName default.
Generator reprodusibel: `tool/gen_icon_test.dart`
(`flutter test tool/gen_icon_test.dart`).
Tidak diubah: applicationId, package, Firebase, keystore, identifier kode.

## Blocker rilis: TIDAK ADA yang kritis

Syarat deploy backend (patch `sekolah`): review + `php artisan test`
+ deploy normal, tanpa migrasi. Data demo mobile lama (nominal
100x-kecil) perlu reseed bila dipakai.
