import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/usecases/auth_usecases.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

void registerAuthModule(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(() {
    try {
      return AuthRemoteDataSource(sl<FirebaseAuth>());
    } catch (_) {
      return const AuthRemoteDataSource();
    }
  });

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<SignIn>(() => SignIn(sl<AuthRepository>()));
  sl.registerLazySingleton<SignUp>(() => SignUp(sl<AuthRepository>()));
  sl.registerLazySingleton<SignOut>(() => SignOut(sl<AuthRepository>()));
  sl.registerLazySingleton<ResetPassword>(
    () => ResetPassword(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      repository: sl<AuthRepository>(),
      signIn: sl<SignIn>(),
      signUp: sl<SignUp>(),
      signOut: sl<SignOut>(),
      resetPassword: sl<ResetPassword>(),
    ),
  );
}
