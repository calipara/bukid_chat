import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date as yyyy-MM-dd
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format date as Month dd, yyyy
  static String formatReadableDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
  
  // Format date as MMM d, yyyy
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  // Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy h:mm a').format(date);
  }
  
  // Format time only
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  // Get the month name
  static String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(2022, month));
  }
  
  // Get the short month name
  static String getShortMonthName(int month) {
    return DateFormat('MMM').format(DateTime(2022, month));
  }
  
  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  // Format as 'Today' or date
  static String formatRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else {
      return formatShortDate(date);
    }
  }
  
  // Get days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
  
  // Format days remaining
  static String formatDaysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final days = daysBetween(now, targetDate);
    
    if (days < 0) {
      return 'Past due by ${days.abs()} days';
    } else if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else {
      return '$days days remaining';
    }
  }
  
  // Get first day of month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  // Get last day of month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  // Add months to date
  static DateTime addMonths(DateTime date, int months) {
    return DateTime(date.year, date.month + months, date.day);
  }
}