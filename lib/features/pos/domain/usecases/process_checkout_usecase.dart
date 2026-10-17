import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/core/services/operation_context.dart';
import 'package:baseet/core/usecase/usecase.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';

class ProcessCheckoutParams extends Equatable {
  final List<CartItemEntity> items;
  final PaymentMethod paymentMethod;
  final double paidAmount;
  final String? customerId, customerName, notes, receiptPath;
  const ProcessCheckoutParams(
      {required this.items,
      required this.paymentMethod,
      this.paidAmount = 0,
      this.customerId,
      this.customerName,
      this.notes,
      this.receiptPath});
  @override
  List<Object?> get props => [
        items,
        paymentMethod,
        paidAmount,
        customerId,
        customerName,
        notes,
        receiptPath
      ];
}

class ProcessCheckoutUseCase
    extends ParamsUseCase<OrderEntity, ProcessCheckoutParams> {
  final PosRepository repository;
  final OperationContext context;
  ProcessCheckoutUseCase(this.repository, this.context);

  @override
  Future<Either<Failure, OrderEntity>> call(
      ProcessCheckoutParams params) async {
    if (params.items.isEmpty ||
        params.items.any((item) =>
            item.quantity <= 0 ||
            !item.customPrice.isFinite ||
            item.customPrice < 0)) {
      return const Left(ValidationFailure(message: 'validation.invalid_cart'));
    }
    final total =
        params.items.fold<double>(0, (sum, item) => sum + item.subtotal);
    if (!total.isFinite ||
        !params.paidAmount.isFinite ||
        params.paidAmount < 0 ||
        (params.paymentMethod == PaymentMethod.debt &&
            params.paidAmount > total)) {
      return const Left(
          ValidationFailure(message: 'validation.invalid_amount'));
    }
    final debt = params.paymentMethod == PaymentMethod.debt;
    if (debt && (params.customerId == null || params.customerId!.isEmpty)) {
      return const Left(
          ValidationFailure(message: 'validation.customer_required'));
    }
    final invoice = context.newId('INV');
    return repository.checkout(OrderEntity(
        id: invoice,
        invoiceNumber: invoice,
        items: List.unmodifiable(params.items),
        totalAmount: total,
        paidAmount: debt ? params.paidAmount : total,
        remainingAmount: debt ? total - params.paidAmount : 0,
        paymentMethod: params.paymentMethod,
        customerId: debt ? params.customerId : null,
        customerName: debt ? params.customerName : null,
        createdAt: context.now(),
        notes: params.notes,
        receiptPath: params.receiptPath));
  }
}
