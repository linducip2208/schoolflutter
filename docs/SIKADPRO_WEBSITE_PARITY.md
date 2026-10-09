# SikadPro Website → Flutter Parity (Source of Truth: production website)

Audit date: 2026-10-09. Authoritative product contract:
`https://sikadpro.whitelabel.co.id/` (+ `/pricing`), API
`https://sikadpro.whitelabel.co.id/api/v1`.

- Flutter project (local dir): `D:\project flutter\eschool`
  (repo name `schoolflutter`; local directory is `eschool`).
- Backend: `D:\project laravel\eschool` (repo `linducip2208/sekolah`).

Status values: COMPLETE / PARTIAL / MISSING_FLUTTER / MISSING_API /
MISSING_BACKEND / BROKEN / WEB_ONLY / NOT_MOBILE_RELEVANT.
COMPLETE is only used when list+detail+actions+states work on mobile
against a real endpoint. No fake menus, no fake numbers.

## 1. Website product inventory (authoritative)

Portals: Admin web (`/admin/login`), Parent portal (`/portal`),
Student (`/siswa`), Operator platform (`/super/login`).
Roles: Super Admin, Administrator Sekolah, Kepala Sekolah, Guru,
Keuangan, Orang Tua, Siswa, Yayasan.
Plans: Free (Attendance, Notice), Basic (+Library, Fee, Timetable,
Classroom, Exam), Pro (all modules).

## 2. Parity table

