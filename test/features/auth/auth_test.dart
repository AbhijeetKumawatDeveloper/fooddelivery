import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fooddelivery/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fooddelivery/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fooddelivery/features/auth/domain/entities/app_user.dart';
import 'package:fooddelivery/features/auth/domain/repositories/auth_repository.dart';
import 'package:fooddelivery/features/auth/domain/usecases/auth_usecases.dart';
import 'package:fooddelivery/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:fooddelivery/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUser extends Mock implements User {}

void main() {
  group('AppUser Entity Tests', () {
    test('props contain id, email, and displayName', () {
      const user1 = AppUser(
        id: 'u1',
        email: 'test@foodgo.com',
        displayName: 'Chef John',
      );
      const user2 = AppUser(
        id: 'u1',
        email: 'test@foodgo.com',
        displayName: 'Chef John',
      );

      expect(user1, equals(user2));
      expect(user1.props, ['u1', 'test@foodgo.com', 'Chef John']);
    });
  });

  group('AuthRepositoryImpl Tests', () {
    late MockAuthRemoteDataSource dataSource;
    late AuthRepositoryImpl repository;
    late MockUser mockUser;

    setUp(() {
      dataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(dataSource);
      mockUser = MockUser();

      when(() => mockUser.uid).thenReturn('u123');
      when(() => mockUser.email).thenReturn('alex@foodgo.com');
      when(() => mockUser.displayName).thenReturn('Alex');
    });

    test('signIn calls data source and returns mapped AppUser', () async {
      when(
        () => dataSource.signIn(
          email: 'alex@foodgo.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUser);

      final user = await repository.signIn(
        email: 'alex@foodgo.com',
        password: 'password123',
      );

      expect(user.id, 'u123');
      expect(user.email, 'alex@foodgo.com');
      expect(user.displayName, 'Alex');
    });

    test('signUp calls data source and returns mapped AppUser', () async {
      when(
        () => dataSource.signUp(
          email: 'alex@foodgo.com',
          password: 'password123',
          displayName: 'Alex',
        ),
      ).thenAnswer((_) async => mockUser);

      final user = await repository.signUp(
        email: 'alex@foodgo.com',
        password: 'password123',
        displayName: 'Alex',
      );

      expect(user.id, 'u123');
      expect(user.email, 'alex@foodgo.com');
      expect(user.displayName, 'Alex');
    });

    test('signOut calls data source signOut', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => dataSource.signOut()).called(1);
    });

    test('sendPasswordResetEmail calls data source', () async {
      when(() => dataSource.sendPasswordResetEmail('alex@foodgo.com'))
          .thenAnswer((_) async {});

      await repository.sendPasswordResetEmail('alex@foodgo.com');

      verify(() => dataSource.sendPasswordResetEmail('alex@foodgo.com'))
          .called(1);
    });
  });

  group('AuthCubit Tests', () {
    late MockAuthRepository repository;
    late StreamController<AppUser?> authStateController;
    late AuthCubit authCubit;

    setUp(() {
      repository = MockAuthRepository();
      authStateController = StreamController<AppUser?>.broadcast();

      when(() => repository.authStateChanges)
          .thenAnswer((_) => authStateController.stream);

      authCubit = AuthCubit(
        repository: repository,
        signIn: SignIn(repository),
        signUp: SignUp(repository),
        signOut: SignOut(repository),
        resetPassword: ResetPassword(repository),
      );
    });

    tearDown(() async {
      await authCubit.close();
      await authStateController.close();
    });

    test('initial state has AuthStatus.initial and no user', () {
      expect(authCubit.state.status, AuthStatus.initial);
      expect(authCubit.state.user, isNull);
    });

    test(
      'updates state to authenticated when authStateChanges emits user',
      () async {
        const user = AppUser(
          id: 'u1',
          email: 'user@foodgo.com',
          displayName: 'User One',
        );

        authStateController.add(user);
        await pumpEventQueue();

        expect(authCubit.state.status, AuthStatus.authenticated);
        expect(authCubit.state.user, user);
      },
    );

    test(
      'updates state to unauthenticated when authStateChanges emits null',
      () async {
        authStateController.add(null);
        await pumpEventQueue();

        expect(authCubit.state.status, AuthStatus.unauthenticated);
        expect(authCubit.state.user, isNull);
      },
    );

    test('login emits [loading] then handles success', () async {
      const user = AppUser(id: 'u1', email: 'login@foodgo.com');

      when(
        () => repository.signIn(
          email: 'login@foodgo.com',
          password: 'secretpassword',
        ),
      ).thenAnswer((_) async => user);

      final expectation = expectLater(
        authCubit.stream,
        emits(
          predicate<AuthState>((state) => state.status == AuthStatus.loading),
        ),
      );

      await authCubit.login('login@foodgo.com', 'secretpassword');
      await expectation;
    });

    test('login handles FirebaseAuthException with friendly message', () async {
      when(() => repository.signIn(email: 'fail@foodgo.com', password: 'wrong'))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expectLater(
        authCubit.stream,
        emitsInOrder([
          predicate<AuthState>((state) => state.status == AuthStatus.loading),
          predicate<AuthState>(
            (state) =>
                state.status == AuthStatus.failure &&
                state.errorMessage == 'Email or password is incorrect.',
          ),
        ]),
      );

      await authCubit.login('fail@foodgo.com', 'wrong');
    });

    test('register handles email-already-in-use exception', () async {
      when(
        () => repository.signUp(
          email: 'exists@foodgo.com',
          password: 'password123',
          displayName: 'Existing User',
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expectLater(
        authCubit.stream,
        emitsInOrder([
          predicate<AuthState>((state) => state.status == AuthStatus.loading),
          predicate<AuthState>(
            (state) =>
                state.status == AuthStatus.failure &&
                state.errorMessage ==
                    'An account already exists with this email.',
          ),
        ]),
      );

      await authCubit.register(
        'exists@foodgo.com',
        'password123',
        'Existing User',
      );
    });

    test('logout calls repository signOut', () async {
      when(() => repository.signOut()).thenAnswer((_) async {});

      await authCubit.logout();

      verify(() => repository.signOut()).called(1);
    });

    test('forgotPassword handles success and failure', () async {
      when(() => repository.sendPasswordResetEmail('reset@foodgo.com'))
          .thenAnswer((_) async {});

      expectLater(
        authCubit.stream,
        emitsInOrder([
          predicate<AuthState>((state) => state.status == AuthStatus.loading),
          predicate<AuthState>(
            (state) => state.status == AuthStatus.unauthenticated,
          ),
        ]),
      );

      await authCubit.forgotPassword('reset@foodgo.com');
    });
  });
}
