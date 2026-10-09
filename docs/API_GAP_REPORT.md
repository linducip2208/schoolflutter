# API Gap Report — SikadPro Mobile (2026-10-09, final pass)

Source: `D:\project laravel\eschool\routes\api.php` (670 baris) vs
`D:\project flutter\eschool\lib\core\api\api_endpoints.dart` (298 path).
Metode: ekstraksi path otomatis + cocokkan URI ternormalisasi
(`php artisan route:list`) + verifikasi body/validasi per controller.

## Hasil: 298/298 path Flutter cocok dengan route backend

Tidak ada lagi MISSING_API operasional. Rincian celah:

## A. CLOSED dalam pass ini (patch backend `sekolah@main`)

| Gap | Patch backend | Test |
|---|---|---|
| Direktori siswa/staf/akademik | `DirectoryController` + 8 route | route wired 401-test |
| Soal quiz tanpa kunci | `LmsController@questions` + route | route wired 401-test |
| Laporan kas/aging/outstanding | `ReportsController` + 3 route | route wired 401-test |
| RKAS read/write | `BudgetController` API + 4 route | route wired 401-test |
| Surat-menyurat | `LetterController` API + 5 route | route wired 401-test |
| Kontrak rupiah (semua modul uang) | `ConvertsRupiah` + 8 controller | `RupiahContractTest` 4/4 |
| Dashboard siswa 500 (`scheduled_at`) | kolom → `start_at` | — (lihat catatan) |
| Harga paket/transaksi super (sen) | `SuperPlan/SubController` | — |
| Invoice staf unbounded `get()` | `paginate(50)` | unwrapList kompatibel |

Catatan: perubahan rupiah bersifat BREAKING terhadap data yang ditulis
mobile sebelum fix (nilai rupiah tersimpan sebagai sen). Data produksi
riil berasal dari web (sen, benar) sehingga tidak terdampak; data demo
yang ditulis via mobile perlu reseed. Deployment: `php artisan test`
+ deploy biasa, tanpa migrasi (tidak ada perubahan skema).

## B. WEB_ONLY by design (bukan gap)

Backup/restore DB, license key, email template, webhook log,
maintenance toggle. Alasan: operasi destruktif/server-only, milik
panel desktop + SSH, tidak pantas di aplikasi mobile.

## C. Sisa minor (terdokumentasi, bukan blocker jual)

- Generate ujian dari bank soal: repo siap, tanpa tombol (butuh
  exam_id + kriteria; alur guru jarang di HP).
- Update/hapus tunggal: soal ujian, buku, kategori disiplin, लंबे —
  pola sama dengan modul lain; ditunda karena jarang dipakai mobile.
- Bullying assign-konselor, alumni edit profil, medical record lookup,
  canteen transactions history, AI usage detail: endpoint ada,
  UI ringkas menyusul.
- Timetable builder drag-drop, builder konflik UI: butuh direktori
  (kini tersedia) —scope besar, web lebih tepat.
- Roles & permissions matrix editor: konfigurasi server, web-only.
- Quiz/lesson update-or-delete lanjutan: pola CRUD sama.

## D. Verifikasi isolasi & permission

Semua controller baru memakai `school_id` eksplisit + permission
(`student.view`, `staff.view`, `accounting.view|manage`,
`school.manage|notice.manage`) + bypass `super_admin` yang konsisten
dengan controller lama. Search siswa/staf di-group agar scope sekolah
tidak bocor via OR. Test negatif (403 lintas-peran) mengikuti pola
backend yang ada; full DB-backed test belum dijalankan di sini
(dokumentasikan di readiness).
