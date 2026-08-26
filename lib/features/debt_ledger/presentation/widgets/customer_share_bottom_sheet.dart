import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerShareBottomSheet extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback onWhatsAppShare;

  const CustomerShareBottomSheet({
    super.key,
    required this.customer,
    required this.onWhatsAppShare,
  });

  static Future<void> show(
    BuildContext context, {
    required CustomerEntity customer,
    required VoidCallback onWhatsAppShare,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CustomerShareBottomSheet(
        customer: customer,
        onWhatsAppShare: onWhatsAppShare,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringsManager.customerStatementShare.lang,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          12.vSpace,
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'كشف حساب العميل: ${customer.name}\nإجمالي الدين: ${customer.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}\nرقم الهاتف: ${customer.phone}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          16.vSpace,
          ListTile(
            leading: AppIcon(AppIcons.whatsapp, color: AppPrimitiveTokens.emerald700),
            title: Text(StringsManager.customerWhatsapp.lang),
            onTap: () {
              Navigator.pop(context);
              onWhatsAppShare();
            },
          ),
        ],
      ),
    );
  }
}
