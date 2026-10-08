# SikadPro Product Gaps (2026-10-09)

Source of truth: `https://sikadpro.whitelabel.co.id/` vs
`D:\project laravel\eschool\routes\api.php` vs
`D:\project flutter\eschool\lib`.

## PRODUCT GAP (website advertises, Laravel has no usable functionality)

None structural — every marketed module has a backend model/service.
Gaps below are API-surface gaps, not missing product logic.

## API GAP (Laravel logic exists, mobile API route missing)

1. Student database CRUD — only `/import/students` + admission enroll.
   Mobile cannot list/search/manage students.
2. Class & rombel CRUD — only academic-years/holidays exposed.
3. RKAS / budgeting (`BudgetController` web-only).
4. Financial reports / accounting (`AccountingService` web-only).
5. Surat-menyurat (`DocumentController` web-only).
6. Marks bulk-input / report-card generate+publish for admin UI
   (routes exist: `/marks/bulk`, `/report-cards/generate|publish` —
   usable, listed here only because no Flutter UI consumes them yet).

## FLUTTER GAP (API exists, Flutter UI missing) — priority order

P1 (admin daily use): PPDB verify/accept, exam/bank-soal mgmt,
marks bulk input, LMS pages, emergency button, ekskul list,
events list, scholarships, achievements, inventory, visitors,
canteen merchant view, transport admin trips, daily-report generate,
finance provider CRUD, payroll generate/mark-paid, Dapodik sync,
dropout-risk + analytics views, foundation (yayasan) dashboard,
lesson-plan, live-class schedule/join UI, essay grader,
medical record mgmt, discipline records, counseling sessions list,
bullying reports, alumni, donations, career, calendar feed render.

P2 (role shells): dedicated accountant/librarian/nurse/counselor/
principal/receptionist navigation (currently staff placeholder).

## Implemented this pass (no fake menus — all wired to real endpoints)

- super_admin shell + dashboard + schools (API `/super/*`).
- Admin module hub: Absensi, Kelas Online, Perpustakaan, Asrama,
  Transport, Pengumuman, Payroll, Chat, Notifikasi, Profil —
  every tile opens an existing working screen via `/admin/*` aliases
  (new) or shared routes.
- Deliberately NOT added: Jadwal/Ujian/Nilai for admin (repos call
  student/teacher-scoped endpoints — would 403/empty), student-context
  pages (klinik/kantin/hafalan need picker), Alumni/Donasi/Karier
  (no Flutter repo/page yet).
