import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class StoreSettingsDialog extends StatefulWidget {
  const StoreSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const StoreSettingsDialog(),
    );
  }

  @override
  State<StoreSettingsDialog> createState() => _StoreSettingsDialogState();
}

class _StoreSettingsDialogState extends State<StoreSettingsDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _onSave() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final storeName = values['store_name']?.toString() ?? '';
      final cashierName = values['cashier_name']?.toString() ?? '';
      final phone = values['phone']?.toString() ?? '';
      final address = values['address']?.toString() ?? '';

      final settingsService = sl<SettingsService>();
      await settingsService.updateStoreProfile(
        name: storeName,
        phone: phone,
        address: address,
        cashier: cashierName,
      );

      if (mounted) {
        Navigator.pop(context);
        context.showStateHandler(
          isLoading: false,
          isSuccess: true,
          successMessage: StringsManager.commonSuccess.lang,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = sl<SettingsService>();

    return Dialog(
      elevation: 16,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.safeDp(20),
        vertical: context.safeDp(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.isTablet ? 520 : 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Icon
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: AppIcon(
                        AppIcons.store,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  14.hSpace,
                  Expanded(
                    child: Text(
                      StringsManager.moreStoreSettings.lang,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              18.vSpace,

              // Form fields
              AppForm(
                formKey: _formKey,
                initialValue: {
                  'store_name': settings.storeName,
                  'cashier_name': settings.cashierName,
                  'phone': settings.storePhone,
                  'address': settings.storeAddress,
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppFormTextField(
                      name: 'store_name',
                      label: StringsManager.storeSettingsNameLabel.lang,
                      validator: AppFormValidators.required(),
                    ),
                    12.vSpace,
                    AppFormTextField(
                      name: 'cashier_name',
                      label: StringsManager.storeSettingsCashierLabel.lang,
                    ),
                    12.vSpace,
                    AppFormTextField(
                      name: 'phone',
                      label: StringsManager.storeSettingsPhoneLabel.lang,
                      keyboardType: TextInputType.phone,
                    ),
                    12.vSpace,
                    AppFormTextField(
                      name: 'address',
                      label: StringsManager.storeSettingsAddressLabel.lang,
                    ),
                  ],
                ),
              ),
              22.vSpace,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: StringsManager.commonCancel.lang,
                      height: 44,
                      borderRadius: AppRadius.full,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  12.hSpace,
                  Expanded(
                    child: AppButton(
                      text: StringsManager.commonSave.lang,
                      height: 44,
                      borderRadius: AppRadius.full,
                      onPressed: _onSave,
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

