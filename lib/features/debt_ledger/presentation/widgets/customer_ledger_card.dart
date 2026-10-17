import 'package:flutter/material.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';

class CustomerLedgerCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback onTap, onVoucherTap;
  const CustomerLedgerCard(
      {super.key,
      required this.customer,
      required this.onTap,
      required this.onVoucherTap});
  @override
  Widget build(BuildContext context) => Card(
      margin: EdgeInsets.zero,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: onTap,
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(customer.name),
                subtitle: customer.phone.isEmpty ? null : Text(customer.phone),
                trailing: const Icon(Icons.chevron_left)),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    customer.totalDebt == 0
                        ? 'simple.no_debt'.lang
                        : '${'simple.owes'.lang} ${customer.totalDebt.toStringAsFixed(2)} ${'pos_currency'.lang}',
                    style: Theme.of(context).textTheme.titleLarge)),
            Wrap(spacing: 8, children: [
              OutlinedButton(
                  onPressed: onTap, child: Text('simple.account'.lang)),
              FilledButton(
                  onPressed: customer.totalDebt <= 0 ? null : onVoucherTap,
                  child: Text('simple.record_payment'.lang))
            ]),
          ])));
}
