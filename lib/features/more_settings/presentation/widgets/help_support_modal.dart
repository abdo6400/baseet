import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class HelpSupportModal extends StatelessWidget {
  const HelpSupportModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const HelpSupportModal(),
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
            StringsManager.moreHelp.lang,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          16.vSpace,
          ListTile(
            leading: AppIcon(AppIcons.help, color: theme.colorScheme.primary),
            title: const Text('دليل الاستخدام والأسئلة الشائعة'),
            subtitle: const Text('تعلم كيفية إدارة نقاط البيع والديون والمخزن بسهولة'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: AppIcon(AppIcons.phone, color: AppPrimitiveTokens.emerald700),
            title: const Text('الدعم الفني والخدمة المباشرة'),
            subtitle: const Text('تواصل معنا للحصول على الدعم الفني والمساعدة'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
