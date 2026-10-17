import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/features/business/presentation/cubits/business_cubit.dart';
import 'package:baseet/features/pos/presentation/blocs/cart/cart_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/cart/cart_event.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_bloc.dart';
import 'package:baseet/features/pos/presentation/blocs/catalog/pos_catalog_event.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/customers_list/customers_list_bloc.dart';
import 'package:baseet/features/debt_ledger/presentation/blocs/customers_list/customers_list_event.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_bloc.dart';
import 'package:baseet/features/inventory/presentation/blocs/inventory_list/inventory_list_event.dart';
import 'package:baseet/features/reports/presentation/blocs/reports/reports_bloc.dart';
import 'package:baseet/features/reports/presentation/blocs/reports/reports_event.dart';

void refreshBusiness(BuildContext context, {bool clearCart = false}) {
  if (clearCart) context.read<CartBloc>().add(ClearCartEvent());
  context.read<BusinessCubit>().load();
  context
      .read<PosCatalogBloc>()
      .add(const LoadPosCatalogEvent(categoryId: 'cat_0', searchQuery: ''));
  context
      .read<CustomersListBloc>()
      .add(const LoadCustomersListEvent(searchQuery: ''));
  context
      .read<InventoryListBloc>()
      .add(const LoadInventoryEvent(categoryId: 'cat_0', searchQuery: ''));
  context.read<ReportsBloc>().add(const LoadReportsSummaryEvent());
}
