import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baseet/core/common/widgets/button/app_button.dart';
import 'package:baseet/core/common/widgets/button/app_outlined_button.dart';
import 'package:baseet/core/common/widgets/form/app_form.dart';
import 'package:baseet/core/common/widgets/form/app_form_dropdown.dart';
import 'package:baseet/core/common/widgets/form/app_form_text_field.dart';
import 'package:baseet/core/common/widgets/icon/app_icon.dart';
import 'package:baseet/core/common/widgets/layout/app_page_wrapper.dart';
import 'package:baseet/core/common/widgets/layout/page_header.dart';
import 'package:baseet/core/common/widgets/scanner/barcode_scanner_modal.dart';
import 'package:baseet/core/extensions/dialog_extension.dart';
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
  final ProductEntity? productToEdit;

  const AddProductPage({super.key, this.productToEdit});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ImagePicker _picker = ImagePicker();
  String _imageUrl = '';

  bool get isEditMode => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.productToEdit?.imageUrl?.trim() ?? '';
    context.read<InventoryListBloc>().add(const LoadInventoryEvent());
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
      }
    } catch (_) {
      // Ignore or handle permission error gracefully
    }
  }

  Future<void> _enterImageUrl() async {
    final url = await context.showTextInputDialog(
      title: StringsManager.productImageEnterUrl.lang,
      hintText: StringsManager.productImageEnterUrlHint.lang,
      initialValue: _imageUrl.startsWith('http') ? _imageUrl : '',
      icon: AppIcons.document,
    );
    if (url != null && url.isNotEmpty && mounted) {
      setState(() {
        _imageUrl = url.trim();
      });
    }
  }

  void _showImageSourcePicker() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                16.vSpace,
                Text(
                  StringsManager.productImageSource.lang,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                16.vSpace,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(AppIcons.inventory, color: theme.colorScheme.primary, size: 20),
                  ),
                  title: Text(
                    StringsManager.productImagePickGallery.lang,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPrimitiveTokens.emerald600.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppPrimitiveTokens.emerald600, size: 20),
                  ),
                  title: Text(
                    StringsManager.productImageTakeCamera.lang,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.link_rounded, color: theme.colorScheme.secondary, size: 20),
                  ),
                  title: Text(
                    StringsManager.productImageEnterUrl.lang,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _enterImageUrl();
                  },
                ),
                if (_imageUrl.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppPrimitiveTokens.red700.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const AppIcon(AppIcons.delete, color: AppPrimitiveTokens.red700, size: 20),
                    ),
                    title: Text(
                      StringsManager.productImageRemove.lang,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppPrimitiveTokens.red700),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _imageUrl = '';
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
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
        id: isEditMode ? widget.productToEdit!.id : UuidGenerator.generate('prod'),
        name: (values['name'] as String?)?.trim() ?? '',
        barcode: (barcode != null && barcode.isNotEmpty)
            ? barcode
            : (isEditMode ? widget.productToEdit!.barcode : UuidGenerator.generate('622')),
        categoryId: categoryId,
        categoryName: categoryName,
        buyPrice: double.tryParse(values['buy_price']?.toString() ?? '0') ?? 0.0,
        sellPrice: double.tryParse(values['sell_price']?.toString() ?? '0') ?? 0.0,
        stockQuantity: int.tryParse(values['stock']?.toString() ?? '10') ?? 10,
        minStockLimit: int.tryParse(values['min_stock']?.toString() ?? '3') ?? 3,
        imageUrl: _imageUrl.trim(),
      );

      if (isEditMode) {
        context.read<AddProductBloc>().add(SubmitUpdateProductEvent(product));
      } else {
        context.read<AddProductBloc>().add(SubmitAddProductEvent(product));
      }
    }
  }

  void _onDeleteProduct() async {
    final confirmed = await context.showConfirmDialog(
      title: StringsManager.productDelete.lang,
      message: StringsManager.productDeleteConfirm.lang,
      confirmText: StringsManager.productDelete.lang,
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<AddProductBloc>().add(SubmitDeleteProductEvent(widget.productToEdit!.id));
    }
  }

  Widget _buildPreviewImage(ThemeData theme) {
    final cleanUrl = _imageUrl.trim();
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(theme),
      );
    } else if (cleanUrl.startsWith('assets/')) {
      return Image.asset(
        cleanUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(theme),
      );
    } else {
      final file = File(cleanUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(theme),
        );
      }
      return _buildFallbackIcon(theme);
    }
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Center(
      child: AppIcon(
        AppIcons.inventory,
        size: 36,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
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
          successMessage: isEditMode
              ? StringsManager.productUpdateSuccess.lang
              : StringsManager.addProductSuccess.lang,
          onSuccess: () {
            context.read<InventoryListBloc>().add(const LoadInventoryEvent());
            context.read<PosCatalogBloc>().add(const LoadPosCatalogEvent());
            context.pop();
          },
        );
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        return AppPageWrapper(
          scrollable: true,
          padding: const EdgeInsets.all(AppSpacing.md),
          appBar: PageHeader(
            title: isEditMode
                ? StringsManager.productEdit.lang
                : StringsManager.addProductTitle.lang,
            showBackButton: true,
            actions: [
              if (isEditMode)
                IconButton(
                  icon: const AppIcon(AppIcons.delete, color: AppPrimitiveTokens.red700, size: 22),
                  tooltip: StringsManager.productDelete.lang,
                  onPressed: _onDeleteProduct,
                ),
            ],
          ),
          child: AppForm(
            formKey: _formKey,
            initialValue: isEditMode
                ? {
                    'name': widget.productToEdit!.name,
                    'barcode': widget.productToEdit!.barcode,
                    'category_id': widget.productToEdit!.categoryId,
                    'buy_price': widget.productToEdit!.buyPrice.toStringAsFixed(0),
                    'sell_price': widget.productToEdit!.sellPrice.toStringAsFixed(0),
                    'stock': widget.productToEdit!.stockQuantity.toString(),
                    'min_stock': widget.productToEdit!.minStockLimit.toString(),
                  }
                : const {
                    'stock': '10',
                    'min_stock': '3',
                  },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Selector / Preview Card
                Center(
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: _showImageSourcePicker,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: _imageUrl.isNotEmpty
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: _imageUrl.isNotEmpty ? 2 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _imageUrl.isNotEmpty
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    _buildPreviewImage(theme),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        color: Colors.black.withValues(alpha: 0.55),
                                        child: Text(
                                          StringsManager.commonEdit.lang,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: AppIcon(
                                        AppIcons.inventory,
                                        size: 30,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    8.vSpace,
                                    Text(
                                      StringsManager.productImageTitle.lang,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    2.vSpace,
                                    Text(
                                      StringsManager.commonOptional.lang,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (_imageUrl.isNotEmpty)
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageUrl = '';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppPrimitiveTokens.red700,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                20.vSpace,

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
                    icon: const AppIcon(AppIcons.barcode, size: 20),
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
                28.vSpace,

                AppButton(
                  text: isEditMode
                      ? StringsManager.productEdit.lang
                      : StringsManager.addProductSave.lang,
                  icon: isEditMode ? AppIcons.edit : AppIcons.save,
                  onPressed: _onSave,
                ),

                if (isEditMode) ...[
                  12.vSpace,
                  AppOutlinedButton(
                    text: StringsManager.productDelete.lang,
                    icon: AppIcons.delete,
                    borderColor: AppPrimitiveTokens.red700,
                    textColor: AppPrimitiveTokens.red700,
                    width: double.infinity,
                    height: 48,
                    borderRadius: AppRadius.lg,
                    onPressed: _onDeleteProduct,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
