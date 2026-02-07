import '../models/dashboard.dart';
import '../models/chart_config.dart';

class DashboardController {
  /// Create a new dashboard
  Dashboard createDashboard(String name) {
    return Dashboard(
      dashboardName: name,
      charts: [],
      layoutGrid: {},
      createdDate: DateTime.now(),
    );
  }

  /// Add a chart to dashboard
  Dashboard addChart(Dashboard dashboard, ChartConfig chart) {
    final updatedCharts = List<ChartConfig>.from(dashboard.charts)..add(chart);
    
    // Auto-generate layout for the new chart
    final newLayout = Map<String, Map<String, double>>.from(dashboard.layoutGrid);
    final chartIndex = updatedCharts.length - 1;
    
    newLayout['chart_$chartIndex'] = {
      'x': (chartIndex % 2) * 50.0, // 2 columns
      'y': (chartIndex ~/ 2) * 50.0,
      'width': 50.0,
      'height': 50.0,
    };

    return Dashboard(
      dashboardName: dashboard.dashboardName,
      charts: updatedCharts,
      layoutGrid: newLayout,
      createdDate: dashboard.createdDate,
    );
  }

  /// Remove a chart from dashboard
  Dashboard removeChart(Dashboard dashboard, int chartIndex) {
    if (chartIndex < 0 || chartIndex >= dashboard.charts.length) {
      return dashboard;
    }

    final updatedCharts = List<ChartConfig>.from(dashboard.charts);
    updatedCharts.removeAt(chartIndex);

    // Remove from layout
    final newLayout = Map<String, Map<String, double>>.from(dashboard.layoutGrid);
    newLayout.remove('chart_$chartIndex');

    return Dashboard(
      dashboardName: dashboard.dashboardName,
      charts: updatedCharts,
      layoutGrid: newLayout,
      createdDate: dashboard.createdDate,
    );
  }

  /// Update layout of a chart
  Dashboard updateLayout(
    Dashboard dashboard,
    int chartIndex,
    double x,
    double y,
    double width,
    double height,
  ) {
    if (chartIndex < 0 || chartIndex >= dashboard.charts.length) {
      return dashboard;
    }

    final newLayout = Map<String, Map<String, double>>.from(dashboard.layoutGrid);
    newLayout['chart_$chartIndex'] = {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };

    return Dashboard(
      dashboardName: dashboard.dashboardName,
      charts: dashboard.charts,
      layoutGrid: newLayout,
      createdDate: dashboard.createdDate,
    );
  }

  /// Update dashboard name
  Dashboard updateDashboardName(Dashboard dashboard, String newName) {
    return Dashboard(
      dashboardName: newName,
      charts: dashboard.charts,
      layoutGrid: dashboard.layoutGrid,
      createdDate: dashboard.createdDate,
    );
  }

  /// Get chart count
  int getChartCount(Dashboard dashboard) {
    return dashboard.charts.length;
  }

  /// Validate dashboard
  bool validateDashboard(Dashboard dashboard) {
    // Check if dashboard has a name
    if (dashboard.dashboardName.isEmpty) {
      return false;
    }

    // Check if all charts in layout exist
    for (var key in dashboard.layoutGrid.keys) {
      final index = int.tryParse(key.replaceAll('chart_', ''));
      if (index == null || index >= dashboard.charts.length) {
        return false;
      }
    }

    return true;
  }
}