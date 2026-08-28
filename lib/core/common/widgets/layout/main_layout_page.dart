import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:baseet/config/locators/global_locator.dart';
import 'package:baseet/core/extensions/dialog_extension.dart';
import 'package:baseet/core/services/settings_service.dart';
import 'custom_bottom_nav_bar.dart';

class MainLayoutPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayoutPage({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        sl<SettingsService>().setHasSeenShowcase(true);
      },
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (navigationShell.currentIndex != 0) {
            _onTap(0);
          } else {
            final shouldExit = await context.showExitAppDialog();
            if (shouldExit == true) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
          body: navigationShell,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }
}
