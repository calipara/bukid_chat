import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'market_price_admin_screen.dart';
import 'api_config_screen.dart';
import 'news_admin_screen.dart';
import 'planting_tips_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Admin',
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Manage app content and configurations',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32.0),
            const Text(
              'Content Management',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildAdminCard(
                    context,
                    'Market Prices',
                    Icons.trending_up,
                    Colors.orange,
                    'Manage and update market prices for crops',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MarketPriceAdminScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildAdminCard(
                    context,
                    'News',
                    Icons.newspaper,
                    Colors.blue,
                    'Manage agriculture news and updates',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewsAdminScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: _buildAdminCard(
                    context,
                    'Planting Tips',
                    Icons.eco,
                    Colors.green,
                    'Manage planting advice and tips',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlantingTipsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: _buildAdminCard(
                    context,
                    'API Configuration',
                    Icons.settings,
                    Colors.purple,
                    'Configure API keys for OpenAI, Weather, etc.',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ApiConfigScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            const Text(
              'System Statistics',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildStatsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Manage',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Active Users', '245', Icons.person, Colors.blue),
                ),
                Expanded(
                  child: _buildStatItem('Farms Registered', '189', Icons.landscape, Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Market Updates', '52', Icons.show_chart, Colors.orange),
                ),
                Expanded(
                  child: _buildStatItem('News Posted', '73', Icons.article, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}