import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/common/widgets/logo/app_logo.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/responsive_text_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash animation for display duration, then navigate to main flow
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    context.go(AppRoutes.pos);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF090D16),
              Color(0xFF0F172A),
              Color(0xFF061E1A),
            ],
            stops: [0.0, 0.5, 1.0],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppPrimitiveTokens.emerald50.withValues(alpha: 0.35),
              AppPrimitiveTokens.emerald50.withValues(alpha: 0.65),
            ],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Stack(
          children: [
            // Ambient glowing radial aura behind logo
            Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _glowAnimation.value,
                    child: Container(
                      width: context.safeDp(280),
                      height: context.safeDp(280),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                            primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Subtle decorative ambient circle top right
            Positioned(
              top: -context.safeDp(60),
              right: -context.safeDp(60),
              child: Container(
                width: context.safeDp(200),
                height: context.safeDp(200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDark ? 0.06 : 0.04),
                ),
              ),
            ),

            // Subtle decorative ambient circle bottom left
            Positioned(
              bottom: -context.safeDp(40),
              left: -context.safeDp(40),
              child: Container(
                width: context.safeDp(180),
                height: context.safeDp(180),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
                ),
              ),
            ),

            // Main Center Branding
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Elevated App Icon Card
                      Container(
                        padding: EdgeInsets.all(context.safeDp(16)),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(context.safeDp(28)),
                          border: Border.all(
                            color: isDark
                                ? theme.colorScheme.outlineVariant.withValues(alpha: 0.3)
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: AppLogo(
                          size: context.safeDp(92),
                          showText: false,
                        ),
                      ),
                      24.vSpace,

                      // App Title "بسيط"
                      SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              StringsManager.appName.lang,
                              style: context.label(
                                40,
                                weight: FontWeight.w900,
                                color: primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            6.vSpace,

                            // Tagline Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.safeDp(16),
                                vertical: context.safeDp(6),
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? primaryColor.withValues(alpha: 0.12)
                                    : primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.18),
                                ),
                              ),
                              child: Text(
                                StringsManager.appSubtitle.lang,
                                style: context.label(
                                  13,
                                  weight: FontWeight.w700,
                                  color: isDark
                                      ? AppPrimitiveTokens.emerald300
                                      : primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Loading Indicator & Footer
            Positioned(
              bottom: context.safeDp(40),
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Smooth linear loading track
                    SizedBox(
                      width: context.safeDp(140),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        child: LinearProgressIndicator(
                          minHeight: context.safeDp(3.5),
                          backgroundColor: primaryColor.withValues(alpha: isDark ? 0.15 : 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    ),
                    12.vSpace,

                    // Version & status footer
                    Text(
                      'BASEET POS • v1.0.0',
                      style: context.label(
                        11,
                        weight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
