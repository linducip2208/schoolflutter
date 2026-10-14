# BUG AUDIT REPORT — SIKAD Pro Flutter

Tanggal: 12 Oktober 2026 · Auditor: Muse Spark (opencode)
Repo: `linducip2208/schoolflutter` (branch `master`)
Commit awal (pre-audit): `df7957b` — working tree BERSIH, tanpa perubahan lokal.
Backend pembanding: `D:\project laravel\eschool` (repo terpisah, hanya dibaca).
API produksi: `https://sikadpro.whitelabel.co.id/api/v1`

Metode: audit source-to-source (Flutter ↔ `routes/api.php` via
`php artisan route:list`, 409 routes), dua sub-audit independen
(auth end-to-end; offline + keamanan), setiap temuan diverifikasi
ulang di kode sebelum diperbaiki. Tidak ada test yang diubah agar
sekadar hijau; tidak ada pemeriksaan yang dinonaktifkan.

---

## 1. Ringkasan hasil

| Metrik | Sebelum | Sesudah |
|---|---|---|
| `flutter analyze` error / warning | 0 / 0 | 0 / 0 (1131 info) |
| `flutter test` | 83/83 | **93/93** (+10 regresi baru) |
| `dart format --set-exit-if-changed lib test` | 2 file belum format | bersih |
| Kontrak API (259 endpoint dipakai repo vs backend) | 259/259 cocok | 259/259 cocok |
| CI workflow | URL placeholder `staging.example.com` | URL dev aman |
| Build APK debug / APK release / AAB | — | sukses semua |

---

## 2. Bug yang ditemukan & diperbaiki

### P0 — Kritis

**P0-1. Antrean offline bisa terkirim sebagai pengguna lain.**
Lokasi: `lib/features/auth/data/auth_repository.dart:95` (`_storeSession`),
`lib/core/sync/sync_engine.dart:153` (`flush`).
Akar masalah: `MutationQueue` tidak terikat pemilik dan `flush()`
me-replay memakai token saat replay. `_storeSession` menimpa sesi tanpa
membersihkan antrean, sehingga: user A antre offline → login user B di
perangkat yang sama (tanpa logout) → mutasi A terkirim sebagai B.
Perbaikan: `_storeSession` membandingkan id user tersimpan; bila berbeda
(atau antrean yatim tanpa sesi), `SyncEngine.instance.clearLocal()`
dijalankan sebelum sesi baru disimpan. Tanpa migrasi skema Drift.
Regresi: `test/core/payment_safety_test.dart` — "login as a different
user wipes the offline outbox" + "same user keeps the outbox".

**P0-2. Kunci idempotensi antrean lemah (risiko tabrakan UNIQUE).**
Lokasi: `lib/core/sync/sync_engine.dart:267` (`_newKey`:
timestamp + `identityHashCode(Object())` yang low-entropy).
Perbaikan: UUID v4 (paket `uuid` sudah dipakai `AuthInterceptor`).

### P1 — Tinggi (uang / sesi)

**P1-1. Kunci idempotensi pembayaran dibuat baru per tap → risiko double-charge.**
Lokasi: `lib/features/payment/presentation/pages/payment_methods_page.dart:44`.
Backend dedup `initiate` pada kunci selama 24 jam
(`PaymentService.php:29-34`), jadi retry pasca-timeout dengan kunci baru
lolos dedup. Perbaikan: satu kunci stabil per (invoice, method),
dipakai ulang sampai intent sukses; `initiate()` kini mewajibkan
`idempotencyKey` (1 pemanggil, diverifikasi).
Regresi: `payment_safety_test.dart` — kunci diteruskan di header + body.

**P1-2. `recordPayment` tanpa guard ganda (backend tanpa dedup).**
Lokasi: `lib/features/fees/data/fees_repository.dart:90`,
 diverifikasi `FeeController.php:83-98` tidak mengenal idempotensi.
`runMutation` tidak punya guard double-tap. Perbaikan: guard in-flight
per invoice di repository + param `idempotencyKey` opsional (header +
body, untuk dukungan backend kelak). Pembayaran cicilan berurutan tetap
diizinkan.
Regresi: overlap ditolak (1 hit jaringan), sekuensial lolos (2 hit).

**P1-3. Retry 2FA loop buntu.**
Lokasi: `lib/features/auth/presentation/bloc/auth_bloc.dart:167`
vs backend `AuthService.php:53` (`Cache::pull` menghanguskan challenge
pada percobaan pertama, benar atau salah).
Perbaikan: kegagalan verifikasi menghapus challenge + pesan
"login ulang untuk kode baru" (halaman 2FA sudah menangani challenge
null dengan pesan kedaluwarsa).
Regresi: `auth_bloc_test.dart` — "challenge cleared on failure".

