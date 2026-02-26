import '../../domain/entities/admin_statistics.dart';

class AdminStatisticsModel {
  final int days;
  final double totalRevenue;
  final int totalOrders;
  final int paidOrders;
  final int productsCount;
  final int customersCount;
  final int tablesTotal;
  final int occupiedTables;

  AdminStatisticsModel({
    required this.days,
    required this.totalRevenue,
    required this.totalOrders,
    required this.paidOrders,
    required this.productsCount,
    required this.customersCount,
    required this.tablesTotal,
    required this.occupiedTables,
  });

  factory AdminStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatisticsModel(
      days: json['days'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      paidOrders: json['paidOrders'] as int,
      productsCount: json['productsCount'] as int,
      customersCount: json['customersCount'] as int,
      tablesTotal: json['tablesTotal'] as int,
      occupiedTables: json['occupiedTables'] as int,
    );
  }

  AdminStatistics toEntity() => AdminStatistics(
        days: days,
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        paidOrders: paidOrders,
        productsCount: productsCount,
        customersCount: customersCount,
        tablesTotal: tablesTotal,
        occupiedTables: occupiedTables,
      );
}

class SalesDataModel {
  final String date;
  final double total;

  SalesDataModel({required this.date, required this.total});

  factory SalesDataModel.fromJson(Map<String, dynamic> json) {
    return SalesDataModel(
      date: json['date'],
      total: (json['total'] as num).toDouble(),
    );
  }

  SalesData toEntity() => SalesData(date: date, total: total);
}

class CategorySalesDataModel {
  final String name;
  final double value;

  CategorySalesDataModel({required this.name, required this.value});

  factory CategorySalesDataModel.fromJson(Map<String, dynamic> json) {
    return CategorySalesDataModel(
      name: json['name'],
      value: (json['value'] as num).toDouble(),
    );
  }

  CategorySalesData toEntity() => CategorySalesData(name: name, value: value);
}
