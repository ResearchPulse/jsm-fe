import 'package:equatable/equatable.dart';

/// Authenticated user identity.
///
/// NOTE: the backend auth response contract is not yet available in this
/// repository, so this entity intentionally contains only data the frontend
/// itself knows (the identifier the user typed). When the real contract is
/// confirmed, replace/extend the fields to mirror the actual backend user.
class AuthUser extends Equatable {
  final String email;

  const AuthUser({required this.email});

  @override
  List<Object?> get props => [email];
}
