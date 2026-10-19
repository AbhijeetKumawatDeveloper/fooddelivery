import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../../features/restaurant_partner/data/datasources/partner_order_datasource.dart';
import '../../../features/restaurant_partner/data/repositories/partner_order_repository_impl.dart';
import '../../../features/restaurant_partner/domain/repositories/partner_order_repository.dart';
import '../../../features/restaurant_partner/domain/usecases/update_order_status.dart';
import '../../../features/restaurant_partner/domain/usecases/watch_partner_orders.dart';
import '../../../features/restaurant_partner/presentation/cubit/partner_order_cubit.dart';

void registerPartnerModule(GetIt sl) {
  sl.registerLazySingleton<PartnerOrderDataSource>(() {
    try {
      return PartnerOrderRemoteDataSource(sl<FirebaseFirestore>());
    } catch (_) {
      return PartnerOrderRemoteDataSource();
    }
  });

  sl.registerLazySingleton<PartnerOrderRepository>(
    () => PartnerOrderRepositoryImpl(sl<PartnerOrderDataSource>()),
  );

  sl.registerLazySingleton<WatchPartnerOrders>(
    () => WatchPartnerOrders(sl<PartnerOrderRepository>()),
  );

  sl.registerLazySingleton<UpdateOrderStatus>(
    () => UpdateOrderStatus(sl<PartnerOrderRepository>()),
  );

  sl.registerFactory<PartnerOrderCubit>(
    () => PartnerOrderCubit(
      watchPartnerOrders: sl<WatchPartnerOrders>(),
      updateOrderStatus: sl<UpdateOrderStatus>(),
      repository: sl<PartnerOrderRepository>(),
    ),
  );
}
