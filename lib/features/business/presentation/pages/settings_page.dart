import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/app/router/app_routes.dart';
import 'package:baseet/app/presentation/refresh_business.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/theme_bloc/theme_bloc.dart';
import 'package:baseet/core/theme/theme_bloc/theme_event.dart';
import 'package:baseet/features/more_settings/presentation/blocs/data_management/data_management_bloc.dart';
import '../cubits/business_cubit.dart';
import '../cubits/store_settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController name;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(
        text: context.read<BusinessCubit>().state.data.storeName);
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> clear() async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: Text('simple.clear'.lang),
                content: Text('simple.clear_warning'.lang),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: Text('common_cancel'.lang)),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: Text('simple.clear'.lang))
                ]));
    if (yes == true && mounted) {
      context
          .read<DataManagementBloc>()
          .add(const DataManagementEvent(DataAction.clear));
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
          listeners: [
            BlocListener<StoreSettingsCubit, StoreSettingsState>(
                listener: (context, state) {
              if (state.saved) context.read<BusinessCubit>().load();
            }),
            BlocListener<DataManagementBloc, DataManagementState>(
                listener: (context, state) {
              if (state.status == DataManagementStatus.success) {
                refreshBusiness(context, clearCart: true);
              }
            }),
          ],
          child: Scaffold(
              appBar: AppBar(title: Text('simple.settings'.lang)),
              body: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text('simple.store_name'.lang,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            TextField(
                                controller: name,
                                decoration: InputDecoration(
                                    labelText: 'simple.store_name'.lang)),
                            const SizedBox(height: 8),
                            BlocBuilder<StoreSettingsCubit, StoreSettingsState>(
                                builder: (context, state) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (state.error != null)
                                            Text(state.error!.lang),
                                          if (state.saved)
                                            Text('simple.saved'.lang),
                                          FilledButton(
                                              onPressed: state.busy
                                                  ? null
                                                  : () => context
                                                      .read<
                                                          StoreSettingsCubit>()
                                                      .save(name.text),
                                              child: Text('simple.save'.lang)),
                                        ])),
                            const Divider(height: 40),
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.qr_code_2),
                                title: Text('simple.transfer'.lang),
                                subtitle: Text('simple.transfer_hint'.lang),
                                onTap: () => context.push(AppRoutes.transfer)),
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.language),
                                title: Text('simple.language'.lang),
                                trailing: DropdownButton<String>(
                                    value: context.locale.languageCode,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'ar', child: Text('العربية')),
                                      DropdownMenuItem(
                                          value: 'en', child: Text('English'))
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        context.setLocale(Locale(value));
                                      }
                                    })),
                            SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('simple.dark_mode'.lang),
                                value: Theme.of(context).brightness ==
                                    Brightness.dark,
                                onChanged: (value) => context
                                    .read<ThemeBloc>()
                                    .add(ToggleThemeEvent(value
                                        ? ThemeMode.dark
                                        : ThemeMode.light))),
                            const Divider(height: 32),
                            ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: Text('simple.help'.lang),
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Text('simple.help_text'.lang))
                                ]),
                            ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: Text('simple.data_management'.lang),
                                children: [
                                  Text('simple.clear_warning'.lang),
                                  const SizedBox(height: 12),
                                  BlocBuilder<DataManagementBloc,
                                          DataManagementState>(
                                      builder: (context, state) =>
                                          Column(children: [
                                            if (state.status ==
                                                DataManagementStatus.error)
                                              Text((state.error ??
                                                      'simple.transfer_failed')
                                                  .lang),
                                            if (state.status ==
                                                DataManagementStatus.success)
                                              Text('simple.cleared'.lang),
                                            TextButton.icon(
                                                onPressed: state.status ==
                                                        DataManagementStatus
                                                            .loading
                                                    ? null
                                                    : clear,
                                                icon: const Icon(
                                                    Icons.delete_outline),
                                                label:
                                                    Text('simple.clear'.lang))
                                          ])),
                                ]),
                            const SizedBox(height: 16),
                            Text('simple.local_only'.lang),
                          ])))));
}
