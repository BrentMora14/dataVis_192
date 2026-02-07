import 'package:flutter/material.dart';
import '../models/data_file.dart';
import '../utils/constants.dart';

class DataPreviewView extends StatelessWidget {
  final DataFile dataFile;
  final VoidCallback onContinue;

  const DataPreviewView({
    super.key,
    required this.dataFile,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildFileInfo(),
            const SizedBox(height: 24),
            _buildColumnInfo(),
            const SizedBox(height: 24),
            _buildDataTable(),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        const Text(
          'Data Preview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Filename:', dataFile.filename),
            _buildInfoRow(
              'File Size:',
              '${(dataFile.fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
            ),
            _buildInfoRow(
              'Rows:',
              '${dataFile.rawData.length - 1}', // -1 for header
            ),
            _buildInfoRow(
              'Columns:',
              '${dataFile.parsedColumns.length}',
            ),
            _buildInfoRow(
              'Date Columns:',
              '${dataFile.getDateColumns().length}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildColumnInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Column Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...dataFile.parsedColumns.map((column) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        column.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(
                        column.type.toString().split('.').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: column.isDateColumn
                          ? Colors.blue[100]
                          : Colors.grey[200],
                    ),
                    if (column.isDateColumn) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    // Limit preview to first 20 rows
    final previewRows = dataFile.rawData
        .take(AppConstants.previewRowLimit + 1)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Preview (First 20 rows)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: dataFile.parsedColumns
                    .map((col) => DataColumn(
                          label: Text(
                            col.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                rows: previewRows.skip(1).map((row) {
                  return DataRow(
                    cells: row.map((cell) {
                      return DataCell(
                        Text(
                          cell?.toString() ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onContinue,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue to Visualization'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}