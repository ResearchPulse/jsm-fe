import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_provider.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_result.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_user.dart';
import 'package:jsm_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:jsm_fe/features/auth/domain/usecases/login_usecase.dart';

class _RecordingRepo implements AuthRepository {
  AuthProvider? provider;
  Object? error;

  @override
  Future<void> login(AuthProvider p) async {
    provider = p;
    if (error != null) throw error!;
  }

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<AuthResult?> handleCallback() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<String?> currentToken() async => null;

  @override
  Future<AuthUser> mockLogin({
    required String sub,
    required String email,
    required String name,
    required String role,
  }) async {
    return AuthUser(sub: sub, email: email, name: name, role: role);
  }
}

void main() {
  test('delegates login to the repository with the provider', () async {
    final repo = _RecordingRepo();
    final useCase = LoginUseCase(repo);

    await useCase(AuthProvider.google);

    expect(repo.provider, AuthProvider.google);
  });

  test('propagates repository failures untouched', () async {
    final repo = _RecordingRepo()..error = Exception('no browser');
    final useCase = LoginUseCase(repo);

    await expectLater(
        useCase(AuthProvider.web), throwsA(isA<Exception>()));
    expect(repo.provider, AuthProvider.web);
  });
}
