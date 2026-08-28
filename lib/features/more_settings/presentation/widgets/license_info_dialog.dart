import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../core/services/license_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class LicenseInfoDialog extends StatefulWidget {
  const LicenseInfoDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const LicenseInfoDialog(),
    );
  }

  @override
  State<LicenseInfoDialog> createState() => _LicenseInfoDialogState();
}

class _LicenseInfoDialogState extends State<LicenseInfoDialog> {
  String _deviceId = '...';
  LicenseInfo? _licenseInfo;
  LicenseStatus _status = LicenseStatus.unactivated;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final deviceId = await sl<DeviceIdService>().getDeviceId();
    final licenseService = sl<LicenseService>();
    final status = await licenseService.checkLicense();
    final info = licenseService.currentLicense;

    if (mounted) {
      setState(() {
        _deviceId = deviceId;
        _licenseInfo = info;
        _status = status;
      });
    }
  }

  void _copyDeviceId() {
    Clipboard.setData(ClipboardData(text: _deviceId));
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: Text(StringsManager.activationDeviceIdCopied.lang),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isActive = _status == LicenseStatus.active;
    final isExpired = _status == LicenseStatus.expired;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.safeDp(20),
        vertical: context.safeDp(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.isTablet ? 540 : 480,
        ),
        child: Padding(
          padding: EdgeInsets.all(context.safeDp(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.safeDp(10)),
                    decoration: BoxDecoration(
                      color: (isActive
                              ? AppPrimitiveTokens.emerald600
                              : AppPrimitiveTokens.red600)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(
                      isActive ? AppIcons.shield : AppIcons.warning,
                      color: isActive
                          ? AppPrimitiveTokens.emerald600
                          : AppPrimitiveTokens.red600,
                      size: context.safeDp(24),
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsManager.moreLicense.lang,
                          style: context.label(
                            18,
                            weight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          StringsManager.moreLicenseSubtitle.lang,
                          style: context.label(
                            12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: AppIcon(AppIcons.close, size: context.safeDp(20)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              16.vSpace,

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.safeDp(14),
                  vertical: context.safeDp(12),
                ),
                decoration: BoxDecoration(
                  color: (isActive
                          ? AppPrimitiveTokens.emerald50
                          : AppPrimitiveTokens.red50),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: (isActive
                        ? AppPrimitiveTokens.emerald300
                        : AppPrimitiveTokens.red200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: isActive
                          ? AppPrimitiveTokens.emerald700
                          : AppPrimitiveTokens.red700,
                      size: context.safeDp(20),
                    ),
                    10.hSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isActive
                                ? StringsManager.activationStatusActive.lang
                                : isExpired
                                    ? StringsManager.activationStatusExpired.lang
                                    : StringsManager
                                        .activationStatusUnactivated.lang,
                            style: context.label(
                              14,
                              weight: FontWeight.w700,
                              color: isActive
                                  ? AppPrimitiveTokens.emerald800
                                  : AppPrimitiveTokens.red800,
                            ),
                          ),
                          if (_licenseInfo != null) ...[
                            2.vSpace,
                            Text(
                              StringsManager.activationExpiresOn.lang.replaceAll(
                                '{}',
                                DateFormat('yyyy/MM/dd')
                                    .format(_licenseInfo!.expiresAt),
                              ),
                              style: context.label(
                                12,
                                color: isActive
                                    ? AppPrimitiveTokens.emerald700
                                    : AppPrimitiveTokens.red700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isActive && _licenseInfo != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.safeDp(10),
                          vertical: context.safeDp(4),
                        ),
                        decoration: BoxDecoration(
                          color: AppPrimitiveTokens.emerald700,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          StringsManager.activationDaysRemaining.lang.replaceAll(
                              '{}', '${_licenseInfo!.daysRemaining}'),
                          style: context.label(
                            11,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              16.vSpace,

              // Device ID
              Text(
                StringsManager.activationDeviceId.lang,
                style: context.label(
                  12,
                  weight: FontWeight.w700,
                ),
              ),
              6.vSpace,
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.safeDp(12),
                  vertical: context.safeDp(10),
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainer
                      : AppPrimitiveTokens.slate100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        _deviceId,
                        style: context.label(
                          14,
                          weight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: StringsManager.activationCopyDeviceId.lang,
                      icon: AppIcon(AppIcons.copy, size: context.safeDp(18)),
                      onPressed: _copyDeviceId,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              20.vSpace,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: StringsManager.activationCopyDeviceId.lang,
                      icon: AppIcons.copy,
                      onPressed: _copyDeviceId,
                    ),
                  ),
                  10.hSpace,
                  Expanded(
                    child: AppButton(
                      text: StringsManager.activationRenewBtn.lang,
                      icon: AppIcons.key,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.activation);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
