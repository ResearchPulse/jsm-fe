import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// App just started; auth status not yet determined.
class AuthInitial extends AuthState {}

/// No session; user must log in.
class AuthUnauthenticated extends AuthState {}

/// Login request in flight.
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// User signed out (distinct from never-authenticated, for routing/logging).
class AuthLoggedOut extends AuthState {}
