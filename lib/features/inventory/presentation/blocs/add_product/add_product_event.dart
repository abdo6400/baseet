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
