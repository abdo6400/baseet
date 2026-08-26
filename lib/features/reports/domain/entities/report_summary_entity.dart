import 'package:equatable/equatable.dart';

class TopProductStat extends Equatable {
  final String productName;
  final int soldQuantity;
  final double totalRevenue;

  const TopProductStat({
    required this.productName,
    required this.soldQuantity,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [productName, soldQuantity, totalRevenue];
}

class ReportSummaryEntity extends Equatable {
  final double totalSales;
  final double netProfit;
  final double cashSales;
  final double debtSales;
  final int totalInvoicesCount;
  final List<TopProductStat> topProducts;

  const ReportSummaryEntity({
    required this.totalSales,
    required this.netProfit,
    required this.cashSales,
    required this.debtSales,
    required this.totalInvoicesCount,
    required this.topProducts,
  });

  @override
  List<Object?> get props => [
        totalSales,
        netProfit,
        cashSales,
        debtSales,
        totalInvoicesCount,
        topProducts,
      ];
}
