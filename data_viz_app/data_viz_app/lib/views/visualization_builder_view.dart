import 'package:flutter/material.dart';
import '../models/data_file.dart';
import '../models/chart_config.dart';
import '../models/date_range.dart';
import '../controllers/storage_controller.dart';
import 'widgets/date_range_picker.dart';
import 'widgets/column_selector.dart';
import 'widgets/chart_display.dart';

class VisualizationBuilderView extends StatefulWidget {
  final DataFile dataFile;

  const VisualizationBuilderView({
    super.key,
    required this.dataFile,
  });

  @override
  State<VisualizationBuilderView> createState() =>
      _VisualizationBuilderViewState();
}

class _VisualizationBuilderViewState extends State<VisualizationBuilderView> {
  final StorageController _storageController = StorageController();
  
  DateRange? _selectedDateRange;
  String? _selectedXColumn;
  List<String> _selectedYColumns = [];
  ChartType _selectedChartType = ChartType.bar;
  String _chartTitle = '';
  ChartConfig? _currentConfig;

  @override
  void initState() {
    super.initState();
    // Set default date range
    if (widget.dataFile.getDateColumns().isNotEmpty) {
      _selectedDateRange = DateRange.lastMonth();
    }
  }

  void _generateChart() {
    if (_selectedXColumn == null || _selectedYColumns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select columns for visualization')),
      );
      return;
    }

    setState(() {
      _currentConfig = ChartConfig(
        chartType: _selectedChartType,
        xAxisColumn: _selectedXColumn!,
        yAxisColumns: _selectedYColumns,
        dateRange: _selectedDateRange,
        title: _chartTitle,
      );
    });
  }

  Future<void> _saveVisualization() async {
    if (_currentConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No chart to save')),
      );
      return;
    }

    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Visualization'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Visualization Name',
            hintText: 'Enter a name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final success = await _storageController.saveVisualization(
        name,
        _currentConfig!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Visualization saved successfully'
                : 'Failed to save visualization'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Visualization'),
        actions: [
          if (_currentConfig != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveVisualization,
              tooltip: 'Save Visualization',
            ),
        ],
      ),
      body: Row(
        children: [
          // Left Panel - Configuration
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chart Title
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Chart Title (optional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _chartTitle = value;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date Range Picker
                  if (widget.dataFile.getDateColumns().isNotEmpty)
                    DateRangePicker(
                      initialRange: _selectedDateRange,
                      onRangeSelected: (range) {
                        setState(() {
                          _selectedDateRange = range;
                        });
                      },
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Column Selector
                  ColumnSelector(
                    dataFile: widget.dataFile,
                    selectedXColumn: _selectedXColumn,
                    selectedYColumns: _selectedYColumns,
                    onXColumnSelected: (column) {
                      setState(() {
                        _selectedXColumn = column;
                      });
                    },
                    onYColumnsSelected: (columns) {
                      setState(() {
                        _selectedYColumns = columns;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Chart Type Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chart Type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ChartType.values.map((type) {
                              return ChoiceChip(
                                label: Text(_getChartTypeLabel(type)),
                                selected: _selectedChartType == type,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedChartType = type;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Generate Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _generateChart,
                      icon: const Icon(Icons.auto_graph),
                      label: const Text('Generate Chart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Panel - Chart Preview
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[100],
              child: _currentConfig != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ChartDisplay(
                        config: _currentConfig!,
                        dataFile: widget.dataFile,
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assessment,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Configure your chart and click "Generate Chart"',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTypeLabel(ChartType type) {
    switch (type) {
      case ChartType.bar:
        return 'Bar';
      case ChartType.line:
        return 'Line';
      case ChartType.pie:
        return 'Pie';
      case ChartType.scatter:
        return 'Scatter';
      case ChartType.area:
        return 'Area';
    }
  }
}