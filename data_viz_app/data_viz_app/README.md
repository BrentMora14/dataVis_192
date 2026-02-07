# data_viz_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

----

# Software Specification Document
## Data Visualization Web Application

**Version:** 1.0  
**Date:** February 6, 2026  
**Target Users:** Small team/organization

---

## 1. Overview

### 1.1 Purpose
This web application enables teams to upload data files and create visual representations through charts, graphs, and interactive dashboards. Users can explore their data through basic filtering and viewing capabilities.

### 1.2 Target Users
- Small teams (5-50 members)
- Organizational departments needing data insights
- Users with basic technical skills

---

## 2. Core Features

### 2.1 Data Import
- **File Upload**: Support for CSV and Excel (.xlsx, .xls) files
- **File Size Limit**: Up to 50MB per file (adjustable)
- **Data Preview**: Show first 10-20 rows after upload for verification
- **Column Detection**: Automatic detection of data types (text, numbers, dates)
- **Date Column Requirement**: System assumes CSV/Excel files contain at least one date or datetime column
- **Date Format Detection**: Automatic parsing of common date formats

### 2.2 Visualization Types
- **Charts and Graphs**:
  - Bar charts (vertical and horizontal)
  - Line charts
  - Pie charts
  - Scatter plots
  - Area charts
- **Interactive Dashboards**:
  - Multi-chart layouts
  - Grid-based arrangement
  - Responsive design for different screen sizes

### 2.3 Interactivity
- **Date Range Selection**:
  - Quick options: Last 7 days, Last month, Last 3 months, Last year
  - Custom date range picker (start and end dates)
  - Visual date range slider
  - **Applied before chart generation**: Data is filtered by date range FIRST, then the chart is created from the filtered dataset
  - All date filtering happens on the detected date/datetime column(s)
- **Additional Filtering**: 
  - Filter by column values (e.g., filter by specific product types)
  - Text search within data
  - Filters work in combination with date range (date range + column filters)
- **View Options**:
  - Toggle between chart types
  - Show/hide data points
  - Zoom in/out on charts
  - Export visualizations as images (PNG/SVG)

---

## 3. User Workflows

### 3.1 Basic User Journey
1. User opens the application (no login required)
2. User uploads a CSV or Excel file
3. System displays data preview
4. User selects columns to visualize
5. User chooses date range for visualization
   - System automatically detects date/datetime columns
   - User selects start and end dates (e.g., "last month", custom range)
   - Example: visualize sales per product type within the last month
6. User chooses chart type
7. System generates visualization based on selected columns and date range
8. User applies additional filters as needed
9. User saves or exports the visualization

### 3.2 Dashboard Creation
1. User creates a new dashboard
2. User adds multiple charts from uploaded data
3. Each chart can have its own date range selection
4. User arranges charts in desired layout
5. User saves dashboard locally (browser storage)
6. User can export or share dashboard data

---

## 4. Technical Requirements

### 4.1 Architecture
- **Pattern**: Model-View-Controller (MVC)
- **Model**: Data classes for uploaded files, chart configurations, dashboard settings, and date ranges
- **View**: Flutter widgets for UI components (file upload, charts, date pickers, dashboards)
- **Controller**: Business logic for file parsing, data filtering, date range processing, and chart generation

### 4.2 Framework
- **Primary Technology**: Dart and Flutter
- **Platform**: Web application (Flutter Web)
- **Charting Library**: fl_chart, syncfusion_flutter_charts, or charts_flutter
- **UI Components**: Flutter widgets with Material Design or custom styling

### 4.3 Backend (Optional/Future)
- **Current Approach**: Client-side file processing (no backend required initially)
- **File Processing**: CSV parsing using Dart packages (csv, excel)
- **Storage**: Local browser storage or IndexedDB for saved visualizations
- **Future Backend**: If needed, can use Dart (shelf/serverpod) or traditional backend

### 4.4 Authentication
- **Current Phase**: Not required - direct access to application
- **Future Phase**: Can be added when team collaboration features are needed

### 4.5 Performance
- Handle files up to 50MB
- Render charts with up to 10,000 data points smoothly
- Dashboard load time under 3 seconds
- Smooth date range selection and chart updates

