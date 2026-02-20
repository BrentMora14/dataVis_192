import 'package:flutter/material.dart';
import '../../models/data_file.dart';
import '../../models/data_column.dart';

class ColumnSelector extends StatelessWidget {
  final DataFile dataFile;
  final String? selectedXColumn;
  final List<String> selectedYColumns;
  final Function(String) onXColumnSelected;
  final Function(List<String>) onYColumnsSelected;

  const ColumnSelector({
    super.key,
    required this.dataFile,
    this.selectedXColumn,
    this.selectedYColumns = const [],
    required this.onXColumnSelected,
    required this.onYColumnsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Columns',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // X-Axis Column Selector
            const Text('X-Axis (Category/Group):'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedXColumn,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select column',
              ),
              items: dataFile.parsedColumns.map((column) {
                return DropdownMenuItem(
                  value: column.name,
                  child: Text(
                    '${column.name} (${_getTypeLabel(column.type)})',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onXColumnSelected(value);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Y-Axis Column Selector
            const Text('Y-Axis (Values to aggregate):'),
            const SizedBox(height: 8),
            _buildYColumnSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildYColumnSelector() {
    final numericColumns = dataFile.parsedColumns
        .where((col) => col.type == ColumnType.number)
        .toList();

    // Build list of options: Count first, then numeric columns
    final options = <Widget>[];
    
    // Add Count (Frequency) option
    final isCountSelected = selectedYColumns.contains('__COUNT__');
    options.add(
      FilterChip(
        label: const Text('Count (Frequency)'),
        selected: isCountSelected,
        onSelected: (selected) {
          if (selected) {
            onYColumnsSelected(['__COUNT__']);
          } else {
            onYColumnsSelected([]);
          }
        },
      ),
    );
    
    // Add numeric columns
    options.addAll(
      numericColumns.map((column) {
        final isSelected = selectedYColumns.contains(column.name);
        return FilterChip(
          label: Text(column.name),
          selected: isSelected,
          onSelected: (selected) {
            List<String> newSelection = List.from(selectedYColumns);
            // Remove __COUNT__ if selecting a numeric column
            newSelection.remove('__COUNT__');
            
            if (selected) {
              if (!newSelection.contains(column.name)) {
                newSelection.add(column.name);
              }
            } else {
              newSelection.remove(column.name);
            }
            onYColumnsSelected(newSelection);
          },
        );
      }).toList(),
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options,
    );
  }

  String _getTypeLabel(ColumnType type) {
    switch (type) {
      case ColumnType.text:
        return 'Text';
      case ColumnType.number:
        return 'Number';
      case ColumnType.date:
        return 'Date';
    }
  }
}