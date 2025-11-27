import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../auth/application/auth_service.dart';
import '../../services/call_service.dart';

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
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  WebSocketChannel? _channel;
  bool _isCallActive = false;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _isVideoOff = false;
  List<String> _participants = [];
  String? _callId;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> _constraints = {
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
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _channel?.sink.close();
    _peerConnection?.close();
    _localStream?.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _initializeCall() async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) throw Exception('No auth token');

      // Crear sala de llamada
      final roomData = await CallService.createCallRoom(widget.groupId, token);
      _callId = roomData['callId'];

      // Conectar al WebSocket
      _connectToWebSocket();

      // Inicializar WebRTC
      await _createPeerConnection();
      await _getUserMedia();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error initializing call: $e');
      _showError('Failed to initialize call: $e');
    }
  }

  void _connectToWebSocket() {
    final token = AuthService.getAuthToken();
    _channel = WebSocketChannel.connect(
      Uri.parse(
        'ws://10.0.2.2:5000/ws/${widget.groupId}',
      ),
    );

    _channel!.stream.listen(
      _handleSignalingMessage,
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket closed'),
    );
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _sendSignalingMessage({
        'type': 'ice-candidate',
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'sdpMid': candidate.sdpMid,
        },
      });
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      print('Remote stream added');
      setState(() {
        _remoteRenderer.srcObject = stream;
        _isCallActive = true;
      });
    };

    _peerConnection!.onRemoveStream = (MediaStream stream) {
      print('Remote stream removed');
      setState(() {
        _remoteRenderer.srcObject = null;
        _isCallActive = false;
      });
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        setState(() => _isCallActive = true);
      } else if (state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        setState(() => _isCallActive = false);
      }
    };
  }

  Future<void> _getUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      },
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;

    // Agregar stream local a la conexión
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  void _handleSignalingMessage(dynamic message) {
    try {
      final data = json.decode(message);
      final type = data['type'];
      final senderId = data['senderId'];

      print('Received signaling message: $type from $senderId');

      switch (type) {
        case 'offer':
          _handleOffer(data['data']);
          break;
        case 'answer':
          _handleAnswer(data['data']);
          break;
        case 'ice-candidate':
          _handleIceCandidate(data['data']);
          break;
        case 'user-joined':
          _handleUserJoined(data['data']);
          break;
        case 'user-left':
          _handleUserLeft(data['data']);
          break;
      }
    } catch (e) {
      print('Error handling signaling message: $e');
    }
  }

  void _sendSignalingMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }

  Future<void> _handleOffer(dynamic offerData) async {
    try {
      final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);

      await _peerConnection!.setRemoteDescription(offer);
      final answer = await _peerConnection!.createAnswer(_constraints);
      await _peerConnection!.setLocalDescription(answer);

      _sendSignalingMessage({
        'type': 'answer',
        'answer': {'sdp': answer.sdp, 'type': answer.type},
      });
    } catch (e) {
      print('Error handling offer: $e');
    }
  }

  Future<void> _handleAnswer(dynamic answerData) async {
    try {
      final answer = RTCSessionDescription(
        answerData['sdp'],
        answerData['type'],
      );
      await _peerConnection!.setRemoteDescription(answer);
    } catch (e) {
      print('Error handling answer: $e');
    }
  }

  Future<void> _handleIceCandidate(dynamic candidateData) async {
    try {
      final candidate = RTCIceCandidate(
        candidateData['candidate']['candidate'],
        candidateData['candidate']['sdpMid'],
        candidateData['candidate']['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      print('Error handling ICE candidate: $e');
    }
  }

  void _handleUserJoined(dynamic userData) {
    final userId = userData['userId'];
    setState(() {
      _participants.add(userId);
    });
  }

  void _handleUserLeft(dynamic userData) {
    final userId = userData['userId'];
    setState(() {
      _participants.remove(userId);
    });
  }

  Future<void> _startCall() async {
    try {
      final offer = await _peerConnection!.createOffer(_constraints);
      await _peerConnection!.setLocalDescription(offer);

      _sendSignalingMessage({
        'type': 'offer',
        'offer': {'sdp': offer.sdp, 'type': offer.type},
      });

      _sendSignalingMessage({
        'type': 'user-joined',
        'userId': await AuthService.getUserId(),
      });
    } catch (e) {
      print('Error starting call: $e');
      _showError('Failed to start call: $e');
    }
  }

  Future<void> _endCall() async {
    try {
      final token = await AuthService.getAuthToken();
      if (token != null) {
        await CallService.endCall(widget.groupId, token);
      }

      _sendSignalingMessage({
        'type': 'user-left',
        'userId': await AuthService.getUserId(),
      });

      _channel?.sink.close();
      _peerConnection?.close();
      _localStream?.dispose();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error ending call: $e');
    }
  }

  void _toggleMute() {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        audioTracks.first.enabled = !_isMuted;
        setState(() => _isMuted = !_isMuted);
      }
    }
  }

  void _toggleVideo() {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        videoTracks.first.enabled = !_isVideoOff;
        setState(() => _isVideoOff = !_isVideoOff);
      }
    }
  }

  void _switchCamera() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      // Helper method para cambiar cámara (depende de la implementación específica)
      // videoTrack.switchCamera();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                // Video remoto (pantalla completa)
                if (_isCallActive && _remoteRenderer.srcObject != null)
                  RTCVideoView(_remoteRenderer)
                else
                  Container(
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
                            'Waiting for participants...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Video local (picture-in-picture)
                Positioned(
                  top: 50,
                  right: 20,
                  width: 120,
                  height: 160,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _localRenderer.srcObject != null
                          ? RTCVideoView(_localRenderer)
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                ),

                // Header con información
                Positioned(
                  top: 50,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                        Text(
                          'Participants: ${_participants.length + 1}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Controles en la parte inferior
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botón micrófono
                        _buildControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          backgroundColor: _isMuted
                              ? Colors.red
                              : Colors.white24,
                          onPressed: _toggleMute,
                        ),

                        // Botón video
                        _buildControlButton(
                          icon: _isVideoOff
                              ? Icons.videocam_off
                              : Icons.videocam,
                          backgroundColor: _isVideoOff
                              ? Colors.red
                              : Colors.white24,
                          onPressed: _toggleVideo,
                        ),

                        // Botón iniciar/terminar llamada
                        _buildControlButton(
                          icon: _isCallActive ? Icons.call_end : Icons.call,
                          backgroundColor: _isCallActive
                              ? Colors.red
                              : Colors.green,
                          iconColor: Colors.white,
                          size: 28,
                          onPressed: _isCallActive ? _endCall : _startCall,
                        ),

                        // Botón cambiar cámara
                        _buildControlButton(
                          icon: Icons.cameraswitch_rounded,
                          backgroundColor: Colors.white24,
                          onPressed: _switchCamera,
                        ),

                        // Botón participantes
                        _buildControlButton(
                          icon: Icons.people_rounded,
                          backgroundColor: Colors.white24,
                          onPressed: _showParticipants,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    double size = 24,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: size),
        onPressed: onPressed,
      ),
    );
  }

  void _showParticipants() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
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
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe ? Colors.blue : Colors.green,
                      child: Text(
                        isMe ? 'You' : 'U${index}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      isMe ? 'You' : 'User ${_participants[index - 1]}',
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
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
