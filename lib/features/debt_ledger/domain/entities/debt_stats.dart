import 'package:equatable/equatable.dart';

class DebtStats extends Equatable {
  final double total;
  final double overdue;
  final double todayCollections;
  const DebtStats(
      {required this.total,
      required this.overdue,
      required this.todayCollections});
  @override
  List<Object?> get props => [total, overdue, todayCollections];
}
