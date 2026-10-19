import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../../features/admin/domain/repositories/admin_repository.dart';
import '../../../features/admin/domain/usecases/get_dashboard_stats.dart';
import '../../../features/admin/presentation/cubit/admin_dashboard_cubit.dart';

void registerAdminModule(GetIt sl) {
  sl.registerLazySingleton<AdminDataSource>(() {
    try {
      return AdminRemoteDataSource(sl<FirebaseFirestore>());
    } catch (_) {
      return AdminRemoteDataSource();
    }
  });

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminDataSource>()),
  );

  sl.registerLazySingleton<GetDashboardStats>(
    () => GetDashboardStats(sl<AdminRepository>()),
  );

  sl.registerFactory<AdminDashboardCubit>(
    () => AdminDashboardCubit(
      getDashboardStats: sl<GetDashboardStats>(),
      repository: sl<AdminRepository>(),
    ),
  );
}
