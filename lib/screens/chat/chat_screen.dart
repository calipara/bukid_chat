import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/chat_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/farm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../image_upload.dart';


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = true;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Display welcome message if chat is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (chatProvider.messages.isEmpty) {
        _showWelcomeMessage();
      }
    });
  }

  void _showWelcomeMessage() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(
      "Kumusta! Ako ang iyong katulong sa pagsasaka. Magtanong ka tungkol sa pagtatanim ng palay at mais, o magpadala ng larawan kung kailangan mo ng tulong sa pagtukoy ng mga peste o sakit ng tanim."
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _messageController.clear();
    _showSuggestions = false;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Send message to provider
    await chatProvider.sendMessage(message);

    // Scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 100),
      _scrollToBottom,
    );
  }

  void _getWeatherRecommendations() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    String cropType = 'Corn and Rice';
    String location = 'Philippines';

    // Get crop type from selected farm if available
    if (farmProvider.selectedFarm != null) {
      cropType = farmProvider.selectedFarm!.crops.join(' and ');
      location = farmProvider.selectedFarm!.location;
    }

    // Get weather conditions
    String weatherCondition = 'Unknown weather conditions';
    if (weatherProvider.currentWeather != null) {
      weatherCondition = '${weatherProvider.getCurrentWeatherDescription()} at ${weatherProvider.getCurrentTemperature()}, ';
      weatherCondition += 'humidity ${weatherProvider.currentWeather!.humidity}%, ';
      weatherCondition += 'wind speed ${weatherProvider.currentWeather!.windSpeed} km/h';
    }

    _showSuggestions = false;

    // Get recommendations
    await chatProvider.getFarmingRecommendations(
      cropType,
      weatherCondition,
      location,
    );

    // Scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 100),
      _scrollToBottom,
    );
  }

  void _takePicture() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    Uint8List? imageData = await ImageUploadHelper.captureImage();

    if (imageData != null) {
      // Show dialog to ask what to analyze
      _showImageQuestionDialog(imageData);
    }
  }

  void _pickImage() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    Uint8List? imageData = await ImageUploadHelper.pickImageFromGallery();

    if (imageData != null) {
      // Show dialog to ask what to analyze
      _showImageQuestionDialog(imageData);
    }
  }

  void _showImageQuestionDialog(Uint8List imageData) {
    final questionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What would you like to know?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.memory(
                imageData,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                hintText: 'e.g., What disease is this? Or leave empty',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kanselahin'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _analyzeImage(imageData, questionController.text);
            },
            child: const Text('Analyze Image'),
          ),
        ],
      ),
    );
  }

  void _analyzeImage(Uint8List imageData, String question) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _showSuggestions = false;

    // Send image for analysis
    await chatProvider.sendImageForAnalysis(imageData, question);

    // Scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 100),
      _scrollToBottom,
    );
  }

  void _useSuggestedQuestion(String question) {
    _messageController.text = question;
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katulong sa Pagsasaka'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Burahin ang Chat'),
                  content: const Text('Sigurado ka bang gusto mong burahin ang chat history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Huwag Muna'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<ChatProvider>(context, listen: false).clearChat();
                        Navigator.pop(context);
                        _showWelcomeMessage();
                      },
                      child: const Text('Burahin'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://pixabay.com/get/g099d58468d755bdba899c35a8414536612de4917ad7f085176e9c470a06dc20a0c7a1048e26446ea46a8cb902ef62316a299335bb68573627873980c5974685c_1280.jpg",
                  ),
                  fit: BoxFit.cover,
                  opacity: 0.1,
                ),
              ),
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (chatProvider.messages.isNotEmpty) {
                      _scrollToBottom();
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),
          ),
          _buildSuggestedQuestions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  color: AppTheme.primaryColor,
                  onPressed: chatProvider.isLoading ? null : _takePicture,
                  tooltip: 'Take a picture',
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  color: AppTheme.secondaryColor,
                  onPressed: chatProvider.isLoading ? null : _pickImage,
                  tooltip: 'Choose from gallery',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: 'Magtanong tungkol sa pagsasaka...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cloud_queue),
                        color: AppTheme.primaryColor,
                        onPressed: chatProvider.isLoading
                            ? null
                            : _getWeatherRecommendations,
                        tooltip: 'Get weather-based recommendations',
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    enabled: !chatProvider.isLoading,
                    onChanged: (value) {
                      if (value.isNotEmpty && _showSuggestions) {
                        setState(() {
                          _showSuggestions = false;
                        });
                      } else if (value.isEmpty && !_showSuggestions) {
                        setState(() {
                          _showSuggestions = true;
                        });
                      }
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty && !chatProvider.isLoading) {
                        _sendMessage();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.accentColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: IconButton(
                    icon: chatProvider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: chatProvider.isLoading
                        ? null
                        : _messageController.text.trim().isNotEmpty
                            ? _sendMessage
                            : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.agriculture,
                color: Colors.white,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageData != null)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          message.imageData!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateTimeUtils.formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final List<String> suggestions = [
      'Paano ihanda ang lupa para sa pagtatanim ng palay?',
      'Kailan ang pinakamabuting panahon para magtanim ng mais?',
      'Paano matukoy ang mga karaniwang peste ng palay?',
      'Anong abono ang pinakamabisa sa mais?',
      'Paano mapapataas ang ani ng palay?',
      'Ano ang mga sintomas ng sakit ng mais?',
    ];

    if (!_showSuggestions) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Mga Mungkahing Tanong',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () => _useSuggestedQuestion(suggestions[index]),
                    child: Chip(
                      label: Text(suggestions[index]),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                      labelStyle: TextStyle(color: AppTheme.primaryColor),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}