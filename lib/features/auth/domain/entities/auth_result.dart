import 'auth_user.dart';

/// Result of a completed external authentication flow.
///
/// Token/session fields must be added once the backend callback contract
/// is confirmed; until then the flow never produces one.
class AuthResult {
  final AuthUser user;

  const AuthResult({required this.user});
}
