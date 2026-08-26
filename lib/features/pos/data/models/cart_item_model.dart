import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'product_model.dart';

class CartItemModel extends CartItemEntity {
  CartItemModel({
    required super.product,
    super.quantity = 1,
    super.customPrice,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map, ProductModel product) {
    return CartItemModel(
      product: product,
      quantity: map['quantity'] as int,
      customPrice: (map['customPrice'] as num?)?.toDouble() ?? product.sellPrice,
    );
  }

  Map<String, dynamic> toMap(String orderId) {
    return {
      'id': '${orderId}_${product.id}',
      'orderId': orderId,
      'productId': product.id,
      'productName': product.name,
      'categoryName': product.categoryName,
      'buyPrice': product.buyPrice,
      'sellPrice': product.sellPrice,
      'quantity': quantity,
      'customPrice': customPrice,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      product: entity.product,
      quantity: entity.quantity,
      customPrice: entity.customPrice,
    );
  }
}
