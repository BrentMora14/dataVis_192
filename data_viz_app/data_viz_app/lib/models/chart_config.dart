import 'package:flutter/material.dart';
import 'date_range.dart';

enum ChartType {
  bar,
  line,
  pie,
  scatter,
  area,
}

class ChartConfig {
  final ChartType chartType;
  final String xAxisColumn;
  final List<String> yAxisColumns;
  final DateRange? dateRange;
  final Map<String, dynamic> appliedFilters;
  final List<Color> colors;
  final String title;

  ChartConfig({
    required this.chartType,
    required this.xAxisColumn,
    required this.yAxisColumns,
    this.dateRange,
    this.appliedFilters = const {},
    List<Color>? colors,
    this.title = '',
  }) : colors = colors ?? [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  ChartConfig copyWith({
    ChartType? chartType,
    String? xAxisColumn,
    List<String>? yAxisColumns,
    DateRange? dateRange,
    Map<String, dynamic>? appliedFilters,
    List<Color>? colors,
    String? title,
  }) {
    return ChartConfig(
      chartType: chartType ?? this.chartType,
      xAxisColumn: xAxisColumn ?? this.xAxisColumn,
      yAxisColumns: yAxisColumns ?? this.yAxisColumns,
      dateRange: dateRange ?? this.dateRange,
      appliedFilters: appliedFilters ?? this.appliedFilters,
      colors: colors ?? this.colors,
      title: title ?? this.title,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'chartType': chartType.toString(),
      'xAxisColumn': xAxisColumn,
      'yAxisColumns': yAxisColumns,
      'dateRange': dateRange?.toJson(),
      'appliedFilters': appliedFilters,
      'colors': colors.map((c) => c.value).toList(),
      'title': title,
    };
  }

  // Create from JSON
  factory ChartConfig.fromJson(Map<String, dynamic> json) {
    return ChartConfig(
      chartType: ChartType.values.firstWhere(
        (e) => e.toString() == json['chartType'],
      ),
      xAxisColumn: json['xAxisColumn'],
      yAxisColumns: List<String>.from(json['yAxisColumns']),
      dateRange: json['dateRange'] != null 
          ? DateRange.fromJson(json['dateRange'])
          : null,
      appliedFilters: Map<String, dynamic>.from(json['appliedFilters']),
      colors: (json['colors'] as List).map((c) => Color(c as int)).toList(),
      title: json['title'],
    );
  }

  String getChartTypeName() {
    switch (chartType) {
      case ChartType.bar:
        return 'Bar Chart';
      case ChartType.line:
        return 'Line Chart';
      case ChartType.pie:
        return 'Pie Chart';
      case ChartType.scatter:
        return 'Scatter Plot';
      case ChartType.area:
        return 'Area Chart';
    }
  }
}