import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../core/constants/api_constants.dart';
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
  // --- Estado Local ---
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;

  // --- Estado de Conexión ---
  WebSocketChannel? _channel;
  String? _callId;
  String? _myUserId;
  bool _isLoading = true;
  bool _isConnectedToSocket = false;
  bool _isCallActive = false;

  // --- Multi-Peer Management (MESH Topology) ---
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};

  // --- Estado de participantes y UI ---
  List<String> _participants = [];
  Timer? _connectionTimer;

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

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _cleanupCall() async {
    _connectionTimer?.cancel();

    // Cerrar WebSocket
    _channel?.sink.close();

    // Detener Stream Local
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localRenderer.dispose();

    // Cerrar todas las conexiones remotas
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
      // 1. Obtener media local
      await _getUserMedia();

      final token = await AuthService.getAuthToken();
      final uid = await AuthService.getUserId();
      _myUserId = uid.toString();

      if (token == null || _myUserId == null) throw Exception('Auth failed');

      // 2. Unirse o Crear Room en Backend
      _callId = await CallService.createOrJoinCall(widget.groupId, token);
      if (_callId == null) throw Exception('Could not get Call ID');

      // 3. Conectar WebSocket
      _connectToWebSocket();

      setState(() => _isLoading = false);

      // Notificar que el usuario se unió
      _sendSignal('user-joined', {'userId': _myUserId});

    } catch (e) {
      print('❌ Initialization error: $e');
      _showError('Failed to join call');
      if (mounted) Navigator.pop(context);
    }
  }

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
      print('❌ Error getting user media: $e');
      _showError('Failed to access camera/microphone');
    }
  }

  void _connectToWebSocket() {
    final baseUrl = ApiConstants.isEmulator ? '10.0.2.2:5118' : '192.168.0.206:5118';
    final wsUrl = 'ws://$baseUrl/ws/call/$_callId?userId=$_myUserId';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnectedToSocket = true;
      print('✅ WebSocket Connected');

      _channel!.stream.listen(
            (message) => _handleSignalingMessage(message),
        onDone: () {
          print('📞 WebSocket connection closed');
          if (mounted) _showError('Connection lost');
        },
        onError: (e) {
          print('❌ WebSocket Error: $e');
          if (mounted) _showError('Connection error: $e');
        },
      );
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _showError('Failed to connect to server');
    }
  }

  // --- Señalización y Lógica P2P ---

  void _handleSignalingMessage(dynamic message) async {
    try {
      final data = json.decode(message);
      final type = data['type'];
      final senderId = data['senderId']?.toString();
      final targetId = data['targetUserId']?.toString();
      final messageCallId = data['callId']?.toString();

      // Verificar que el mensaje es para esta llamada
      if (messageCallId != _callId) {
        print('🔄 Ignoring message for different call: $messageCallId');
        return;
      }

      // Ignorar mis propios mensajes
      if (senderId == _myUserId) return;

      // Si el mensaje tiene destinatario específico y no soy yo, ignorar
      if (targetId != null && targetId != _myUserId) return;

      print('📩 Signal received: $type from $senderId');

      switch (type) {
        case 'user-joined':
          _handleUserJoined(senderId!);
          // Alguien nuevo entró. YO (que ya estoy dentro) debo iniciar conexión con él.
          _createPeerConnection(senderId, initiate: true);
          break;

        case 'user-left':
          _handleUserLeft(senderId!);
          break;

        case 'offer':
          final offer = data['data'];
          // Recibo oferta, debo responder.
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
      print('❌ Error handling signaling message: $e');
    }
  }

  void _handleUserJoined(String userId) {
    if (!_participants.contains(userId)) {
      print('👤 User joined: $userId');
      setState(() {
        _participants.add(userId);
      });
      _showSuccess('User $userId joined the call');
    }
  }

  void _handleUserLeft(String userId) {
    print('👤 User left: $userId');
    setState(() {
      _participants.remove(userId);
    });
    _removePeer(userId);
    _showInfo('User $userId left the call');
  }

  // Crea una conexión P2P para un usuario específico
  Future<RTCPeerConnection> _createPeerConnection(String remoteUserId, {required bool initiate}) async {
    print('🔄 Creating PC for user: $remoteUserId (Initiator: $initiate)');

    // Si ya existe, cerrarla para reiniciar (evita estados corruptos)
    if (_peerConnections.containsKey(remoteUserId)) {
      await _peerConnections[remoteUserId]!.close();
    }

    final pc = await createPeerConnection(_iceServers, _sdpConstraints);
    _peerConnections[remoteUserId] = pc;

    // Agregar tracks locales a esta conexión
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        pc.addTrack(track, _localStream!);
      });
    }

    // Configurar callbacks
    pc.onIceCandidate = (candidate) {
      _sendSignal('ice-candidate', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      }, targetUserId: remoteUserId);
    };

    pc.onAddStream = (stream) {
      print('📹 Stream received from $remoteUserId');
      _addRemoteRenderer(remoteUserId, stream);
      _setCallActive(true);
    };

    pc.onRemoveStream = (stream) {
      print('📹 Stream removed from $remoteUserId');
      _setCallActive(_remoteRenderers.isNotEmpty);
    };

    pc.onConnectionState = (RTCPeerConnectionState state) {
      print('🔗 Connection state with $remoteUserId: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _setCallActive(true);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _setCallActive(_remoteRenderers.isNotEmpty);
      }
    };

    // Si soy el iniciador (ej: yo ya estaba y entró alguien), creo la oferta
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
    // El otro usuario inició la conexión, creo mi PC pasivo
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
    print('👋 Removing peer $userId');

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
      print('📤 Sent signaling message: $type for call: $_callId');
    } catch (e) {
      print('❌ Error sending signaling message: $e');
    }
  }

  // --- UI Controls ---

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
    _showInfo(_isMuted ? 'Microphone muted' : 'Microphone unmuted');
  }

  void _toggleVideo() {
    setState(() {
      _isVideoOff = !_isVideoOff;
      _localStream?.getVideoTracks().forEach((track) {
        track.enabled = !_isVideoOff;
      });
    });
    _showInfo(_isVideoOff ? 'Camera turned off' : 'Camera turned on');
  }

  Future<void> _switchCamera() async {
    if (_localStream == null) return;

    try {
      final videoTrack = _localStream!.getVideoTracks().first;

      final constraints = {
        'video': {'facingMode': _isFrontCamera ? 'environment' : 'user'},
      };

      // Obtener nuevo stream con la cámara cambiada
      final newStream = await navigator.mediaDevices.getUserMedia(constraints);
      final newVideoTrack = newStream.getVideoTracks().first;

      // Reemplazar el track en todas las conexiones peer
      for (var pc in _peerConnections.values) {
        final senders = await pc.getSenders();
        final videoSender = senders.firstWhere((s) => s.track?.kind == 'video');
        await videoSender.replaceTrack(newVideoTrack);
      }

      // Actualizar el stream local
      _localStream!.removeTrack(_localStream!.getVideoTracks().first);
      _localStream!.addTrack(newVideoTrack);
      _localRenderer.srcObject = _localStream;

      // Dispose del stream anterior
      final oldTracks = newStream.getTracks();
      for (var track in oldTracks) {
        if (track != newVideoTrack) {
          track.stop();
        }
      }

      setState(() => _isFrontCamera = !_isFrontCamera);
      _showInfo('Camera switched to ${_isFrontCamera ? 'front' : 'rear'}');
    } catch (e) {
      print('❌ Error switching camera: $e');
      _showError('Failed to switch camera');
    }
  }

  Future<void> _leaveCall() async {
    try {
      // Enviar mensaje explícito de salida antes de cortar socket
      _sendSignal('user-left', {'userId': _myUserId});

      final token = await AuthService.getAuthToken();
      if (token != null) {
        await CallService.endCall(widget.groupId, token);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Error ending call: $e');
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

  // --- UI Helpers ---

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
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Initializing call...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          // Video Grid (de la versión CORRECTA)
          _buildVideoGrid(),

          // Información de participantes (de la versión ANTIGUA)
          Positioned(
            top: 80,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
          ),

          // Controles mejorados (combinación de ambas versiones)
          Positioned(
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
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final List<Widget> videoViews = [];

    // 1. Agregar Remotos
    _remoteRenderers.forEach((id, renderer) {
      videoViews.add(
        _buildVideoItem(renderer, isLocal: false, userId: id),
      );
    });

    // 2. Agregar Local (picture-in-picture)
    if (_localRenderer.srcObject != null) {
      videoViews.add(
        _buildLocalVideoOverlay(),
      );
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
                _participants.isEmpty
                    ? 'Waiting for participants...'
                    : 'Connecting...',
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

    // Grid para múltiples participantes
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
            // Indicadores de estado (solo para local en grid)
            if (isLocal) ...[
              Positioned(
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
              ),
            ]
          ],
        ),
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
              // Indicadores de estado
              Positioned(
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
              ),
            ],
          ),
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