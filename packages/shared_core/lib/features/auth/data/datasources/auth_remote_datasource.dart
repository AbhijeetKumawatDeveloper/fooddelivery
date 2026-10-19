import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth? firebaseAuth;

  const AuthRemoteDataSource([this.firebaseAuth]);

  Stream<User?> get authStateChanges =>
      firebaseAuth?.authStateChanges() ?? const Stream.empty();

  Future<User> signIn({required String email, required String password}) async {
    final auth = firebaseAuth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'no-firebase-app',
        message: 'Firebase is not initialized.',
      );
    }

    final result = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in.',
      );
    }

    return user;
  }

  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final auth = firebaseAuth;
    if (auth == null) {
      throw FirebaseAuthException(
        code: 'no-firebase-app',
        message: 'Firebase is not initialized.',
      );
    }

    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Account creation failed.',
      );
    }

    await user.updateDisplayName(displayName.trim());
    await user.reload();

    return auth.currentUser ?? user;
  }

  Future<void> signOut() async {
    await firebaseAuth?.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await firebaseAuth?.sendPasswordResetEmail(email: email.trim());
  }
}
