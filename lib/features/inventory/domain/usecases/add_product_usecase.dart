import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';

class AddProductParams extends Equatable {
  final ProductEntity product;

  const AddProductParams(this.product);

  @override
  List<Object?> get props => [product];
}

class AddProductUseCase extends ParamsUseCase<ProductEntity, AddProductParams> {
  final InventoryRepository repository;

  AddProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(AddProductParams params) {
    return repository.addProduct(params.product);
  }
}
