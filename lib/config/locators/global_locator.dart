import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baseet/config/database/local/app_database.dart';
import '../../core/theme/theme_bloc/theme_bloc.dart';
import '../routes/route_config.dart';

final GetIt sl = GetIt.instance;

Future<void> initGlobalLocator(GetIt sl) async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // SQLite Database
  final appDb = AppDatabase();
  await appDb.init(seedIfEmpty: true);
  sl.registerLazySingleton<AppDatabase>(() => appDb);

  // Router
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  // ThemeBloc
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc(sl()));
}
