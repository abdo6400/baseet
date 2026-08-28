import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/database/local/app_database.dart';
import '../../../../config/locators/global_locator.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/extensions/dialog_extension.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/theme/theme_bloc/theme_bloc.dart';
import '../../../../core/theme/theme_bloc/theme_event.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import '../../../debt_ledger/presentation/blocs/customers_list/customers_list_event.dart';
import '../../../inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import '../../../inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import '../../../pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import '../../../pos/presentation/blocs/catalog/pos_catalog_event.dart';
import '../../../reports/presentation/blocs/reports/reports_bloc.dart';
import '../../../reports/presentation/blocs/reports/reports_event.dart';
import '../widgets/about_app_dialog.dart';
import '../widgets/help_support_modal.dart';
import '../widgets/license_info_dialog.dart';
import '../widgets/more_menu_item.dart';
import '../widgets/store_profile_card.dart';
import '../widgets/store_settings_dialog.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  void _refreshAllBlocs(BuildContext context) {
    context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
    context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());
    context.read<ReportsBloc>().add(const LoadReportsSummaryEvent());
  }

  void _onClearData(BuildContext context) async {
    final confirmed = await context.showConfirmDialog(
      title: StringsManager.moreClearTitle.lang,
      message: StringsManager.moreClearConfirm.lang,
      confirmText: StringsManager.commonClearAll.lang,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await sl<AppDatabase>().clearAllData();
      if (context.mounted) {
        _refreshAllBlocs(context);
        context.showStateHandler(
          isLoading: false,
          isSuccess: true,
          successMessage: StringsManager.moreClearSuccess.lang,
        );
      }
    }
  }

  void _onReplayTour(BuildContext context) async {
    await sl<SettingsService>().setHasSeenShowcase(false);
    if (context.mounted) {
      context.go(AppRoutes.pos);
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
          style: context.label(
            22,
            weight: FontWeight.w800,
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
        padding: EdgeInsets.all(context.safeDp(16)),
        child: Column(
          children: [
            // Store Profile Card
            const StoreProfileCard(),
            16.vSpace,

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
                  MoreMenuItem(
                    title: StringsManager.moreStoreSettings.lang,
                    icon: AppIcons.store,
                    onTap: () => StoreSettingsDialog.show(context),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.receiptsListTitle.lang,
                    icon: AppIcons.receipt,
                    onTap: () => context.push(AppRoutes.receipts),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.suppliersTitle.lang,
                    icon: AppIcons.user,
                    onTap: () => context.push(AppRoutes.suppliers),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.morePrinterSettings.lang,
                    icon: AppIcons.printer,
                    onTap: () => context.push(AppRoutes.printerSettings),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.receiptSettingsTitle.lang,
                    icon: AppIcons.document,
                    onTap: () => context.push(AppRoutes.receiptSettings),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.backupSettingsTitle.lang,
                    icon: AppIcons.database,
                    onTap: () => context.push(AppRoutes.backupSettings),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.showcaseReplayTour.lang,
                    icon: AppIcons.help,
                    onTap: () => _onReplayTour(context),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.moreAppearance.lang,
                    icon: AppIcons.darkLight,
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        context.read<ThemeBloc>().add(
                              ToggleThemeEvent(
                                  val ? ThemeMode.dark : ThemeMode.light),
                            );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.moreLanguage.lang,
                    icon: AppIcons.language,
                    trailing: Text(
                      context.locale.languageCode == 'ar'
                          ? 'العربية'
                          : 'English',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    onTap: () {
                      final newLocale = context.locale.languageCode == 'ar'
                          ? const Locale('en')
                          : const Locale('ar');
                      context.setLocale(newLocale);
                    },
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.moreHelp.lang,
                    icon: AppIcons.info,
                    onTap: () => HelpSupportModal.show(context),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.moreLicense.lang,
                    icon: AppIcons.shield,
                    onTap: () => LicenseInfoDialog.show(context),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.moreAbout.lang,
                    icon: AppIcons.store,
                    trailing: const Text('v1.0.0',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    onTap: () => AboutAppDialog.show(context),
                  ),
                  const Divider(height: 1),
                  MoreMenuItem(
                    title: StringsManager.moreClearMenu.lang,
                    icon: AppIcons.clear,
                    iconColor: AppPrimitiveTokens.red700,
                    onTap: () => _onClearData(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

