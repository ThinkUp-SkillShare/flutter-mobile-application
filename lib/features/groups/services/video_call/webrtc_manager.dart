import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Manages WebRTC peer connections, media streams, and ICE candidate exchange
/// for mesh-based video conferencing.
class WebRTCManager {
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, MediaStream> _remoteStreams = {};

  MediaStream? _localStream;
  final String localUserId;
  final Function(String, MediaStream) onRemoteStreamAdded;
  final Function(String) onRemoteStreamRemoved;
  final Function(RTCIceCandidate, String) onIceCandidate;

  /// Configuration for ICE servers (STUN)
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  /// SDP constraints for peer connections
  static const Map<String, dynamic> sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  WebRTCManager({
    required this.localUserId,
    required this.onRemoteStreamAdded,
    required this.onRemoteStreamRemoved,
    required this.onIceCandidate,
  });

  /// Initializes local media stream with camera and microphone access.
  Future<MediaStream> initializeLocalMedia({
    bool audio = true,
    bool video = true,
    bool frontCamera = true,
  }) async {
    final constraints = {
      'audio': audio,
      'video': video
          ? {
        'facingMode': frontCamera ? 'user' : 'environment',
        'width': {'ideal': 640},
        'height': {'ideal': 480},
        'frameRate': {'ideal': 30},
      }
          : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    return _localStream!;
  }

  /// Creates a peer connection for communication with a remote user.
  Future<RTCPeerConnection> createPeerConnectionForUser(
      String remoteUserId, {
        required bool initiateOffer,
      }) async {
    // Clean up existing connection if any
    await _cleanupPeer(remoteUserId);

    // Use WebRTC's createPeerConnection function
    final pc = await createPeerConnection(iceServers, sdpConstraints);
    _peerConnections[remoteUserId] = pc;

    // Add local tracks if available
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        pc.addTrack(track, _localStream!);
      }
    }

    // Set up event handlers
    pc.onIceCandidate = (candidate) {
      onIceCandidate(candidate, remoteUserId);
    };

    pc.onAddStream = (stream) {
      _remoteStreams[remoteUserId] = stream;
      onRemoteStreamAdded(remoteUserId, stream);
    };

    pc.onRemoveStream = (stream) {
      _remoteStreams.remove(remoteUserId);
      onRemoteStreamRemoved(remoteUserId);
    };

    // Create offer if initiating
    if (initiateOffer) {
      final offer = await pc.createOffer(sdpConstraints);
      await pc.setLocalDescription(offer);
    }

    return pc;
  }

  /// Handles incoming SDP offer from a remote peer.
  Future<RTCSessionDescription> handleOffer(
      String remoteUserId,
      dynamic offerData,
      ) async {
    final pc = await createPeerConnectionForUser(
      remoteUserId,
      initiateOffer: false,
    );

    await pc.setRemoteDescription(RTCSessionDescription(
      offerData['sdp'],
      offerData['type'],
    ));

    final answer = await pc.createAnswer(sdpConstraints);
    await pc.setLocalDescription(answer);

    return answer;
  }

  /// Handles incoming SDP answer from a remote peer.
  Future<void> handleAnswer(
      String remoteUserId,
      dynamic answerData,
      ) async {
    final pc = _peerConnections[remoteUserId];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(
        answerData['sdp'],
        answerData['type'],
      ));
    }
  }

  /// Handles incoming ICE candidate from a remote peer.
  Future<void> handleIceCandidate(
      String remoteUserId,
      dynamic candidateData,
      ) async {
    final pc = _peerConnections[remoteUserId];
    if (pc != null) {
      await pc.addCandidate(RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      ));
    }
  }

  /// Switches camera between front and back.
  Future<void> switchCamera() async {
    if (_localStream == null) return;

    final videoTrack = _localStream!.getVideoTracks().first;

    // Get current facing mode
    final constraints = videoTrack.getConstraints();
    final currentFacingMode = constraints['facingMode'] ?? 'user';
    final isFrontCamera = currentFacingMode == 'user';

    final newConstraints = {
      'video': {
        'facingMode': isFrontCamera ? 'environment' : 'user',
      },
    };

    final newStream = await navigator.mediaDevices.getUserMedia(newConstraints);
    final newVideoTrack = newStream.getVideoTracks().first;

    // Replace track in all peer connections
    for (final pc in _peerConnections.values) {
      final senders = await pc.getSenders();
      for (final sender in senders) {
        if (sender.track?.kind == 'video') {
          await sender.replaceTrack(newVideoTrack);
          break;
        }
      }
    }

    // Update local stream
    _localStream!.removeTrack(videoTrack);
    _localStream!.addTrack(newVideoTrack);

    // Clean up old track
    videoTrack.stop();
  }

  /// Toggles local audio mute state.
  void toggleAudio(bool mute) {
    if (_localStream != null) {
      for (final track in _localStream!.getAudioTracks()) {
        track.enabled = !mute;
      }
    }
  }

  /// Toggles local video state.
  void toggleVideo(bool enable) {
    if (_localStream != null) {
      for (final track in _localStream!.getVideoTracks()) {
        track.enabled = enable;
      }
    }
  }

  /// Cleans up resources for a specific peer.
  Future<void> _cleanupPeer(String userId) async {
    if (_peerConnections.containsKey(userId)) {
      await _peerConnections[userId]!.close();
      _peerConnections.remove(userId);
    }
    if (_remoteRenderers.containsKey(userId)) {
      await _remoteRenderers[userId]!.dispose();
      _remoteRenderers.remove(userId);
    }
    _remoteStreams.remove(userId);
  }

  /// Disposes all resources and cleans up connections.
  Future<void> dispose() async {
    for (final userId in _peerConnections.keys.toList()) {
      await _cleanupPeer(userId);
    }

    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        track.stop();
      }
      _localStream!.dispose();
      _localStream = null;
    }
  }

  /// Gets the current peer connection for a user.
  RTCPeerConnection? getPeerConnection(String userId) => _peerConnections[userId];

  /// Gets all active peer connections.
  Map<String, RTCPeerConnection> get peerConnections => Map.from(_peerConnections);

  /// Getter for local stream
  MediaStream? get localStream => _localStream;
}