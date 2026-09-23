import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_provider.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Login page. Requires an [AuthCubit] above it (provided by AuthGate).
///
/// No local email/password form: the backend's web authentication page
/// handles credentials. This screen only launches the external flow
/// (see AuthRepositoryImpl for the backend integration point).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const _signInLabel = 'Sign in';
  static const _googleLabel = 'Continue with Google';

  void _launch(BuildContext context, AuthProvider provider) {
    context.read<AuthCubit>().login(provider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                // Authenticated -> root switch handled by AuthGate.
              },
              builder: (context, state) {
                final busy = state is AuthLoading;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        button: true,
                        label: _signInLabel,
                        child: ElevatedButton(
                          onPressed: busy
                              ? null
                              : () => _launch(context, AuthProvider.web),
                          child: busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text(_signInLabel),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Semantics(
                        button: true,
                        label: _googleLabel,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text(_googleLabel),
                          onPressed: busy
                              ? null
                              : () => _launch(context, AuthProvider.google),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
