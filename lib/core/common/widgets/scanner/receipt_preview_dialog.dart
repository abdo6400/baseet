import 'dart:io';
import 'package:flutter/material.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';

class ReceiptPreviewDialog extends StatelessWidget {
  final String imagePath;
  final String? title;

  const ReceiptPreviewDialog({
    super.key,
    required this.imagePath,
    this.title,
  });

  static void show(BuildContext context, {required String imagePath, String? title}) {
    showDialog(
      context: context,
      builder: (ctx) => ReceiptPreviewDialog(imagePath: imagePath, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(imagePath);
    final isNetwork = imagePath.startsWith('http');

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          title: Text(
            title ?? StringsManager.receiptPreview.lang,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: AppIcon(AppIcons.close, color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: isNetwork
                ? Image.network(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _buildError(theme),
                  )
                : (file.existsSync()
                    ? Image.file(
                        file,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildError(theme),
                      )
                    : _buildError(theme)),
          ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(AppIcons.warning, size: 48, color: Colors.white54),
        const SizedBox(height: 12),
        const Text(
          'Image could not be loaded or file is unavailable.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