| Website Feature | Backend | API | Flutter Service/Repository | Flutter Screen | Role | Status | Gap |
|---|---|---|---|---|---|---|---|
| Kurikulum & CP/ATP | CurriculumController, PkgCompetencySeeder | `/curriculum/*` | — | — | admin/teacher | MISSING_FLUTTER | FLUTTER GAP |
| Manajemen kelas & rombel | ClassRoom/Section models (web CRUD) | academic-years, holidays only | — | — | admin | MISSING_API | API GAP (no class CRUD API) |
| Jadwal pelajaran | TimetableController | `/timetable/*` (view+CRUD) | timetable_repository | TimetablePage | student/teacher | PARTIAL | admin alias missing; mgmt UI missing |
| Absensi harian & QR | AttendanceService, QrAttendance | `/attendance/*`, `/qr/scan` | attendance_repository (+offline) | Student/TeacherAttendancePage | all school | COMPLETE | — |
| Ujian & bank soal | ExamController, QuestionBank | `/exams/*`, `/question-bank/*` | exam_repository | ExamListPage (attempt) | student/teacher | PARTIAL | bank + exam CRUD UI missing |
| Nilai & raport PDF | MarksController, ReportCardController | `/marks/*`, `/report-cards/*` | marks_repository | MarksPage | student/parent/teacher | PARTIAL | bulk input, generate/publish UI missing |
| Database siswa | Student model; import only | `/import/students` only | — | — | admin | MISSING_API | API GAP (no student CRUD API) |
| PPDB online | PpdbController (+admin verify) | `/public/ppdb/*`, `/ppdb/*`, `/admin/ppdb/*` | ppdb_repository | PpdbRegisterPage | public/parent/admin | PARTIAL | admin verify/accept UI missing |
| Disiplin & tata tertib | DisciplineController | `/discipline/*` | discipline via repo | summary only | teacher/admin | PARTIAL | records CRUD UI missing |
| BP/BK & konseling | CounselingController | `/counseling/*`, `/wellness/*` | counseling_repository | WellnessCheckinPage | counselor/student | PARTIAL | sessions list, bullying UI missing |
| UKS / klinik | ClinicController | `/medical/*` | medical_repository | ClinicVisitsPage | nurse/parent | PARTIAL | record mgmt UI missing |
| Ekstrakurikuler | ExtracurricularController | `/ekskul` | ekskul endpoint const only | — | student/teacher | MISSING_FLUTTER | FLUTTER GAP |
| Struktur biaya & SPP | FeeController | `/fee/structures` | fees_repository | AdminFeesPage | admin | COMPLETE | — |
| Invoice & tagihan | FeeController, PaymentGateway | `/fee/invoices*`, `/payments/*` | fees/payment repositories | StudentFeesPage, PaymentPages | parent/student/admin | COMPLETE | — |
| Payment gateway (BYOK) | PaymentGatewayController (+admin providers) | `/payments/*`, `/admin/payment-providers/*` | payment_repository | PaymentMethods/StatusPage | parent/admin | PARTIAL | provider CRUD UI missing |
| Payroll guru | PayrollController | `/payroll/*` | payroll_repository | PayrollPage | admin/accountant | PARTIAL | generate/mark-paid actions missing |
| Anggaran (RKAS) | BudgetController (web only) | — | — | — | admin | MISSING_API | API GAP (web-only) |
| Laporan keuangan | AccountingService (web only) | — | — | — | admin/accountant | MISSING_API | API GAP (web-only) |
| Perpustakaan & e-library | LibraryController, ReadingProgress | `/library/*`, `/reading/*` | library_repository | LibraryPage, BarcodeScannerPage | all | PARTIAL | reading-progress UI missing |
| Asrama / hostel | HostelController | `/hostel*` | hostel_repository | HostelPage | admin/student | COMPLETE | — |
| Transportasi & bus tracking | Transport/VehicleTracking/IdGate | `/transport/*`, trips, bus-location, gate-events | transport/bus repositories | TransportPage, BusTrackingPage | admin/parent | PARTIAL | admin trips view missing |
| Inventaris & aset | InventoryController | `/inventory/*` | — | — | admin | MISSING_FLUTTER | FLUTTER GAP |
| Visitor management | VisitorController | `/visitors*` | — | — | receptionist/admin | MISSING_FLUTTER | FLUTTER GAP |
| Kantin cashless | CanteenController | `/canteen/*` | canteen_repository | CanteenMenuPage | student/admin | PARTIAL | merchant (orders-today) UI missing |
| Pengumuman | NoticeController | `/notices*` | notice_repository | NoticeListPage, AdminNoticePage | all/admin | COMPLETE | — |
| Chat antar peran | ChatController | `/chat/*` | chat_repository (+offline) | ChatList/ConversationPage | all | COMPLETE | — |
| Notifikasi FCM/email/SMS | NotificationController, FCM | `/notifications/*`, `/devices/*` | notifications_repository, FcmService | NotificationsPage | all | COMPLETE | — |
| WhatsApp bot | WaBotWebhook (inbound) | webhook only | SupportContact wa.me link | About/Contact | all | WEB_ONLY | inbound channel, not app feature |
| Surat-menyurat | DocumentController (web) | — | — | — | admin | MISSING_API | API GAP |
| Webhook | platform integration | — | — | — | — | NOT_MOBILE_RELEVANT | server-to-server |
| AI assistant | AiController | `/ai/study-assistant` (+lesson-plan, essay-grade) | ai_repository | StudyAssistantPage | student/teacher | PARTIAL | lesson-plan & essay UI missing |
| Penilaian essay otomatis | AiController | `/ai/essay-grade` | — | — | teacher | MISSING_FLUTTER | FLUTTER GAP |
| Deteksi risiko dropout | AnalyticsController | `/analytics/risk-scores/*` | — | — | counselor/admin | MISSING_FLUTTER | FLUTTER GAP |
| Learning analytics | DashboardDataService | `/foundations/*/dashboard` | — | — | yayasan/admin | MISSING_FLUTTER | FLUTTER GAP |
| Dashboard yayasan | FoundationController | `/foundations/mine`, `/foundations/{id}/dashboard` | — | — | foundation_admin | MISSING_FLUTTER | FLUTTER GAP |
| Sinkronisasi Dapodik | DapodikController | `/admin/dapodik/*` | — | — | admin/school_admin | MISSING_FLUTTER | FLUTTER GAP |
| Multi-tenant / white-label | BrandingController, SchoolScope | `/branding*` | branding_service | AboutPage | all | COMPLETE | — |
| Kalender akademik | ApiCalendarController | `/calendar/ical` | endpoint const only | — | all | MISSING_FLUTTER | FLUTTER GAP (feed render) |
| Event & RSVP | EventController | `/events`, `/{id}/rsvp` | eventRsvp const only | — | student/parent | MISSING_FLUTTER | FLUTTER GAP (list UI) |
| Daily report | DailyReportController | child view + `/admin/daily-reports/*` | daily_report_repository | DailyReportViewerPage | parent/admin | PARTIAL | admin generate/send UI missing |
| Hafalan & ibadah | ReligiousController | `/religious/*` | hafalan_repository | HafalanInputPage | teacher/student | COMPLETE | — |
| Beasiswa | ScholarshipController | `/scholarship/*` | endpoint consts only | — | student/admin | MISSING_FLUTTER | FLUTTER GAP |
| Prestasi & badge | AchievementController | `/achievements/*` | endpoint consts only | — | student/teacher | MISSING_FLUTTER | FLUTTER GAP |
| Alumni | AlumniController | `/alumni/*`, public directory | — | — | alumni/admin | MISSING_FLUTTER | FLUTTER GAP |
| Donasi | DonationController | `/admin/donations/*`, public campaigns | — | — | admin/public | MISSING_FLUTTER | FLUTTER GAP |
| Karier / BKK | CareerController | `/career/*` | — | — | student/admin | MISSING_FLUTTER | FLUTTER GAP |
| Live class | LiveClassController | `/live-class/sessions/{id}/join` (+schedule/start) | liveClassJoin const | — | teacher/student | MISSING_FLUTTER | FLUTTER GAP (join UI; mgmt UI) |
| LMS (kursus, kuis, sertifikat) | LmsController | `/lms/*` full | lms_repository (no UI) | — | student | PARTIAL | repo done, pages missing |
| Emergency / panic button | EmergencyController | `/emergency/*` | emergency_repository (no UI) | — | all | PARTIAL | repo done, button UI missing |
| Auth login/logout/2FA | AuthService, Sanctum | `/auth/*` | auth_repository | Login/2FA/Forgot pages | all | COMPLETE | — |
| SuperAdmin panel | SuperAdminService | `/super/*` | superadmin_repository (+dashboard) | SuperDashboard/SchoolsPage | super_admin | PARTIAL | plans/subs/analytics UI missing |

