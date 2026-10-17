import 'package:baseet/core/services/operation_context.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/catalog/domain/entities/category_entity.dart';
import 'package:baseet/features/inventory/domain/repositories/inventory_repository.dart';

class AddCategoryParams extends Equatable {
  final CategoryEntity category;

  const AddCategoryParams(this.category);

  @override
  List<Object?> get props => [category];
}

class AddCategoryUseCase
    extends ParamsUseCase<CategoryEntity, AddCategoryParams> {
  final InventoryRepository repository;

  final OperationContext context;
  AddCategoryUseCase(this.repository, this.context);

  @override
  Future<Either<Failure, CategoryEntity>> call(AddCategoryParams params) {
    final category = params.category;
    if (category.name.trim().isEmpty) {
      return Future.value(const Left(
          ValidationFailure(message: 'validation.invalid_category')));
    }
    return repository.addCategory(CategoryEntity(
        id: context.newId('cat'),
        name: category.name.trim(),
        iconName: category.iconName,
        colorHex: category.colorHex));
  }
}
