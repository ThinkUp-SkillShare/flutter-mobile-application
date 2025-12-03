import 'package:flutter/material.dart';

class ChatInputWidget extends StatelessWidget {
  final TextEditingController messageController;
  final bool isRecording;
  final bool isSending;
  final VoidCallback onSendMessage;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onShowAttachmentOptions;

  const ChatInputWidget({
    super.key,
    required this.messageController,
    required this.isRecording,
    required this.isSending,
    required this.onSendMessage,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onShowAttachmentOptions,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          if (!isRecording)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF324779)),
              onPressed: onShowAttachmentOptions,
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: isRecording
                  ? _buildRecordingUI()
                  : TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(fontFamily: 'Sarabun'),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontFamily: 'Sarabun'),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildRecordingUI() {
    return Row(
      children: [
        const Icon(Icons.mic_rounded, color: Color(0xFFD32F2F), size: 24),
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
    );
  }

  Widget _buildActionButton() {
    if (isRecording) {
      return IconButton(
        icon: const Icon(Icons.stop_rounded, color: Color(0xFFD32F2F)),
        onPressed: onStopRecording,
      );
    } else if (messageController.text.isEmpty && !isSending) {
      return IconButton(
        icon: const Icon(Icons.mic_rounded, color: Color(0xFF324779)),
        onPressed: onStartRecording,
      );
    } else if (isSending) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.send_rounded, color: Color(0xFF324779)),
        onPressed: onSendMessage,
      );
    }
  }
}