import 'package:flutter/material.dart';
import '../theme/tokens/app_tokens.dart';

class OverlayLoader {
  static OverlayEntry? _currentLoader;

  static void show(BuildContext context) {
    if (_currentLoader != null) return;

    _currentLoader = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppLightSemanticTokens.primary),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentLoader!);
  }

  static void hide() {
    _currentLoader?.remove();
    _currentLoader = null;
  }
}
