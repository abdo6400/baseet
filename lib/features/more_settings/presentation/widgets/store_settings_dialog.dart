import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _logoPath = sl<SettingsService>().storeLogoPath;
  }

  Future<void> _pickLogo(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _logoPath = picked.path);
      }
    } catch (_) {}
  }

  void _showLogoSourcePicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                16.vSpace,
                Text(
                  StringsManager.storeLogoTitle.lang,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                16.vSpace,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(AppIcons.inventory, color: theme.colorScheme.primary, size: 20),
                  ),
                  title: Text(
                    StringsManager.storeLogoPickGallery.lang,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickLogo(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPrimitiveTokens.emerald600.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppPrimitiveTokens.emerald600, size: 20),
                  ),
                  title: Text(
                    StringsManager.storeLogoTakeCamera.lang,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickLogo(ImageSource.camera);
                  },
                ),
                if (_logoPath != null && _logoPath!.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppPrimitiveTokens.red700.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, color: AppPrimitiveTokens.red700, size: 20),
                    ),
                    title: Text(
                      StringsManager.storeLogoRemove.lang,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppPrimitiveTokens.red700),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _logoPath = '');
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

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
        logoPath: _logoPath,
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

  Widget _buildLogoAvatar(ThemeData theme) {
    final hasLogo = _logoPath != null && _logoPath!.trim().isNotEmpty && File(_logoPath!).existsSync();

    return Stack(
      children: [
        GestureDetector(
          onTap: _showLogoSourcePicker,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: hasLogo
                ? Image.file(
                    File(_logoPath!),
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: AppIcon(
                      AppIcons.store,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: GestureDetector(
            onTap: _showLogoSourcePicker,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
        ),
      ],
    );
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
              // Header with Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringsManager.moreStoreSettings.lang,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              12.vSpace,

              // Logo Avatar Picker
              Center(
                child: Column(
                  children: [
                    _buildLogoAvatar(theme),
                    6.vSpace,
                    TextButton(
                      onPressed: _showLogoSourcePicker,
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: Text(
                        _logoPath != null && _logoPath!.isNotEmpty
                            ? StringsManager.storeLogoChange.lang
                            : StringsManager.storeLogoPick.lang,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              14.vSpace,

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

