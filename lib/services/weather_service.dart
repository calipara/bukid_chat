import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/weather_model.dart';
import 'storage_service.dart';

class WeatherService {
  final StorageService _storageService = StorageService();
  
  // Fetch weather for given coordinates
  Future<List<WeatherModel>> fetchWeather(double lat, double lng) async {
    // First check if we have recent weather data
    final lastUpdate = await _storageService.getLastWeatherUpdate();
    final now = DateTime.now();
    
    // If we have data that's less than 6 hours old, return it
    if (lastUpdate != null && 
        now.difference(lastUpdate).inHours < ApiConstants.weatherDataRefreshInterval) {
      final cachedData = await _storageService.getWeatherData();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
    }
    
    // Check if using placeholder API key - use mock data instead of real API call
    if (ApiConstants.weatherApiKey == 'OPENWEATHER-API-KEY') {
      // Return mock weather data
      final mockData = _generateMockWeatherData(lat, lng);
      await _storageService.saveWeatherData(mockData);
      return mockData;
    }
    
    // Otherwise fetch new data from actual API
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.weatherApiBaseUrl}?lat=$lat&lon=$lng&units=metric&appid=${ApiConstants.weatherApiKey}',
        ),
      );
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<WeatherModel> weatherList = [];
        
        // Parse the 5-day forecast data
        for (var item in jsonData['list']) {
          weatherList.add(WeatherModel.fromOpenWeatherMap(item));
        }
        
        // Save to storage
        await _storageService.saveWeatherData(weatherList);
        
        return weatherList;
      } else {
        // If API fails, generate mock data
        final mockData = _generateMockWeatherData(lat, lng);
        await _storageService.saveWeatherData(mockData);
        return mockData;
      }
    } catch (e) {
      // If there's an error, try to return cached data if available
      final cachedData = await _storageService.getWeatherData();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
      
      // As last resort, return mock data
      final mockData = _generateMockWeatherData(lat, lng);
      await _storageService.saveWeatherData(mockData);
      return mockData;
    }
  }
  
  // Get current weather (first item from forecast)
  Future<WeatherModel?> getCurrentWeather(double lat, double lng) async {
    final forecastList = await fetchWeather(lat, lng);
    if (forecastList.isNotEmpty) {
      return forecastList.first;
    }
    return null;
  }
  
  // Get daily forecast (one item per day)
  Future<List<WeatherModel>> getDailyForecast(double lat, double lng) async {
    final forecastList = await fetchWeather(lat, lng);
    final Map<String, WeatherModel> dailyMap = {};
    
    // Group by day and take one item per day
    for (var weather in forecastList) {
      final dateKey = weather.timestamp.toIso8601String().split('T')[0];
      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = weather;
      }
    }
    
    return dailyMap.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  // Get farmer-friendly weather description
  String getFarmerAdvice(WeatherModel weather) {
    if (weather.main == 'Rain' && weather.rainAmount > 10) {
      return 'Heavy rainfall expected. Not suitable for fieldwork. Ensure proper drainage to prevent waterlogging.';
    } else if (weather.main == 'Rain') {
      return 'Light rain expected. Limited fieldwork possible. Good time for planting if prepared.';
    } else if (weather.temperature > 35) {
      return 'Very hot conditions. Irrigate crops in early morning or evening. Avoid midday fieldwork.';
    } else if (weather.windSpeed > 10) {
      return 'Strong winds expected. Not suitable for spraying pesticides or fertilizers.';
    } else if (weather.main == 'Clear' && weather.temperature > 30) {
      return 'Hot and clear. Good for drying harvests. Ensure adequate irrigation for young plants.';
    } else if (weather.main == 'Clouds') {
      return 'Cloudy conditions. Good for general fieldwork and planting.';
    } else {
      return 'Favorable conditions for most farming activities.';
    }
  }
  
  // Generate mock weather data for development and when API key is not available
  List<WeatherModel> _generateMockWeatherData(double lat, double lng) {
    final List<WeatherModel> mockWeatherList = [];
    final now = DateTime.now();
    
    // Weather condition options
    final List<Map<String, dynamic>> conditions = [
      {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'},
      {'main': 'Clouds', 'description': 'scattered clouds', 'icon': '03d'},
      {'main': 'Clouds', 'description': 'broken clouds', 'icon': '04d'},
      {'main': 'Rain', 'description': 'light rain', 'icon': '10d', 'rain': 2.5},
      {'main': 'Rain', 'description': 'moderate rain', 'icon': '10d', 'rain': 8.0},
    ];
    
    // Generate 5 days of weather data
    for (int i = 0; i < 5; i++) {
      final day = now.add(Duration(days: i));
      
      // Create 4 data points per day (every 6 hours)
      for (int hour = 0; hour < 24; hour += 6) {
        final time = DateTime(day.year, day.month, day.day, hour);
        
        // Randomly select a weather condition
        final condition = conditions[DateTime.now().microsecond % conditions.length];
        
        // Generate temperature - higher during day, lower at night
        double baseTemp = 28.0; // Base temperature for Philippines
        if (hour > 6 && hour < 18) {
          baseTemp += 4.0; // Daytime is warmer
        } else {
          baseTemp -= 3.0; // Nighttime is cooler
        }
        
        // Add some randomness to temperature
        final randomFactor = (DateTime.now().microsecond % 100) / 100;
        final temperature = baseTemp + (randomFactor * 4) - 2; // +/- 2 degrees
        
        mockWeatherList.add(WeatherModel(
          temperature: temperature,
          feelsLike: temperature + 1.0,
          tempMin: temperature - 2.0,
          tempMax: temperature + 2.0,
          pressure: 1010 + (DateTime.now().microsecond % 10),
          humidity: 65 + (DateTime.now().microsecond % 20),
          windSpeed: 3.0 + (DateTime.now().microsecond % 100) / 10, // 3-13 km/h
          windDegree: (DateTime.now().microsecond % 360),
          description: condition['description'],
          icon: condition['icon'],
          main: condition['main'],
          timestamp: time,
          rainAmount: condition['rain'] ?? 0.0,
        ));
      }
    }
    
    return mockWeatherList;
  }
}