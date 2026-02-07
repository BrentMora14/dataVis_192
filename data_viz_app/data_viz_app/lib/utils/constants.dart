import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Data Visualizer';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFFF44336), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
  ];

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double borderRadiusS = 4.0;
  static const double borderRadiusM = 8.0;
  static const double borderRadiusL = 12.0;

  // File Upload
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const int previewRowLimit = 20;

  // Storage Keys
  static const String storageKeyVisualizations = 'saved_visualizations';
  static const String storageKeyDashboards = 'saved_dashboards';

  // Chart Settings
  static const int maxDataPoints = 10000;
  static const double chartHeight = 400.0;
  static const double chartWidth = 600.0;
}