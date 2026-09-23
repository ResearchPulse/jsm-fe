import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_provider.dart';
import 'package:jsm_fe/features/auth/domain/usecases/auth_launcher.dart';

void main() {
  test(
    'repository login throws ServerException (backend contract not wired yet)',
    () async {
      final repo = AuthRepositoryImpl();
      expect(
        () => repo.login(AuthProvider.web),
        throwsA(isA<ServerException>()),
      );
    },
  );

  test('restoreSession returns null (no session storage yet)', () async {
    final repo = AuthRepositoryImpl();
    expect(await repo.restoreSession(), isNull);
  });

  test('logout completes without error (no session to clear)', () async {
    final repo = AuthRepositoryImpl();
    await repo.logout(); // must not throw
  });

  test(
    'AuthLauncher.start throws ServerException (no backend auth URL yet)',
    () async {
      final launcher = const AuthLauncher();
      expect(
        () => launcher.start(AuthProvider.google),
        throwsA(isA<ServerException>()),
      );
    },
  );

  test('AuthLauncher implements the launcher seam for the repository',
      () async {
    // The launcher is the single place browser/platform logic will live;
    // it must stay constructible and provider-addressable.
    const AuthLauncher();
    for (final p in AuthProvider.values) {
      await _expectThrows(p);
    }
  });
}

Future<void> _expectThrows(AuthProvider p) async {
  try {
    await const AuthLauncher().start(p);
    fail('expected ServerException for $p');
  } on ServerException {
    // expected
  }
}
