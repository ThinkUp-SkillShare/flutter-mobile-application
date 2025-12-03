import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Utility class for file operations including base64 conversion and MIME type detection
class FileUtils {
  /// Converts a file to base64 string
  static Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Error converting file to base64: $e');
    }
  }

  /// Gets MIME type based on file extension
  static String getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    final mimeTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.gif': 'image/gif',
      '.bmp': 'image/bmp',
      '.webp': 'image/webp',
      '.mp3': 'audio/mpeg',
      '.m4a': 'audio/mp4',
      '.aac': 'audio/aac',
      '.wav': 'audio/wav',
      '.ogg': 'audio/ogg',
      '.pdf': 'application/pdf',
      '.doc': 'application/msword',
      '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      '.xls': 'application/vnd.ms-excel',
      '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      '.txt': 'text/plain',
      '.zip': 'application/zip',
      '.rar': 'application/x-rar-compressed',
    };

    return mimeTypes[extension] ?? 'application/octet-stream';
  }

  /// Creates a data URL from base64 string
  static String createDataUrl(String base64, String fileName) {
    final mimeType = getMimeType(fileName);
    return 'data:$mimeType;base64,$base64';
  }

  /// Extracts file name from path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Formats file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Gets appropriate icon for file type
  static String getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return '📄';
      case '.doc':
      case '.docx':
        return '📝';
      case '.xls':
      case '.xlsx':
        return '📊';
      case '.zip':
      case '.rar':
      case '.7z':
        return '🗜️';
      case '.mp3':
      case '.wav':
      case '.m4a':
        return '🎵';
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return '🖼️';
      default:
        return '📎';
    }
  }
}