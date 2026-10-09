# API Contract Audit — Bukti per Endpoint

Metode: (1) ekstraksi 298 path Flutter vs `php artisan route:list` →
cocok semua; (2) baca validasi tiap controller untuk tiap body yang
dikirim Flutter; (3) baca shape response untuk tiap key yang dibaca
Flutter. Hanya yang DIVERIFIKASI manual dicatat di bawah; sisanya
mengikuti pola defensif (`as num? ?? default`, `unwrapList` dua bentuk).

## Mismatch yang ditemukan & diperbaiki (P0/P1)

| Flutter mengirim | Backend minta | Fix |
|---|---|---|
| panic `{lat,lng?}` | `latitude,longitude` required | field + GPS geolocator |
| qr `{payload}` | `{token}` + device_info? | field |
| wellness `{mood}` | `mood_score` 1-10 | field + clamp |
| notice `{body}` | `content` required | field + target/schedule |
| branding `{name,primary_color}` | `display_name,color_primary…` | field |
| ai `{prompt,history?}` | `messages[{role,content}]` | format |
| complete-lesson `{lesson_id}` | `enrollment_id` + `lesson_id` | enrollment flow + sertifikat |
| super extend `{plan_expires_at}` | `plan_id` + `expires_at` | field + upgrade action |
| dashboard query `scheduled_at` | kolom `start_at` | backend fix (500 → ok) |
| exam list baca `name/subject/str` | `title`, relasi `subject.name`, `start_at` | mapping + attempt flow |
| payroll baca `net/employee_name` | `net_salary`, relasi `staff.user` | mapping + generate/markPaid |
| admission baca `name/source`, status bebas | `student_name`, enum enquiry/applied/enrolled/rejected | mapping + aksi |
| parent/children baca `name/nis` | model + relasi `user/classSection`, `admission_no` | mapping relasi |
| storeStructure `amount` rupiah | DB sen | backend ×100 (ConvertsRupiah) |
| recordPayment/topup/refund/donate rupiah | ledger sen | backend ×100 |
| invoice/dashboard/rencana tampil mentah | DB sen | backend /100 (rupiah-out) |

## Uang: kontrak per endpoint (terverifikasi di kode backend)

Rupiah-out (dibagi di API): fee, payroll slip/struktur-fixed,
kantin, donasi, beasiswa-fixed, inventaris, budget, reports,
dashboard fees, plan, subscription, invoice.
Disentuh: persen (payroll percentage, discount %, fee bp),
poin, qty, skor, ID. Regression: `test/core/rupiah_test.dart`
(Rp10.000 request→display, body tak berubah, 401/403/422/500 typed).

## Envelope & error

- List: raw `[...]` atau `{data:[...],total}` → `unwrapList` keduanya.
- Paginate: `page` param di 14 repo; UI infinite-scroll opt-in.
- Error: `mapDioError` typed (401/403/422-field/429/5xx); 401 di luar
  login/2FA → `AuthSessionExpired` (tanpa loop); login/2FA 401
  mempertahankan pesan form.
- Upload: multipart field `file` (import/ppdb/doc), `avatar`, `logo`;
  batas backend (10MB/2MB) dipakai di picker (ekstensi).
- Download: bytes → temp → open_filex (rapor PDF, CSV export).
- Idempotency-Key: chat/attendance/assignment + header global
  `X-App-Platform: mobile`.

## Yang TIDAK diverifikasi live (NOT RUN)

Integrasi produksi end-to-end ( larangan tulis ke produksi).
Verifikasi bersifat statis + unit/widget/mock-adapter, ditambah
health-check read-only publik (`/health`, `/api-docs` 200).
