import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/users/domain/entities/user_profile.dart';
import 'package:jsm_fe/features/users/domain/repositories/users_repository.dart';
import 'package:jsm_fe/features/users/domain/usecases/create_account_usecase.dart';
import 'package:jsm_fe/features/users/presentation/cubit/create_account_cubit.dart';

class _FakeUsersRepository implements UsersRepository {
  Object? error;

  @override
  Future<UserProfile> createAccount({
    required UserRole role,
    required String email,
    required String fullName,
    required String password,
  }) async {
    if (error != null) throw error!;
    return UserProfile(id: 'u1', email: email, name: fullName);
  }
}

void main() {
  group('CreateAccountCubit', () {
    blocTest<CreateAccountCubit, CreateAccountState>(
      'emits submitting then success on valid submission',
      build: () => CreateAccountCubit(
          createAccount: CreateAccountUseCase(_FakeUsersRepository())),
      act: (cubit) => cubit.submit(
        role: UserRole.student,
        email: 's@university.edu',
        fullName: 'Sinh Vien',
        password: 'secret-pass-1',
      ),
      expect: () => [
        isA<CreateAccountSubmitting>(),
        isA<CreateAccountSuccess>()
            .having((s) => s.user.email, 'email', 's@university.edu'),
      ],
    );

    blocTest<CreateAccountCubit, CreateAccountState>(
      'emits failure (not crash) when the backend rejects the account',
      build: () {
        final repo = _FakeUsersRepository()..error = const ServerException('Email already used.');
        return CreateAccountCubit(createAccount: CreateAccountUseCase(repo));
      },
      act: (cubit) => cubit.submit(
        role: UserRole.lecturer,
        email: 'dup@university.edu',
        fullName: 'Giang Vien',
        password: 'secret-pass-1',
      ),
      expect: () => [
        isA<CreateAccountSubmitting>(),
        isA<CreateAccountFailure>()
            .having((s) => s.message, 'message', 'Email already used.'),
      ],
    );

    test('reset returns to the initial state', () {
      final cubit = CreateAccountCubit(
          createAccount: CreateAccountUseCase(_FakeUsersRepository()));
      cubit.reset();
      expect(cubit.state, isA<CreateAccountInitial>());
    });
  });
}
