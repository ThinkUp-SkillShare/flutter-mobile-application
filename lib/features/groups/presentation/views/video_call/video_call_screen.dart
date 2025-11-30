import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../auth/application/auth_service.dart';
import '../../../services/video_call/call_service.dart';

class VideoCallScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const VideoCallScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // Local media state
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;

  // Connection state
  WebSocketChannel? _channel;
  String? _callId;
  String? _myUserId;
  bool _isLoading = true;
  bool _isConnectedToSocket = false;
  bool _isCallActive = false;

  // Multi-peer management (MESH topology)
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};

  // Participants and UI state
  List<String> _participants = [];
  Timer? _connectionTimer;

  // WebRTC configuration
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> _sdpConstraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
    'optional': [],
  };

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _initializeCall();
  }

  @override
  void dispose() {
    _cleanupCall();
    super.dispose();
  }

  // Initialization methods
  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _cleanupCall() async {
    _connectionTimer?.cancel();
    _channel?.sink.close();

    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localRenderer.dispose();

    for (var pc in _peerConnections.values) {
      await pc.close();
    }
    for (var renderer in _remoteRenderers.values) {
      await renderer.dispose();
    }

    _peerConnections.clear();
    _remoteRenderers.clear();
  }

  Future<void> _initializeCall() async {
    try {
      await _getUserMedia();

      final token = await AuthService.getAuthToken();
      final uid = await AuthService.getUserId();
      _myUserId = uid.toString();

      if (token == null || _myUserId == null) throw Exception('Auth failed');

      _callId = await CallService.createOrJoinCall(widget.groupId, token);
      if (_callId == null) throw Exception('Could not get Call ID');

      _connectToWebSocket();

      setState(() => _isLoading = false);
      _sendSignal('user-joined', {'userId': _myUserId});

    } catch (e) {
      _showError('Failed to join call');
      if (mounted) Navigator.pop(context);
    }
  }

  // Media methods
  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': _isFrontCamera ? 'user' : 'environment',
        'optional': [],
      },
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      setState(() {});
    } catch (e) {
      _showError('Failed to access camera/microphone');
    }
  }

  // WebSocket methods
  void _connectToWebSocket() {
    final baseUrl = ApiConstants.isEmulator ? '10.0.2.2:5118' : '192.168.0.206:5118';
    final wsUrl = 'ws://$baseUrl/ws/call/$_callId?userId=$_myUserId';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnectedToSocket = true;

      _channel!.stream.listen(
            (message) => _handleSignalingMessage(message),
        onDone: () {
          if (mounted) _showError('Connection lost');
        },
        onError: (e) {
          if (mounted) _showError('Connection error: $e');
        },
      );
    } catch (e) {
      _showError('Failed to connect to server');
    }
  }

  // Signaling and WebRTC methods
  void _handleSignalingMessage(dynamic message) async {
    try {
      final data = json.decode(message);
      final type = data['type'];
      final senderId = data['senderId']?.toString();
      final targetId = data['targetUserId']?.toString();
      final messageCallId = data['callId']?.toString();

      if (messageCallId != _callId) return;
      if (senderId == _myUserId) return;
      if (targetId != null && targetId != _myUserId) return;

      switch (type) {
        case 'user-joined':
          _handleUserJoined(senderId!);
          _createPeerConnection(senderId, initiate: true);
          break;

        case 'user-left':
          _handleUserLeft(senderId!);
          break;

        case 'offer':
          final offer = data['data'];
          await _handleOffer(senderId!, offer);
          break;

        case 'answer':
          final answer = data['data'];
          await _handleAnswer(senderId!, answer);
          break;

        case 'ice-candidate':
          final candidate = data['data'];
          await _handleIceCandidate(senderId!, candidate);
          break;
      }
    } catch (e) {
      // Handle signaling error
    }
  }

  void _handleUserJoined(String userId) {
    if (!_participants.contains(userId)) {
      setState(() {
        _participants.add(userId);
      });
    }
  }

  void _handleUserLeft(String userId) {
    setState(() {
      _participants.remove(userId);
    });
    _removePeer(userId);
  }

  Future<RTCPeerConnection> _createPeerConnection(
      String remoteUserId, {
        required bool initiate,
      }) async {
    if (_peerConnections.containsKey(remoteUserId)) {
      await _peerConnections[remoteUserId]!.close();
    }

    final pc = await createPeerConnection(_iceServers, _sdpConstraints);
    _peerConnections[remoteUserId] = pc;

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        pc.addTrack(track, _localStream!);
      });
    }

    pc.onIceCandidate = (candidate) {
      _sendSignal('ice-candidate', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      }, targetUserId: remoteUserId);
    };

    pc.onAddStream = (stream) {
      _addRemoteRenderer(remoteUserId, stream);
      _setCallActive(true);
    };

    pc.onRemoveStream = (stream) {
      _setCallActive(_remoteRenderers.isNotEmpty);
    };

    pc.onConnectionState = (RTCPeerConnectionState state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _setCallActive(true);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _setCallActive(_remoteRenderers.isNotEmpty);
      }
    };

    if (initiate) {
      final offer = await pc.createOffer(_sdpConstraints);
      await pc.setLocalDescription(offer);
      _sendSignal('offer', {
        'sdp': offer.sdp,
        'type': offer.type,
      }, targetUserId: remoteUserId);
    }

    return pc;
  }

  Future<void> _handleOffer(String senderId, dynamic offerData) async {
    final pc = await _createPeerConnection(senderId, initiate: false);

    await pc.setRemoteDescription(RTCSessionDescription(
      offerData['sdp'],
      offerData['type'],
    ));

    final answer = await pc.createAnswer(_sdpConstraints);
    await pc.setLocalDescription(answer);

    _sendSignal('answer', {
      'sdp': answer.sdp,
      'type': answer.type,
    }, targetUserId: senderId);
  }

  Future<void> _handleAnswer(String senderId, dynamic answerData) async {
    final pc = _peerConnections[senderId];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(
        answerData['sdp'],
        answerData['type'],
      ));
    }
  }

  Future<void> _handleIceCandidate(String senderId, dynamic candidateData) async {
    final pc = _peerConnections[senderId];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      ));
    }
  }

  void _addRemoteRenderer(String userId, MediaStream stream) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = stream;
    setState(() {
      _remoteRenderers[userId] = renderer;
    });
  }

  void _removePeer(String userId) async {
    if (_remoteRenderers.containsKey(userId)) {
      await _remoteRenderers[userId]!.dispose();
      setState(() {
        _remoteRenderers.remove(userId);
      });
    }

    if (_peerConnections.containsKey(userId)) {
      await _peerConnections[userId]!.close();
      _peerConnections.remove(userId);
    }

    _setCallActive(_remoteRenderers.isNotEmpty);
  }

  void _setCallActive(bool active) {
    if (_isCallActive != active) {
      setState(() {
        _isCallActive = active;
      });
    }
  }

  void _sendSignal(String type, dynamic data, {String? targetUserId}) {
    if (_channel == null || _channel!.sink == null) return;

    try {
      final msg = {
        'type': type,
        'data': data,
        'senderId': _myUserId,
        'targetUserId': targetUserId,
        'callId': _callId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      _channel!.sink.add(json.encode(msg));
    } catch (e) {
      // Handle send error
    }
  }

  // UI Control methods
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
  }

  void _toggleVideo() {
    setState(() {
      _isVideoOff = !_isVideoOff;
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = !_isVideoOff;
      });
    });
  }

  Future<void> _switchCamera() async {
    if (_localStream == null) return;

    try {
      final constraints = {
        'video': {'facingMode': _isFrontCamera ? 'environment' : 'user'},
      };

      final newStream = await navigator.mediaDevices.getUserMedia(constraints);
      final newVideoTrack = newStream.getVideoTracks().first;

      for (var pc in _peerConnections.values) {
        final senders = await pc.getSenders();
        final videoSender = senders.firstWhere((s) => s.track?.kind == 'video');
        await videoSender.replaceTrack(newVideoTrack);
      }

      _localStream!.removeTrack(_localStream!.getVideoTracks().first);
      _localStream!.addTrack(newVideoTrack);
      _localRenderer.srcObject = _localStream;

      final oldTracks = newStream.getTracks();
      for (var track in oldTracks) {
        if (track != newVideoTrack) {
          track.stop();
        }
      }

      setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      _showError('Failed to switch camera');
    }
  }

  Future<void> _leaveCall() async {
    try {
      _sendSignal('user-left', {'userId': _myUserId});

      final token = await AuthService.getAuthToken();
      if (token != null) {
        await CallService.endCall(widget.groupId, token);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  void _showParticipants() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _participants.length + 1,
                itemBuilder: (context, index) {
                  final isMe = index == 0;
                  final participantId = isMe ? _myUserId : _participants[index - 1];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe ? Colors.blue : Colors.green,
                      child: Text(
                        isMe ? 'You' : 'U${index}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      isMe ? 'You (Me)' : 'User $participantId',
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      isMe ? 'Connected' : 'In call',
                      style: TextStyle(
                        color: isMe ? Colors.blue : Colors.green,
                      ),
                    ),
                    trailing: isMe
                        ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total participants: ${_participants.length + 1}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helper methods
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showInfo(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _leaveCall,
        ),
        title: Text(widget.groupName, style: const TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing call...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          _buildVideoGrid(),
          _buildParticipantInfo(),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final List<Widget> videoViews = [];

    _remoteRenderers.forEach((id, renderer) {
      videoViews.add(_buildVideoItem(renderer, isLocal: false, userId: id));
    });

    if (_localRenderer.srcObject != null) {
      videoViews.add(_buildLocalVideoOverlay());
    }

    if (videoViews.isEmpty) {
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
                _participants.isEmpty ? 'Waiting for participants...' : 'Connecting...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              if (_participants.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${_participants.length} participant(s) in call',
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

    return GridView.count(
      crossAxisCount: videoViews.length > 2 ? 2 : 1,
      childAspectRatio: videoViews.length > 2 ? 1.0 : 1.3,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: videoViews,
    );
  }

  Widget _buildVideoItem(RTCVideoRenderer renderer, {required bool isLocal, String? userId}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isLocal ? Colors.blue : Colors.green, width: 2),
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
              mirror: isLocal && _isFrontCamera,
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
            if (isLocal) _buildLocalStatusIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalStatusIndicators() {
    return Positioned(
      top: 5,
      left: 5,
      child: Row(
        children: [
          if (_isMuted)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_off,
                size: 12,
                color: Colors.white,
              ),
            ),
          if (_isVideoOff)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off,
                size: 12,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocalVideoOverlay() {
    return Positioned(
      top: 80,
      right: 20,
      width: 120,
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isCallActive ? Colors.green : Colors.orange,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              RTCVideoView(_localRenderer),
              _buildLocalStatusIndicators(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantInfo() {
    return Positioned(
      top: 80,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Participants: ${_participants.length + 1}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            if (!_isCallActive && _remoteRenderers.isEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Connecting...',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
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
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              backgroundColor: _isMuted ? Colors.red : Colors.white24,
              onPressed: _toggleMute,
              tooltip: _isMuted ? 'Unmute' : 'Mute',
            ),
            _buildControlButton(
              icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
              backgroundColor: _isVideoOff ? Colors.red : Colors.white24,
              onPressed: _toggleVideo,
              tooltip: _isVideoOff ? 'Turn on camera' : 'Turn off camera',
            ),
            _buildControlButton(
              icon: Icons.cameraswitch_rounded,
              backgroundColor: Colors.white24,
              onPressed: _switchCamera,
              tooltip: 'Switch camera',
            ),
            _buildControlButton(
              icon: Icons.call_end,
              backgroundColor: Colors.red,
              iconColor: Colors.white,
              size: 28,
              onPressed: _leaveCall,
              tooltip: 'End call',
            ),
            _buildControlButton(
              icon: Icons.people_rounded,
              backgroundColor: Colors.white24,
              onPressed: _showParticipants,
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