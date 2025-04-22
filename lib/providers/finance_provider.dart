import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/financial_model.dart';
import '../services/storage_service.dart';

class FinanceProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<FinancialRecordModel> _financialRecords = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedFarmId = '';

  // Getters
  List<FinancialRecordModel> get financialRecords => _financialRecords;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedFarmId => _selectedFarmId;

  // Constructor loads financial records from storage
  FinanceProvider() {
    loadFinancialRecords();
  }

  // Filter records by farm
  List<FinancialRecordModel> getRecordsForFarm(String farmId) {
    return _financialRecords.where((record) => record.farmId == farmId).toList();
  }

  // Set selected farm ID
  void setSelectedFarm(String farmId) {
    _selectedFarmId = farmId;
    notifyListeners();
  }

  // Load financial records from storage
  Future<void> loadFinancialRecords() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _financialRecords = await _storageService.getFinancialRecords();
    } catch (e) {
      _errorMessage = 'Failed to load financial records: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new financial record
  Future<void> addFinancialRecord(FinancialRecordModel record) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _financialRecords.add(record);
      await _storageService.saveFinancialRecords(_financialRecords);
    } catch (e) {
      _errorMessage = 'Failed to add financial record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing financial record
  Future<void> updateFinancialRecord(FinancialRecordModel updatedRecord) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final index = _financialRecords.indexWhere(
        (record) => record.id == updatedRecord.id,
      );
      if (index != -1) {
        _financialRecords[index] = updatedRecord;
        await _storageService.saveFinancialRecords(_financialRecords);
      } else {
        _errorMessage = 'Record not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to update financial record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a financial record
  Future<void> deleteFinancialRecord(String recordId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _financialRecords.removeWhere((record) => record.id == recordId);
      await _storageService.saveFinancialRecords(_financialRecords);
    } catch (e) {
      _errorMessage = 'Failed to delete financial record: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get financial summary for a farm
  FinancialSummaryModel getFinancialSummary(String farmId) {
    final farmRecords = getRecordsForFarm(farmId);
    
    // Calculate totals
    double totalIncome = 0;
    double totalExpenses = 0;
    
    // Category breakdowns
    Map<String, double> expensesByCategory = {};
    Map<String, double> incomeByCategory = {};
    
    // Process records
    for (var record in farmRecords) {
      if (record.type == TransactionType.income) {
        totalIncome += record.amount;
        incomeByCategory[record.category] = 
            (incomeByCategory[record.category] ?? 0) + record.amount;
      } else {
        totalExpenses += record.amount;
        expensesByCategory[record.category] = 
            (expensesByCategory[record.category] ?? 0) + record.amount;
      }
    }
    
    // Sort records by date to get recent transactions
    farmRecords.sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = farmRecords.take(5).toList();
    
    return FinancialSummaryModel(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netProfit: totalIncome - totalExpenses,
      expensesByCategory: expensesByCategory,
      incomeByCategory: incomeByCategory,
      recentTransactions: recentTransactions,
    );
  }

  // Generate financial projection
  FinancialProjectionModel generateProjection({
    required String farmId,
    required double estimatedYield,
    required double estimatedPricePerKg,
    required double areaHectares,
  }) {
    final summary = getFinancialSummary(farmId);
    
    return summary.generateProjection(
      estimatedYield: estimatedYield,
      estimatedPricePerKg: estimatedPricePerKg,
      areaHectares: areaHectares,
    );
  }

  // Generate a unique ID
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        Random().nextInt(10000).toString();
  }

  // Get formatted amount with PHP symbol
  String getFormattedAmount(double amount) {
    return 'u20b1${amount.toStringAsFixed(2)}';
  }

  // Get records by month
  List<FinancialRecordModel> getRecordsByMonth(String farmId, DateTime month) {
    final farmRecords = getRecordsForFarm(farmId);
    return farmRecords.where((record) => 
        record.date.year == month.year && 
        record.date.month == month.month
    ).toList();
  }

  // Get monthly summary
  Map<String, double> getMonthlySummary(
    String farmId, 
    DateTime startMonth, 
    DateTime endMonth
  ) {
    final Map<String, double> monthlySummary = {};
    
    // Create a copy of the start date
    var currentMonth = DateTime(startMonth.year, startMonth.month);
    
    // Iterate through months
    while (currentMonth.isBefore(endMonth) || 
           (currentMonth.year == endMonth.year && currentMonth.month == endMonth.month)) {
      
      // Get records for this month
      final monthRecords = getRecordsByMonth(farmId, currentMonth);
      
      // Calculate profit for this month
      double income = 0;
      double expenses = 0;
      
      for (var record in monthRecords) {
        if (record.type == TransactionType.income) {
          income += record.amount;
        } else {
          expenses += record.amount;
        }
      }
      
      // Add to summary
      final monthKey = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
      monthlySummary[monthKey] = income - expenses;
      
      // Move to next month
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }
    
    return monthlySummary;
  }
}