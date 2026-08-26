import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'overlay_loader.dart';

extension StateHandleExtension on BuildContext {
  void showStateHandler({
    required bool isLoading,
    bool isError = false,
    bool isSuccess = false,
    String? errorMessage,
    String? successMessage,
    VoidCallback? onSuccess,
  }) {
    if (isLoading) {
      OverlayLoader.show(this);
    } else {
      OverlayLoader.hide();
    }

    if (isError && errorMessage != null) {
      toastification.show(
        context: this,
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        title: Text(errorMessage),
        autoCloseDuration: const Duration(seconds: 4),
      );
    }

    if (isSuccess) {
      if (successMessage != null) {
        toastification.show(
          context: this,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: Text(successMessage),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
      onSuccess?.call();
    }
  }
}
