class FileValidator {
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB in bytes
  static const List<String> allowedExtensions = ['.csv', '.xlsx', '.xls'];

  /// Validate file size
  static bool validateFileSize(int fileSize) {
    return fileSize <= maxFileSize;
  }

  /// Validate file extension
  static bool validateFileExtension(String filename) {
    final lowerFilename = filename.toLowerCase();
    return allowedExtensions.any((ext) => lowerFilename.endsWith(ext));
  }

  /// Get file extension
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  /// Get error message for validation failure
  static String getErrorMessage(String filename, int fileSize) {
    if (!validateFileExtension(filename)) {
      return 'Invalid file type. Please upload a CSV or Excel file.';
    }
    if (!validateFileSize(fileSize)) {
      return 'File too large. Maximum size is 50MB.';
    }
    return '';
  }

  /// Get human-readable file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}