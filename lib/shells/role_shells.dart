import 'package:flutter/material.dart';

import '../app/router/routes.dart';
import '_shell_scaffold.dart';

/// Dedicated shells for non-core backend roles (docs role parity).
/// Each shell only links screens whose API the role may call
/// (verified against RolePermissionSeeder + controller gates).

class AccountantShell extends StatelessWidget {
  const AccountantShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Tagihan',
        route: Routes.accountantFees),
    ShellNavItem(
        icon: Icons.payments_outlined,
        activeIcon: Icons.payments,
        label: 'Payroll',
        route: Routes.accountantPayroll),
    ShellNavItem(
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment,
        label: 'Laporan',
        route: Routes.accountantReports),
    ShellNavItem(
        icon: Icons.account_balance_outlined,
        activeIcon: Icons.account_balance,
        label: 'Anggaran',
        route: Routes.accountantBudget),
    ShellNavItem(
        icon: Icons.volunteer_activism_outlined,
        activeIcon: Icons.volunteer_activism,
        label: 'Donasi',
        route: Routes.accountantDonasi),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.accountantProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class LibrarianShell extends StatelessWidget {
  const LibrarianShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: 'Katalog',
        route: Routes.librarianLibrary),
    ShellNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Notifikasi',
        route: Routes.notifications),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.librarianProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class NurseShell extends StatelessWidget {
  const NurseShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.medical_services_outlined,
        activeIcon: Icons.medical_services,
        label: 'UKS',
        route: Routes.nurseVisits),
    ShellNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Notifikasi',
        route: Routes.notifications),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.nurseProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class CounselorShell extends StatelessWidget {
  const CounselorShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.forum_outlined,
        activeIcon: Icons.forum,
        label: 'Konseling',
        route: Routes.counselorCounseling),
    ShellNavItem(
        icon: Icons.gavel_outlined,
        activeIcon: Icons.gavel,
        label: 'Disiplin',
        route: Routes.counselorDiscipline),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.counselorProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class PrincipalShell extends StatelessWidget {
  const PrincipalShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
        route: Routes.principalDashboard),
    ShellNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Keuangan',
        route: Routes.principalFees),
    ShellNavItem(
        icon: Icons.assessment_outlined,
        activeIcon: Icons.assessment,
        label: 'Laporan',
        route: Routes.principalReports),
    ShellNavItem(
        icon: Icons.account_balance_outlined,
        activeIcon: Icons.account_balance,
        label: 'Anggaran',
        route: Routes.principalBudget),
    ShellNavItem(
        icon: Icons.chat_outlined,
        activeIcon: Icons.chat,
        label: 'Chat',
        route: Routes.principalChat),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.principalProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class FrontDeskShell extends StatelessWidget {
  const FrontDeskShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
        label: 'Tamu',
        route: Routes.frontdeskVisitor),
    ShellNavItem(
        icon: Icons.person_add_outlined,
        activeIcon: Icons.person_add,
        label: 'Admisi',
        route: Routes.frontdeskAdmission),
    ShellNavItem(
        icon: Icons.how_to_reg_outlined,
        activeIcon: Icons.how_to_reg,
        label: 'PPDB',
        route: Routes.frontdeskPpdb),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.frontdeskProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class HrShell extends StatelessWidget {
  const HrShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.payments_outlined,
        activeIcon: Icons.payments,
        label: 'Payroll',
        route: Routes.hrPayroll),
    ShellNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Notifikasi',
        route: Routes.notifications),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.hrProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class TransportOpsShell extends StatelessWidget {
  const TransportOpsShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.directions_bus_outlined,
        activeIcon: Icons.directions_bus,
        label: 'Transport',
        route: Routes.transportOpsManage),
    ShellNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Notifikasi',
        route: Routes.notifications),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.transportOpsProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class HostelOpsShell extends StatelessWidget {
  const HostelOpsShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.apartment_outlined,
        activeIcon: Icons.apartment,
        label: 'Asrama',
        route: Routes.hostelOpsHome),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.hostelOpsProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class ProcurementShell extends StatelessWidget {
  const ProcurementShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: 'Inventaris',
        route: Routes.procurementInventory),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.procurementProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class GateShell extends StatelessWidget {
  const GateShell({super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Scan',
        route: Routes.gateScan),
    ShellNavItem(
        icon: Icons.sos_outlined,
        activeIcon: Icons.sos,
        label: 'Darurat',
        route: Routes.gateEmergency),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.gateProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class VisitorOpsShell extends StatelessWidget {
  const VisitorOpsShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
        label: 'Tamu',
        route: Routes.visitorOpsHome),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.visitorOpsProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class SchoolOpsShell extends StatelessWidget {
  const SchoolOpsShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.fastfood_outlined,
        activeIcon: Icons.fastfood,
        label: 'Kantin',
        route: Routes.schoolOpsCanteen),
    ShellNavItem(
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
        label: 'Tamu',
        route: Routes.schoolOpsVisitor),
    ShellNavItem(
        icon: Icons.sync_outlined,
        activeIcon: Icons.sync,
        label: 'Dapodik',
        route: Routes.schoolOpsDapodik),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.schoolOpsProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}

class FoundationShell extends StatelessWidget {
  const FoundationShell(
      {super.key, required this.child, required this.location});
  final Widget child;
  final String location;

  static const List<ShellNavItem> _items = <ShellNavItem>[
    ShellNavItem(
        icon: Icons.foundation_outlined,
        activeIcon: Icons.foundation,
        label: 'Yayasan',
        route: Routes.foundationHome),
    ShellNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: Routes.foundationProfile),
  ];

  @override
  Widget build(BuildContext context) =>
      ShellScaffold(child: child, location: location, items: _items);
}
