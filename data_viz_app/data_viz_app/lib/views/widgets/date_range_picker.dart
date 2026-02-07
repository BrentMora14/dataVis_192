import 'package:flutter/material.dart';
import '../../models/date_range.dart';
import '../../utils/date_parser.dart';

class DateRangePicker extends StatefulWidget {
  final DateRange? initialRange;
  final Function(DateRange) onRangeSelected;

  const DateRangePicker({
    super.key,
    this.initialRange,
    required this.onRangeSelected,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateRangePreset _selectedPreset = DateRangePreset.lastMonth;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null) {
      _selectedPreset = widget.initialRange!.presetType;
      _customStart = widget.initialRange!.startDate;
      _customEnd = widget.initialRange!.endDate;
    }
  }

  void _applyPreset(DateRangePreset preset) {
    setState(() {
      _selectedPreset = preset;
    });

    DateRange range;
    switch (preset) {
      case DateRangePreset.last7Days:
        range = DateRange.last7Days();
        break;
      case DateRangePreset.lastMonth:
        range = DateRange.lastMonth();
        break;
      case DateRangePreset.last3Months:
        range = DateRange.last3Months();
        break;
      case DateRangePreset.lastYear:
        range = DateRange.lastYear();
        break;
      case DateRangePreset.custom:
        return; // Don't apply until dates are selected
    }

    widget.onRangeSelected(range);
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _customStart = picked.start;
        _customEnd = picked.end;
        _selectedPreset = DateRangePreset.custom;
      });

      final range = DateRange.custom(picked.start, picked.end);
      widget.onRangeSelected(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPresetChip('Last 7 Days', DateRangePreset.last7Days),
                _buildPresetChip('Last Month', DateRangePreset.lastMonth),
                _buildPresetChip('Last 3 Months', DateRangePreset.last3Months),
                _buildPresetChip('Last Year', DateRangePreset.lastYear),
                _buildPresetChip('Custom', DateRangePreset.custom),
              ],
            ),
            if (_selectedPreset == DateRangePreset.custom) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _selectCustomRange,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _customStart != null && _customEnd != null
                      ? '${DateParser.formatDate(_customStart!)} - ${DateParser.formatDate(_customEnd!)}'
                      : 'Pick Custom Dates',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, DateRangePreset preset) {
    final isSelected = _selectedPreset == preset;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (preset == DateRangePreset.custom) {
          _selectCustomRange();
        } else {
          _applyPreset(preset);
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
    );
  }
}