### 4.6 Recommended Dart Packages
- **File Processing**: `csv` (CSV parsing), `excel` (Excel file handling)
- **Charts**: `fl_chart` (lightweight, customizable) or `syncfusion_flutter_charts` (feature-rich)
- **Date/Time**: `intl` (date formatting), `flutter_datetime_picker` (date range selection)
- **Storage**: `shared_preferences` or `hive` (local data persistence)
- **File Upload**: `file_picker` (web file selection)
- **State Management**: `provider`, `riverpod`, or `bloc` (optional, based on preference)

### 4.7 MVC Structure Overview

**Models**:
- `DataFile`: Represents uploaded CSV/Excel file with metadata
  - Properties: filename, file size, upload timestamp, raw data (List of rows), parsed columns
- `DataColumn`: Individual column with type information (text, number, date)
  - Properties: column name, data type, sample values, is_date_column flag
- `DateRange`: Start and end dates for filtering
  - Properties: start_date (DateTime), end_date (DateTime), preset_type (enum: custom, last_7_days, last_month, etc.)
- `ChartConfig`: Chart type, selected columns, filters, and styling
  - Properties: chart_type (bar/line/pie/scatter/area), x_axis_column, y_axis_column(s), date_range, applied_filters, colors, title
- `Dashboard`: Collection of charts with layout information
  - Properties: dashboard_name, list of ChartConfig objects, layout_grid (positions and sizes), created_date

**Views**:
- `UploadView`: File upload interface
- `DataPreviewView`: Display uploaded data in table format
- `VisualizationBuilderView`: Chart creation interface with controls
- `DashboardView`: Multi-chart dashboard display
- `DateRangePickerView`: Date selection widget

**Controllers**:
- `FileController`: Handle file upload, parsing, and validation
  - Methods: uploadFile(), parseCSV(), parseExcel(), validateFileType(), validateFileSize(), detectColumns()
- `DataController`: Manage data filtering, date range application, and column selection
  - Methods: applyDateRange(), filterByColumn(), searchData(), getFilteredData(), detectDateColumns()
- `ChartController`: Generate and update charts based on configuration
  - Methods: generateChart(), updateChartType(), applyChartConfig(), exportChartImage()
- `DashboardController`: Manage dashboard state and chart arrangements
  - Methods: createDashboard(), addChart(), removeChart(), updateLayout(), saveDashboard()
- `StorageController`: Handle saving/loading visualizations from browser storage
  - Methods: saveVisualization(), loadVisualization(), listSavedVisualizations(), deleteVisualization()

---

## 5. User Interface

### 5.1 Key Pages
1. **Home/Upload Page**: Initial landing page with drag-and-drop file upload
2. **Data Preview Page**: View uploaded data and column information
3. **Visualization Builder**: Interactive chart creation interface with date range selection
4. **Dashboard Editor**: Arrange and manage multiple visualizations

### 5.2 Design Principles
- Clean, minimal interface
- Clear navigation between sections
- Tooltips and help text for guidance
- Responsive design (desktop and tablet support)

---

## 6. Data and Security

### 6.1 Data Storage
- **Current Approach**: Browser-based storage (localStorage/IndexedDB)
- **Uploaded Files**: Processed client-side, stored temporarily in browser
- **Saved Visualizations**: Stored locally in user's browser
- **Data Persistence**: Data remains until user clears browser storage

### 6.2 Security Considerations (Future Priority)
- File upload validation (file type and size checks)
- Protection against malicious file uploads
- Data encryption if backend storage is added later
- User authentication can be implemented in future phases

---

## 7. Future Enhancements (Optional)

These features can be added in future versions:
- Real-time data refresh from external sources
- More advanced filtering (custom formulas, calculated fields)
- Collaboration features (comments, annotations)
- Scheduled reports/exports
- API access for programmatic data upload
- Additional chart types (heat maps, tree maps)

---

## 8. Success Metrics

- Users can upload and visualize data within 3 minutes of opening the application
- Date range selection is intuitive and works with various date formats
- 90% of visualizations render without errors
- Charts update smoothly when date range is changed
- Application works reliably in modern web browsers (Chrome, Firefox, Safari, Edge)
- Positive user feedback on ease of use

---

## 9. Development Priorities

### Phase 1 (MVP - Minimum Viable Product)
- **Set up MVC structure**:
  - Create base Model classes (DataFile, DataColumn, DateRange, ChartConfig)
  - Implement Controllers (FileController, DataController, ChartController)
  - Build Views (UploadView, VisualizationBuilderView)
