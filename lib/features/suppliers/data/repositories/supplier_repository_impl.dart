import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/entities/supplier_invoice_entity.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../datasources/supplier_local_datasource.dart';
import '../models/supplier_model.dart';
import '../models/supplier_invoice_model.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSource localDataSource;

  SupplierRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({String? searchQuery}) {
    return Failure.handleCall(() => localDataSource.getSuppliers(searchQuery: searchQuery));
  }

  @override
  Future<Either<Failure, SupplierEntity>> getSupplierById(String id) {
    return Failure.handleCall(() => localDataSource.getSupplierById(id));
  }

  @override
  Future<Either<Failure, SupplierEntity>> addSupplier(SupplierEntity supplier) {
    return Failure.handleCall(() => localDataSource.addSupplier(SupplierModel.fromEntity(supplier)));
  }

  @override
  Future<Either<Failure, void>> deleteSupplier(String id) {
    return Failure.handleCall(() => localDataSource.deleteSupplier(id));
  }

  @override
  Future<Either<Failure, List<SupplierInvoiceEntity>>> getSupplierInvoices(String supplierId) {
    return Failure.handleCall(() => localDataSource.getSupplierInvoices(supplierId));
  }

  @override
  Future<Either<Failure, SupplierInvoiceEntity>> addSupplierInvoice(SupplierInvoiceEntity invoice) {
    return Failure.handleCall(() => localDataSource.addSupplierInvoice(SupplierInvoiceModel.fromEntity(invoice)));
  }

  @override
  Future<Either<Failure, double>> getTotalSupplierDebt() {
    return Failure.handleCall(() => localDataSource.getTotalSupplierDebt());
  }
}
