import 'dart:convert';

class MarketPriceModel {
  final String cropType; // 'Corn' or 'Palay'
  final String variety;
  final double pricePerKg;
  final double pricePerCavan; // 50kg sack price
  final String location;
  final DateTime date;
  final String source; // Source of the price information
  final PriceTrend trend;

  MarketPriceModel({
    required this.cropType,
    required this.variety,
    required this.pricePerKg,
    required this.pricePerCavan,
    required this.location,
    required this.date,
    required this.source,
    required this.trend,
  });

  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType,
      'variety': variety,
      'pricePerKg': pricePerKg,
      'pricePerCavan': pricePerCavan,
      'location': location,
      'date': date.toIso8601String(),
      'source': source,
      'trend': trend.toString().split('.').last,
    };
  }

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      cropType: json['cropType'],
      variety: json['variety'],
      pricePerKg: json['pricePerKg'].toDouble(),
      pricePerCavan: json['pricePerCavan'].toDouble(),
      location: json['location'],
      date: DateTime.parse(json['date']),
      source: json['source'],
      trend: _parseTrend(json['trend']),
    );
  }

  static PriceTrend _parseTrend(String trendString) {
    switch (trendString) {
      case 'up':
        return PriceTrend.up;
      case 'down':
        return PriceTrend.down;
      case 'stable':
        return PriceTrend.stable;
      default:
        return PriceTrend.stable;
    }
  }

  static String toJsonList(List<MarketPriceModel> priceList) {
    final jsonList = priceList.map((price) => price.toJson()).toList();
    return json.encode(jsonList);
  }

  static List<MarketPriceModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => MarketPriceModel.fromJson(json)).toList();
  }

  // Sample data for initial demo
  static List<MarketPriceModel> getSampleData() {
    final now = DateTime.now();
    
    return [
      // Corn prices
      MarketPriceModel(
        cropType: 'Corn',
        variety: 'Yellow Corn',
        pricePerKg: 18.50,
        pricePerCavan: 925.0,
        location: 'Nueva Ecija',
        date: now,
        source: 'Department of Agriculture',
        trend: PriceTrend.up,
      ),
      MarketPriceModel(
        cropType: 'Corn',
        variety: 'White Corn',
        pricePerKg: 20.25,
        pricePerCavan: 1012.50,
        location: 'Isabela',
        date: now,
        source: 'Department of Agriculture',
        trend: PriceTrend.stable,
      ),
      MarketPriceModel(
        cropType: 'Corn',
        variety: 'Sweet Corn',
        pricePerKg: 35.0,
        pricePerCavan: 1750.0,
        location: 'Bukidnon',
        date: now,
        source: 'Local Market Survey',
        trend: PriceTrend.up,
      ),
      
      // Palay prices
      MarketPriceModel(
        cropType: 'Palay',
        variety: 'NSIC Rc222',
        pricePerKg: 19.75,
        pricePerCavan: 987.50,
        location: 'Nueva Ecija',
        date: now,
        source: 'Department of Agriculture',
        trend: PriceTrend.down,
      ),
      MarketPriceModel(
        cropType: 'Palay',
        variety: 'Dinorado',
        pricePerKg: 25.50,
        pricePerCavan: 1275.0,
        location: 'Iloilo',
        date: now,
        source: 'NFA',
        trend: PriceTrend.stable,
      ),
      MarketPriceModel(
        cropType: 'Palay',
        variety: 'Black Rice',
        pricePerKg: 60.0,
        pricePerCavan: 3000.0,
        location: 'Davao',
        date: now,
        source: 'Local Market Survey',
        trend: PriceTrend.up,
      ),
    ];
  }
}

enum PriceTrend {
  up,
  down,
  stable,
}