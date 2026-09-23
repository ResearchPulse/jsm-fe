import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/restore_session_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

/// Creates the app-level AuthCubit and checks the persisted session on
/// start (currently always unauthenticated — the backend session
/// contract is not available yet; see AuthRepositoryImpl).
class AuthCubitScope extends StatelessWidget {
  final Widget child;

  const AuthCubitScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repo = AuthRepositoryImpl();
        return AuthCubit(
          loginUseCase: LoginUseCase(repo),
          logoutUseCase: LogoutUseCase(repo),
          restoreSessionUseCase: RestoreSessionUseCase(repo),
        )..checkSession();
      },
      child: child,
    );
  }
}
