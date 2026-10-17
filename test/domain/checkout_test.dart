import 'package:baseet/core/enums/enums.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/services/operation_context.dart';
import 'package:baseet/features/catalog/domain/entities/product_entity.dart';
import 'package:baseet/features/debt_ledger/domain/entities/debt_policy.dart';
import 'package:baseet/features/pos/domain/entities/cart_item_entity.dart';
import 'package:baseet/features/pos/domain/entities/order_entity.dart';
import 'package:baseet/features/pos/domain/repositories/pos_repository.dart';
import 'package:baseet/features/pos/domain/usecases/process_checkout_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FixedContext implements OperationContext {
  @override
  DateTime now() => DateTime(2026, 10, 17, 12);
  @override
  String newId(String prefix) => '${prefix}_test';
}

class RecordingPosRepository implements PosRepository {
  OrderEntity? saved;
  @override
  Future<Either<Failure, OrderEntity>> checkout(OrderEntity order) async {
    saved = order;
    return Right(order);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getCatalog(
          {String? categoryId, String? searchQuery}) async =>
      const Right([]);
  @override
  Future<Either<Failure, double>> getTodaySalesTotal() async => const Right(0);
}

const product = ProductEntity(
    id: 'p1',
    name: 'Milk',
    barcode: '123',
    categoryId: 'c1',
    categoryName: 'Food',
    buyPrice: 3,
    sellPrice: 10,
    stockQuantity: 5);

void main() {
  late RecordingPosRepository repository;
  late ProcessCheckoutUseCase checkout;
  setUp(() {
    repository = RecordingPosRepository();
    checkout = ProcessCheckoutUseCase(repository, FixedContext());
  });

  test(
      'builds invoice from line prices and partial payment with injected ID/time',
      () async {
    final result = await checkout(ProcessCheckoutParams(
        items: [CartItemEntity(product: product, quantity: 2, customPrice: 8)],
        paymentMethod: PaymentMethod.debt,
        paidAmount: 6,
        customerId: 'customer'));
    expect(result.isRight(), isTrue);
    final order = repository.saved!;
    expect(order.totalAmount, 16);
    expect(order.remainingAmount, 10);
    expect(order.id, 'INV_test');
    expect(order.createdAt, DateTime(2026, 10, 17, 12));
  });

  test('cash checkout clears credit customer details', () async {
    await checkout(ProcessCheckoutParams(
        items: [CartItemEntity(product: product)],
        paymentMethod: PaymentMethod.cash,
        customerId: 'stale'));
    expect(repository.saved!.customerId, isNull);
    expect(repository.saved!.paidAmount, 10);
    expect(repository.saved!.remainingAmount, 0);
  });

  test('invalid carts and payment inputs never reach persistence', () async {
    final cases = [
      const ProcessCheckoutParams(items: [], paymentMethod: PaymentMethod.cash),
      ProcessCheckoutParams(
          items: [CartItemEntity(product: product, quantity: 0)],
          paymentMethod: PaymentMethod.cash),
      ProcessCheckoutParams(
          items: [CartItemEntity(product: product, customPrice: double.nan)],
          paymentMethod: PaymentMethod.cash),
      ProcessCheckoutParams(
          items: [CartItemEntity(product: product)],
          paymentMethod: PaymentMethod.debt),
      ProcessCheckoutParams(
          items: [CartItemEntity(product: product)],
          paymentMethod: PaymentMethod.debt,
          customerId: 'c',
          paidAmount: 11),
      ProcessCheckoutParams(
          items: [CartItemEntity(product: product)],
          paymentMethod: PaymentMethod.debt,
          customerId: 'c',
          paidAmount: -1),
    ];
    for (final params in cases) {
      expect((await checkout(params)).isLeft(), isTrue);
      expect(repository.saved, isNull);
    }
  });

  test(
      'debt policy rejects overpayment, nonfinite values, and credit limit overflow',
      () {
    expect(DebtPolicy.receivePayment(100, 101).isLeft(), isTrue);
    expect(DebtPolicy.receivePayment(100, double.nan).isLeft(), isTrue);
    expect(DebtPolicy.receivePayment(100, -1).isLeft(), isTrue);
    expect(
        DebtPolicy.receivePayment(100, 100), const Right<Failure, double>(0));
    expect(DebtPolicy.addCredit(90, 11, 100).isLeft(), isTrue);
    expect(
        DebtPolicy.addCredit(90, 10, 100), const Right<Failure, double>(100));
  });
}
