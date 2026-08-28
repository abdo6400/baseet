abstract class AppRoutes {
  static const String splash = '/splash';
  static const String activation = '/activation';

  // POS & Receipts
  static const String pos = '/pos';
  static const String checkout = '/pos/checkout';
  static const String receipts = '/receipts';

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

  // Suppliers
  static const String suppliers = '/suppliers';
  static const String addSupplier = '/suppliers/add-supplier';
  static const String supplierStatement = '/suppliers/supplier-statement/:id';
  static String supplierStatementPath(String id) => '/suppliers/supplier-statement/$id';
  static const String addSupplierInvoice = '/suppliers/add-invoice';

  // Reports & Settings
  static const String reports = '/reports';
  static const String more = '/more';
  static const String printerSettings = '/more/printer-settings';
  static const String receiptSettings = '/more/receipt-settings';
  static const String backupSettings = '/more/backup-settings';
}
