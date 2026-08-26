import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../../../config/locators/global_locator.dart';
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
import '../../domain/entities/supplier_entity.dart';
import '../blocs/add_supplier/add_supplier_bloc.dart';
import '../blocs/add_supplier/add_supplier_event.dart';
import '../blocs/add_supplier/add_supplier_state.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _onSave(BuildContext context) {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final newSupplier = SupplierEntity(
        id: 'sup_${DateTime.now().millisecondsSinceEpoch}',
        name: (values['name'] as String?)?.trim() ?? '',
        companyName: (values['company_name'] as String?)?.trim() ?? '',
        phone: (values['phone'] as String?)?.trim() ?? '',
        address: (values['address'] as String?)?.trim() ?? '',
        totalDebt: double.tryParse(values['initial_debt']?.toString() ?? '0') ?? 0.0,
        lastTransactionDate: DateTime.now(),
      );

      context.read<AddSupplierBloc>().add(SubmitAddSupplierEvent(newSupplier));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddSupplierBloc>(),
      child: BlocConsumer<AddSupplierBloc, AddSupplierState>(
        listener: (context, state) {
          context.showStateHandler(
            isLoading: state.status == AddSupplierStatus.loading,
            isError: state.status == AddSupplierStatus.error,
            isSuccess: state.status == AddSupplierStatus.success,
            errorMessage: state.errorMessage ?? StringsManager.commonError.lang,
            successMessage: StringsManager.suppliersSuccess.lang,
            onSuccess: () {
              if (state.createdSupplier != null) {
                Navigator.pop(context, state.createdSupplier);
              }
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.status == AddSupplierStatus.loading;

          return AppPageWrapper(
            scrollable: true,
            padding: const EdgeInsets.all(AppSpacing.md),
            appBar: PageHeader(
              title: StringsManager.suppliersAddSupplier.lang,
              showBackButton: true,
            ),
            child: AppForm(
              formKey: _formKey,
              initialValue: const {'initial_debt': '0'},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppFormTextField(
                    name: 'name',
                    label: StringsManager.suppliersName.lang,
                    hint: StringsManager.suppliersNameHint.lang,
                    validator: AppFormValidators.required(),
                  ),
                  16.vSpace,
                  AppFormTextField(
                    name: 'company_name',
                    label: StringsManager.suppliersCompanyName.lang,
                    hint: StringsManager.suppliersCompanyNameHint.lang,
                    validator: AppFormValidators.required(),
                  ),
                  16.vSpace,
                  AppFormTextField(
                    name: 'phone',
                    label: StringsManager.suppliersPhone.lang,
                    hint: StringsManager.suppliersPhoneHint.lang,
                    keyboardType: TextInputType.phone,
                    validator: AppFormValidators.compose([
                      AppFormValidators.required(),
                    ]),
                  ),
                  16.vSpace,
                  AppFormTextField(
                    name: 'address',
                    label: StringsManager.suppliersAddress.lang,
                    hint: StringsManager.suppliersAddressHint.lang,
                  ),
                  16.vSpace,
                  AppFormTextField(
                    name: 'initial_debt',
                    label: StringsManager.suppliersInitialDebt.lang,
                    hint: StringsManager.suppliersInitialDebtHint.lang,
                    keyboardType: TextInputType.number,
                    validator: AppFormValidators.numeric(),
                  ),
                  24.vSpace,
                  AppButton(
                    text: StringsManager.suppliersSave.lang,
                    icon: AppIcons.save,
                    isLoading: isLoading,
                    onPressed: () => _onSave(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
