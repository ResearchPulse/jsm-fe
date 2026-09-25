import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../features/auth/domain/entities/auth_provider.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';

/// Root gate of the app: switches between loading, Login, Home, and
/// recoverable error based on authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthSwitch();
  }
}

class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomePage();
        }
        if (state is AuthInitial || state is AuthLoading) {
          // Session check / flow in flight: not a login screen frame.
          return const Scaffold(
            body: LoadingView(message: 'Checking session…'),
          );
        }
        if (state is AuthFailure) {
          // Recoverable error: user can retry the login flow.
          return Scaffold(
            body: ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AuthCubit>().login(AuthProvider.web),
            ),
          );
        }
        // AuthUnauthenticated, AuthLoggedOut: show Login.
        return const LoginPage();
      },
    );
  }
}
