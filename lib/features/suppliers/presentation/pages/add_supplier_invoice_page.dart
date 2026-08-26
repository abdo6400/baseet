import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:printing/printing.dart';
import 'package:toastification/toastification.dart';
import '../../../../core/common/widgets/button/app_button.dart';
import '../../../../core/common/widgets/form/app_form.dart';
import '../../../../core/common/widgets/icon/app_icon.dart';
import '../../../../core/common/widgets/layout/app_page_wrapper.dart';
import '../../../../core/common/widgets/layout/page_header.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/theme/tokens/app_tokens.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/strings_manager.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_invoice_entity.dart';
import '../utils/supplier_pdf_helper.dart';
import '../widgets/supplier_info_header.dart';
import '../widgets/supplier_invoice_item_row.dart';
import '../widgets/supplier_invoice_summary_card.dart';

class AddSupplierInvoicePage extends StatefulWidget {
  final SupplierEntity supplier;

  const AddSupplierInvoicePage({super.key, required this.supplier});

  @override
  State<AddSupplierInvoicePage> createState() => _AddSupplierInvoicePageState();
}

class _AddSupplierInvoicePageState extends State<AddSupplierInvoicePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  double _paidAmount = 0.0;

  final List<Map<String, dynamic>> _itemRows = [
    {
      'nameController': TextEditingController(text: 'حليب المراعي 1 لتر'),
      'qtyController': TextEditingController(text: '20'),
      'priceController': TextEditingController(text: '35'),
    },
  ];

  @override
  void dispose() {
    for (var row in _itemRows) {
      row['nameController']?.dispose();
      row['qtyController']?.dispose();
      row['priceController']?.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _itemRows.add({
        'nameController': TextEditingController(),
        'qtyController': TextEditingController(text: '1'),
        'priceController': TextEditingController(text: '0'),
      });
    });
  }

  void _removeItem(int index) {
    if (_itemRows.length > 1) {
      setState(() {
        final row = _itemRows.removeAt(index);
        row['nameController']?.dispose();
        row['qtyController']?.dispose();
        row['priceController']?.dispose();
      });
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    for (var row in _itemRows) {
      final qty = int.tryParse(row['qtyController']?.text ?? '0') ?? 0;
      final price = double.tryParse(row['priceController']?.text ?? '0') ?? 0.0;
      total += (qty * price);
    }
    return total;
  }

  List<SupplierInvoiceItemEntity> _getItems() {
    return _itemRows.map((row) {
      final name = row['nameController']?.text.trim() ?? '';
      final qty = int.tryParse(row['qtyController']?.text ?? '1') ?? 1;
      final price = double.tryParse(row['priceController']?.text ?? '0') ?? 0.0;
      return SupplierInvoiceItemEntity(
        productName: name.isNotEmpty ? name : StringsManager.commonEmpty.lang,
        quantity: qty,
        unitPrice: price,
      );
    }).toList();
  }

  void _onSaveAndPrint() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      final total = _calculateTotal();
      final paid = double.tryParse(values['paid_amount']?.toString() ?? '0') ?? 0.0;
      final notes = (values['notes'] as String?)?.trim() ?? '';
      final items = _getItems();

      final invoice = SupplierInvoiceEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString().substring(6),
        supplierId: widget.supplier.id,
        supplierName: widget.supplier.name,
        date: DateTime.now(),
        items: items,
        totalAmount: total,
        paidAmount: paid,
        notes: notes,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => SupplierPdfHelper.generateInvoicePdf(
          invoice: invoice,
          supplier: widget.supplier,
        ),
      );

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: Text(StringsManager.suppliersInvoiceSuccess.lang),
          autoCloseDuration: const Duration(seconds: 3),
        );
        Navigator.pop(context, invoice);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _calculateTotal();

    return AppPageWrapper(
      scrollable: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      appBar: PageHeader(
        title: StringsManager.suppliersAddInvoice.lang,
        showBackButton: true,
      ),
      child: AppForm(
        formKey: _formKey,
        initialValue: const {
          'paid_amount': '0',
          'notes': '',
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier Info Header
            SupplierInfoHeader(
              supplier: widget.supplier,
              showDebtBadge: false,
            ),
            16.vSpace,

            // Items List Title + Add Item Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${StringsManager.suppliersPurchasedGoods.lang} (${_itemRows.length})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addNewItem,
                  icon: AppIcon(AppIcons.add, size: 18),
                  label: Text(
                    StringsManager.suppliersAddItem.lang,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            8.vSpace,

            // Item Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _itemRows.length,
              separatorBuilder: (_, __) => 12.vSpace,
              itemBuilder: (context, index) {
                final row = _itemRows[index];
                return SupplierInvoiceItemRow(
                  index: index + 1,
                  nameController: row['nameController'],
                  qtyController: row['qtyController'],
                  priceController: row['priceController'],
                  showDeleteButton: _itemRows.length > 1,
                  onDelete: () => _removeItem(index),
                  onChanged: (_) => setState(() {}),
                );
              },
            ),
            20.vSpace,

            // Summary Card driven by FormBuilder
            SupplierInvoiceSummaryCard(
              totalAmount: total,
              paidAmount: _paidAmount,
              onPaidChanged: (val) {
                setState(() {
                  _paidAmount = double.tryParse(val ?? '0') ?? 0.0;
                });
              },
            ),
            20.vSpace,

            // Save and Print Action Button
            AppButton(
              text: StringsManager.suppliersSaveAndPrint.lang,
              icon: AppIcons.printer,
              onPressed: _onSaveAndPrint,
            ),
          ],
        ),
      ),
    );
  }
}
