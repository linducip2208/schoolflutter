import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/two_factor_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/attendance/presentation/pages/student_attendance_page.dart';
import '../../features/attendance/presentation/pages/teacher_attendance_page.dart';
import '../../features/chat/presentation/pages/chat_conversation_page.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/classroom/presentation/pages/classroom_page.dart';
import '../../features/dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/parent_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/staff_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/student_dashboard_page.dart';
import '../../features/dashboard/presentation/pages/teacher_dashboard_page.dart';
import '../../features/exam/presentation/pages/exam_list_page.dart';
import '../../features/fees/presentation/pages/admin_fees_page.dart';
import '../../features/fees/presentation/pages/student_fees_page.dart';
import '../../features/hostel/presentation/pages/hostel_page.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/transport/presentation/pages/transport_page.dart';
import '../../features/marks/presentation/pages/marks_page.dart';
import '../../features/notice/presentation/pages/admin_notice_page.dart';
import '../../features/notice/presentation/pages/notice_list_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/about_page.dart';
import '../../features/payroll/presentation/pages/payroll_page.dart';
import '../../features/admission/presentation/pages/admission_page.dart';
import '../../features/timetable/presentation/pages/timetable_page.dart';
// Phase 8-11
import '../../features/ppdb/presentation/pages/ppdb_register_page.dart';
import '../../features/bus_tracking/presentation/pages/bus_tracking_page.dart';
import '../../features/medical/presentation/pages/clinic_visits_page.dart';
import '../../features/counseling/presentation/pages/wellness_checkin_page.dart';
import '../../features/ai_assistant/presentation/pages/study_assistant_page.dart';
import '../../features/hafalan/presentation/pages/hafalan_input_page.dart';
import '../../features/canteen/presentation/pages/canteen_menu_page.dart';
import '../../features/daily_report/presentation/pages/daily_report_viewer_page.dart';
import '../../features/superadmin/presentation/pages/super_dashboard_page.dart';
import '../../features/superadmin/presentation/pages/super_schools_page.dart';
import '../../features/superadmin/presentation/pages/super_plans_page.dart';
import '../../features/superadmin/presentation/pages/super_analytics_page.dart';
import '../../features/superadmin/presentation/pages/super_system_page.dart';
import '../../features/exam/presentation/pages/exam_manage_page.dart';
import '../../features/exam/presentation/pages/question_bank_page.dart';
import '../../features/lessonplan/presentation/pages/lessonplan_page.dart';
import '../../features/curriculum/presentation/pages/curriculum_page.dart';
import '../../features/marks/presentation/pages/marks_bulk_page.dart';
import '../../features/academic/presentation/pages/academic_years_page.dart';
import '../../features/ppdb/presentation/pages/ppdb_verify_page.dart';
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/events/presentation/pages/calendar_page.dart';
import '../../features/donations/presentation/pages/donations_page.dart';
import '../../features/achievements/presentation/pages/achievements_page.dart';
import '../../features/scholarships/presentation/pages/scholarships_page.dart';
import '../../features/career/presentation/pages/career_page.dart';
import '../../features/ekskul/presentation/pages/ekskul_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/visitors/presentation/pages/visitors_page.dart';
import '../../features/canteen/presentation/pages/canteen_merchant_page.dart';
import '../../features/transport/presentation/pages/transport_admin_page.dart';
import '../../features/dapodik/presentation/pages/dapodik_page.dart';
import '../../features/medical/presentation/pages/medical_manage_page.dart';
import '../../features/discipline/presentation/pages/discipline_page.dart';
import '../../features/counseling/presentation/pages/counseling_page.dart';
import '../../features/counseling/presentation/pages/bullying_report_page.dart';
import '../../features/bus_tracking/presentation/pages/idgate_page.dart';
import '../../features/liveclass/presentation/pages/liveclass_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_tools_page.dart';
import '../../features/ai_assistant/presentation/pages/ai_providers_page.dart';
import '../../features/payment/presentation/pages/payment_providers_page.dart';
import '../../features/branding/presentation/pages/branding_page.dart';
import '../../features/importexport/presentation/pages/import_export_page.dart';
import '../../features/analytics/presentation/pages/risk_analytics_page.dart';
import '../../features/foundation/presentation/pages/foundation_page.dart';
import '../../features/daily_report/presentation/pages/daily_report_admin_page.dart';
import '../../features/alumni/presentation/pages/alumni_page.dart';
import '../../features/lms/presentation/pages/lms_courses_page.dart';
import '../../features/emergency/presentation/pages/emergency_page.dart';
import '../../features/fees/presentation/pages/finance_tools_page.dart';
import '../../features/parent/presentation/pages/children_list_page.dart';
import '../../features/attendance/presentation/pages/attendance_tools_page.dart';
import '../../features/hafalan/presentation/pages/hafalan_targets_page.dart';
import '../../features/gate/presentation/pages/qr_scan_page.dart';
import '../../features/directory/presentation/pages/students_page.dart';
import '../../features/directory/presentation/pages/staff_page.dart';
import '../../features/finance/presentation/pages/reports_page.dart';
import '../../features/finance/presentation/pages/budget_page.dart';
import '../../features/letters/presentation/pages/letters_page.dart';
import '../../features/lms/presentation/pages/quizzes_page.dart';
import '../../shells/teacher_menu_page.dart';
import '../../shells/role_shells.dart';
import '../../shells/student_menu_page.dart';
import '../../shells/parent_menu_page.dart';
import '../../shells/admin_menu_page.dart';
import '../../shells/admin_shell.dart';
import '../../shells/super_admin_shell.dart';
import '../../shells/parent_shell.dart';
import '../../shells/staff_shell.dart';
import '../../shells/student_shell.dart';
import '../../shells/teacher_shell.dart';
import 'routes.dart';

