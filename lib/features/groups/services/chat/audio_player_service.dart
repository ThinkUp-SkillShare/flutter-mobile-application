import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing audio playback across chat messages
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal() {
    _setupAudioListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingUrl;
  bool _isPlaying = false;
  Duration _currentDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  final Map<String, Function(bool)> _playStateListeners = {};
  final Map<String, Function(Duration, Duration)> _positionListeners = {};

  /// Sets up audio player event listeners
  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      final isNowPlaying = state == PlayerState.playing;

      if (isNowPlaying != _isPlaying) {
        _isPlaying = isNowPlaying;
        if (_currentPlayingUrl != null) {
          _notifyPlayStateListeners(_currentPlayingUrl!, _isPlaying);
        }
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _currentDuration = duration;
      if (_currentPlayingUrl != null) {
        _notifyPositionListeners(_currentPlayingUrl!, _currentPosition, _currentDuration);
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
      if (_currentPlayingUrl != null) {
        _notifyPositionListeners(_currentPlayingUrl!, _currentPosition, _currentDuration);
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      if (_currentPlayingUrl != null) {
        _notifyPlayStateListeners(_currentPlayingUrl!, false);
        _notifyPositionListeners(_currentPlayingUrl!, Duration.zero, _currentDuration);
      }
    });
  }

  /// Notifies all play state listeners for a specific audio URL
  void _notifyPlayStateListeners(String audioUrl, bool isPlaying) {
    final listener = _playStateListeners[audioUrl];
    if (listener != null) {
      listener(isPlaying);
    }
  }

  /// Notifies all position listeners for a specific audio URL
  void _notifyPositionListeners(String audioUrl, Duration position, Duration duration) {
    final listener = _positionListeners[audioUrl];
    if (listener != null) {
      listener(position, duration);
    }
  }

  /// Plays audio from URL or base64 data
  Future<void> playAudio(String audioUrl) async {
    try {
      // If already playing this audio, pause it
      if (_currentPlayingUrl == audioUrl && _isPlaying) {
        await pauseAudio();
        return;
      }

      // If playing different audio, stop current
      if (_currentPlayingUrl != null && _currentPlayingUrl != audioUrl) {
        await stopAudio();
      }

      Source source = await _getAudioSource(audioUrl);
      await _audioPlayer.play(source);

      _currentPlayingUrl = audioUrl;
      _isPlaying = true;

    } catch (e) {
      _isPlaying = false;
      _currentPlayingUrl = null;
      rethrow;
    }
  }

  /// Gets audio source from URL or base64
  Future<Source> _getAudioSource(String audioUrl) async {
    if (audioUrl.startsWith('data:')) {
      // Base64 data URL
      final base64String = audioUrl.split(',').last;
      final tempPath = await _base64ToTempFile(base64String);
      return DeviceFileSource(tempPath);
    } else if (audioUrl.startsWith('http')) {
      // HTTP URL
      return UrlSource(audioUrl);
    } else {
      // Assume it's a file path
      return DeviceFileSource(audioUrl);
    }
  }

  /// Pauses current audio playback
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      if (_currentPlayingUrl != null) {
        _notifyPlayStateListeners(_currentPlayingUrl!, false);
      }
    } catch (e) {
      _isPlaying = false;
    }
  }

  /// Stops current audio playback
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentPosition = Duration.zero;

      if (_currentPlayingUrl != null) {
        _notifyPlayStateListeners(_currentPlayingUrl!, false);
        _notifyPositionListeners(_currentPlayingUrl!, Duration.zero, _currentDuration);
        _currentPlayingUrl = null;
      }
    } catch (e) {
      _isPlaying = false;
      _currentPlayingUrl = null;
    }
  }

  /// Seeks to specific position in audio
  Future<void> seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _currentPosition = position;
    } catch (e) {
      // Ignore seek errors
    }
  }

  /// Converts base64 string to temporary file
  Future<String> _base64ToTempFile(String base64String) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final bytes = base64.decode(base64String);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      throw Exception('Error processing audio file: $e');
    }
  }

  /// Checks if specific audio is currently playing
  bool isPlaying(String audioUrl) {
    return _currentPlayingUrl == audioUrl && _isPlaying;
  }

  /// Gets current position of specific audio
  Duration getCurrentPosition(String audioUrl) {
    if (_currentPlayingUrl == audioUrl) return _currentPosition;
    return Duration.zero;
  }

  /// Gets duration of specific audio
  Duration getDuration(String audioUrl) {
    if (_currentPlayingUrl == audioUrl) return _currentDuration;
    return Duration.zero;
  }

  /// Sets play state change listener for specific audio URL
  void setPlayStateListener(String audioUrl, Function(bool) listener) {
    if (listener == null) {
      _playStateListeners.remove(audioUrl);
    } else {
      _playStateListeners[audioUrl] = listener;
    }
  }

  /// Sets position change listener for specific audio URL
  void setPositionListener(String audioUrl, Function(Duration, Duration) listener) {
    if (listener == null) {
      _positionListeners.remove(audioUrl);
    } else {
      _positionListeners[audioUrl] = listener;
    }
  }

  /// Removes all listeners for specific audio URL
  void removeListeners(String audioUrl) {
    _playStateListeners.remove(audioUrl);
    _positionListeners.remove(audioUrl);
  }

  /// Disposes audio player resources
  void dispose() {
    stopAudio();
    _audioPlayer.dispose();
    _playStateListeners.clear();
    _positionListeners.clear();
  }
}