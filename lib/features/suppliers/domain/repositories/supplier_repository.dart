import 'package:dartz/dartz.dart';
import '../../../../config/database/error/failures.dart';
import '../entities/supplier_entity.dart';
import '../entities/supplier_invoice_entity.dart';

abstract class SupplierRepository {
  Future<Either<Failure, List<SupplierEntity>>> getSuppliers({String? searchQuery});
  Future<Either<Failure, SupplierEntity>> getSupplierById(String id);
  Future<Either<Failure, SupplierEntity>> addSupplier(SupplierEntity supplier);
  Future<Either<Failure, List<SupplierInvoiceEntity>>> getSupplierInvoices(String supplierId);
  Future<Either<Failure, SupplierInvoiceEntity>> addSupplierInvoice(SupplierInvoiceEntity invoice);
  Future<Either<Failure, double>> getTotalSupplierDebt();
}
