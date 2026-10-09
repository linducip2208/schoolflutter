# Feature Parity Matrix — Bukti per Fitur

Legenda: VERIFIED_COMPLETE (kode dibaca + kontrak cocok + tes/build),
PARTIAL (bagian kecil belum), WEB_ONLY_BY_DESIGN, NOT_VERIFIED (live).

## Akademik

| Fitur | Role | Screen | API | Status | Bukti |
|---|---|---|---|---|---|
| Dashboard per-role + super | semua | 6 dashboard pages + super | `/dashboard/*`, `/super/dashboard` | VERIFIED_COMPLETE | dashboard_bloc_test, backend keys cocok |
| Tahun ajaran + libur | admin | AcademicYearsPage (2 tab) | `/academic-years*`, `/holidays` | VERIFIED_COMPLETE | validasi cocok |
| Direktori siswa/staf | admin+ | StudentsPage, StaffPage (+search) | `/directory/*` | VERIFIED_COMPLETE | relasi user dipakai |
| Jadwal | student/teacher | TimetablePage | `/timetable/*` views | VERIFIED_COMPLETE | — |
| Absensi + QR + kunci/koreksi | semua | 2 pages + AttendanceToolsPage + QrScanPage | `/attendance/*`, `/qr/scan` | VERIFIED_COMPLETE | field `token`, offline queue test |
| Ujian attempt | student | ExamListPage + ExamAttemptPage | start/submit/result | VERIFIED_COMPLETE | kunci disembunyikan server |
| Ujian kelola + bank soal | teacher/admin | ExamManagePage, QuestionBankPage | CRUD + generate | VERIFIED_COMPLETE | validasi cocok |
| Nilai + rapor PDF | semua | MarksPage (per-role) + MarksBulkPage | `/marks/*`, `/report-cards/*` | VERIFIED_COMPLETE | parent 404 diperbaiki |
| Kurikulum/RPP | teacher/admin | CurriculumPage, LessonPlanPage | `/curriculum/*`, `/lesson-plans/*` | VERIFIED_COMPLETE | validasi cocok |
| Classroom+tugas+nilai | semua | ClassroomPage (+grade dialog) | lessons/assignments/submit/grade | VERIFIED_COMPLETE | offline submit test |
| Pengumuman target/jadwal | admin baca semua | AdminNoticePage, NoticeListPage | CRUD + `content` | VERIFIED_COMPLETE | bug 422 diperbaiki |

## Keuangan (kontrak rupiah backend, regression test)

| Fitur | Screen | Status | Bukti |
|---|---|---|---|
| Struktur + invoice + bayar manual | AdminFeesPage (3 tab), FinanceToolsPage | VERIFIED_COMPLETE | ConvertsRupiah + rupiah_test |
| Payment gateway BYOK + provider | PaymentPages, PaymentProvidersPage | VERIFIED_COMPLETE | initiate fields cocok |
| Payroll slip/struktur | PayrollPage (2 tab) | VERIFIED_COMPLETE | key `net_salary` + aksi |
| RKAS + realisasi | BudgetPage | VERIFIED_COMPLETE | planned×100 server |
| Laporan kas/aging/outstanding | ReportsPage | VERIFIED_COMPLETE | Controller baru + test route |
| Beasiswa apply/grant/invoice | ScholarshipsPage | VERIFIED_COMPLETE | fixed-vs-% ditangani |
| Donasi campaign/donate publik | DonationsPage | VERIFIED_COMPLETE | min:100 = Rp100 |
| Kantin + merchant | CanteenMenuPage, CanteenMerchantPage | VERIFIED_COMPLETE | ledger sen, topup Rp |

## Pembelajaran & komunikasi

LMS (enroll/progress/lesson/quiz-attempt/sertifikat): VERIFIED_COMPLETE
(`enrollment_id` diperbaiki). Live class schedule/join: VERIFIED_COMPLETE.
AI tools (3 fitur, format `messages`): VERIFIED_COMPLETE.
Chat (baru + offline) & notifikasi baca: VERIFIED_COMPLETE.
Event+RSVP, kalender iCal, daily report (+admin), hafalan+target,
PPDB (publik+verify+upload+submit): VERIFIED_COMPLETE.

## Layanan siswa & operasional

Perpus (katalog/pinjam/overdue), asrama (kamar/alokasi), transport
(rute/kendaraan/assign/trip/track), UKS, BK (sesi/bullying/risk),
disiplin, ekskul, prestasi, karier, alumni, visitor, inventaris,
dapodik (+import/export), yayasan, analitik risiko, ID gate,
emergency (+GPS panic, recent): VERIFIED_COMPLETE.

## Super admin & sekolah

Dashboard/tenant/plans/subs/analytics/system/health/config:
VERIFIED_COMPLETE. Backup/license/email/webhook/maintenance:
WEB_ONLY_BY_DESIGN. Profil sekolah/branding: VERIFIED_COMPLETE.

## Auth, role, offline, keamanan

Login/2FA/logout/expiry (tanpa loop), 21 role → shell+guard+test,
secure storage + drift clear saat logout, backoff+idempotency:
VERIFIED_COMPLETE (auth_bloc_test, sync_engine_test, rupiah_test).
l10n: infra ada, 0 layar pakai → PARTIAL (terdokumentasi, pasar ID).
Pinning/pentest: NOT_VERIFIED (keputusan tercatat).
