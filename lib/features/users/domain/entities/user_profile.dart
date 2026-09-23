import 'package:equatable/equatable.dart';

/// An account created by an admin via the users module.
class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? name;

  const UserProfile({
    required this.id,
    required this.email,
    this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}

/// Account role supported by the backend users module.
enum UserRole {
  student('student'),
  lecturer('lecturer');

  final String value;
  const UserRole(this.value);
}
