import 'package:flutter/material.dart';

class AppPageWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const AppPageWrapper({
    super.key,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = child;

    if (padding != null) {
      bodyContent = Padding(padding: padding!, child: bodyContent);
    }

    if (scrollable) {
      bodyContent = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
