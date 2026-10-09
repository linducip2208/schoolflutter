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
