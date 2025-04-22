import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../services/openai_service.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final Uint8List? imageData; // Optional image attachment

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.imageData,
  });
}

class ChatProvider with ChangeNotifier {
  final OpenAIService _openAIService = OpenAIService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Send a text message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    
    // Set loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get response from OpenAI
      final response = await _openAIService.askFarmingQuestion(message);
      
      // Add bot response
      final botMessage = ChatMessage(
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      _errorMessage = 'Failed to get response: $e';
      
      // Add error message from bot
      final errorMessage = ChatMessage(
        message: 'Sorry, I couldn\'t process your message right now. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send an image with optional message for analysis
  Future<void> sendImageForAnalysis(Uint8List imageData, String message) async {
    // Add user message with image
    final userMessage = ChatMessage(
      message: message.isEmpty ? 'What is wrong with this plant?' : message,
      isUser: true,
      timestamp: DateTime.now(),
      imageData: imageData,
    );
    _messages.add(userMessage);
    
    // Set loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get image analysis from OpenAI
      final response = await _openAIService.analyzeCropImage(imageData, message);
      
      // Add bot response
      final botMessage = ChatMessage(
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      _errorMessage = 'Failed to analyze image: $e';
      
      // Add error message from bot
      final errorMessage = ChatMessage(
        message: 'Sorry, I couldn\'t analyze the image right now. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get farming recommendations based on weather
  Future<void> getFarmingRecommendations(
    String cropType,
    String weatherCondition,
    String location,
  ) async {
    // Construct a context message
    final contextMsg = 'Please give me farming recommendations for $cropType in $location with the following weather conditions: $weatherCondition';
    
    // Add user message
    final userMessage = ChatMessage(
      message: contextMsg,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    
    // Set loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get recommendations from OpenAI
      final response = await _openAIService.getFarmingRecommendations(
        cropType,
        weatherCondition,
        location,
      );
      
      // Add bot response
      final botMessage = ChatMessage(
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      _errorMessage = 'Failed to get recommendations: $e';
      
      // Add error message from bot
      final errorMessage = ChatMessage(
        message: 'Sorry, I couldn\'t provide recommendations right now. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get financial advice
  Future<void> getFinancialAdvice(
    String cropType,
    double expenses,
    double revenue,
    double area,
  ) async {
    // Construct a context message
    final contextMsg = 'I need financial advice for my $cropType farm. ' +
                      'Area: ${area.toStringAsFixed(2)} hectares, ' +
                      'Expenses: u20b1${expenses.toStringAsFixed(2)}, ' +
                      'Revenue: u20b1${revenue.toStringAsFixed(2)}';
    
    // Add user message
    final userMessage = ChatMessage(
      message: contextMsg,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    
    // Set loading state
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Get advice from OpenAI
      final response = await _openAIService.getFinancialAdvice(
        cropType,
        expenses,
        revenue,
        area,
      );
      
      // Add bot response
      final botMessage = ChatMessage(
        message: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMessage);
    } catch (e) {
      _errorMessage = 'Failed to get financial advice: $e';
      
      // Add error message from bot
      final errorMessage = ChatMessage(
        message: 'Sorry, I couldn\'t provide financial advice right now. Please try again later.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear chat history
  void clearChat() {
    _messages = [];
    notifyListeners();
  }
}