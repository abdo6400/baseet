import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
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

  void _onSave() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      Navigator.pop(context);
      context.showStateHandler(
        isLoading: false,
        isSuccess: true,
        successMessage: StringsManager.commonSuccess.lang,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      title: Text(
        StringsManager.moreStoreSettings.lang,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: AppForm(
          formKey: _formKey,
          initialValue: const {
            'store_name': 'متجر الأمل للمواد الغذائية',
            'phone': '01012345678',
            'address': 'القاهرة، مصر',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppFormTextField(
                name: 'store_name',
                label: 'اسم المتجر',
                validator: AppFormValidators.required(),
              ),
              12.vSpace,
              AppFormTextField(
                name: 'phone',
                label: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator: AppFormValidators.required(),
              ),
              12.vSpace,
              const AppFormTextField(
                name: 'address',
                label: 'العنوان',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(StringsManager.commonCancel.lang),
        ),
        AppButton(
          text: StringsManager.commonSave.lang,
          height: 38,
          onPressed: _onSave,
        ),
      ],
    );
  }
}
