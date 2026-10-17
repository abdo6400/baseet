import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/features/business/presentation/cubits/business_cubit.dart';

class MainLayoutPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainLayoutPage({super.key, required this.navigationShell});
  static const labels = [
    'simple.home',
    'simple.sell',
    'simple.customers',
    'simple.products',
    'simple.reports',
    'simple.settings'
  ];
  static const icons = [
    Icons.home_outlined,
    Icons.shopping_cart_outlined,
    Icons.people_outline,
    Icons.inventory_2_outlined,
    Icons.bar_chart_outlined,
    Icons.settings_outlined
  ];
  void select(BuildContext context, int index) {
    context.read<BusinessCubit>().load();
    navigationShell.goBranch(index,
        initialLocation: index == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final wide = box.maxWidth >= 1000;
        const bottom = [0, 1, 2, 5];
        final active = bottom.contains(navigationShell.currentIndex)
            ? bottom.indexOf(navigationShell.currentIndex)
            : 0;
        return PopScope(
            canPop: navigationShell.currentIndex == 0,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && navigationShell.currentIndex != 0) {
                select(context, 0);
              }
            },
            child: Scaffold(
              body: SafeArea(
                  child: Row(children: [
                if (wide)
                  NavigationRail(
                      extended: true,
                      indicatorColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      selectedIconTheme: IconThemeData(
                          color: Theme.of(context).colorScheme.primary),
                      minExtendedWidth: 210,
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: (i) => select(context, i),
                      leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('app_name'.lang,
                              style: Theme.of(context).textTheme.titleLarge)),
                      destinations: List.generate(
                          labels.length,
                          (i) => NavigationRailDestination(
                              icon: Icon(icons[i]),
                              label: Text(labels[i].lang)))),
                if (wide) const VerticalDivider(width: 1),
                Expanded(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: navigationShell))),
              ])),
              bottomNavigationBar: wide
                  ? null
                  : NavigationBar(
                      selectedIndex: active,
                      indicatorColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12),
                      onDestinationSelected: (i) => select(context, bottom[i]),
                      destinations: bottom
                          .map((i) => NavigationDestination(
                              icon: Icon(icons[i]),
                              selectedIcon: Icon(icons[i],
                                  color: Theme.of(context).colorScheme.primary),
                              label: labels[i].lang))
                          .toList()),
            ));
      });
}
