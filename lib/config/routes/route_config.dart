import 'package:go_router/go_router.dart';
import '../../core/common/widgets/layout/main_layout_page.dart';
import '../../core/utils/constants_manager.dart';
import '../../features/activation/presentation/pages/activation_page.dart';
import '../../features/debt_ledger/presentation/pages/add_customer_page.dart';
import '../../features/debt_ledger/presentation/pages/customer_statement_page.dart';
import '../../features/debt_ledger/presentation/pages/debt_ledger_page.dart';
import '../../features/debt_ledger/presentation/pages/payment_voucher_page.dart';
import '../../features/inventory/presentation/pages/add_category_page.dart';
import '../../features/inventory/presentation/pages/add_product_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/more_settings/presentation/pages/more_page.dart';
import '../../features/more_settings/presentation/pages/printer_settings_page.dart';
import '../../features/pos/presentation/pages/checkout_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/pos/presentation/pages/receipts_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/suppliers/presentation/pages/add_supplier_page.dart';
import '../../features/suppliers/presentation/pages/suppliers_page.dart';
import 'app_routes.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    navigatorKey: ConstantsManager.rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.activation,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) {
          final isExpired = state.uri.queryParameters['expired'] == 'true';
          return ActivationPage(isExpired: isExpired);
        },
      ),

      // Direct Routes
      GoRoute(
        path: AppRoutes.receipts,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) => const ReceiptsPage(),
      ),
      GoRoute(
        path: AppRoutes.suppliers,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) => const SuppliersPage(),
      ),
      GoRoute(
        path: AppRoutes.addSupplier,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) => const AddSupplierPage(),
      ),
      GoRoute(
        path: AppRoutes.printerSettings,
        parentNavigatorKey: ConstantsManager.rootNavigatorKey,
        builder: (context, state) => const PrinterSettingsPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutPage(navigationShell: navigationShell);
        },
        branches: [
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
                    builder: (context, state) => const CheckoutPage(),
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
                      return CustomerStatementPage(customerId: id);
                    },
                  ),
                  GoRoute(
                    path: 'add-customer',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => const AddCustomerPage(),
                  ),
                  GoRoute(
                    path: 'payment-voucher',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) {
                      final customerId = state.uri.queryParameters['customerId'];
                      return PaymentVoucherPage(customerId: customerId);
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
                builder: (context, state) => const InventoryPage(),
                routes: [
                  GoRoute(
                    path: 'add-product',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => const AddProductPage(),
                  ),
                  GoRoute(
                    path: 'add-category',
                    parentNavigatorKey: ConstantsManager.rootNavigatorKey,
                    builder: (context, state) => const AddCategoryPage(),
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
                builder: (context, state) => const MorePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
