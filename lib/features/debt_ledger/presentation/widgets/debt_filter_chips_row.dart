import 'package:flutter/material.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/strings_manager.dart';

class DebtFilterChipsRow extends StatelessWidget {
  final DebtStatus? selectedStatus;
  final bool sortByHighest;
  final void Function(DebtStatus? status, bool sortByHighest) onFilterSelected;

  const DebtFilterChipsRow({
    super.key,
    required this.selectedStatus,
    required this.sortByHighest,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildChip(
            context,
            label: StringsManager.debtsFilterAll.lang,
            isSelected: selectedStatus == null && !sortByHighest,
            onTap: () => onFilterSelected(null, false),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: StringsManager.debtsFilterOverdue.lang,
            isSelected: selectedStatus == DebtStatus.overdue,
            onTap: () => onFilterSelected(DebtStatus.overdue, false),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: StringsManager.debtsFilterRegular.lang,
            isSelected: selectedStatus == DebtStatus.regular,
            onTap: () => onFilterSelected(DebtStatus.regular, false),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: StringsManager.debtsFilterHighest.lang,
            isSelected: sortByHighest,
            onTap: () => onFilterSelected(null, true),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
