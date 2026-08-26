import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/tokens/app_tokens.dart';
import '../utils/strings_manager.dart';

extension DialogExtension on BuildContext {
  Future<bool?> showExitAppDialog() {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          StringsManager.commonExitTitle.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(StringsManager.commonExitMessage.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(StringsManager.commonCancel.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppLightSemanticTokens.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(StringsManager.commonConfirm.tr()),
          ),
        ],
      ),
    );
  }
}
