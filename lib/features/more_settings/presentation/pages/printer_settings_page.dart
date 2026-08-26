import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_text_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../widgets/printer_type_tile.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  String _printerType = 'bluetooth'; // 'bluetooth', 'network', 'system'
  String _paperSize = '80mm'; // '80mm', '58mm'
  bool _autoPrintReceipt = true;
  final _ipController = TextEditingController(text: '192.168.1.100');

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _onSave() {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text(StringsManager.printerSavedSuccess.lang),
      autoCloseDuration: const Duration(seconds: 3),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageWrapper(
      scrollable: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      appBar: PageHeader(
        title: StringsManager.printerSettingsTitle.lang,
        showBackButton: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection Method Card
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
                  StringsManager.printerConnectionType.lang,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                12.vSpace,
                PrinterTypeTile(
                  title: StringsManager.printerBluetooth.lang,
                  value: 'bluetooth',
                  groupValue: _printerType,
                  icon: Icons.bluetooth,
                  onChanged: (val) => setState(() => _printerType = val),
                ),
                PrinterTypeTile(
                  title: StringsManager.printerNetwork.lang,
                  value: 'network',
                  groupValue: _printerType,
                  icon: Icons.wifi,
                  onChanged: (val) => setState(() => _printerType = val),
                ),
                if (_printerType == 'network')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.s2),
                    child: AppTextField(
                      controller: _ipController,
                      label: StringsManager.printerIpAddress.lang,
                      hint: StringsManager.printerIpHint.lang,
                    ),
                  ),
                PrinterTypeTile(
                  title: StringsManager.printerUsb.lang,
                  value: 'system',
                  groupValue: _printerType,
                  icon: Icons.print,
                  onChanged: (val) => setState(() => _printerType = val),
                ),
              ],
            ),
          ),
          16.vSpace,

          // Paper Size & Settings
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
                  StringsManager.printerPaperSize.lang,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                12.vSpace,
                ListTile(
                  title: Text(StringsManager.printerPaperSize.lang, style: const TextStyle(fontSize: 14)),
                  trailing: DropdownButton<String>(
                    value: _paperSize,
                    items: [
                      DropdownMenuItem(value: '80mm', child: Text(StringsManager.printerPaper80.lang)),
                      DropdownMenuItem(value: '58mm', child: Text(StringsManager.printerPaper58.lang)),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paperSize = val);
                    },
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(StringsManager.printerAutoPrint.lang, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(StringsManager.printerAutoPrintSubtitle.lang, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
                  value: _autoPrintReceipt,
                  onChanged: (val) => setState(() => _autoPrintReceipt = val),
                ),
              ],
            ),
          ),
          24.vSpace,

          AppButton(
            text: StringsManager.printerSaveSettings.lang,
            icon: AppIcons.save,
            onPressed: _onSave,
          ),
        ],
      ),
    );
  }
}
