import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final ResetPassword resetPassword;

  StreamSubscription? _authSubscription;

  AuthCubit({
    required this.repository,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.resetPassword,
  }) : super(const AuthState()) {
    _authSubscription = repository.authStateChanges.listen(
      (user) {
        if (isClosed) return;

        emit(
          state.copyWith(
            status: user == null
                ? AuthStatus.unauthenticated
                : AuthStatus.authenticated,
            user: user,
            clearUser: user == null,
            clearError: true,
          ),
        );
      },
      onError: (_) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              errorMessage: 'Unable to verify authentication.',
            ),
          );
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await signIn(email, password);
    } on FirebaseAuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _messageFor(error.code),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to sign in. Please try again.',
        ),
      );
    }
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await signUp(email, password, displayName);
    } on FirebaseAuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _messageFor(error.code),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to create your account.',
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await signOut();
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to log out. Please try again.',
        ),
      );
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    try {
      await resetPassword(email);
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearError: true),
      );
    } on FirebaseAuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _messageFor(error.code),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Unable to send the reset email.',
        ),
      );
    }
  }

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await super.close();
  }
}
