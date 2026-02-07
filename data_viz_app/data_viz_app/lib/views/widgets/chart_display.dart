import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_config.dart';
import '../../models/data_file.dart';
import '../../controllers/chart_controller.dart';

class ChartDisplay extends StatelessWidget {
  final ChartConfig config;
  final DataFile dataFile;

  const ChartDisplay({
    super.key,
    required this.config,
    required this.dataFile,
  });

  @override
  Widget build(BuildContext context) {
    final chartController = ChartController();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (config.title.isNotEmpty) ...[
              Text(
                config.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 400,
              child: _buildChart(chartController),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ChartController controller) {
    try {
      final chartData = controller.generateChart(config, dataFile);

      switch (config.chartType) {
        case ChartType.bar:
          return BarChart(chartData as BarChartData);
        case ChartType.line:
        case ChartType.area:
          return LineChart(chartData as LineChartData);
        case ChartType.pie:
          return PieChart(chartData as PieChartData);
        case ChartType.scatter:
          return ScatterChart(chartData as ScatterChartData);
      }
    } catch (e) {
      return Center(
        child: Text(
          'Error generating chart: $e',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
  }

  Widget _buildLegend() {
    if (config.chartType == ChartType.pie) {
      // For pie charts, show category legend
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'X: ${config.xAxisColumn}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              Text(
                'Y: ${config.yAxisColumns.join(", ")}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}