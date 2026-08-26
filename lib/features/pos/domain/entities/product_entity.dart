import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final String categoryId;
  final String categoryName;
  final double buyPrice;
  final double sellPrice;
  final int stockQuantity;
  final int minStockLimit;
  final String? imageUrl;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.barcode,
    required this.categoryId,
    required this.categoryName,
    required this.buyPrice,
    required this.sellPrice,
    required this.stockQuantity,
    this.minStockLimit = 5,
    this.imageUrl,
  });

  bool get isLowStock => stockQuantity <= minStockLimit;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? barcode,
    String? categoryId,
    String? categoryName,
    double? buyPrice,
    double? sellPrice,
    int? stockQuantity,
    int? minStockLimit,
    String? imageUrl,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLimit: minStockLimit ?? this.minStockLimit,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        barcode,
        categoryId,
        categoryName,
        buyPrice,
        sellPrice,
        stockQuantity,
        minStockLimit,
        imageUrl,
      ];
}
