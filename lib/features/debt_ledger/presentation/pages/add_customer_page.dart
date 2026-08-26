import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/form/app_form_text_field.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_form_validators.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();

  void _onSave() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final customer = CustomerEntity(
        id: UuidGenerator.generate('cust'),
        name: (values['name'] as String?)?.trim() ?? '',
        phone: (values['phone'] as String?)?.trim() ?? '',
        totalDebt: 0.0,
        creditLimit: double.tryParse(values['credit_limit']?.toString() ?? '3000') ?? 3000.0,
        address: (values['address'] as String?)?.trim().isNotEmpty == true
            ? (values['address'] as String).trim()
            : null,
        notes: (values['notes'] as String?)?.trim().isNotEmpty == true
            ? (values['notes'] as String).trim()
            : null,
      );

      context.read<AddCustomerBloc>().add(SubmitAddCustomerEvent(customer));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        return AppPageWrapper(
          scrollable: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          appBar: PageHeader(
            title: StringsManager.addCustomerTitle.lang,
            showBackButton: true,
          ),
          child: AppForm(
            formKey: _formKey,
            initialValue: const {'credit_limit': '3000'},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFormTextField(
                  name: 'name',
                  label: StringsManager.addCustomerName.lang,
                  hint: StringsManager.addCustomerNameHint.lang,
                  validator: AppFormValidators.required(),
                ),
                16.vSpace,
                AppFormTextField(
                  name: 'phone',
                  label: StringsManager.addCustomerPhone.lang,
                  hint: StringsManager.addCustomerPhoneHint.lang,
                  keyboardType: TextInputType.phone,
                  validator: AppFormValidators.required(),
                ),
                16.vSpace,
                AppFormTextField(
                  name: 'credit_limit',
                  label: StringsManager.addCustomerCreditLimit.lang,
                  hint: StringsManager.addCustomerLimitHint.lang,
                  keyboardType: TextInputType.number,
                  validator: AppFormValidators.numeric(),
                ),
                16.vSpace,
                AppFormTextField(
                  name: 'address',
                  label: StringsManager.addCustomerAddress.lang,
                  hint: StringsManager.addCustomerAddressHint.lang,
                ),
                16.vSpace,
                AppFormTextField(
                  name: 'notes',
                  label: StringsManager.addCustomerNotes.lang,
                  hint: StringsManager.addCustomerNotesHint.lang,
                  maxLines: 3,
                ),
                24.vSpace,
                AppButton(
                  text: StringsManager.addCustomerSave.lang,
                  icon: AppIcons.save,
                  onPressed: _onSave,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
