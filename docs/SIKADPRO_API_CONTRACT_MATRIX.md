# API Contract Matrix — Flutter vs Laravel

Verifikasi otomatis: 298 path Flutter vs `php artisan route:list` →
COCOK SEMUA (script `tool` + Pest route-wired 12/12).
Body/envelope/permission: baca per controller (detail di
SIKADPRO_API_CONTRACT_AUDIT.md). Metode Flutter: GET/POST/PUT/DELETE
mengikuti route backend (bukan hanya GET+POST).

| Grup endpoint | Jml | Metode | Status |
|---|---|---|---|
| Auth (login/2FA/logout/profile/avatar/password/FCM) | 10 | POST+PUT | VERIFIED (incl. 401-expiry) |
| Devices, uploads, school, branding | 8 | POST/GET/PUT | VERIFIED |
| Dashboard ×4 + super | 12 | GET | VERIFIED (keys cocok) |
| Academic years/holidays | 2 | GET/POST | VERIFIED |
| Attendance (+lock/reopen/corrections) | 9 | GET/POST | VERIFIED (enum cocok) |
| Timetable views | 4 | GET | VERIFIED |
| Classroom (+assign/grade) | 8 | GET/POST | VERIFIED |
| Exam (+manage/submissions) | 5 | GET/POST/DELETE | VERIFIED (kunci hidden) |
| Question bank | 3 | GET/POST | VERIFIED |
| Lesson plan | 7 | GET/POST | VERIFIED |
| Curriculum | 4 | GET/POST | VERIFIED |
| Marks (+bulk/grade/rapor/PDF) | 6 | GET/POST | VERIFIED |
| Admission (+status/enroll) | 4 | GET/POST/PUT | VERIFIED (enum cocok) |
| Fees (+generate/pay) | 6 | GET/POST | VERIFIED (rupiah) |
| Payroll (+generate/markPaid) | 3 | GET/POST | VERIFIED (rupiah, fixed-vs-%) |
| Library (+issue/return/overdue) | 8 | GET/POST | VERIFIED (user_id) |
| Hostel (+rooms/allocate) | 3 | GET/POST | VERIFIED |
| Transport (+assign/trips/track) | 7 | GET/POST | VERIFIED |
| Notice (+target/schedule) | 1 | GET/POST/DELETE | VERIFIED (`content`) |
| Chat (+start/send) | 4 | GET/POST | VERIFIED (recipient_id, idempotent) |
| Notifications | 4 | GET/POST | VERIFIED |
| Parent portal + children 7-tab | 4 | GET | VERIFIED (relasi) |
| Payments + providers BYOK | 9 | GET/POST | VERIFIED |
| PPDB publik + admin + upload | 5 | GET/POST | VERIFIED (jalur enum, file) |
| Bus/gate/medical parent | 4 | GET/POST | VERIFIED |
| Hafalan/ibadah + target | 4 | GET/POST | VERIFIED |
| Canteen + merchant | 8 | GET/POST/PUT | VERIFIED (rupiah, status enum) |
| AI tools + admin provider | 7 | GET/POST/DELETE | VERIFIED (`messages`) |
| Live class | 4 | GET/POST | VERIFIED |
| Daily report + admin | 2 | GET/POST | VERIFIED (`date?` saja) |
| Events + RSVP + iCal | 3 | GET/POST | VERIFIED |
| LMS + quiz attempt | 9 | GET/POST | VERIFIED (tanpa kunci, enrollment) |
| Donations + publik | 3 | GET/POST | VERIFIED (min:100=Rp100) |
| Achievements/scholarship/career/alumni/ekskul | 12 | GET/POST | VERIFIED |
| Inventory/visitors/dapodik | 16 | GET/POST | VERIFIED (file CSV) |
| Medical/discipline/counseling | 11 | GET/POST | VERIFIED |
| Risk/foundation/import-export/sync/emergency/QR | 12 | GET/POST | VERIFIED (GPS required) |
| Directory/reports/budget/letters | 17 | GET/POST/PUT | VERIFIED (baru + test) |
| Super plans/subs/analytics/system | 13 | GET/POST/PUT | VERIFIED (rupiah) |

Total grup: 90. MISMATCH: 0 (semua temuan sudah diperbaiki dan
diuji). Destruktif dibatasi: delete hanya exam/notice (konfirmasi UI);
provider/method destroy TIDAK diekspos (sengaja).