- **Core features**:
  - File upload interface (CSV support)
  - Date/datetime column detection
  - Date range selector (quick options + custom range)
  - Column selection for visualization
  - Basic chart types (bar, line, pie)
  - Simple filtering
  - Save visualizations to browser storage
  - Export charts as images

### Phase 2
- Excel file support
- Dashboard creation with multiple charts
- Export functionality
- Improved UI/UX

### Phase 3
- Team collaboration features
- Performance optimization
- Additional chart types
- Advanced filtering options

---

## 10. Concrete Example: Sales Data Visualization

To clarify the application's purpose, here's a concrete example:

### Sample CSV Data:
```csv
Date,Product Type,Sales Amount,Region
2025-01-15,Electronics,1500,North
2025-01-16,Clothing,800,South
2025-01-17,Electronics,2100,East
2025-01-18,Clothing,950,North
2025-01-20,Electronics,1800,West
```

### User Workflow:
1. User uploads the CSV file
2. System detects "Date" column as datetime, other columns as text/number
3. User selects:
   - X-axis: Product Type
   - Y-axis: Sales Amount (sum/average)
   - Date range: "Last month" (filters to January 2025 data)
4. User chooses "Bar chart"
5. System filters data by date range, groups by Product Type, sums Sales Amount
6. Result: Bar chart showing total sales per product type for January 2025

### Expected Output:
- Electronics: $5,400
- Clothing: $1,750

This example demonstrates how date range filtering works with categorical grouping to create meaningful visualizations.

---

## 11. Project Structure (MVC Organization)

```
lib/
├── main.dart
├── models/
│   ├── data_file.dart
│   ├── data_column.dart
│   ├── date_range.dart
│   ├── chart_config.dart
│   └── dashboard.dart
├── views/
│   ├── upload_view.dart
│   ├── data_preview_view.dart
│   ├── visualization_builder_view.dart
│   ├── dashboard_view.dart
│   └── widgets/
│       ├── date_range_picker.dart
│       ├── chart_display.dart
│       └── column_selector.dart
├── controllers/
│   ├── file_controller.dart
│   ├── data_controller.dart
│   ├── chart_controller.dart
│   ├── dashboard_controller.dart
│   └── storage_controller.dart
└── utils/
    ├── date_parser.dart
    ├── file_validator.dart
    └── constants.dart
```

### MVC Data Flow Example:
1. **User uploads file** → `UploadView` → `FileController.uploadFile()`
2. **Controller parses file** → `FileController` creates `DataFile` model
3. **Model updated** → `DataFile` with columns detected
4. **View reflects changes** → `DataPreviewView` displays data
5. **User selects date range** → `VisualizationBuilderView` → `DataController.applyDateRange()`
6. **Controller filters data** → Updates model with filtered dataset
7. **User creates chart** → `ChartController.generateChart()` with `ChartConfig`
8. **View renders chart** → `VisualizationBuilderView` displays chart widget

---

## 12. Key Implementation Notes

### Date Range Filtering Logic:
1. When user selects a date range, `DataController.applyDateRange()` is called
2. Controller identifies the date column(s) in the dataset
3. Filters the raw data to only include rows where date falls within range
4. Returns filtered dataset to be used for chart generation
5. Chart is generated ONLY from the filtered data

### Chart Generation Flow:
1. User selects columns for X and Y axes
2. User selects chart type (bar, line, pie, etc.)
3. `ChartController.generateChart()` receives:
   - Filtered data (already filtered by date range)
   - Column selections
   - Chart type
4. Controller aggregates data if needed (sum, average, count)
5. Creates ChartConfig model
6. Returns chart data to View for rendering

### Data Aggregation Examples:
- **Bar chart**: Group by X-axis column, sum/average Y-axis values
- **Line chart**: X-axis is typically date (within selected range), Y-axis is metric over time
- **Pie chart**: Group by category column, sum values for each category

---

## 13. Questions to Consider

Before development begins:
1. What are the most common date formats in your CSV files (e.g., MM/DD/YYYY, YYYY-MM-DD)?
2. Should the application support multiple date columns in a single file?
3. What should happen when users upload files without date columns?
4. What is the maximum data size the browser should handle comfortably?
5. Should saved visualizations be exportable/importable for sharing between users?
6. Are there specific chart types that are higher priority for your use case?