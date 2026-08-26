import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';

class ReceiptScannerSheet extends StatelessWidget {
  const ReceiptScannerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => const ReceiptScannerSheet(),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (file != null && context.mounted) {
        Navigator.of(context).pop(file.path);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              StringsManager.receiptScannerTitle.lang,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),

            // Camera Option
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              tileColor: theme.colorScheme.surfaceContainerLowest,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(AppIcons.barcode, size: 22, color: theme.colorScheme.primary),
              ),
              title: Text(
                StringsManager.receiptScannerCamera.lang,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              trailing: AppIcon(AppIcons.arrowForward, size: 16, color: Colors.grey),
              onTap: () => _pickImage(context, ImageSource.camera),
            ),
            const SizedBox(height: 12),

            // Gallery Option
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              tileColor: theme.colorScheme.surfaceContainerLowest,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppPrimitiveTokens.emerald700.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: AppIcon(AppIcons.pdf, size: 22, color: AppPrimitiveTokens.emerald700),
              ),
              title: Text(
                StringsManager.receiptScannerGallery.lang,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              trailing: AppIcon(AppIcons.arrowForward, size: 16, color: Colors.grey),
              onTap: () => _pickImage(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
