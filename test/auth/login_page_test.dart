import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_provider.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_result.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_user.dart';
import 'package:jsm_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:jsm_fe/features/auth/domain/usecases/login_usecase.dart';
import 'package:jsm_fe/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jsm_fe/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:jsm_fe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jsm_fe/features/auth/presentation/cubit/auth_state.dart';
import 'package:jsm_fe/features/auth/presentation/pages/login_page.dart';

/// Stub repository standing in for the external-browser flow:
/// never launches a browser or makes real OAuth requests.
class _StubRepo implements AuthRepository {
  Object? loginError;

  @override
  Future<AuthResult> login(AuthProvider provider) async {
    // Real timer so the loading state is observable before completion.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (loginError != null) throw loginError!;
    return AuthResult(user: AuthUser(email: 'user@jsm.dev'));
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}

Widget _wrap(AuthRepository repo) => BlocProvider(
      create: (_) => AuthCubit(
            loginUseCase: LoginUseCase(repo),
            logoutUseCase: LogoutUseCase(repo),
            restoreSessionUseCase: RestoreSessionUseCase(repo),
          )..checkSession(),
      child: const MaterialApp(home: LoginPage()),
    );

void main() {
  testWidgets('unauthenticated start renders Sign in and Google buttons',
      (tester) async {
    final repo = _StubRepo();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle(); // checkSession -> unauthenticated
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Continue with Google'), findsOneWidget);
    // No local credential form: the web page handles email/password.
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('tapping Sign in launches the web auth flow', (tester) async {
    final repo = _StubRepo();
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // begin loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(LoginView));
    expect(ctx.read<AuthCubit>().state, isA<AuthAuthenticated>());
  });

  testWidgets('tapping Continue with Google launches the google flow',
      (tester) async {
    var launchedProvider = AuthProvider.web;
    final repo = _ProviderSpyRepo((p) => launchedProvider = p);
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(launchedProvider, AuthProvider.google);
  });

  testWidgets('auth failure surfaces a snackbar, stays on login',
      (tester) async {
    final repo = _StubRepo()..loginError = Exception('access_denied');
    await tester.pumpWidget(_wrap(repo));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    final ctx = tester.element(find.byType(LoginView));
    expect(ctx.read<AuthCubit>().state, isA<AuthFailure>());
  });
}

class _ProviderSpyRepo implements AuthRepository {
  final void Function(AuthProvider) onLogin;
  _ProviderSpyRepo(this.onLogin);

  @override
  Future<AuthResult> login(AuthProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    onLogin(provider);
    return AuthResult(user: AuthUser(email: 'g@jsm.dev'));
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}
