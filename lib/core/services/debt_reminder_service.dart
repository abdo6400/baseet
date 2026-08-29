import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/database/local/app_database.dart';
import '../extensions/translation_extension.dart';
import '../utils/strings_manager.dart';

class DebtReminderItem {
  final String id;
  final String name;
  final String phone;
  final double amount;
  final bool isCustomer;
  final DateTime? lastTransactionDate;

  DebtReminderItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.amount,
    required this.isCustomer,
    this.lastTransactionDate,
  });
}

class DebtReminderService {
  final AppDatabase appDatabase;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  DebtReminderService({AppDatabase? database})
      : appDatabase = database ?? AppDatabase();

  /// Initialize local notification channels and permissions
  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Request notification permission on Android 13+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Local notifications init error: $e');
    }
  }

  /// Sends an immediate local notification banner to the user's device
  Future<void> showDebtNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'debt_reminders_channel',
      'تذكيرات الديون والمستحقات',
      channelDescription: 'إشعارات تنبيهية بالديون المتأخرة ومواعيد سداد العملاء والموردين',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Checks for overdue customer and supplier debts and triggers device local notification
  Future<void> checkAndNotifyOverdueDebts() async {
    final reminders = await getOverdueReminders();
    if (reminders.isEmpty) return;

    final customerDebts = reminders.where((r) => r.isCustomer).toList();
    final supplierDebts = reminders.where((r) => !r.isCustomer).toList();

    final totalCustomerDebt = customerDebts.fold(0.0, (sum, item) => sum + item.amount);
    final totalSupplierDebt = supplierDebts.fold(0.0, (sum, item) => sum + item.amount);

    if (customerDebts.isNotEmpty) {
      final topCustomer = customerDebts.first;
      final body = customerDebts.length == 1
          ? 'المستحق على ${topCustomer.name}: ${topCustomer.amount.toStringAsFixed(0)} ج.م'
          : 'يوجد ${customerDebts.length} عملاء بإجمالي مستحقات ${totalCustomerDebt.toStringAsFixed(0)} ج.م';

      await showDebtNotification(
        title: '🔔 تذكير ديون العملاء المستحقة',
        body: body,
        payload: 'customer_debts',
      );
    }

    if (supplierDebts.isNotEmpty) {
      final body = 'يوجد ${supplierDebts.length} موردين بإجمالي مستحقات مطلوبة ${totalSupplierDebt.toStringAsFixed(0)} ج.م';

      await showDebtNotification(
        title: '📦 تنبيه مستحقات الموردين',
        body: body,
        payload: 'supplier_debts',
      );
    }
  }

  /// Fetches customers and suppliers who have outstanding debt
  Future<List<DebtReminderItem>> getOverdueReminders() async {
    final db = await appDatabase.database;
    final List<DebtReminderItem> reminders = [];

    // 1. Customers with debt
    final custMaps = await db.query(
      'customers',
      where: 'totalDebt > 0',
      orderBy: 'totalDebt DESC',
    );

    for (final map in custMaps) {
      final id = map['id'] as String;
      final name = map['name'] as String;
      final phone = map['phone'] as String? ?? '';
      final totalDebt = (map['totalDebt'] as num?)?.toDouble() ?? 0.0;
      final lastPayment = map['lastPaymentDate'] != null
          ? DateTime.tryParse(map['lastPaymentDate'] as String)
          : null;

      reminders.add(DebtReminderItem(
        id: id,
        name: name,
        phone: phone,
        amount: totalDebt,
        isCustomer: true,
        lastTransactionDate: lastPayment,
      ));
    }

    // 2. Suppliers with debt
    final supMaps = await db.query(
      'suppliers',
      where: 'totalDebt > 0',
      orderBy: 'totalDebt DESC',
    );

    for (final map in supMaps) {
      final id = map['id'] as String;
      final name = map['name'] as String;
      final phone = map['phone'] as String? ?? '';
      final totalDebt = (map['totalDebt'] as num?)?.toDouble() ?? 0.0;
      final lastTx = map['lastTransactionDate'] != null
          ? DateTime.tryParse(map['lastTransactionDate'] as String)
          : null;

      reminders.add(DebtReminderItem(
        id: id,
        name: name,
        phone: phone,
        amount: totalDebt,
        isCustomer: false,
        lastTransactionDate: lastTx,
      ));
    }

    return reminders;
  }

  /// Formats reminder message for WhatsApp or SMS
  String formatReminderMessage({
    required String name,
    required double amount,
    required bool isCustomer,
    String? storeName,
  }) {
    final store = storeName ?? StringsManager.appName.lang;
    final amountFormatted = '${amount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}';

    if (isCustomer) {
      return 'مرحباً $name، نود تذكيركم بلطف بالمبلغ المستحق لحسابكم لدى $store وقدره $amountFormatted. شاكرين لكم حسن تعاونكم.';
    } else {
      return 'مرحباً $name، نود إشعاركم بأن إجمالي المستحقات المتبقية لكم هو $amountFormatted. سيتم تسويتها قريباً. مع تحيات $store.';
    }
  }

  /// Sends reminder via WhatsApp
  Future<bool> sendWhatsAppReminder({
    required String phone,
    required String message,
  }) async {
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.startsWith('00')) {
      cleanPhone = '+${cleanPhone.substring(2)}';
    } else if (cleanPhone.startsWith('01') && cleanPhone.length == 11) {
      // Egyptian mobile format default
      cleanPhone = '+20${cleanPhone.substring(1)}';
    }

    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
