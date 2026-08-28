import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:toastification/toastification.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/button/app_outlined_button.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/dialog_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
  late final SettingsService _settingsService;
  late final BackupService _backupService;

  String _backupDirectory = '';
  bool _autoBackupEnabled = false;
  String _lastBackupDate = '';
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _settingsService = sl<SettingsService>();
    _backupService = sl<BackupService>();
    _backupDirectory = _settingsService.backupDirectoryPath;
    _autoBackupEnabled = _settingsService.autoBackupEnabled;
    _lastBackupDate = _settingsService.lastBackupDate;
  }

  Future<void> _pickDirectory() async {
    try {
      final selectedDir = await FilePicker.platform.getDirectoryPath();
      if (selectedDir != null && selectedDir.isNotEmpty) {
        setState(() {
          _backupDirectory = selectedDir;
        });
        await _settingsService.setBackupDirectoryPath(selectedDir);
      }
    } catch (_) {}
  }

  Future<void> _toggleAutoBackup(bool enabled) async {
    setState(() {
      _autoBackupEnabled = enabled;
    });
    await _settingsService.setAutoBackupEnabled(enabled);
  }

  Future<void> _runBackupNow() async {
    HapticFeedback.mediumImpact();
    setState(() => _isBackingUp = true);

    try {
      final path = await _backupService.createBackup(
        targetDirectory: _backupDirectory.isNotEmpty ? _backupDirectory : null,
      );

      setState(() {
        _lastBackupDate = _settingsService.lastBackupDate;
      });

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: Text(StringsManager.backupCreatedSuccess.lang),
          description: Text(path, style: const TextStyle(fontSize: 11)),
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: Text('${StringsManager.commonError.lang}: $e'),
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreBackupNow() async {
    HapticFeedback.mediumImpact();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;

        if (!mounted) return;
        final confirmed = await context.showConfirmDialog(
          title: StringsManager.backupRestoreTitle.lang,
          message: StringsManager.backupRestoreConfirm.lang,
          confirmText: StringsManager.backupRestoreTitle.lang,
          isDestructive: true,
        );

        if (confirmed == true && mounted) {
          setState(() => _isRestoring = true);
          await _backupService.restoreBackup(filePath);

          if (mounted) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.fillColored,
              title: Text(StringsManager.backupRestoredSuccess.lang),
              autoCloseDuration: const Duration(seconds: 4),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          title: Text('${StringsManager.commonError.lang}: $e'),
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageWrapper(
      scrollable: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      appBar: PageHeader(
        title: StringsManager.backupSettingsTitle.lang,
        showBackButton: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Destination Directory Card
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
                  StringsManager.backupDirectoryLabel.lang,
                  style: context.label(15, weight: FontWeight.w800, color: theme.colorScheme.primary),
                ),
                8.vSpace,
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Text(
                          _backupDirectory.isNotEmpty
                              ? _backupDirectory
                              : StringsManager.backupDirectoryDefault.lang,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _backupDirectory.isNotEmpty
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.outline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    8.hSpace,
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: _pickDirectory,
                      icon: const Icon(Icons.folder_open, size: 18),
                      label: Text(StringsManager.backupChooseDirectory.lang, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          16.vSpace,

          // Auto Backup & Last Backup Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    StringsManager.backupAutoBackup.lang,
                    style: context.label(14, weight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    StringsManager.backupAutoBackupSubtitle.lang,
                    style: context.label(12, color: theme.colorScheme.outline),
                  ),
                  value: _autoBackupEnabled,
                  onChanged: _toggleAutoBackup,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    StringsManager.backupLastDate.lang,
                    style: context.label(13.5, weight: FontWeight.w600),
                  ),
                  trailing: Text(
                    _lastBackupDate.isNotEmpty
                        ? _lastBackupDate.replaceFirst('T', ' ').substring(0, 16)
                        : StringsManager.backupNever.lang,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _lastBackupDate.isNotEmpty
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          24.vSpace,

          // Manual Backup Action
          AppButton(
            text: _isBackingUp
                ? StringsManager.commonLoading.lang
                : StringsManager.backupNow.lang,
            icon: AppIcons.save,
            onPressed: _isBackingUp ? () {} : _runBackupNow,
          ),
          12.vSpace,

          // Restore Backup Action
          AppOutlinedButton(
            text: _isRestoring
                ? StringsManager.commonLoading.lang
                : StringsManager.backupRestoreTitle.lang,
            icon: AppIcons.refresh,
            width: double.infinity,
            height: 48,
            borderRadius: AppRadius.lg,
            onPressed: _isRestoring ? () {} : _restoreBackupNow,
          ),
        ],
      ),
    );
  }
}