**P1-4. Session restore tanpa validasi server.**
Lokasi: `auth_repository.dart:126`, `auth_bloc.dart:122`.
Token yang direvoke / akun dinonaktifkan tetap dianggap login sampai
request pertama 401. Perbaikan: `validateSession()` (`GET /auth/me`)
oportunistik saat boot — 401 kedaluwarsa via interceptor global,
galat jaringan mempertahankan sesi cache (boot offline tetap jalan).
Regresi: "unauthenticated when server rejects session" (optimistic
authenticated → expired bersih).

### P2 — Sedang

**P2-1. Cast `as` pada respons login bisa crash (`TypeError`).**
Lokasi: `auth_repository.dart:58,86,96-98`. Perbaikan: ekstraktor
`_message()` aman + validasi `token`/`user` → `ServerException`.
Regresi: "200 without token raises ServerException, not TypeError".

**P2-2. Guard `homeroom_teacher` menolak shell guru.**
Lokasi: `lib/app/router/app_router.dart:934`. `homeForRole` memetakan
`homeroom_teacher` → `/teacher/dashboard` tetapi `_roleMatches`
menolak prefix `/teacher/` (redirect no-op yang rapuh).
Perbaikan: izinkan + seam uji `roleMatchesForTest`.
Regresi: `role_routing_test.dart` — guard matrix 7 kasus.

**P2-3. `school_code` login diabaikan backend.**
Lokasi: `login_page.dart:125` (field "Kode Sekolah (opsional)") vs
`LoginRequest.php:14-21` (tanpa rule) — diverifikasi, bukan asumsi.
Keputusan: TIDAK diubah di Flutter (kontrak mencadangkan field untuk
implementasi backend kelak; pengiriman field yang diabaikan tidak
berbahaya). Dicatat sebagai temuan backend §5.

### P3 — Rendah / hardening

**P3-1. Interceptor 401 menghapus sesi saat login gagal + navigasi ganda.**
Lokasi: `error_interceptor.dart:18-26`. `clearAuth()` jalan bahkan untuk
401 password-salah, dan `router.go(login)` berpacu dengan redirect
(`expireSession` cukup — redirect mendarat sekali).
Perbaikan: auth-attempt dikecualikan dari clear; `go()` eksplisit dihapus.

**P3-2. Logger debug mencetak password & token.**
Lokasi: `api_client.dart:43-51` (`requestBody/responseBody: true`;
body login berisi password plaintext, respons berisi token).
Perbaikan: body dimatikan, status + error tetap.

**P3-3. Kegagalan tulis secure storage ditelan diam-diam.**
Lokasi: `app_storage.dart:55`. Perbaikan: `debugPrint` saat `kDebugMode`
(mirror memori tetap menjaga sesi).

### CI (Tahap 2)

- `dart format lib test`: 2 file dirapikan (`main.dart`,
  `design_system_test.dart`, perubahan whitespace saja).
- `flutter pub get`: OK. Drift codegen (`build_runner`) dijalankan —
  0 perubahan (`.g.dart` sinkron).
- `.github/workflows/flutter.yml`: `staging.example.com` (domain
  placeholder tak-ada) → `http://10.0.2.2:8000/api/v1` +
  `APP_ENV=development` (loopback emulator, tak-routable; build CI tak
  mungkin menyentuh produksi). Urutan analyze → test → build dipertahankan.

---

## 3. Diverifikasi BERSIH (bukan bug)

- Kontrak API: 259/259 endpoint cocok method+path dengan backend
  (satu-satunya "mismatch" adalah artefak regex `/2fa/` pada script audit;
  `POST /auth/2fa/verify` ada di backend).
- Token di secure storage terenkripsi; FCM unregister sebelum logout;
  401 → logout otomatis; 422 dipetakan ke `ValidationException`.
- Tidak ada `print/debugPrint` token/password; tidak ada URL http aktif
  selain loopback dev; `prodApiBaseUrl` https.
- Manifest final: tanpa `READ_MEDIA_*` (dicabut via `tools:node="remove"`);
  tersisa `READ_EXTERNAL_STORAGE maxSdkVersion=32` dari `open_filex`
  (fallback sah Android ≤12, bukan pelanggaran kebijakan Photo/Video).
- Isolasi tenant backend: `TenantIsolationTest` hijau di repo backend.

---

## 4. Hasil verifikasi akhir (bukti perintah)

