abstract class StringsManager {
  static const String appName = 'app_name';
  static const String appSubtitle = 'app_subtitle';
  static const String cashier = 'cashier';

  // Navigation
  static const String navPos = 'nav_pos';
  static const String navDebts = 'nav_debts';
  static const String navInventory = 'nav_inventory';
  static const String navReports = 'nav_reports';
  static const String navMore = 'nav_more';

  // POS
  static const String posTitle = 'pos_title';
  static const String posDailySales = 'pos_daily_sales';
  static const String posAllCategories = 'pos_all_categories';
  static const String posSearchProduct = 'pos_search_product';
  static const String posAvailable = 'pos_available';
  static const String posCurrency = 'pos_currency';
  static const String posTotal = 'pos_total';
  static const String posItemsCount = 'pos_items_count';
  static const String posCheckout = 'pos_checkout';
  static const String posEmptyCart = 'pos_empty_cart';
  static const String posAddToCart = 'pos_add_to_cart';
  static const String posNoProductsFound = 'pos_no_products_found';

  // Checkout
  static const String checkoutTitle = 'checkout_title';
  static const String checkoutOrderSummary = 'checkout_order_summary';
  static const String checkoutPaymentMethod = 'checkout_payment_method';
  static const String checkoutCash = 'checkout_cash';
  static const String checkoutDebt = 'checkout_debt';
  static const String checkoutCard = 'checkout_card';
  static const String checkoutCustomer = 'checkout_customer';
  static const String checkoutSelectCustomer = 'checkout_select_customer';
  static const String checkoutReceivedAmount = 'checkout_received_amount';
  static const String checkoutRemainingAmount = 'checkout_remaining_amount';
  static const String checkoutNotes = 'checkout_notes';
  static const String checkoutNotesHint = 'checkout_notes_hint';
  static const String checkoutConfirm = 'checkout_confirm';
  static const String checkoutSuccess = 'checkout_success';
  static const String checkoutErrorSelectCustomer = 'checkout_error_select_customer';

  // Debts
  static const String debtsTitle = 'debts_title';
  static const String debtsSubtitle = 'debts_subtitle';
  static const String debtsTotal = 'debts_total';
  static const String debtsOverdue = 'debts_overdue';
  static const String debtsTodayCollections = 'debts_today_collections';
  static const String debtsSearchCustomer = 'debts_search_customer';
  static const String debtsFilterAll = 'debts_filter_all';
  static const String debtsFilterOverdue = 'debts_filter_overdue';
  static const String debtsFilterRegular = 'debts_filter_regular';
  static const String debtsFilterHighest = 'debts_filter_highest';
  static const String debtsStatusOverdue = 'debts_status_overdue';
  static const String debtsStatusRegular = 'debts_status_regular';
  static const String debtsStatusLimitExceeded = 'debts_status_limit_exceeded';
  static const String debtsLastPayment = 'debts_last_payment';
  static const String debtsActionRemind = 'debts_action_remind';
  static const String debtsActionVoucher = 'debts_action_voucher';
  static const String debtsAddCustomer = 'debts_add_customer';
  static const String debtsNoCustomersFound = 'debts_no_customers_found';
  static const String debtsDebtSuffix = 'debts_debt_suffix';

  // Customer Statement
  static const String customerStatementTitle = 'customer_statement_title';
  static const String customerTotalBalance = 'customer_total_balance';
  static const String customerCreditLimit = 'customer_credit_limit';
  static const String customerPhone = 'customer_phone';
  static const String customerCall = 'customer_call';
  static const String customerWhatsapp = 'customer_whatsapp';
  static const String customerWhatsappReminder = 'customer_whatsapp_reminder';
  static const String customerTransactionsHistory = 'customer_transactions_history';
  static const String customerAddDebt = 'customer_add_debt';
  static const String customerSettleDebt = 'customer_settle_debt';
  static const String customerStatementShare = 'customer_statement_share';
  static const String customerTypeSale = 'customer_type_sale';
  static const String customerTypePayment = 'customer_type_payment';
  static const String customerNoTransactions = 'customer_no_transactions';

