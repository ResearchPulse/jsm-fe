import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/domain/usecases/get_featured_journals_usecase.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../features/auth/domain/entities/auth_provider.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/users/data/repositories/users_repository_impl.dart';
import '../features/users/domain/usecases/create_account_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'auth_cubit_scope.dart';

/// Root of the app: provides AuthCubit at the app level and switches
/// between loading, Login, Home, and recoverable error based on
/// authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => HomeRepositoryImpl()),
        RepositoryProvider<CreateAccountUseCase>(
          create: (context) {
            final authRepo = context.read<AuthRepository>();
            return CreateAccountUseCase(
                UsersRepositoryImpl(authRepository: authRepo));
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeCubit(
              getFeaturedJournalsUseCase: GetFeaturedJournalsUseCase(
                context.read<HomeRepositoryImpl>(),
              ),
            ),
          ),
        ],
        child: const AuthCubitScope(child: _AuthSwitch()),
      ),
    );
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
