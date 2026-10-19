import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../../features/delivery_partner/data/datasources/delivery_remote_datasource.dart';
import '../../../features/delivery_partner/data/repositories/delivery_repository_impl.dart';
import '../../../features/delivery_partner/domain/repositories/delivery_repository.dart';
import '../../../features/delivery_partner/domain/usecases/update_delivery_location.dart';
import '../../../features/delivery_partner/domain/usecases/update_delivery_status.dart';
import '../../../features/delivery_partner/domain/usecases/watch_assigned_orders.dart';
import '../../../features/delivery_partner/presentation/cubit/delivery_cubit.dart';

void registerDeliveryModule(GetIt sl) {
  sl.registerLazySingleton<DeliveryDataSource>(() {
    try {
      return DeliveryRemoteDataSource(sl<FirebaseFirestore>());
    } catch (_) {
      return DeliveryRemoteDataSource();
    }
  });

  sl.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(sl<DeliveryDataSource>()),
  );

  sl.registerLazySingleton<WatchAssignedOrders>(
    () => WatchAssignedOrders(sl<DeliveryRepository>()),
  );

  sl.registerLazySingleton<UpdateDeliveryStatus>(
    () => UpdateDeliveryStatus(sl<DeliveryRepository>()),
  );

  sl.registerLazySingleton<UpdateDeliveryLocation>(
    () => UpdateDeliveryLocation(sl<DeliveryRepository>()),
  );

  sl.registerFactory<DeliveryCubit>(
    () => DeliveryCubit(
      watchAssignedOrders: sl<WatchAssignedOrders>(),
      updateDeliveryStatus: sl<UpdateDeliveryStatus>(),
      updateDeliveryLocation: sl<UpdateDeliveryLocation>(),
      repository: sl<DeliveryRepository>(),
    ),
  );
}
