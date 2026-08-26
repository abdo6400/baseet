import 'package:flutter/material.dart';
import '../theme/tokens/app_tokens.dart';
import '../utils/strings_manager.dart';
import 'translation_extension.dart';

extension DialogExtension on BuildContext {
  Future<bool?> showExitAppDialog() {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          StringsManager.commonExitTitle.lang,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(StringsManager.commonExitMessage.lang),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(StringsManager.commonCancel.lang),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppLightSemanticTokens.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(StringsManager.commonConfirm.lang),
          ),
        ],
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText ?? StringsManager.commonCancel.lang),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppPrimitiveTokens.red700 : AppLightSemanticTokens.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText ?? StringsManager.commonConfirm.lang),
          ),
        ],
      ),
    );
  }
}
