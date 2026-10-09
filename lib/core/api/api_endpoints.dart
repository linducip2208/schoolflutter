class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth
  static const String login = '/auth/login';
  static const String twoFactorVerify = '/auth/2fa/verify';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String updateAvatar = '/auth/avatar';
  static const String changePassword = '/auth/change-password';
  static const String registerFcmToken = '/auth/fcm-token';

  // ── Device tokens (multi-device push registry)
  static const String devicesRegister = '/devices/register';
  static const String devicesUnregister = '/devices/unregister';

  // ── Uploads (purpose-scoped, server-validated)
  static const String uploads = '/uploads';
  static const String uploadFile = '/uploads/file';

  // ── School
  static const String schoolProfile = '/school/profile';
  static const String schoolSettings = '/school/settings';
  static const String schoolLogo = '/school/logo';

  // ── Dashboard (aggregator per role)
  static const String studentDashboard = '/dashboard/student';
  static const String teacherDashboard = '/dashboard/teacher';
  static const String parentDashboard = '/dashboard/parent';
  static const String adminDashboard = '/dashboard/admin';

  // ── Academic Years / Holidays
  static const String academicYears = '/academic-years';
  static const String holidays = '/holidays';

  // ── Attendance
  static const String myAttendance = '/attendance/me';
  static String attendanceByClass(int sectionId) =>
      '/attendance/class/$sectionId';
  static String attendanceByStudent(int studentId) =>
      '/attendance/student/$studentId';
  static String attendanceSummary(int studentId) =>
      '/attendance/summary/$studentId';

  // ── Timetable
  static const String timetableMy = '/timetable/my';
  static const String timetableStudentMy = '/timetable/student/my';
  static String timetableByClass(int sectionId) =>
      '/timetable/class/$sectionId';
  static String timetableByTeacher(int teacherId) =>
      '/timetable/teacher/$teacherId';

  // ── Classroom
  static const String classroomLessons = '/classroom/lessons';
  static const String classroomAssignments = '/classroom/assignments';
  static String submitAssignment(int assignmentId) =>
      '/classroom/assignments/$assignmentId/submit';
  static String assignmentSubmissions(int assignmentId) =>
      '/classroom/assignments/$assignmentId/submissions';

  // ── Exam
  static const String exams = '/exams';
  static String examQuestions(int examId) => '/exams/$examId/questions';
  static String startExam(int examId) => '/exams/$examId/start';
  static String submitExam(int examId) => '/exams/$examId/submit';
  static String examResult(int examId) => '/exams/$examId/result';

  // ── Marks
  static const String myMarks = '/marks/me';
  static String marksByStudent(int studentId) => '/marks/student/$studentId';
  static String reportCardByStudent(int studentId) =>
      '/report-cards/student/$studentId';
  static String reportCardPdf(int reportCardId) =>
      '/report-cards/$reportCardId/pdf';

  // ── Admission
  static const String admission = '/admission';
  static const String admissionStats = '/admission/stats';

  // ── Fees
  static const String feeStructures = '/fee/structures';
  static const String feeInvoices = '/fee/invoices';
  static const String myFeeInvoices = '/fee/invoices/me';
  static String invoicePaymentLink(int invoiceId) =>
      '/fee/invoices/$invoiceId/payment-link';
  static String invoicePay(int invoiceId) => '/fee/invoices/$invoiceId/pay';

  // ── Payroll
  static const String payrollSlips = '/payroll/slips';
  static const String payrollStructures = '/payroll/structures';

  // ── Library
  static const String libraryBooks = '/library/books';
  static const String libraryCategories = '/library/categories';
  static const String libraryIssues = '/library/issues';
  static const String libraryIssue = '/library/issue';
  static String libraryReturn(int issueId) => '/library/return/$issueId';

  // ── Hostel
  static const String hostels = '/hostel';
  static String hostelRooms(int hostelId) => '/hostel/$hostelId/rooms';
  static const String hostelAllocate = '/hostel/allocate';

  // ── Transport
  static const String transportRoutes = '/transport/routes';
  static const String transportVehicles = '/transport/vehicles';
  static const String transportAssign = '/transport/assign-student';

  // ── Notice
  static const String notices = '/notices';

  // ── Chat
  static const String conversations = '/chat/conversations';
  static String conversationMessages(int id) =>
      '/chat/conversations/$id/messages';
  static String sendMessage(int id) => '/chat/conversations/$id/send';

  // ── Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String markNotificationRead(int id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // ── Parent Portal
  static const String parentChildren = '/parent/children';
  static String parentChildAttendance(int studentId) =>
      '/parent/children/$studentId/attendance';
  static String parentChildMarks(int studentId) =>
      '/parent/children/$studentId/marks';
  static String parentChildInvoices(int studentId) =>
      '/parent/children/$studentId/invoices';

  // ── Branding (school whitelabel)
  static String brandingPublic(String subdomain) => '/branding/$subdomain';
  static const String brandingMine = '/branding';

  // ── Payments (dynamic gateway)
  static const String paymentMethods = '/payments/methods';
  static const String paymentInitiate = '/payments/initiate';
  static String paymentShow(String referenceNo) => '/payments/$referenceNo';
  static String paymentCancel(String referenceNo) =>
      '/payments/$referenceNo/cancel';

  // ── PPDB (public + authenticated)
  static String ppdbPeriods(String subdomain) =>
      '/public/ppdb/$subdomain/periods';
  static String ppdbRegister(String subdomain) =>
      '/public/ppdb/$subdomain/register';
  static const String ppdbMyApplications = '/ppdb/applications/me';
  static String ppdbSubmit(int id) => '/ppdb/applications/$id/submit';
  static String ppdbUploadDoc(int id) => '/ppdb/applications/$id/upload-doc';

  // ── Bus tracking + Gate
  static String childBusLocation(int studentId) =>
      '/parent/children/$studentId/bus-location';
  static String childGateEvents(int studentId) =>
      '/parent/children/$studentId/gate-events';

  // ── UKS / Medical (parent view)
  static String studentClinicVisits(int studentId) =>
      '/medical/students/$studentId/visits';
  static String studentVaccinations(int studentId) =>
      '/medical/students/$studentId/vaccinations';

  // ── Wellness checkin
  static const String wellnessCheckin = '/wellness/checkin';

  // ── Hafalan (Religious)
  static const String hafalanRecord = '/religious/hafalan';
  static String hafalanSummary(int studentId) =>
      '/religious/hafalan/student/$studentId';
  static const String ibadahLog = '/religious/ibadah';
  static String ibadahSummary(int studentId) =>
      '/religious/ibadah/student/$studentId';

  // ── Canteen
  static const String canteenMenu = '/canteen/menu';
  static String canteenWallet(int studentId) => '/canteen/wallet/$studentId';
  static String canteenTopup(int studentId) =>
      '/canteen/wallet/$studentId/topup';
  static const String canteenOrder = '/canteen/orders';

  // ── AI
  static const String aiStudyAssistant = '/ai/study-assistant';

  // ── Live class
  static String liveClassJoin(int sessionId) =>
      '/live-class/sessions/$sessionId/join';

  // ── Daily report
  static String childDailyReports(int studentId) =>
      '/parent/children/$studentId/daily-reports';

  // ── Events
  static String publicEventList(String subdomain) =>
      '/public/events/$subdomain';
  static String eventRsvp(int eventId) => '/events/$eventId/rsvp';

  // ── LMS (mobile)
  static const String lmsCourses = '/lms/courses';
  static String lmsCourseDetail(int courseId) => '/lms/courses/$courseId';
  static const String lmsEnroll = '/lms/enroll';
  static const String lmsProgress = '/lms/progress';
  static const String lmsCompleteLesson = '/lms/complete-lesson';
  static const String lmsQuizzes = '/lms/quizzes';
  static const String lmsQuizSubmit = '/lms/quiz/submit';
  static String quizQuestions(int quizId) => '/lms/quizzes/$quizId/questions';
  static String lmsCertificate(int enrollmentId) =>
      '/lms/enrollments/$enrollmentId/certificate';

  // ── Super Admin (platform-level, role:super_admin, bypass SchoolScope)
  static const String superDashboard = '/super/dashboard';
  static const String superSchools = '/super/schools';
  static String superSchoolDetail(int id) => '/super/schools/$id';
  static String superSchoolStats(int id) => '/super/schools/$id/stats';
  static const String superPlans = '/super/plans';
  static const String superSubscriptions = '/super/subscriptions';
  static const String superRevenueAnalytics = '/super/analytics/revenue';
  static const String superGrowthAnalytics = '/super/analytics/growth';

  // ── Exam (manage)
  static String examUpdate(int examId) => '/exams/$examId';
  static String examDelete(int examId) => '/exams/$examId';
  static String examStoreQuestion(int examId) => '/exams/$examId/questions';
  static String examSubmissions(int examId) => '/exams/$examId/submissions';

  // ── Question bank
  static const String qbCategories = '/question-bank/categories';
  static const String qbItems = '/question-bank/items';
  static const String qbGenerateExam = '/question-bank/generate-exam';

  // ── Lesson plans (RPP)
  static const String lessonPlans = '/lesson-plans';
  static String lessonPlan(int id) => '/lesson-plans/$id';
  static String lessonPlanSubmit(int id) => '/lesson-plans/$id/submit';
  static String lessonPlanApprove(int id) => '/lesson-plans/$id/approve';
  static String lessonPlanReject(int id) => '/lesson-plans/$id/reject';
  static String lessonPlanExecute(int id) => '/lesson-plans/$id/mark-executed';
  static String lessonCoverage(int semesterId) =>
      '/lesson-plans/coverage/$semesterId';

  // ── Curriculum (CP/TP/KI/KD)
  static const String currFrameworks = '/curriculum/frameworks';
  static const String currCompetencies = '/curriculum/competencies';
  static const String currAssessments = '/curriculum/assessments';
  static const String currCoverage = '/curriculum/coverage';

  // ── Marks (manage)
  static const String marksBulk = '/marks/bulk';
  static String markUpdate(int markId) => '/marks/$markId';
  static const String gradeSystems = '/grade-systems';
  static const String reportCardsGenerate = '/report-cards/generate';
  static String reportCardPublish(int reportCardId) =>
      '/report-cards/$reportCardId/publish';

  // ── Admission (manage)
  static String admissionUpdate(int id) => '/admission/$id';
  static String admissionEnroll(int id) => '/admission/$id/enroll';

  // ── Fees (manage)
  static const String feeGenerateMonthly = '/fee/generate-monthly';

  // ── Payroll (manage)
  static const String payrollGenerateSlip = '/payroll/generate-slip';
  static String payrollMarkPaid(int slipId) =>
      '/payroll/slips/$slipId/mark-paid';

  // ── PPDB admin
  static const String ppdbAdminApplications = '/admin/ppdb/applications';
  static String ppdbVerify(int id) => '/admin/ppdb/applications/$id/verify';
  static String ppdbAccept(int id) => '/admin/ppdb/applications/$id/accept';
  static String ppdbReject(int id) => '/admin/ppdb/applications/$id/reject';
  static String ppdbRunSelection(int periodId) =>
      '/admin/ppdb/$periodId/run-selection';
  static const String ppdbBatchEnroll = '/admin/ppdb/batch-enroll';
  static const String ppdbReports = '/admin/ppdb/reports';

  // ── Transport admin + ID gate admin
  static const String transportActiveTrips = '/admin/transport/active-trips';
  static String transportTrackTrip(int id) =>
      '/admin/transport/trips/$id/track';
  static String idCardIssue(int studentId) =>
      '/admin/students/$studentId/id-card';
  static String idCardRotateQr(int cardId) =>
      '/admin/id-cards/$cardId/rotate-qr';

  // ── Daily report admin
  static const String dailyReportGenerate = '/admin/daily-reports/generate';
  static String dailyReportSend(int id) => '/admin/daily-reports/$id/send';

  // ── Payment providers admin (BYOK)
  static const String payProviders = '/admin/payment-providers';
  static String payProviderTest(int id) => '/admin/payment-providers/$id/test';
  static const String payProviderPresets =
      '/admin/payment-providers/presets/list';
  static const String payProviderPresetLoad =
      '/admin/payment-providers/presets/load';
  static const String payMethodsAdmin = '/admin/payment-methods';

  // ── AI admin + tools
  static const String aiProviders = '/admin/ai/providers';
  static String aiProvider(int id) => '/admin/ai/providers/$id';
  static const String aiModels = '/admin/ai/models';
  static const String aiFeatures = '/admin/ai/features';
  static const String aiUsage = '/admin/ai/usage';
  static const String aiLessonPlan = '/ai/lesson-plan';
  static const String aiEssayGrade = '/ai/essay-grade';

  // ── Events (manage)
  static const String eventsAdmin = '/events';
  static String eventRsvps(int id) => '/events/$id/rsvps';
  static const String eventCheckIn = '/events/check-in';

  // ── Donations
  static const String donationAdminCampaigns = '/admin/donations/campaigns';
  static const String donationAdminList = '/admin/donations';
  static String publicDonationCampaigns(String subdomain) =>
      '/public/donations/$subdomain/campaigns';

  // ── Achievements (manage)
  static const String achievementCategories = '/achievements/categories';
  static const String achievementRecord = '/achievements';
  static String achievementVerify(int id) => '/achievements/$id/verify';
  static String achievementsOfStudent(int id) => '/achievements/students/$id';
  static const String achievementLeaderboard = '/achievements/leaderboard';

  // ── Scholarships (manage)
  static const String scholarshipApply = '/scholarship/applications';
  static String scholarshipGrant(int id) =>
      '/scholarship/applications/$id/grant';
  static String scholarshipApplyToInvoice(int id) =>
      '/scholarship/applications/$id/apply-to-invoice';

  // ── Career
  static const String careerAssess = '/career/assessments';
  static String careerStudentAssess(int id) =>
      '/career/assessments/student/$id';
  static const String careerInternships = '/career/internships';
  static String careerLogActivity(int id) =>
      '/career/internships/$id/log-activity';

  // ── Alumni
  static const String alumniProfile = '/alumni/profile';
  static String alumniVerify(int id) => '/admin/alumni/$id/verify';

  // ── Ekskul (manage)
  static String ekskulEnroll(int id) => '/ekskul/$id/enroll';
  static String ekskulAttendance(int id) => '/ekskul/$id/attendance';

  // ── Inventory
  static const String invAssets = '/inventory/assets';
  static const String invLoans = '/inventory/loans';
  static String invApproveLoan(int id) => '/inventory/loans/$id/approve';
  static String invReturnLoan(int id) => '/inventory/loans/$id/return';
  static const String invMaintenance = '/inventory/maintenance';
  static String invResolveMaintenance(int id) =>
      '/inventory/maintenance/$id/resolve';

  // ── Visitors
  static const String visitors = '/visitors';
  static const String visitorsActive = '/visitors/active';
  static const String visitorCheckIn = '/visitors/check-in';
  static const String visitorPreRegister = '/visitors/pre-register';
  static String visitorApprove(int id) => '/visitors/$id/approve';
  static String visitorCheckOut(int id) => '/visitors/$id/check-out';

  // ── Dapodik
  static const String dapodikConfig = '/admin/dapodik/config';
  static const String dapodikTest = '/admin/dapodik/test-connection';
  static const String dapodikPreview = '/admin/dapodik/preview';
  static const String dapodikRuns = '/admin/dapodik/runs';
  static const String dapodikConflicts = '/admin/dapodik/conflicts';
  static String dapodikResolveConflict(int id) =>
      '/admin/dapodik/conflicts/$id/resolve';
  static String dapodikConfirmRun(int runId) =>
      '/admin/dapodik/runs/$runId/confirm';
  static const String dapodikImport = '/admin/dapodik/import-students';
  static const String dapodikExport = '/admin/dapodik/export-students';

  // ── Canteen merchant
  static const String canteenOrdersToday = '/canteen/orders/today';
  static String canteenOrderStatus(int id) => '/canteen/orders/$id/status';
  static String canteenWalletLock(int walletId) =>
      '/canteen/wallet/$walletId/lock';
  static String canteenOrderRefund(int id) => '/canteen/orders/$id/refund';
  static String canteenTransactions(int studentId) =>
      '/canteen/wallet/$studentId/transactions';

  // ── Medical (manage)
  static const String medicalStoreVisit = '/medical/visits';
  static String medicalUpdateRecord(int studentId) =>
      '/medical/students/$studentId/record';
  static String medicalStoreVaccination(int studentId) =>
      '/medical/students/$studentId/vaccinations';

  // ── Discipline (manage)
  static const String disciplineCategories = '/discipline/categories';
  static const String disciplineRecords = '/discipline/records';
  static const String disciplineLeaderboard = '/discipline/leaderboard';

  // ── Counseling (manage)
  static const String counselingSchedule = '/counseling/sessions';
  static String counselingComplete(int id) =>
      '/counseling/sessions/$id/complete';
  static const String bullyingReports = '/counseling/bullying-reports';
  static String bullyingAssign(int id) =>
      '/counseling/bullying-reports/$id/assign';
  static String bullyingClose(int id) =>
      '/counseling/bullying-reports/$id/close';

  // ── Live class (manage)
  static const String liveProviders = '/live-class/providers';
  static const String liveSessions = '/live-class/sessions';
  static String liveStart(int id) => '/live-class/sessions/$id/start';
  static String liveEnd(int id) => '/live-class/sessions/$id/end';
  static String liveLeave(int id) => '/live-class/sessions/$id/leave';

  // ── Analytics (dropout risk)
  static const String riskCompute = '/analytics/risk-scores/compute';
  static String riskStudent(int id) => '/analytics/risk-scores/student/$id';
  static const String riskAtRisk = '/analytics/risk-scores/at-risk';

  // ── Foundation (yayasan)
  static const String foundationsMine = '/foundations/mine';
  static String foundationDashboard(int id) => '/foundations/$id/dashboard';
  static String foundationSchoolDetail(int f, int s) =>
      '/foundations/$f/schools/$s';

  // ── Import / export
  static const String importStudents = '/import/students';
  static const String importStudentsTemplate = '/import/students/template';
  static const String exportMarks = '/export/marks';
  static const String exportFeeCollection = '/export/fee-collection';

  // ── Classroom (manage)
  static const String classroomStoreLesson = '/classroom/lessons';
  static String classroomLesson(int id) => '/classroom/lessons/$id';
  static String classroomLessonMaterials(int id) =>
      '/classroom/lessons/$id/materials';
  static const String classroomStoreAssignment = '/classroom/assignments';
  static String classroomAssignment(int id) => '/classroom/assignments/$id';
  static String classroomGradeSubmission(int submissionId) =>
      '/classroom/submissions/$submissionId/grade';

  // ── Attendance (manage)
  static String attendanceLock(int sectionId) =>
      '/attendance/class/$sectionId/lock';
  static String attendanceReopen(int sectionId) =>
      '/attendance/class/$sectionId/reopen';
  static const String attendanceCorrections = '/attendance/corrections';
  static String attendanceApproveCorrection(int id) =>
      '/attendance/corrections/$id/approve';
  static String attendanceRejectCorrection(int id) =>
      '/attendance/corrections/$id/reject';
  static String attendanceRequestCorrection(int attendanceId) =>
      '/attendance/$attendanceId/correction';

  // ── Timetable (manage)
  static const String timetableStore = '/timetable';
  static String timetableSlot(int id) => '/timetable/$id';
  static const String timetableBreaks = '/timetable/breaks';
  static const String timetableBulk = '/timetable/bulk';

  // ── Hostel (manage)
  static String hostelStoreRoom(int hostelId) => '/hostel/$hostelId/rooms';

  // ── Library (manage)
  static const String libraryStoreBook = '/library/books';
  static String libraryBook(int id) => '/library/books/$id';
  static const String libraryStoreCategory = '/library/categories';
  static const String libraryMarkOverdue = '/library/mark-overdue';

  // ── Transport (manage)
  static const String transportStoreRoute = '/transport/routes';
  static const String transportStoreVehicle = '/transport/vehicles';

  // ── Chat (start)
  static const String chatStart = '/chat/conversations';

  // ── Religious (targets)
  static const String hafalanTargets = '/religious/hafalan/targets';

  // ── Directory (students, staff, academic reference)
  static const String dirStudents = '/directory/students';
  static const String dirStaff = '/directory/staff';
  static const String dirClassRooms = '/directory/class-rooms';
  static const String dirSections = '/directory/sections';
  static const String dirClassSections = '/directory/class-sections';
  static const String dirSubjects = '/directory/subjects';
  static const String dirSemesters = '/directory/semesters';
  static const String dirMediums = '/directory/mediums';

  // ── Finance reports (whole rupiah)
  static const String reportsCash = '/reports/cash-summary';
  static const String reportsAging = '/reports/aging';
  static const String reportsOutstanding = '/reports/outstanding';

  // ── Budget / RKAS (whole rupiah in/out)
  static const String budgetDashboard = '/budget/dashboard';
  static const String budgetCategories = '/budget/categories';
  static const String budgetItems = '/budget/items';
  static const String budgetTransactions = '/budget/transactions';

  // ── Letters (surat-menyurat)
  static const String letters = '/letters';
  static const String letterTemplates = '/letters/templates';
  static String letter(int id) => '/letters/$id';
  static String letterStatus(int id) => '/letters/$id/status';

  // ── Super extras
  static String superSchoolActivity(int id) =>
      '/super/schools/$id/activity-log';
  static String superSchoolSuspend(int id) => '/super/schools/$id/suspend';
  static String superSchoolActivate(int id) => '/super/schools/$id/activate';
  static String superSchoolExtend(int id) =>
      '/super/schools/$id/subscription/extend';
  static String superSchoolUpgrade(int id) =>
      '/super/schools/$id/subscription/upgrade';
  static const String superSystemConfig = '/super/system/config';
  static const String apiDeepHealth = '/health/deep';

  // ── Offline sync batch (backend replay, max 200 records)
  static const String syncBatch = '/sync/batch';

  // ── Emergency
  static const String emergencyPanic = '/emergency/panic';
  static const String emergencyRecent = '/emergency/recent';
  static const String emergencyContacts = '/emergency/contacts';

  // ── QR attendance
  static const String qrScan = '/qr/scan';

  // ── Counseling / wellness / discipline
  static const String counselingSessions = '/counseling/sessions';
  static const String wellnessAtRisk = '/wellness/at-risk';
  static String disciplineSummary(int studentId) =>
      '/discipline/students/$studentId/summary';

  // ── Medical (staff view)
  static const String medicalVisits = '/medical/visits';
  static String medicalRecord(int studentId) =>
      '/medical/students/$studentId/record';

  // ── Reading progress
  static const String readingProgress = '/reading/progress';

  // ── Achievements / scholarships
  static const String achievementBadges = '/achievements/badges';
  static const String scholarshipPrograms = '/scholarship/programs';

  // ── Extracurricular
  static const String ekskul = '/ekskul';

  // ── Calendar
  static const String calendarIcal = '/calendar/ical';

  // ── Branding
  static String brandingPublicSubdomain(String subdomain) =>
      '/branding/$subdomain';
}
