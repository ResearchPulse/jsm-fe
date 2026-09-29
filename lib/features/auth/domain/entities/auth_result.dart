import 'auth_user.dart';

/// Result of a completed external authentication flow.
///
/// Tokens are intentionally NOT part of this object: they never cross into
/// the presentation layer. The repository persists them internally.
class AuthResult {
  final AuthUser user;

  const AuthResult({required this.user});
}
