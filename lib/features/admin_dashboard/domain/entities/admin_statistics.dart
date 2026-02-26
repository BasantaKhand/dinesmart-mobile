import 'package:equatable/equatable.dart';

class AdminStatistics extends Equatable {
  final int days;
  final double totalRevenue;
  final int totalOrders;
  final int paidOrders;
  final int productsCount;
  final int customersCount;
  final int tablesTotal;
  final int occupiedTables;

  const AdminStatistics({
    required this.days,
    required this.totalRevenue,
    required this.totalOrders,
    required this.paidOrders,
    required this.productsCount,
    required this.customersCount,
    required this.tablesTotal,
    required this.occupiedTables,
  });

  @override
  List<Object?> get props => [
        days,
        totalRevenue,
        totalOrders,
        paidOrders,
        productsCount,
        customersCount,
        tablesTotal,
        occupiedTables,
      ];
}

class SalesData extends Equatable {
  final String date;
  final double total;

  const SalesData({required this.date, required this.total});

  @override
  List<Object?> get props => [date, total];
}

class CategorySalesData extends Equatable {
  final String name;
  final double value;

  const CategorySalesData({required this.name, required this.value});

  @override
  List<Object?> get props => [name, value];
}
