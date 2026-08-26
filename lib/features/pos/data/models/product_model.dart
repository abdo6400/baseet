import 'package:baseet/features/pos/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.barcode,
    required super.categoryId,
    required super.categoryName,
    required super.buyPrice,
    required super.sellPrice,
    required super.stockQuantity,
    super.minStockLimit = 3,
    super.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      barcode: map['barcode'] as String,
      categoryId: map['categoryId'] as String,
      categoryName: map['categoryName'] as String,
      buyPrice: (map['buyPrice'] as num).toDouble(),
      sellPrice: (map['sellPrice'] as num).toDouble(),
      stockQuantity: map['stockQuantity'] as int,
      minStockLimit: (map['minStockLimit'] as int?) ?? 3,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stockQuantity': stockQuantity,
      'minStockLimit': minStockLimit,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      barcode: entity.barcode,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      buyPrice: entity.buyPrice,
      sellPrice: entity.sellPrice,
      stockQuantity: entity.stockQuantity,
      minStockLimit: entity.minStockLimit,
      imageUrl: entity.imageUrl,
    );
  }
}
