import 'package:baseet/features/reports/domain/entities/report_summary_entity.dart';

class TopProductStatModel extends TopProductStat {
  const TopProductStatModel({
    required super.productName,
    required super.soldQuantity,
    required super.totalRevenue,
  });

  factory TopProductStatModel.fromMap(Map<String, dynamic> map) {
    return TopProductStatModel(
      productName: map['productName'] as String,
      soldQuantity: (map['soldQuantity'] as num).toInt(),
      totalRevenue: (map['totalRevenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'soldQuantity': soldQuantity,
      'totalRevenue': totalRevenue,
    };
  }
}

class ReportSummaryModel extends ReportSummaryEntity {
  const ReportSummaryModel({
    required super.totalSales,
    required super.netProfit,
    required super.cashSales,
    required super.debtSales,
    required super.totalInvoicesCount,
    required super.topProducts,
  });

  factory ReportSummaryModel.fromEntity(ReportSummaryEntity entity) {
    return ReportSummaryModel(
      totalSales: entity.totalSales,
      netProfit: entity.netProfit,
      cashSales: entity.cashSales,
      debtSales: entity.debtSales,
      totalInvoicesCount: entity.totalInvoicesCount,
      topProducts: entity.topProducts,
    );
  }
}
