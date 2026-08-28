import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
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
    final settings = sl<SettingsService>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text(
        StringsManager.moreStoreSettings.lang,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: AppForm(
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
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                text: StringsManager.commonCancel.lang,
                height: 42,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            10.hSpace,
            Expanded(
              child: AppButton(
                text: StringsManager.commonSave.lang,
                height: 42,
                onPressed: _onSave,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

