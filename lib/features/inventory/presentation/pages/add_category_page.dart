import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/common/widgets/button/app_button.dart';
import 'package:baseet/core/common/widgets/form/app_text_field.dart';
import 'package:baseet/core/common/widgets/layout/page_header.dart';
import 'package:baseet/core/extensions/state_handle_extension.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_category/add_category_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_category/add_category_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_category/add_category_state.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = CategoryEntity(
        id: '',
        name: _nameController.text.trim(),
        iconName: 'category',
      );

      context.read<AddCategoryBloc>().add(SubmitAddCategoryEvent(category));
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
          successMessage: StringsManager.addCategorySuccess.lang,
          onSuccess: () {
            context.read<InventoryListBloc>().add(const LoadInventoryEvent());
            context.pop();
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PageHeader(
            title: StringsManager.addCategoryTitle.lang,
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: StringsManager.addCategoryName.lang,
                    hint: StringsManager.addCategoryExampleHint.lang,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? StringsManager.commonRequired.lang
                        : null,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: StringsManager.addCategorySave.lang,
                    icon: AppIcons.save,
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
