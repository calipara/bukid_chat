import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/market_price_model.dart';
import '../../providers/market_provider.dart';
import '../../utils/formatter_utils.dart';
import '../../constants/app_constants.dart';

class MarketPriceAdminScreen extends StatefulWidget {
  const MarketPriceAdminScreen({Key? key}) : super(key: key);

  @override
  _MarketPriceAdminScreenState createState() => _MarketPriceAdminScreenState();
}

class _MarketPriceAdminScreenState extends State<MarketPriceAdminScreen> {
  String _filterCropType = 'All';
  bool _isAdding = false;
  bool _isEditing = false;
  MarketPriceModel? _selectedPrice;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _cropTypeController = TextEditingController();
  final _varietyController = TextEditingController();
  final _pricePerKgController = TextEditingController();
  final _locationController = TextEditingController();
  final _sourceController = TextEditingController();
  String _selectedTrend = 'stable';

  @override
  void dispose() {
    _cropTypeController.dispose();
    _varietyController.dispose();
    _pricePerKgController.dispose();
    _locationController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _cropTypeController.text = 'Corn';
    _varietyController.text = '';
    _pricePerKgController.text = '';
    _locationController.text = '';
    _sourceController.text = 'Department of Agriculture';
    _selectedTrend = 'stable';
    _selectedPrice = null;
  }

  void _prepareForEdit(MarketPriceModel price) {
    _cropTypeController.text = price.cropType;
    _varietyController.text = price.variety;
    _pricePerKgController.text = price.pricePerKg.toString();
    _locationController.text = price.location;
    _sourceController.text = price.source;
    _selectedTrend = price.trend.toString().split('.').last;
    _selectedPrice = price;
  }

  void _showAddEditForm({MarketPriceModel? priceToEdit}) {
    setState(() {
      if (priceToEdit != null) {
        _isEditing = true;
        _isAdding = false;
        _prepareForEdit(priceToEdit);
      } else {
        _isAdding = true;
        _isEditing = false;
        _resetForm();
      }
    });
  }

  void _cancelAddEdit() {
    setState(() {
      _isAdding = false;
      _isEditing = false;
      _resetForm();
    });
  }

  void _saveMarketPrice() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final provider = Provider.of<MarketProvider>(context, listen: false);
      
      // Parse values
      final cropType = _cropTypeController.text;
      final variety = _varietyController.text;
      final pricePerKg = double.parse(_pricePerKgController.text);
      final location = _locationController.text;
      final source = _sourceController.text;
      
      // Calculate price per cavan (50kg sack)
      final pricePerCavan = pricePerKg * 50;
      
      // Parse trend
      PriceTrend trend;
      switch (_selectedTrend) {
        case 'up':
          trend = PriceTrend.up;
          break;
        case 'down':
          trend = PriceTrend.down;
          break;
        case 'stable':
        default:
          trend = PriceTrend.stable;
          break;
      }

