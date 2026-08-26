import 'package:flutter/material.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
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
    return Row(
      children: [
        Expanded(
          child: AppOutlinedButton(
            text: StringsManager.customerCall.lang,
            icon: AppIcons.phone,
            height: 44,
            onPressed: onCall,
          ),
        ),
        8.hSpace,
        Expanded(
          child: AppOutlinedButton(
            text: StringsManager.customerWhatsapp.lang,
            icon: AppIcons.whatsapp,
            textColor: AppPrimitiveTokens.emerald700,
            borderColor: AppPrimitiveTokens.emerald700.withValues(alpha: 0.5),
            height: 44,
            onPressed: onWhatsApp,
          ),
        ),
        8.hSpace,
        Expanded(
          child: AppButton(
            text: StringsManager.debtsActionVoucher.lang,
            icon: AppIcons.receipt,
            height: 44,
            onPressed: onVoucher,
          ),
        ),
      ],
    );
  }
}
