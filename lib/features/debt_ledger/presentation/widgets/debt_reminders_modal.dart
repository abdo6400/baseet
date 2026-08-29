import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/feedback/empty_state_widget.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/debt_reminder_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class DebtRemindersModal extends StatefulWidget {
  const DebtRemindersModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DebtRemindersModal(),
    );
  }

  @override
  State<DebtRemindersModal> createState() => _DebtRemindersModalState();
}

class _DebtRemindersModalState extends State<DebtRemindersModal> {
  late Future<List<DebtReminderItem>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _remindersFuture = sl<DebtReminderService>().getOverdueReminders();
  }

  void _sendReminder(DebtReminderItem item) async {
    HapticFeedback.lightImpact();
    final service = sl<DebtReminderService>();
    final message = service.formatReminderMessage(
      name: item.name,
      amount: item.amount,
      isCustomer: item.isCustomer,
    );

    if (item.phone.isNotEmpty) {
      await service.sendWhatsAppReminder(phone: item.phone, message: message);
    }
  }

  void _callPhone(String phone) async {
    if (phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 22),
                    ),
                    10.hSpace,
                    Text(
                      StringsManager.remindersTitle.lang,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notification_add, color: AppPrimitiveTokens.amber500),
                      tooltip: 'إرسال إشعار للنظام الآن',
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await sl<DebtReminderService>().checkAndNotifyOverdueDebts();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Expanded(
            child: FutureBuilder<List<DebtReminderItem>>(
              future: _remindersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: EmptyStateWidget(
                      title: StringsManager.remindersNoOverdue.lang,
                      subtitle: StringsManager.remindersAllClear.lang,
                      icon: AppIcons.check,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => 10.vSpace,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.isCustomer
                                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                  : AppPrimitiveTokens.amber500.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.isCustomer ? Icons.person : Icons.local_shipping,
                              color: item.isCustomer ? theme.colorScheme.primary : AppPrimitiveTokens.amber500,
                              size: 20,
                            ),
                          ),
                          10.hSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.phone.isNotEmpty ? item.phone : StringsManager.commonNoPhone.lang,
                                  style: TextStyle(fontSize: 11.5, color: theme.colorScheme.outline),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.amount.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: item.isCustomer ? AppPrimitiveTokens.red700 : theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.phone.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.call, color: AppPrimitiveTokens.emerald500, size: 22),
                                  tooltip: StringsManager.commonCall.lang,
                                  onPressed: () => _callPhone(item.phone),
                                ),
                              IconButton(
                                icon: const AppIcon(AppIcons.share, size: 22, color: AppPrimitiveTokens.emerald500),
                                tooltip: StringsManager.remindersSendWhatsApp.lang,
                                onPressed: () => _sendReminder(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
