import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/create_account_usecase.dart';

/// State for the account creation form.
abstract class CreateAccountState extends Equatable {
  const CreateAccountState();

  @override
  List<Object?> get props => [];
}

class CreateAccountInitial extends CreateAccountState {}

class CreateAccountSubmitting extends CreateAccountState {}

class CreateAccountSuccess extends CreateAccountState {
  final UserProfile user;
  const CreateAccountSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class CreateAccountFailure extends CreateAccountState {
  final String message;
  const CreateAccountFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

class CreateAccountCubit extends Cubit<CreateAccountState> {
  final CreateAccountUseCase createAccount;

  CreateAccountCubit({required this.createAccount})
      : super(CreateAccountInitial());

  Future<void> submit({
    required UserRole role,
    required String email,
    required String fullName,
    required String password,
  }) async {
    emit(CreateAccountSubmitting());
    try {
      final user = await createAccount(
        role: role,
        email: email,
        fullName: fullName,
        password: password,
      );
      emit(CreateAccountSuccess(user: user));
    } catch (e) {
      emit(CreateAccountFailure(message: _message(e)));
    }
  }

  void reset() => emit(CreateAccountInitial());

  static String _message(Object e) {
    var text = e.toString();
    // Strip "ServerException: "/"Exception: " prefixes and "(code: ...)"
    // suffixes so users see the backend's message, not the type name.
    text = text.replaceFirst(RegExp(r'^[A-Za-z]+Exception: '), '');
    text = text.replaceFirst(RegExp(r' \(code: [^)]*\)'), '');
    return text;
  }
}
