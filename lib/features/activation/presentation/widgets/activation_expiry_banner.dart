import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class ActivationExpiryBanner extends StatelessWidget {
  final DateTime expiredAt;

  const ActivationExpiryBanner({
    super.key,
    required this.expiredAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.safeDp(12)),
      decoration: BoxDecoration(
        color: AppPrimitiveTokens.red50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppPrimitiveTokens.red200,
        ),
      ),
      child: Row(
        children: [
          AppIcon(
            AppIcons.warning,
            color: AppPrimitiveTokens.red600,
            size: context.safeDp(22),
          ),
          12.hSpace,
          Expanded(
            child: Text(
              StringsManager.activationExpiresOn.lang.replaceAll(
                '{}',
                DateFormat('yyyy/MM/dd').format(expiredAt),
              ),
              style: context.label(
                13,
                weight: FontWeight.w600,
                color: AppPrimitiveTokens.red800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
