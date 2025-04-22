import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/farm_model.dart';
import '../models/financial_model.dart';
import '../models/market_price_model.dart';
import '../models/weather_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  // Singleton instance of SharedPreferences
  SharedPreferences? _prefs;

  // Initialize shared preferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Check if onboarding is complete
  Future<bool> isOnboardingComplete() async {
    await init();
    return _prefs!.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  // Set onboarding complete status
  Future<void> setOnboardingComplete(bool complete) async {
    await init();
    await _prefs!.setBool(AppConstants.keyOnboardingComplete, complete);
  }

  // Check if farm profile is created
  Future<bool> isFarmProfileCreated() async {
    await init();
    return _prefs!.getBool(AppConstants.keyFarmProfileCreated) ?? false;
  }

  // Set farm profile creation status
  Future<void> setFarmProfileCreated(bool created) async {
    await init();
    await _prefs!.setBool(AppConstants.keyFarmProfileCreated, created);
  }

  // Save farm data
  Future<void> saveFarms(List<FarmModel> farms) async {
    await init();
    final jsonString = FarmModel.toJsonList(farms);
    await _prefs!.setString(AppConstants.keyFarmData, jsonString);
  }

  // Get farm data
  Future<List<FarmModel>> getFarms() async {
    await init();
    final jsonString = _prefs!.getString(AppConstants.keyFarmData);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return FarmModel.fromJsonList(jsonString);
  }

  // Save weather data
  Future<void> saveWeatherData(List<WeatherModel> weatherList) async {
    await init();
    final jsonString = WeatherModel.toJsonList(weatherList);
    await _prefs!.setString(AppConstants.keyWeatherData, jsonString);
    await _prefs!.setString(
      AppConstants.keyLastWeatherUpdate,
      DateTime.now().toIso8601String(),
    );
  }

  // Get weather data
  Future<List<WeatherModel>> getWeatherData() async {
    await init();
    final jsonString = _prefs!.getString(AppConstants.keyWeatherData);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return WeatherModel.fromJsonList(jsonString);
  }

  // Get last weather update time
  Future<DateTime?> getLastWeatherUpdate() async {
    await init();
    final dateString = _prefs!.getString(AppConstants.keyLastWeatherUpdate);
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    return DateTime.parse(dateString);
  }

  // Save market price data
  Future<void> saveMarketPrices(List<MarketPriceModel> priceList) async {
    await init();
    final jsonString = MarketPriceModel.toJsonList(priceList);
    await _prefs!.setString(AppConstants.keyMarketPrices, jsonString);
    await _prefs!.setString(
      AppConstants.keyLastMarketUpdate,
      DateTime.now().toIso8601String(),
    );
  }

  // Get market price data
  Future<List<MarketPriceModel>> getMarketPrices() async {
    await init();
    final jsonString = _prefs!.getString(AppConstants.keyMarketPrices);
    if (jsonString == null || jsonString.isEmpty) {
      // Return sample data if no data is available
      return MarketPriceModel.getSampleData();
    }
    return MarketPriceModel.fromJsonList(jsonString);
  }

  // Get last market price update time
  Future<DateTime?> getLastMarketUpdate() async {
    await init();
    final dateString = _prefs!.getString(AppConstants.keyLastMarketUpdate);
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    return DateTime.parse(dateString);
  }

  // Save financial records
  Future<void> saveFinancialRecords(List<FinancialRecordModel> records) async {
    await init();
    final jsonString = FinancialRecordModel.toJsonList(records);
    await _prefs!.setString(AppConstants.keyFinancialRecords, jsonString);
  }

  // Get financial records
  Future<List<FinancialRecordModel>> getFinancialRecords() async {
    await init();
    final jsonString = _prefs!.getString(AppConstants.keyFinancialRecords);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return FinancialRecordModel.fromJsonList(jsonString);
  }

  // Save user settings
  Future<void> saveUserName(String name) async {
    await init();
    await _prefs!.setString(AppConstants.keyUserName, name);
  }

  // Get user name
  Future<String?> getUserName() async {
    await init();
    return _prefs!.getString(AppConstants.keyUserName);
  }

  // Save selected crops
  Future<void> saveSelectedCrops(List<String> crops) async {
    await init();
    await _prefs!.setStringList(AppConstants.keySelectedCrops, crops);
  }

  // Get selected crops
  Future<List<String>> getSelectedCrops() async {
    await init();
    return _prefs!.getStringList(AppConstants.keySelectedCrops) ?? [];
  }

  // Save language preference
  Future<void> saveLanguagePreference(String language) async {
    await init();
    await _prefs!.setString(AppConstants.keyLanguagePreference, language);
  }

  // Get language preference
  Future<String> getLanguagePreference() async {
    await init();
    return _prefs!.getString(AppConstants.keyLanguagePreference) ?? 'English';
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await init();
    await _prefs!.clear();
  }
}