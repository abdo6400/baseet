import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'package:baseet/app/di/global_locator.dart';
import 'package:baseet/app/router/route_config.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/app_theme.dart';
import 'package:baseet/core/theme/theme_bloc/theme_bloc.dart';
import 'package:baseet/core/theme/theme_bloc/theme_state.dart';
import 'package:baseet/core/utils/constants_manager.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/cart/cart_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'package:baseet/features/reports/presentation/blocs/reports/reports_bloc.dart';

class BaseetApp extends StatelessWidget {
  const BaseetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: sl<ThemeBloc>()),
        BlocProvider<CartBloc>.value(value: sl<CartBloc>()),
        BlocProvider<PosCatalogBloc>(create: (_) => sl<PosCatalogBloc>()),
        BlocProvider<CustomersListBloc>(create: (_) => sl<CustomersListBloc>()),
        BlocProvider<InventoryListBloc>(create: (_) => sl<InventoryListBloc>()),
        BlocProvider<ReportsBloc>(create: (_) => sl<ReportsBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ToastificationWrapper(
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              themeMode: themeState.mode,
              theme: AppTheme.buildLight(locale: context.locale),
              darkTheme: AppTheme.buildDark(locale: context.locale),
              scaffoldMessengerKey: ConstantsManager.snackBarKey,
              routerConfig: sl<AppRouter>().router,
              onGenerateTitle: (context) => StringsManager.appName.lang,
              builder: (context, child) {
                final mediaQueryData = MediaQuery.of(context);
                final clampedTextScaler = mediaQueryData.textScaler.clamp(
                  minScaleFactor: 1.0,
                  maxScaleFactor: 1.15,
                );
                return MediaQuery(
                  data: mediaQueryData.copyWith(
                    textScaler: clampedTextScaler,
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
