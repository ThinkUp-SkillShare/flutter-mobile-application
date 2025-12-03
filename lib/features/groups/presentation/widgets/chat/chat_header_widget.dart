import 'package:flutter/material.dart';

class ChatHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String groupName;
  final int messageCount;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const ChatHeaderWidget({
    super.key,
    required this.groupName,
    required this.messageCount,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF324779),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: onBack,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            groupName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Sarabun',
            ),
          ),
          Text(
            '$messageCount messages',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'Sarabun',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}