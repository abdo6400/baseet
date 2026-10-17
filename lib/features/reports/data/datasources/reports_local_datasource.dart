import 'package:baseet/core/services/operation_context.dart';
import 'package:baseet/features/reports/domain/entities/report_period.dart';
import 'package:baseet/core/database/app_database.dart';
import 'package:baseet/features/reports/data/models/report_summary_model.dart';
import 'package:baseet/features/reports/domain/entities/report_summary_entity.dart';

abstract class ReportsLocalDataSource {
  Future<ReportSummaryModel> getReportSummary(ReportPeriod period);
}

class ReportsLocalDataSourceImpl implements ReportsLocalDataSource {
  final AppDatabase appDatabase;
  final OperationContext context;

  ReportsLocalDataSourceImpl(
      {required AppDatabase database, required this.context})
      : appDatabase = database;

  @override
  Future<ReportSummaryModel> getReportSummary(ReportPeriod period) async {
    final db = await appDatabase.database;
    final now = context.now();
    final startStr = period.startAt(now).toIso8601String();
    final endStr = period.endBefore(now).toIso8601String();

    // 1. Total Sales & Invoices Count
    final salesResult = await db.rawQuery('''
      SELECT SUM(totalAmount) as totalSales, COUNT(*) as invoiceCount
      FROM orders
      WHERE createdAt >= ? AND createdAt < ?
    ''', [startStr, endStr]);

    // 2. Net Profit calculation
    final profitResult = await db.rawQuery('''
      SELECT SUM((order_items.customPrice - order_items.buyPrice) * order_items.quantity) as profit
      FROM order_items
      INNER JOIN orders ON order_items.orderId = orders.id
      WHERE orders.createdAt >= ? AND orders.createdAt < ?
    ''', [startStr, endStr]);

    // 3. Cash Sales
    final cashResult = await db.rawQuery('''
      SELECT SUM(totalAmount) as cashSales
      FROM orders
      WHERE paymentMethod = 'cash' AND createdAt >= ? AND createdAt < ?
    ''', [startStr, endStr]);

    // 4. Debt Sales
    final debtResult = await db.rawQuery('''
      SELECT SUM(totalAmount) as debtSales
      FROM orders
      WHERE paymentMethod = 'debt' AND createdAt >= ? AND createdAt < ?
    ''', [startStr, endStr]);

    // 5. Top Products
    final topResult = await db.rawQuery('''
      SELECT 
        order_items.productName as productName,
        SUM(order_items.quantity) as soldQuantity,
        SUM(order_items.customPrice * order_items.quantity) as totalRevenue
      FROM order_items
      INNER JOIN orders ON order_items.orderId = orders.id
      WHERE orders.createdAt >= ? AND orders.createdAt < ?
      GROUP BY order_items.productName
      ORDER BY soldQuantity DESC
      LIMIT 6
    ''', [startStr, endStr]);

    final double totalSales =
        (salesResult.isNotEmpty && salesResult.first['totalSales'] != null)
            ? (salesResult.first['totalSales'] as num).toDouble()
            : 0;

    final int invoiceCount =
        (salesResult.isNotEmpty && salesResult.first['invoiceCount'] != null)
            ? (salesResult.first['invoiceCount'] as int)
            : 0;

    final double netProfit =
        (profitResult.isNotEmpty && profitResult.first['profit'] != null)
            ? (profitResult.first['profit'] as num).toDouble()
            : 0;

    final double cashSales =
        (cashResult.isNotEmpty && cashResult.first['cashSales'] != null)
            ? (cashResult.first['cashSales'] as num).toDouble()
            : 0;

    final double debtSales =
        (debtResult.isNotEmpty && debtResult.first['debtSales'] != null)
            ? (debtResult.first['debtSales'] as num).toDouble()
            : 0;

    List<TopProductStat> topProducts = topResult.map((m) {
      return TopProductStatModel.fromMap(m);
    }).toList();

    return ReportSummaryModel(
      totalSales: totalSales,
      netProfit: netProfit,
      cashSales: cashSales,
      debtSales: debtSales,
      totalInvoicesCount: invoiceCount,
      topProducts: topProducts,
    );
  }
}
