import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final double customPrice;

  CartItemEntity({
    required this.product,
    this.quantity = 1,
    double? customPrice,
  }) : customPrice = customPrice ?? product.sellPrice;

  double get subtotal => customPrice * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    double? customPrice,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
    );
  }

  @override
  List<Object?> get props => [product, quantity, customPrice];
}
