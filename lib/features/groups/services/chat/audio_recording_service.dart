import 'dart:io';
import 'package:record/record.dart';

/// Service for handling audio recording functionality
class AudioRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  /// Starts audio recording
  Future<void> startRecording() async {
    try {
      if (_isRecording) return;

      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }

      final tempDir = await Directory.systemTemp.createTemp();
      _currentRecordingPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentRecordingPath!,
      );

      _isRecording = true;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      rethrow;
    }
  }

  /// Stops audio recording and returns the file
  Future<File?> stopRecording() async {
    try {
      if (!_isRecording) return null;

      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null && _currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          return file;
        }
      }

      return null;
    } catch (e) {
      _isRecording = false;
      _currentRecordingPath = null;
      return null;
    }
  }

  /// Cancels current recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stop();
      }
    } catch (e) {
      // Ignore cancel errors
    } finally {
      _isRecording = false;
      _currentRecordingPath = null;
    }
  }

  /// Checks if currently recording
  bool get isRecording => _isRecording;

  /// Gets current recording duration (if supported)
  Future<Duration?> getRecordingDuration() async {
    if (!_isRecording) return null;
    try {
      final duration = await _audioRecorder.getAmplitude();
      // Note: getAmplitude doesn't return duration, this is a placeholder
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Disposes recording resources
  Future<void> dispose() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stop();
      }
      _audioRecorder.dispose();
    } catch (e) {
      // Ignore dispose errors
    }
  }
}