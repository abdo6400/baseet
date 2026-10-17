import 'package:get_it/get_it.dart';
import 'package:baseet/core/services/operation_context.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/core/theme/theme_bloc/theme_bloc.dart';
import 'package:baseet/app/router/route_config.dart';

final GetIt sl = GetIt.instance;

Future<void> initGlobalLocator(GetIt sl) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<OperationContext>(
      () => const SystemOperationContext());

  // SQLite Database
  final appDb = AppDatabase();
  await appDb.init(seedIfEmpty: const bool.fromEnvironment('DEMO_MODE'));
  sl.registerLazySingleton<AppDatabase>(() => appDb);

  // Router
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  // ThemeBloc
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc(sl()));
}