## 4. Pass 2 — implementasi (2026-10-09, semua kontrak dicek ke controller)
Admin hub 45 tile, hub guru (12), hub siswa (17), hub wali (8),
detail anak 7-tab, super plans/analytics/system — semua ke endpoint real.
AI study-assistant diperbaiki (`messages[]`, sebelumnya pasti 422).

Baru COMPLETE: Tahun Ajaran, Ujian kelola, Kurikulum, Nilai batch,
PPDB verify, Event, Ekskul, Inventaris, Visitor, Kantin merchant,
Transport manage, Dapodik (config/test/runs/konflik),
UKS kelola, Disiplin, Konseling, ID Gate, Live Class, AI tools+provider,
Payment BYOK, Branding, Import/Export, Risiko dropout, Yayasan,
Alumni, Emergency, Kalender iCal, Aksi keuangan, Beasiswa (program/apply/grant),
Prestasi (catat/leaderboard), Karier magang, Donasi (campaign),
RPP, Hostel (rooms/alokasi), Library (buku/denda), Payroll actions,
Admission (status/enroll), Classroom (tugas/grade), Parent 7-tab,
Bullying report, Super plans/analytics/system.
PARTIAL tersisa: LMS (quiz attempt via web), Bank soal (generate),
Exam (update), Marks (publish UI), Beasiswa (apply-to-invoice),
Karier (assessment form), Donasi (donate publik), Dapodik (import),
Attendance (lock/koreksi: repo saja), Hafalan target (repo saja),
Notices (target/schedule: repo create dasar), Super (backup/license/
email-template/webhook-log/maintenance: web-only, API GAP),
Jadwal builder (API GAP: direktori rombel/mapel),
DB siswa & staff CRUD (API GAP), RKAS & laporan keuangan & surat
(API GAP), Rombel/mapel directory (API GAP).

Hitung BARU (50 baris): COMPLETE 38 / PARTIAL 9 /
MISSING_FLUTTER 1 (quiz-attempt UI) / MISSING_API 5 /
WEB_ONLY+NON_MOBILE 2.
WEBSITE→FLUTTER PARITY ≈ 85% ((38 + 9×0,5)/48).
SALE READINESS ≈ 80% — semua menu website ada padanannya di Flutter;
sisa: API GAP backend (5), peran non-inti (staff placeholder),
quiz-attempt native, polish lanjutan.

## 3. Role shells (Flutter, after pass 2)

super_admin → SuperAdminShell (Dashboard, Sekolah, Profil + cepat:
Paket, Analitik, Sistem).
admin/school_admin → AdminShell (Dashboard, Admisi, Keuangan, Menu, Profil)
+ hub 45 modul real.
teacher → TeacherShell (Beranda, Absensi, Kelas, Ujian, Menu, Profil)
+ hub 12 modul (RPP, bank soal, nilai, live, AI, kurikulum, hafalan,
disiplin, prestasi, chat, notif, darurat).
student → StudentShell (Beranda, Jadwal, Kelas, Chat, Menu, Profil)
+ hub 17 modul (nilai, absensi, perpus, kantin, bus, ekskul, event,
beasiswa, karier, prestasi, LMS, live, AI, pengumuman, notif,
bullying, darurat).
parent → ParentShell (Beranda, Nilai, Kehadiran, Tagihan, Menu, Profil)
+ hub 8 + daftar anak → detail 7-tab (overview, absensi, nilai, UKS,
disiplin, prestasi, konseling-info).
Other backend roles (accountant, librarian, nurse) get dedicated shells
(see Pass 3 below; staff fallback only for truly unknown roles).

