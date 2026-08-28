import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:toastification/toastification.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class ReceiptSettingsPage extends StatefulWidget {
  const ReceiptSettingsPage({super.key});

  @override
  State<ReceiptSettingsPage> createState() => _ReceiptSettingsPageState();
}

class _ReceiptSettingsPageState extends State<ReceiptSettingsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final SettingsService _settings;

  late bool _showLogo;
  late bool _showPhone;
  late bool _showAddress;
  late bool _showTax;
  late bool _showSignatures;
  late bool _showFooterNotes;

  @override
  void initState() {
    super.initState();
    _settings = sl<SettingsService>();
    _showLogo = _settings.showLogoOnReceipt;
    _showPhone = _settings.showStorePhone;
    _showAddress = _settings.showStoreAddress;
    _showTax = _settings.showTaxNumber;
    _showSignatures = _settings.showSignatureOnReceipt;
    _showFooterNotes = _settings.showFooterNoteOnReceipt;
  }

  Future<void> _onSave() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      await _settings.setReceiptHeaderTitle(values['header_title']?.toString() ?? '');
      await _settings.setReceiptTaxNumber(values['tax_number']?.toString() ?? '');
      await _settings.setReceiptFooterNote(values['footer_note']?.toString() ?? '');
      await _settings.setShowLogoOnReceipt(_showLogo);
      await _settings.setShowStorePhone(_showPhone);
      await _settings.setShowStoreAddress(_showAddress);
      await _settings.setShowTaxNumber(_showTax);
      await _settings.setShowSignatureOnReceipt(_showSignatures);
      await _settings.setShowFooterNoteOnReceipt(_showFooterNotes);

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: Text(StringsManager.receiptSettingsSaved.lang),
          autoCloseDuration: const Duration(seconds: 3),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageWrapper(
      scrollable: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      appBar: PageHeader(
        title: StringsManager.receiptSettingsTitle.lang,
        showBackButton: true,
      ),
      child: AppForm(
        formKey: _formKey,
        initialValue: {
          'header_title': _settings.receiptHeaderTitle,
          'tax_number': _settings.receiptTaxNumber,
          'footer_note': _settings.receiptFooterNote,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Header & Footer fields
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringsManager.receiptTextSettings.lang,
                    style: context.label(15, weight: FontWeight.w800, color: theme.colorScheme.primary),
                  ),
                  12.vSpace,
                  AppFormTextField(
                    name: 'header_title',
                    label: StringsManager.receiptHeaderTitleLabel.lang,
                    hint: StringsManager.receiptHeaderTitleHint.lang,
                  ),
                  12.vSpace,
                  AppFormTextField(
                    name: 'tax_number',
                    label: StringsManager.receiptTaxNumberLabel.lang,
                    hint: '300000000000003',
                    keyboardType: TextInputType.number,
                  ),
                  12.vSpace,
                  AppFormTextField(
                    name: 'footer_note',
                    label: StringsManager.receiptFooterNoteLabel.lang,
                    hint: StringsManager.receiptFooterNoteHint.lang,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            16.vSpace,

            // Display Toggles Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StringsManager.receiptDisplayOptions.lang,
                    style: context.label(15, weight: FontWeight.w800, color: theme.colorScheme.primary),
                  ),
                  8.vSpace,
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(StringsManager.receiptShowLogo.lang, style: context.label(13.5)),
                    subtitle: _settings.storeLogoPath != null && _settings.storeLogoPath!.isNotEmpty
                        ? Text(
                            StringsManager.storeLogoTitle.lang,
                            style: TextStyle(fontSize: 11.5, color: theme.colorScheme.primary),
                          )
                        : null,
                    value: _showLogo,
                    onChanged: (val) => setState(() => _showLogo = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(StringsManager.receiptShowStorePhone.lang, style: context.label(13.5)),
                    value: _showPhone,
                    onChanged: (val) => setState(() => _showPhone = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(StringsManager.receiptShowStoreAddress.lang, style: context.label(13.5)),
                    value: _showAddress,
                    onChanged: (val) => setState(() => _showAddress = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(StringsManager.receiptShowTaxNumber.lang, style: context.label(13.5)),
                    value: _showTax,
                    onChanged: (val) => setState(() => _showTax = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(StringsManager.receiptShowSignatures.lang, style: context.label(13.5)),
                    value: _showSignatures,
                    onChanged: (val) => setState(() => _showSignatures = val),
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(StringsManager.receiptShowFooterNotes.lang, style: context.label(13.5)),
                    value: _showFooterNotes,
                    onChanged: (val) => setState(() => _showFooterNotes = val),
                  ),
                ],
              ),
            ),
            24.vSpace,

            AppButton(
              text: StringsManager.receiptSaveSettings.lang,
              icon: AppIcons.save,
              onPressed: _onSave,
            ),
          ],
        ),
      ),
    );
  }
}
