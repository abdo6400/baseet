import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/pos/domain/entities/product_entity.dart';
import '../repositories/inventory_repository.dart';

class UpdateProductUseCase extends ParamsUseCase<ProductEntity, ProductEntity> {
  final InventoryRepository repository;

  UpdateProductUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(ProductEntity params) {
    return repository.updateProduct(params);
  }
}
