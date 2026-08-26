import 'package:equatable/equatable.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

enum AddProductStatus { initial, submitting, success, error }

class AddProductState extends Equatable {
  final AddProductStatus status;
  final ProductEntity? createdProduct;
  final String? errorMessage;

  const AddProductState({
    this.status = AddProductStatus.initial,
    this.createdProduct,
    this.errorMessage,
  });

  AddProductState copyWith({
    AddProductStatus? status,
    ProductEntity? createdProduct,
    String? errorMessage,
  }) {
    return AddProductState(
      status: status ?? this.status,
      createdProduct: createdProduct ?? this.createdProduct,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, createdProduct, errorMessage];
}
