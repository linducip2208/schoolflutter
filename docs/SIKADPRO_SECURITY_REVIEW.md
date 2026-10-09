# Security Review — Bukti dan Sisa Risiko

## Diverifikasi (dengan bukti)

| Area | Temuan/Hasil | Bukti |
|---|---|---|
| Secret hardcode | Nihil (`Bearer ..`, `sk-`, `password=`): 0 match | grep lib/ |
| Log sensitif | Hanya error debug-gated, tanpa token | grep debugPrint |
| TLS | Tanpa `badCertificateCallback`; Dio default validasi | grep |
| Error ke user | Typed messages ID, tanpa stack trace | error_handler + test |
| Token | secure storage + mirror timeout; header Bearer per-request | app_storage, auth_interceptor |
| AuthZ | Semua controller baru: school_id + permission + super bypass; UI gate hanya UX | api.php, guards test |
| Tenant | Search di-group (tanpa OR bocor); paginate scoped | DirectoryController |
| Upload | Tipe/size divalidasi backend (mimes/max); picker batasi ekstensi | controller + picker |
| Logout | clearAuth + drift kv/outbox clear; 401 → expired tanpa loop | test AuthSessionExpired |
| Keuangan offline | Selalu online (dio langsung); tanpa sukses palsu | grep repo keuangan |
| Permissions OS | Kamera/GPS/file/notif saat dipakai; manifest+plist minimal | manifest, plist |
| Quiz anti-cheat | Kunci disembunyikan server; attempt butuh enrollment milik sendiri | ExamService, LmsController |
| Destruktif | Konfirmasi dialog (hapus, check-out, panic); tanpa reset/force | kode |

## Sisa risiko (jujur, P3)

1. Certificate pinning belum dipasang — keputusan: risiko lockout saat
   rotasi lebih besar; dokumentasikan, evaluasi saat domain stabil.
2. Pentest dinamis/instrumented belum dilakukan (tanpa perangkat farm).
3. Rate-limit login mengandalkan throttle backend (`throttle:login`).
4. File dibuka via app eksternal (open_filex) — konten dari endpoint
   ber-auth milik sekolah sendiri; acceptable.
5. Demo credentials di seeder bersifat publik (by design untuk demo);
   production wajib ganti (website sendiri memperingatkan).
