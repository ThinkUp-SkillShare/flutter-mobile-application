import 'package:flutter/material.dart';

class ParticipantListWidget extends StatelessWidget {
  final List<String> participants;
  final String userId;

  const ParticipantListWidget({
    super.key,
    required this.participants,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              itemCount: participants.length + 1,
              itemBuilder: (context, index) {
                final isMe = index == 0;
                final participantId = isMe ? userId : participants[index - 1];

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
              'Total participants: ${participants.length + 1}',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}