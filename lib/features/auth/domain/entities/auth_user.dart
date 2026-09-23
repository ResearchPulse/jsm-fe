import 'package:equatable/equatable.dart';

/// Authenticated user identity, sourced from Central SSO userinfo.
class AuthUser extends Equatable {
  final String sub;
  final String? email;
  final String? name;
  final String? picture;

  const AuthUser({
    required this.sub,
    this.email,
    this.name,
    this.picture,
  });

  @override
  List<Object?> get props => [sub, email, name, picture];
}
