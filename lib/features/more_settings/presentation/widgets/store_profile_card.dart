import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import 'store_settings_dialog.dart';

class StoreProfileCard extends StatelessWidget {
  const StoreProfileCard({super.key});

  Widget _buildLogo(SettingsService settings, ThemeData theme) {
    final logoPath = settings.storeLogoPath?.trim() ?? '';
    if (logoPath.isNotEmpty) {
      final file = File(logoPath);
      if (file.existsSync()) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const AppLogo(size: 52, showText: false),
          ),
        );
      }
    }
    return const AppLogo(size: 52, showText: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = sl<SettingsService>();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        return InkWell(
          onTap: () => StoreSettingsDialog.show(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                _buildLogo(settings, theme),
                14.hSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.storeName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      4.vSpace,
                      Text(
                        settings.cashierName,
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

