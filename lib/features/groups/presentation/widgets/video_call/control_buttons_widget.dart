import 'package:flutter/material.dart';

class ControlButtonsWidget extends StatelessWidget {
  final bool isMuted;
  final bool isVideoEnabled;
  final VoidCallback onToggleAudio;
  final VoidCallback onToggleVideo;
  final VoidCallback onSwitchCamera;
  final VoidCallback onLeaveCall;
  final VoidCallback onShowParticipants;

  const ControlButtonsWidget({
    super.key,
    required this.isMuted,
    required this.isVideoEnabled,
    required this.onToggleAudio,
    required this.onToggleVideo,
    required this.onSwitchCamera,
    required this.onLeaveCall,
    required this.onShowParticipants,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: isMuted ? Icons.mic_off : Icons.mic,
              backgroundColor: isMuted ? Colors.red : Colors.white24,
              onPressed: onToggleAudio,
              tooltip: isMuted ? 'Unmute' : 'Mute',
            ),
            _buildControlButton(
              icon: isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              backgroundColor: isVideoEnabled ? Colors.white24 : Colors.red,
              onPressed: onToggleVideo,
              tooltip: isVideoEnabled ? 'Turn off camera' : 'Turn on camera',
            ),
            _buildControlButton(
              icon: Icons.cameraswitch_rounded,
              backgroundColor: Colors.white24,
              onPressed: onSwitchCamera,
              tooltip: 'Switch camera',
            ),
            _buildControlButton(
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              size: 28,
              onPressed: onLeaveCall,
              tooltip: 'End call',
            ),
            _buildControlButton(
              icon: Icons.people_rounded,
              backgroundColor: Colors.white24,
              onPressed: onShowParticipants,
              tooltip: 'Participants',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    double size = 24,
    String tooltip = '',
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor, size: size),
          onPressed: onPressed,
        ),
      ),
    );
  }
}