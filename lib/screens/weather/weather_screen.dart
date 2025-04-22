import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/weather_model.dart';
import '../../providers/weather_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showRecommendation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Refresh weather data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleRecommendation() {
    setState(() {
      _showRecommendation = !_showRecommendation;
    });
  }

  void _getAIRecommendations() {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final currentWeather = weatherProvider.currentWeather;
    
    if (currentWeather == null) return;
    
    // Navigate to the chat screen
    Navigator.pop(context);
    
    // Wait for navigation to complete before sending the message
    Future.delayed(Duration(milliseconds: 300), () {
      // Get weather description
      final weatherCondition = weatherProvider.getCurrentWeatherDescription() + 
                             ' at ' + weatherProvider.getCurrentTemperature() + 
                             ', humidity ${currentWeather.humidity}%, ' +
                             'wind speed ${currentWeather.windSpeed} km/h';
      
      // Request farming recommendations based on current weather
      chatProvider.getFarmingRecommendations(
        'Corn and Rice',
        weatherCondition,
        weatherProvider.location,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forecast ng Panahon'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ngayon'),
            Tab(text: '5-Araw na Forecast'),
          ],
        ),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.currentWeather == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Walang available na data ng panahon',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => weatherProvider.fetchWeatherData(),
                    child: const Text('I-refresh'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodayWeather(weatherProvider),
              _buildForecastWeather(weatherProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayWeather(WeatherProvider weatherProvider) {
    final currentWeather = weatherProvider.currentWeather!;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and date
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(
                weatherProvider.location,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Text(
                DateTimeUtils.formatReadableDate(DateTime.now()),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Current weather card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weatherProvider.getCurrentTemperature(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weatherProvider.getCurrentWeatherDescription(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Feels like ${currentWeather.feelsLike.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Image.network(
                        currentWeather.getIconUrl(),
                        width: 90,
                        height: 90,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.cloud,
                          size: 90,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherDetail(
                        'Humidity',
                        '${currentWeather.humidity}%',
                        Icons.water_drop_outlined,
                      ),
                      _buildWeatherDetail(
                        'Wind',
                        '${currentWeather.windSpeed} km/h',
                        Icons.air,
                      ),
                      _buildWeatherDetail(
                        'Pressure',
                        '${currentWeather.pressure} hPa',
                        Icons.compress,
                      ),
                    ],
                  ),
                  if (currentWeather.rainAmount > 0) ...[  
                    const SizedBox(height: 16),
                    _buildWeatherDetail(
                      'Rainfall',
                      '${currentWeather.rainAmount} mm',
                      Icons.umbrella,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Farming conditions
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.agriculture,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Kondisyon para sa Pagsasaka',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(_showRecommendation
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                        onPressed: _toggleRecommendation,
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade300),
                  Text(
                    weatherProvider.getFarmingCondition(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_showRecommendation) ...[  
                    const SizedBox(height: 16),
                    const Text(
                      'Activity Recommendations:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildActivitySuitabilityIndicator(
                      'Pagtatanim',
                      weatherProvider.isSuitableForPlanting(),
                    ),
                    const SizedBox(height: 8),
                    _buildActivitySuitabilityIndicator(
                      'Harvesting',
                      weatherProvider.isSuitableForHarvesting(),
                    ),
                    const SizedBox(height: 8),
                    _buildActivitySuitabilityIndicator(
                      'Paglalagay ng Pesticide',
                      weatherProvider.isSuitableForPesticides(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _getAIRecommendations,
                        icon: const Icon(Icons.psychology),
                        label: const Text('Get AI Recommendations'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // High and low temperatures
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temperature Range',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'High',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentWeather.tempMax.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Low',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentWeather.tempMin.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildForecastWeather(WeatherProvider weatherProvider) {
    final forecast = weatherProvider.weatherForecasts;

    if (forecast.isEmpty) {
      return const Center(child: Text('No forecast data available'));
    }

    // Extract temperature data for chart
    final tempData = forecast.take(5).map((weather) {
      return FlSpot(
        forecast.indexOf(weather).toDouble(),
        weather.temperature,
      );
    }).toList();

    // Extract humidity data for chart
    final humidityData = forecast.take(5).map((weather) {
      return FlSpot(
        forecast.indexOf(weather).toDouble(),
        weather.humidity.toDouble(),
      );
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Temperature chart
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Temperature Forecast (°C)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: LineChart(
                      LineChartData(
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
                                if (value.toInt() >= forecast.length || value < 0) {
                                  return const Text('');
                                }
                                final date = forecast[value.toInt()].timestamp;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateTimeUtils.getShortMonthName(date.month) + ' ' + date.day.toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: tempData,
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor.withOpacity(0.2),
                            ),
                          ),
                        ],
                        minY: forecast.map((w) => w.temperature).reduce((a, b) => a < b ? a : b) - 5,
                        maxY: forecast.map((w) => w.temperature).reduce((a, b) => a > b ? a : b) + 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Humidity chart
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Humidity Forecast (%)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: LineChart(
                      LineChartData(
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
                                if (value.toInt() >= forecast.length || value < 0) {
                                  return const Text('');
                                }
                                final date = forecast[value.toInt()].timestamp;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    DateTimeUtils.getShortMonthName(date.month) + ' ' + date.day.toString(),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: humidityData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                        ],
                        minY: 0,
                        maxY: 100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Daily forecast list
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Forecast',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...forecast.take(5).map((weather) => _buildDailyForecastItem(weather)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActivitySuitabilityIndicator(String activity, bool suitable) {
    return Row(
      children: [
        Icon(
          suitable ? Icons.check_circle : Icons.cancel,
          color: suitable ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          activity,
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        Text(
          suitable ? 'Suitable' : 'Not Recommended',
          style: TextStyle(
            color: suitable ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecastItem(WeatherModel weather) {
    final isToday = DateTimeUtils.isToday(weather.timestamp);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : DateTimeUtils.getShortMonthName(weather.timestamp.month) + ' ' + weather.timestamp.day.toString(),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                if (!isToday)
                  Text(
                    DateTimeUtils.formatTime(weather.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          
          // Weather icon
          Image.network(
            weather.getIconUrl(),
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.cloud,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          
          // Weather condition
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather.main,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  weather.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // Temperature
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weather.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Feels like ${weather.feelsLike.toStringAsFixed(1)}°C',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}