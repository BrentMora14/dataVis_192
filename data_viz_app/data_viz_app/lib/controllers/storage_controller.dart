import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chart_config.dart';
import '../models/dashboard.dart';
import '../utils/constants.dart';

class StorageController {
  /// Save a visualization
  Future<bool> saveVisualization(String name, ChartConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visualizations = await listSavedVisualizations();
      
      visualizations[name] = config.toJson();
      
      return await prefs.setString(
        AppConstants.storageKeyVisualizations,
        jsonEncode(visualizations),
      );
    } catch (e) {
      print('Error saving visualization: $e');
      return false;
    }
  }

  /// Load a visualization
  Future<ChartConfig?> loadVisualization(String name) async {
    try {
      final visualizations = await listSavedVisualizations();
      
      if (visualizations.containsKey(name)) {
        return ChartConfig.fromJson(visualizations[name]);
      }
      return null;
    } catch (e) {
      print('Error loading visualization: $e');
      return null;
    }
  }

  /// List all saved visualizations
  Future<Map<String, dynamic>> listSavedVisualizations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.storageKeyVisualizations);
      
      if (jsonString != null) {
        return Map<String, dynamic>.from(jsonDecode(jsonString));
      }
      return {};
    } catch (e) {
      print('Error listing visualizations: $e');
      return {};
    }
  }

  /// Delete a visualization
  Future<bool> deleteVisualization(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visualizations = await listSavedVisualizations();
      
      visualizations.remove(name);
      
      return await prefs.setString(
        AppConstants.storageKeyVisualizations,
        jsonEncode(visualizations),
      );
    } catch (e) {
      print('Error deleting visualization: $e');
      return false;
    }
  }

  /// Save a dashboard
  Future<bool> saveDashboard(Dashboard dashboard) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dashboards = await listSavedDashboards();
      
      dashboards[dashboard.dashboardName] = dashboard.toJson();
      
      return await prefs.setString(
        AppConstants.storageKeyDashboards,
        jsonEncode(dashboards),
      );
    } catch (e) {
      print('Error saving dashboard: $e');
      return false;
    }
  }

  /// Load a dashboard
  Future<Dashboard?> loadDashboard(String name) async {
    try {
      final dashboards = await listSavedDashboards();
      
      if (dashboards.containsKey(name)) {
        return Dashboard.fromJson(dashboards[name]);
      }
      return null;
    } catch (e) {
      print('Error loading dashboard: $e');
      return null;
    }
  }

  /// List all saved dashboards
  Future<Map<String, dynamic>> listSavedDashboards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.storageKeyDashboards);
      
      if (jsonString != null) {
        return Map<String, dynamic>.from(jsonDecode(jsonString));
      }
      return {};
    } catch (e) {
      print('Error listing dashboards: $e');
      return {};
    }
  }

  /// Delete a dashboard
  Future<bool> deleteDashboard(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dashboards = await listSavedDashboards();
      
      dashboards.remove(name);
      
      return await prefs.setString(
        AppConstants.storageKeyDashboards,
        jsonEncode(dashboards),
      );
    } catch (e) {
      print('Error deleting dashboard: $e');
      return false;
    }
  }

  /// Clear all saved data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.storageKeyVisualizations);
      await prefs.remove(AppConstants.storageKeyDashboards);
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}