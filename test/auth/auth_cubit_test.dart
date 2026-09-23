import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_provider.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_result.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_user.dart';
import 'package:jsm_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:jsm_fe/features/auth/domain/usecases/login_usecase.dart';
import 'package:jsm_fe/features/auth/domain/usecases/logout_usecase.dart';
import 'package:jsm_fe/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:jsm_fe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:jsm_fe/features/auth/presentation/cubit/auth_state.dart';

/// Fake repository standing in for the external-browser flow:
/// never makes real OAuth or network requests.
class _FakeAuthRepository implements AuthRepository {
  AuthResult? loginResult;
  Object? loginError;
  AuthSession? storedSession;
  bool logoutCalled = false;

  @override
  Future<AuthResult> login(AuthProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (loginError != null) throw loginError!;
    return loginResult ?? AuthResult(user: AuthUser(email: 'user@jsm.dev'));
  }

  @override
  Future<AuthSession?> restoreSession() async => storedSession;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    storedSession = null;
  }
}

void main() {
  late _FakeAuthRepository repo;
  late AuthCubit cubit;

  setUp(() {
    repo = _FakeAuthRepository();
    cubit = AuthCubit(
      loginUseCase: LoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      restoreSessionUseCase: RestoreSessionUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  test('initial state is AuthInitial', () {
    expect(cubit.state, isA<AuthInitial>());
  });

  test('checkSession with no stored session emits AuthUnauthenticated',
      () async {
    await cubit.checkSession();
    expect(cubit.state, isA<AuthUnauthenticated>());
  });

  test('checkSession restores stored session -> AuthAuthenticated',
      () async {
    repo.storedSession = AuthSession(user: AuthUser(email: 'saved@jsm.dev'));
    await cubit.checkSession();
    expect(cubit.state, isA<AuthAuthenticated>());
    expect((cubit.state as AuthAuthenticated).user.email, 'saved@jsm.dev');
  });

  test('checkSession with throwing storage falls back to unauthenticated',
      () async {
    final throwing = _ThrowingRepo();
    final c = AuthCubit(
      loginUseCase: LoginUseCase(throwing),
      logoutUseCase: LogoutUseCase(throwing),
      restoreSessionUseCase: RestoreSessionUseCase(throwing),
    );
    await c.checkSession();
    expect(c.state, isA<AuthUnauthenticated>());
    await c.close();
  });

  test('login success emits loading then authenticated (web provider)',
      () async {
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.login(AuthProvider.web);
    await Future<void>.delayed(Duration.zero); // let stream deliver
    await sub.cancel();
    expect(
      states.map((s) => s.runtimeType),
      [AuthLoading, AuthAuthenticated],
    );
    expect((cubit.state as AuthAuthenticated).user.email, 'user@jsm.dev');
  });

  test('login with google provider passes provider through', () async {
    var seenProvider = AuthProvider.web;
    final recording = _RecordingRepo()
      ..onLogin = (p) => seenProvider = p;
    final c = AuthCubit(
      loginUseCase: LoginUseCase(recording),
      logoutUseCase: LogoutUseCase(recording),
      restoreSessionUseCase: RestoreSessionUseCase(recording),
    );
    await c.login(AuthProvider.google);
    expect(seenProvider, AuthProvider.google);
    await c.close();
  });

  test('login failure (invalid callback / denied) emits AuthFailure',
      () async {
    repo.loginError = ServerException('access_denied', 401);
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.login(AuthProvider.google);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(
      states.map((s) => s.runtimeType),
      [AuthLoading, AuthFailure],
    );
    expect((cubit.state as AuthFailure).message, contains('access_denied'));
  });

  test('logout emits AuthLoggedOut and clears session', () async {
    repo.storedSession = AuthSession(user: AuthUser(email: 'a@b.com'));
    final states = <AuthState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.logout();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(states.map((s) => s.runtimeType), [AuthLoading, AuthLoggedOut]);
    expect(repo.logoutCalled, isTrue);
    expect(repo.storedSession, isNull);
  });

  test('logout emits AuthLoggedOut even if repository throws', () async {
    final throwing = _ThrowingRepo();
    final c = AuthCubit(
      loginUseCase: LoginUseCase(throwing),
      logoutUseCase: LogoutUseCase(throwing),
      restoreSessionUseCase: RestoreSessionUseCase(throwing),
    );
    await c.logout();
    expect(c.state, isA<AuthLoggedOut>());
    await c.close();
  });
}

class _RecordingRepo implements AuthRepository {
  void Function(AuthProvider)? onLogin;

  @override
  Future<AuthResult> login(AuthProvider provider) async {
    onLogin?.call(provider);
    return AuthResult(user: AuthUser(email: 'g@jsm.dev'));
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}

class _ThrowingRepo implements AuthRepository {
  @override
  Future<AuthResult> login(AuthProvider provider) async =>
      throw ServerException();

  @override
  Future<AuthSession?> restoreSession() async => throw CacheException();

  @override
  Future<void> logout() async => throw Exception('boom');
}
