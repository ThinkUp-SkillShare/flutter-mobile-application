import 'dart:convert';

import 'package:web_socket_channel/io.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/models/chat_message.dart';

class ChatWebSocketService {
  static IOWebSocketChannel? _channel;
  static int? _currentGroupId;
  static bool _isConnecting = false;
  static int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  static final Map<int, List<Function(ChatMessage)>> _messageListeners = {};
  static final Map<int, List<Function()>> _connectionListeners = {};
  static final Map<int, List<Function(dynamic)>> _errorListeners = {};
  static final Map<int, List<Function()>> _disconnectionListeners = {};

  static void connect(int groupId, String token) {
    print('🔗 WebSocket - Connect called for group $groupId');

    if (_currentGroupId == groupId && _channel != null && _channel!.sink != null) {
      print('🔗 WebSocket - Already connected to group $groupId');
      return;
    }

    if (_isConnecting) {
      print('🔗 WebSocket - Already connecting, will retry');
      return;
    }

    _isConnecting = true;
    _currentGroupId = groupId;

    print('🔗 WebSocket - Starting connection to group $groupId');
    _tryConnect(groupId, token);
  }

  static void _tryConnect(int groupId, String token) async {
    try {
      print('🔗 WebSocket - Trying to connect...');

      if (_channel != null && _channel!.sink != null) {
        try {
          _channel!.sink.close();
        } catch (e) {
          print('🔗 WebSocket - Error closing old connection: $e');
        }
        _channel = null;
      }

      final baseUrl = ApiConstants.baseUrl;
      print('🔗 WebSocket - Base URL: $baseUrl');

      final uri = Uri.parse(baseUrl.replaceFirst('/api', ''));

      final protocol = uri.scheme == 'https' ? 'wss' : 'ws';
      final wsUrl = '$protocol://${uri.host}:${uri.port}/ws/chat/$groupId';

      print('🔗 WebSocket - Connecting to: $wsUrl');
      print('🔗 WebSocket - GroupId: $groupId');
      print('🔗 WebSocket - Token length: ${token.length}');

      _channel = IOWebSocketChannel.connect(
        wsUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔗 WebSocket - Connection established, setting up listeners...');

      _channel!.stream.listen(
            (message) {
          print('🔗 WebSocket - Raw message received: $message');
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket - Stream error: $error');
          _isConnecting = false;
          _notifyError(groupId, error);
          _scheduleReconnect(groupId, token);
        },
        onDone: () {
          print('🔌 WebSocket - Connection closed by server');
          _isConnecting = false;
          _notifyDisconnection(groupId);
          _scheduleReconnect(groupId, token);
        },
      );

      _reconnectAttempts = 0;
      _isConnecting = false;

      print('✅ WebSocket - Connected successfully to group $groupId');
      _notifyConnection(groupId);

    } catch (e, stackTrace) {
      print('❌ WebSocket - Connection failed: $e');
      print('❌ WebSocket - Stack trace: $stackTrace');
      _isConnecting = false;
      _notifyError(groupId, e);
      _scheduleReconnect(groupId, token);
    }
  }

  static void _notifyConnection(int groupId) {
    final listeners = _connectionListeners[groupId] ?? [];
    print('🔗 WebSocket - Notifying ${listeners.length} connection listeners');

    for (final listener in listeners) {
      try {
        listener();
      } catch (e) {
        print('❌ WebSocket - Error in connection listener: $e');
      }
    }
  }

  static void _notifyDisconnection(int groupId) {
    final listeners = _disconnectionListeners[groupId] ?? [];
    print('🔌 WebSocket - Notifying ${listeners.length} disconnection listeners');

    for (final listener in listeners) {
      try {
        listener();
      } catch (e) {
        print('❌ WebSocket - Error in disconnection listener: $e');
      }
    }
  }

  static void _scheduleReconnect(int groupId, String token) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);

      print('🔗 WebSocket - Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)');

