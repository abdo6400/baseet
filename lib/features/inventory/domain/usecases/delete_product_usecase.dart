import 'package:dartz/dartz.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import '../repositories/inventory_repository.dart';

class DeleteProductUseCase extends ParamsUseCase<void, String> {
  final InventoryRepository repository;

  DeleteProductUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteProduct(params);
  }
}
