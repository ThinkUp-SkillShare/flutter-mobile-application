import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onReply;
  final VoidCallback? onReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onImageTap;
  final VoidCallback? onAudioPlay;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onReply,
    this.onReact,
    this.onEdit,
    this.onDelete,
    this.onImageTap,
    this.onAudioPlay,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByCurrentUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 16,
        right: isMe ? 16 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                message.userEmail,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF324779),
                  fontFamily: 'Sarabun',
                ),
              ),
            ),
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
                  if (message.replyToMessage != null) _buildReplyPreview(isMe),
                  _buildMessageContent(isMe),
                  if (message.reactions.isNotEmpty) _buildReactions(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontFamily: 'Sarabun',
                  ),
                ),
                if (message.isEdited) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(edited)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                ],
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead ? const Color(0xFF0F9D58) : Colors.grey[500],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(bool isMe) {
    final reply = message.replyToMessage!;
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white : const Color(0xFF324779),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isMe ? Colors.white : const Color(0xFF324779),
              fontFamily: 'Sarabun',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reply.messageType == 'text'
                ? reply.content ?? ''
                : _getMessageTypeLabel(reply.messageType),
            style: TextStyle(
              fontSize: 12,
              color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[700],
              fontFamily: 'Sarabun',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isMe) {
    switch (message.messageType) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message.content ?? '',
            style: TextStyle(
              fontSize: 15,
              color: isMe ? Colors.white : const Color(0xFF333333),
              height: 1.4,
              fontFamily: 'Sarabun',
            ),
          ),
        );
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

  Widget _buildImageMessage(bool isMe) {
    return GestureDetector(
      onTap: onImageTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.network(
              message.fileUrl ?? '',
              width: 250,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 250,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 250,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
            if (message.content != null && message.content!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  child: Text(
                    message.content!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Sarabun',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onAudioPlay,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.2) : const Color(0xFF324779).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: isMe ? Colors.white : const Color(0xFF324779),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  20,
                      (index) => Container(
                    width: 3,
                    height: (index % 3 + 1) * 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white.withOpacity(0.6) : const Color(0xFF324779).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(message.duration ?? 0),
                style: TextStyle(
                  fontSize: 12,
                  color: isMe ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                  fontFamily: 'Sarabun',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(bool isMe) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.white.withOpacity(0.2) : const Color(0xFF324779).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(message.fileName ?? ''),
              color: isMe ? Colors.white : const Color(0xFF324779),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
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
                  _formatFileSize(message.fileSize ?? 0),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    fontFamily: 'Sarabun',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactions() {
    final reactionGroups = <String, List<MessageReaction>>{};
    for (var reaction in message.reactions) {
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
              border: Border.all(color: const Color(0xFF324779).withOpacity(0.2)),
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
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.reply_rounded, color: Color(0xFF324779)),
              title: const Text('Reply', style: TextStyle(fontFamily: 'Sarabun')),
              onTap: () {
                Navigator.pop(context);
                onReply?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_reaction_outlined, color: Color(0xFF324779)),
              title: const Text('React', style: TextStyle(fontFamily: 'Sarabun')),
              onTap: () {
                Navigator.pop(context);
                onReact?.call();
              },
            ),
            if (message.isSentByCurrentUser && message.messageType == 'text') ...[
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Color(0xFF324779)),
                title: const Text('Edit', style: TextStyle(fontFamily: 'Sarabun')),
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
            ],
            if (message.isSentByCurrentUser) ...[
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Color(0xFFD32F2F)),
                title: const Text('Delete', style: TextStyle(fontFamily: 'Sarabun', color: Color(0xFFD32F2F))),
                onTap: () {
                  Navigator.pop(context);
                  onDelete?.call();
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

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