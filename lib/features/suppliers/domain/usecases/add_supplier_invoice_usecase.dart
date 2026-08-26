import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supplier_invoice_entity.dart';
import '../repositories/supplier_repository.dart';

class AddSupplierInvoiceUseCase extends ParamsUseCase<SupplierInvoiceEntity, SupplierInvoiceEntity> {
  final SupplierRepository repository;

  AddSupplierInvoiceUseCase(this.repository);

  @override
  Future<Either<Failure, SupplierInvoiceEntity>> call(SupplierInvoiceEntity params) {
    return repository.addSupplierInvoice(params);
  }
}
