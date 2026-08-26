abstract class AppRoutes {
  static const String splash = '/splash';

  // POS
  static const String pos = '/pos';
  static const String checkout = '/pos/checkout';

  // Debt Ledger
  static const String debts = '/debt-ledger';
  static const String customerStatement = '/debt-ledger/customer-statement/:id';
  static String customerStatementPath(String id) => '/debt-ledger/customer-statement/$id';

  static const String addCustomer = '/debt-ledger/add-customer';
  static const String paymentVoucher = '/debt-ledger/payment-voucher';
  static String paymentVoucherPath({String? customerId}) =>
      customerId != null && customerId.isNotEmpty
          ? '/debt-ledger/payment-voucher?customerId=$customerId'
          : '/debt-ledger/payment-voucher';

  // Inventory
  static const String inventory = '/inventory';
  static const String addProduct = '/inventory/add-product';
  static const String addCategory = '/inventory/add-category';

  // Reports & Settings
  static const String reports = '/reports';
  static const String more = '/more';
}
