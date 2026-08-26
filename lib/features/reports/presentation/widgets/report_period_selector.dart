import 'package:flutter/material.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/strings_manager.dart';

class ReportPeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodSelected;

  const ReportPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _PeriodTabItem(
            title: StringsManager.reportsPeriodToday.lang,
            periodKey: 'today',
            isSelected: selectedPeriod == 'today',
            onTap: () => onPeriodSelected('today'),
          ),
          _PeriodTabItem(
            title: StringsManager.reportsPeriodWeek.lang,
            periodKey: 'week',
            isSelected: selectedPeriod == 'week',
            onTap: () => onPeriodSelected('week'),
          ),
          _PeriodTabItem(
            title: StringsManager.reportsPeriodMonth.lang,
            periodKey: 'month',
            isSelected: selectedPeriod == 'month',
            onTap: () => onPeriodSelected('month'),
          ),
        ],
      ),
    );
  }
}

class _PeriodTabItem extends StatelessWidget {
  final String title;
  final String periodKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodTabItem({
    required this.title,
    required this.periodKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
