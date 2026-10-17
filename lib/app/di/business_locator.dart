import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:baseet/features/business/data/datasources/business_local_datasource.dart';
import 'package:baseet/features/business/data/repositories/business_repository_impl.dart';
import 'package:baseet/features/business/domain/repositories/business_repository.dart';
import 'package:baseet/features/business/domain/usecases/business_usecases.dart';
import 'package:baseet/features/business/presentation/cubits/business_cubit.dart';
import 'package:baseet/features/business/presentation/cubits/product_editor_cubit.dart';
import 'package:baseet/features/business/presentation/cubits/store_settings_cubit.dart';
import 'package:baseet/features/device_transfer/data/datasources/backup_datasource.dart';
import 'package:baseet/features/device_transfer/data/datasources/local_transfer.dart';
import 'package:baseet/features/device_transfer/data/repositories/transfer_repository_impl.dart';
import 'package:baseet/features/device_transfer/domain/repositories/transfer_repository.dart';
import 'package:baseet/features/device_transfer/presentation/cubits/transfer_cubit.dart';

Future<void> initBusinessLocator(GetIt sl) async {
  sl.registerLazySingleton(() => BusinessLocalDataSource(sl(), sl()));
  sl.registerLazySingleton<BusinessRepository>(
      () => BusinessRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoadBusinessUseCase(sl()));
  sl.registerLazySingleton(() => SaveProductUseCase(sl()));
  sl.registerLazySingleton(() => SaveStoreUseCase(sl()));
  sl.registerFactory(() => BusinessCubit(sl()));
  sl.registerFactory(() => ProductEditorCubit(sl(), sl()));
  sl.registerFactory(() => StoreSettingsCubit(sl()));
  final Directory directory = await getApplicationSupportDirectory();
  sl.registerFactory<TransferRepository>(() => TransferRepositoryImpl(
      BackupDataSource(sl(), directory), LocalTransfer()));
  sl.registerFactory(() => TransferCubit(sl()));
}
