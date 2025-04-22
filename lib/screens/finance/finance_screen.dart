import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../home/home_screen.dart';
import '../../models/farm_model.dart';

import '../../models/financial_model.dart';
import '../../providers/finance_provider.dart';
import '../../providers/farm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatter_utils.dart';
import '../../utils/date_utils.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();
  bool _showProjection = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load financial records when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FinanceProvider>(context, listen: false).loadFinancialRecords();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTransactionDialog() {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
    
    if (farmProvider.farms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a farm first')),
      );
      return;
    }
    
    // Form fields
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController(
      text: DateTimeUtils.formatDate(DateTime.now()),
    );
    
    String farmId = farmProvider.selectedFarm?.id ?? farmProvider.farms.first.id;
    String fieldId = '';
    String activityType = AppConstants.activityTypes.first;
    String category = FinancialCategories.expense.first;
    String paymentMethod = FinancialCategories.paymentMethods.first;
    TransactionType transactionType = TransactionType.expense;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final farmFields = farmProvider.farms
              .firstWhere((farm) => farm.id == farmId)
              .fields;
              
          return AlertDialog(
            title: const Text('Dagdag Record ng Pera'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction type
                  const Text(
                    'Uri ng Transaksyon',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              transactionType = TransactionType.expense;
                              category = FinancialCategories.expense.first;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: transactionType == TransactionType.expense
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: transactionType == TransactionType.expense
                                    ? Colors.red
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: transactionType == TransactionType.expense
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                const Text('Gastos'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              transactionType = TransactionType.income;
                              category = FinancialCategories.income.first;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: transactionType == TransactionType.income
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: transactionType == TransactionType.income
                                    ? Colors.green
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: transactionType == TransactionType.income
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                const Text('Kita'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount (PHP)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          dateController.text = DateTimeUtils.formatDate(pickedDate);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // Farm
                  DropdownButtonFormField<String>(
                    value: farmId,
                    decoration: const InputDecoration(
                      labelText: 'Farm',
                      prefixIcon: Icon(Icons.landscape),
                    ),
                    items: farmProvider.farms.map((farm) {
                      return DropdownMenuItem<String>(
                        value: farm.id,
                        child: Text(farm.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        farmId = value!;
                        fieldId = ''; // Reset field when farm changes
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Field (optional)
                  DropdownButtonFormField<String>(
                    value: fieldId.isEmpty ? null : fieldId,
                    decoration: const InputDecoration(
                      labelText: 'Field (Optional)',
                      prefixIcon: Icon(Icons.crop_square),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('Entire Farm'),
                      ),
                      ...farmFields.map((field) {
                        return DropdownMenuItem<String>(
                          value: field.id,
                          child: Text(field.name),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        fieldId = value ?? '';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Activity Type
                  DropdownButtonFormField<String>(
                    value: activityType,
                    decoration: const InputDecoration(
                      labelText: 'Activity Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: AppConstants.activityTypes.map((activity) {
                      return DropdownMenuItem<String>(
                        value: activity,
                        child: Text(activity),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        activityType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Category
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.folder),
                    ),
                    items: (transactionType == TransactionType.expense
                            ? FinancialCategories.expense
                            : FinancialCategories.income)
                        .map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Method
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment),
                    ),
                    items: FinancialCategories.paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        paymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate inputs
                  if (amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter an amount')),
                    );
                    return;
                  }
                  
                  try {
                    final amount = double.parse(amountController.text);
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Amount must be greater than 0')),
                      );
                      return;
                    }
                    
                    // Create financial record
                    final record = FinancialRecordModel(
                      id: financeProvider.generateId(),
                      farmId: farmId,
                      fieldId: fieldId,
                      amount: amount,
                      activityType: activityType,
                      description: descriptionController.text,
                      date: DateTime.parse(dateController.text),
                      type: transactionType,
                      category: category,
                      paymentMethod: paymentMethod,
                    );
                    
                    // Add record
                    financeProvider.addFinancialRecord(record);
                    
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid number for amount')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleProjection() {
    setState(() {
      _showProjection = !_showProjection;
    });
  }

  void _selectMonth() async {
    final currentMonth = DateTime(_selectedMonth.year, _selectedMonth.month);
    
    final result = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (result != null) {
      setState(() {
        _selectedMonth = DateTime(result.year, result.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pamamahala ng Pera'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buod'),
            Tab(text: 'Mga Transaksyon'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: Consumer2<FinanceProvider, FarmProvider>(
        builder: (context, financeProvider, farmProvider, child) {
          if (financeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there are farms and records
          final hasFarms = farmProvider.hasFarms;
          final selectedFarm = farmProvider.selectedFarm;
          final farmId = selectedFarm?.id ?? '';
          
          // Set selected farm in finance provider if needed
          if (hasFarms && selectedFarm != null && financeProvider.selectedFarmId != farmId) {
            financeProvider.setSelectedFarm(farmId);
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSummaryTab(financeProvider, farmProvider),
              _buildTransactionsTab(financeProvider, farmProvider),
              _buildAnalyticsTab(financeProvider, farmProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Dagdag Transaksyon'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSummaryTab(FinanceProvider financeProvider, FarmProvider farmProvider) {
    if (!farmProvider.hasFarms) {
      return _buildNoFarmMessage();
    }

    final farmId = farmProvider.selectedFarm!.id;
    final summary = financeProvider.getFinancialSummary(farmId);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm selector
          _buildFarmSelector(farmProvider),
          const SizedBox(height: 24),
          
          // Financial summary cards
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buod ng Pera',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem(
                        'Kita',
                        FormatterUtils.formatCurrency(summary.totalIncome),
                        Icons.arrow_upward,
                        Colors.white,
                      ),
                      _buildSummaryItem(
                        'Gastos',
                        FormatterUtils.formatCurrency(summary.totalExpenses),
                        Icons.arrow_downward,
                        Colors.white,
                      ),
                      _buildSummaryItem(
                        'Kabuuang Kita',
                        FormatterUtils.formatCurrency(summary.netProfit),
                        Icons.account_balance,
                        Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  Text(
                    summary.netProfit >= 0
                        ? 'You are currently profitable! 🎉'
                        : 'You are currently running at a loss.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Recent transactions
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _tabController.animateTo(1); // Switch to Transactions tab
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (summary.recentTransactions.isEmpty)
                    const Center(
                      child: Text(
                        'No transactions recorded yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...summary.recentTransactions.map((record) => _buildTransactionItem(record)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Category breakdown
          Row(
            children: [
              Expanded(
                child: _buildCategoryBreakdown(
                  'Expense Categories',
                  summary.expensesByCategory,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCategoryBreakdown(
                  'Income Sources',
                  summary.incomeByCategory,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Financial projection
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Financial Projection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showProjection
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                        onPressed: _toggleProjection,
                      ),
                    ],
                  ),
                  if (_showProjection) ...[  
                    const SizedBox(height: 16),
                    _buildProjectionCalculator(financeProvider, farmProvider),
                  ] else ...[  
                    const SizedBox(height: 8),
                    const Text(
                      'Calculate your potential profits based on yield and market prices',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _toggleProjection,
                      child: const Text('Show Calculator'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(FinanceProvider financeProvider, FarmProvider farmProvider) {
    if (!farmProvider.hasFarms) {
      return _buildNoFarmMessage();
    }

    final farmId = farmProvider.selectedFarm!.id;
    final farm = farmProvider.selectedFarm!;
    final records = financeProvider.getRecordsForFarm(farmId);
    
    // Filter records by month
    final monthRecords = records.where((record) {
      return record.date.year == _selectedMonth.year && 
              record.date.month == _selectedMonth.month;
    }).toList();
    
    // Sort by date, most recent first
    monthRecords.sort((a, b) => b.date.compareTo(a.date));
    
    // Calculate totals for the month
    double monthIncome = 0;
    double monthExpenses = 0;
    for (var record in monthRecords) {
      if (record.type == TransactionType.income) {
        monthIncome += record.amount;
      } else {
        monthExpenses += record.amount;
      }
    }
    final monthProfit = monthIncome - monthExpenses;
    
    return Column(
      children: [
        // Farm and month selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFarmSelector(farmProvider),
              const SizedBox(height: 16),
              _buildMonthSelector(),
            ],
          ),
        ),
        
        // Month summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kita',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatterUtils.formatCurrency(monthIncome),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Gastos',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatterUtils.formatCurrency(monthExpenses),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Kabuuang Kita',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatterUtils.formatCurrency(monthProfit),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: monthProfit >= 0 ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Transaction list
        Expanded(
          child: monthRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddTransactionDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Dagdag Transaksyon'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: monthRecords.length,
                  itemBuilder: (context, index) {
                    final record = monthRecords[index];
                    
                    // Group by date
                    final bool showDate = index == 0 ||
                        DateTimeUtils.formatDate(record.date) != 
                          DateTimeUtils.formatDate(monthRecords[index - 1].date);
                        
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate) ...[  
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              DateTimeUtils.formatReadableDate(record.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Divider(),
                        ],
                        _buildTransactionItemDetailed(record, farm, financeProvider),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab(FinanceProvider financeProvider, FarmProvider farmProvider) {
    if (!farmProvider.hasFarms) {
      return _buildNoFarmMessage();
    }

    final farmId = farmProvider.selectedFarm!.id;
    final records = financeProvider.getRecordsForFarm(farmId);
    
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No financial data to analyze',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Add transactions to view analytics',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddTransactionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Dagdag Transaksyon'),
            ),
          ],
        ),
      );
    }
    
    // Calculate data for last 6 months
    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
    final monthlySummary = financeProvider.getMonthlySummary(
      farmId,
      sixMonthsAgo,
      DateTime(now.year, now.month + 1, 0),
    );
    
    // Convert data for chart
    final profitData = <FlSpot>[];
    final incomeData = <FlSpot>[];
    final expenseData = <FlSpot>[];
    final months = <String>[];
    
    double maxAmount = 0;
    
    for (int i = 0; i < 6; i++) {
      final date = DateTime(sixMonthsAgo.year, sixMonthsAgo.month + i);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final monthName = DateFormat('MMM').format(date);
      
      months.add(monthName);
      
      // Get income and expenses for month
      double income = 0;
      double expense = 0;
      
      for (var record in records) {
        if (record.date.year == date.year && record.date.month == date.month) {
          if (record.type == TransactionType.income) {
            income += record.amount;
          } else {
            expense += record.amount;
          }
        }
      }
      
      double profit = income - expense;
      maxAmount = max(maxAmount, max(income, expense));
      
      profitData.add(FlSpot(i.toDouble(), profit));
      incomeData.add(FlSpot(i.toDouble(), income));
      expenseData.add(FlSpot(i.toDouble(), expense));
    }
    
    // Get summary
    final summary = financeProvider.getFinancialSummary(farmId);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFarmSelector(farmProvider),
          const SizedBox(height: 24),
          
          // Monthly trend chart
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Financial Trend',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 280,
                    child: LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final data = spot.x.toInt();
                                final month = months[data];
                                final amount = FormatterUtils.formatCurrency(spot.y);
                                final name = spot.barIndex == 0
                                    ? 'Income'
                                    : spot.barIndex == 1
                                        ? 'Expense'
                                        : 'Profit';
                                        
                                return LineTooltipItem(
                                  '$month $name: $amount',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value >= months.length || value < 0) {
                                  return const Text('');
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    months[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: maxAmount * 1.2,
                        lineBarsData: [
                          LineChartBarData(
                            spots: incomeData,
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: expenseData,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: profitData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Income', Colors.green),
                      const SizedBox(width: 24),
                      _buildLegendItem('Expenses', Colors.red),
                      const SizedBox(width: 24),
                      _buildLegendItem('Net Profit', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Category breakdown charts
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (summary.expensesByCategory.isEmpty)
                    const Text('No expense data available')
                  else
                    SizedBox(
                      height: 300,
                      child: PieChart(
                        PieChartData(
                          sections: _getPieChartSections(summary.expensesByCategory),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {},
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (summary.expensesByCategory.isNotEmpty)
                    Column(
                      children: summary.expensesByCategory.entries.map((entry) {
                        return _buildCategoryLegendItem(
                          entry.key,
                          entry.value,
                          summary.totalExpenses,
                          _getCategoryColor(entry.key, summary.expensesByCategory.keys.toList()),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Expense by activity type
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expenses by Activity',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxActivityAmount(records) * 1.2,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= AppConstants.activityTypes.length || value < 0) {
                                  return const Text('');
                                }
                                final activity = AppConstants.activityTypes[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    activity.length > 10 ? activity.substring(0, 8) + '...' : activity,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: _getActivityBarGroups(records),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final activity = AppConstants.activityTypes[group.x.toInt()];
                              return BarTooltipItem(
                                '$activity\n${FormatterUtils.formatCurrency(rod.toY)}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNoFarmMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            "https://pixabay.com/get/g773bf56d7c0c6e5c6d6e0f9d5a5e7f8a7c4ddbe54da4c1e8f3d4a83ee0d45d1f6f32c24e9e46dc5066f551ca72efcf8e3e3b28ba4e8b6fe54b23f9ec81a9c70_1280.jpg",
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          const Text(
            'No farms added yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'You need to create a farm to track finances',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Farm tab
              Navigator.pop(context);
              Navigator.pushNamed(context, '/farm');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Farm'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmSelector(FarmProvider farmProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.landscape, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: farmProvider.selectedFarm?.id ?? (farmProvider.farms.isNotEmpty ? farmProvider.farms.first.id : null),
                hint: const Text('Select Farm'),
                isExpanded: true,
                items: farmProvider.farms.map((farm) {
                  return DropdownMenuItem<String>(
                    value: farm.id,
                    child: Text(farm.name),
                  );
                }).toList(),
                onChanged: (farmId) {
                  if (farmId != null) {
                    final farm = farmProvider.farms.firstWhere((f) => f.id == farmId);
                    farmProvider.setSelectedFarm(farm);
                    Provider.of<FinanceProvider>(context, listen: false).setSelectedFarm(farmId);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return InkWell(
      onTap: _selectMonth,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(FinancialRecordModel record) {
    final isIncome = record.type == TransactionType.income;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: isIncome ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          
          // Description and date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description.isNotEmpty ? record.description : record.category,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateTimeUtils.formatShortDate(record.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // Amount
          Text(
            (isIncome ? '+ ' : '- ') + FormatterUtils.formatCurrency(record.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItemDetailed(FinancialRecordModel record, FarmModel farm, FinanceProvider financeProvider) {
    final isIncome = record.type == TransactionType.income;
    
    // Find field name if applicable
    String fieldName = 'Entire Farm';
    if (record.fieldId.isNotEmpty) {
      final field = farm.fields.firstWhere(
        (f) => f.id == record.fieldId,
        orElse: () => FieldModel(
          id: '',
          name: 'Unknown Field',
          areaHectares: 0,
          cropType: '',
          cropVariety: '',
          plantingDate: '',
          expectedHarvestDate: '',
          boundaries: [],
        ),
      );
      fieldName = field.name;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onLongPress: () {
          // Show delete confirmation
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Transaction'),
              content: const Text('Are you sure you want to delete this transaction?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    financeProvider.deleteFinancialRecord(record.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction type indicator
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Transaction details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.description.isNotEmpty ? record.description : record.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.category + ' - ' + record.activityType,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Text(
                    (isIncome ? '+ ' : '- ') + FormatterUtils.formatCurrency(record.amount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Field
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Field',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fieldName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  
                  // Payment method
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Method',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.paymentMethod,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  
                  // Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateTimeUtils.formatTime(record.date),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(String title, Map<String, double> categories, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...categories.entries.map((entry) {
                final percentage = categories.values.isNotEmpty
                    ? entry.value / categories.values.reduce((a, b) => a + b) * 100
                    : 0.0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            FormatterUtils.formatCurrency(entry.value),
                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          color: color,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionCalculator(FinanceProvider financeProvider, FarmProvider farmProvider) {
    final yieldController = TextEditingController(text: '5000');
    final priceController = TextEditingController(text: '20');
    
    final farm = farmProvider.selectedFarm!;
    
    // For showing projection results
    FinancialProjectionModel? projection;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calculate your potential profit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: yieldController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Yield (kg/hectare)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Expected Price (₱/kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  try {
                    final yield = double.parse(yieldController.text);
                    final price = double.parse(priceController.text);
                    
                    if (yield <= 0 || price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Values must be greater than 0')),
                      );
                      return;
                    }
                    
                    final proj = financeProvider.generateProjection(
                      farmId: farm.id,
                      estimatedYield: yield,
                      estimatedPricePerKg: price,
                      areaHectares: farm.areaHectares,
                    );
                    
                    setState(() {
                      projection = proj;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid numbers')),
                    );
                  }
                },
                child: const Text('Calculate'),
              ),
            ),
            if (projection != null) ...[  
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Projection Results',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildProjectionItem(
                      'Total Yield',
                      FormatterUtils.formatWeight(projection!.projectedYield),
                    ),
                    _buildProjectionItem(
                      'Expected Revenue',
                      FormatterUtils.formatCurrency(projection!.projectedRevenue),
                    ),
                    _buildProjectionItem(
                      'Expected Expenses',
                      FormatterUtils.formatCurrency(projection!.projectedExpenses),
                    ),
                    _buildProjectionItem(
                      'Projected Profit',
                      FormatterUtils.formatCurrency(projection!.projectedProfit),
                      isHighlighted: true,
                    ),
                    _buildProjectionItem(
                      'Return on Investment',
                      FormatterUtils.formatPercentage(projection!.returnOnInvestment),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProjectionItem(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppTheme.primaryColor : null,
              fontSize: isHighlighted ? 18 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildCategoryLegendItem(String category, double amount, double total, Color color) {
    final percentage = total > 0 ? (amount / total * 100) : 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            FormatterUtils.formatCurrency(amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            '(${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, double> categories) {
    final total = categories.values.fold<double>(0, (sum, value) => sum + value);
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];
    
    return categories.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final amount = entry.value.value;
      final percentage = total > 0 ? (amount / total * 100) : 0;
      
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category, List<String> categories) {
    final List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];
    
    final index = categories.indexOf(category);
    return colors[index % colors.length];
  }

  double _getMaxActivityAmount(List<FinancialRecordModel> records) {
    final Map<String, double> activityTotals = {};
    
    for (var activity in AppConstants.activityTypes) {
      activityTotals[activity] = 0;
    }
    
    for (var record in records) {
      if (record.type == TransactionType.expense) {
        activityTotals[record.activityType] = 
            (activityTotals[record.activityType] ?? 0) + record.amount;
      }
    }
    
    return activityTotals.values.fold<double>(0, (max, value) => value > max ? value : max);
  }

  List<BarChartGroupData> _getActivityBarGroups(List<FinancialRecordModel> records) {
    final Map<String, double> activityTotals = {};
    
    for (var activity in AppConstants.activityTypes) {
      activityTotals[activity] = 0;
    }
    
    for (var record in records) {
      if (record.type == TransactionType.expense) {
        activityTotals[record.activityType] = 
            (activityTotals[record.activityType] ?? 0) + record.amount;
      }
    }
    
    return AppConstants.activityTypes.asMap().entries.map((entry) {
      final index = entry.key;
      final activity = entry.value;
      final amount = activityTotals[activity] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: AppTheme.primaryColor,
            width: 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            rodStackItems: [
              BarChartRodStackItem(0, amount, AppTheme.primaryColor.withOpacity(0.7)),
            ],
          ),
        ],
      );
    }).toList();
  }
}

// AppConstants class for this file
class AppConstants {
  // Financial activity types
  static const List<String> activityTypes = [
    'Land Preparation',
    'Planting',
    'Fertilizer Application',
    'Pest Control',
    'Irrigation',
    'Harvest',
    'Post-Harvest',
    'Transportation',
    'Marketing',
    'Equipment Purchase',
    'Other'
  ];
}