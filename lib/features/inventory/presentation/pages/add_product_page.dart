import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/config/database/local/mock_data.dart';
import 'package:baseet/core/common/widgets/button/app_button.dart';
import 'package:baseet/core/common/widgets/form/app_text_field.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/common/widgets/layout/page_header.dart';
import 'package:baseet/core/common/widgets/scanner/barcode_scanner_modal.dart';
import 'package:baseet/core/extensions/state_handle_extension.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/theme/tokens/app_tokens.dart';
import 'package:baseet/core/utils/app_icons.dart';
import 'package:baseet/core/utils/strings_manager.dart';
import 'package:baseet/core/utils/uuid_generator.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/add_product/add_product_state.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_event.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');
  final _minStockController = TextEditingController(text: '3');
  String _selectedCategoryId = 'cat_1';

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = BaseetMockData.initialCategories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => BaseetMockData.initialCategories[1],
      );

      final product = ProductEntity(
        id: UuidGenerator.generate('prod'),
        name: _nameController.text.trim(),
        barcode: _barcodeController.text.trim().isNotEmpty
            ? _barcodeController.text.trim()
            : UuidGenerator.generate('622'),
        categoryId: _selectedCategoryId,
        categoryName: category.name,
        buyPrice: double.tryParse(_buyPriceController.text) ?? 0.0,
        sellPrice: double.tryParse(_sellPriceController.text) ?? 0.0,
        stockQuantity: int.tryParse(_stockController.text) ?? 0,
        minStockLimit: int.tryParse(_minStockController.text) ?? 3,
        imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=300&q=80',
      );

      context.read<AddProductBloc>().add(SubmitAddProductEvent(product));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = BaseetMockData.initialCategories.where((c) => c.id != 'cat_0').toList();

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
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: PageHeader(
            title: StringsManager.addProductTitle.lang,
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
                    label: StringsManager.addProductName.lang,
                    hint: StringsManager.addProductExampleHint.lang,
                    validator: (val) => val == null || val.trim().isEmpty ? StringsManager.commonRequired.lang : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _barcodeController,
                    label: StringsManager.addProductBarcode.lang,
                    hint: StringsManager.addProductBarcodeHint.lang,
                    suffixIcon: IconButton(
                      icon: AppIcon(AppIcons.barcode, size: 20),
                      tooltip: StringsManager.barcodeScannerTitle.lang,
                      onPressed: () async {
                        final code = await BarcodeScannerModal.show(context);
                        if (code != null && code.isNotEmpty) {
                          _barcodeController.text = code;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  Text(
                    StringsManager.addProductCategory.lang,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategoryId,
                        items: categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCategoryId = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prices Row
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _buyPriceController,
                          label: StringsManager.addProductBuyPrice.lang,
                          hint: '0.0',
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.trim().isEmpty ? StringsManager.commonRequired.lang : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _sellPriceController,
                          label: StringsManager.addProductSellPrice.lang,
                          hint: '0.0',
                          keyboardType: TextInputType.number,
                          validator: (val) => val == null || val.trim().isEmpty ? StringsManager.commonRequired.lang : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock & Min Alert Row
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _stockController,
                          label: StringsManager.addProductInitialStock.lang,
                          hint: '10',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _minStockController,
                          label: StringsManager.addProductMinStock.lang,
                          hint: '3',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    text: StringsManager.addProductSave.lang,
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