  // Add Customer
  static const String addCustomerTitle = 'add_customer_title';
  static const String addCustomerName = 'add_customer_name';
  static const String addCustomerNameHint = 'add_customer_name_hint';
  static const String addCustomerPhone = 'add_customer_phone';
  static const String addCustomerPhoneHint = 'add_customer_phone_hint';
  static const String addCustomerCreditLimit = 'add_customer_credit_limit';
  static const String addCustomerLimitHint = 'add_customer_limit_hint';
  static const String addCustomerAddress = 'add_customer_address';
  static const String addCustomerAddressHint = 'add_customer_address_hint';
  static const String addCustomerNotes = 'add_customer_notes';
  static const String addCustomerNotesHint = 'add_customer_notes_hint';
  static const String addCustomerSave = 'add_customer_save';
  static const String addCustomerSuccess = 'add_customer_success';

  // Voucher
  static const String voucherTitle = 'voucher_title';
  static const String voucherAmount = 'voucher_amount';
  static const String voucherCustomer = 'voucher_customer';
  static const String voucherSelectCustomer = 'voucher_select_customer';
  static const String voucherRemaining = 'voucher_remaining';
  static const String voucherMethod = 'voucher_method';
  static const String voucherReceiptNo = 'voucher_receipt_no';
  static const String voucherNotes = 'voucher_notes';
  static const String voucherNotesHint = 'voucher_notes_hint';
  static const String voucherSave = 'voucher_save';
  static const String voucherSuccess = 'voucher_success';
  static const String voucherErrorInvalidAmount = 'voucher_error_invalid_amount';

  // Inventory
  static const String inventoryTitle = 'inventory_title';
  static const String inventorySubtitle = 'inventory_subtitle';
  static const String inventoryTotalProducts = 'inventory_total_products';
  static const String inventoryLowStock = 'inventory_low_stock';
  static const String inventoryStockValue = 'inventory_stock_value';
  static const String inventorySearch = 'inventory_search';
  static const String inventoryAddProduct = 'inventory_add_product';
  static const String inventoryAddCategory = 'inventory_add_category';
  static const String inventoryBuyPrice = 'inventory_buy_price';
  static const String inventorySellPrice = 'inventory_sell_price';
  static const String inventoryStockCount = 'inventory_stock_count';
  static const String inventoryNoProductsFound = 'inventory_no_products_found';
  static const String inventoryStockQuantityLabel = 'inventory_stock_quantity_label';
  static const String inventoryBuyPriceLabel = 'inventory_buy_price_label';

  // Add Product
  static const String addProductTitle = 'add_product_title';
  static const String addProductName = 'add_product_name';
  static const String addProductExampleHint = 'add_product_example_hint';
  static const String addProductBarcode = 'add_product_barcode';
  static const String addProductBarcodeHint = 'add_product_barcode_hint';
  static const String addProductCategory = 'add_product_category';
  static const String addProductBuyPrice = 'add_product_buy_price';
  static const String addProductSellPrice = 'add_product_sell_price';
  static const String addProductInitialStock = 'add_product_initial_stock';
  static const String addProductMinStock = 'add_product_min_stock';
  static const String addProductSave = 'add_product_save';
  static const String addProductSuccess = 'add_product_success';

  // Add Category
  static const String addCategoryTitle = 'add_category_title';
  static const String addCategoryName = 'add_category_name';
  static const String addCategoryExampleHint = 'add_category_example_hint';
  static const String addCategoryIcon = 'add_category_icon';
  static const String addCategoryColor = 'add_category_color';
  static const String addCategorySave = 'add_category_save';
  static const String addCategorySuccess = 'add_category_success';

