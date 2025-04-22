import 'package:intl/intl.dart';

class FormatterUtils {
  // Format currency with PHP symbol
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  // Format currency as integer (no decimal) with PHP symbol
  static String formatCurrencyInteger(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '₱',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
  
  // Format decimal number
  static String formatDecimal(double value, {int decimalPlaces = 2}) {
    final formatter = NumberFormat.decimalPattern();
    formatter.minimumFractionDigits = decimalPlaces;
    formatter.maximumFractionDigits = decimalPlaces;
    return formatter.format(value);
  }
  
  // Format area in hectares
  static String formatArea(double hectares) {
    if (hectares < 0.01) {
      // Convert to square meters for very small areas
      final sqm = hectares * 10000;
      return '${sqm.toStringAsFixed(0)} sq.m';
    } else {
      return '${hectares.toStringAsFixed(2)} ha';
    }
  }
  
  // Format weight in kilograms
  static String formatWeight(double kg) {
    if (kg >= 1000) {
      // Convert to metric tons for large weights
      final tons = kg / 1000;
      return '${tons.toStringAsFixed(2)} MT';
    } else {
      return '${kg.toStringAsFixed(1)} kg';
    }
  }
  
  // Format percentage
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.percentPattern();
    formatter.maximumFractionDigits = 1;
    return formatter.format(percentage / 100);
  }
  
  // Format compact number (e.g., 1.2k, 3.4M)
  static String formatCompactNumber(double number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }
  
  // Format phone number for Philippines
  static String formatPhilippinePhone(String phone) {
    if (phone.length != 10 && phone.length != 11) return phone;
    
    if (phone.length == 10) {
      // Format as 0XXX-XXX-XXXX
      return '0${phone.substring(0, 3)}-${phone.substring(3, 6)}-${phone.substring(6)}';
    } else {
      // Format as 0XXXX-XXX-XXXX
      return '${phone.substring(0, 4)}-${phone.substring(4, 7)}-${phone.substring(7)}';
    }
  }
  
  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} GB';
    }
  }
}