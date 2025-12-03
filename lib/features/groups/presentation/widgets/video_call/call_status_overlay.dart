import 'package:flutter/material.dart';

class CallStatusOverlay extends StatelessWidget {
  final String groupName;
  final int participantCount;
  final bool isConnected;

  const CallStatusOverlay({
    super.key,
    required this.groupName,
    required this.participantCount,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
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
              groupName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Participants: $participantCount',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            if (!isConnected) ...[
              const SizedBox(height: 4),
              const Text(
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
}