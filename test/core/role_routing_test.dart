import 'package:eschool_app/app/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Role-based home routing (SikadPro parity)', () {
    test('super_admin lands on super dashboard', () {
      expect(Routes.homeForRole('super_admin'), Routes.superDashboard);
    });
    test('school_admin gets dedicated ops home', () {
      expect(Routes.homeForRole('school_admin'), Routes.schoolOpsCanteen);
      expect(Routes.homeForRole('admin'), Routes.adminDashboard);
    });
    test('core roles map to their shells', () {
      expect(Routes.homeForRole('student'), Routes.studentDashboard);
      expect(Routes.homeForRole('parent'), Routes.parentDashboard);
      expect(Routes.homeForRole('teacher'), Routes.teacherDashboard);
    });
    test('unknown roles fall back to staff', () {
      expect(Routes.homeForRole('accountant'), Routes.accountantFees);
      expect(Routes.homeForRole('librarian'), Routes.librarianLibrary);
      expect(Routes.homeForRole('nurse'), Routes.nurseVisits);
      expect(Routes.homeForRole('counselor'), Routes.counselorCounseling);
      expect(Routes.homeForRole('principal'), Routes.principalDashboard);
      expect(Routes.homeForRole('receptionist'), Routes.frontdeskVisitor);
      expect(Routes.homeForRole('hr'), Routes.hrPayroll);
      expect(Routes.homeForRole('transport_admin'), Routes.transportOpsManage);
      expect(Routes.homeForRole('hostel_admin'), Routes.hostelOpsHome);
      expect(
          Routes.homeForRole('procurement_admin'), Routes.procurementInventory);
      expect(Routes.homeForRole('driver'), Routes.gateScan);
      expect(Routes.homeForRole('security'), Routes.gateScan);
      expect(
          Routes.homeForRole('visitor_operator'), Routes.visitorOpsHome);
      expect(Routes.homeForRole('school_admin'), Routes.schoolOpsCanteen);
      expect(Routes.homeForRole('foundation_admin'), Routes.foundationHome);
      expect(Routes.homeForRole('homeroom_teacher'), Routes.teacherDashboard);
      expect(Routes.homeForRole('random_xyz'), Routes.staffDashboard);
    });
    test('admin module hub + aliases registered', () {
      expect(Routes.adminMenu, '/admin/menu');
      expect(Routes.adminAttendance, '/admin/attendance');
      expect(Routes.adminClassroom, '/admin/classroom');
      expect(Routes.adminLibrary, '/admin/library');
      expect(Routes.adminChat, '/admin/chat');
    });
    test('super routes registered', () {
      expect(Routes.superDashboard, '/super/dashboard');
      expect(Routes.superSchools, '/super/schools');
      expect(Routes.superProfile, '/super/profile');
      expect(Routes.superPlans, '/super/plans');
      expect(Routes.superAnalytics, '/super/analytics');
      expect(Routes.superSystem, '/super/system');
    });
    test('teacher/student/parent hubs registered', () {
      expect(Routes.teacherMenu, '/teacher/menu');
      expect(Routes.teacherRpp, '/teacher/rpp');
      expect(Routes.teacherBankSoal, '/teacher/bank-soal');
      expect(Routes.teacherNilai, '/teacher/nilai');
      expect(Routes.teacherLive, '/teacher/live');
      expect(Routes.teacherAi, '/teacher/ai');
      expect(Routes.studentMenu, '/student/menu');
      expect(Routes.studentEkskul, '/student/ekskul');
      expect(Routes.studentEvent, '/student/event');
      expect(Routes.studentBeasiswa, '/student/beasiswa');
      expect(Routes.studentKarier, '/student/karier');
      expect(Routes.studentLms, '/student/lms');
      expect(Routes.parentMenu, '/parent/menu');
      expect(Routes.parentChildren, '/parent/children');
      expect(Routes.parentEvent, '/parent/event');
      expect(Routes.parentDonasi, '/parent/donasi');
    });
    test('admin expansion routes registered', () {
      expect(Routes.adminPpdb, '/admin/ppdb');
      expect(Routes.adminTahunAjaran, '/admin/tahun-ajaran');
      expect(Routes.adminExamManage, '/admin/exam-manage');
      expect(Routes.adminBankSoal, '/admin/bank-soal');
      expect(Routes.adminRpp, '/admin/rpp');
      expect(Routes.adminKurikulum, '/admin/kurikulum');
      expect(Routes.adminNilaiBatch, '/admin/nilai-batch');
      expect(Routes.adminEvent, '/admin/event');
      expect(Routes.adminDonasi, '/admin/donasi');
      expect(Routes.adminPrestasi, '/admin/prestasi');
      expect(Routes.adminBeasiswa, '/admin/beasiswa');
      expect(Routes.adminKarier, '/admin/karier');
      expect(Routes.adminEkskul, '/admin/ekskul');
      expect(Routes.adminInventaris, '/admin/inventaris');
      expect(Routes.adminVisitor, '/admin/visitor');
      expect(Routes.adminKantin, '/admin/kantin');
      expect(Routes.adminTransportManage, '/admin/transport-manage');
      expect(Routes.adminDapodik, '/admin/dapodik');
      expect(Routes.adminMedis, '/admin/medis');
      expect(Routes.adminDisiplin, '/admin/disiplin');
      expect(Routes.adminKonseling, '/admin/konseling');
      expect(Routes.adminGate, '/admin/gate');
      expect(Routes.adminLive, '/admin/live');
      expect(Routes.adminAiTools, '/admin/ai-tools');
      expect(Routes.adminAiProvider, '/admin/ai-provider');
      expect(Routes.adminPayProvider, '/admin/pay-provider');
      expect(Routes.adminBranding, '/admin/branding');
      expect(Routes.adminImportExport, '/admin/import-export');
      expect(Routes.adminRisiko, '/admin/risiko');
      expect(Routes.adminYayasan, '/admin/yayasan');
      expect(Routes.adminLaporanHarian, '/admin/laporan-harian');
      expect(Routes.adminAlumni, '/admin/alumni');
      expect(Routes.adminLms, '/admin/lms');
      expect(Routes.adminEmergency, '/admin/emergency');
      expect(Routes.adminCalendar, '/admin/calendar');
      expect(Routes.adminFinanceTools, '/admin/finance-tools');
    });
  });
}
