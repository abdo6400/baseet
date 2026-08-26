import 'package:flutter/material.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const AboutAppDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogo(size: 80, showText: false),
          16.vSpace,
          Text(
            StringsManager.appName.lang,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
          4.vSpace,
          Text(
            'v1.0.0',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          12.vSpace,
          Text(
            StringsManager.appSubtitle.lang,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          16.vSpace,
          const Text(
            'تطبيق بسيط هو نظام نقاط بيع (POS) ودفتر ديون إلكتروني ذكي للمحلات والأنشطة التجارية.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(StringsManager.commonCancel.lang),
        ),
      ],
    );
  }
}
