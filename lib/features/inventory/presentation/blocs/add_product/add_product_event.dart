import 'package:equatable/equatable.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAddProductEvent extends AddProductEvent {
  final ProductEntity product;

  const SubmitAddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class SubmitUpdateProductEvent extends AddProductEvent {
  final ProductEntity product;

  const SubmitUpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class SubmitDeleteProductEvent extends AddProductEvent {
  final String productId;

  const SubmitDeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
