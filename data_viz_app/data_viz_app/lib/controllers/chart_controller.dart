import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/chart_config.dart';
import '../models/data_file.dart';
import 'data_controller.dart';

class ChartController {
  final DataController _dataController = DataController();

  /// Generate chart data based on configuration
  dynamic generateChart(ChartConfig config, DataFile dataFile) {
    // Get filtered data
    final filteredData = _dataController.getFilteredData(
      dataFile,
      dateRange: config.dateRange,
      dateColumnName: dataFile.getDateColumns().isNotEmpty 
          ? dataFile.getDateColumns().first.name 
          : null,
      columnFilters: config.appliedFilters,
    );

    switch (config.chartType) {
      case ChartType.bar:
        return _generateBarChartData(config, dataFile, filteredData);
      case ChartType.line:
        return _generateLineChartData(config, dataFile, filteredData);
      case ChartType.pie:
        return _generatePieChartData(config, dataFile, filteredData);
      case ChartType.scatter:
        return _generateScatterChartData(config, dataFile, filteredData);
      case ChartType.area:
        return _generateAreaChartData(config, dataFile, filteredData);
    }
  }

  /// Generate bar chart data
  BarChartData _generateBarChartData(
    ChartConfig config,
    DataFile dataFile,
    List<List<dynamic>> data,
  ) {
    final aggregated = _dataController.groupAndAggregate(
      data,
      dataFile,
      config.xAxisColumn,
      config.yAxisColumns.first,
      aggregateType: 'sum',
    );

    final barGroups = <BarChartGroupData>[];
    int index = 0;

    aggregated.forEach((key, value) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: config.colors[index % config.colors.length],
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    });

    return BarChartData(
      barGroups: barGroups,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final keys = aggregated.keys.toList();
              if (value.toInt() >= 0 && value.toInt() < keys.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      gridData: const FlGridData(show: true),
    );
  }

  /// Generate line chart data
  LineChartData _generateLineChartData(
    ChartConfig config,
    DataFile dataFile,
    List<List<dynamic>> data,
  ) {
    final aggregated = _dataController.groupAndAggregate(
      data,
      dataFile,
      config.xAxisColumn,
      config.yAxisColumns.first,
      aggregateType: 'sum',
    );

    final spots = <FlSpot>[];
    int index = 0;

    aggregated.forEach((key, value) {
      spots.add(FlSpot(index.toDouble(), value));
      index++;
    });

    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: config.colors.first,
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final keys = aggregated.keys.toList();
              if (value.toInt() >= 0 && value.toInt() < keys.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    keys[value.toInt()],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      gridData: const FlGridData(show: true),
    );
  }

  /// Generate pie chart data
  PieChartData _generatePieChartData(
    ChartConfig config,
    DataFile dataFile,
    List<List<dynamic>> data,
  ) {
    final aggregated = _dataController.groupAndAggregate(
      data,
      dataFile,
      config.xAxisColumn,
      config.yAxisColumns.first,
      aggregateType: 'sum',
    );

    final sections = <PieChartSectionData>[];
    int index = 0;
    final total = aggregated.values.reduce((a, b) => a + b);

    aggregated.forEach((key, value) {
      final percentage = (value / total * 100).toStringAsFixed(1);
      sections.add(
        PieChartSectionData(
          value: value,
          title: '$percentage%',
          color: config.colors[index % config.colors.length],
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });

    return PieChartData(
      sections: sections,
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }

  /// Generate scatter plot data
  ScatterChartData _generateScatterChartData(
    ChartConfig config,
    DataFile dataFile,
    List<List<dynamic>> data,
  ) {
    final xIndex = dataFile.getColumnIndex(config.xAxisColumn);
    final yIndex = dataFile.getColumnIndex(config.yAxisColumns.first);

    final spots = <ScatterSpot>[];

    for (var row in data) {
      if (xIndex >= row.length || yIndex >= row.length) continue;
      
      final x = double.tryParse(row[xIndex]?.toString() ?? '0') ?? 0.0;
      final y = double.tryParse(row[yIndex]?.toString() ?? '0') ?? 0.0;

      spots.add(ScatterSpot(x, y));
    }

    return ScatterChartData(
      scatterSpots: spots,
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true),
      gridData: const FlGridData(show: true),
    );
  }

  /// Generate area chart data
  LineChartData _generateAreaChartData(
    ChartConfig config,
    DataFile dataFile,
    List<List<dynamic>> data,
  ) {
    final lineData = _generateLineChartData(config, dataFile, data);
    
    // Convert to area chart by adding gradient
    return LineChartData(
      lineBarsData: lineData.lineBarsData.map((lineBar) {
        return LineChartBarData(
          spots: lineBar.spots,
          isCurved: lineBar.isCurved,
          color: lineBar.color,
          barWidth: lineBar.barWidth,
          dotData: lineBar.dotData,
          belowBarData: BarAreaData(
            show: true,
            color: (lineBar.color ?? Colors.blue).withOpacity(0.3),
          ),
        );
      }).toList(),
      titlesData: lineData.titlesData,
      borderData: lineData.borderData,
      gridData: lineData.gridData,
    );
  }

  /// Update chart type
  ChartConfig updateChartType(ChartConfig config, ChartType newType) {
    return config.copyWith(chartType: newType);
  }

  /// Apply chart configuration
  ChartConfig applyChartConfig(
    ChartConfig config, {
    String? xAxisColumn,
    List<String>? yAxisColumns,
    String? title,
  }) {
    return config.copyWith(
      xAxisColumn: xAxisColumn,
      yAxisColumns: yAxisColumns,
      title: title,
    );
  }
}