import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  const AuthRepositoryImpl(this.dataSource);

  AppUser _mapUser(User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges => dataSource.authStateChanges.map(
    (user) => user == null ? null : _mapUser(user),
  );

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    return _mapUser(await dataSource.signIn(email: email, password: password));
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _mapUser(
      await dataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  @override
  Future<void> signOut() => dataSource.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      dataSource.sendPasswordResetEmail(email);
}
