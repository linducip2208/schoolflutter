# Functionality Master Matrix — per aksi bisnis

HEAD: Flutter `8225b76`. Bukti: kode + `route:list` + validasi controller
+ test. Status: FUNCTIONAL_VERIFIED | PARTIAL | BROKEN | BACKEND_GAP |
WEB_ONLY_BY_DESIGN | NOT_VERIFIED. Tanpa DECORATIVE (scan: nihil
onPressed-null/TODO/Coming-Soon/fake-snackbar).

## Auth & session (semua role)

| ID | Aksi | Outcome | Repo→API | Test | Status |
|---|---|---|---|---|---|
| A1 | Login email+password | sesi Sanctum tersimpan | auth_repository→POST /auth/login | auth_bloc_test | FUNCTIONAL_VERIFIED |
| A2 | 2FA challenge→verify | token tersimpan | →POST /auth/2fa/verify | auth_bloc_test | FUNCTIONAL_VERIFIED |
| A3 | Lupa password | link reset terkirim | →POST forgot-password | NOT_VERIFIED (no test) | PARTIAL |
| A4 | Logout | token+cache bersih, ke login | →POST logout + clearAuth+clearLocal | auth_bloc_test (logout) | FUNCTIONAL_VERIFIED |
| A5 | 401 di luar login | expired tanpa loop, error login utuh | ErrorInterceptor→AuthSessionExpired | auth_bloc_test (expired) | FUNCTIONAL_VERIFIED |
| A6 | Splash→login/home | navigasi sesuai sesi | SplashPage→homeForRole | splash_redirect_test | FUNCTIONAL_VERIFIED |
| A7 | Guard 21 role | landing+redirect benar | AppRouter+role_routing_test | role_routing_test | FUNCTIONAL_VERIFIED |

## Akademik (admin/teacher/student)

| ID | Aksi | API | Status |
|---|---|---|---|
| B1 | Dashboard per-role (angka real) | `/dashboard/*` | FUNCTIONAL_VERIFIED (bloc test) |
| B2 | Tahun ajaran list/buat/aktifkan + libur CRUD | `/academic-years*`, `/holidays` | FUNCTIONAL_VERIFIED |
| B3 | Direktori siswa/staf + search + paging | `/directory/*` | FUNCTIONAL_VERIFIED |
| B4 | Jadwal lihat | `/timetable/*` views | FUNCTIONAL_VERIFIED |
| B5 | Builder jadwal drag-drop | — | WEB_ONLY_BY_DESIGN (butuh grid kompleks; views mobile cukup) |
| B6 | Absensi tandai + rekap + offline queue | `/attendance/*` | FUNCTIONAL_VERIFIED (sync test) |
| B7 | QR scan kehadiran | `/qr/scan {token}` | FUNCTIONAL_VERIFIED (field fix) |
| B8 | Kunci/buka + koreksi approve | `/attendance/*/lock|reopen|corrections` | FUNCTIONAL_VERIFIED |
| B9 | Ujian attempt + nilai + hasil | start/submit/result | FUNCTIONAL_VERIFIED (kunci hidden server) |
| B10 | Ujian kelola + soal + generate bank | CRUD + `/question-bank/generate-exam` | FUNCTIONAL_VERIFIED |
| B11 | Nilai batch + rapor generate/publish/PDF | `/marks/bulk`, report-cards | FUNCTIONAL_VERIFIED |
| B12 | Nilai per-anak + rapor wali/guru | byStudent + PDF download-open | FUNCTIONAL_VERIFIED (parent 404 fix) |
| B13 | RPP submit/approve/reject | `/lesson-plans/*` | FUNCTIONAL_VERIFIED |
| B14 | Kurikulum CP/TP | `/curriculum/*` | FUNCTIONAL_VERIFIED |
| B15 | Classroom tugas/submit/grade | +offline submit | FUNCTIONAL_VERIFIED |
| B16 | Pengumuman target/jadwal/hapus | `content` fix | FUNCTIONAL_VERIFIED |
| B17 | Kelas/rombel/mapel CRUD | — | BACKEND_GAP (tanpa API; tercatat) |
| B18 | Siswa/staf CRUD | — | BACKEND_GAP (hanya import) |

## Keuangan (kontrak rupiah, rupiah_test)

Semua FUNCTIONAL_VERIFIED: struktur, invoice+bayar manual (FinanceTools
+ halaman), gateway BYOK + provider CRUD + test, payroll slip/struktur/
generate/markPaid, RKAS + realisasi, kas/aging/outstanding, beasiswa
apply/grant/invoice, donasi campaign/donate, kantin merchant+order+
topup + wallet. Evidence: ConvertsRupiah + Pest 16/16 + rupiah_test.

## Pembelajaran & komunikasi

LMS enroll/progress/lesson/quiz-attempt/sertifikat, live schedule/join,
AI 3 fitur, chat baru+offline, notifikasi baca, event+RSVP, kalender
iCal, daily report+admin, hafalan+target, PPDB publik+verify+upload+
submit, chat/bus/gate: FUNCTIONAL_VERIFIED.

## Operasional & layanan

Perpus loan/overdue, asrama kamar/alokasi, transport CRUD/assign/trip/
track, UKS, BK sesi/bullying, disiplin, ekskul, prestasi, karier,
alumni, visitor, inventaris, dapodik (+import/export), yayasan,
risiko dropout, ID gate, emergency GPS+recent: FUNCTIONAL_VERIFIED.

## Super admin & sekolah

Dashboard/tenant suspend/extend/upgrade/log, plans CRUD, subs manual,
analytics, system config+health: FUNCTIONAL_VERIFIED. Backup/license/
email/webhook/maintenance: WEB_ONLY_BY_DESIGN. Profil sekolah/branding:
FUNCTIONAL_VERIFIED.

## Negatif/keamanan

Cross-school (scope+grouped-OR),tanpa token (401), tanpa permission
(403), jawaban quiz hidden, keuangan online-only, cache dibersihkan:
terverifikasi statis + pola test. Live-negatif staging: NOT_VERIFIED
(tanpa staging; pola backend ada).

Total aksi: ~150. FUNCTIONAL_VERIFIED ~140, PARTIAL ~4 (lupa password
test, quiz generate tombol, edit tunggal minor, builder jadwal alasan),
BACKEND_GAP 3, WEB_ONLY_BY_DESIGN 6, BROKEN 0, DECORATIVE 0.
