import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/config/database/local/app_database.dart';
import 'package:baseet/config/locators/global_locator.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/theme_bloc/theme_bloc.dart';
import 'package:baseet/core/theme/theme_bloc/theme_event.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/assets_manager.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/customers_list/customers_list_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_event.dart';
import 'package:baseet/features/reports/presentation/blocs/reports/reports_bloc.dart';
import 'package:baseet/features/reports/presentation/blocs/reports/reports_event.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  void _refreshAllBlocs(BuildContext context) {
    context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
    context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());
    context.read<ReportsBloc>().add(const LoadReportsSummaryEvent());
  }

  void _onReseedData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(StringsManager.moreReseedTitle.lang),
        content: Text(StringsManager.moreReseedConfirm.lang),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(StringsManager.commonCancel.lang),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(StringsManager.commonConfirm.lang),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await sl<AppDatabase>().reseedDemoData();
      if (context.mounted) {
        _refreshAllBlocs(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(StringsManager.moreReseedSuccess.lang)),
        );
      }
    }
  }

  void _onClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(StringsManager.moreClearTitle.lang),
        content: Text(StringsManager.moreClearConfirm.lang),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(StringsManager.commonCancel.lang),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPrimitiveTokens.red700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(StringsManager.commonClearAll.lang),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await sl<AppDatabase>().clearAllData();
      if (context.mounted) {
        _refreshAllBlocs(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(StringsManager.moreClearSuccess.lang)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          StringsManager.appName.lang,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.colorScheme.outlineVariant, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Store Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        AssetsManager.appIcon,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringsManager.moreDefaultStoreName.lang,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          StringsManager.moreDefaultCashierName.lang,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings Menu Container
            Material(
              color: theme.colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreStoreSettings.lang,
                    icon: AppIcons.store,
                    onTap: () => _showStoreSettingsDialog(context),
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.morePrinterSettings.lang,
                    icon: AppIcons.printer,
                    onTap: () => _showPrinterSettingsDialog(context),
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreBackup.lang,
                    icon: AppIcons.backup,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(StringsManager.moreBackupSuccess.lang)),
                      );
                    },
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreReseedMenu.lang,
                    icon: AppIcons.refresh,
                    onTap: () => _onReseedData(context),
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreClearMenu.lang,
                    icon: AppIcons.clear,
                    iconColor: AppPrimitiveTokens.red700,
                    onTap: () => _onClearData(context),
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreAppearance.lang,
                    icon: AppIcons.darkLight,
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        context.read<ThemeBloc>().add(
                              ToggleThemeEvent(val ? ThemeMode.dark : ThemeMode.light),
                            );
                      },
                    ),
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreLanguage.lang,
                    icon: AppIcons.language,
                    trailing: Text(
                      context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    onTap: () {
                      final newLocale = context.locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
                      context.setLocale(newLocale);
                    },
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreHelp.lang,
                    icon: AppIcons.help,
                    onTap: () => _showHelpSupportModal(context),
                  ),
                  _buildDivider(theme),
                  _buildMenuItem(
                    context,
                    title: StringsManager.moreAbout.lang,
                    icon: AppIcons.info,
                    trailing: const Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required dynamic icon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: AppIcon(icon, color: iconColor ?? theme.colorScheme.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: iconColor,
        ),
      ),
      trailing: trailing ?? AppIcon(AppIcons.arrowForward, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
      indent: 16,
      endIndent: 16,
    );
  }

  void _showStoreSettingsDialog(BuildContext context) {
    final storeNameController = TextEditingController(text: 'متجر الأمل للمواد الغذائية');
    final phoneController = TextEditingController(text: '01012345678');
    final addressController = TextEditingController(text: 'القاهرة، مصر');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(StringsManager.moreStoreSettings.lang, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(labelText: 'اسم المتجر', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'رقم الهاتف', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(StringsManager.commonCancel.lang),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(StringsManager.commonSuccess.lang)),
              );
            },
            child: Text(StringsManager.commonSave.lang),
          ),
        ],
      ),
    );
  }

  void _showPrinterSettingsDialog(BuildContext context) {
    bool autoPrint = true;
    String paperSize = '80mm';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(StringsManager.morePrinterSettings.lang, style: const TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('طباعة الفاتورة تلقائياً عند الدفع'),
                value: autoPrint,
                onChanged: (val) => setDialogState(() => autoPrint = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: paperSize,
                decoration: const InputDecoration(labelText: 'حجم الورق', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: '58mm', child: Text('58mm (حراري صغير)')),
                  DropdownMenuItem(value: '80mm', child: Text('80mm (حراري قياسي)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => paperSize = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(StringsManager.commonCancel.lang),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(StringsManager.commonSuccess.lang)),
                );
              },
              child: Text(StringsManager.commonSave.lang),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringsManager.moreHelp.lang,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: AppIcon(AppIcons.help, color: theme.colorScheme.primary),
              title: const Text('دليل الاستخدام والأسئلة الشائعة'),
              subtitle: const Text('تعلم كيفية إدارة نقاط البيع والديون والمخزن بسهولة'),
              onTap: () => Navigator.pop(modalContext),
            ),
            ListTile(
              leading: AppIcon(AppIcons.phone, color: AppPrimitiveTokens.emerald700),
              title: const Text('الدعم الفني والخدمة المباشرة'),
              subtitle: const Text('تواصل معنا للحصول على الدعم الفني والمساعدة'),
              onTap: () => Navigator.pop(modalContext),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                AssetsManager.appIcon,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              StringsManager.appName.lang,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'v1.0.0',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              StringsManager.appSubtitle.lang,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'تطبيق بسيط هو نظام نقاط بيع (POS) ودفتر ديون إلكتروني ذكي للمحلات والأنشطة التجارية.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
