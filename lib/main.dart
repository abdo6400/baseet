import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:baseet/app/app.dart';
import 'package:baseet/app/di/locator.dart';
import 'package:baseet/core/utils/assets_manager.dart';
import 'package:baseet/core/utils/constants_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

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
