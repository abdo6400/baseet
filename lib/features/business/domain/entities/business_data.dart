import 'package:equatable/equatable.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/customer_entity.dart';

class SaleRecord extends Equatable {
  final String id, number, paymentMethod;
  final DateTime date;
  final double total, paid, remaining;
  final String? customer;
  final List<SaleLine> lines;
  const SaleRecord(
      {required this.id,
      required this.number,
      required this.date,
      required this.total,
      required this.paid,
      required this.remaining,
      required this.paymentMethod,
      this.customer,
      this.lines = const []});
  @override
  List<Object?> get props => [
        id,
        number,
        date,
        total,
        paid,
        remaining,
        paymentMethod,
        customer,
        lines
      ];
}

class SaleLine extends Equatable {
  final String name;
  final int quantity;
  final double price;
  const SaleLine(this.name, this.quantity, this.price);
  @override
  List<Object?> get props => [name, quantity, price];
}

class BusinessData extends Equatable {
  final String storeName;
  final double todaySales, totalDebt;
  final int todayInvoices, lowStock;
  final List<ProductEntity> products;
  final List<CustomerEntity> customers;
  final List<SaleRecord> sales;
  const BusinessData(
      {this.storeName = '',
      this.todaySales = 0,
      this.totalDebt = 0,
      this.todayInvoices = 0,
      this.lowStock = 0,
      this.products = const [],
      this.customers = const [],
      this.sales = const []});
  @override
  List<Object?> get props => [
        storeName,
        todaySales,
        totalDebt,
        todayInvoices,
        lowStock,
        products,
        customers,
        sales
      ];
}
