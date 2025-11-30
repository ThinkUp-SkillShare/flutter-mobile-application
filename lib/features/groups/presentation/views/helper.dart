import 'package:flutter_webrtc/flutter_webrtc.dart';

class Helper {
  static Future<void> switchCamera(MediaStreamTrack videoTrack) async {
    try {
      if (videoTrack is! MediaStreamTrack) {
        throw Exception('Video track does not support camera switching');
      }

      await videoTrack.switchCamera();
    } catch (e) {
      print('Error switching camera: $e');
      throw e;
    }
  }
}