import 'chart_config.dart';

class Dashboard {
  final String dashboardName;
  final List<ChartConfig> charts;
  final Map<String, Map<String, double>> layoutGrid;
  final DateTime createdDate;

  Dashboard({
    required this.dashboardName,
    required this.charts,
    required this.layoutGrid,
    required this.createdDate,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dashboardName': dashboardName,
      'charts': charts.map((chart) => chart.toJson()).toList(),
      'layoutGrid': layoutGrid,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  // Create from JSON
  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      dashboardName: json['dashboardName'],
      charts: (json['charts'] as List)
          .map((chart) => ChartConfig.fromJson(chart))
          .toList(),
      layoutGrid: Map<String, Map<String, double>>.from(
        (json['layoutGrid'] as Map).map(
          (key, value) => MapEntry(key, Map<String, double>.from(value)),
        ),
      ),
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}