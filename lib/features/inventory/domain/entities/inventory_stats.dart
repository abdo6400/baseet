import 'package:equatable/equatable.dart';

class InventoryStats extends Equatable {
  final int totalProducts;
  final int lowStockCount;
  final double stockValue;
  const InventoryStats(
      {required this.totalProducts,
      required this.lowStockCount,
      required this.stockValue});
  @override
  List<Object?> get props => [totalProducts, lowStockCount, stockValue];
}
