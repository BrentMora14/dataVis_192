import 'dart:typed_data';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_pkg;
import '../models/data_file.dart';
import '../models/data_column.dart';
import '../utils/date_parser.dart';
import '../utils/file_validator.dart';

class FileController {
  /// Upload and parse a file with progress tracking
  Future<DataFile?> uploadFile(
    String filename,
    Uint8List bytes,
    {Function(double)? onProgress}
  ) async {
    // Validate file
    if (!FileValidator.validateFileExtension(filename)) {
      throw Exception('Invalid file type');
    }
    if (!FileValidator.validateFileSize(bytes.length)) {
      throw Exception('File too large');
    }

    onProgress?.call(0.0);

    // Parse based on extension
    final extension = FileValidator.getFileExtension(filename);
    
    List<List<dynamic>> rawData;
    if (extension == '.csv') {
      rawData = await parseCSVWithProgress(bytes, onProgress);
    } else if (extension == '.xlsx' || extension == '.xls') {
      rawData = await parseExcel(bytes);
      onProgress?.call(0.4);
    } else {
      throw Exception('Unsupported file type');
    }

    // Detect columns with progress
    final columns = await detectColumnsAsync(rawData, onProgress);

    onProgress?.call(1.0);

    return DataFile(
      filename: filename,
      fileSize: bytes.length,
      uploadTimestamp: DateTime.now(),
      rawData: rawData,
      parsedColumns: columns,
    );
  }

  /// Parse CSV file with progress updates
  Future<List<List<dynamic>>> parseCSVWithProgress(
    Uint8List bytes,
    Function(double)? onProgress,
  ) async {
    try {
      final String csvString = utf8.decode(bytes);
      
      // Parse CSV (this is still synchronous but fast)
      final List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      
      onProgress?.call(0.4);
      
      return rows;
    } catch (e) {
      throw Exception('Failed to parse CSV: $e');
    }
  }

  /// Parse CSV file (legacy method for backwards compatibility)
  Future<List<List<dynamic>>> parseCSV(Uint8List bytes) async {
    return parseCSVWithProgress(bytes, null);
  }

  /// Parse Excel file
  Future<List<List<dynamic>>> parseExcel(Uint8List bytes) async {
    try {
      final excelFile = excel_pkg.Excel.decodeBytes(bytes);
      
      // Get the first sheet
      final sheetName = excelFile.tables.keys.first;
      final sheet = excelFile.tables[sheetName];
      
      if (sheet == null) {
        throw Exception('No data found in Excel file');
      }

      List<List<dynamic>> rows = [];
      for (var row in sheet.rows) {
        rows.add(row.map((cell) => cell?.value).toList());
      }
      
      return rows;
    } catch (e) {
      throw Exception('Failed to parse Excel: $e');
    }
  }

  /// Detect column types with progress updates (async)
  Future<List<DataColumn>> detectColumnsAsync(
    List<List<dynamic>> rawData,
    Function(double)? onProgress,
  ) async {
    if (rawData.isEmpty) {
      return [];
    }

    // First row is headers
    final headers = rawData[0].map((h) => h?.toString() ?? '').toList();
    final dataRows = rawData.skip(1).toList();

    List<DataColumn> columns = [];

    for (int i = 0; i < headers.length; i++) {
      final columnName = headers[i];
      final columnData = dataRows.map((row) => 
        i < row.length ? row[i] : null
      ).where((val) => val != null).toList();

      // Get sample values
      final sampleValues = columnData.take(5).toList();

      // Detect type
      ColumnType type = _detectColumnType(columnData);
      bool isDate = type == ColumnType.date;

      columns.add(DataColumn(
        name: columnName,
        type: type,
        sampleValues: sampleValues,
        isDateColumn: isDate,
      ));

      // Update progress (40% to 100% range for column detection)
      final progress = 0.4 + (i / headers.length) * 0.6;
      onProgress?.call(progress);

      // Yield to UI thread every 10 columns to keep responsive
      if (i % 10 == 0 && i > 0) {
        await Future.delayed(const Duration(milliseconds: 1));
      }
    }

    return columns;
  }

  /// Detect column types from raw data (legacy synchronous method)
  List<DataColumn> detectColumns(List<List<dynamic>> rawData) {
    if (rawData.isEmpty) {
      return [];
    }

    // First row is headers
    final headers = rawData[0].map((h) => h?.toString() ?? '').toList();
    final dataRows = rawData.skip(1).toList();

    List<DataColumn> columns = [];

    for (int i = 0; i < headers.length; i++) {
      final columnName = headers[i];
      final columnData = dataRows.map((row) => 
        i < row.length ? row[i] : null
      ).where((val) => val != null).toList();

      // Get sample values
      final sampleValues = columnData.take(5).toList();

      // Detect type
      ColumnType type = _detectColumnType(columnData);
      bool isDate = type == ColumnType.date;

      columns.add(DataColumn(
        name: columnName,
        type: type,
        sampleValues: sampleValues,
        isDateColumn: isDate,
      ));
    }

    return columns;
  }

  /// Detect the type of a column based on its values
  ColumnType _detectColumnType(List<dynamic> values) {
    if (values.isEmpty) return ColumnType.text;

    int dateCount = 0;
    int numberCount = 0;
    int checkedCount = 0;

    // Sample up to 20 values for detection
    final sampleSize = values.length < 20 ? values.length : 20;

    for (var value in values.take(sampleSize)) {
      final strValue = value?.toString() ?? '';
      
      if (strValue.isEmpty) continue;
      
      checkedCount++;
      
      // Check if it's a date
      if (DateParser.looksLikeDate(strValue)) {
        dateCount++;
      }
      // Check if it's a number
      else if (double.tryParse(strValue) != null) {
        numberCount++;
      }
    }

    if (checkedCount == 0) return ColumnType.text;

    // Calculate percentages based on checked values
    final datePercent = dateCount / checkedCount;
    final numberPercent = numberCount / checkedCount;

    // If most values look like dates (70% threshold)
    if (datePercent >= 0.7) {
      return ColumnType.date;
    }
    // If most values are numbers (70% threshold)
    else if (numberPercent >= 0.7) {
      return ColumnType.number;
    }
    // Otherwise, text
    else {
      return ColumnType.text;
    }
  }

  /// Validate file type
  bool validateFileType(String filename) {
    return FileValidator.validateFileExtension(filename);
  }

  /// Validate file size
  bool validateFileSize(int size) {
    return FileValidator.validateFileSize(size);
  }
}