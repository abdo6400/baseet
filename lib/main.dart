import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'config/locators/locator.dart';
import 'core/utils/assets_manager.dart';
import 'core/utils/constants_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();
  await initLocator();

  runApp(
    EasyLocalization(
      supportedLocales: ConstantsManager.supportedLocales,
      path: AssetsManager.translationsPath,
      fallbackLocale: const Locale(ConstantsManager.arabicLocale),
      startLocale: const Locale(ConstantsManager.arabicLocale),
      child: const BaseetApp(),
    ),
  );
}
