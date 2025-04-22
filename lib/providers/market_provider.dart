import 'package:flutter/foundation.dart';
import '../models/market_price_model.dart';
import '../services/market_service.dart';

class MarketProvider with ChangeNotifier {
  final MarketService _marketService = MarketService();
  List<MarketPriceModel> _marketPrices = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCropType = 'All'; // 'All', 'Corn', or 'Palay'

  // Getters
  List<MarketPriceModel> get marketPrices => _marketPrices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCropType => _selectedCropType;
  
  // Setter for market prices - needed for admin functionality
  set marketPrices(List<MarketPriceModel> prices) {
    _marketPrices = prices;
    notifyListeners();
  }
  
  // Filtered market prices based on selected crop type
  List<MarketPriceModel> get filteredMarketPrices {
    if (_selectedCropType == 'All') {
      return _marketPrices;
    } else {
      return _marketPrices.where((price) => price.cropType == _selectedCropType).toList();
    }
  }

  // Set selected crop type
  void setSelectedCropType(String cropType) {
    _selectedCropType = cropType;
    notifyListeners();
  }

  // Fetch market prices
  Future<void> fetchMarketPrices() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _marketPrices = await _marketService.fetchMarketPrices();
    } catch (e) {
      _errorMessage = 'Failed to fetch market prices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add a market price
  void addMarketPrice(MarketPriceModel price) {
    _marketPrices.add(price);
    notifyListeners();
  }
  
  // Update a market price
  void updateMarketPrice(MarketPriceModel oldPrice, MarketPriceModel newPrice) {
    final index = _marketPrices.indexWhere(
      (p) => p.cropType == oldPrice.cropType && p.variety == oldPrice.variety,
    );
    if (index != -1) {
      _marketPrices[index] = newPrice;
      notifyListeners();
    }
  }
  
  // Delete a market price
  void deleteMarketPrice(MarketPriceModel price) {
    _marketPrices.removeWhere(
      (p) => p.cropType == price.cropType && p.variety == price.variety,
    );
    notifyListeners();
  }

  // Get market recommendation for a crop type
  Future<String> getMarketRecommendation(String cropType) async {
    try {
      return await _marketService.getPriceRecommendation(cropType);
    } catch (e) {
      return 'Unable to provide market recommendation at this time.';
    }
  }

  // Get highest price for a crop type
  MarketPriceModel? getHighestPrice(String cropType) {
    try {
      final prices = _marketPrices.where((price) => price.cropType == cropType).toList();
      if (prices.isEmpty) return null;
      
      return prices.reduce((a, b) => a.pricePerKg > b.pricePerKg ? a : b);
    } catch (e) {
      return null;
    }
  }

  // Get lowest price for a crop type
  MarketPriceModel? getLowestPrice(String cropType) {
    try {
      final prices = _marketPrices.where((price) => price.cropType == cropType).toList();
      if (prices.isEmpty) return null;
      
      return prices.reduce((a, b) => a.pricePerKg < b.pricePerKg ? a : b);
    } catch (e) {
      return null;
    }
  }

  // Get average price for a crop type
  double getAveragePrice(String cropType) {
    try {
      final prices = _marketPrices.where((price) => price.cropType == cropType).toList();
      if (prices.isEmpty) return 0;
      
      final totalPrice = prices.fold<double>(0, (sum, price) => sum + price.pricePerKg);
      return totalPrice / prices.length;
    } catch (e) {
      return 0;
    }
  }

  // Get price trend ratio (up/down/stable)
  Map<String, int> getPriceTrendRatio(String cropType) {
    try {
      final prices = _marketPrices.where((price) => price.cropType == cropType).toList();
      if (prices.isEmpty) {
        return {'up': 0, 'down': 0, 'stable': 0};
      }
      
      int upCount = prices.where((price) => price.trend == PriceTrend.up).length;
      int downCount = prices.where((price) => price.trend == PriceTrend.down).length;
      int stableCount = prices.where((price) => price.trend == PriceTrend.stable).length;
      
      return {'up': upCount, 'down': downCount, 'stable': stableCount};
    } catch (e) {
      return {'up': 0, 'down': 0, 'stable': 0};
    }
  }

  // Get formatted price with PHP symbol
  String getFormattedPrice(double price) {
    return 'u20b1${price.toStringAsFixed(2)}';
  }
}