import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/welcome_popup.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _boot();
    });
  }

  /// Splash is transient: wait for auth boot, show the once-per-install
  /// welcome popup, then leave splash. Without this, dismissing the popup
  /// leaves only the spinner (loading terus) because the router keeps
  /// unauthenticated users on this public route.
  Future<void> _boot() async {
    AuthBloc? auth;
    try {
      auth = context.read<AuthBloc>();
    } catch (_) {
      // No AuthBloc in tree (widget tests) — stay on splash.
      return;
    }
    try {
      if (auth.state.status == AuthStatus.unknown) {
        await auth.stream
            .firstWhere((AuthState s) => s.status != AuthStatus.unknown)
            .timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      // Boot timeout — fall through to login below.
    }
    if (!mounted) return;
    try {
      await FirstLaunchService(store: PrefsFirstLaunchStore())
          .maybeShow(context);
    } catch (_) {
      // Popup/storage failure must never trap the user on splash.
    }
    if (!mounted) return;
    AuthState s;
    try {
      s = auth.state;
    } catch (_) {
      return;
    }
    if (s.status == AuthStatus.authenticated && s.user != null) {
      context.go(Routes.homeForRole(s.user!.role));
    } else {
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.school_rounded, size: 96, color: Colors.white),
              SizedBox(height: 16),
              Text(
                'eSchool',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
