import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/dialog_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../../pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import '../../../pos/presentation/blocs/catalog/pos_catalog_event.dart';
import '../../domain/entities/category_entity.dart';
import '../blocs/add_category/add_category_bloc.dart';
import '../blocs/add_category/add_category_event.dart';
import '../blocs/add_category/add_category_state.dart';
import '../blocs/inventory_list/inventory_list_bloc.dart';
import '../blocs/inventory_list/inventory_list_event.dart';
import '../blocs/inventory_list/inventory_list_state.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  CategoryEntity? _editingCategory;

  final List<Color> _categoryColors = const [
    Color(0xFF2563EB), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFF64748B), // Slate
  ];
  int _selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());
  }

  void _onSave() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final category = CategoryEntity(
        id: _editingCategory?.id ?? UuidGenerator.generate('cat'),
        name: (values['name'] as String?)?.trim() ?? '',
        iconName: 'category',
      );

      context.read<AddCategoryBloc>().add(SubmitAddCategoryEvent(category));
    }
  }

  void _startEditing(CategoryEntity category) {
    setState(() {
      _editingCategory = category;
      _formKey.currentState?.patchValue({'name': category.name});
    });
  }

  void _clearEditing() {
    setState(() {
      _editingCategory = null;
      _formKey.currentState?.reset();
    });
  }

  void _confirmDelete(CategoryEntity category) async {
    final confirmed = await context.showConfirmDialog(
      title: '${StringsManager.categoryDelete.lang} (${category.name})',
      message: StringsManager.categoryDeleteConfirm.lang,
      confirmText: StringsManager.commonDelete.lang,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<AddCategoryBloc>().add(DeleteCategoryEvent(category.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AddCategoryBloc, AddCategoryState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: state.status == AddCategoryStatus.submitting,
          isError: state.status == AddCategoryStatus.error,
          isSuccess: state.status == AddCategoryStatus.success,
          errorMessage: state.errorMessage,
          successMessage: _editingCategory != null
              ? StringsManager.commonSuccess.lang
              : StringsManager.addCategorySuccess.lang,
          onSuccess: () {
            context.read<InventoryListBloc>().add(const LoadInventoryEvent());
            context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
            _clearEditing();
          },
        );
      },
      builder: (context, state) {
        return AppPageWrapper(
          scrollable: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          appBar: PageHeader(
            title: _editingCategory != null ? StringsManager.categoryEdit.lang : StringsManager.addCategoryTitle.lang,
            showBackButton: true,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: AppForm(
                  formKey: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _editingCategory != null ? StringsManager.categoryEdit.lang : StringsManager.addCategoryTitle.lang,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (_editingCategory != null)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: _clearEditing,
                              tooltip: StringsManager.commonCancel.lang,
                            ),
                        ],
                      ),
                      14.vSpace,
                      AppFormTextField(
                        name: 'name',
                        label: StringsManager.addCategoryName.lang,
                        hint: StringsManager.addCategoryExampleHint.lang,
                        validator: AppFormValidators.required(),
                      ),
                      16.vSpace,

                      // Color selection palette
                      Text(
                        StringsManager.addCategoryColor.lang,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_categoryColors.length, (index) {
                          final color = _categoryColors[index];
                          final isSelected = _selectedColorIndex == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorIndex = index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: theme.colorScheme.onSurface, width: 3)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }),
                      ),
                      24.vSpace,
                      AppButton(
                        text: _editingCategory != null
                            ? StringsManager.categorySaveEdit.lang
                            : StringsManager.addCategorySave.lang,
                        icon: AppIcons.save,
                        onPressed: _onSave,
                      ),
                    ],
                  ),
                ),
              ),
              24.vSpace,

              // Existing Categories List from SQLite
              BlocBuilder<InventoryListBloc, InventoryListState>(
                builder: (context, invState) {
                  final categories = invState.categories.where((c) => c.id != 'cat_0').toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${StringsManager.categoryExistingList.lang} (${categories.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      12.vSpace,
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => 8.vSpace,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isCurrentlyEditing = _editingCategory?.id == cat.id;

                          return Container(
                            decoration: BoxDecoration(
                              color: isCurrentlyEditing
                                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                                  : theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isCurrentlyEditing
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _categoryColors[index % _categoryColors.length].withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.category_rounded,
                                    color: _categoryColors[index % _categoryColors.length],
                                    size: 18,
                                  ),
                                ),
                              ),
                              title: Text(
                                cat.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isCurrentlyEditing ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: AppIcon(AppIcons.edit, size: 18, color: theme.colorScheme.primary),
                                    onPressed: () => _startEditing(cat),
                                  ),
                                  IconButton(
                                    icon: AppIcon(AppIcons.delete, size: 18, color: theme.colorScheme.error),
                                    onPressed: () => _confirmDelete(cat),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
