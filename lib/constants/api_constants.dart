class ApiConstants {
  // OpenAI API
  static const String openAiBaseUrl = 'https://us-central1-dreamflow-dev.cloudfunctions.net/dreamflowOpenaiProxyHttpsFn';
  static const String openAiModel = 'gpt-4o';
  static const String openAiApiKeyPlaceholder = 'JeYnymDVWyCP1p2cWk0P-427618800e3313b87deb9c7dd60dd1ae55945b505d9445bf55b8fb04666f2978';

  // Weather API - using OpenWeatherMap as example
  static const String weatherApiBaseUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  static const String weatherApiKey = 'OPENWEATHER-API-KEY'; // Replace in production
  
  // Geocoding API
  static const String geocodingApiBaseUrl = 'https://api.openweathermap.org/geo/1.0/direct';
  
  // Default coordinates for Philippines (Manila)
  static const double defaultLatitude = 14.5995;
  static const double defaultLongitude = 120.9842;
  
  // Philippine locations - sample for initial data
  static const Map<String, Map<String, double>> philippineLocations = {
    'Manila': {'lat': 14.5995, 'lng': 120.9842},
    'Cebu City': {'lat': 10.3157, 'lng': 123.8854},
    'Davao City': {'lat': 7.1907, 'lng': 125.4553},
    'Nueva Ecija': {'lat': 15.5784, 'lng': 121.1113}, // Major rice producing area
    'Isabela': {'lat': 16.9754, 'lng': 121.8107}, // Major corn/rice production area
    'Bukidnon': {'lat': 8.0515, 'lng': 125.0852}, // Major corn producing area
    'Iloilo': {'lat': 10.7202, 'lng': 122.5621}, // Rice production area
    'Cagayan': {'lat': 17.9418, 'lng': 121.7888}, // Rice and corn production
  };
  
  // Default market API data refresh interval in hours
  static const int marketDataRefreshInterval = 24;
  
  // Default weather API data refresh interval in hours
  static const int weatherDataRefreshInterval = 6;
  
  // Chatbot context prompt for Philippine farming (used as system message)
  static const String farmingChatbotContext = '''
    You are a helpful assistant for Filipino farmers focusing on corn and rice (palay) cultivation. 
    Provide practical advice specific to Philippine agricultural conditions, using simple language.
    Include both traditional farming knowledge and modern sustainable techniques.
    When appropriate, mention local terms and practices familiar to Filipino farmers.
    For pest identification, analyze any images provided and suggest appropriate management strategies.
    Be specific about solutions available in the Philippines and consider local climate patterns.
    Always prioritize environmentally-friendly and cost-effective solutions when possible.
  ''';
}