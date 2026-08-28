import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locators/global_locator.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/services/license_service.dart';
import '../../../../core/utils/strings_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait minimum splash duration while verifying license
    final results = await Future.wait([
      Future.delayed(const Duration(milliseconds: 1500)),
      sl<LicenseService>().checkLicense(),
    ]);

    if (!mounted) return;

    final status = results[1] as LicenseStatus;
    if (status == LicenseStatus.active) {
      context.go(AppRoutes.pos);
    } else if (status == LicenseStatus.expired) {
      context.go('${AppRoutes.activation}?expired=true');
    } else {
      context.go(AppRoutes.activation);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background ambient glow
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.12 : 0.06),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon with subtle shadow
                    const AppLogo(size: 110, showText: false),
                    const SizedBox(height: 24),
                    // App Title "بسيط"
                    Text(
                      StringsManager.appName.lang,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // App Subtitle "الكاشير ودفتر الديون الذكي"
                    Text(
                      StringsManager.appSubtitle.lang,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading spinner
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
