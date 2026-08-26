import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/supplier_invoice_entity.dart';
import '../repositories/supplier_repository.dart';

class GetSupplierInvoicesUseCase extends ParamsUseCase<List<SupplierInvoiceEntity>, String> {
  final SupplierRepository repository;

  GetSupplierInvoicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SupplierInvoiceEntity>>> call(String supplierId) {
    return repository.getSupplierInvoices(supplierId);
  }
}
