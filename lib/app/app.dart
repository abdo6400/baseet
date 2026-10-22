import 'package:baseet/core/theme/app_theme.dart';
import 'package:baseet/core/utils/assets_manager.dart';
import 'package:baseet/core/utils/constants_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BaseetApp extends StatelessWidget {
  const BaseetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      onGenerateTitle: (_) => 'app_name'.tr(),
      scaffoldMessengerKey: ConstantsManager.snackBarKey,
      theme: AppTheme.buildLight(locale: context.locale),
      darkTheme: AppTheme.buildDark(locale: context.locale),
      home: const _FoundationPage(),
    );
  }
}

class _FoundationPage extends StatelessWidget {
  const _FoundationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AssetsManager.appIcon, width: 96, height: 96),
                  const SizedBox(height: 24),
                  Text(
                    'app_name'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'foundation_ready'.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
