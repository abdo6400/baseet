import 'package:flutter/material.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class ActivationHeader extends StatelessWidget {
  final bool isExpired;

  const ActivationHeader({
    super.key,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Center(child: AppLogo(size: context.safeDp(84), showText: false)),
        16.vSpace,
        Text(
          StringsManager.appName.lang,
          textAlign: TextAlign.center,
          style: context.label(
            30,
            weight: FontWeight.w900,
            color: theme.colorScheme.primary,
          ),
        ),
        4.vSpace,
        Text(
          isExpired
              ? StringsManager.activationExpiredTitle.lang
              : StringsManager.activationTitle.lang,
          textAlign: TextAlign.center,
          style: context.label(
            18,
            weight: FontWeight.w700,
            color: isExpired
                ? AppPrimitiveTokens.red600
                : theme.colorScheme.onSurface,
          ),
        ),
        8.vSpace,
        Text(
          isExpired
              ? StringsManager.activationExpiredDesc.lang
              : StringsManager.activationSubtitle.lang,
          textAlign: TextAlign.center,
          style: context.label(
            13,
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
