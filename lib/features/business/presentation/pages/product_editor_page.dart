import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/app/presentation/refresh_business.dart';
import 'package:baseet/core/common/widgets/scanner/barcode_scanner_modal.dart';
import '../cubits/product_editor_cubit.dart';
import '../cubits/business_cubit.dart';

class ProductEditorPage extends StatefulWidget {
  final String? productId;
  const ProductEditorPage({super.key, this.productId});
  @override
  State<ProductEditorPage> createState() => _ProductEditorPageState();
}

class _ProductEditorPageState extends State<ProductEditorPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      price = TextEditingController(),
      quantity = TextEditingController(text: '0'),
      cost = TextEditingController(),
      barcode = TextEditingController(),
      minimum = TextEditingController(text: '3');
  ProductEntity? original;
  @override
  void initState() {
    super.initState();
    original = context
        .read<BusinessCubit>()
        .state
        .data
        .products
        .where((p) => p.id == widget.productId)
        .firstOrNull;
    if (original case final p?) {
      name.text = p.name;
      price.text = p.sellPrice.toString();
      quantity.text = p.stockQuantity.toString();
      cost.text = p.buyPrice.toString();
      barcode.text = p.barcode;
      minimum.text = p.minStockLimit.toString();
    }
  }

  @override
  void dispose() {
    for (final controller in [name, price, quantity, cost, barcode, minimum]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? number(String? text, {bool integer = false, bool required = false}) {
    if ((text ?? '').isEmpty) return required ? 'common_required'.lang : null;
    final n = integer ? int.tryParse(text!) : double.tryParse(text!);
    return n == null || !n.isFinite || n < 0
        ? 'simple.valid_number'.lang
        : null;
  }

  void save() {
    if (!(form.currentState?.validate() ?? false)) return;
    final product = ProductEntity(
        id: original?.id ?? '',
        name: name.text.trim(),
        barcode: barcode.text.trim(),
        categoryId: original?.categoryId ?? 'general',
        categoryName: original?.categoryName ?? 'general',
        buyPrice: double.tryParse(cost.text) ?? 0,
        sellPrice: double.parse(price.text),
        stockQuantity: int.parse(quantity.text),
        minStockLimit: int.tryParse(minimum.text) ?? 3,
        imageUrl: original?.imageUrl);
    context
        .read<ProductEditorCubit>()
        .save(product, existing: original != null);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.productId != null && original == null) {
      return Scaffold(
          appBar: AppBar(),
          body: Center(child: Text('simple.product_missing'.lang)));
    }
    return BlocConsumer<ProductEditorCubit, ProductEditorState>(
        listener: (context, state) {
          if (state.saved) {
            refreshBusiness(context, clearCart: original != null);
            context.pop();
          }
        },
        builder: (context, state) => Scaffold(
            appBar: AppBar(
                title: Text((original == null
                        ? 'simple.add_product'
                        : 'simple.edit_product')
                    .lang)),
            body: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Form(
                        key: form,
                        child: ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              Text('simple.product_basics'.lang),
                              const SizedBox(height: 20),
                              TextFormField(
                                  controller: name,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                      labelText: 'simple.product_name'.lang),
                                  validator: (v) => (v ?? '').trim().isEmpty
                                      ? 'common_required'.lang
                                      : null),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: price,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                      labelText: 'simple.sell_price'.lang),
                                  validator: (v) => number(v, required: true)),
                              const SizedBox(height: 16),
                              TextFormField(
                                  controller: quantity,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'simple.quantity'.lang),
                                  validator: (v) =>
                                      number(v, integer: true, required: true)),
                              const SizedBox(height: 16),
                              ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text('simple.more_details'.lang),
                                  children: [
                                    TextFormField(
                                        controller: barcode,
                                        decoration: InputDecoration(
                                            labelText:
                                                'simple.barcode_optional'.lang,
                                            suffixIcon: IconButton(
                                                tooltip: 'simple.scan'.lang,
                                                icon: const Icon(
                                                    Icons.qr_code_scanner),
                                                onPressed: () async {
                                                  final result =
                                                      await BarcodeScannerModal
                                                          .show(context);
                                                  if (result != null) {
                                                    barcode.text = result;
                                                  }
                                                }))),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                        controller: cost,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                            labelText:
                                                'simple.cost_optional'.lang),
                                        validator: (v) => number(v)),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                        controller: minimum,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText: 'simple.low_limit'.lang),
                                        validator: (v) =>
                                            number(v, integer: true)),
                                    const SizedBox(height: 12),
                                  ]),
                              if (state.error != null)
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Text(state.error!.lang,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error))),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                  onPressed: state.busy ? null : save,
                                  icon: const Icon(Icons.check),
                                  label: Text((state.busy
                                          ? 'simple.saving'
                                          : 'simple.save')
                                      .lang)),
                            ]))))));
  }
}
