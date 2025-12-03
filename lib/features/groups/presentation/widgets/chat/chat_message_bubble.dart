import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/utils/file_utils.dart';
import '../../../domain/models/chats/chat_message.dart';
import '../../../domain/models/chats/message_reaction.dart';
import '../../../services/chat/audio_player_service.dart';

/// Widget that displays a single chat message with support for text,
/// images, audio, files, reactions, and replies.
class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onReply;
  final VoidCallback? onReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onImageTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onReply,
    this.onReact,
    this.onEdit,
    this.onDelete,
    this.onImageTap,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  final AudioPlayerService _audioService = AudioPlayerService();
  bool _isAudioPlaying = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  String _audioUrl = '';

  @override
  void initState() {
    super.initState();
    _audioUrl = _getAudioUrl();
    _setupAudioListeners();
    _initializeAudioState();
  }

  @override
  void dispose() {
    // CORRECCIÓN: Usar removeListeners en lugar de setPlayStateListener(null)
    _audioService.removeListeners(_audioUrl);
    super.dispose();
  }

  /// Sets up audio playback state listeners
  void _setupAudioListeners() {
    if (_audioUrl.isEmpty) return;

    // Configurar listeners usando los nuevos métodos
    _audioService.setPlayStateListener(_audioUrl, (bool isPlaying) {
      if (!mounted) return;
      setState(() => _isAudioPlaying = isPlaying);
    });

    _audioService.setPositionListener(_audioUrl, (
      Duration position,
      Duration duration,
    ) {
      if (!mounted) return;
      setState(() {
        _audioPosition = position;
        if (duration.inSeconds > 0) {
          _audioDuration = duration;
        }
      });
    });
  }

  /// Initializes audio state for this message
  void _initializeAudioState() {
    if (_audioUrl.isEmpty) return;

    setState(() {
      _isAudioPlaying = _audioService.isPlaying(_audioUrl);
      _audioPosition = _audioService.getCurrentPosition(_audioUrl);
      _audioDuration = Duration(seconds: widget.message.duration ?? 0);
    });
  }

  /// Gets the full URL for audio files
  String _getAudioUrl() {
    if (widget.message.fileUrl == null || widget.message.fileUrl!.isEmpty) {
      return '';
    }

    // Usar la constante centralizada para construir URLs
    return ApiConstants.buildAudioUrl(widget.message.fileUrl);
  }

  /// Toggles audio playback for this message
  Future<void> _toggleAudioPlayback() async {
    try {
      if (_audioUrl.isEmpty) return;

      if (_audioService.isPlaying(_audioUrl)) {
        await _audioService.pauseAudio();
      } else {
        await _audioService.playAudio(_audioUrl);
      }
    } catch (e) {
      _showErrorSnackbar('Error playing audio: ${e.toString()}');
    }
  }

  /// Seeks to a specific position in the audio
  void _seekAudio(double value) {
    final newPosition = Duration(seconds: value.toInt());
    _audioService.seekAudio(newPosition);

    if (mounted) {
      setState(() => _audioPosition = newPosition);
    }
  }

  /// Shows an error snackbar
  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isSentByCurrentUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 16,
        right: isMe ? 16 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe) _buildSenderName(),
          GestureDetector(
            onLongPress: () => _showMessageOptions(context),
            child: Container(
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF324779) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.replyToMessage != null)
                    _buildReplyPreview(isMe),
                  _buildMessageContent(isMe),
                  if (widget.message.reactions.isNotEmpty) _buildReactions(),
                ],
              ),
            ),
          ),
          _buildMessageFooter(isMe),
        ],
      ),
    );
  }

  /// Builds sender name for messages from other users
  Widget _buildSenderName() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        widget.message.userEmail.split('@')[0],
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF324779),
          fontFamily: 'Sarabun',
        ),
      ),
    );
  }

  /// Builds reply preview when message is a reply
  Widget _buildReplyPreview(bool isMe) {
    final reply = widget.message.replyToMessage!;
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : const Color(0xFF324779),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.userEmail,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isMe ? Colors.white70 : Colors.black87,
            ),
          ),
          Text(
            reply.content ?? 'Attachment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: isMe ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main message content based on type
  Widget _buildMessageContent(bool isMe) {
    switch (widget.message.messageType) {
      case 'text':
        return _buildTextMessage(isMe);
      case 'image':
        return _buildImageMessage(isMe);
      case 'audio':
        return _buildAudioMessage(isMe);
      case 'file':
        return _buildFileMessage(isMe);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Builds text message content
  Widget _buildTextMessage(bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        widget.message.content ?? '',
        style: TextStyle(
          fontSize: 15,
          color: isMe ? Colors.white : const Color(0xFF333333),
          height: 1.4,
          fontFamily: 'Sarabun',
        ),
      ),
    );
  }

  /// Builds image message content
  Widget _buildImageMessage(bool isMe) {
    return GestureDetector(
      onTap: widget.onImageTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.message.fileUrl != null
            ? _buildImageWidget()
            : const Icon(Icons.error),
      ),
    );
  }

  /// Builds image widget handling both base64 and URL images
  Widget _buildImageWidget() {
    final fileUrl = widget.message.fileUrl!;

    if (fileUrl.startsWith('data:')) {
      final base64String = fileUrl.split(',').last;
      try {
        return Image.memory(
          base64.decode(base64String),
          width: 250,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildImageError(),
        );
      } catch (e) {
        return _buildImageError();
      }
    } else {
      final imageUrl = ApiConstants.buildFileUrl(fileUrl);
      return Image.network(
        imageUrl,
        width: 250,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoading();
        },
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }
  }

  Widget _buildImageLoading() {
    return Container(
      width: 250,
      height: 200,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: 250,
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
    );
  }

  /// Builds audio message content
  Widget _buildAudioMessage(bool isMe) {
    if (_audioUrl.isEmpty) {
      return _buildUnavailableAudioMessage(isMe);
    }

    final durationSeconds = _audioDuration.inSeconds > 0
        ? _audioDuration.inSeconds.toDouble()
        : (widget.message.duration ?? 0).toDouble();

    final positionSeconds = _audioPosition.inSeconds.toDouble();
    final safePosition = positionSeconds.clamp(
      0.0,
      durationSeconds > 0 ? durationSeconds : 1.0,
    );

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          _buildAudioPlayButton(isMe),
          const SizedBox(width: 12),
          _buildAudioControls(isMe, safePosition, durationSeconds),
        ],
      ),
    );
  }

  Widget _buildAudioPlayButton(bool isMe) {
    return GestureDetector(
      onTap: _toggleAudioPlayback,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (!isMe) BoxShadow(color: Colors.black12, blurRadius: 2),
          ],
        ),
        child: Icon(
          _isAudioPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: isMe ? Colors.white : const Color(0xFF324779),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAudioControls(bool isMe, double position, double duration) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              trackHeight: 3,
              activeTrackColor: isMe ? Colors.white : const Color(0xFF324779),
              inactiveTrackColor: isMe ? Colors.white30 : Colors.grey[300],
              thumbColor: isMe ? Colors.white : const Color(0xFF324779),
            ),
            child: Slider(
              value: position,
              min: 0,
              max: duration > 0 ? duration : 1.0,
              onChanged: _seekAudio,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_audioPosition.inSeconds),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                Text(
                  _formatDuration(duration.toInt()),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableAudioMessage(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: isMe ? Colors.white70 : Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Audio unavailable',
            style: TextStyle(color: isMe ? Colors.white : Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Builds file message content
  Widget _buildFileMessage(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFileIcon(isMe),
          const SizedBox(width: 12),
          _buildFileInfo(isMe),
        ],
      ),
    );
  }

  Widget _buildFileIcon(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.2)
            : const Color(0xFF324779).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getFileIcon(widget.message.fileName ?? ''),
        color: isMe ? Colors.white : const Color(0xFF324779),
        size: 24,
      ),
    );
  }

  Widget _buildFileInfo(bool isMe) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message.fileName ?? 'File',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isMe ? Colors.white : const Color(0xFF333333),
              fontFamily: 'Sarabun',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            FileUtils.formatFileSize(widget.message.fileSize ?? 0),
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
              fontFamily: 'Sarabun',
            ),
          ),
        ],
      ),
    );
  }

  /// Builds reactions on the message
  Widget _buildReactions() {
    final reactionGroups = <String, List<MessageReaction>>{};
    for (var reaction in widget.message.reactions) {
      reactionGroups.putIfAbsent(reaction.reaction, () => []).add(reaction);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactionGroups.entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF324779).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.key, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${entry.value.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF324779),
                    fontFamily: 'Sarabun',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds message footer with timestamp and read status
  Widget _buildMessageFooter(bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(widget.message.createdAt),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              widget.message.isRead ? Icons.done_all : Icons.done,
              size: 14,
              color: widget.message.isRead
                  ? const Color(0xFF0F9D58)
                  : Colors.grey[500],
            ),
          ],
        ],
      ),
    );
  }

  /// Shows message options bottom sheet
  void _showMessageOptions(BuildContext context) {
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
            const _BottomSheetHandle(),
            const SizedBox(height: 8),
            const _BottomSheetTitle('Message Options'),
            const SizedBox(height: 16),
            _buildOptionTile(
              icon: Icons.reply_rounded,
              label: 'Reply',
              color: const Color(0xFF324779),
              onTap: () {
                Navigator.pop(context);
                widget.onReply?.call();
              },
            ),
            _buildOptionTile(
              icon: Icons.add_reaction_outlined,
              label: 'React',
              color: const Color(0xFF324779),
              onTap: () {
                Navigator.pop(context);
                widget.onReact?.call();
              },
            ),
            if (widget.message.isSentByCurrentUser &&
                widget.message.messageType == 'text')
              _buildOptionTile(
                icon: Icons.edit_rounded,
                label: 'Edit',
                color: const Color(0xFF324779),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
              ),
            if (widget.message.isSentByCurrentUser)
              _buildOptionTile(
                icon: Icons.delete_rounded,
                label: 'Delete',
                color: const Color(0xFFD32F2F),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(fontFamily: 'Sarabun', color: color),
      ),
      onTap: onTap,
    );
  }

  /// Formats time for display
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  /// Formats duration in MM:SS format
  String _formatDuration(int seconds) {
    if (seconds < 0) seconds = 0;

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// Gets appropriate icon for file type
  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}

/// Reusable bottom sheet handle widget
class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Reusable bottom sheet title widget
class _BottomSheetTitle extends StatelessWidget {
  final String title;

  const _BottomSheetTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
