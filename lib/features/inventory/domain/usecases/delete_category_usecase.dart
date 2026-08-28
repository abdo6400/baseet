import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';

class DeleteCategoryParams extends Equatable {
  final String id;

  const DeleteCategoryParams(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteCategoryUseCase extends ParamsUseCase<void, DeleteCategoryParams> {
  final InventoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCategoryParams params) {
    return repository.deleteCategory(params.id);
  }
}
