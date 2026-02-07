import 'package:flutter/material.dart';
import 'models/data_file.dart';
import 'views/upload_view.dart';
import 'views/data_preview_view.dart';
import 'views/visualization_builder_view.dart';
import 'utils/constants.dart';

void main() {
  runApp(const DataVizApp());
}

class DataVizApp extends StatelessWidget {
  const DataVizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DataFile? _currentDataFile;
  int _currentStep = 0; // 0: Upload, 1: Preview, 2: Visualize

  void _handleFileUploaded(DataFile dataFile) {
    setState(() {
      _currentDataFile = dataFile;
      _currentStep = 1;
    });
  }

  void _handleContinueToVisualization() {
    setState(() {
      _currentStep = 2;
    });
  }

  void _resetToUpload() {
    setState(() {
      _currentDataFile = null;
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          if (_currentDataFile != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetToUpload,
              tooltip: 'Upload New File',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0:
        return UploadView(
          onFileUploaded: _handleFileUploaded,
        );
      case 1:
        return DataPreviewView(
          dataFile: _currentDataFile!,
          onContinue: _handleContinueToVisualization,
        );
      case 2:
        return VisualizationBuilderView(
          dataFile: _currentDataFile!,
        );
      default:
        return const Center(child: Text('Unknown state'));
    }
  }
}