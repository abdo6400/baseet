import 'package:get_it/get_it.dart';
import 'debt_locator.dart';
import 'global_locator.dart';
import 'inventory_locator.dart';
import 'pos_locator.dart';
import 'reports_locator.dart';

Future<void> initLocator() async {
  final sl = GetIt.instance;
  await initGlobalLocator(sl);
  initPosLocator(sl);
  initDebtLocator(sl);
  initInventoryLocator(sl);
  initReportsLocator(sl);
}