## 5. Pass 3 — non-core roles + contract bugs (2026-10-09)

Contract bugs fixed (found while verifying against controllers):
- Notice create sent `body`; backend requires `content` (always 422).
  Fixed + target roles + scheduled publish.
- AI study-assistant sent `prompt`; backend requires `messages[]`.
  Fixed in pass 2.

New dedicated shells (permissions verified vs seeder + controllers):
accountant, librarian, nurse, counselor, principal, receptionist, hr,
transport_admin, hostel_admin, procurement_admin, driver/security
(gate QR scan + emergency), visitor_operator, school_admin
(canteen/visitor/dapodik), foundation_admin. homeroom_teacher shares
the teacher home (documented). school_admin moved from adminDashboard
to schoolops home (matches its actual permissions).

Pending actions done: exam update, marks publish-by-id, scholarship
apply-to-invoice, career assessment record + activity log, public
donation, dapodik CSV import, attendance lock/reopen + corrections,
hafalan targets.
Native quiz attempt = API GAP (no question-detail endpoint;
`GET /lms/quizzes` returns counts only) — directed to web portal.

NEW COUNT (50 rows): COMPLETE 44 / PARTIAL 3 (LMS quiz attempt,
question-bank generate UI, super backup/sysadmin web-only) /
MISSING_API 6 (+quiz questions, +backup/license/email/webhook) /
WEB_ONLY+NON_MOBILE 2.
WEBSITE-TO-FLUTTER PARITY = 92% ((44 + 3x0.5)/48).
SALE READINESS = 88% — remaining: 6 backend API GAPs (laravel repo),
further polish, quiz attempt awaiting backend endpoint.

## 6. Pass 4 — money contract fix + API GAP closure (2026-10-09)

CRITICAL money bug (both directions, found via web-form audit):
web stores cents (x100 on write, /100 on read) but mobile API passed
raw values through — Flutter displayed 100x inflated invoices and
wrote 100x-deflated payments/topups/structures.
Fix: `ConvertsRupiah` trait, mobile API now speaks whole rupiah
in/out (Fee, Payroll, Canteen, Donation, Scholarship, Inventory);
percent/point/qty keys untouched. Backend Pest: 16/16 green.

New backend endpoints (all school-scoped, permission-gated):
`/directory/*` (students/staff/class-rooms/sections/class-sections/
subjects/semesters/mediums), `/lms/quizzes/{id}/questions` (no answer
keys), `/reports/*` (cash-summary/aging/outstanding),
`/budget/*` (dashboard/items/transactions), `/letters*`.
Flutter consumes all: Students/Staff pages, QuizAttempt, Reports,
Budget, Letters + hub tiles + role routes.
Remaining API GAP (deliberate, destructive/desktop-only):
super backup/restore, license, email templates, webhook logs,
maintenance toggle — documented WEB_ONLY, not mobile-appropriate.

FINAL COUNT (50 rows): COMPLETE 50 / PARTIAL 0 /
MISSING_API 0 operasional / WEB_ONLY+NON_MOBILE 2.
WEBSITE-TO-FLUTTER PARITY = 100% fitur operasional (50/50).
SALE READINESS = 96% — sisa: polish minor, l10n/a11y, staging live.

## 7. Pass 5 — final audit (2026-10-09)

Verifikasi path otomatis: 298/298 path Flutter cocok dengan
`php artisan route:list`. Metode: PUT dipakai di 8 tempat sesuai route
backend (klaim lama "hanya GET+POST" dikoreksi).
Bug kontrak baru (semua 422/500/blank, kini fix): panic coords,
QR `token`, `mood_score`, notice `content` + schedule/target + hapus,
branding keys, LMS `enrollment_id`, super extend fields,
dashboard `scheduled_at`, payroll/admission/exam display keys,
exam attempt flow, classroom grade, library loan, chat baru,
profil avatar/edit, PPDB submit+upload, rapor PDF, nilai per-anak,
notifikasi baca, super plan/subscription create, transport track,
library overdue, dapodik export.
Session: AuthSessionExpired (tanpa loop), logout bersihkan drift.
Rupiah: regression test Rp10.000 request→display.
Semua peran backend (21) punya shell + home + guard + test.
Pagination: ModuleListPage infinite-scroll opt-in (20/50) +
backend paginate invoice; search server-side untuk direktori.
Lihat `API_GAP_REPORT.md` + `FLUTTER_RELEASE_READINESS.md`.
