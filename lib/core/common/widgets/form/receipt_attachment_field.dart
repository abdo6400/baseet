import 'dart:io';
import 'package:flutter/material.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/common/widgets/scanner/receipt_preview_dialog.dart';
import 'package:baseet/core/common/widgets/scanner/receipt_scanner_sheet.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';

class ReceiptAttachmentField extends StatelessWidget {
  final String? receiptPath;
  final ValueChanged<String?> onChanged;

  const ReceiptAttachmentField({
    super.key,
    required this.receiptPath,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAttachment = receiptPath != null && receiptPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringsManager.receiptScannerTitle.lang,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (!hasAttachment)
          InkWell(
            onTap: () async {
              final path = await ReceiptScannerSheet.show(context);
              if (path != null) {
                onChanged(path);
              }
            },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(AppIcons.receipt, size: 20, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    StringsManager.receiptAttachPrompt.lang,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppPrimitiveTokens.emerald700.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    width: 48,
                    height: 48,
                    color: theme.colorScheme.surfaceContainer,
                    child: File(receiptPath!).existsSync()
                        ? Image.file(
                            File(receiptPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => AppIcon(AppIcons.receipt, color: AppPrimitiveTokens.emerald700),
                          )
                        : AppIcon(AppIcons.receipt, color: AppPrimitiveTokens.emerald700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StringsManager.receiptAttached.lang,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppPrimitiveTokens.emerald700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        receiptPath!.split(Platform.pathSeparator).last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: AppIcon(AppIcons.info, size: 18, color: theme.colorScheme.primary),
                  tooltip: StringsManager.receiptView.lang,
                  onPressed: () {
                    ReceiptPreviewDialog.show(context, imagePath: receiptPath!);
                  },
                ),
                IconButton(
                  icon: AppIcon(AppIcons.delete, size: 18, color: theme.colorScheme.error),
                  tooltip: StringsManager.receiptRemove.lang,
                  onPressed: () => onChanged(null),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
