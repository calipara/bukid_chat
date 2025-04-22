class AppConstants {
  // App general information
  static const String appName = 'Bukid App';
  static const String appVersion = '1.0.0';
  
  // User preferences keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyUserName = 'user_name';
  static const String keyFarmProfileCreated = 'farm_profile_created';
  static const String keySelectedCrops = 'selected_crops';
  
  // Farm data keys
  static const String keyFarmData = 'farm_data';
  static const String keyFarmMaps = 'farm_maps';
  
  // Weather keys
  static const String keyLastWeatherUpdate = 'last_weather_update';
  static const String keyWeatherData = 'weather_data';
  
  // Market price keys
  static const String keyMarketPrices = 'market_prices';
  static const String keyLastMarketUpdate = 'last_market_update';
  
  // Financial keys
  static const String keyFinancialRecords = 'financial_records';
  
  // Language options
  static const String keyLanguagePreference = 'language_preference';
  static const List<String> supportedLanguages = ['English', 'Filipino'];
  
  // Crop types for Philippines
  static const List<String> cropTypes = ['Corn', 'Palay (Rice)'];
  
  // Mais varieties common in Philippines
  static const List<String> cornVarieties = [
    'Yellow Corn',
    'White Corn',
    'Glutinous Corn',
    'Sweet Corn',
    'Bt Corn',
    'GMO Corn',
    'Native Corn',
  ];
  
  // Rice/Palay varieties common in Philippines
  static const List<String> palayVarieties = [
    'NSIC Rc160 (Tubigan 14)',
    'NSIC Rc222 (Tubigan 18)',
    'NSIC Rc216 (Tubigan 17)',
    'NSIC Rc238 (Tubigan 21)',
    'NSIC Rc402 (Tubigan 36)',
    'Dinorado',
    'Black Rice',
    'Red Rice',
    'Glutinous Rice',
    'NSIC Rc9 (Apo)',
    'NSIC Rc14 (Rio Grande)',
  ];

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

  // Units of measurement
  static const Map<String, String> units = {
    'area': 'Hectare',
    'small_area': 'Square Meter',
    'weight_large': 'Metric Ton',
    'weight': 'Kilogram',
    'volume': 'Liter',
    'count': 'Piece',
    'sack': 'Sack (50kg)',
    'cavan': 'Cavan (50kg)',
  };
}