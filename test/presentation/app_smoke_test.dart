import 'package:baseet/app/app.dart';
import 'package:baseet/core/utils/assets_manager.dart';
import 'package:baseet/core/utils/constants_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('localized foundation screen starts', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: ConstantsManager.supportedLocales,
        path: AssetsManager.translationsPath,
        fallbackLocale: const Locale(ConstantsManager.englishLocale),
        startLocale: const Locale(ConstantsManager.englishLocale),
        child: const BaseetApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Baseet'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
