import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import 'auth_state.dart';

/// Manages authentication state. All browser/callback/launcher logic
/// lives in the repository layer, never in widgets.
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final RestoreSessionUseCase restoreSessionUseCase;
  final AuthRepository repository;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.restoreSessionUseCase,
    required this.repository,
  }) : super(AuthInitial());

  /// Called once at app start: processes the SSO callback page load (if
  /// this is one), otherwise restores the persisted session, if any.
  Future<void> checkSession() async {
    try {
      AuthResult? result;
      try {
        result = await repository.handleCallback();
      } catch (e) {
        // Invalid state / missing code / failed exchange: safe failure, no
        // crash, no partial authentication.
        emit(AuthFailure(message: _sanitize(e)));
        return;
      }
      if (result != null) {
        emit(AuthAuthenticated(user: result.user));
        return;
      }
      final session = await restoreSessionUseCase();
      if (session != null) {
        emit(AuthAuthenticated(user: session.user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      // A failed restore (expired/invalid session, storage error) means
      // unauthenticated, not a crash.
      emit(AuthUnauthenticated());
    }
  }

  /// Issues the redirect to the SSO authorize page. On web the browser
  /// navigates away; the result arrives via checkSession() on the callback
  /// page load. If the redirect could not be issued, recoverable failure.
  Future<void> login(AuthProvider provider) async {
    emit(AuthLoading());
    try {
      await loginUseCase(provider);
      // Web: the browser navigated away — nothing more to do here.
      // Desktop: the full flow (browser + loopback callback + exchange)
      // already finished inside the repository; pick up the session.
      final session = await restoreSessionUseCase();
      if (session != null) {
        emit(AuthAuthenticated(user: session.user));
      }
    } catch (e) {
      emit(AuthFailure(message: _sanitize(e)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
    } catch (_) {
      // Logout must always leave the user signed out locally, even if the
      // session invalidation fails.
    }
    emit(AuthLoggedOut());
  }

  /// Maps any error to a user-safe message: exception text from the data
  /// layer never contains tokens, but keep this as the single funnel so
  /// raw internals are not surfaced verbatim.
  String _sanitize(Object e) {
    final text = e.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}
