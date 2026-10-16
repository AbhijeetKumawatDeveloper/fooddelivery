import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  const SignIn(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.signIn(email: email, password: password);
  }
}

class SignUp {
  final AuthRepository repository;
  const SignUp(this.repository);

  Future<AppUser> call(String email, String password, String displayName) {
    return repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

class SignOut {
  final AuthRepository repository;
  const SignOut(this.repository);

  Future<void> call() => repository.signOut();
}

class ResetPassword {
  final AuthRepository repository;
  const ResetPassword(this.repository);

  Future<void> call(String email) => repository.sendPasswordResetEmail(email);
}
