import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/locators/global_locator.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/device_id_service.dart';
import '../../../../core/services/license_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class ActivationPage extends StatefulWidget {
  final bool isExpired;

  const ActivationPage({
    super.key,
    this.isExpired = false,
  });

  @override
  State<ActivationPage> createState() => _ActivationPageState();
}

class _ActivationPageState extends State<ActivationPage> {
  final TextEditingController _keyController = TextEditingController();
  final FocusNode _keyFocusNode = FocusNode();

  String _deviceId = '...';
  bool _isLoadingDevice = true;
  bool _isActivating = false;
  bool _isExpiredState = false;
  DateTime? _expiredAt;

  @override
  void initState() {
    super.initState();
    _isExpiredState = widget.isExpired;
    _loadDeviceAndLicense();
  }

  Future<void> _loadDeviceAndLicense() async {
    final deviceIdService = sl<DeviceIdService>();
    final licenseService = sl<LicenseService>();

    final id = await deviceIdService.getDeviceId();
    final status = await licenseService.checkLicense();
    final licenseInfo = licenseService.currentLicense;

    if (mounted) {
      setState(() {
        _deviceId = id;
        _isLoadingDevice = false;
        if (status == LicenseStatus.expired || widget.isExpired) {
          _isExpiredState = true;
          _expiredAt = licenseInfo?.expiresAt;
        }
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _keyFocusNode.dispose();
    super.dispose();
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

  Future<void> _pasteKey() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _keyController.text = clipboardData.text!.trim();
      });
    }
  }

  Future<void> _sendViaWhatsApp() async {
    final message = StringsManager.activationWhatsAppText.lang.replaceAll('{}', _deviceId);
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  Future<void> _activate() async {
    final inputKey = _keyController.text.trim();
    if (inputKey.isEmpty) {
      context.showStateHandler(
        isLoading: false,
        isError: true,
        errorMessage: StringsManager.activationErrorInvalidKey.lang,
      );
      return;
    }

    setState(() {
      _isActivating = true;
    });

    final licenseService = sl<LicenseService>();
    final result = await licenseService.activateKey(inputKey);

    if (!mounted) return;

    setState(() {
      _isActivating = false;
    });

    if (result.isSuccess) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: Text(StringsManager.activationSuccess.lang),
        autoCloseDuration: const Duration(seconds: 3),
      );

      // Navigate into app
      context.go(AppRoutes.pos);
    } else {
      String errorMessage;
      switch (result.error) {
        case ActivationError.deviceMismatch:
          errorMessage = StringsManager.activationErrorDeviceMismatch.lang;
          break;
        case ActivationError.alreadyExpired:
          errorMessage = StringsManager.activationErrorExpired.lang;
          break;
        case ActivationError.clockTampered:
          errorMessage = StringsManager.activationErrorClock.lang;
          break;
        case ActivationError.invalidSignature:
        case ActivationError.invalidFormat:
        default:
          errorMessage = StringsManager.activationErrorInvalidKey.lang;
          break;
      }

      context.showStateHandler(
        isLoading: false,
        isError: true,
        errorMessage: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo & Header
                  const Center(child: AppLogo(size: 84, showText: false)),
                  16.vSpace,
                  Text(
                    StringsManager.appName.lang,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  4.vSpace,
                  Text(
                    _isExpiredState
                        ? StringsManager.activationExpiredTitle.lang
                        : StringsManager.activationTitle.lang,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _isExpiredState
                          ? AppPrimitiveTokens.red600
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  8.vSpace,
                  Text(
                    _isExpiredState
                        ? StringsManager.activationExpiredDesc.lang
                        : StringsManager.activationSubtitle.lang,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  20.vSpace,

                  // Expiry Banner if expired
                  if (_isExpiredState && _expiredAt != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppPrimitiveTokens.red50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppPrimitiveTokens.red200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const AppIcon(
                            AppIcons.warning,
                            color: AppPrimitiveTokens.red600,
                            size: 22,
                          ),
                          12.hSpace,
                          Expanded(
                            child: Text(
                              StringsManager.activationExpiresOn.lang.replaceAll(
                                '{}',
                                DateFormat('yyyy/MM/dd').format(_expiredAt!),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppPrimitiveTokens.red800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    16.vSpace,
                  ],

                  // Device ID Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: AppIcon(
                                AppIcons.shield,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                            ),
                            10.hSpace,
                            Expanded(
                              child: Text(
                                StringsManager.activationDeviceId.lang,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        12.vSpace,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? theme.colorScheme.surfaceContainer
                                : AppPrimitiveTokens.slate100,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _isLoadingDevice
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : SelectableText(
                                        _deviceId,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5,
                                          fontFamily: 'monospace',
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                              ),
                              8.hSpace,
                              IconButton(
                                tooltip: StringsManager.activationCopyDeviceId.lang,
                                icon: const AppIcon(
                                  AppIcons.copy,
                                  size: 20,
                                ),
                                onPressed: _copyDeviceId,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                        12.vSpace,
                        Row(
                          children: [
                            Expanded(
                              child: AppOutlinedButton(
                                text: StringsManager.activationCopyDeviceId.lang,
                                icon: AppIcons.copy,
                                height: 40,
                                onPressed: _copyDeviceId,
                              ),
                            ),
                            10.hSpace,
                            Expanded(
                              child: AppOutlinedButton(
                                text: StringsManager.activationSendToWhatsApp.lang,
                                icon: AppIcons.whatsapp,
                                height: 40,
                                onPressed: _sendViaWhatsApp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  20.vSpace,

                  // Activation Key Input Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: AppIcon(
                                    AppIcons.key,
                                    color: theme.colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                                10.hSpace,
                                Text(
                                  StringsManager.activationKeyLabel.lang,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: _pasteKey,
                              icon: const AppIcon(AppIcons.copy, size: 16),
                              label: Text(
                                StringsManager.activationPaste.lang,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        10.vSpace,
                        TextField(
                          controller: _keyController,
                          focusNode: _keyFocusNode,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                          decoration: InputDecoration(
                            hintText: StringsManager.activationKeyHint.lang,
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? theme.colorScheme.surfaceContainer
                                : AppPrimitiveTokens.slate50,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(
                                  color: theme.colorScheme.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(
                                  color: theme.colorScheme.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(
                                  color: theme.colorScheme.primary, width: 1.5),
                            ),
                          ),
                        ),
                        16.vSpace,
                        AppButton(
                          text: _isExpiredState
                              ? StringsManager.activationRenewBtn.lang
                              : StringsManager.activationBtn.lang,
                          icon: AppIcons.check,
                          isLoading: _isActivating,
                          onPressed: _activate,
                        ),
                      ],
                    ),
                  ),
                  20.vSpace,

                  // Instructions Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainer.withValues(alpha: 0.4)
                          : AppPrimitiveTokens.slate100.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppIcon(
                              AppIcons.info,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            8.hSpace,
                            Text(
                              StringsManager.activationInstructions.lang,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
