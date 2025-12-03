import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoGridWidget extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers;
  final List<String> participants;
  final String userId;
  final bool isFrontCamera;

  const VideoGridWidget({
    super.key,
    required this.localRenderer,
    required this.remoteRenderers,
    required this.participants,
    required this.userId,
    required this.isFrontCamera,
  });

  @override
  Widget build(BuildContext context) {
    final videoViews = _buildVideoViews();

    if (videoViews.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.count(
      crossAxisCount: videoViews.length > 2 ? 2 : 1,
      childAspectRatio: videoViews.length > 2 ? 1.0 : 1.3,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: videoViews,
    );
  }

  List<Widget> _buildVideoViews() {
    final List<Widget> views = [];

    // Add remote videos
    remoteRenderers.forEach((id, renderer) {
      views.add(_buildVideoItem(
        renderer,
        isLocal: false,
        userId: id,
        isFrontCamera: false,
      ));
    });

    // Add local video
    if (localRenderer.srcObject != null) {
      views.add(_buildVideoItem(
        localRenderer,
        isLocal: true,
        userId: userId,
        isFrontCamera: isFrontCamera,
      ));
    }

    return views;
  }

  Widget _buildVideoItem(
      RTCVideoRenderer renderer, {
        required bool isLocal,
        required String userId,
        required bool isFrontCamera,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isLocal ? Colors.blue : Colors.green,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            RTCVideoView(
              renderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: isLocal && isFrontCamera,
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.black54,
                child: Text(
                  isLocal ? 'Me' : 'User $userId',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              participants.isEmpty
                  ? 'Waiting for participants...'
                  : 'Connecting...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            if (participants.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${participants.length} participant(s) in call',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}