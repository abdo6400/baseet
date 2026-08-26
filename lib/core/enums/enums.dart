enum PaymentMethod {
  cash,
  debt,
  card;

  String get key {
    switch (this) {
      case PaymentMethod.cash:
        return 'checkout_cash';
      case PaymentMethod.debt:
        return 'checkout_debt';
      case PaymentMethod.card:
        return 'checkout_card';
    }
  }
}

enum DebtStatus {
  regular,
  overdue,
  limitExceeded;

  String get key {
    switch (this) {
      case DebtStatus.regular:
        return 'debts_status_regular';
      case DebtStatus.overdue:
        return 'debts_status_overdue';
      case DebtStatus.limitExceeded:
        return 'debts_status_limit_exceeded';
    }
  }
}

enum TransactionType {
  saleCredit,
  paymentVoucher;

  String get key {
    switch (this) {
      case TransactionType.saleCredit:
        return 'customer_type_sale';
      case TransactionType.paymentVoucher:
        return 'customer_type_payment';
    }
  }
}

enum FieldType {
  text,
  number,
  phone,
  dropdown,
  search,
  date,
}