      Future.delayed(delay, () {
        if (_currentGroupId == groupId) {
          _tryConnect(groupId, token);
        }
      });
    } else {
      print('❌ WebSocket - Max reconnection attempts reached');
      _reconnectAttempts = 0;
    }
  }

  static void _handleMessage(String message) {
    try {
      final data = json.decode(message);
      final type = data['type'];

      print('🔗 WebSocket - Handling message type: $type');

      if (type == 'new_message') {
        final messageData = data['data'];
        final normalizedData = _normalizeMessageData(messageData);
        final chatMessage = ChatMessage.fromJson(normalizedData);

        // Notificar a todos los listeners del grupo
        final listeners = _messageListeners[_currentGroupId] ?? [];
        print('🔗 WebSocket - Notifying ${listeners.length} listeners for new message');

        for (final listener in listeners) {
          try {
            listener(chatMessage);
          } catch (e) {
            print('❌ WebSocket - Error in message listener: $e');
          }
        }
      } else if (type == 'connection_established') {
        print('✅ WebSocket - Connection established: ${data['message']}');
      } else if (type == 'user_joined') {
        print('👤 WebSocket - User joined: ${data['userId']}');
      } else if (type == 'user_left') {
        print('👤 WebSocket - User left: ${data['userId']}');
      }

    } catch (e) {
      print('❌ WebSocket - Error parsing message: $e');
      print('❌ WebSocket - Raw message: $message');
    }
  }

  static Map<String, dynamic> _normalizeMessageData(Map<String, dynamic> data) {
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
      'isEdited': data['IsEdited'] ?? data['isEdited'],
      'isDeleted': data['IsDeleted'] ?? data['isDeleted'],
      'createdAt': data['CreatedAt'] ?? data['createdAt'],
      'updatedAt': data['UpdatedAt'] ?? data['updatedAt'],
      'reactions': data['Reactions'] ?? data['reactions'] ?? [],
      'isRead': data['IsRead'] ?? data['isRead'],
      'isSentByCurrentUser': data['IsSentByCurrentUser'] ?? data['isSentByCurrentUser'],
    };
  }

  static void addMessageListener(int groupId, Function(ChatMessage) listener) {
    if (!_messageListeners.containsKey(groupId)) {
      _messageListeners[groupId] = [];
    }
    _messageListeners[groupId]!.add(listener);
    print('👂 WebSocket - Added message listener for group $groupId. Total: ${_messageListeners[groupId]!.length}');
  }

  static void removeMessageListener(int groupId, Function(ChatMessage) listener) {
    _messageListeners[groupId]?.remove(listener);
    print('➖ WebSocket - Removed message listener for group $groupId');
  }

  static void addConnectionListener(int groupId, Function() listener) {
    if (!_connectionListeners.containsKey(groupId)) {
      _connectionListeners[groupId] = [];
    }
    _connectionListeners[groupId]!.add(listener);
    print('👂 WebSocket - Added connection listener for group $groupId');
  }

  static void removeConnectionListener(int groupId, Function() listener) {
    _connectionListeners[groupId]?.remove(listener);
    print('➖ WebSocket - Removed connection listener for group $groupId');
  }

  static void addErrorListener(int groupId, Function(dynamic) listener) {
    if (!_errorListeners.containsKey(groupId)) {
      _errorListeners[groupId] = [];
    }
    _errorListeners[groupId]!.add(listener);
    print('👂 WebSocket - Added error listener for group $groupId');
  }

  static void removeErrorListener(int groupId, Function(dynamic) listener) {
    _errorListeners[groupId]?.remove(listener);
    print('➖ WebSocket - Removed error listener for group $groupId');
  }

  static void addDisconnectionListener(int groupId, Function() listener) {
    if (!_disconnectionListeners.containsKey(groupId)) {
      _disconnectionListeners[groupId] = [];
    }
    _disconnectionListeners[groupId]!.add(listener);
    print('👂 WebSocket - Added disconnection listener for group $groupId');
  }

  static void removeDisconnectionListener(int groupId, Function() listener) {
    _disconnectionListeners[groupId]?.remove(listener);
    print('➖ WebSocket - Removed disconnection listener for group $groupId');
  }

  static void _notifyError(int groupId, dynamic error) {
    final listeners = _errorListeners[groupId] ?? [];
    for (final listener in listeners) {
      try {
        listener(error);
      } catch (e) {
        print('❌ WebSocket - Error in error listener: $e');
      }
    }
  }

  static void sendMessage(dynamic message) {
    if (_channel != null && _channel!.sink != null) {
      try {
        _channel!.sink.add(json.encode(message));
        print('📤 WebSocket - Message sent: $message');
      } catch (e) {
        print('❌ WebSocket - Error sending message: $e');
      }
    }
  }

  static void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
      _currentGroupId = null;
      _isConnecting = false;
      print('🔌 WebSocket - Disconnected');
    }
  }

  static bool isConnected(int groupId) {
    return _currentGroupId == groupId && _channel != null;
  }

  static int? getCurrentGroupId() {
    return _currentGroupId;
  }
}