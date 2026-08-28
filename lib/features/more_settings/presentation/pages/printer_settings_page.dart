import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:toastification/toastification.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/form/app_text_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../widgets/printer_type_tile.dart';

class DiscoveredBtDevice {
  final String name;
  final String address;
  final bool isPaired;

  DiscoveredBtDevice({
    required this.name,
    required this.address,
    this.isPaired = false,
  });
}

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  late String _printerType;
  late String _paperSize;
  late bool _autoPrintReceipt;
  late final TextEditingController _ipController;

  bool _isScanning = false;
  String? _connectedDeviceAddress;
  List<DiscoveredBtDevice> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    final settings = sl<SettingsService>();
    _printerType = settings.printerType;
    _paperSize = settings.paperSize;
    _autoPrintReceipt = settings.autoPrintReceipt;
    _ipController = TextEditingController(text: settings.printerIp);
    _connectedDeviceAddress = settings.printerIp;

    if (_printerType == 'bluetooth') {
      _loadInitialBtDevices();
    }
  }

  void _loadInitialBtDevices() {
    _discoveredDevices = [
      DiscoveredBtDevice(name: 'POS-80C Thermal Printer', address: '00:11:22:33:44:55', isPaired: true),
      DiscoveredBtDevice(name: 'MPT-II Bluetooth Printer', address: 'AA:BB:CC:DD:EE:FF', isPaired: false),
    ];
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _startBtScan() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isScanning = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isScanning = false;
        _discoveredDevices = [
          DiscoveredBtDevice(name: 'POS-80C Thermal Printer', address: '00:11:22:33:44:55', isPaired: true),
          DiscoveredBtDevice(name: 'MPT-II Bluetooth Printer', address: 'AA:BB:CC:DD:EE:FF', isPaired: false),
          DiscoveredBtDevice(name: 'XP-58IIL Receipt Printer', address: '12:34:56:78:90:AB', isPaired: false),
          DiscoveredBtDevice(name: 'ZJ-5802 Mobile POS', address: 'FE:DC:BA:98:76:54', isPaired: false),
        ];
      });

      toastification.show(
        context: context,
        type: ToastificationType.info,
        style: ToastificationStyle.fillColored,
        title: Text(StringsManager.bluetoothScanFinished.lang),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  void _connectDevice(DiscoveredBtDevice device) {
    HapticFeedback.selectionClick();
    setState(() {
      _connectedDeviceAddress = device.address;
      _ipController.text = device.name;
    });

    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: Text('${StringsManager.bluetoothDeviceConnected.lang}: ${device.name}'),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  Future<void> _testPrint() async {
    HapticFeedback.mediumImpact();
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: _paperSize == '58mm' ? PdfPageFormat.roll57 : PdfPageFormat.roll80,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('=== ${StringsManager.appName.lang} ===', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text(StringsManager.printerTestPrintSuccess.lang, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 4),
                pw.Text(DateTime.now().toString().substring(0, 19), style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 8),
                pw.Text('====================', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _onSave() async {
    final settings = sl<SettingsService>();
    await settings.updatePrinterSettings(
      type: _printerType,
      ip: _ipController.text.trim(),
      size: _paperSize,
      autoPrint: _autoPrintReceipt,
    );

    if (mounted) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        title: Text(StringsManager.printerSavedSuccess.lang),
        autoCloseDuration: const Duration(seconds: 3),
      );
      Navigator.pop(context);
    }
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
                  style: context.label(
                    15,
                    weight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                12.vSpace,
                PrinterTypeTile(
                  title: StringsManager.printerBluetooth.lang,
                  value: 'bluetooth',
                  groupValue: _printerType,
                  icon: Icons.bluetooth,
                  onChanged: (val) {
                    setState(() => _printerType = val);
                    _loadInitialBtDevices();
                  },
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

          // Bluetooth Discovery Section
          if (_printerType == 'bluetooth') ...[
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          StringsManager.bluetoothDiscoveredDevices.lang,
                          style: context.label(
                            14.5,
                            weight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _isScanning ? null : _startBtScan,
                        icon: _isScanning
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh, size: 16),
                        label: Text(
                          _isScanning
                              ? StringsManager.bluetoothScanning.lang
                              : StringsManager.bluetoothScanDevices.lang,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  8.vSpace,
                  if (_discoveredDevices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          StringsManager.bluetoothNoDevices.lang,
                          style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _discoveredDevices.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final dev = _discoveredDevices[index];
                        final isConnected = _connectedDeviceAddress == dev.address;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.bluetooth,
                              color: isConnected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            dev.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isConnected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                          subtitle: Text(
                            dev.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: theme.colorScheme.outline, fontSize: 11.5),
                          ),
                          trailing: isConnected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(
                                    StringsManager.bluetoothDeviceConnected.lang,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                )
                              : TextButton(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: () => _connectDevice(dev),
                                  child: Text(StringsManager.bluetoothConnect.lang),
                                ),
                        );
                      },
                    ),
                ],
              ),
            ),
            16.vSpace,
          ],

          // Paper Size & Settings
          Container(
            padding: EdgeInsets.all(context.safeDp(AppSpacing.md)),
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
                  style: context.label(
                    15,
                    weight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                12.vSpace,
                ListTile(
                  title: Text(StringsManager.printerPaperSize.lang, style: context.label(14)),
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
                  title: Text(StringsManager.printerAutoPrint.lang, style: context.label(14)),
                  subtitle: Text(
                    StringsManager.printerAutoPrintSubtitle.lang,
                    style: context.label(12, color: theme.colorScheme.outline),
                  ),
                  value: _autoPrintReceipt,
                  onChanged: (val) => setState(() => _autoPrintReceipt = val),
                ),
              ],
            ),
          ),
          20.vSpace,

          // Test Print Button
          AppOutlinedButton(
            text: StringsManager.printerTestPrint.lang,
            icon: AppIcons.printer,
            width: double.infinity,
            height: 48,
            borderRadius: AppRadius.lg,
            onPressed: _testPrint,
          ),
          12.vSpace,

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
