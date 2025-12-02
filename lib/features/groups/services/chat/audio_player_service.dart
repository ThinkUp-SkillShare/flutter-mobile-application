import 'dart:io';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();

  factory AudioPlayerService() => _instance;

  AudioPlayerService._internal() {
    print('🎵 AudioPlayerService - Singleton instance created');
    _setupAudioListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentPlayingUrl;
  bool _isPlaying = false;
  Duration _currentDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  Function(String, bool)? _onPlayStateChanged;
  Function(String, Duration, Duration)? _onPositionChanged;

  void init() {
    print('🎵 AudioPlayerService - Initializing...');
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    print('🎵 AudioPlayerService - Setting up listeners');

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      final isNowPlaying = state == PlayerState.playing;
      print(
        '🎵 AudioPlayerService - Player state changed: $state, Playing: $isNowPlaying',
      );

      if (isNowPlaying != _isPlaying) {
        _isPlaying = isNowPlaying;
        if (_currentPlayingUrl != null) {
          print(
            '🎵 AudioPlayerService - Notifying play state change: $_currentPlayingUrl -> $_isPlaying',
          );
          _onPlayStateChanged?.call(_currentPlayingUrl!, _isPlaying);
        }
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      print('🎵 AudioPlayerService - Duration changed: $duration');
      _currentDuration = duration;
      if (_currentPlayingUrl != null) {
        _onPositionChanged?.call(
          _currentPlayingUrl!,
          _currentPosition,
          _currentDuration,
        );
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
      if (_currentPlayingUrl != null) {
        _onPositionChanged?.call(
          _currentPlayingUrl!,
          _currentPosition,
          _currentDuration,
        );
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      print('🎵 AudioPlayerService - Playback completed');
      _isPlaying = false;
      _currentPosition = Duration.zero;
      if (_currentPlayingUrl != null) {
        _onPlayStateChanged?.call(_currentPlayingUrl!, false);
        _onPositionChanged?.call(
          _currentPlayingUrl!,
          Duration.zero,
          _currentDuration,
        );
      }
    });
  }

  Future<void> playAudio(String audioUrl) async {
    try {
      print('🎵 AudioPlayerService - Playing audio: $audioUrl');

      // Si ya se está reproduciendo este audio, pausarlo
      if (_currentPlayingUrl == audioUrl && _isPlaying) {
        await pauseAudio();
        return;
      }

      // Si es un audio diferente, detener el actual
      if (_currentPlayingUrl != null && _currentPlayingUrl != audioUrl) {
        await stopAudio();
      }

      // Preparar la fuente
      Source source;

      if (audioUrl.startsWith('data:')) {
        // Es Base64 data URL
        final base64String = audioUrl.split(',').last;
        final tempPath = await _base64ToTempFile(base64String);
        source = DeviceFileSource(tempPath);
        print('🎵 AudioPlayerService - Playing from device file: $tempPath');
      } else if (audioUrl.startsWith('http')) {
        // Es URL HTTP
        source = UrlSource(audioUrl);
        print('🎵 AudioPlayerService - Playing from URL: $audioUrl');
      } else {
        // Es nombre de archivo en servidor
        final fullUrl = 'http://192.168.0.206:5118/uploads/audio/$audioUrl';
        source = UrlSource(fullUrl);
        print('🎵 AudioPlayerService - Playing from server file: $fullUrl');
      }

      // Configurar el player y reproducir
      await _audioPlayer.play(source);

      _currentPlayingUrl = audioUrl;
      _isPlaying = true;

      print('✅ AudioPlayerService - Playback started for: $audioUrl');

    } catch (e, stackTrace) {
      print('❌ AudioPlayerService - Error playing audio: $e');
      print('❌ AudioPlayerService - StackTrace: $stackTrace');
      _isPlaying = false;
      _currentPlayingUrl = null;

      // Re-lanzar el error para que sea manejado por la UI
      rethrow;
    }
  }

  Future<void> pauseAudio() async {
    try {
      print('🎵 AudioPlayerService - Pausing audio');
      await _audioPlayer.pause();
      _isPlaying = false;
      if (_currentPlayingUrl != null) {
        _onPlayStateChanged?.call(_currentPlayingUrl!, false);
      }
    } catch (e) {
      print('❌ AudioPlayerService - Error pausing audio: $e');
      _isPlaying = false;
    }
  }

  Future<void> stopAudio() async {
    try {
      print('🎵 AudioPlayerService - Stopping audio');
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentPosition = Duration.zero;

      if (_currentPlayingUrl != null) {
        _onPlayStateChanged?.call(_currentPlayingUrl!, false);
        _onPositionChanged?.call(
          _currentPlayingUrl!,
          Duration.zero,
          _currentDuration,
        );
        _currentPlayingUrl = null;
      }
    } catch (e) {
      print('❌ AudioPlayerService - Error stopping audio: $e');
      _isPlaying = false;
      _currentPlayingUrl = null;
    }
  }

  Future<void> seekAudio(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _currentPosition = position;
    } catch (e) {
      print('❌ AudioPlayerService - Error seeking audio: $e');
    }
  }

  Future<String> _base64ToTempFile(String base64String) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final bytes = base64.decode(base64String);
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      print('🎵 AudioPlayerService - Base64 saved to temp file: $filePath');
      return filePath;
    } catch (e) {
      print('❌ AudioPlayerService - Error converting base64: $e');
      throw Exception('Error al procesar audio local');
    }
  }

  bool isPlaying(String audioUrl) {
    return _currentPlayingUrl == audioUrl && _isPlaying;
  }

  Duration getCurrentPosition(String audioUrl) {
    if (_currentPlayingUrl == audioUrl) return _currentPosition;
    return Duration.zero;
  }

  Duration getDuration(String audioUrl) {
    if (_currentPlayingUrl == audioUrl) return _currentDuration;
    return Duration.zero;
  }

  void setPlayStateListener(Function(String, bool) listener) {
    _onPlayStateChanged = listener;
  }

  void setPositionListener(Function(String, Duration, Duration) listener) {
    _onPositionChanged = listener;
  }

  void dispose() {
    print('🎵 AudioPlayerService - Disposing...');
    stopAudio();
    _audioPlayer.dispose();
    _onPlayStateChanged = null;
    _onPositionChanged = null;
  }
}
