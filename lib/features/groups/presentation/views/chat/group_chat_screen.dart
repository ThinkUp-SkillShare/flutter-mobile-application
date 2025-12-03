import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/utils/file_utils.dart';
import '../../../../auth/application/auth_service.dart';
import '../../../services/chat/audio_player_service.dart';
import '../../../services/chat/audio_recording_service.dart';
import '../../../services/chat/chat_service.dart';
import '../../../domain/models/chats/chat_message.dart';
import '../../../services/chat/chat_websocket_service.dart';
import '../../widgets/chat/chat_header_widget.dart';
import '../../widgets/chat/chat_input_widget.dart';
import '../../widgets/chat/chat_message_bubble.dart';

/// Screen for group chat functionality with real-time messaging,
/// file sharing, and audio messages.
class GroupChatScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioRecordingService _recordingService = AudioRecordingService();
  final ChatWebSocketService _webSocketService = ChatWebSocketService();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  ChatMessage? _replyingTo;
  ChatMessage? _editingMessage;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _webSocketService.removeMessageListener(widget.groupId, _handleNewMessage);
    _messageController.dispose();
    _scrollController.dispose();
    _recordingService.dispose();
    AudioPlayerService().dispose();
    super.dispose();
  }

  /// Initializes chat by loading messages and connecting WebSocket
  Future<void> _initializeChat() async {
    await _loadMessages();
    await _connectWebSocket();
  }

  /// Loads messages from API
  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final loadedMessages = await ChatService.getMessages(
        widget.groupId,
        token,
      );

      setState(() => _messages = loadedMessages);
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackbar('Failed to load messages');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Connects to WebSocket for real-time updates
  Future<void> _connectWebSocket() async {
    final token = await AuthService.getAuthToken();
    if (token == null) return;

    try {
      await _webSocketService.connect(widget.groupId, token);

      _webSocketService.addMessageListener(widget.groupId, _handleNewMessage);
      _webSocketService.addConnectionListener(widget.groupId, () {
        _showSuccessSnackbar('Connected to chat');
      });
      _webSocketService.addErrorListener(widget.groupId, (error) {
        _showErrorSnackbar('Connection error');
      });
    } catch (e) {
      _showErrorSnackbar('Failed to connect to chat');
    }
  }

  /// Handles incoming WebSocket messages
  void _handleNewMessage(ChatMessage message) {
    if (!mounted) return;

    setState(() {
      final existingIndex = _messages.indexWhere((m) => m.id == message.id);

      if (existingIndex == -1) {
        _messages.add(message);
        _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else {
        _messages[existingIndex] = message;
      }
    });

    if (!message.isSentByCurrentUser) {
      _scrollToBottom();
    }
  }

  /// Sends a text message
  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _editingMessage == null) return;

    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => _isSending = true);

    try {
      if (_editingMessage != null) {
        await _editMessage(text, token);
      } else {
        await _sendNewMessage(text, token);
      }

      _messageController.clear();
      _clearReplyAndEdit();
    } catch (e) {
      _showErrorSnackbar('Failed to send message');
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// Edits an existing message
  Future<void> _editMessage(String text, String token) async {
    final success = await ChatService.updateMessage(
      widget.groupId,
      _editingMessage!.id,
      text,
      token,
    );

    if (success) {
      setState(() {
        final index = _messages.indexWhere((m) => m.id == _editingMessage!.id);
        if (index != -1) {
          final oldMessage = _messages[index];
          _messages[index] = ChatMessage(
            id: oldMessage.id,
            groupId: oldMessage.groupId,
            userId: oldMessage.userId,
            userEmail: oldMessage.userEmail,
            userProfileImage: oldMessage.userProfileImage,
            messageType: oldMessage.messageType,
            content: text,
            fileUrl: oldMessage.fileUrl,
            fileName: oldMessage.fileName,
            fileSize: oldMessage.fileSize,
            duration: oldMessage.duration,
            replyToMessageId: oldMessage.replyToMessageId,
            replyToMessage: oldMessage.replyToMessage,
            isEdited: true,
            isDeleted: oldMessage.isDeleted,
            createdAt: oldMessage.createdAt,
            updatedAt: DateTime.now(),
            reactions: oldMessage.reactions,
            isRead: oldMessage.isRead,
            isSentByCurrentUser: oldMessage.isSentByCurrentUser,
          );
        }
      });
    }
  }

  /// Sends a new message
  Future<void> _sendNewMessage(String text, String token) async {
    final message = await ChatService.sendMessage(
      groupId: widget.groupId,
      token: token,
      messageType: 'text',
      content: text,
      replyToMessageId: _replyingTo?.id,
    );

    if (message != null) {
      setState(() => _messages.add(message));
      _scrollToBottom();
    }
  }

  /// Sends an image message
  Future<void> _sendImage(File imageFile, String fileName) async {
    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => _isSending = true);

    try {
      final fileSize = await imageFile.length();
      final base64Image = await FileUtils.fileToBase64(imageFile);
      final dataUrl = FileUtils.createDataUrl(base64Image, fileName);

      final message = await ChatService.sendImageMessage(
        groupId: widget.groupId,
        token: token,
        imageBase64: dataUrl,
        fileName: fileName,
        fileSize: fileSize,
        replyToMessageId: _replyingTo?.id,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
          _clearReplyAndEdit();
        });
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to send image');
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// Sends an audio message
  Future<void> _sendAudio(File audioFile, String fileName, int duration) async {
    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => _isSending = true);

    try {
      final fileSize = await audioFile.length();
      final base64Audio = await FileUtils.fileToBase64(audioFile);
      final dataUrl = FileUtils.createDataUrl(base64Audio, fileName);

      final message = await ChatService.sendAudioMessage(
        groupId: widget.groupId,
        token: token,
        audioBase64: dataUrl,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
        replyToMessageId: _replyingTo?.id,
      );

      if (message != null) {
        setState(() {
          _messages.add(message);
          _clearReplyAndEdit();
        });
        _scrollToBottom();
      }
    } catch (e) {
      _showErrorSnackbar('Failed to send audio');
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// Deletes a message
  Future<void> _deleteMessage(ChatMessage message) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    final token = await AuthService.getAuthToken();
    if (token == null) return;

    final success = await ChatService.deleteMessage(
      widget.groupId,
      message.id,
      token,
    );

    if (success) {
      setState(() => _messages.removeWhere((m) => m.id == message.id));
    }
  }

  /// Shows image preview in full screen
  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
              ),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Scrolls to the bottom of the message list
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Clears reply and edit states
  void _clearReplyAndEdit() {
    setState(() {
      _replyingTo = null;
      _editingMessage = null;
    });
  }

  /// Shows confirmation dialog for message deletion
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Shows success snackbar
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: ChatHeaderWidget(
        groupName: widget.groupName,
        messageCount: _messages.length,
        onBack: () => Navigator.pop(context),
        onRefresh: _loadMessages,
      ),
      body: Column(
        children: [
          if (_replyingTo != null)
            _buildReplyHeader(_replyingTo!, () => _clearReplyAndEdit()),
          if (_editingMessage != null)
            _buildEditHeader(() => _clearReplyAndEdit()),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(),
          ),
          ChatInputWidget(
            messageController: _messageController,
            isRecording: _recordingService.isRecording,
            isSending: _isSending,
            onSendMessage: _sendTextMessage,
            onStartRecording: _recordingService.startRecording,
            onStopRecording: () async {
              final file = await _recordingService.stopRecording();
              if (file != null) {
                await _sendAudio(
                  file,
                  'recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
                  60, // Estimated duration
                );
              }
            },
            onShowAttachmentOptions: () => _showAttachmentOptions(context),
          ),
        ],
      ),
    );
  }

  /// Builds reply header
  Widget _buildReplyHeader(ChatMessage message, VoidCallback onCancel) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF324779).withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF324779),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${message.userEmail}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF324779),
                    fontFamily: 'Sarabun',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.messageType == 'text'
                      ? message.content ?? ''
                      : _getMessageTypeLabel(message.messageType),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontFamily: 'Sarabun',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }

  /// Builds edit header
  Widget _buildEditHeader(VoidCallback onCancel) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, size: 20, color: Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Editing message',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B35),
                fontFamily: 'Sarabun',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }

  /// Builds empty state for no messages
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF324779).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: Color(0xFF324779),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
              fontFamily: 'Sarabun',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to send a message!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'Sarabun',
            ),
          ),
        ],
      ),
    );
  }

  /// Builds message list
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ChatMessageBubble(
          message: message,
          onReply: () => setState(() => _replyingTo = message),
          onReact: () => _showReactionPicker(message),
          onEdit: message.isSentByCurrentUser && message.messageType == 'text'
              ? () {
            setState(() {
              _editingMessage = message;
              _messageController.text = message.content ?? '';
            });
          }
              : null,
          onDelete: message.isSentByCurrentUser
              ? () => _deleteMessage(message)
              : null,
          onImageTap: message.fileUrl != null
              ? () {
            final imageUrl = ApiConstants.buildFileUrl(message.fileUrl!);
            _showImagePreview(imageUrl);
          }
              : null,
        );
      },
    );
  }

  /// Shows reaction picker bottom sheet
  void _showReactionPicker(ChatMessage message) {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😡', '🎉', '🔥'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'React to message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sarabun',
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: reactions.map((emoji) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    final token = await AuthService.getAuthToken();
                    if (token == null) return;

                    await ChatService.addReaction(
                      widget.groupId,
                      message.id,
                      emoji,
                      token,
                    );

                    _loadMessages();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 32)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Shows attachment options bottom sheet
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildAttachmentOption(
              icon: Icons.image_rounded,
              color: const Color(0xFF0F9D58),
              label: 'Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            _buildAttachmentOption(
              icon: Icons.camera_alt_rounded,
              color: const Color(0xFF9B59B6),
              label: 'Camera',
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            _buildAttachmentOption(
              icon: Icons.attach_file_rounded,
              color: const Color(0xFF324779),
              label: 'File',
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontFamily: 'Sarabun')),
      onTap: onTap,
    );
  }

  Future<void> _pickImageFromGallery() async {
    // Implement image picker from gallery
  }

  Future<void> _pickImageFromCamera() async {
    // Implement image picker from camera
  }

  Future<void> _pickFile() async {
    // Implement file picker
  }

  String _getMessageTypeLabel(String type) {
    switch (type) {
      case 'image':
        return '📷 Image';
      case 'audio':
        return '🎤 Audio';
      case 'file':
        return '📎 File';
      default:
        return 'Message';
    }
  }
}