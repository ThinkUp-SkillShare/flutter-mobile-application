import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../auth/application/auth_service.dart';
import '../../../services/video_call/call_service.dart';
import '../../../services/video_call/video_call_websocket_service.dart';
import '../../../services/video_call/webrtc_manager.dart';

import '../../widgets/video_call/call_status_overlay.dart';
import '../../widgets/video_call/control_buttons_widget.dart';
import '../../widgets/video_call/participant_list_widget.dart';
import '../../widgets/video_call/video_grid_widget.dart';

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
  // Services
  late VideoCallWebSocketService _webSocketService;
  late WebRTCManager _webRTCManager;

  // State
  String? _callId;
  String? _userId;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isConnected = false;

  // Media
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final List<String> _participants = [];

  // Stream controllers
  final StreamController<String> _errorStreamController = StreamController<String>();
  final StreamController<bool> _callStatusStreamController = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Initializes the call by setting up media, services, and connections.
  Future<void> _initializeCall() async {
    try {
      await _initializeRenderers();
      await _initializeUserInfo();
      await _initializeCallServices();
      await _initializeMedia();
      await _connectToCall();

      setState(() => _isLoading = false);
    } catch (e) {
      _handleError('Failed to initialize call: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  /// Initializes video renderers.
  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
  }

  /// Retrieves user authentication information.
  Future<void> _initializeUserInfo() async {
    final token = await AuthService.getAuthToken();
    final uid = await AuthService.getUserId();

    if (token == null || uid == null) {
      throw Exception('Authentication required');
    }

    _userId = uid.toString();
  }

  /// Initializes WebSocket and WebRTC services.
  Future<void> _initializeCallServices() async {
    final token = await AuthService.getAuthToken();
    _callId = await CallService.createOrJoinCall(widget.groupId, token!);

    if (_callId == null) {
      throw Exception('Could not create or join call');
    }

    _webSocketService = VideoCallWebSocketService(
      callId: _callId!,
      userId: _userId!,
    );

    _webRTCManager = WebRTCManager(
      localUserId: _userId!,
      onRemoteStreamAdded: _handleRemoteStreamAdded,
      onRemoteStreamRemoved: _handleRemoteStreamRemoved,
      onIceCandidate: _handleLocalIceCandidate,
    );

    _setupWebSocketListeners();
  }

  /// Initializes local media (camera and microphone).
  Future<void> _initializeMedia() async {
    await _webRTCManager.initializeLocalMedia(
      audio: true,
      video: true,
      frontCamera: _isFrontCamera,
    );
    _localRenderer.srcObject = _webRTCManager.localStream;
  }

  /// Connects to the call via WebSocket.
  Future<void> _connectToCall() async {
    await _webSocketService.connect();
    _webSocketService.sendSignalingMessage(
      type: 'user-joined',
      data: {'userId': _userId},
    );
    setState(() => _isConnected = true);
  }

  /// Sets up WebSocket message listeners.
  void _setupWebSocketListeners() {
    _webSocketService.messageStream.listen(_handleWebSocketMessage);
  }

  /// Handles incoming WebSocket messages for signaling.
  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final senderId = message['senderId']?.toString();
    final targetId = message['targetUserId']?.toString();
    final callId = message['callId']?.toString();

    // Validate message
    if (callId != _callId || senderId == _userId) return;
    if (targetId != null && targetId != _userId) return;

    switch (type) {
      case 'user-joined':
        _handleParticipantJoined(senderId!);
        _initiatePeerConnection(senderId);
        break;
      case 'user-left':
        _handleParticipantLeft(senderId!);
        break;
      case 'offer':
        _handleRemoteOffer(senderId!, message['data']);
        break;
      case 'answer':
        _handleRemoteAnswer(senderId!, message['data']);
        break;
      case 'ice-candidate':
        _handleRemoteIceCandidate(senderId!, message['data']);
        break;
    }
  }

  /// Handles new participant joining the call.
  void _handleParticipantJoined(String userId) {
    if (!_participants.contains(userId)) {
      setState(() => _participants.add(userId));
    }
  }

  /// Handles participant leaving the call.
  void _handleParticipantLeft(String userId) {
    setState(() => _participants.remove(userId));
    _removeRemoteParticipant(userId);
  }

  /// Initiates peer connection with a new participant.
  void _initiatePeerConnection(String remoteUserId) async {
    final pc = await _webRTCManager.createPeerConnectionForUser(
      remoteUserId,
      initiateOffer: true,
    );

    final offer = await pc.createOffer(WebRTCManager.sdpConstraints);
    await pc.setLocalDescription(offer);

    _webSocketService.sendSignalingMessage(
      type: 'offer',
      data: {
        'sdp': offer.sdp,
        'type': offer.type,
      },
      targetUserId: remoteUserId,
    );
  }

  /// Handles remote SDP offer.
  Future<void> _handleRemoteOffer(String senderId, dynamic offerData) async {
    final answer = await _webRTCManager.handleOffer(senderId, offerData);

    _webSocketService.sendSignalingMessage(
      type: 'answer',
      data: {
        'sdp': answer.sdp,
        'type': answer.type,
      },
      targetUserId: senderId,
    );
  }

  /// Handles remote SDP answer.
  Future<void> _handleRemoteAnswer(String senderId, dynamic answerData) async {
    await _webRTCManager.handleAnswer(senderId, answerData);
  }

  /// Handles remote ICE candidate.
  Future<void> _handleRemoteIceCandidate(
      String senderId,
      dynamic candidateData,
      ) async {
    await _webRTCManager.handleIceCandidate(senderId, candidateData);
  }

  /// Handles local ICE candidate for sending to remote peers.
  void _handleLocalIceCandidate(RTCIceCandidate candidate, String remoteUserId) {
    _webSocketService.sendSignalingMessage(
      type: 'ice-candidate',
      data: {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      },
      targetUserId: remoteUserId,
    );
  }

  /// Handles remote stream being added.
  void _handleRemoteStreamAdded(String userId, MediaStream stream) async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    renderer.srcObject = stream;

    setState(() {
      _remoteRenderers[userId] = renderer;
      _callStatusStreamController.add(true);
    });
  }

  /// Handles remote stream being removed.
  void _handleRemoteStreamRemoved(String userId) {
    _removeRemoteParticipant(userId);
    _callStatusStreamController.add(_remoteRenderers.isNotEmpty);
  }

  /// Removes a remote participant and cleans up resources.
  void _removeRemoteParticipant(String userId) async {
    if (_remoteRenderers.containsKey(userId)) {
      await _remoteRenderers[userId]!.dispose();
      setState(() => _remoteRenderers.remove(userId));
    }
  }

  /// Toggles audio mute state.
  void _toggleAudio() {
    setState(() => _isMuted = !_isMuted);
    _webRTCManager.toggleAudio(_isMuted);
  }

  /// Toggles video state.
  void _toggleVideo() {
    setState(() => _isVideoEnabled = !_isVideoEnabled);
    _webRTCManager.toggleVideo(_isVideoEnabled);
  }

  /// Switches between front and back camera.
  Future<void> _switchCamera() async {
    try {
      await _webRTCManager.switchCamera();
      setState(() => _isFrontCamera = !_isFrontCamera);
    } catch (e) {
      _handleError('Failed to switch camera');
    }
  }

  /// Leaves the call and cleans up resources.
  Future<void> _leaveCall() async {
    try {
      _webSocketService.sendSignalingMessage(
        type: 'user-left',
        data: {'userId': _userId},
      );

      final token = await AuthService.getAuthToken();
      if (token != null) {
        await CallService.endCall(widget.groupId, token);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  /// Cleans up all resources.
  Future<void> _cleanupResources() async {
    await _webSocketService.disconnect();
    await _webRTCManager.dispose();
    await _localRenderer.dispose();

    for (final renderer in _remoteRenderers.values) {
      await renderer.dispose();
    }

    _errorStreamController.close();
    _callStatusStreamController.close();
  }

  /// Displays error messages to the user.
  void _handleError(String message) {
    if (!_errorStreamController.isClosed) {
      _errorStreamController.add(message);
    }

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _leaveCall,
        ),
        title: Text(
          widget.groupName,
          style: const TextStyle(color: Colors.white),
        ),
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
          // Video grid
          VideoGridWidget(
            localRenderer: _localRenderer,
            remoteRenderers: _remoteRenderers,
            participants: _participants,
            userId: _userId!,
            isFrontCamera: _isFrontCamera,
          ),

          // Status overlay
          CallStatusOverlay(
            groupName: widget.groupName,
            participantCount: _participants.length + 1,
            isConnected: _isConnected,
          ),

          // Control buttons
          ControlButtonsWidget(
            isMuted: _isMuted,
            isVideoEnabled: _isVideoEnabled,
            onToggleAudio: _toggleAudio,
            onToggleVideo: _toggleVideo,
            onSwitchCamera: _switchCamera,
            onLeaveCall: _leaveCall,
            onShowParticipants: () => showModalBottomSheet(
              context: context,
              builder: (context) => ParticipantListWidget(
                participants: _participants,
                userId: _userId!,
              ),
            ),
          ),

          // Error stream listener
          StreamBuilder<String>(
            stream: _errorStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleError(snapshot.data!);
                });
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}