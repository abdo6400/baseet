import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/common/widgets/button/app_button.dart';
import 'package:baseet/core/common/widgets/form/app_form.dart';
import 'package:baseet/core/common/widgets/form/app_form_dropdown.dart';
import 'package:baseet/core/common/widgets/form/app_form_text_field.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/common/widgets/layout/app_page_wrapper.dart';
import 'package:baseet/core/common/widgets/layout/page_header.dart';
import 'package:baseet/core/common/widgets/scanner/barcode_scanner_modal.dart';
import 'package:baseet/core/extensions/spacing_extension.dart';
import 'package:baseet/core/extensions/state_handle_extension.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_form_validators.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/core/utils/uuid_generator.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_state.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_state.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_event.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());
  }

  void _onSave() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final categoryId = values['category_id']?.toString() ?? 'cat_1';
      final categories = context.read<InventoryListBloc>().state.categories;
      final category = categories.where((c) => c.id == categoryId).firstOrNull;
      final categoryName = category?.name ?? StringsManager.posAllCategories.lang;

      final barcode = (values['barcode'] as String?)?.trim();

      final product = ProductEntity(
        id: UuidGenerator.generate('prod'),
        name: (values['name'] as String?)?.trim() ?? '',
        barcode: (barcode != null && barcode.isNotEmpty) ? barcode : UuidGenerator.generate('622'),
        categoryId: categoryId,
        categoryName: categoryName,
        buyPrice: double.tryParse(values['buy_price']?.toString() ?? '0') ?? 0.0,
        sellPrice: double.tryParse(values['sell_price']?.toString() ?? '0') ?? 0.0,
        stockQuantity: int.tryParse(values['stock']?.toString() ?? '10') ?? 10,
        minStockLimit: int.tryParse(values['min_stock']?.toString() ?? '3') ?? 3,
        imageUrl: '',
      );

      context.read<AddProductBloc>().add(SubmitAddProductEvent(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductBloc, AddProductState>(
      listener: (context, state) {
        context.showStateHandler(
          isLoading: state.status == AddProductStatus.submitting,
          isError: state.status == AddProductStatus.error,
          isSuccess: state.status == AddProductStatus.success,
          errorMessage: state.errorMessage,
          successMessage: StringsManager.addProductSuccess.lang,
          onSuccess: () {
            context.read<InventoryListBloc>().add(const LoadInventoryEvent());
            context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
            context.pop();
          },
        );
      },
      builder: (context, state) {
        return AppPageWrapper(
          scrollable: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          appBar: PageHeader(
            title: StringsManager.addProductTitle.lang,
            showBackButton: true,
          ),
          child: AppForm(
            formKey: _formKey,
            initialValue: const {
              'stock': '10',
              'min_stock': '3',
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppFormTextField(
                  name: 'name',
                  label: StringsManager.addProductName.lang,
                  hint: StringsManager.addProductExampleHint.lang,
                  validator: AppFormValidators.required(),
                ),
                16.vSpace,
                AppFormTextField(
                  name: 'barcode',
                  label: StringsManager.addProductBarcode.lang,
                  hint: StringsManager.addProductBarcodeHint.lang,
                  suffixIcon: IconButton(
                    icon: AppIcon(AppIcons.barcode, size: 20),
                    tooltip: StringsManager.barcodeScannerTitle.lang,
                    onPressed: () async {
                      final inventoryBloc = context.read<InventoryListBloc>();
                      final code = await BarcodeScannerModal.show(context);
                      if (!mounted || code == null || code.isEmpty) return;

                      final products = inventoryBloc.state.products;
                      final existing = products.where((p) => p.barcode == code).firstOrNull;

                      if (existing != null) {
                        _formKey.currentState?.patchValue({
                          'barcode': code,
                          'name': existing.name,
                          'buy_price': existing.buyPrice.toStringAsFixed(0),
                          'sell_price': existing.sellPrice.toStringAsFixed(0),
                          'stock': existing.stockQuantity.toString(),
                          'min_stock': existing.minStockLimit.toString(),
                          'category_id': existing.categoryId,
                        });
                        // ignore: use_build_context_synchronously
                        context.showStateHandler(
                          isLoading: false,
                          isSuccess: true,
                          successMessage: StringsManager.barcodeProductAdded.trArgs(args: [existing.name]),
                        );
                      } else {
                        _formKey.currentState?.patchValue({'barcode': code});
                      }
                    },
                  ),
                ),
                16.vSpace,

                // Category Dropdown
                BlocBuilder<InventoryListBloc, InventoryListState>(
                  builder: (context, invState) {
                    final categories = invState.categories.where((c) => c.id != 'cat_0').toList();
                    return AppFormDropdown<String>(
                      name: 'category_id',
                      label: StringsManager.addProductCategory.lang,
                      items: categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      validator: AppFormValidators.required(),
                    );
                  },
                ),
                16.vSpace,

                // Prices Row
                Row(
                  children: [
                    Expanded(
                      child: AppFormTextField(
                        name: 'buy_price',
                        label: StringsManager.addProductBuyPrice.lang,
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                        validator: AppFormValidators.compose([
                          AppFormValidators.required(),
                          AppFormValidators.numeric(),
                        ]),
                      ),
                    ),
                    12.hSpace,
                    Expanded(
                      child: AppFormTextField(
                        name: 'sell_price',
                        label: StringsManager.addProductSellPrice.lang,
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                        validator: AppFormValidators.compose([
                          AppFormValidators.required(),
                          AppFormValidators.numeric(),
                        ]),
                      ),
                    ),
                  ],
                ),
                16.vSpace,

                // Stock & Min Alert Row
                Row(
                  children: [
                    Expanded(
                      child: AppFormTextField(
                        name: 'stock',
                        label: StringsManager.addProductInitialStock.lang,
                        hint: '10',
                        keyboardType: TextInputType.number,
                        validator: AppFormValidators.numeric(),
                      ),
                    ),
                    12.hSpace,
                    Expanded(
                      child: AppFormTextField(
                        name: 'min_stock',
                        label: StringsManager.addProductMinStock.lang,
                        hint: '3',
                        keyboardType: TextInputType.number,
                        validator: AppFormValidators.numeric(),
                      ),
                    ),
                  ],
                ),
                24.vSpace,

                AppButton(
                  text: StringsManager.addProductSave.lang,
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
