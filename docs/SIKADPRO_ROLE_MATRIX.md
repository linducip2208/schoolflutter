# Role-Workflow Matrix — 21 Backend Roles

Sumber: `RolePermissionSeeder` + controller gates + `homeForRole` +
`role_routing_test` (8 tes). Aturan: Flutter guard = UX saja;
server memvalidasi semua (`requirePermission`/middleware + scope).

| Role | Home | Shell/tabs | Aksi kunci terverifikasi | Dilarang (server) |
|---|---|---|---|---|
| super_admin | /super/dashboard | Dashboard,Sekolah,Profil + Paket/Analitik/Sistem | semua (bypass) | — |
| admin | /admin/dashboard | Dashboard,Admisi,Keuangan,Menu(50+),Profil | bulk fees/payroll/verify/RPP/bank | lintas tenant |
| school_admin | /schoolops/canteen | Kantin,Tamu,Dapodik,Profil | merchant/visitor/dapodik | modul akademik |
| teacher/homeroom | /teacher/dashboard | Beranda,Absensi,Kelas,Ujian,Menu,Profil | absensi/nilai/RPP/bank/grade | data sekolah lain |
| student | /student/dashboard | Beranda,Jadwal,Kelas,Chat,Menu,Profil | attempt/quiz/LMS milik sendiri | nilai orang, kunci soal |
| parent | /parent/dashboard | Beranda,Nilai,Kehadiran,Tagihan,Menu,Profil | hanya anak ter-relasi | anak lain (403/404) |
| accountant | /accountant/fees | Tagihan,Payroll,Laporan,Anggaran,Donasi,Profil | accounting.* | akademik |
| principal | /principal/dashboard | Dashboard,Keuangan,Laporan,Anggaran,Chat,Profil | view+approve-level | manage operasional |
| librarian | /librarian/library | Katalog,Notifikasi,Profil | library.* | lainnya |
| nurse | /nurse/visits | UKS,Notifikasi,Profil | medical.* | lainnya |
| counselor | /counselor/counseling | Konseling,Disiplin,Profil | counseling/discipline | lainnya |
| receptionist | /frontdesk/visitor | Tamu,Admisi,PPDB,Profil | visitor/admission/ppdb | keuangan |
| hr | /hr/payroll | Payroll,Notifikasi,Profil | payroll.* | lainnya |
| transport_admin | /transport-ops/manage | Transport,Notifikasi,Profil | transport.* | lainnya |
| hostel_admin | /hostel-ops/home | Asrama,Profil | hostel.* | lainnya |
| procurement_admin | /procurement/inventory | Inventaris,Profil | inventory.* | lainnya |
| driver/security | /gate/scan | Scan,Darurat,Profil | gate.scan | manage |
| visitor_operator | /visitor-ops/home | Tamu,Profil | visitor.* | lainnya |
| foundation_admin | /foundation/home | Yayasan,Profil | foundation.view | sekolah lain di luar yayasan |
| (unknown) | /staff/dashboard | placeholder jujur | — | semua spesifik |

Bukti login/landing per role: backend seeder akun demo + redirect
`homeForRole`; guard diuji statis. Live multi-role: NOT RUN (butuh
staging + kredensial per role; pola backend TenantIsolationTest ada).
