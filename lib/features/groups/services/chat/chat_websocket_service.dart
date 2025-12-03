import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../domain/models/chats/chat_message.dart';

/// Manages WebSocket connections for real-time chat functionality
class ChatWebSocketService {
  static final ChatWebSocketService _instance = ChatWebSocketService._internal();

  factory ChatWebSocketService() => _instance;

  ChatWebSocketService._internal();

  IOWebSocketChannel? _channel;
  int? _currentGroupId;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  final Map<int, List<Function(ChatMessage)>> _messageListeners = {};
  final Map<int, List<Function()>> _connectionListeners = {};
  final Map<int, List<Function(dynamic)>> _errorListeners = {};
  final Map<int, List<Function()>> _disconnectionListeners = {};

  /// Connects to WebSocket server for the specified group
  Future<void> connect(int groupId, String token) async {
    if (_currentGroupId == groupId && _channel != null) return;
    if (_isConnecting) return;

    _isConnecting = true;
    _currentGroupId = groupId;

    await _tryConnect(groupId, token);
  }

  Future<void> _tryConnect(int groupId, String token) async {
    try {
      // Close existing connection if any
      await _disconnect();

      final wsUrl = ApiConstants.webSocketChat(groupId);

      _channel = IOWebSocketChannel.connect(
        wsUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      _channel!.stream.listen(
        _handleIncomingMessage,
        onError: (error) => _handleConnectionError(groupId, token, error),
        onDone: () => _handleConnectionClosed(groupId, token),
      );

      _reconnectAttempts = 0;
      _isConnecting = false;
      _notifyConnection(groupId);

    } catch (e) {
      _isConnecting = false;
      _notifyError(groupId, e);
      _scheduleReconnect(groupId, token);
    }
  }

  /// Handles incoming WebSocket messages
  void _handleIncomingMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final type = data['type'];

      if (type == 'new_message') {
        _handleNewMessage(data['data']);
      } else if (type == 'connection_established') {
        // Connection successful
      } else if (type == 'user_joined' || type == 'user_left') {
        // User presence updates can be handled here if needed
      }
    } catch (e) {
      // Ignore parsing errors for non-JSON messages
    }
  }

  /// Processes new message data
  void _handleNewMessage(Map<String, dynamic> messageData) {
    if (_currentGroupId == null) return;

    try {
      final normalizedData = _normalizeMessageData(messageData);
      final chatMessage = ChatMessage.fromJson(normalizedData);

      final listeners = _messageListeners[_currentGroupId] ?? [];
      for (final listener in listeners) {
        try {
          listener(chatMessage);
        } catch (e) {
          // Prevent error in one listener from breaking others
        }
      }
    } catch (e) {
      _notifyError(_currentGroupId!, e);
    }
  }

  /// Normalizes message data to ensure consistent field names
  Map<String, dynamic> _normalizeMessageData(Map<String, dynamic> data) {
    return {
      'id': data['Id'] ?? data['id'],
      'groupId': data['GroupId'] ?? data['groupId'],
      'userId': data['UserId'] ?? data['userId'],
      'userEmail': data['UserEmail'] ?? data['userEmail'],
      'userProfileImage': data['UserProfileImage'] ?? data['userProfileImage'],
      'messageType': data['MessageType'] ?? data['messageType'],
      'content': data['Content'] ?? data['content'],
      'fileUrl': data['FileUrl'] ?? data['fileUrl'],
      'fileName': data['FileName'] ?? data['fileName'],
      'fileSize': data['FileSize'] ?? data['fileSize'],
      'duration': data['Duration'] ?? data['duration'],
      'replyToMessageId': data['ReplyToMessageId'] ?? data['replyToMessageId'],
      'replyToMessage': data['ReplyToMessage'] ?? data['replyToMessage'],
      'isEdited': data['IsEdited'] ?? data['isEdited'] ?? false,
      'isDeleted': data['IsDeleted'] ?? data['isDeleted'] ?? false,
      'createdAt': data['CreatedAt'] ?? data['createdAt'],
      'updatedAt': data['UpdatedAt'] ?? data['updatedAt'],
      'reactions': data['Reactions'] ?? data['reactions'] ?? [],
      'isRead': data['IsRead'] ?? data['isRead'] ?? false,
      'isSentByCurrentUser': data['IsSentByCurrentUser'] ?? data['isSentByCurrentUser'] ?? false,
    };
  }

  /// Handles connection errors
  void _handleConnectionError(int groupId, String token, dynamic error) {
    _isConnecting = false;
    _notifyError(groupId, error);
    _scheduleReconnect(groupId, token);
  }

  /// Handles connection closed by server
  void _handleConnectionClosed(int groupId, String token) {
    _isConnecting = false;
    _notifyDisconnection(groupId);
    _scheduleReconnect(groupId, token);
  }

  /// Schedules reconnection attempt
  void _scheduleReconnect(int groupId, String token) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);

      Future.delayed(delay, () {
        if (_currentGroupId == groupId) {
          _tryConnect(groupId, token);
        }
      });
    } else {
      _reconnectAttempts = 0;
    }
  }

  /// Notifies all connection listeners
  void _notifyConnection(int groupId) {
    final listeners = _connectionListeners[groupId] ?? [];
    for (final listener in listeners) {
      try {
        listener();
      } catch (_) {}
    }
  }

  /// Notifies all disconnection listeners
  void _notifyDisconnection(int groupId) {
    final listeners = _disconnectionListeners[groupId] ?? [];
    for (final listener in listeners) {
      try {
        listener();
      } catch (_) {}
    }
  }

  /// Notifies all error listeners
  void _notifyError(int groupId, dynamic error) {
    final listeners = _errorListeners[groupId] ?? [];
    for (final listener in listeners) {
      try {
        listener(error);
      } catch (_) {}
    }
  }

  /// Sends a message through WebSocket
  void sendMessage(dynamic message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (_) {
        // Ignore send errors
      }
    }
  }

  /// Disconnects from WebSocket server
  Future<void> disconnect() async {
    await _disconnect();
    _currentGroupId = null;
    _reconnectAttempts = 0;
  }

  Future<void> _disconnect() async {
    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (_) {
        // Ignore close errors
      }
      _channel = null;
    }
  }

  // Listener management methods
  void addMessageListener(int groupId, Function(ChatMessage) listener) {
    _messageListeners.putIfAbsent(groupId, () => []).add(listener);
  }

  void removeMessageListener(int groupId, Function(ChatMessage) listener) {
    _messageListeners[groupId]?.remove(listener);
  }

  void addConnectionListener(int groupId, Function() listener) {
    _connectionListeners.putIfAbsent(groupId, () => []).add(listener);
  }

  void removeConnectionListener(int groupId, Function() listener) {
    _connectionListeners[groupId]?.remove(listener);
  }

  void addErrorListener(int groupId, Function(dynamic) listener) {
    _errorListeners.putIfAbsent(groupId, () => []).add(listener);
  }

  void removeErrorListener(int groupId, Function(dynamic) listener) {
    _errorListeners[groupId]?.remove(listener);
  }

  void addDisconnectionListener(int groupId, Function() listener) {
    _disconnectionListeners.putIfAbsent(groupId, () => []).add(listener);
  }

  void removeDisconnectionListener(int groupId, Function() listener) {
    _disconnectionListeners[groupId]?.remove(listener);
  }

  /// Checks if connected to a specific group
  bool isConnected(int groupId) {
    return _currentGroupId == groupId && _channel != null;
  }

  /// Gets current connected group ID
  int? get currentGroupId => _currentGroupId;
}