# Test Results — Bukti Eksekusi (2026-10-09)

## Flutter (`D:\project flutter\eschool`, master@0c45b6f + working tree)

| Perintah | Hasil |
|---|---|
| `flutter pub get` | OK (+geolocator) |
| `dart format --set-exit-if-changed lib test` | Bersih kecuali `lib/main.dart` (pre-existing, tak disentuh) |
| `flutter analyze lib test` | 0 error (1050 info: trailing-comma style) |
| `flutter test` | 74/74 hijau (~6 dtk) |

Isi suite: auth bloc (login/boot/2FA/logout/session-expiry),
dashboard bloc, sync engine (outbox/backoff/idempotency),
error mapping + rupiah regression (Rp10.000 round-trip + 401/403/422/500),
role routing 21 peran, production config, welcome popup, login/2FA/
splash widget, unwrap, smoke.

## Backend (`D:\project laravel\eschool`, main@a31bb59 + working tree)

| Perintah | Hasil |
|---|---|
| `php artisan test --filter=RupiahContractTest\|MobileMoneyAndDirectoryTest\|ApiContractTest` | 23/23 hijau (48 assertions, ~136 dtk) |

## Tidak dijalankan (alasan)

- Integrasi live produksi tulis: dilarang (produksi).
- `flutter build ipa`: tanpa toolchain macOS.
- Uji perangkat fisik (GPS/kamera): tanpa farm; GPS diuji via mock?
  belum — permission flow statis terverifikasi.
- Beban/stress: tanpa staging.

## Kegagalan selama pass (diperbaiki, bukan dihapus)

- `school_admin shares admin home`: ekspektasi kedaluwarsa setelah
  mapping diperbaiki → test diperbarui, implementasi benar.
- Brace mismatch 3 file saat editazu → ditulis ulang bersih, analyze hijau.
