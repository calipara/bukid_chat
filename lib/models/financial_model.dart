import 'dart:convert';

class FinancialRecordModel {
  final String id;
  final String farmId;
  final String fieldId; // Optional, can be empty if applies to entire farm
  final double amount;
  final String activityType; // From AppConstants.activityTypes
  final String description;
  final DateTime date;
  final TransactionType type; // Income or Expense
  final String category;
  final String paymentMethod; // Cash, Bank, etc.

  FinancialRecordModel({
    required this.id,
    required this.farmId,
    required this.fieldId,
    required this.amount,
    required this.activityType,
    required this.description,
    required this.date,
    required this.type,
    required this.category,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'fieldId': fieldId,
      'amount': amount,
      'activityType': activityType,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category,
      'paymentMethod': paymentMethod,
    };
  }

  factory FinancialRecordModel.fromJson(Map<String, dynamic> json) {
    return FinancialRecordModel(
      id: json['id'],
      farmId: json['farmId'],
      fieldId: json['fieldId'],
      amount: json['amount'].toDouble(),
      activityType: json['activityType'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: _parseTransactionType(json['type']),
      category: json['category'],
      paymentMethod: json['paymentMethod'],
    );
  }

  static TransactionType _parseTransactionType(String typeString) {
    return typeString == 'income' ? TransactionType.income : TransactionType.expense;
  }

  static String toJsonList(List<FinancialRecordModel> records) {
    final jsonList = records.map((record) => record.toJson()).toList();
    return json.encode(jsonList);
  }

  static List<FinancialRecordModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => FinancialRecordModel.fromJson(json)).toList();
  }
}

class FinancialSummaryModel {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final List<FinancialRecordModel> recentTransactions;

  FinancialSummaryModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.recentTransactions,
  });

  // Generate a financial projection based on current data
  FinancialProjectionModel generateProjection({
    required double estimatedYield,
    required double estimatedPricePerKg,
    required double areaHectares,
  }) {
    // Basic estimation for corn/rice farming in Philippines
    const kgPerHectare = 5000.0; // Average yield of palay/corn in kg per hectare
    
    double projectedYield = estimatedYield * areaHectares; // in kg
    double projectedRevenue = projectedYield * estimatedPricePerKg;
    
    // Assume similar expense pattern as current data
    double projectedExpenses = (totalExpenses / areaHectares) * areaHectares;
    
    return FinancialProjectionModel(
      projectedYield: projectedYield,
      projectedRevenue: projectedRevenue,
      projectedExpenses: projectedExpenses,
      projectedProfit: projectedRevenue - projectedExpenses,
      returnOnInvestment: (projectedRevenue - projectedExpenses) / projectedExpenses * 100,
    );
  }
}

class FinancialProjectionModel {
  final double projectedYield; // in kg
  final double projectedRevenue;
  final double projectedExpenses;
  final double projectedProfit;
  final double returnOnInvestment; // ROI as percentage

  FinancialProjectionModel({
    required this.projectedYield,
    required this.projectedRevenue,
    required this.projectedExpenses,
    required this.projectedProfit,
    required this.returnOnInvestment,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectedYield': projectedYield,
      'projectedRevenue': projectedRevenue,
      'projectedExpenses': projectedExpenses,
      'projectedProfit': projectedProfit,
      'returnOnInvestment': returnOnInvestment,
    };
  }

  factory FinancialProjectionModel.fromJson(Map<String, dynamic> json) {
    return FinancialProjectionModel(
      projectedYield: json['projectedYield'].toDouble(),
      projectedRevenue: json['projectedRevenue'].toDouble(),
      projectedExpenses: json['projectedExpenses'].toDouble(),
      projectedProfit: json['projectedProfit'].toDouble(),
      returnOnInvestment: json['returnOnInvestment'].toDouble(),
    );
  }
}

enum TransactionType {
  income,
  expense,
}

// Categories for financial records
class FinancialCategories {
  static const List<String> expense = [
    'Seeds',
    'Fertilizer',
    'Pesticides',
    'Labor',
    'Equipment',
    'Fuel',
    'Irrigation',
    'Land Rental',
    'Transportation',
    'Storage',
    'Marketing',
    'Other',
  ];

  static const List<String> income = [
    'Crop Sales',
    'Government Subsidy',
    'Other Income',
  ];

  static const List<String> paymentMethods = [
    'Cash',
    'Bank Transfer',
    'Mobile Wallet',
    'Credit',
    'Barter',
  ];
}