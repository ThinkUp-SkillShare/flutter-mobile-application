import 'package:flutter/material.dart';
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
      '.ppt': 'application/vnd.ms-powerpoint',
      '.pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
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

  /// Gets file type category
  static String getFileTypeCategory(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return 'pdf';
      case '.doc':
      case '.docx':
        return 'document';
      case '.xls':
      case '.xlsx':
        return 'spreadsheet';
      case '.ppt':
      case '.pptx':
        return 'presentation';
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return 'image';
      default:
        return 'other';
    }
  }

  /// Validates if file is supported
  static bool isSupportedFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    final supportedExtensions = [
      '.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx',
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp',
      '.txt', '.zip', '.rar'
    ];
    return supportedExtensions.contains(extension);
  }

  /// Gets appropriate color for file type
  static Color getFileTypeColor(String fileType) {
    return switch (fileType.toLowerCase()) {
      'pdf' => const Color(0xFFE74C3C),
      'doc' || 'docx' || 'document' => const Color(0xFF2B579A),
      'xls' || 'xlsx' || 'spreadsheet' => const Color(0xFF217346),
      'ppt' || 'pptx' || 'presentation' => const Color(0xFFD24726),
      'jpg' || 'jpeg' || 'png' || 'gif' || 'bmp' || 'image' => const Color(0xFFE67E22),
      _ => const Color(0xFF95A5A6),
    };
  }

  /// Gets appropriate icon for file type
  static IconData getFileTypeIcon(String fileType) {
    return switch (fileType.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf,
      'doc' || 'docx' || 'document' => Icons.description,
      'xls' || 'xlsx' || 'spreadsheet' => Icons.table_chart,
      'ppt' || 'pptx' || 'presentation' => Icons.slideshow,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'bmp' || 'image' => Icons.image,
      _ => Icons.insert_drive_file,
    };
  }
}