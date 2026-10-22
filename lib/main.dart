import 'package:baseet/app/app.dart';
import 'package:baseet/core/utils/assets_manager.dart';
import 'package:baseet/core/utils/constants_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: ConstantsManager.supportedLocales,
      path: AssetsManager.translationsPath,
      fallbackLocale: const Locale(ConstantsManager.arabicLocale),
      child: const BaseetApp(),
    ),
  );
}
