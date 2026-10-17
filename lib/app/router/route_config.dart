import 'package:baseet/features/device_transfer/presentation/cubits/transfer_cubit.dart';
import 'package:baseet/features/device_transfer/presentation/pages/transfer_page.dart';
import 'package:baseet/features/business/presentation/cubits/store_settings_cubit.dart';
import 'package:baseet/features/business/presentation/cubits/product_editor_cubit.dart';
import 'package:baseet/features/business/presentation/pages/settings_page.dart';
import 'package:baseet/features/business/presentation/pages/sales_page.dart';
import 'package:baseet/features/business/presentation/pages/product_editor_page.dart';
import 'package:baseet/features/business/presentation/pages/products_page.dart';
import 'package:baseet/features/business/presentation/pages/home_page.dart';
import 'package:baseet/features/more_settings/presentation/blocs/data_management/data_management_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_category/add_category_bloc.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/payment_voucher/payment_voucher_bloc.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/customer_statement/customer_statement_bloc.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/add_customer/add_customer_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/checkout/checkout_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/app/di/global_locator.dart';
import 'package:baseet/app/presentation/cubits/process_lookups_cubit.dart';
import 'package:baseet/app/presentation/widgets/process_lookups_gate.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/common/widgets/layout/main_layout_page.dart';
import 'package:baseet/core/utils/constants_manager.dart';
import 'package:baseet/features/debt_ledger/presentation/pages/add_customer_page.dart';
import 'package:baseet/features/debt_ledger/presentation/pages/customer_statement_page.dart';
import 'package:baseet/features/debt_ledger/presentation/pages/debt_ledger_page.dart';
import 'package:baseet/features/debt_ledger/presentation/pages/payment_voucher_page.dart';
import 'package:baseet/features/inventory/presentation/pages/add_category_page.dart';
import 'package:baseet/features/pos/presentation/pages/checkout_page.dart';
import 'package:baseet/features/pos/presentation/pages/pos_page.dart';
import 'package:baseet/features/reports/presentation/pages/reports_page.dart';
import 'package:baseet/features/splash/presentation/pages/splash_page.dart';
import 'package:baseet/app/router/app_routes.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    navigatorKey: ConstantsManager.rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
          path: AppRoutes.sales,
          builder: (context, state) => const SalesPage()),
      GoRoute(
          path: AppRoutes.transfer,
          builder: (context, state) => BlocProvider(
              create: (_) => sl<TransferCubit>(), child: const TransferPage())),
      GoRoute(
        path: AppRoutes.splash,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage())
          ]),
          // Branch 0: POS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.pos,
                builder: (context, state) => const PosPage(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                        create: (_) => sl<CheckoutBloc>(),
                        child: BlocProvider(
                            create: (_) => ProcessLookupsCubit(sl(), sl())
                              ..load(customers: true),
                            child: ProcessLookupsGate(
                                customers: true, child: const CheckoutPage()))),
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Debts
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.debts,
                builder: (context, state) => const DebtLedgerPage(),
                routes: [
                  GoRoute(
                    path: 'customer-statement/:id',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return BlocProvider(
                          create: (_) => sl<CustomerStatementBloc>(),
                          child: CustomerStatementPage(customerId: id));
                    },
                  ),
                  GoRoute(
                    path: 'add-customer',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                        create: (_) => sl<AddCustomerBloc>(),
                        child: const AddCustomerPage()),
                  ),
                  GoRoute(
                    path: 'payment-voucher',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) {
                      final customerId =
                          state.uri.queryParameters['customerId'];
                      return BlocProvider(
                          create: (_) => sl<PaymentVoucherBloc>(),
                          child: BlocProvider(
                              create: (_) => ProcessLookupsCubit(sl(), sl())
                                ..load(customers: true),
                              child: ProcessLookupsGate(
                                  customers: true,
                                  child: PaymentVoucherPage(
                                      customerId: customerId))));
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Inventory
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.inventory,
                builder: (context, state) => const ProductsPage(),
                routes: [
                  GoRoute(
                    path: 'add-product',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                        create: (_) => sl<ProductEditorCubit>(),
                        child: const ProductEditorPage()),
                  ),
                  GoRoute(
                      path: 'edit/:id',
                      parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                      builder: (context, state) => BlocProvider(
                          create: (_) => sl<ProductEditorCubit>(),
                          child: ProductEditorPage(
                              productId: state.pathParameters['id']))),
                  GoRoute(
                    path: 'add-category',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                        create: (_) => sl<AddCategoryBloc>(),
                        child: const AddCategoryPage()),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => const ReportsPage(),
              ),
            ],
          ),

          // Branch 4: More
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) => BlocProvider(
                    create: (_) => sl<DataManagementBloc>(),
                    child: BlocProvider(
                        create: (_) => sl<StoreSettingsCubit>(),
                        child: const SettingsPage())),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
