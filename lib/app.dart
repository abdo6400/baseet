import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'config/locators/global_locator.dart';
import 'config/routes/route_config.dart';
import 'core/extensions/translation_extension.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc/theme_bloc.dart';
import 'core/theme/theme_bloc/theme_state.dart';
import 'core/utils/constants_manager.dart';
import 'core/utils/strings_manager.dart';
import 'features/debt_ledger/presentation/blocs/add_customer/add_customer_bloc.dart';
import 'features/debt_ledger/presentation/blocs/customer_statement/customer_statement_bloc.dart';
import 'features/debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import 'features/debt_ledger/presentation/blocs/payment_voucher/payment_voucher_bloc.dart';
import 'features/inventory/presentation/blocs/add_category/add_category_bloc.dart';
import 'features/inventory/presentation/blocs/add_product/add_product_bloc.dart';
import 'features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'features/pos/presentation/blocs/cart/cart_bloc.dart';
import 'features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'features/pos/presentation/blocs/checkout/checkout_bloc.dart';
import 'features/pos/presentation/blocs/receipts/pos_receipts_bloc.dart';
import 'features/reports/presentation/blocs/reports/reports_bloc.dart';

class BaseetApp extends StatelessWidget {
  const BaseetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => sl<ThemeBloc>()),
        BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
        BlocProvider<PosCatalogBloc>(create: (_) => sl<PosCatalogBloc>()),
        BlocProvider<CheckoutBloc>(create: (_) => sl<CheckoutBloc>()),
        BlocProvider<PosReceiptsBloc>(create: (_) => sl<PosReceiptsBloc>()),
        BlocProvider<CustomersListBloc>(create: (_) => sl<CustomersListBloc>()),
        BlocProvider<CustomerStatementBloc>(create: (_) => sl<CustomerStatementBloc>()),
        BlocProvider<AddCustomerBloc>(create: (_) => sl<AddCustomerBloc>()),
        BlocProvider<PaymentVoucherBloc>(create: (_) => sl<PaymentVoucherBloc>()),
        BlocProvider<InventoryListBloc>(create: (_) => sl<InventoryListBloc>()),
        BlocProvider<AddProductBloc>(create: (_) => sl<AddProductBloc>()),
        BlocProvider<AddCategoryBloc>(create: (_) => sl<AddCategoryBloc>()),
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
