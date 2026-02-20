import '../models/data_file.dart';
import '../models/date_range.dart';
import '../models/data_column.dart';
import '../utils/date_parser.dart';

class DataController {
  /// Apply date range filter to data
  List<List<dynamic>> applyDateRange(
    DataFile dataFile,
    DateRange dateRange,
    String dateColumnName,
  ) {
    final dateColumnIndex = dataFile.getColumnIndex(dateColumnName);
    if (dateColumnIndex == -1) {
      return dataFile.rawData.skip(1).toList(); // Skip header
    }

    // Filter data by date range
    final filtered = dataFile.rawData.skip(1).where((row) {
      if (dateColumnIndex >= row.length) return false;
      
      final dateValue = row[dateColumnIndex]?.toString() ?? '';
      final parsedDate = DateParser.parseDate(dateValue);
      
      if (parsedDate == null) return false;

      return parsedDate.isAfter(dateRange.startDate.subtract(const Duration(days: 1))) &&
             parsedDate.isBefore(dateRange.endDate.add(const Duration(days: 1)));
    }).toList();

    return filtered;
  }

  /// Filter data by column values
  List<List<dynamic>> filterByColumn(
    List<List<dynamic>> data,
    DataFile dataFile,
    String columnName,
    dynamic filterValue,
  ) {
    final columnIndex = dataFile.getColumnIndex(columnName);
    if (columnIndex == -1) return data;

    return data.where((row) {
      if (columnIndex >= row.length) return false;
      return row[columnIndex] == filterValue;
    }).toList();
  }

  /// Search data for text
  List<List<dynamic>> searchData(
    List<List<dynamic>> data,
    String searchText,
  ) {
    if (searchText.isEmpty) return data;

    return data.where((row) {
      return row.any((cell) => 
        cell?.toString().toLowerCase().contains(searchText.toLowerCase()) ?? false
      );
    }).toList();
  }

  /// Get filtered data with all filters applied
  List<List<dynamic>> getFilteredData(
    DataFile dataFile, {
    DateRange? dateRange,
    String? dateColumnName,
    Map<String, dynamic>? columnFilters,
    String? searchText,
  }) {
    List<List<dynamic>> data = dataFile.rawData.skip(1).toList();

    // Apply date range filter
    if (dateRange != null && dateColumnName != null) {
      data = applyDateRange(dataFile, dateRange, dateColumnName);
    }

    // Apply column filters
    if (columnFilters != null) {
      for (var entry in columnFilters.entries) {
        data = filterByColumn(data, dataFile, entry.key, entry.value);
      }
    }

    // Apply search
    if (searchText != null && searchText.isNotEmpty) {
      data = searchData(data, searchText);
    }

    return data;
  }

  /// Detect date columns in the data file
  List<DataColumn> detectDateColumns(DataFile dataFile) {
    return dataFile.getDateColumns();
  }

  /// Group data by a column and aggregate another column
  Map<String, double> groupAndAggregate(
    List<List<dynamic>> data,
    DataFile dataFile,
    String groupByColumn,
    String aggregateColumn,
    {String aggregateType = 'sum'} // sum, avg, count
  ) {
    final groupIndex = dataFile.getColumnIndex(groupByColumn);
    
    // Special handling for Count (Frequency) mode
    if (aggregateColumn == '__COUNT__') {
      return _countByGroup(data, groupIndex);
    }
    
    final aggIndex = dataFile.getColumnIndex(aggregateColumn);

    if (groupIndex == -1 || aggIndex == -1) {
      return {};
    }

    Map<String, List<double>> grouped = {};

    for (var row in data) {
      if (groupIndex >= row.length || aggIndex >= row.length) continue;

      final groupValue = row[groupIndex]?.toString() ?? 'Unknown';
      final aggValue = double.tryParse(row[aggIndex]?.toString() ?? '0') ?? 0.0;

      grouped.putIfAbsent(groupValue, () => []);
      grouped[groupValue]!.add(aggValue);
    }

    // Aggregate
    Map<String, double> result = {};
    for (var entry in grouped.entries) {
      double value;
      if (aggregateType == 'avg') {
        value = entry.value.reduce((a, b) => a + b) / entry.value.length;
      } else if (aggregateType == 'count') {
        value = entry.value.length.toDouble();
      } else { // sum
        value = entry.value.reduce((a, b) => a + b);
      }
      result[entry.key] = value;
    }

    return result;
  }

  /// Count occurrences of each group (for frequency distribution)
  Map<String, double> _countByGroup(List<List<dynamic>> data, int groupIndex) {
    if (groupIndex == -1) return {};
    
    Map<String, int> counts = {};
    
    for (var row in data) {
      if (groupIndex >= row.length) continue;
      final groupValue = row[groupIndex]?.toString() ?? 'Unknown';
      counts[groupValue] = (counts[groupValue] ?? 0) + 1;
    }
    
    // Convert to double for consistency with other aggregations
    return counts.map((key, value) => MapEntry(key, value.toDouble()));
  }

  /// Get unique values for a column
  List<dynamic> getUniqueValues(DataFile dataFile, String columnName) {
    final columnIndex = dataFile.getColumnIndex(columnName);
    if (columnIndex == -1) return [];

    final values = dataFile.rawData.skip(1).map((row) {
      if (columnIndex >= row.length) return null;
      return row[columnIndex];
    }).where((val) => val != null).toSet().toList();

    return values;
  }

  /// Filter data to only include rows with specific X-axis values
  List<List<dynamic>> filterByXAxisValues(
    List<List<dynamic>> data,
    DataFile dataFile,
    String columnName,
    List<String> selectedValues,
  ) {
    if (selectedValues.isEmpty) return [];
    
    final columnIndex = dataFile.getColumnIndex(columnName);
    if (columnIndex == -1) return data;

    return data.where((row) {
      if (columnIndex >= row.length) return false;
      final value = row[columnIndex]?.toString() ?? '';
      return selectedValues.contains(value);
    }).toList();
  }
}