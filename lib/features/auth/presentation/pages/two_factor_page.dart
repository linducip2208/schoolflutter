import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

/// Second-factor screen shown after login returns HTTP 202 with a
/// `challenge_id`. Accepts a 6-digit TOTP code or a recovery code.
class TwoFactorPage extends StatefulWidget {
  const TwoFactorPage({super.key});

  @override
  State<TwoFactorPage> createState() => _TwoFactorPageState();
}

class _TwoFactorPageState extends State<TwoFactorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _code = TextEditingController();
  bool _useRecovery = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final String value = _code.text.trim();
    context.read<AuthBloc>().add(AuthTwoFactorVerifyRequested(
          code: _useRecovery ? null : value,
          recoveryCode: _useRecovery ? value : null,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Dua Langkah')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext c, AuthState state) {
          if (state.status == AuthStatus.authenticated) {
            c.go(Routes.homeForRole(state.user!.role));
          } else if (state.status == AuthStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(c)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 24),
                  Text('Kode keamanan',
                      style: Theme.of(context).textTheme.displayLarge),
                  const SizedBox(height: 8),
                  Text(
                    _useRecovery
                        ? 'Masukkan salah satu kode pemulihan Anda.'
                        : 'Masukkan kode 6 digit dari aplikasi authenticator.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _code,
                    decoration: InputDecoration(
                      labelText:
                          _useRecovery ? 'Kode pemulihan' : 'Kode 6 digit',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: _useRecovery
                        ? null
                        : <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                    validator: (String? v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Kode wajib diisi';
                      }
                      if (!_useRecovery && v.trim().length != 6) {
                        return 'Kode harus 6 digit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        setState(() => _useRecovery = !_useRecovery),
                    child: Text(_useRecovery
                        ? 'Gunakan kode authenticator'
                        : 'Gunakan kode pemulihan'),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState p, AuthState c) =>
                        p.status != c.status,
                    builder: (BuildContext c, AuthState state) {
                      final bool busy =
                          state.status == AuthStatus.loggingIn;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : _submit,
                          child: busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Verifikasi'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
