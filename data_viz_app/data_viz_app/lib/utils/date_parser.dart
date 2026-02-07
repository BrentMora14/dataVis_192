import 'package:intl/intl.dart';

class DateParser {
  // Common date formats to try
  static final List<DateFormat> _formats = [
    DateFormat('yyyy-MM-dd'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('yyyy/MM/dd'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('MM-dd-yyyy'),
    DateFormat('yyyy-MM-dd HH:mm:ss'),
    DateFormat('MM/dd/yyyy HH:mm:ss'),
    DateFormat('dd/MM/yyyy HH:mm:ss'),
    DateFormat('yyyy-MM-ddTHH:mm:ss'),
    DateFormat('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
  ];

  /// Attempts to parse a date string using various formats
  static DateTime? parseDate(String dateString) {
    if (dateString.isEmpty) return null;

    // Try each format
    for (var format in _formats) {
      try {
        return format.parse(dateString);
      } catch (e) {
        // Continue to next format
      }
    }

    // Try parsing as ISO 8601
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Not a valid date
    }

    return null;
  }

  /// Check if a string looks like a date
  static bool looksLikeDate(String value) {
    return parseDate(value) != null;
  }

  /// Format a DateTime for display
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format a DateTime with time for display
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}