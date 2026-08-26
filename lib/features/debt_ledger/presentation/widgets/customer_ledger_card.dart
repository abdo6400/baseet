import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/common/widgets/feedback/status_badge.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerLedgerCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback onTap;
  final VoidCallback onVoucherTap;

  const CustomerLedgerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onVoucherTap,
  });

  void _sendWhatsAppReminder(BuildContext context) async {
    final debtStr = customer.totalDebt.toStringAsFixed(customer.totalDebt.truncateToDouble() == customer.totalDebt ? 0 : 2);
    final message = Uri.encodeComponent(
      StringsManager.customerWhatsappReminder.trArgs(args: [customer.name, debtStr]),
    );
    final url = Uri.parse('https://wa.me/20${customer.phone}?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialLetter = customer.name.isNotEmpty ? customer.name[0] : 'ع';

    StatusBadgeVariant badgeVariant;
    String badgeLabel;

    switch (customer.status) {
      case DebtStatus.overdue:
        badgeVariant = StatusBadgeVariant.error;
        badgeLabel = StringsManager.debtsStatusOverdue.lang;
        break;
      case DebtStatus.limitExceeded:
        badgeVariant = StatusBadgeVariant.warning;
        badgeLabel = StringsManager.debtsStatusLimitExceeded.lang;
        break;
      case DebtStatus.regular:
        badgeVariant = StatusBadgeVariant.success;
        badgeLabel = StringsManager.debtsStatusRegular.lang;
        break;
    }

    final isHighDebt = customer.isOverdue || customer.isLimitExceeded;
    final debtColor = isHighDebt ? AppPrimitiveTokens.red700 : AppPrimitiveTokens.emerald700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initialLetter,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              customer.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(label: badgeLabel, variant: badgeVariant),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (customer.lastPaymentDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${StringsManager.debtsLastPayment.lang}: ${customer.lastPaymentDate!.day}/${customer.lastPaymentDate!.month}/${customer.lastPaymentDate!.year}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Debt Amount Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: debtColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '-${customer.totalDebt.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: debtColor,
                        ),
                      ),
                      Text(
                        StringsManager.posCurrency.lang,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: debtColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5), height: 1),
            const SizedBox(height: 8),

            // Action buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // WhatsApp reminder button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  onPressed: () => _sendWhatsAppReminder(context),
                  icon: AppIcon(AppIcons.whatsapp, size: 14),
                  label: Text(
                    StringsManager.debtsActionRemind.lang,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),

                // Payment voucher button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onVoucherTap();
                  },
                  icon: AppIcon(AppIcons.receipt, size: 14, color: Colors.white),
                  label: Text(
                    StringsManager.debtsActionVoucher.lang,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
