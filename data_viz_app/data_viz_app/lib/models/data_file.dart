import 'data_column.dart';

class DataFile {
  final String filename;
  final int fileSize;
  final DateTime uploadTimestamp;
  final List<List<dynamic>> rawData;
  final List<DataColumn> parsedColumns;

  DataFile({
    required this.filename,
    required this.fileSize,
    required this.uploadTimestamp,
    required this.rawData,
    required this.parsedColumns,
  });

  // Get column by name
  DataColumn? getColumnByName(String name) {
    try {
      return parsedColumns.firstWhere((col) => col.name == name);
    } catch (e) {
      return null;
    }
  }

  // Get all date columns
  List<DataColumn> getDateColumns() {
    return parsedColumns.where((col) => col.isDateColumn).toList();
  }

  // Get column index by name
  int getColumnIndex(String columnName) {
    for (int i = 0; i < parsedColumns.length; i++) {
      if (parsedColumns[i].name == columnName) {
        return i;
      }
    }
    return -1;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'fileSize': fileSize,
      'uploadTimestamp': uploadTimestamp.toIso8601String(),
      'rawData': rawData,
      'parsedColumns': parsedColumns.map((col) => col.toJson()).toList(),
    };
  }

  // Create from JSON
  factory DataFile.fromJson(Map<String, dynamic> json) {
    return DataFile(
      filename: json['filename'],
      fileSize: json['fileSize'],
      uploadTimestamp: DateTime.parse(json['uploadTimestamp']),
      rawData: (json['rawData'] as List)
          .map((row) => List<dynamic>.from(row))
          .toList(),
      parsedColumns: (json['parsedColumns'] as List)
          .map((col) => DataColumn.fromJson(col))
          .toList(),
    );
  }
}