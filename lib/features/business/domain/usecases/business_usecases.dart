import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import '../entities/business_data.dart';
import '../repositories/business_repository.dart';

class LoadBusinessUseCase extends NoParamsUseCase<BusinessData> {
  final BusinessRepository repository;
  LoadBusinessUseCase(this.repository);
  @override
  Future<Either<Failure, BusinessData>> call() => repository.load();
}

class SaveProductParams extends Equatable {
  final ProductEntity product;
  const SaveProductParams(this.product);
  @override
  List<Object?> get props => [product];
}

class SaveProductUseCase extends ParamsUseCase<void, SaveProductParams> {
  final BusinessRepository repository;
  SaveProductUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(SaveProductParams params) async {
    final p = params.product;
    if (p.name.trim().isEmpty ||
        !p.sellPrice.isFinite ||
        p.sellPrice < 0 ||
        !p.buyPrice.isFinite ||
        p.buyPrice < 0 ||
        p.stockQuantity < 0) {
      return const Left(
          ValidationFailure(message: 'validation.invalid_product'));
    }
    return repository.saveProduct(p);
  }
}

class StoreNameParams extends Equatable {
  final String name;
  const StoreNameParams(this.name);
  @override
  List<Object?> get props => [name];
}

class SaveStoreUseCase extends ParamsUseCase<void, StoreNameParams> {
  final BusinessRepository repository;
  SaveStoreUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(StoreNameParams params) async {
    if (params.name.trim().isEmpty || params.name.length > 100) {
      return const Left(ValidationFailure(message: 'simple.store_required'));
    }
    return repository.saveStore(params.name.trim());
  }
}
