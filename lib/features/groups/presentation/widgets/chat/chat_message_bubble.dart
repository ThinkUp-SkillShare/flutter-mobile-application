import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../domain/models/chat_message.dart';
import '../../../services/chat/audio_player_service.dart';

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
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    _currentAudioUrl = _getAudioUrl();
    _setupAudioListeners();
    _initializeAudioState();
  }

  void _setupAudioListeners() {
    final myAudioUrl = _getAudioUrl();

    print('🎵 Setting up audio listeners for: $myAudioUrl');

    _audioService.setPlayStateListener((String audioUrl, bool isPlaying) {
      print(
        '🎵 Play state listener - URL: $audioUrl, Playing: $isPlaying, My URL: $myAudioUrl',
      );

      if (mounted) {
        if (audioUrl == myAudioUrl) {
          print('🎵 Updating play state for this message: $isPlaying');
          setState(() {
            _isAudioPlaying = isPlaying;
          });
        } else if (_isAudioPlaying && audioUrl != myAudioUrl) {
          // Si otro audio empezó a reproducirse, pausar este
          print('🎵 Another audio started, pausing this one');
          setState(() {
            _isAudioPlaying = false;
          });
        }
      }
    });

    _audioService.setPositionListener((
      String audioUrl,
      Duration position,
      Duration duration,
    ) {
      if (mounted && audioUrl == myAudioUrl) {
        setState(() {
          _audioPosition = position;
          if (duration.inSeconds > 0) {
            _audioDuration = duration;
          }
        });
      }
    });
  }

  void _initializeAudioState() {
    final audioUrl = _getAudioUrl();

    if (audioUrl.isNotEmpty) {
      final isCurrentlyPlaying = _audioService.isPlaying(audioUrl);

      setState(() {
        _currentAudioUrl = audioUrl;
        _isAudioPlaying = isCurrentlyPlaying;
        _audioPosition = _audioService.getCurrentPosition(audioUrl);
        _audioDuration = Duration(seconds: widget.message.duration ?? 0);
      });

      print(
        '🎵 Initial state - Playing: $isCurrentlyPlaying, Duration: ${_audioDuration.inSeconds}s',
      );
    }
  }

  String _getAudioUrl() {
    if (widget.message.fileUrl == null || widget.message.fileUrl!.isEmpty) {
      return '';
    }

    if (widget.message.fileUrl!.startsWith('http') ||
        widget.message.fileUrl!.startsWith('data:')) {
      return widget.message.fileUrl!;
    }

    return 'http://192.168.0.206:5118/uploads/audio/${widget.message.fileUrl!}';
  }

  void _toggleAudioPlayback() async {
    try {
      final audioUrl = _getAudioUrl();
      print('🎵 Toggling playback for: $audioUrl');

      if (audioUrl.isEmpty) {
        print('❌ Empty audio URL');
        return;
      }

      if (_audioService.isPlaying(audioUrl)) {
        print('🎵 Pausing audio');
        await _audioService.pauseAudio();
      } else {
        print('🎵 Playing audio');
        await _audioService.playAudio(audioUrl);
      }
    } catch (e, stackTrace) {
      print('❌ Error toggling audio playback: $e');
      print('❌ Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _seekAudio(double value) {
    final newPosition = Duration(seconds: value.toInt());
    _audioService.seekAudio(newPosition);

    if (mounted) {
      setState(() {
        _audioPosition = newPosition;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
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
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 4),
              child: Text(
                widget.message.userEmail.split('@')[0],
                // Mostrar solo nombre antes del @
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
                  if (widget.message.replyToMessage != null)
                    _buildReplyPreview(isMe),
                  _buildMessageContent(isMe),
                  if (widget.message.reactions.isNotEmpty) _buildReactions(),
                ],
              ),
            ),
          ),
          // Timestamp row...
          Padding(
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
          ),
        ],
      ),
    );
  }

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
            reply.content ?? 'Archivo adjunto',
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

  Widget _buildMessageContent(bool isMe) {
    switch (widget.message.messageType) {
      case 'text':
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
      case 'image':
        return _buildImageMessage(isMe);
      case 'audio':
        if (widget.message.fileUrl != null &&
            widget.message.fileUrl!.isNotEmpty) {
          return _buildAudioMessage(isMe);
        } else {
          return _buildUnavailableAudioMessage(isMe);
        }
      case 'file':
        return _buildFileMessage(isMe);
      default:
        return const SizedBox.shrink();
    }
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
            'Audio no disponible',
            style: TextStyle(color: isMe ? Colors.white : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(bool isMe) {
    return GestureDetector(
      onTap: widget.onImageTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.message.fileUrl != null
            ? _buildImageFromBase64OrUrl(widget.message.fileUrl!)
            : const Icon(Icons.error),
      ),
    );
  }

  Widget _buildImageFromBase64OrUrl(String fileUrl) {
    if (fileUrl.startsWith('data:')) {
      final base64String = fileUrl.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        width: 250,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      final imageUrl = 'http://192.168.0.206:5118/uploads/images/$fileUrl';
      return Image.network(
        imageUrl,
        width: 250,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 250,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildAudioMessage(bool isMe) {
    // Usar la duración real del audio si está disponible, sino usar la del mensaje
    final durationSeconds = _audioDuration.inSeconds > 0
        ? _audioDuration.inSeconds.toDouble()
        : (widget.message.duration ?? 0).toDouble();

    final positionSeconds = _audioPosition.inSeconds.toDouble();
    final safePosition = positionSeconds.clamp(
      0.0,
      durationSeconds > 0 ? durationSeconds : 1.0,
    );

    print(
      '🎵 BUILDING AUDIO MESSAGE - '
      'Playing: $_isAudioPlaying, '
      'Position: $positionSeconds, '
      'Duration: $durationSeconds',
    );

    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Botón de play/pause
          GestureDetector(
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
                _isAudioPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: isMe ? Colors.white : const Color(0xFF324779),
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Barra de progreso y tiempos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de progreso
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    trackHeight: 3,
                    activeTrackColor: isMe
                        ? Colors.white
                        : const Color(0xFF324779),
                    inactiveTrackColor: isMe
                        ? Colors.white30
                        : Colors.grey[300],
                    thumbColor: isMe ? Colors.white : const Color(0xFF324779),
                  ),
                  child: Slider(
                    value: safePosition,
                    min: 0,
                    max: durationSeconds > 0 ? durationSeconds : 1.0,
                    onChanged: _seekAudio,
                  ),
                ),

                // Tiempos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tiempo transcurrido
                      Text(
                        _formatDuration(_audioPosition.inSeconds),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),

                      // Duración total
                      Text(
                        _formatDuration(durationSeconds.toInt()),
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
          ),
          const SizedBox(width: 12),
          Flexible(
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
                  _formatFileSize(widget.message.fileSize ?? 0),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
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
              leading: const Icon(
                Icons.reply_rounded,
                color: Color(0xFF324779),
              ),
              title: const Text(
                'Reply',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onReply?.call();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.add_reaction_outlined,
                color: Color(0xFF324779),
              ),
              title: const Text(
                'React',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onReact?.call();
              },
            ),
            if (widget.message.isSentByCurrentUser &&
                widget.message.messageType == 'text') ...[
              ListTile(
                leading: const Icon(
                  Icons.edit_rounded,
                  color: Color(0xFF324779),
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(fontFamily: 'Sarabun'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call();
                },
              ),
            ],
            if (widget.message.isSentByCurrentUser) ...[
              ListTile(
                leading: const Icon(
                  Icons.delete_rounded,
                  color: Color(0xFFD32F2F),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Sarabun',
                    color: Color(0xFFD32F2F),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete?.call();
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
    if (seconds < 0) seconds = 0;

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '0:${remainingSeconds.toString().padLeft(2, '0')}';
    }
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
