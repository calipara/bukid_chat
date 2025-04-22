import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/market_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/market_price_model.dart';
import '../../utils/formatter_utils.dart';
import '../../utils/date_utils.dart';

class MarketPriceScreen extends StatefulWidget {
  const MarketPriceScreen({Key? key}) : super(key: key);

  @override
  _MarketPriceScreenState createState() => _MarketPriceScreenState();
}

class _MarketPriceScreenState extends State<MarketPriceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLocation = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch market prices when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false).fetchMarketPrices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _getLocations(List<MarketPriceModel> prices) {
    final Set<String> locations = {'All'};
    for (var price in prices) {
      locations.add(price.location);
    }
    return locations.toList();
  }

  List<MarketPriceModel> _filterByLocation(List<MarketPriceModel> prices) {
    if (_selectedLocation == 'All') {
      return prices;
    }
    return prices.where((price) => price.location == _selectedLocation).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presyo sa Merkado'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lahat'),
            Tab(text: 'Mais'),
            Tab(text: 'Palay'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  Provider.of<MarketProvider>(context, listen: false)
                      .setSelectedCropType('All');
                  break;
                case 1:
                  Provider.of<MarketProvider>(context, listen: false)
                      .setSelectedCropType('Corn');
                  break;
                case 2:
                  Provider.of<MarketProvider>(context, listen: false)
                      .setSelectedCropType('Palay');
                  break;
              }
            });
          },
        ),
      ),
      body: Consumer<MarketProvider>(
        builder: (context, marketProvider, child) {
          if (marketProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (marketProvider.marketPrices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Market price data unavailable',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => marketProvider.fetchMarketPrices(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          // Get all available locations
          final locations = _getLocations(marketProvider.marketPrices);

          return Column(
            children: [
              // Location filter
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Lokasyon:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLocation,
                            isExpanded: true,
                            items: locations.map((location) {
                              return DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLocation = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => marketProvider.fetchMarketPrices(),
                      tooltip: 'Refresh prices',
                    ),
                  ],
                ),
              ),

              // Market price content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPriceList(marketProvider, 'All'),
                    _buildPriceList(marketProvider, 'Corn'),
                    _buildPriceList(marketProvider, 'Palay'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceList(MarketProvider marketProvider, String cropType) {
    // Get filtered data based on crop type and location
    final filteredData = _filterByLocation(
      cropType == 'All'
          ? marketProvider.marketPrices
          : marketProvider.marketPrices
              .where((price) => price.cropType == cropType)
              .toList(),
    );

    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          'No price data available for $cropType in $_selectedLocation',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price summary
          _buildPriceSummary(marketProvider, cropType),
          const SizedBox(height: 24),

          // Price chart
          if (cropType != 'All') _buildPriceChart(filteredData),
          if (cropType != 'All') const SizedBox(height: 24),

          // Market recommendation
          if (cropType != 'All') _buildMarketRecommendation(marketProvider, cropType),
          if (cropType != 'All') const SizedBox(height: 24),

          // Price list
          const Text(
            'Current Market Prices',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              return _buildPriceItem(filteredData[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(MarketProvider marketProvider, String cropType) {
    if (cropType == 'All') {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Avg: ${FormatterUtils.formatCurrency(marketProvider.getAveragePrice('Corn'))} / kg',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    _buildTrendIndicator(marketProvider.getPriceTrendRatio('Corn')),
                  ],
                ),
              ),
              Container(width: 1, height: 70, color: Colors.grey[300]),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Palay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Avg: ${FormatterUtils.formatCurrency(marketProvider.getAveragePrice('Palay'))} / kg',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    _buildTrendIndicator(marketProvider.getPriceTrendRatio('Palay')),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final highestPrice = marketProvider.getHighestPrice(cropType);
      final lowestPrice = marketProvider.getLowestPrice(cropType);
      final averagePrice = marketProvider.getAveragePrice(cropType);
      final trendRatio = marketProvider.getPriceTrendRatio(cropType);

      final color = cropType == 'Corn' ? Colors.amber[800]! : Colors.green[800]!;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cropType + ' Price Summary',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  _buildTrendIndicator(trendRatio, color: Colors.white),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPriceIndicator(
                    'High',
                    highestPrice != null
                        ? FormatterUtils.formatCurrency(highestPrice.pricePerKg)
                        : 'N/A',
                    highestPrice?.location ?? '',
                    Icons.arrow_upward,
                    Colors.white,
                  ),
                  _buildPriceIndicator(
                    'Low',
                    lowestPrice != null
                        ? FormatterUtils.formatCurrency(lowestPrice.pricePerKg)
                        : 'N/A',
                    lowestPrice?.location ?? '',
                    Icons.arrow_downward,
                    Colors.white,
                  ),
                  _buildPriceIndicator(
                    'Average',
                    FormatterUtils.formatCurrency(averagePrice),
                    'All Locations',
                    Icons.timeline,
                    Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildPriceChart(List<MarketPriceModel> prices) {
    // Sort prices by variety
    final sortedPrices = [...prices];
    sortedPrices.sort((a, b) => a.variety.compareTo(b.variety));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Comparison by Variety',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  minY: 0,
                  maxY: sortedPrices.map((p) => p.pricePerKg).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      // tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final price = sortedPrices[groupIndex];
                        return BarTooltipItem(
                          '${price.variety}\n${FormatterUtils.formatCurrency(price.pricePerKg)}/kg',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedPrices.length || value < 0) {
                            return const Text('');
                          }
                          // Abbreviate variety name to fit
                          final variety = sortedPrices[value.toInt()].variety;
                          final abbreviated = variety.length > 10
                              ? variety.substring(0, 8) + '...'
                              : variety;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              abbreviated,
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: sortedPrices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final price = entry.value;
                    
                    Color barColor;
                    if (price.trend == PriceTrend.up) {
                      barColor = Colors.green;
                    } else if (price.trend == PriceTrend.down) {
                      barColor = Colors.red;
                    } else {
                      barColor = Colors.orange;
                    }

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: price.pricePerKg,
                          color: barColor,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Rising', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Stable', Colors.orange),
                const SizedBox(width: 16),
                _buildLegendItem('Falling', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMarketRecommendation(MarketProvider marketProvider, String cropType) {
    return FutureBuilder<String>(
      future: marketProvider.getMarketRecommendation(cropType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recommendation = snapshot.data ?? 'No market recommendation available';

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Market Recommendation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  recommendation,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceItem(MarketPriceModel price) {
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
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crop type indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: price.cropType == 'Corn'
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    price.cropType == 'Corn' ? Icons.grass : Icons.grain,
                    color: price.cropType == 'Corn' ? Colors.amber[800] : Colors.green[800],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Crop details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.variety,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price.cropType,
                        style: TextStyle(
                          color: price.cropType == 'Corn'
                              ? Colors.amber[800]
                              : Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          trendIcon,
                          color: trendColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Location
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      price.location,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                // Date and source
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateTimeUtils.formatShortDate(price.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Source: ${price.source}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Per kilogram price
                Text(
                  'Per kg: ' + FormatterUtils.formatCurrency(price.pricePerKg),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                
                // Per cavan price
                Text(
                  'Per cavan: ' + FormatterUtils.formatCurrency(price.pricePerCavan),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(Map<String, int> trendRatio, {Color color = Colors.black}) {
    final up = trendRatio['up'] ?? 0;
    final down = trendRatio['down'] ?? 0;
    final stable = trendRatio['stable'] ?? 0;

    String trendText;
    IconData trendIcon;
    Color trendColor;

    if (up > down && up > stable) {
      trendText = 'Mostly Rising';
      trendIcon = Icons.trending_up;
      trendColor = Colors.green;
    } else if (down > up && down > stable) {
      trendText = 'Mostly Falling';
      trendIcon = Icons.trending_down;
      trendColor = Colors.red;
    } else {
      trendText = 'Mostly Stable';
      trendIcon = Icons.trending_flat;
      trendColor = Colors.orange;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trendIcon,
          color: color == Colors.white ? Colors.white : trendColor,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          trendText,
          style: TextStyle(
            color: color == Colors.white ? Colors.white : trendColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceIndicator(
    String label,
    String price,
    String location,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location,
          style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}