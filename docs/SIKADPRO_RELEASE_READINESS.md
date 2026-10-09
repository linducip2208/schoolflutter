# Release Readiness Checklist

Status: RELEASE_READY bersyarat (lihat langkah manual).

## Gate (bukti di SIKADPRO_TEST_RESULTS.md)

- [x] P0 selesai: rupiah, auth/session, tenant, kontrak rusak.
- [x] Nominal konsisten (regression Rp10.000).
- [x] Tanpa bocor antar akun (drift clear) / sekolah (scope+test pola).
- [x] Login/logout/expiry tanpa loop.
- [x] Build release sukses (APK+AAB di bawah).
- [x] Tanpa sukses palsu (keuangan online-only; tombol = API real).
- [x] Kontrak penting cocok (298/298 + body audit).
- [x] Regression tests kritis hijau.

## Artefak

- `build/app/outputs/flutter-apk/app-release.apk` (94,2MB)
- `build/app/outputs/bundle/release/app-release.aab` (68,5MB)
- Label `Sikad Pro` (aapt), package `com.sikadpro`, icons adaptif+iOS.
- Signing: keystore lokal tidak diubah; tanpa password di repo.

## Langkah manual sebelum publish

1. Review + merge patch backend (`sekolah`: ConvertsRupiah lanjutan,
   Directory/Reports/Budget/Letters/quiz-questions, dashboard fix,
   invoice paginate). Tanpa migrasi. Reseed data demo mobile lama
   bila dipakai (nominal 100x-kecil).
2. Deploy backend staging → smoke login demo → produksi.
3. Play Console: upload AAB, isi Data Safety (kontak, lokasi panic,
   file), target SDK 36.
4. Ganti password demo produksi; aktifkan 2FA akun keuangan.
5. Pantau Crashlytics/FCM token unregistered saat logout (sudah ada).

## Blocker: tidak ada yang kritis (lihat REMAINING_GAPS untuk P1-P3).
