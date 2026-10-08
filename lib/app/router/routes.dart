class Routes {
  Routes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String twoFactor = '/2fa';
  static const String forgotPassword = '/forgot-password';

  // Student
  static const String studentDashboard = '/student/dashboard';
  static const String studentTimetable = '/student/timetable';
  static const String studentClassroom = '/student/classroom';
  static const String studentAttendance = '/student/attendance';
  static const String studentExam = '/student/exam';
  static const String studentMarks = '/student/marks';
  static const String studentFees = '/student/fees';
  static const String studentLibrary = '/student/library';
  static const String studentChat = '/student/chat';
  static const String studentProfile = '/student/profile';
  // Student module hub + aliases (docs §student).
  static const String studentMenu = '/student/menu';
  static const String studentEkskul = '/student/ekskul';
  static const String studentEvent = '/student/event';
  static const String studentBeasiswa = '/student/beasiswa';
  static const String studentKarier = '/student/karier';
  static const String studentPrestasi = '/student/prestasi';
  static const String studentLms = '/student/lms';
  static const String studentLive = '/student/live';
  static const String studentAi = '/student/ai';
  static const String studentEmergency = '/student/emergency';
  static const String studentBullying = '/student/bullying';
  static const String studentBus = '/student/bus/:studentId';
  static const String studentCalendar = '/student/calendar';
  static const String studentQuizzes = '/student/quizzes';

  // Parent
  static const String parentDashboard = '/parent/dashboard';
  static const String parentMarks = '/parent/marks';
  static const String parentAttendance = '/parent/attendance';
  static const String parentFees = '/parent/fees';
  static const String parentChat = '/parent/chat';
  static const String parentProfile = '/parent/profile';
  // Parent module hub + aliases (docs §parent).
  static const String parentMenu = '/parent/menu';
  static const String parentChildren = '/parent/children';
  static const String parentEvent = '/parent/event';
  static const String parentDonasi = '/parent/donasi';
  static const String parentBullying = '/parent/bullying';
  static const String parentEmergency = '/parent/emergency';

  // Teacher
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherClassroom = '/teacher/classroom';
  static const String teacherExam = '/teacher/exam';
  static const String teacherChat = '/teacher/chat';
  static const String teacherProfile = '/teacher/profile';
  // Teacher module hub + aliases (docs §teacher).
  static const String teacherMenu = '/teacher/menu';
  static const String teacherRpp = '/teacher/rpp';
  static const String teacherBankSoal = '/teacher/bank-soal';
  static const String teacherNilai = '/teacher/nilai';
  static const String teacherLive = '/teacher/live';
  static const String teacherAi = '/teacher/ai';
  static const String teacherKurikulum = '/teacher/kurikulum';
  static const String teacherDisiplin = '/teacher/disiplin';
  static const String teacherPrestasi = '/teacher/prestasi';
  static const String teacherEmergency = '/teacher/emergency';
  static const String teacherBullying = '/teacher/bullying';
  static const String teacherAttendanceTools = '/teacher/attendance-tools';
  static const String teacherHafalanTargets = '/teacher/hafalan-targets';
  static const String teacherQuizzes = '/teacher/quizzes';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminAdmissions = '/admin/admissions';
  static const String adminFees = '/admin/fees';
  static const String adminPayroll = '/admin/payroll';
  static const String adminNotice = '/admin/notice';
  static const String adminProfile = '/admin/profile';
  // Admin module hub + working-screen aliases (role-agnostic pages
  // that backend permits for admin; student/teacher-scoped pages
  // like timetable/marks/exam-attempt are deliberately NOT aliased).
  static const String adminMenu = '/admin/menu';
  static const String adminAttendance = '/admin/attendance';
  static const String adminClassroom = '/admin/classroom';
  static const String adminLibrary = '/admin/library';
  static const String adminChat = '/admin/chat';
  // Admin module hub expansion (docs §2-§9, 47 modul ERP).
  static const String adminPpdb = '/admin/ppdb';
  static const String adminTahunAjaran = '/admin/tahun-ajaran';
  static const String adminExamManage = '/admin/exam-manage';
  static const String adminBankSoal = '/admin/bank-soal';
  static const String adminRpp = '/admin/rpp';
  static const String adminKurikulum = '/admin/kurikulum';
  static const String adminNilaiBatch = '/admin/nilai-batch';
  static const String adminEvent = '/admin/event';
  static const String adminDonasi = '/admin/donasi';
  static const String adminPrestasi = '/admin/prestasi';
  static const String adminBeasiswa = '/admin/beasiswa';
  static const String adminKarier = '/admin/karier';
  static const String adminEkskul = '/admin/ekskul';
  static const String adminInventaris = '/admin/inventaris';
  static const String adminVisitor = '/admin/visitor';
  static const String adminKantin = '/admin/kantin';
  static const String adminTransportManage = '/admin/transport-manage';
  static const String adminDapodik = '/admin/dapodik';
  static const String adminMedis = '/admin/medis';
  static const String adminDisiplin = '/admin/disiplin';
  static const String adminKonseling = '/admin/konseling';
  static const String adminGate = '/admin/gate';
  static const String adminLive = '/admin/live';
  static const String adminAiTools = '/admin/ai-tools';
  static const String adminAiProvider = '/admin/ai-provider';
  static const String adminPayProvider = '/admin/pay-provider';
  static const String adminBranding = '/admin/branding';
  static const String adminImportExport = '/admin/import-export';
  static const String adminRisiko = '/admin/risiko';
  static const String adminYayasan = '/admin/yayasan';
  static const String adminLaporanHarian = '/admin/laporan-harian';
  static const String adminAlumni = '/admin/alumni';
  static const String adminLms = '/admin/lms';
  static const String adminEmergency = '/admin/emergency';
  static const String adminCalendar = '/admin/calendar';
  static const String adminFinanceTools = '/admin/finance-tools';
  static const String adminAttendanceTools = '/admin/attendance-tools';
  static const String adminHafalanTargets = '/admin/hafalan-targets';
  static const String adminStudents = '/admin/students';
  static const String adminStaff = '/admin/staff';
  static const String adminReports = '/admin/reports';
  static const String adminBudget = '/admin/budget';
  static const String adminLetters = '/admin/letters';
  static const String adminQuizzes = '/admin/quizzes';

  // Staff
  static const String staffDashboard = '/staff/dashboard';
  static const String staffProfile = '/staff/profile';

  // Common
  static const String notice = '/notice';
  static const String notifications = '/notifications';
  static const String chatConversation = '/chat/:conversationId';
  static const String hostel = '/hostel';
  static const String transport = '/transport';
  static const String about = '/about';

  // ===== Phase 8-11 routes =====

  // Phase 8 — Student Lifecycle
  static const String ppdbRegister = '/ppdb/register';
  static const String parentBusTracking = '/parent/bus-tracking/:studentId';
  static const String parentClinicVisits = '/parent/clinic/:studentId';
  static const String wellnessCheckin = '/student/wellness';

  // Phase 9 — Teaching Tools
  static const String studyAssistant = '/student/ai-assistant';
  static const String hafalanInput = '/teacher/hafalan';
  static const String canteenMenu = '/student/canteen/:studentId';

  // Phase 10 — Engagement
  static const String parentDailyReport = '/parent/daily-report/:studentId';

  // Phase 11 already covered by web

  // Super Admin (platform-level)
  static const String superDashboard = '/super/dashboard';
  static const String superSchools = '/super/schools';
  static const String superProfile = '/super/profile';
  static const String superPlans = '/super/plans';
  static const String superAnalytics = '/super/analytics';
  static const String superSystem = '/super/system';

  // ===== Role shells (non-core backend roles) =====
  static const String accountantFees = '/accountant/fees';
  static const String accountantPayroll = '/accountant/payroll';
  static const String accountantPayProvider = '/accountant/pay-provider';
  static const String accountantDonasi = '/accountant/donasi';
  static const String accountantProfile = '/accountant/profile';
  static const String accountantReports = '/accountant/reports';
  static const String accountantBudget = '/accountant/budget';

  static const String librarianLibrary = '/librarian/library';
  static const String librarianProfile = '/librarian/profile';

  static const String nurseVisits = '/nurse/visits';
  static const String nurseProfile = '/nurse/profile';

  static const String counselorCounseling = '/counselor/counseling';
  static const String counselorDiscipline = '/counselor/discipline';
  static const String counselorProfile = '/counselor/profile';

  static const String principalDashboard = '/principal/dashboard';
  static const String principalFees = '/principal/fees';
  static const String principalChat = '/principal/chat';
  static const String principalProfile = '/principal/profile';
  static const String principalReports = '/principal/reports';
  static const String principalBudget = '/principal/budget';

  static const String frontdeskVisitor = '/frontdesk/visitor';
  static const String frontdeskAdmission = '/frontdesk/admission';
  static const String frontdeskPpdb = '/frontdesk/ppdb';
  static const String frontdeskProfile = '/frontdesk/profile';

  static const String hrPayroll = '/hr/payroll';
  static const String hrProfile = '/hr/profile';

  static const String transportOpsManage = '/transport-ops/manage';
  static const String transportOpsProfile = '/transport-ops/profile';

  static const String hostelOpsHome = '/hostel-ops/home';
  static const String hostelOpsProfile = '/hostel-ops/profile';

  static const String procurementInventory = '/procurement/inventory';
  static const String procurementProfile = '/procurement/profile';

  static const String gateScan = '/gate/scan';
  static const String gateEmergency = '/gate/emergency';
  static const String gateProfile = '/gate/profile';

  static const String visitorOpsHome = '/visitor-ops/home';
  static const String visitorOpsProfile = '/visitor-ops/profile';

  static const String schoolOpsCanteen = '/schoolops/canteen';
  static const String schoolOpsVisitor = '/schoolops/visitor';
  static const String schoolOpsDapodik = '/schoolops/dapodik';
  static const String schoolOpsProfile = '/schoolops/profile';

  static const String foundationHome = '/foundation/home';
  static const String foundationProfile = '/foundation/profile';

  static String homeForRole(String role) {
    return switch (role) {
      'super_admin' => superDashboard,
      'student' => studentDashboard,
      'parent' => parentDashboard,
      'teacher' || 'homeroom_teacher' => teacherDashboard,
      'admin' => adminDashboard,
      'school_admin' => schoolOpsCanteen,
      'accountant' => accountantFees,
      'librarian' => librarianLibrary,
      'nurse' => nurseVisits,
      'counselor' => counselorCounseling,
      'principal' => principalDashboard,
      'receptionist' => frontdeskVisitor,
      'hr' => hrPayroll,
      'transport_admin' => transportOpsManage,
      'hostel_admin' => hostelOpsHome,
      'procurement_admin' => procurementInventory,
      'driver' || 'security' => gateScan,
      'visitor_operator' => visitorOpsHome,
      'foundation_admin' => foundationHome,
      _ => staffDashboard,
    };
  }
}
