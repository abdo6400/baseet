import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:baseet/app/di/global_locator.dart';
import 'package:baseet/app/router/route_config.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/theme/app_theme.dart';
import 'package:baseet/features/business/domain/entities/business_data.dart';
import 'package:baseet/features/business/domain/repositories/business_repository.dart';
import 'package:baseet/features/business/domain/usecases/business_usecases.dart';
import 'package:baseet/features/business/presentation/cubits/business_cubit.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/pos/presentation/widgets/pos_product_grid_card.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeRepository implements BusinessRepository {
  @override
  Future<Either<Failure, BusinessData>> load() async =>
      const Right(BusinessData());
  @override
  Future<Either<Failure, void>> saveProduct(ProductEntity product) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> saveStore(String name) async =>
      const Right(null);
}

class FixtureAssetLoader extends AssetLoader {
  const FixtureAssetLoader();
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      jsonDecode(File('$path/${locale.languageCode}.json').readAsStringSync())
          as Map<String, dynamic>;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    final font = FontLoader('IBM Plex Sans Arabic')
      ..addFont(rootBundle.load(
          'assets/fonts/IBM_Plex_Sans_Arabic/IBMPlexSansArabic-Regular.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final (width, height) in [(360.0, 800.0), (1280.0, 800.0)]) {
    testWidgets('Arabic home and real navigation fit ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cubit = BusinessCubit(LoadBusinessUseCase(HomeRepository()));
      await cubit.load();
      final appRouter = AppRouter();
      appRouter.router.go('/home');
      addTearDown(appRouter.router.dispose);
      addTearDown(cubit.close);
      final boundary = GlobalKey();
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        startLocale: const Locale('ar'),
        fallbackLocale: const Locale('ar'),
        path: 'assets/translations',
        assetLoader: const FixtureAssetLoader(),
        child: Builder(
            builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: RepaintBoundary(
                      key: boundary,
                      child: MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        locale: context.locale,
                        localizationsDelegates: context.localizationDelegates,
                        supportedLocales: context.supportedLocales,
                        theme: AppTheme.buildLight(locale: const Locale('ar')),
                        routerConfig: appRouter.router,
                      )),
                )),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('الرئيسية'), findsWidgets);
      expect(find.text('ابدأ بإضافة أول منتج'), findsOneWidget);
      expect(find.text('المنتجات'), findsWidgets);
      if (width > 1000) {
        expect(find.byType(NavigationRail), findsOneWidget);
      } else {
        expect(find.byType(NavigationBar), findsOneWidget);
      }
      final capture = Platform.environment['BASEET_CAPTURE_DIR'];
      if (capture != null) {
        await tester.runAsync(() async {
          final image = await (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 1);
          final bytes =
              (await image.toByteData(format: ui.ImageByteFormat.png))!
                  .buffer
                  .asUint8List();
          await Directory(capture).create(recursive: true);
          await File('$capture/home-ar-${width.toInt()}.png')
              .writeAsBytes(bytes);
          image.dispose();
        });
      }
      // This uses the actual app router and products page, not a duplicate test route.
      await tester.ensureVisible(find.text('المنتجات').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('المنتجات').first);
      await tester.pumpAndSettle();
      expect(appRouter.router.routeInformationProvider.value.uri.path,
          '/inventory');
      expect(find.text('إضافة منتج'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await sl.reset();
    });
  }

  testWidgets('product card is readable and sold-out products cannot be added',
      (tester) async {
    var added = false;
    const product = ProductEntity(
        id: 'p',
        name: 'منتج طويل الاسم',
        barcode: '123',
        categoryId: 'general',
        categoryName: 'general',
        buyPrice: 0,
        sellPrice: 12.75,
        stockQuantity: 0);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 158,
                height: 190,
                child: PosProductGridCard(
                    product: product, onAddToCart: () => added = true)))));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(FilledButton));
    expect(added, isFalse);
    expect(find.textContaining('12.75'), findsOneWidget);
  });
}
