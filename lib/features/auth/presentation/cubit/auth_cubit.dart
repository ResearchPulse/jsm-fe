import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_provider.dart';
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

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.restoreSessionUseCase,
  }) : super(AuthInitial());

  /// Called once at app start: restores the persisted session, if any.
  Future<void> checkSession() async {
    try {
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

  /// Launches the external authentication flow (web login page or
  /// Google OAuth); completes when the backend redirects back.
  Future<void> login(AuthProvider provider) async {
    emit(AuthLoading());
    try {
      final result = await loginUseCase(provider);
      emit(AuthAuthenticated(user: result.user));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await logoutUseCase();
    } catch (_) {
      // Logout must always leave the user signed out locally, even if the
      // backend session invalidation fails.
    }
    emit(AuthLoggedOut());
  }
}
