import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/config/database/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/inventory/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';

class AddCategoryParams extends Equatable {
  final CategoryEntity category;

  const AddCategoryParams(this.category);

  @override
  List<Object?> get props => [category];
}

class AddCategoryUseCase extends ParamsUseCase<CategoryEntity, AddCategoryParams> {
  final InventoryRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(AddCategoryParams params) {
    return repository.addCategory(params.category);
  }
}
