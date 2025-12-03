import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../../core/constants/api_constants.dart';

/// Handles WebSocket communication for video calls including signaling,
/// participant management, and real-time updates.
class VideoCallWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageStreamController =
  StreamController<Map<String, dynamic>>.broadcast();

  final String _callId;
  final String _userId;

  VideoCallWebSocketService({
    required String callId,
    required String userId,
  }) : _callId = callId, _userId = userId;

  /// Connects to the WebSocket server for the current call.
  Future<void> connect() async {
    try {
      final wsUrl = ApiConstants.webSocketCall(_callId, _userId);
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
            (message) => _handleIncomingMessage(message),
        onDone: () => _messageStreamController.add({
          'type': 'connection-closed',
          'message': 'WebSocket connection closed'
        }),
        onError: (error) => _messageStreamController.add({
          'type': 'connection-error',
          'error': error.toString()
        }),
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  /// Disconnects from the WebSocket server.
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  /// Sends a signaling message to the server.
  void sendSignalingMessage({
    required String type,
    required dynamic data,
    String? targetUserId,
  }) {
    if (_channel == null || _channel!.sink == null) return;

    final message = {
      'type': type,
      'data': data,
      'senderId': _userId,
      'targetUserId': targetUserId,
      'callId': _callId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _channel!.sink.add(json.encode(message));
  }

  /// Stream of incoming WebSocket messages.
  Stream<Map<String, dynamic>> get messageStream => _messageStreamController.stream;

  /// Handles incoming WebSocket messages and forwards them to listeners.
  void _handleIncomingMessage(dynamic message) {
    try {
      final decoded = json.decode(message);
      _messageStreamController.add(decoded);
    } catch (e) {
      _messageStreamController.add({
        'type': 'parse-error',
        'error': 'Failed to parse message: $e',
        'raw': message.toString(),
      });
    }
  }

  /// Checks if the WebSocket connection is active.
  bool get isConnected => _channel != null;
}