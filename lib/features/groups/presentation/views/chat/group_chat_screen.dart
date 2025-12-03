import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:record/record.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../auth/application/auth_service.dart';
import '../../../services/chat/audio_player_service.dart';
import '../../../services/chat/chat_service.dart';
import '../../../domain/models/chat_message.dart';
import '../../../services/chat/chat_websocket_service.dart';
import '../../widgets/chat/chat_message_bubble.dart';
import 'package:path_provider/path_provider.dart';

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
  final AudioRecorder _audioRecorder = AudioRecorder();

  List<ChatMessage> messages = [];
  bool isLoading = true;
  bool isSending = false;
  bool isRecording = false;
  String? _currentAudioPath;
  ChatMessage? replyingTo;
  ChatMessage? editingMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
    _initializeAudioService();
  }

  void _initializeAudioService() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioService = AudioPlayerService();
      audioService.init();
    });
  }

  @override
  void dispose() {
    ChatWebSocketService.removeMessageListener(
      widget.groupId,
      _handleNewMessage,
    );
    super.dispose();
  }

  void _connectWebSocket() async {
    print('🔗 Connecting WebSocket for group ${widget.groupId}');

    final token = await AuthService.getAuthToken();
    if (token == null) {
      print('❌ No auth token available');
      return;
    }

    try {
      // Remover listeners antiguos primero
      ChatWebSocketService.removeMessageListener(
        widget.groupId,
        _handleNewMessage,
      );

      // Conectar WebSocket
      ChatWebSocketService.connect(widget.groupId, token);

      // Agregar listeners
      ChatWebSocketService.addMessageListener(
        widget.groupId,
        _handleNewMessage,
      );

      ChatWebSocketService.addConnectionListener(widget.groupId, () {
        print('✅ WebSocket connected for group ${widget.groupId}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connected to chat'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });

      ChatWebSocketService.addErrorListener(widget.groupId, (error) {
        print('❌ WebSocket error: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Connection error: ${error.toString()}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });

      ChatWebSocketService.addDisconnectionListener(widget.groupId, () {
        print('🔌 WebSocket disconnected from group ${widget.groupId}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection lost. Reconnecting...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } catch (e) {
      print('❌ WebSocket Connection Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleNewMessage(ChatMessage message) {
    if (!mounted) return;

    print(
      '🆕 WebSocket - New message received: ${message.id}, Type: ${message.messageType}',
    );

    setState(() {
      // Verificar si el mensaje ya existe
      final existingIndex = messages.indexWhere((m) => m.id == message.id);

      if (existingIndex == -1) {
        // Mensaje nuevo
        messages.add(message);
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        print('✅ Added new message, total: ${messages.length}');
      } else {
        // Actualizar mensaje existente
        messages[existingIndex] = message;
        print('🔄 Updated existing message');
      }
    });

    // Desplazar al final si el mensaje es nuevo
    if (message.isSentByCurrentUser != true) {
      _scrollToBottom();
    }
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
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

  Future<void> _loadMessages() async {
    print('🔄 LOAD MESSAGES - Starting...');
    setState(() => isLoading = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) {
        print('❌ LOAD MESSAGES - No auth token');
        return;
      }

      print('🔄 LOAD MESSAGES - GroupId: ${widget.groupId}');

      final loadedMessages = await ChatService.getMessages(
        widget.groupId,
        token,
      );

      print('🔄 LOAD MESSAGES - Loaded ${loadedMessages.length} messages');

      setState(() => messages = loadedMessages);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          print('🔄 LOAD MESSAGES - Scrolled to bottom');
        }
      });
    } catch (e) {
      print('❌ LOAD MESSAGES - Error: $e');
    } finally {
      setState(() => isLoading = false);
      print('🏁 LOAD MESSAGES - Finished, isLoading: false');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && editingMessage == null)
      return;
    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => isSending = true);

    try {
      if (editingMessage != null) {
        print('✏️ MESSAGE - Editing message ID: ${editingMessage!.id}');

        final success = await ChatService.updateMessage(
          widget.groupId,
          editingMessage!.id,
          _messageController.text.trim(),
          token,
        );

        print('✏️ MESSAGE - Edit result: $success');

        if (success) {
          setState(() {
            final index = messages.indexWhere(
              (m) => m.id == editingMessage!.id,
            );
            if (index != -1) {
              messages[index] = ChatMessage(
                id: messages[index].id,
                groupId: messages[index].groupId,
                userId: messages[index].userId,
                userEmail: messages[index].userEmail,
                userProfileImage: messages[index].userProfileImage,
                messageType: messages[index].messageType,
                content: _messageController.text.trim(),
                fileUrl: messages[index].fileUrl,
                fileName: messages[index].fileName,
                fileSize: messages[index].fileSize,
                duration: messages[index].duration,
                replyToMessageId: messages[index].replyToMessageId,
                replyToMessage: messages[index].replyToMessage,
                isEdited: true,
                isDeleted: messages[index].isDeleted,
                createdAt: messages[index].createdAt,
                updatedAt: DateTime.now(),
                reactions: messages[index].reactions,
                isRead: messages[index].isRead,
                isSentByCurrentUser: messages[index].isSentByCurrentUser,
              );
            }
            editingMessage = null;
          });
          print('✅ MESSAGE - Edit successful');
        } else {
          print('❌ MESSAGE - Edit failed');
        }
      } else {
        final message = await ChatService.sendMessage(
          groupId: widget.groupId,
          token: token,
          messageType: 'text',
          content: _messageController.text.trim(),
          replyToMessageId: replyingTo?.id,
        );

        print('📤 MESSAGE - Send result: ${message != null}');

        if (message != null) {
          setState(() {
            messages.add(message);
            replyingTo = null;
          });
          _scrollToBottom();
          print('✅ MESSAGE - Added to UI, total messages: ${messages.length}');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else {
          print('❌ MESSAGE - Send returned null');
        }
      }

      _messageController.clear();
      print('✅ MESSAGE - Process completed');
      _messageController.clear();
    } catch (e) {
      print('❌ MESSAGE - Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _sendImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image == null) return;

    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => isSending = true);

    try {
      final file = File(image.path);
      final fileSize = await file.length();

      // Convertir imagen a Base64
      final base64Image = await ChatService.fileToBase64(file);
      final dataUrl = ChatService.createDataUrl(base64Image, image.name);

      final message = await ChatService.sendMessage(
        groupId: widget.groupId,
        token: token,
        messageType: 'image',
        fileBase64: dataUrl,
        fileName: image.name,
        fileSize: fileSize,
        replyToMessageId: replyingTo?.id,
      );

      if (message != null) {
        setState(() {
          messages.add(message);
          replyingTo = null;
        });

        _scrollToBottom();
      }
    } catch (e) {
      print('Error sending image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending image: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _sendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => isSending = true);

    try {
      final file = File(result.files.first.path!);
      final fileSize = result.files.first.size;
      final fileName = result.files.first.name;

      // Convertir archivo a Base64
      final base64File = await ChatService.fileToBase64(file);
      final dataUrl = ChatService.createDataUrl(base64File, fileName);

      final message = await ChatService.sendMessage(
        groupId: widget.groupId,
        token: token,
        messageType: 'file',
        fileBase64: dataUrl,
        fileName: fileName,
        fileSize: fileSize,
        replyToMessageId: replyingTo?.id,
      );

      if (message != null) {
        setState(() {
          messages.add(message);
          replyingTo = null;
        });

        _scrollToBottom();
      }
    } catch (e) {
      print('Error sending file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending file: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission denied'),
              backgroundColor: Color(0xFFD32F2F),
            ),
          );
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      _currentAudioPath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentAudioPath!,
      );

      setState(() => isRecording = true);
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => isRecording = false);

    if (path == null) return;

    final token = await AuthService.getAuthToken();
    if (token == null) return;

    setState(() => isSending = true);

    try {
      final file = File(path);
      final fileSize = await file.length();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Convertir audio a Base64
      final base64Audio = await ChatService.fileToBase64(file);
      final dataUrl = ChatService.createDataUrl(base64Audio, fileName);

      const duration = 60;

      final message = await ChatService.sendMessage(
        groupId: widget.groupId,
        token: token,
        messageType: 'audio',
        fileBase64: dataUrl,
        fileName: fileName,
        fileSize: fileSize,
        duration: duration,
        replyToMessageId: replyingTo?.id,
      );

      if (message != null) {
        setState(() {
          messages.add(message);
          replyingTo = null;
        });

        _scrollToBottom();
      }
    } catch (e) {
      print('Error sending audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending audio: $e'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    final confirm = await showDialog<bool>(
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
    );

    if (confirm != true) return;

    final token = await AuthService.getAuthToken();
    if (token == null) return;

    final success = await ChatService.deleteMessage(
      widget.groupId,
      message.id,
      token,
    );

    if (success) {
      setState(() {
        messages.removeWhere((m) => m.id == message.id);
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF324779),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Sarabun',
              ),
            ),
            Text(
              '${messages.length} messages',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontFamily: 'Sarabun',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          if (replyingTo != null) _buildReplyingToBar(),
          if (editingMessage != null) _buildEditingBar(),

          // FIX: Use Expanded with proper constraints
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? _buildEmptyState()
                : Container(
                    constraints: const BoxConstraints.expand(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        print(
                          '📱 Rendering message ${message.id} - Type: ${message.messageType} - FileUrl: ${message.fileUrl}',
                        );
                        return ChatMessageBubble(
                          message: message,
                          onReply: () => setState(() => replyingTo = message),
                          onReact: () => _showReactionPicker(message),
                          onEdit:
                              message.isSentByCurrentUser &&
                                  message.messageType == 'text'
                              ? () {
                                  setState(() {
                                    editingMessage = message;
                                    _messageController.text =
                                        message.content ?? '';
                                  });
                                }
                              : null,
                          onDelete: message.isSentByCurrentUser
                              ? () => _deleteMessage(message)
                              : null,
                          onImageTap: () {
                            if (message.fileUrl != null) {
                              String imageUrl = ApiConstants.buildFileUrl(
                                message.fileUrl!,
                              );
                              _showImagePreview(imageUrl);
                            }
                          },
                        );
                      },
                    ),
                  ),
          ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildReplyingToBar() {
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
                  'Replying to ${replyingTo!.userEmail}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF324779),
                    fontFamily: 'Sarabun',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyingTo!.messageType == 'text'
                      ? replyingTo!.content ?? ''
                      : _getMessageTypeLabel(replyingTo!.messageType),
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
            onPressed: () => setState(() => replyingTo = null),
          ),
        ],
      ),
    );
  }

  Widget _buildEditingBar() {
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
            onPressed: () {
              setState(() {
                editingMessage = null;
                _messageController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

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

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        // REMOVE SafeArea from here since we wrapped the entire body
        children: [
          if (!isRecording) ...[
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF324779),
              ),
              onPressed: () => _showAttachmentOptions(),
            ),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: isRecording
                  ? Row(
                      children: [
                        const Icon(
                          Icons.mic_rounded,
                          color: Color(0xFFD32F2F),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recording...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontFamily: 'Sarabun',
                            ),
                          ),
                        ),
                      ],
                    )
                  : TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(fontFamily: 'Sarabun'),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'Sarabun'),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
            ),
          ),
          const SizedBox(width: 8),
          if (isRecording)
            IconButton(
              icon: const Icon(Icons.stop_rounded, color: Color(0xFFD32F2F)),
              onPressed: _stopRecording,
            )
          else if (_messageController.text.isEmpty && !isSending)
            IconButton(
              icon: const Icon(Icons.mic_rounded, color: Color(0xFF324779)),
              onPressed: _startRecording,
            )
          else
            isSending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF324779),
                    ),
                    onPressed: _sendMessage,
                  ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
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
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F9D58).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: Color(0xFF0F9D58),
                ),
              ),
              title: const Text(
                'Photo',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () {
                Navigator.pop(context);
                _sendImage();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF324779).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_file_rounded,
                  color: Color(0xFF324779),
                ),
              ),
              title: const Text(
                'File',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () {
                Navigator.pop(context);
                _sendFile();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF9B59B6),
                ),
              ),
              title: const Text(
                'Camera',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  // Usar la misma lógica de _sendImage
                  final token = await AuthService.getAuthToken();
                  if (token == null) return;

                  setState(() => isSending = true);

                  try {
                    final file = File(image.path);
                    final fileSize = await file.length();
                    final base64Image = await ChatService.fileToBase64(file);
                    final dataUrl = ChatService.createDataUrl(
                      base64Image,
                      image.name,
                    );

                    final message = await ChatService.sendMessage(
                      groupId: widget.groupId,
                      token: token,
                      messageType: 'image',
                      fileBase64: dataUrl,
                      fileName: image.name,
                      fileSize: fileSize,
                      replyToMessageId: replyingTo?.id,
                    );

                    if (message != null) {
                      setState(() {
                        messages.add(message);
                        replyingTo = null;
                      });
                      _scrollToBottom();
                    }
                  } catch (e) {
                    print('Error sending camera image: $e');
                  } finally {
                    setState(() => isSending = false);
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
