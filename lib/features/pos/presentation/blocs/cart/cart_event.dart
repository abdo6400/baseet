import 'package:equatable/equatable.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddProductToCartEvent extends CartEvent {
  final ProductEntity product;
  final int quantity;

  const AddProductToCartEvent(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveProductFromCartEvent extends CartEvent {
  final String productId;

  const RemoveProductFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateItemQuantityEvent extends CartEvent {
  final String productId;
  final int newQuantity;

  const UpdateItemQuantityEvent(this.productId, this.newQuantity);

  @override
  List<Object?> get props => [productId, newQuantity];
}

class ClearCartEvent extends CartEvent {}
