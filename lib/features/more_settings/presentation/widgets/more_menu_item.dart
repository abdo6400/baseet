import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/utils/app_icons.dart';

class MoreMenuItem extends StatelessWidget {
  final String title;
  final dynamic icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MoreMenuItem({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: AppIcon(icon, color: iconColor ?? theme.colorScheme.primary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: iconColor,
        ),
      ),
      trailing: trailing ?? AppIcon(AppIcons.arrowForward, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