  // Reports
  static const String reportsTitle = 'reports_title';
  static const String reportsSubtitle = 'reports_subtitle';
  static const String reportsPeriodToday = 'reports_period_today';
  static const String reportsPeriodWeek = 'reports_period_week';
  static const String reportsPeriodMonth = 'reports_period_month';
  static const String reportsPeriodCustom = 'reports_period_custom';
  static const String reportsNetProfit = 'reports_net_profit';
  static const String reportsTotalSales = 'reports_total_sales';
  static const String reportsCashCollected = 'reports_cash_collected';
  static const String reportsDebtSales = 'reports_debt_sales';
  static const String reportsInvoicesCount = 'reports_invoices_count';
  static const String reportsInvoiceUnit = 'reports_invoice_unit';
  static const String reportsSoldUnit = 'reports_sold_unit';
  static const String reportsTopProducts = 'reports_top_products';
  static const String reportsSalesOverview = 'reports_sales_overview';
  static const String reportsExport = 'reports_export';
  static const String reportsExportPdfSuccess = 'reports_export_pdf_success';

  // Days
  static const String daySat = 'day_sat';
  static const String daySun = 'day_sun';
  static const String dayMon = 'day_mon';
  static const String dayTue = 'day_tue';
  static const String dayWed = 'day_wed';
  static const String dayThu = 'day_thu';
  static const String dayFri = 'day_fri';

  // More & Settings
  static const String moreTitle = 'more_title';
  static const String moreDefaultStoreName = 'more_default_store_name';
  static const String moreDefaultCashierName = 'more_default_cashier_name';
  static const String moreStoreSettings = 'more_store_settings';
  static const String morePrinterSettings = 'more_printer_settings';
  static const String moreBackup = 'more_backup';
  static const String moreBackupSuccess = 'more_backup_success';
  static const String moreReseedMenu = 'more_reseed_menu';
  static const String moreReseedTitle = 'more_reseed_title';
  static const String moreReseedConfirm = 'more_reseed_confirm';
  static const String moreReseedSuccess = 'more_reseed_success';
  static const String moreClearMenu = 'more_clear_menu';
  static const String moreClearTitle = 'more_clear_title';
  static const String moreClearConfirm = 'more_clear_confirm';
  static const String moreClearSuccess = 'more_clear_success';
  static const String moreAppearance = 'more_appearance';
  static const String moreLanguage = 'more_language';
  static const String moreCurrentLanguage = 'more_current_language';
  static const String moreHelp = 'more_help';
  static const String moreAbout = 'more_about';

  // Common
  static const String commonSave = 'common_save';
  static const String commonCancel = 'common_cancel';
  static const String commonConfirm = 'common_confirm';
  static const String commonDelete = 'common_delete';
  static const String commonEdit = 'common_edit';
  static const String commonSearch = 'common_search';
  static const String commonRetry = 'common_retry';
  static const String commonEmpty = 'common_empty';
  static const String commonError = 'common_error';
  static const String commonSuccess = 'common_success';
  static const String commonExitTitle = 'common_exit_title';
  static const String commonExitMessage = 'common_exit_message';
  static const String commonRequired = 'common_required';
  static const String commonClearAll = 'common_clear_all';

  // Scanner & Camera
  static const String barcodeScannerTitle = 'barcode_scanner_title';
  static const String barcodeScannerInstruction = 'barcode_scanner_instruction';
  static const String barcodeScannerTorch = 'barcode_scanner_torch';
  static const String barcodeScannerFlip = 'barcode_scanner_flip';
  static const String barcodeScannerManual = 'barcode_scanner_manual';
  static const String barcodeProductAdded = 'barcode_product_added';
  static const String barcodeProductNotFound = 'barcode_product_not_found';
  static const String barcodeScannerSimulate = 'barcode_scanner_simulate';

  // Receipts & Invoices
  static const String receiptScannerTitle = 'receipt_scanner_title';
  static const String receiptScannerCamera = 'receipt_scanner_camera';
  static const String receiptScannerGallery = 'receipt_scanner_gallery';
  static const String receiptAttached = 'receipt_attached';
  static const String receiptAttachPrompt = 'receipt_attach_prompt';
  static const String receiptRemove = 'receipt_remove';
  static const String receiptView = 'receipt_view';
  static const String receiptViewInvoice = 'receipt_view_invoice';
  static const String receiptPreview = 'receipt_preview';
  static const String receiptPhotoOrDoc = 'receipt_photo_or_doc';
}