```
dart format --set-exit-if-changed lib test   → 240 files (0 changed)
flutter analyze --no-pub                     → 0 error, 0 warning
flutter test                                 → 93/93 All tests passed!
flutter build apk --debug (CI config)        → app-debug.apk (194.1 MB)
flutter build apk --release (produksi)       → app-release.apk (94.6 MB)
flutter build appbundle --release (produksi) → app-release.aab (68.7 MB)
```

---

## 5. Belum terselesaikan (butuh backend / keputusan penerbit)

1. **Token Sanctum tanpa kedaluwarsa + tanpa endpoint refresh**
   (`config/sanctum.php:50`, `AuthService.php:41`; grep `refresh` nihil di
   `routes/api.php`). Token curian valid selamanya. Perlu keputusan
   backend (repo `sekolah`, histori terpisah — tidak disentuh).
2. **Dedup `recordPayment` sisi server** — mitigasi Flutter (§P1-2)
   menahan double-tap; replay duplikat tetap mungkin jika backend tidak
   menambahkan `idempotency_key` pada `FeeController::recordPayment`.
3. **Alur reset-password in-app tak lengkap** — konstanta
   `resetPassword` tanpa pemanggil; halaman lupa-sandi hanya mengirim
   email (penyelesaian via tautan web). Perlu deep-link/applink +
   layar reset (fitur baru, di luar scope perbaikan bug).
4. **FCM token di SharedPreferences plaintext + registry ganda**
   (`users.fcm_token` vs `device_tokens`; endpoint legacy
   `/auth/fcm-token` tanpa pemanggil mobile). Dampak rendah.
5. **Default Pusher dev (`10.0.2.2:6001`, TLS off) tanpa guard rilis**
   — risiko salah konfigurasi produksi, bukan bug aktif.
6. **Retensi server, kebijakan usia siswa, email privasi final (C1–C7
   di `docs/privacy-policy.html`)** — menunggu konfirmasi penerbit.

---

## 6. Risiko yang wajib diuji manual

- Ganti akun A→B dengan antrean offline (P0-1) di 2 perangkat fisik.
- Timeout buatan saat initiate pembayaran (mode pesawat mid-request).
- Boot offline dengan sesi tersimpan; boot online dengan token direvoke.
- 2FA: kode salah 1x → wajib login ulang (bukan retry).
- `homeroom_teacher` menjelajah seluruh tab guru.
- Buka foto profil (Photo Picker), logo sekolah, impor CSV, pindai QR
  gerbang & barcode perpus — tanpa izin media luas (AAB baru).
- Notifikasi FCM foreground/background + tap deep-link.

---

## 7. Perubahan Git (belum di-commit saat laporan ditulis)

Commit awal: `df7957b` (clean). Diubah 17 file (15 modifikasi + 2 baru:
laporan ini dan `test/core/payment_safety_test.dart`): workflow CI, `app_router`,
`api_client`, `error_interceptor`, `app_storage`, `sync_engine`,
`auth_repository`, `auth_bloc`, `fees_repository`,
`payment_repository`, `payment_methods_page`, `main.dart` (format),
2 file test. Perintah yang disarankan:

```bash
git add -A
git commit -m "audit: P0 antrean lintas-user, idempotensi bayar, 2FA, validasi sesi, guard homeroom + 10 regresi"
git push origin master
```

Klaim jujur: 93 test otomatis hijau + kontrak 259/259 + build sukses.
Bukan klaim "bebas bug" — §5 dan §6 di atas adalah sisa yang diketahui.

## 8. Addendum 2026-10-14 (pasca-push `8bb7194`)

1. **Firebase Analytics dihapus dari build** (`android/app/build.gradle.kts`):
   `implementation("com.google.firebase:firebase-analytics")` dibuang.
   Dart terbukti hanya memakai core + messaging (grep nihil) — SDK yang
   menganggur ikut mengumpulkan data (beban Data Safety + risiko review).
   `docs/privacy-policy.html` [C7] ditandai SELESAI (tidak ada analitik).
2. **`android:allowBackup="false"`** (`AndroidManifest.xml`): default
   true mem-backup token Sanctum + cache ke Google Drive; aplikasi
   sekolah tidak boleh membocorkan kredensial ke backup perangkat.
3. **Komentar TODO applicationId dihapus** (kosmetik; id `com.sikadpro` tetap).
4. Verifikasi: `flutter build appbundle --release` sukses (67,8 MB);
   merged manifest memuat `allowBackup="false"`, tanpa analytics /
   `READ_MEDIA_*`. `flutter analyze` tetap 0 error/warning; tidak ada
   perubahan Dart sehingga test tidak perlu diulang (93/93 terakhir).
