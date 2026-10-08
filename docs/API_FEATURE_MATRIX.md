# API Feature Matrix — Flutter vs Laravel

Backend: `D:\project laravel\eschool\routes\api.php` (`/api/v1`)
Flutter: `lib/core/api/api_endpoints.dart` + `lib/features/*/data/*_repository.dart`

| Feature | Laravel endpoint | Flutter screen | Role | Offline | Status | Tests |
|---|---|---|---|---|---|---|
| Login | POST /auth/login | login_page | all | no | ✅ | bloc_test |
| 2FA verify | POST /auth/2fa/verify | two_factor_page | all | no | ✅ | bloc_test |
| Logout | POST /auth/logout | profile_page | all | no | ✅ | bloc_test |
| Me | GET /auth/me | profile (repo) | all | cache | ✅ | — |
| Update profile | PUT /auth/profile | profile_repository | all | no | ✅ new | — |
| Avatar | POST /auth/avatar | upload_repository | all | no | ✅ | — |
| Change password | POST /auth/change-password | profile_page | all | no | ✅ | — |
| Forgot/reset | POST /auth/forgot-password | forgot_password_page | guest | no | ✅ | widget |
| FCM register | POST /devices/register | fcm_service | all | no | ✅ | — |
| FCM unregister | POST /devices/unregister | fcm_service/logout | all | no | ✅ | — |
| Uploads | POST /uploads | upload_repository | all | no | ✅ | — |
| Dashboard student | GET /dashboard/student | student_dashboard | student | snapshot | ✅ | bloc_test |
| Dashboard teacher | GET /dashboard/teacher | teacher_dashboard | teacher | snapshot | ✅ | bloc_test |
| Dashboard parent | GET /dashboard/parent | parent_dashboard | parent | snapshot | ✅ | bloc_test |
| Dashboard admin | GET /dashboard/admin | admin_dashboard | admin | snapshot | ✅ | bloc_test |
| Attendance me | GET /attendance/me | student_attendance | student | 6h cache | ✅ | sync_test |
| Attendance class | GET+POST /attendance/class/{id} | teacher_attendance | teacher | outbox | ✅ | sync_test |
| Attendance summary | GET /attendance/summary/{id} | marks/attendance | all | cache | ✅ | — |
| QR scan | POST /qr/scan | emergency_repository | teacher | no | ✅ new | — |
| Timetable my | GET /timetable/my | timetable_page | teacher | 6h cache | ✅ | — |
| Timetable student | GET /timetable/student/my | timetable_page | student | 6h cache | ✅ | — |
| Lessons | GET /classroom/lessons | classroom_page | all | cache | ✅ | — |
| Assignments | GET /classroom/assignments | classroom_page | all | cache | ✅ | — |
| Submit assignment | POST .../submit | classroom_repo | student | outbox | ✅ | — |
| Exams | GET /exams | exam_list | all | cache | ✅ | — |
| Exam start/submit/result | GET+POST /exams/{id}/* | exam_repo | student | no | ✅ | — |
| Marks me | GET /marks/me | marks_page | student | cache | ✅ | — |
| Report card | GET /report-cards/student/{id} | marks_repo | all | cache | ✅ | — |
| Report PDF | GET /report-cards/{id}/pdf | marks_repo | all | download | ✅ | — |
| Admission | GET /admission | admission_page | admin | no | ✅ refactored | — |
| Fees mine | GET /fee/invoices/me | student_fees | student/parent | cache | ✅ | — |
| Fees all | GET /fee/invoices | admin_fees | admin | no | ✅ | — |
| Payment link/pay | GET /fee/invoices/{id}/* | fees_repo | parent | no | ✅ | — |
| Payments methods | GET /payments/methods | payment_methods | parent | no | ✅ | — |
| Payments initiate | POST /payments/initiate | payment_repo | parent | idempotent | ✅ | — |
| Payroll slips | GET /payroll/slips | payroll_page | staff | no | ✅ refactored | — |
| Library books | GET /library/books | library_page | all | cache | ✅ | — |
| Library issue/return | POST /library/issue, /return/{id} | library_repo | librarian | outbox | ✅ | — |
| Hostel | GET /hostel | hostel_page | admin | no | ✅ | — |
| Transport routes | GET /transport/routes | transport_page | admin | no | ✅ | — |
| Notices | GET /notices | notice_list | all | cache | ✅ | — |
| Chat list | GET /chat/conversations | chat_list | all | cache | ✅ | — |
| Chat send | POST .../send (Idempotency-Key) | chat_repo | all | outbox | ✅ | — |
| Notifications | GET /notifications (20/pg) | notifications_page | all | cache | ✅ new repo | — |
| Children | GET /parent/children | parent_dashboard | parent | cache | ✅ | — |
| Child attendance/marks/invoices | GET /parent/children/{id}/* | parent pages | parent | cache | ✅ | — |
| Bus location | GET .../bus-location | bus_tracking_page | parent | live | ✅ new repo | — |
| Gate events | GET .../gate-events | bus_tracking | parent | cache | ✅ | — |
| Daily reports | GET .../daily-reports | daily_report_viewer | parent | cache | ✅ new repo | — |
| Clinic visits | GET /medical/students/{id}/visits | clinic_visits | parent/nurse | cache | ✅ new repo | — |
| Wellness checkin | POST /wellness/checkin | wellness_checkin | teacher | outbox | ✅ new repo | — |
| Hafalan record | POST /religious/hafalan | hafalan_input | teacher | outbox | ✅ refactored | — |
| Canteen menu/wallet/order | GET /canteen/menu, ... | canteen_menu | student | cache | ✅ refactored | — |
| AI assistant | POST /ai/study-assistant | study_assistant | student | no | ✅ new repo | — |
| Live class join | POST /live-class/sessions/{id}/join | classroom | all | no | ✅ | — |
| PPDB periods/register | GET+POST /public/ppdb/{sub}/* | ppdb_register | guest | no | ✅ new repo | — |
| Events / RSVP | GET /events, POST /events/{id}/rsvp | events | all | no | ✅ | — |
| LMS courses | GET /lms/courses | lms_repository | student | cache | ✅ new | — |
| LMS enroll/progress | POST /lms/enroll, GET /lms/progress | lms_repo | student | no | ✅ new | — |
| Sync batch | POST /sync/batch (200 max) | sync_engine.flushBatch | all | outbox | ✅ new | sync_test |
| Emergency panic | POST /emergency/panic | emergency_repo | all | no | ✅ new | — |

Notes:
- No fake data; all screens backend-driven with loading/empty/error/retry.
- Money IDR integer whole rupiah (no /100) — locked by test.
- Dates id_ID, Asia/Jakarta (backend).