      if (_isEditing && _selectedPrice != null) {
        // Create updated model
        final updatedPrice = MarketPriceModel(
          cropType: cropType,
          variety: variety,
          pricePerKg: pricePerKg,
          pricePerCavan: pricePerCavan,
          location: location,
          date: DateTime.now(), // Update date to current
          source: source,
          trend: trend,
        );

        // Replace in list
        final prices = List<MarketPriceModel>.from(provider.marketPrices);
        final index = prices.indexWhere(
          (p) => p.cropType == _selectedPrice!.cropType && p.variety == _selectedPrice!.variety,
        );

        if (index != -1) {
          prices[index] = updatedPrice;
          provider.marketPrices = prices; // This would be replaced with a provider method in real app
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price updated successfully')),
        );
      } else {
        // Create new model
        final newPrice = MarketPriceModel(
          cropType: cropType,
          variety: variety,
          pricePerKg: pricePerKg,
          pricePerCavan: pricePerCavan,
          location: location,
          date: DateTime.now(),
          source: source,
          trend: trend,
        );

        // Add to list
        final prices = List<MarketPriceModel>.from(provider.marketPrices);
        prices.add(newPrice);
        provider.marketPrices = prices; // This would be replaced with a provider method in real app

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Price added successfully')),
        );
      }

      // Close form
      setState(() {
        _isAdding = false;
        _isEditing = false;
        _resetForm();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deleteMarketPrice(MarketPriceModel price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${price.variety} ${price.cropType} price data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = Provider.of<MarketProvider>(context, listen: false);
              final prices = List<MarketPriceModel>.from(provider.marketPrices);
              prices.removeWhere(
                (p) => p.cropType == price.cropType && p.variety == price.variety,
              );
              provider.marketPrices = prices; // This would be replaced with a provider method in real app

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Price deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Price Management'),
        centerTitle: true,
      ),
      body: Consumer<MarketProvider>(
        builder: (context, marketProvider, child) {
          final prices = marketProvider.marketPrices;
          
          // Apply filter
          final filteredPrices = _filterCropType == 'All'
              ? prices
              : prices.where((price) => price.cropType == _filterCropType).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Filter: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterCropType,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Crops')),
                              DropdownMenuItem(value: 'Corn', child: Text('Corn')),
                              DropdownMenuItem(value: 'Palay', child: Text('Palay (Rice)')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _filterCropType = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    if (!_isAdding && !_isEditing)
                      ElevatedButton.icon(
                        onPressed: () => _showAddEditForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Price'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (_isAdding || _isEditing) _buildAddEditForm(),
              Expanded(
                child: filteredPrices.isEmpty
                    ? Center(
                        child: Text(
                          _filterCropType == 'All'
                              ? 'No market prices available.\nAdd your first price data!'
                              : 'No $_filterCropType prices available.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredPrices.length,
                        itemBuilder: (context, index) {
                          final price = filteredPrices[index];
                          return _buildPriceCard(price);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceCard(MarketPriceModel price) {
    final trendIcon = price.trend == PriceTrend.up
        ? Icons.trending_up
        : price.trend == PriceTrend.down
            ? Icons.trending_down
            : Icons.trending_flat;

    final trendColor = price.trend == PriceTrend.up
        ? Colors.green
        : price.trend == PriceTrend.down
            ? Colors.red
            : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop type indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: price.cropType == 'Corn'
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    price.cropType == 'Corn' ? Icons.grass : Icons.grain,
                    color: price.cropType == 'Corn' ? Colors.amber[800] : Colors.green[800],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16.0),
                
                // Price details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.variety,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        price.cropType,
                        style: TextStyle(
                          color: price.cropType == 'Corn'
                              ? Colors.amber[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            price.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Price and trend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatterUtils.formatCurrency(price.pricePerKg) + '/kg',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          trendIcon,
                          color: trendColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          price.trend.toString().split('.').last,
                          style: TextStyle(
                            color: trendColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddEditForm(priceToEdit: price),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8.0),
                TextButton.icon(
                  onPressed: () => _deleteMarketPrice(price),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEditForm() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit Market Price' : 'Add New Market Price',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Crop Type dropdown
              DropdownButtonFormField<String>(
                value: _cropTypeController.text,
                decoration: const InputDecoration(
                  labelText: 'Crop Type',
                  prefixIcon: Icon(Icons.agriculture),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Corn', child: Text('Corn')),
                  DropdownMenuItem(value: 'Palay', child: Text('Palay (Rice)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _cropTypeController.text = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a crop type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Variety dropdown
              TextFormField(
                controller: _varietyController,
                decoration: const InputDecoration(
                  labelText: 'Variety',
                  hintText: 'e.g., Yellow Corn, Dinorado Rice',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the crop variety';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Price per kg
              TextFormField(
                controller: _pricePerKgController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price per kg (PHP)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price per kg';
                  }
                  try {
                    final price = double.parse(value);
                    if (price <= 0) {
                      return 'Price must be greater than 0';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Nueva Ecija, Isabela',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Source
              TextFormField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Source',
                  hintText: 'e.g., Department of Agriculture',
                  prefixIcon: Icon(Icons.source),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the data source';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              
              // Price Trend
              const Text(
                'Price Trend',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _buildTrendOption('up', Icons.trending_up, Colors.green),
                  const SizedBox(width: 16.0),
                  _buildTrendOption('stable', Icons.trending_flat, Colors.orange),
                  const SizedBox(width: 16.0),
                  _buildTrendOption('down', Icons.trending_down, Colors.red),
                ],
              ),
              const SizedBox(height: 24.0),
              
              // Form buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelAddEdit,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _saveMarketPrice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: Text(_isEditing ? 'Update Price' : 'Add Price'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendOption(String trend, IconData icon, Color color) {
    final isSelected = _selectedTrend == trend;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTrend = trend;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey,
              ),
              const SizedBox(height: 4.0),
              Text(
                trend.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}