import 'package:flutter/material.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class CustomerStatementActions extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onVoucher;

  const CustomerStatementActions({
    super.key,
    required this.onCall,
    required this.onWhatsApp,
    required this.onVoucher,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: AppOutlinedButton(
            text: StringsManager.customerCall.lang,
            icon: AppIcons.phone,
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            onPressed: onCall,
          ),
        ),
        8.hSpace,
        Expanded(
          child: AppOutlinedButton(
            text: StringsManager.customerWhatsapp.lang,
            icon: AppIcons.whatsapp,
            textColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
            borderColor: const Color(0xFF25D366),
            backgroundColor: const Color(0xFF25D366).withValues(alpha: isDark ? 0.15 : 0.08),
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            onPressed: onWhatsApp,
          ),
        ),
        8.hSpace,
        Expanded(
          flex: 1,
          child: AppButton(
            text: StringsManager.debtsActionVoucher.lang,
            icon: AppIcons.receipt,
            height: 42,
            fontSize: 13,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            onPressed: onVoucher,
          ),
        ),
      ],
    );
  }
}
