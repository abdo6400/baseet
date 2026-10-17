class BackupSnapshot {
  final String contents;
  final DateTime createdAt;
  final int products, customers, invoices;
  const BackupSnapshot(
      {required this.contents,
      required this.createdAt,
      required this.products,
      required this.customers,
      required this.invoices});
}

class TransferSession {
  final String code;
  final DateTime expiresAt;
  const TransferSession(this.code, this.expiresAt);
}
