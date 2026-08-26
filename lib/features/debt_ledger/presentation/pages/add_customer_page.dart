import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_text_field.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/customer_entity.dart';
import '../blocs/add_customer/add_customer_bloc.dart';
import '../blocs/add_customer/add_customer_event.dart';
import '../blocs/add_customer/add_customer_state.dart';
import '../blocs/customers_list/customers_list_bloc.dart';
import '../blocs/customers_list/customers_list_event.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _limitController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _limitController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final customer = CustomerEntity(
        id: UuidGenerator.generate('cust'),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        totalDebt: 0.0,
        creditLimit: double.tryParse(_limitController.text) ?? 3000.0,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      context.read<AddCustomerBloc>().add(SubmitAddCustomerEvent(customer));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AddCustomerBloc, AddCustomerState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: state.status == AddCustomerStatus.submitting,
          isError: state.status == AddCustomerStatus.error,
          isSuccess: state.status == AddCustomerStatus.success,
          errorMessage: state.errorMessage,
          successMessage: StringsManager.addCustomerSuccess.lang,
          onSuccess: () {
            context.read<CustomersListBloc>().add(const LoadCustomersListEvent());
            context.pop();
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PageHeader(
            title: StringsManager.addCustomerTitle.lang,
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
                    label: StringsManager.addCustomerName.lang,
                    hint: StringsManager.addCustomerNameHint.lang,
                    validator: (val) => val == null || val.trim().isEmpty ? StringsManager.commonRequired.lang : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    label: StringsManager.addCustomerPhone.lang,
                    hint: StringsManager.addCustomerPhoneHint.lang,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().isEmpty ? StringsManager.commonRequired.lang : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _limitController,
                    label: StringsManager.addCustomerCreditLimit.lang,
                    hint: StringsManager.addCustomerLimitHint.lang,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _addressController,
                    label: StringsManager.addCustomerAddress.lang,
                    hint: StringsManager.addCustomerAddressHint.lang,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _notesController,
                    label: StringsManager.addCustomerNotes.lang,
                    hint: StringsManager.addCustomerNotesHint.lang,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  AppButton(
                    text: StringsManager.addCustomerSave.lang,
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
