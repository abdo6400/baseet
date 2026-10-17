import 'package:baseet/core/services/operation_context.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';

class AddProductParams extends Equatable {
  final ProductEntity product;

  const AddProductParams(this.product);

  @override
  List<Object?> get props => [product];
}

class AddProductUseCase extends ParamsUseCase<ProductEntity, AddProductParams> {
  final InventoryRepository repository;

  final OperationContext context;
  AddProductUseCase(this.repository, this.context);

  @override
  Future<Either<Failure, ProductEntity>> call(AddProductParams params) {
    final product = params.product.copyWith(
        id: context.newId('prod'),
        barcode: params.product.barcode.trim().isEmpty
            ? context.newId('622')
            : params.product.barcode);
    if (product.name.trim().isEmpty ||
        product.barcode.isEmpty ||
        !product.buyPrice.isFinite ||
        !product.sellPrice.isFinite ||
        product.buyPrice < 0 ||
        product.sellPrice < 0 ||
        product.stockQuantity < 0 ||
        product.minStockLimit < 0) {
      return Future.value(
          const Left(ValidationFailure(message: 'validation.invalid_product')));
    }
    return repository.addProduct(product);
  }
}
