enum ColumnType {
  text,
  number,
  date,
}

class DataColumn {
  final String name;
  final ColumnType type;
  final List<dynamic> sampleValues;
  final bool isDateColumn;

  DataColumn({
    required this.name,
    required this.type,
    required this.sampleValues,
    required this.isDateColumn,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString(),
      'sampleValues': sampleValues,
      'isDateColumn': isDateColumn,
    };
  }

  // Create from JSON
  factory DataColumn.fromJson(Map<String, dynamic> json) {
    return DataColumn(
      name: json['name'],
      type: ColumnType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      sampleValues: List<dynamic>.from(json['sampleValues']),
      isDateColumn: json['isDateColumn'],
    );
  }
}