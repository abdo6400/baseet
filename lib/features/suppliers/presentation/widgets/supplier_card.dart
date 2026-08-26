import 'package:flutter/material.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/supplier_entity.dart';

class SupplierCard extends StatelessWidget {
  final SupplierEntity supplier;
  final VoidCallback? onTap;
  final VoidCallback? onInvoiceTap;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onWhatsAppTap;

  const SupplierCard({
    super.key,
    required this.supplier,
    this.onTap,
    this.onInvoiceTap,
    this.onPhoneTap,
    this.onWhatsAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            supplier.name.isNotEmpty ? supplier.name[0] : 'م',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(supplier.companyName, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
            Text(supplier.phone, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${supplier.totalDebt.toStringAsFixed(0)} ${StringsManager.posCurrency.lang}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: supplier.totalDebt > 0 ? AppPrimitiveTokens.amber500 : theme.colorScheme.primary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onInvoiceTap != null)
                  IconButton(
                    icon: Icon(Icons.receipt_long, size: 18, color: theme.colorScheme.primary),
                    onPressed: onInvoiceTap,
                    tooltip: StringsManager.suppliersAddInvoice.lang,
                  ),
                if (onPhoneTap != null)
                  IconButton(
                    icon: Icon(Icons.phone, size: 18, color: theme.colorScheme.primary),
                    onPressed: onPhoneTap,
                    tooltip: StringsManager.suppliersCall.lang,
                  ),
                if (onWhatsAppTap != null)
                  IconButton(
                    icon: const Icon(Icons.chat, size: 18, color: AppPrimitiveTokens.emerald700),
                    onPressed: onWhatsAppTap,
                    tooltip: StringsManager.suppliersWhatsapp.lang,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
