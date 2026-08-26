import 'package:flutter/material.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';

class PaymentMethodTile extends StatelessWidget {
  final String title;
  final PaymentMethod method;
  final dynamic icon;
  final bool isSelected;
  final bool isDebt;
  final ValueChanged<PaymentMethod> onSelected;

  const PaymentMethodTile({
    super.key,
    required this.title,
    required this.method,
    required this.icon,
    required this.isSelected,
    this.isDebt = false,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isDebt ? theme.colorScheme.secondary : theme.colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? activeColor : theme.colorScheme.outlineVariant,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            children: [
              AppIcon(icon, color: isSelected ? activeColor : theme.colorScheme.onSurfaceVariant, size: 22),
              4.vSpace,
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
