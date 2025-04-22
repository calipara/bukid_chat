import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class ApiConfigScreen extends StatefulWidget {
  const ApiConfigScreen({Key? key}) : super(key: key);

  @override
  _ApiConfigScreenState createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _openAiController = TextEditingController();
  final _weatherApiController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _weatherApiController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _openAiController.text = prefs.getString('openai_api_key') ?? '';
      _weatherApiController.text = prefs.getString('weather_api_key') ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveApiKeys() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', _openAiController.text.trim());
      await prefs.setString('weather_api_key', _weatherApiController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API keys saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving API keys: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Configuration'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configure API Keys',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'These API keys are used for weather forecasts and AI assistant features.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    _buildApiKeyCard(
                      'OpenAI API Key',
                      'Used for the farm assistant chatbot',
                      Icons.psychology,
                      Colors.purple,
                      _openAiController,
                      'Enter OpenAI API key',
                    ),
                    const SizedBox(height: 24.0),
                    _buildApiKeyCard(
                      'Weather API Key',
                      'Used for weather forecasts (OpenWeatherMap)',
                      Icons.cloud,
                      Colors.blue,
                      _weatherApiController,
                      'Enter Weather API key',
                    ),
                    const SizedBox(height: 40.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: _isSaving ? null : _saveApiKeys,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : const Text(
                                'SAVE CHANGES',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    const SizedBox(height: 16.0),
                    _buildApiKeyInstructions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildApiKeyCard(
    String title,
    String description,
    IconData icon,
    Color color,
    TextEditingController controller,
    String hint,
  ) {
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
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: hint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data != null && data.text != null) {
                      controller.text = data.text!;
                    }
                  },
                  tooltip: 'Paste from clipboard',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the API key';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How to get API Keys',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        _buildInstructionStep(
          '1. OpenAI API Key',
          'Go to OpenAI website (https://platform.openai.com) and create an account. Navigate to API keys section and generate a new key.',
          Icons.key,
        ),
        _buildInstructionStep(
          '2. Weather API Key',
          'Visit OpenWeatherMap (https://openweathermap.org) and register for a free account. Generate an API key from your account dashboard.',
          Icons.key,
        ),
        _buildInstructionStep(
          '3. App Configuration',
          'After saving, restart the app for changes to take effect. The keys are stored securely on the device.',
          Icons.settings,
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}