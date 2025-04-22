import '../models/market_price_model.dart';
import 'storage_service.dart';
import '../constants/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketService {
  final StorageService _storageService = StorageService();
  
  // Fetch latest market prices (would normally come from an API)
  Future<List<MarketPriceModel>> fetchMarketPrices() async {
    // First check if we have recent market data
    final lastUpdate = await _storageService.getLastMarketUpdate();
    final now = DateTime.now();
    
    // If we have data that's less than 24 hours old, return it
    if (lastUpdate != null && 
        now.difference(lastUpdate).inHours < ApiConstants.marketDataRefreshInterval) {
      final cachedData = await _storageService.getMarketPrices();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
    }
    
    // In a real app, we would fetch data from an API here
    // For this demo, we'll use sample data
    // But we'll simulate a network request with a delay
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network request
      
      // Generate sample data
      final sampleData = MarketPriceModel.getSampleData();
      
      // Save to storage
      await _storageService.saveMarketPrices(sampleData);
      
      return sampleData;
    } catch (e) {
      // If there's an error, try to return cached data if available
      final cachedData = await _storageService.getMarketPrices();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
      throw Exception('Failed to fetch market prices: $e');
    }
  }
  
  // Get prices for a specific crop type
  Future<List<MarketPriceModel>> getPricesForCrop(String cropType) async {
    final allPrices = await fetchMarketPrices();
    return allPrices.where((price) => price.cropType == cropType).toList();
  }
  
  // Get price for specific crop and variety
  Future<MarketPriceModel?> getPriceForVariety(
    String cropType, 
    String variety
  ) async {
    final allPrices = await fetchMarketPrices();
    try {
      return allPrices.firstWhere(
        (price) => price.cropType == cropType && price.variety == variety
      );
    } catch (e) {
      return null; // Not found
    }
  }
  
  // Get price recommendation for farming decision
  Future<String> getPriceRecommendation(String cropType) async {
    final prices = await getPricesForCrop(cropType);
    
    if (prices.isEmpty) {
      return 'No market data available for $cropType.';
    }
    
    // Find the best price and location
    final bestPrice = prices.reduce(
      (a, b) => a.pricePerKg > b.pricePerKg ? a : b
    );
    
    // Find the average price
    final averagePrice = prices.fold<double>(
        0, (sum, price) => sum + price.pricePerKg) / prices.length;
    
    // Count trends
    int upTrends = prices.where((p) => p.trend == PriceTrend.up).length;
    int downTrends = prices.where((p) => p.trend == PriceTrend.down).length;
    
    String trendAnalysis;
    if (upTrends > downTrends) {
      trendAnalysis = 'Market prices appear to be increasing.';
    } else if (downTrends > upTrends) {
      trendAnalysis = 'Market prices appear to be decreasing.';
    } else {
      trendAnalysis = 'Market prices are relatively stable.';
    }
    
    return 'The best current price for $cropType is ₱${bestPrice.pricePerKg.toStringAsFixed(2)}/kg ' 
      + 'in ${bestPrice.location}. Average price is ₱${averagePrice.toStringAsFixed(2)}/kg. ' 
      + trendAnalysis;
  }
}