class AppRouter {
  AppRouter._(this._authBloc)
      : _rootNavigatorKey = GlobalKey<NavigatorState>() {
    config = _build();
  }

  static AppRouter? _instance;
  static AppRouter of(BuildContext context) {
    _instance ??= AppRouter._(context.read<AuthBloc>());
    return _instance!;
  }

  static AppRouter? get maybeInstance => _instance;

  final AuthBloc _authBloc;
  final GlobalKey<NavigatorState> _rootNavigatorKey;
  late final GoRouter config;

  GoRouter get router => config;

  GoRouter _build() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.splash,
      refreshListenable: _AuthListenable(_authBloc),
      redirect: _redirect,
      routes: <RouteBase>[
        GoRoute(
          path: Routes.splash,
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: Routes.twoFactor,
          builder: (_, __) => const TwoFactorPage(),
        ),
        GoRoute(
          path: Routes.forgotPassword,
          builder: (_, __) => const ForgotPasswordPage(),
        ),

        // ── Student
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              StudentShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(
                path: Routes.studentDashboard,
                builder: (_, __) => const StudentDashboardPage()),
            GoRoute(
                path: Routes.studentTimetable,
                builder: (_, __) => const TimetablePage()),
            GoRoute(
                path: Routes.studentClassroom,
                builder: (_, __) => const ClassroomPage()),
            GoRoute(
                path: Routes.studentAttendance,
                builder: (_, __) => const StudentAttendancePage()),
            GoRoute(
                path: Routes.studentExam,
                builder: (_, __) => const ExamListPage()),
            GoRoute(
                path: Routes.studentMarks,
                builder: (_, __) => const MarksPage()),
            GoRoute(
                path: Routes.studentFees,
                builder: (_, __) => const StudentFeesPage()),
            GoRoute(
                path: Routes.studentLibrary,
                builder: (_, __) => const LibraryPage()),
            GoRoute(
                path: Routes.studentChat,
                builder: (_, __) => const ChatListPage()),
            GoRoute(
                path: Routes.studentProfile,
                builder: (_, __) => const ProfilePage()),
            GoRoute(
                path: Routes.studentMenu,
                builder: (_, __) => const StudentMenuPage()),
            GoRoute(
                path: Routes.studentEkskul,
                builder: (_, __) => const EkskulPage()),
            GoRoute(
                path: Routes.studentEvent,
                builder: (_, __) => const EventsPage()),
            GoRoute(
                path: Routes.studentBeasiswa,
                builder: (_, __) => const ScholarshipsPage()),
            GoRoute(
                path: Routes.studentKarier,
                builder: (_, __) => const CareerPage()),
            GoRoute(
                path: Routes.studentPrestasi,
                builder: (_, __) => const AchievementsPage()),
            GoRoute(
                path: Routes.studentLms,
                builder: (_, __) => const LmsCoursesPage()),
            GoRoute(
                path: Routes.studentLive,
                builder: (_, __) => const LiveClassPage()),
            GoRoute(
                path: Routes.studentAi,
                builder: (_, __) => const AiToolsPage()),
            GoRoute(
                path: Routes.studentEmergency,
                builder: (_, __) => const EmergencyPage()),
            GoRoute(
                path: Routes.studentBullying,
                builder: (_, __) => const BullyingReportPage()),
            GoRoute(
                path: Routes.studentCalendar,
                builder: (_, __) => const CalendarPage()),
            GoRoute(
                path: Routes.studentQuizzes,
                builder: (_, __) => const QuizzesPage()),
            GoRoute(
              path: Routes.studentBus,
              builder: (_, GoRouterState s) => BusTrackingPage(
                studentId: int.parse(s.pathParameters['studentId']!),
                studentName: s.uri.queryParameters['name'] ?? 'Saya',
              ),
            ),
          ],
        ),

        // ── Parent
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              ParentShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(
                path: Routes.parentDashboard,
                builder: (_, __) => const ParentDashboardPage()),
            GoRoute(
                path: Routes.parentMarks,
                builder: (_, __) => const MarksPage()),
            GoRoute(
                path: Routes.parentAttendance,
                builder: (_, __) => const StudentAttendancePage()),
            GoRoute(
                path: Routes.parentFees,
                builder: (_, __) => const StudentFeesPage()),
            GoRoute(
                path: Routes.parentChat,
                builder: (_, __) => const ChatListPage()),
            GoRoute(
                path: Routes.parentProfile,
                builder: (_, __) => const ProfilePage()),
            GoRoute(
                path: Routes.parentMenu,
                builder: (_, __) => const ParentMenuPage()),
            GoRoute(
                path: Routes.parentChildren,
                builder: (_, __) => const ChildrenListPage()),
            GoRoute(
                path: Routes.parentEvent,
                builder: (_, __) => const EventsPage()),
            GoRoute(
                path: Routes.parentDonasi,
                builder: (_, __) => const DonationsPage()),
            GoRoute(
                path: Routes.parentBullying,
                builder: (_, __) => const BullyingReportPage()),
            GoRoute(
                path: Routes.parentEmergency,
                builder: (_, __) => const EmergencyPage()),
          ],
        ),

        // ── Teacher
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              TeacherShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(
                path: Routes.teacherDashboard,
                builder: (_, __) => const TeacherDashboardPage()),
            GoRoute(
                path: Routes.teacherAttendance,
                builder: (_, __) => const TeacherAttendancePage()),
            GoRoute(
                path: Routes.teacherClassroom,
                builder: (_, __) => const ClassroomPage()),
            GoRoute(
                path: Routes.teacherExam,
                builder: (_, __) => const ExamListPage()),
            GoRoute(
                path: Routes.teacherChat,
                builder: (_, __) => const ChatListPage()),
            GoRoute(
                path: Routes.teacherProfile,
                builder: (_, __) => const ProfilePage()),
            GoRoute(
                path: Routes.teacherMenu,
                builder: (_, __) => const TeacherMenuPage()),
            GoRoute(
                path: Routes.teacherRpp,
                builder: (_, __) => const LessonPlanPage()),
            GoRoute(
                path: Routes.teacherBankSoal,
                builder: (_, __) => const QuestionBankPage()),
            GoRoute(
                path: Routes.teacherNilai,
                builder: (_, __) => const MarksBulkPage()),
            GoRoute(
                path: Routes.teacherLive,
                builder: (_, __) => const LiveClassPage()),
            GoRoute(
                path: Routes.teacherAi,
                builder: (_, __) => const AiToolsPage()),
            GoRoute(
                path: Routes.teacherKurikulum,
                builder: (_, __) => const CurriculumPage()),
            GoRoute(
                path: Routes.teacherDisiplin,
                builder: (_, __) => const DisciplinePage()),
            GoRoute(
                path: Routes.teacherPrestasi,
                builder: (_, __) => const AchievementsPage()),
            GoRoute(
                path: Routes.teacherEmergency,
                builder: (_, __) => const EmergencyPage()),
            GoRoute(
                path: Routes.teacherBullying,
                builder: (_, __) => const BullyingReportPage()),
            GoRoute(
                path: Routes.teacherAttendanceTools,
                builder: (_, __) => const AttendanceToolsPage()),
            GoRoute(
                path: Routes.teacherHafalanTargets,
                builder: (_, __) => const HafalanTargetsPage()),
            GoRoute(
                path: Routes.teacherQuizzes,
                builder: (_, __) => const QuizzesPage()),
          ],
        ),

        // ── Admin
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              AdminShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(
                path: Routes.adminDashboard,
                builder: (_, __) => const AdminDashboardPage()),
            GoRoute(
                path: Routes.adminAdmissions,
                builder: (_, __) => const AdmissionPage()),
            GoRoute(
                path: Routes.adminFees,
                builder: (_, __) => const AdminFeesPage()),
            GoRoute(
                path: Routes.adminPayroll,
                builder: (_, __) => const PayrollPage()),
            GoRoute(
                path: Routes.adminNotice,
                builder: (_, __) => const AdminNoticePage()),
            GoRoute(
                path: Routes.adminProfile,
                builder: (_, __) => const ProfilePage()),
            // Admin module hub + role-agnostic working-screen aliases.
            GoRoute(
                path: Routes.adminMenu,
                builder: (_, __) => const AdminMenuPage()),
            GoRoute(
                path: Routes.adminAttendance,
                builder: (_, __) => const TeacherAttendancePage()),
            GoRoute(
                path: Routes.adminClassroom,
                builder: (_, __) => const ClassroomPage()),
            GoRoute(
                path: Routes.adminLibrary,
                builder: (_, __) => const LibraryPage()),
            GoRoute(
                path: Routes.adminChat,
                builder: (_, __) => const ChatListPage()),
            GoRoute(
                path: Routes.adminPpdb,
                builder: (_, __) => const PpdbVerifyPage()),
            GoRoute(
                path: Routes.adminTahunAjaran,
                builder: (_, __) => const AcademicYearsPage()),
            GoRoute(
                path: Routes.adminExamManage,
                builder: (_, __) => const ExamManagePage()),
            GoRoute(
                path: Routes.adminBankSoal,
                builder: (_, __) => const QuestionBankPage()),
            GoRoute(
                path: Routes.adminRpp,
                builder: (_, __) => const LessonPlanPage()),
            GoRoute(
                path: Routes.adminKurikulum,
                builder: (_, __) => const CurriculumPage()),
            GoRoute(
                path: Routes.adminNilaiBatch,
                builder: (_, __) => const MarksBulkPage()),
            GoRoute(
                path: Routes.adminEvent,
                builder: (_, __) => const EventsPage()),
            GoRoute(
                path: Routes.adminDonasi,
                builder: (_, __) => const DonationsPage()),
            GoRoute(
                path: Routes.adminPrestasi,
                builder: (_, __) => const AchievementsPage()),
            GoRoute(
                path: Routes.adminBeasiswa,
                builder: (_, __) => const ScholarshipsPage()),
            GoRoute(
                path: Routes.adminKarier,
                builder: (_, __) => const CareerPage()),
            GoRoute(
                path: Routes.adminEkskul,
                builder: (_, __) => const EkskulPage()),
            GoRoute(
                path: Routes.adminInventaris,
                builder: (_, __) => const InventoryPage()),
            GoRoute(
                path: Routes.adminVisitor,
                builder: (_, __) => const VisitorsPage()),
            GoRoute(
                path: Routes.adminKantin,
                builder: (_, __) => const CanteenMerchantPage()),
            GoRoute(
                path: Routes.adminTransportManage,
                builder: (_, __) => const TransportAdminPage()),
            GoRoute(
                path: Routes.adminDapodik,
                builder: (_, __) => const DapodikPage()),
            GoRoute(
                path: Routes.adminMedis,
                builder: (_, __) => const MedicalManagePage()),
            GoRoute(
                path: Routes.adminDisiplin,
                builder: (_, __) => const DisciplinePage()),
            GoRoute(
                path: Routes.adminKonseling,
                builder: (_, __) => const CounselingPage()),
            GoRoute(
                path: Routes.adminGate,
                builder: (_, __) => const IdGatePage()),
            GoRoute(
                path: Routes.adminLive,
                builder: (_, __) => const LiveClassPage()),
            GoRoute(
                path: Routes.adminAiTools,
                builder: (_, __) => const AiToolsPage()),
            GoRoute(
                path: Routes.adminAiProvider,
                builder: (_, __) => const AiProvidersPage()),
            GoRoute(
                path: Routes.adminPayProvider,
                builder: (_, __) => const PaymentProvidersPage()),
            GoRoute(
                path: Routes.adminBranding,
                builder: (_, __) => const BrandingPage()),
            GoRoute(
                path: Routes.adminImportExport,
                builder: (_, __) => const ImportExportPage()),
            GoRoute(
                path: Routes.adminRisiko,
                builder: (_, __) => const RiskAnalyticsPage()),
            GoRoute(
                path: Routes.adminYayasan,
                builder: (_, __) => const FoundationPage()),
            GoRoute(
                path: Routes.adminLaporanHarian,
                builder: (_, __) => const DailyReportAdminPage()),
            GoRoute(
                path: Routes.adminAlumni,
                builder: (_, __) => const AlumniPage()),
            GoRoute(
                path: Routes.adminLms,
                builder: (_, __) => const LmsCoursesPage()),
            GoRoute(
                path: Routes.adminEmergency,
                builder: (_, __) => const EmergencyPage()),
            GoRoute(
                path: Routes.adminCalendar,
                builder: (_, __) => const CalendarPage()),
            GoRoute(
                path: Routes.adminFinanceTools,
                builder: (_, __) => const FinanceToolsPage()),
            GoRoute(
                path: Routes.adminAttendanceTools,
                builder: (_, __) => const AttendanceToolsPage()),
            GoRoute(
                path: Routes.adminHafalanTargets,
                builder: (_, __) => const HafalanTargetsPage()),
            GoRoute(
                path: Routes.adminStudents,
                builder: (_, __) => const StudentsPage()),
            GoRoute(
                path: Routes.adminStaff,
                builder: (_, __) => const StaffPage()),
            GoRoute(
                path: Routes.adminReports,
                builder: (_, __) => const ReportsPage()),
            GoRoute(
                path: Routes.adminBudget,
                builder: (_, __) => const BudgetPage()),
            GoRoute(
                path: Routes.adminLetters,
                builder: (_, __) => const LettersPage()),
            GoRoute(
                path: Routes.adminQuizzes,
                builder: (_, __) => const QuizzesPage()),
          ],
        ),

        // ── Super Admin (platform operator)
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              SuperAdminShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(
                path: Routes.superDashboard,
                builder: (_, __) => const SuperDashboardPage()),
            GoRoute(
                path: Routes.superSchools,
                builder: (_, __) => const SuperSchoolsPage()),
            GoRoute(
                path: Routes.superProfile,
                builder: (_, __) => const ProfilePage()),
            GoRoute(
                path: Routes.superPlans,
                builder: (_, __) => const SuperPlansPage()),
            GoRoute(
                path: Routes.superAnalytics,
                builder: (_, __) => const SuperAnalyticsPage()),
            GoRoute(
                path: Routes.superSystem,
                builder: (_, __) => const SuperSystemPage()),
          ],
        ),

        // ── Role shells (non-core backend roles)
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              AccountantShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.accountantFees, builder: (_, __) => const AdminFeesPage()),
            GoRoute(path: Routes.accountantPayroll, builder: (_, __) => const PayrollPage()),
            GoRoute(path: Routes.accountantPayProvider, builder: (_, __) => const PaymentProvidersPage()),
            GoRoute(path: Routes.accountantDonasi, builder: (_, __) => const DonationsPage()),
            GoRoute(path: Routes.accountantReports, builder: (_, __) => const ReportsPage()),
            GoRoute(path: Routes.accountantBudget, builder: (_, __) => const BudgetPage()),
            GoRoute(path: Routes.accountantProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              LibrarianShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.librarianLibrary, builder: (_, __) => const LibraryPage()),
            GoRoute(path: Routes.librarianProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              NurseShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.nurseVisits, builder: (_, __) => const MedicalManagePage()),
            GoRoute(path: Routes.nurseProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              CounselorShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.counselorCounseling, builder: (_, __) => const CounselingPage()),
            GoRoute(path: Routes.counselorDiscipline, builder: (_, __) => const DisciplinePage()),
            GoRoute(path: Routes.counselorProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              PrincipalShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.principalDashboard, builder: (_, __) => const AdminDashboardPage()),
            GoRoute(path: Routes.principalFees, builder: (_, __) => const AdminFeesPage()),
            GoRoute(path: Routes.principalChat, builder: (_, __) => const ChatListPage()),
            GoRoute(path: Routes.principalReports, builder: (_, __) => const ReportsPage()),
            GoRoute(path: Routes.principalBudget, builder: (_, __) => const BudgetPage()),
            GoRoute(path: Routes.principalProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              FrontDeskShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.frontdeskVisitor, builder: (_, __) => const VisitorsPage()),
            GoRoute(path: Routes.frontdeskAdmission, builder: (_, __) => const AdmissionPage()),
            GoRoute(path: Routes.frontdeskPpdb, builder: (_, __) => const PpdbVerifyPage()),
            GoRoute(path: Routes.frontdeskProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              HrShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.hrPayroll, builder: (_, __) => const PayrollPage()),
            GoRoute(path: Routes.hrProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              TransportOpsShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.transportOpsManage, builder: (_, __) => const TransportAdminPage()),
            GoRoute(path: Routes.transportOpsProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              HostelOpsShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.hostelOpsHome, builder: (_, __) => const HostelPage()),
            GoRoute(path: Routes.hostelOpsProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              ProcurementShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.procurementInventory, builder: (_, __) => const InventoryPage()),
            GoRoute(path: Routes.procurementProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              GateShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.gateScan, builder: (_, __) => const QrScanPage()),
            GoRoute(path: Routes.gateEmergency, builder: (_, __) => const EmergencyPage()),
            GoRoute(path: Routes.gateProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              VisitorOpsShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.visitorOpsHome, builder: (_, __) => const VisitorsPage()),
            GoRoute(path: Routes.visitorOpsProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              SchoolOpsShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.schoolOpsCanteen, builder: (_, __) => const CanteenMerchantPage()),
            GoRoute(path: Routes.schoolOpsVisitor, builder: (_, __) => const VisitorsPage()),
            GoRoute(path: Routes.schoolOpsDapodik, builder: (_, __) => const DapodikPage()),
            GoRoute(path: Routes.schoolOpsProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              FoundationShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(path: Routes.foundationHome, builder: (_, __) => const FoundationPage()),
            GoRoute(path: Routes.foundationProfile, builder: (_, __) => const ProfilePage()),
          ],
        ),

        // ── Staff
        ShellRoute(
          builder: (BuildContext c, GoRouterState s, Widget child) =>
              StaffShell(location: s.uri.path, child: child),
          routes: <RouteBase>[
            GoRoute(
                path: Routes.staffDashboard,
                builder: (_, __) => const StaffDashboardPage()),
            GoRoute(
                path: Routes.staffProfile,
                builder: (_, __) => const ProfilePage()),
          ],
        ),

        // ── Common
        GoRoute(
            path: Routes.notice, builder: (_, __) => const NoticeListPage()),
        GoRoute(
            path: Routes.notifications,
            builder: (_, __) => const NotificationsPage()),
        GoRoute(
          path: Routes.chatConversation,
          builder: (BuildContext c, GoRouterState s) => ChatConversationPage(
            conversationId: int.parse(s.pathParameters['conversationId']!),
          ),
        ),
        GoRoute(path: Routes.hostel, builder: (_, __) => const HostelPage()),
        GoRoute(
            path: Routes.transport, builder: (_, __) => const TransportPage()),
        GoRoute(path: Routes.about, builder: (_, __) => const AboutPage()),

        // ===== Phase 8 — Student Lifecycle =====
        GoRoute(
          path: Routes.ppdbRegister,
          builder: (_, GoRouterState s) {
            final String subdomain =
                s.uri.queryParameters['subdomain'] ?? 'demo';
            return PpdbRegisterPage(subdomain: subdomain);
          },
        ),
        GoRoute(
          path: Routes.parentBusTracking,
          builder: (_, GoRouterState s) => BusTrackingPage(
            studentId: int.parse(s.pathParameters['studentId']!),
            studentName: s.uri.queryParameters['name'] ?? 'Anak',
          ),
        ),
        GoRoute(
          path: Routes.parentClinicVisits,
          builder: (_, GoRouterState s) => ClinicVisitsPage(
            studentId: int.parse(s.pathParameters['studentId']!),
            studentName: s.uri.queryParameters['name'] ?? 'Anak',
          ),
        ),
        GoRoute(
          path: Routes.wellnessCheckin,
          builder: (_, GoRouterState s) {
            final int? studentId =
                int.tryParse(s.uri.queryParameters['student_id'] ?? '');
            return WellnessCheckinPage(studentId: studentId ?? 0);
          },
        ),

        // ===== Phase 9 — Teaching Tools =====
        GoRoute(
            path: Routes.studyAssistant,
            builder: (_, __) => const StudyAssistantPage()),
        GoRoute(
          path: Routes.hafalanInput,
          builder: (_, GoRouterState s) {
            final int? studentId =
                int.tryParse(s.uri.queryParameters['student_id'] ?? '');
            return HafalanInputPage(studentId: studentId ?? 0);
          },
        ),
        GoRoute(
          path: Routes.canteenMenu,
          builder: (_, GoRouterState s) => CanteenMenuPage(
            studentId: int.parse(s.pathParameters['studentId']!),
          ),
        ),

        // ===== Phase 10 — Engagement =====
        GoRoute(
          path: Routes.parentDailyReport,
          builder: (_, GoRouterState s) => DailyReportViewerPage(
            studentId: int.parse(s.pathParameters['studentId']!),
            studentName: s.uri.queryParameters['name'] ?? 'Anak',
          ),
        ),
      ],
      errorBuilder: (BuildContext c, GoRouterState s) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Halaman tidak ditemukan:\n${s.uri}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    final AuthState s = _authBloc.state;
    final String loc = state.matchedLocation;

    if (s.status == AuthStatus.unknown) {
      return loc == Routes.splash ? null : Routes.splash;
    }
    final bool authed = s.status == AuthStatus.authenticated && s.user != null;
    final bool isPublic = loc == Routes.login ||
        loc == Routes.twoFactor ||
        loc == Routes.forgotPassword ||
        loc == Routes.splash;

    if (!authed && !isPublic) return Routes.login;
    if (authed && isPublic) return Routes.homeForRole(s.user!.role);
    if (authed && !isPublic) {
      // Role-based route guard: /student/*, /parent/*, /teacher/*,
      // /admin/*, /staff/* prefixes require the matching role.
      // Shared routes (notice, notifications, chat, hostel, ...) are open
      // to every authenticated user; the API enforces authorization.
      final String role = s.user!.role;
      final String? required = _roleForPrefix(loc);
      if (required != null && !_roleMatches(role, required)) {
        return Routes.homeForRole(role);
      }
    }
    return null;
  }

  /// Returns the role required by a path prefix, or null for shared routes.
  static String? _roleForPrefix(String loc) {
    if (loc.startsWith('/super/')) return 'super_admin';
    if (loc.startsWith('/student/')) return 'student';
    if (loc.startsWith('/parent/')) return 'parent';
    if (loc.startsWith('/teacher/')) return 'teacher';
    if (loc.startsWith('/admin/')) return 'admin';
    if (loc.startsWith('/staff/')) return 'staff';
    if (loc.startsWith('/accountant/')) return 'accountant';
    if (loc.startsWith('/librarian/')) return 'librarian';
    if (loc.startsWith('/nurse/')) return 'nurse';
    if (loc.startsWith('/counselor/')) return 'counselor';
    if (loc.startsWith('/principal/')) return 'principal';
    if (loc.startsWith('/frontdesk/')) return 'receptionist';
    if (loc.startsWith('/hr/')) return 'hr';
    if (loc.startsWith('/transport-ops/')) return 'transport_admin';
    if (loc.startsWith('/hostel-ops/')) return 'hostel_admin';
    if (loc.startsWith('/procurement/')) return 'procurement_admin';
    if (loc.startsWith('/gate/')) return 'gate_ops';
    if (loc.startsWith('/visitor-ops/')) return 'visitor_operator';
    if (loc.startsWith('/schoolops/')) return 'school_admin';
    if (loc.startsWith('/foundation/')) return 'foundation_admin';
    return null;
  }

  static bool _roleMatches(String role, String required) {
    // super_admin has full platform access (backend policies grant
    // super_admin bypass on every school-scoped check).
    if (role == 'super_admin') return true;
    if (role == required) return true;
    // Device-operator roles share the gate shell.
    if (required == 'gate_ops' && (role == 'driver' || role == 'security')) {
      return true;
    }
    // school_admin is an admin; /staff/* is the generic fallback shell
    // for every other back-office role (principal, nurse, librarian,
    // accountant, ...), so it must never bounce.
    if (required == 'admin' && role == 'school_admin') return true;
    if (required == 'staff') return true;
    return false;
  }
}

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }
  late final Object _sub;

  @override
  void dispose() {
    (_sub as dynamic).cancel();
    super.dispose();
  }
}
