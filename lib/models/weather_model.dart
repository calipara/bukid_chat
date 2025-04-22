import 'dart:convert';

class WeatherModel {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final String description;
  final String icon;
  final String main;
  final DateTime timestamp;
  final double rainAmount; // rainfall in mm

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.description,
    required this.icon,
    required this.main,
    required this.timestamp,
    this.rainAmount = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'pressure': pressure,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDegree': windDegree,
      'description': description,
      'icon': icon,
      'main': main,
      'timestamp': timestamp.toIso8601String(),
      'rainAmount': rainAmount,
    };
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['temperature'].toDouble(),
      feelsLike: json['feelsLike'].toDouble(),
      tempMin: json['tempMin'].toDouble(),
      tempMax: json['tempMax'].toDouble(),
      pressure: json['pressure'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'].toDouble(),
      windDegree: json['windDegree'],
      description: json['description'],
      icon: json['icon'],
      main: json['main'],
      timestamp: DateTime.parse(json['timestamp']),
      rainAmount: json['rainAmount']?.toDouble() ?? 0.0,
    );
  }

  static String toJsonList(List<WeatherModel> weatherList) {
    final jsonList = weatherList.map((weather) => weather.toJson()).toList();
    return json.encode(jsonList);
  }

  static List<WeatherModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => WeatherModel.fromJson(json)).toList();
  }

  // Factory method to create from OpenWeatherMap API response
  factory WeatherModel.fromOpenWeatherMap(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    final main = json['main'];
    final wind = json['wind'];
    final rain = json['rain'];

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      pressure: main['pressure'],
      humidity: main['humidity'],
      windSpeed: (wind['speed'] as num).toDouble(),
      windDegree: wind['deg'],
      description: weather['description'],
      icon: weather['icon'],
      main: weather['main'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      rainAmount: rain != null && rain['3h'] != null ? (rain['3h'] as num).toDouble() : 0.0,
    );
  }

  // Helper method to get weather icon URL
  String getIconUrl() {
    if (icon.isEmpty) {
      // Return default icon URL if no icon available
      return 'https://openweathermap.org/img/wn/01d@2x.png';
    }
    return 'https://openweathermap.org/img/wn/$icon@2x.png';
  }

  // Helper to get temperature in Celsius
  String getTemperatureCelsius() {
    return '${temperature.toStringAsFixed(1)}°C';
  }

  // Get weather condition appropriate for farming
  String getFarmingCondition() {
    if (main == 'Rain' && rainAmount > 10) {
      return 'Heavy Rain - Not suitable for fieldwork';
    } else if (main == 'Rain') {
      return 'Light Rain - Limited fieldwork possible';
    } else if (temperature > 35) {
      return 'Very Hot - Ensure proper hydration, limit midday work';
    } else if (windSpeed > 10) {
      return 'Strong Winds - Caution with spraying activities';
    } else if (main == 'Clear' && temperature > 30) {
      return 'Hot & Clear - Good for drying harvests, ensure irrigation';
    } else if (main == 'Clouds') {
      return 'Cloudy - Good conditions for fieldwork';
    } else {
      return 'Favorable farming conditions';
    }
  }
}