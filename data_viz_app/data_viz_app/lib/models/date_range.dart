enum DateRangePreset {
  custom,
  last7Days,
  lastMonth,
  last3Months,
  lastYear,
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;
  final DateRangePreset presetType;

  DateRange({
    required this.startDate,
    required this.endDate,
    required this.presetType,
  });

  // Factory constructors for presets
  factory DateRange.last7Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    return DateRange(
      startDate: start,
      endDate: end,
      presetType: DateRangePreset.last7Days,
    );
  }

  factory DateRange.lastMonth() {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - 1, end.day);
    return DateRange(
      startDate: start,
      endDate: end,
      presetType: DateRangePreset.lastMonth,
    );
  }

  factory DateRange.last3Months() {
    final end = DateTime.now();
    final start = DateTime(end.year, end.month - 3, end.day);
    return DateRange(
      startDate: start,
      endDate: end,
      presetType: DateRangePreset.last3Months,
    );
  }

  factory DateRange.lastYear() {
    final end = DateTime.now();
    final start = DateTime(end.year - 1, end.month, end.day);
    return DateRange(
      startDate: start,
      endDate: end,
      presetType: DateRangePreset.lastYear,
    );
  }

  factory DateRange.custom(DateTime start, DateTime end) {
    return DateRange(
      startDate: start,
      endDate: end,
      presetType: DateRangePreset.custom,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'presetType': presetType.toString(),
    };
  }

  // Create from JSON
  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      presetType: DateRangePreset.values.firstWhere(
        (e) => e.toString() == json['presetType'],
      ),
    );
  }

  String getDisplayName() {
    switch (presetType) {
      case DateRangePreset.last7Days:
        return 'Last 7 Days';
      case DateRangePreset.lastMonth:
        return 'Last Month';
      case DateRangePreset.last3Months:
        return 'Last 3 Months';
      case DateRangePreset.lastYear:
        return 'Last Year';
      case DateRangePreset.custom:
        return 'Custom Range';
    }
  }
}